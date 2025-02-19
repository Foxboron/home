-- Telescope
local telescope = require('telescope')
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader><leader>', builtin.buffers, {})
telescope.load_extension('luasnip')
telescope.setup {
    defaults = {
        mappings = {
            i = {
                ["<C-j>"] = require('telescope.actions').move_selection_next,
                ["<C-k>"] = require('telescope.actions').move_selection_previous
            }
        }
    }
}

vim.lsp.handlers['textDocument/codeAction'] = builtin.lsp_code_actions
vim.lsp.handlers['textDocument/references'] = builtin.lsp_references
vim.lsp.handlers['textDocument/definition'] = builtin.lsp_definitions
vim.lsp.handlers['textDocument/typeDefinition'] = builtin.lsp_type_definitions
vim.lsp.handlers['textDocument/implementation'] = builtin.lsp_implementations
vim.lsp.handlers['textDocument/documentSymbol'] = builtin.lsp_document_symbols
vim.lsp.handlers['workspace/symbol'] = builtin.lsp_workspace_symbols
