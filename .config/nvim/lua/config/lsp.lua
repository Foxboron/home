-- LSP
local lspconfig = require('lspconfig')
local navic = require('nvim-navic')

local on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

  -- TODO: This spams no code action
  -- vim.api.nvim_create_autocmd("BufWritePre", {
  --   buffer = buffer,
  --   callback = function()
  --     vim.lsp.buf.format()
  --     vim.lsp.buf.code_action { context = { only = { 'source.organizeImports' } }, apply = true }
  --     vim.lsp.buf.code_action { context = { only = { 'source.fixAll' } }, apply = true }
  --   end
  -- })
  vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = { "*.go" },
      callback = function()
          vim.lsp.buf.format()

          local params = vim.lsp.util.make_range_params()
          params.context = {only = {"source.organizeImports"}}
          vim.lsp.buf_request_all(0, "textDocument/codeAction", params, function(responses)
              for client_id, response in pairs(responses) do
                  if response.result then
                      for _, result in pairs(response.result) do
                          if result.edit then
                              vim.lsp.util.apply_workspace_edit(result.edit, vim.lsp.get_client_by_id(client_id).offset_encoding)
                          else
                              vim.lsp.buf.execute_command(result.command)
                          end
                      end
                      -- This routine is async, which I like because it doesn't lock up.
                      -- However, it doesn't complete before the write, so it needs another write.
                      -- The below write() *can* trigger an infinite loop of BufWritePre if the language server acts up.
                      -- See the nvim-lspconfig issue for alternatives: https://github.com/neovim/nvim-lspconfig/issues/115
                      vim.cmd.write()
                  end
              end
          end)
      end,
  })

  -- TODO: Default maps in some future version
  vim.keymap.set('n', 'grn', function()
    vim.lsp.buf.rename()
  end, { desc = 'vim.lsp.buf.rename()' })

  vim.keymap.set({ 'n', 'x' }, 'gra', function()
    vim.lsp.buf.code_action()
  end, { desc = 'vim.lsp.buf.code_action()' })

  vim.keymap.set('n', 'grr', function()
    vim.lsp.buf.references()
  end, { desc = 'vim.lsp.buf.references()' })

  vim.keymap.set('i', '<C-S>', function()
    vim.lsp.buf.signature_help()
  end, { desc = 'vim.lsp.buf.signature_help()' })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.insertReplaceSupport = false
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.gopls.setup{
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities),
  init_options = {
    usePlaceholders = true,
  },
  settings = {
    gopls = {
      gofumpt = true,
      staticcheck = true,
      templateExtensions = { "gotmpl" },
      vulncheck = "Imports",
      analyses = {
        unusedparams = true,
      },
    },
  },
  cmd = { "gopls" },
  filetypes = {"go", "gomod", "gotmpl"},
  single_file_support = true,
}

-- need this as global keymap
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'vim.lsp.buf.hover()' })
