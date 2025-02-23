-- LSP
local lspconfig = require('lspconfig')
local navic = require('nvim-navic')
local builtin = require('telescope.builtin')

local on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

    vim.lsp.handlers['textDocument/codeAction'] = builtin.lsp_code_actions
    vim.lsp.handlers['textDocument/references'] = builtin.lsp_references
    vim.lsp.handlers['textDocument/definition'] = builtin.lsp_definitions
    vim.lsp.handlers['textDocument/typeDefinition'] = builtin.lsp_type_definitions
    vim.lsp.handlers['textDocument/implementation'] = builtin.lsp_implementations
    vim.lsp.handlers['textDocument/documentSymbol'] = builtin.lsp_document_symbols
    vim.lsp.handlers['workspace/symbol'] = builtin.lsp_workspace_symbols

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
      callback = function(event)
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
end


vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

  -- TODO: Default maps in some future version
    map('grn', vim.lsp.buf.rename, 'Code Rename')
    map('gra', vim.lsp.buf.code_action , 'Code Action', {'n', 'x'})
    map('grr', vim.lsp.buf.references , 'References')
    map('<C-S>', vim.lsp.buf.signature_help, 'Signature Help', 'i')
  
    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
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
      completeUnimported = true,
      experimentalPostfixCompletions = true,
      semanticTokens = true,
      staticcheck = true,
      usePlaceholders = true,

      templateExtensions = { "gotmpl" },
      vulncheck = "Imports",
      analyses = {
        modernize = true,
        nilness = true,
        shadow = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
      },
      codelenses = {
          gc_details = false,
          generate = true,
          regenerate_cgo = true,
          run_govulncheck = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
      },
    },
  },
  cmd = { "gopls" },
  filetypes = {"go", "gomod", "gotmpl"},
  single_file_support = true,
}

-- need this as global keymap
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'vim.lsp.buf.hover()' })



