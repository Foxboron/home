require('config.vimwiki')

vim.cmd("source ~/.config/nvim/plugins.vim")

-- Helpers
-- TODO: Remove and simplify
local opts = { noremap=true, silent=true }
function keymap(key, fun)
  vim.keymap.set('n', key, fun, opts)
end

require('config.settings')

require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "go" },

  highlight = { enable = true },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {
        "navic",
        color_correction = nil,
        navic_opts = nil
    },
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {
    lualine_a = {'buffers'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {'tabs'}
  },
  extensions = {}
}



require('config.telescope')
require('config.cmp')
require('config.lsp')
require('dap-go').setup()
require('config.dap').setup()

-- vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
-- vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
-- vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
-- vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
-- vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
-- vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
-- vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
-- vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
-- vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
-- vim.keymap.set('n', '<Leader>dj', function() require('dap').run_to_cursor() end)
-- vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
--   require('dap.ui.widgets').hover()
-- end)
-- vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
--   require('dap.ui.widgets').preview()
-- end)
-- vim.keymap.set('n', '<Leader>df', function()
--   local widgets = require('dap.ui.widgets')
--   widgets.centered_float(widgets.frames)
-- end)
-- vim.keymap.set('n', '<Leader>ds', function()
--   local widgets = require('dap.ui.widgets')
--   widgets.centered_float(widgets.scopes)
-- end)

require('config.tests')
require('config.git')

-- Git
-- Autocmd
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(args)
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line("$")
    local not_commit = vim.bo[args.buf].filetype ~= "gitcommit"

    if valid_line and not_commit then
      vim.cmd([[normal! g`"]])
    end
  end,
})

-- Stuff for testing
local presets = require("markview.presets");

require("markview").setup({
    markdown = {
        headings = presets.headings.slanted
    },
    preview = {
      filetypes = { "markdown", "vimwiki" },
    },
});

vim.api.nvim_create_autocmd({ "DiagnosticChanged" }, {
    group = vim.api.nvim_create_augroup("user_diagnostic_qflist", {}),
    callback = function(args)
    -- Use pcall because I was getting inconsistent errors when quitting vim.
    -- Possibly timing errors from trying to get/create diagnostics/qflists
    -- that don't exist anymore. DiagnosticChanged fires at some strange times.
    local has_diagnostics, diagnostics = pcall(vim.diagnostic.get)
    local has_qflist, qflist = pcall(vim.fn.getqflist, { title = 0, id = 0, items = 0 })
    if not has_diagnostics or not has_qflist then return end

    -- Sometimes the event fires with an empty diagnostic list in the data.
    -- This conditional prevents re-creating the qflist with the same
    -- diagnostics, which reverts selection to the first item.
    if
      #args.data.diagnostics == 0
      and #diagnostics > 0
      and qflist.title == "All Diagnostics"
      and #qflist.items == #diagnostics
    then
      return
    end

    vim.schedule(function()
      -- If the last qflist was created by this autocmd, replace it so other
      -- lists (e.g., vimgrep results) aren't buried due to diagnostic changes.
      pcall(vim.fn.setqflist, {}, qflist.title == "All Diagnostics" and "r" or " ", {
        title = "All Diagnostics",
        items = vim.diagnostic.toqflist(diagnostics),
      })

      -- Don't steal focus from other qflists. For example, when working
      -- through vimgrep results, you likely want :cnext to take you to the
      -- next match, rather than the next diagnostic. Use :cnew to switch to
      -- the diagnostic qflist when you want it.
      if qflist.id ~= 0 and qflist.title ~= "All Diagnostics" then pcall(vim.cmd.cold) end
    end)
  end,
})

local noremap_silent = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>l', function()
    local win = vim.api.nvim_get_current_win()
    local qf_winid = vim.fn.getloclist(win, { winid = 0 }).winid
    local action = qf_winid > 0 and 'lclose' or 'lopen'
    pcall(vim.cmd, action)
end, noremap_silent)

vim.keymap.set('n', '<leader>q', function()
    local qf_winid = vim.fn.getqflist({ winid = 0 }).winid
    local action = qf_winid > 0 and 'cclose' or 'copen'
    vim.cmd('botright '..action)
end, noremap_silent)

require("trouble").setup()
vim.keymap.set('n', '<leader>xx', function()
  require("trouble").toggle("diagnostics") 
end, noremap_silent)
require("todo-comments").setup()
