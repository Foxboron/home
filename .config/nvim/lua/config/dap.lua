-- https://github.com/mfussenegger/nvim-dap#usage
-- @see :help dap-configuration

local M = {}

local if_nil = function(value, val_nil, val_non_nil)
  if value == nil then return val_nil
  else return val_non_nil end
end

------------------------------------------------------------------------------
-- DAP Configs.
------------------------------------------------------------------------------
---@diagnostic disable: missing-fields

M.setup_sign = function()
  vim.api.nvim_set_hl(0, 'DapBreakpoint', { ctermbg=0, fg='#993939' })
  vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DapBreakpoint" })

  vim.api.nvim_set_hl(0, 'DapLogPoint', { ctermbg=0, fg='#61afef', bg='#31353f' })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapBreakpoint", linehl = "DapCurrentLine", numhl = "DiagnosticSignWarn", })
  vim.api.nvim_set_hl(0, 'DapStopped', { ctermbg=0, fg='#98c379', bg='#31353f' })

  vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
  vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DapBreakpoint", linehl = "DapBreakpoint", numhl = "DapBreakpoint" })
end

--- Setup nvim-dap-ui
M.setup_ui = function()
  local dap = require('dap')
  local dapui = require('dapui')

  local columns = function(x) return x end
  local width_ratio = function(x) return x end
  local height_ratio = function(x) return x end

  -- :help nvim-dap-ui
  -- https://github.com/rcarriga/nvim-dap-ui#configuration
  -- ~/.vim/plugged/nvim-dap-ui/lua/dapui/config/init.lua

  require("dapui").setup {
    mappings = {
      -- Use a table to apply multiple mappings
      expand = { "<CR>", "<2-LeftMouse>" },
      open = "o",
      remove = "d",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    element_mappings = {
      stacks = {
        open = {"<CR>", "o"},
      }
    },
    layouts = {
      {
        position = "left",
        size = columns(30),
        elements = {
          { id = "scopes", size = height_ratio(0.1) },
          { id = "breakpoints", size = height_ratio(0.2) },
          { id = "stacks", size = height_ratio(0.3) },
          { id = "watches", size = height_ratio(0.4) },
        },
      },
      { elements = { "repl" }, size = height_ratio(0.25), position = "right" },
      { elements = { "console", }, size = width_ratio(0.25), position = "bottom" },
    },
    controls = {
      -- Enable control buttons
      enabled = vim.fn.exists("+winbar") > 0,
      elements = "repl",  -- show in this element
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = "single", -- Border style. Can be "single", "double" or "rounded"
      mappings = {
        close = { "q", "<Esc>" },
      },
    },
    windows = { indent = 1 },
    render = {
      max_type_length = nil, -- Can be integer or nil.
      max_value_lines = 100, -- Can be integer or nil.
    }
  }

  -- Register custom dapui elements (dapui v3.0+)
  local dapui_exception = {
    buffer = require("dapui.util").create_buffer("DAP Exceptions", { filetype = "dapui_exceptions" }),
    float_defaults = function() return { enter = false } end
  }
  function dapui_exception.render()
    -- get the diagnostic information and draw upon rendering/entering.
    local session = require("dap").session()
    if session == nil then
      return
    end
    local buf = dapui_exception.buffer()
    local diagnostics = vim.diagnostic.get(nil, { namespace = session.ns } )  ---@type Diagnostic[]
    local msg = table.concat(vim.tbl_map(function(d) return d.message end, diagnostics), '\n')
    if not msg or msg == "" then
      msg = "(No exception was caught)"
    end
    pcall(function()
      vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(msg, '\n'))
      vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    end)
  end
  xpcall(function()
    dapui.register_element("exception", dapui_exception)
  end, function(err)
    if err:match("already exists") then return end
    vim.notify(debug.traceback(err, 1), vim.log.levels.ERROR, { title = "dapui" })
  end)

  -- Custom highlights for dap-ui elements
  vim.cmd [[
    hi DapReplPrompt guifg=#fab005 gui=NONE
    augroup dapui_highlights
      autocmd!
      autocmd FileType dap-repl syntax match DapReplPrompt '^dap>'
    augroup END
  ]]

  -- Completion in DAP widgets, via nvim-cmp
  -- require("cmp").setup {
  --   enabled = function()
  --     return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
  --       or require("cmp_dap").is_dap_buffer()
  --   end
  -- }
  require("cmp").setup.filetype({
    "dap-repl", "dapui_watches", "dapui_hover", "dapui_eval_input"
  }, {
    sources = {
      { name = "dap", trigger_characters = { '.' } },
    },
  })

  -- Events
  -- https://microsoft.github.io/debug-adapter-protocol/specification#Events
  -- e.g., initialized, stopped, continued, exited, terminated, thread, output, breakpoint, module, etc.
  dap.listeners.after.event_initialized["dapui_config"] = function()
    -- Open DAP UI Elements when a debug session starts, unless openUIOnEntry is false.
    ---@diagnostic disable-next-line: undefined-field
    local openUIOnEntry = if_nil(dap.session().config.openUIOnEntry, true, false)
    if openUIOnEntry then
      dapui.open {}
    end
  end
  dap.listeners.after.event_stopped["dapui_config"] = function()
    -- Open DapUI when the debugger hits a breakpoint.
    dapui.open {}
  end

  -- autocmds for dapui elements
  do
    vim.cmd [[
      augroup dapui
        autocmd!
        autocmd WinEnter * if &filetype == 'dap-repl'    | startinsert! | endif
        autocmd WinEnter * if &filetype == 'dap-watches' | startinsert! | endif
      augroup END
    ]]
  end

  vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "\\[dap-repl\\]",
    callback = vim.schedule_wrap(function(args)
      vim.api.nvim_set_current_win(vim.fn.bufwinid(args.buf))
    end)
  })

  -- DAP REPL: insert mode keymaps need to be fixed (C-j, C-k, C-l, etc.)
  local dapui_keymaps = vim.api.nvim_create_augroup("dapui_keymaps", { clear = true })
  vim.api.nvim_create_autocmd("WinEnter", {
    pattern = "*",
    group = dapui_keymaps,
    desc = 'Fix scrolloff for dap-repl',
    callback = function()
      if vim.bo.filetype == 'dap-repl' then
        vim.wo.scrolloff = 0  -- to allow 'clear' REPL
      end
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dap-repl",
    group = dapui_keymaps,
    desc = 'Fix and add insert-mode keymaps for dap-repl',
    callback = function()
      -- TODO ctrl-x
      vim.keymap.set('i', '<c-h>', '<C-g>u<C-w>h', { buffer = true, desc = 'Move to the left window' })
      vim.keymap.set('i', '<c-j>', '<C-g>u<C-w>j', { buffer = true, desc = 'Move to the above window' })
      vim.keymap.set('i', '<c-k>', '<C-g>u<C-w>k', { buffer = true, desc = 'Move to the below window' })
      vim.keymap.set('i', '<c-l>', '<c-u><c-\\><c-o>zt', { buffer = true, remap = true, desc = 'Clear REPL' })
      vim.keymap.set('i', '<c-p>', '<Up>',   { buffer = true, remap = true, desc = 'Previous Command' })
      vim.keymap.set('i', '<c-n>', '<Down>', { buffer = true, remap = true, desc = 'Next Command' })

      -- Override <Tab> so that it can trigger autocompletion even if the cursor does not have a preceding word.
      vim.keymap.set('i', '<tab>', function() require('cmp').complete() end, { buffer = true, desc = 'Tab Completion in dap-repl' })

      -- Debugger commands (see setup_cmds_and_keymaps)
      -- M._bind_keymaps_for_repl()
    end,
  })

end


--- Body of :DebugStart.
--- @param opts { adapter: string, configuration?: string, args: string[] }
function M.start(opts)
  -- Currently, there is no public API to override filetype (see mfussenegger/nvim-dap#1090)<
  -- so we re-implement "select_config_and_run" and call dap.run() manually
  local adapter = opts.adapter or vim.bo.filetype
  local launch_ctx = { adapter = adapter, args = opts.args }

  ---@type dap.Configuration[]
  local configurations = require('dap').configurations[adapter] or {}

  -- apply pre-filter to prune out
  ---@param configuration dapext.Configuration
  configurations = vim.tbl_filter(function(configuration)
    local typ = type(configuration.available)
    if typ == "nil" then
      return true
    elseif typ == "boolean" then
      return configuration.available --[[@as boolean]]
    elseif typ == "function" then
      return configuration.available(configuration, launch_ctx)
    else
      error(string.format("Unknown type: %s", typ))
    end
  end, configurations)

  -- apply configuration filter: e.g. :DebugStart python.attach
  if opts.configuration then
    configurations = vim.tbl_filter(function(config) ---@param config dapext.Configuration
      return config.id == opts.configuration
    end, configurations)
  end

  if #configurations == 0 then
    local msg = ('No available DAP configuration for filetype/adapter `%s`'):format(adapter)
    if opts.configuration then
      msg = msg .. (' and configuration `%s`'):format(opts.configuration)
    end
    vim.notify(msg .. '.', vim.log.levels.WARN, { title = 'config/dap' })
    return
  end

  if #configurations > 1 and #launch_ctx.args > 0 then
    local msg = 'DebugStart: Cannot have arguments when there are multiple configurations.'
    vim.notify(msg, vim.log.levels.ERROR, { title = 'config/dap' })
    return
  end

  ---@param configuration dapext.Configuration
  local run = function(configuration)
    require('dap').run(configuration, {
      ---@type fun(config: dapext.Configuration):dap.Configuration
      before = function(config)
        -- create a new copy of configuration to override with runtime arguments
        if config.resolve_args then
          local mt = getmetatable(config)
          if not xpcall(function()
            local override = config.resolve_args(launch_ctx.args)
            config = vim.tbl_deep_extend('force', config, override or {})
          end, function(err)
            vim.api.nvim_err_writeln(err)
          end) then
            return { _ = require('dap').ABORT }
          end
          config.resolve_args = nil  -- do not call it again
          return setmetatable(config, mt)
        end
        return config
      end
    })
  end

  require('dap.ui').pick_if_many(
    configurations,
    ("Choose Configuration [%s]"):format(adapter),
    function(configuration)
      local label = configuration.name
      if configuration.id then
        label = string.format('[%s] %s', configuration.id, label)
      end
      return label
    end,
    function(configuration)
      if configuration then
        run(configuration)
      end
    end)
end


local function command(cmd, fn, opts)
  opts = vim.tbl_deep_extend('force', { bar = true }, opts or {})
  vim.api.nvim_create_user_command(cmd, fn, opts or {})
end
local function keymap(lhs, rhs)
  if type(rhs) == 'table' then
    if rhs.cmd then rhs = string.format('<cmd>%s<CR>', rhs.cmd)
    else return error("Unknown rhs options.") end
  end
  vim.keymap.set('n', lhs, rhs, { remap = false, silent = true })
end

M.setup_cmds_and_keymaps = function()  -- Commands and Keymaps.
  -- Define "global" commands and keymaps
  -- Define similar keymaps as https://code.visualstudio.com/docs/editor/debugging#_debug-actions
  -- @see :help dap-api  :help dap-mappings
  local dap = require('dap')
  local dapui = require('dapui')

  command('Debug', function()
    if dap.configurations[vim.bo.filetype] then
      vim.cmd [[ DebugStart ]]
    else  -- no available DAP adapters, fall back to build
      vim.cmd [[
        echohl WarningMsg
        echon ":Debug not defined for this filetype. Try :Build instead."
        echohl NONE
      ]]
    end
  end, { desc = 'Start or continue DAP.' })

  -- :DebugStart {adapter[.config]} [args...]
  command('DebugStart', function(e)
    local arg = e.fargs[1]
    local adapter, config_id = arg, nil
    if arg and arg:find('%.') then
      adapter, config_id = unpack(vim.split(arg, "%."))
    end
    M.start {
      adapter = adapter,
      configuration = config_id,
      args = { unpack(e.fargs, 2) },
    }
  end, { nargs = '*', complete = function(arglead, cmdline, cursorpos)
    local fargs = vim.split(cmdline, ' +', { trimempty = true })
    if not (fargs[2] or ''):find('%.') then -- no dot yet, complete adapters
      return vim.tbl_keys(dap.configurations)  ---@type string[]
    elseif vim.iter then -- complete configurations id for the adapter, requires nvim 0.10+
      local adapter, _ = unpack(vim.split(fargs[2], "%."))
      return (vim.iter(dap.configurations[adapter] or {})
        :filter(function(c) return c.id ~= nil end)
        :map(function(c) return adapter .. '.' .. c.id end)
        :totable())
    end
  end })

  command('DapOpen', function() dapui.open {} end)
  command('DapClose', function() dapui.close {} end)
  command('DapToggle', function() dapui.toggle {} end)

  command('DapStackUp', dap.up)
  command('DapStackDown', dap.down)
  command('DapRunToCursor',   function() dap.run_to_cursor() end)

  keymap('<leader>b', { cmd = 'DapToggleBreakpoint' })

  -- see M._bind_session_keymaps() for session-only key mappings
end

M.setup_session_keymaps = function()
  -- Debug-Session-Only keymaps.
  -- Keymaps that are temporarily active ONLY during the debug session.
  -- When the DAP session terminates, keymaps will be reset.

  local dap = require('dap')

  M._keymaps_original = {}
  local get_keymap = function(mode, lhs)
    local keymaps = vim.api.nvim_get_keymap(mode)
    for _, keymap in pairs(keymaps) do
      if keymap.lhs == lhs then return keymap end
    end
    return nil
  end
  local debug_nmap = function(lhs, rhs, opts)
    M._keymaps_original[lhs] = get_keymap('n', lhs)
    opts = vim.tbl_deep_extend('keep', opts or {}, { bar = true })
    vim.keymap.set('n', lhs, rhs, { noremap = true, nowait = true})
  end
  local to_bool = function(x)
    if x == nil then return false end
    if type(x) == "boolean" then return x end
    if type(x) == "number" then return x > 0 end
    if type(x) == "string" then return x ~= "" end
    error("Unknown type : " .. type(x))
  end

  -- Override "global" keymaps when DAP session initiailzes.
  dap.listeners.after.event_initialized["dap_keymaps"] = function() M._bind_session_keymaps() end
  M._bind_session_keymaps = function()
    debug_nmap('<leader>c', '<cmd>DapContinue<CR>')  -- Continue
    debug_nmap('<leader>n', '<cmd>DapStepOver<CR>')  -- Next
    debug_nmap('<leader>s', '<cmd>DapStepInto<CR>')  --  Step
    debug_nmap('<leader>t', '<cmd>DapRunToCursor<CR>')  -- run To cursor
    debug_nmap('<leader>f', '<cmd>DapStepOut<CR>')  -- Finish
    debug_nmap('<leader>r', '<cmd>DapStepOut<CR>')  -- Return
    debug_nmap('<leader>q', '<cmd>DapTerminate<CR>')  -- Return

    debug_nmap('K', function() require('dapui').eval() end,
        { desc = 'Evaluate or examine the expression on the cursor.'})
    debug_nmap('?', function() M.DebugEval() end,
        { desc = 'Evaluate an arbitrary expression using input dialog.'})

    debug_nmap('<C-u>', '<cmd>DapStackUp<CR>')
    debug_nmap('<C-d>', '<cmd>DapStackDown<CR>')

    debug_nmap('<leader>e', function()
      require("dapui").float_element("exception", { enter = false })
    end, { desc = 'Show the active exception in a floating window.' })
  end

  -- Restore the keymap existing to before the DAP session
  -- Some adapters may not fully support the 'terminated' event, see mfussenegger/nvim-dap#742
  dap.listeners.after.disconnect["dap_keymaps"] = function() M.unbind_session_keymaps() end
  dap.listeners.after.event_terminated["dap_keymaps"] = function() M.unbind_session_keymaps() end
  M.unbind_session_keymaps = function()
    for _, keymap in pairs(M._keymaps_original) do
      if keymap then
        vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs or keymap.callback,
          {  -- see :map-arguments
            silent = to_bool(keymap.silent),
            expr = to_bool(keymap.expr),
            nowait = to_bool(keymap.nowait),
            noremap = to_bool(keymap.noremap),
            replace_keycodes = to_bool(keymap.replace_keycodes),
            script = to_bool(keymap.script),
          })
      else
        vim.keymap.del(keymap.mode, keymap.lhs)
      end
    end
    M._keymaps_original = {}
  end

end

------------------------------------------------------------------------------
-- Not essential, but useful advanced setups
------------------------------------------------------------------------------

M.setup_virtualtext = function()
  -- https://github.com/theHamsta/nvim-dap-virtual-text
  require("nvim-dap-virtual-text").setup {
    enabled = true,

    virt_text_pos = 'eol',  ---@type 'inline'|'eol'

    --- A callback that determines how a variable is displayed or whether it should be omitted
    --- @param variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
    --- @param buf integer
    --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
    --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
    --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
    --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
    display_callback = function(variable, buf, stackframe, node, options)
      if options.virt_text_pos == 'inline' then
        return ' = ' .. variable.value
      else
        return '  ◄ ' .. variable.name .. ' = ' .. variable.value
      end
    end,
  }

end

M.setup_breakpoint_persistence = function()
  -- https://github.com/Weissle/persistent-breakpoints.nvim

  require('persistent-breakpoints').setup {
    load_breakpoints_event = { "BufReadPost" }
  }

  local pb_api = require('persistent-breakpoints.api')

  -- Ensure called at least once after VimEnter, because DAP is loading lazily
  pb_api.load_breakpoints()

  -- Override and keymaps
  command("DapBreakpoint", function() pb_api.toggle_breakpoint() end)
end


M.DebugEval = function(default_expr)
  -- :DebugEval command ('?' in the session keymap)

  if require('dap').session() == nil then
    return vim.notify('DebugEval: Not in a Debug session.', vim.log.levels.WARN, {title = 'nvim-dap'})
  end
  if default_expr == "" then default_expr = nil end

  -- Get user input and evaluate the expression.
  local opts = {
    prompt = "DebugEval> ",
    default = default_expr or vim.fn.expand('<cexpr>'),
    -- Assumes dressing.nvim; see lua module "dressing.input"
    -- completion does not support lua funcref yet.
    -- This works as an omnicomplete, so needs cmp-omni.
    completion = "custom,v:lua.require('config.dap').DebugEvalCompletion",
    insert_only = false,
  }
  vim.ui.input(opts, function(input)
    if input and input ~= "" then
      -- Show evaluation of the input expression in a floating window.
      vim.defer_fn(function()
        require "dapui".eval(input, {})
      end, 10)
    end
  end)
end

M.DebugEvalCompletion = function(A, L, P)
  -- Hack: Monkey-batch buffer vars and keymaps upon the first completion hit (<Tab>)
  local cmp = require('cmp')
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(bufnr, "filetype", "dapui_eval_input")  -- to make is_dap_buffer() return true
  cmp.setup.buffer({ enabled = true })
  vim.keymap.set("i", "<Tab>", function()
    if cmp.visible() then cmp.select_next_item()
    else cmp.complete() end
  end, { buffer = bufnr })
  vim.keymap.set("i", "<S-Tab>", function()
    if cmp.visible() then cmp.select_prev_item() end
  end, { buffer = bufnr })
  cmp.complete()
  return ''
end

-- Customize REPL commands
M.setup_repl_handlers = function()
  local repl = require("dap.repl")
  local utils = require("dap.utils")
  local commands = {}

  commands.eval_and_print = function(text)
    local session = assert(require("dap").session())
    session:evaluate(text, function(err, resp)
      local message = nil
      if err then message = utils.fmt_error(err)
      else message = resp.result
      end

      if message then
        repl.append(message, nil, { newline = false })
      end
    end)
  end

  repl.commands.custom_commands[".p"] = commands.eval_and_print
  repl.commands.custom_commands["p"] = commands.eval_and_print
end


-- Entrypoint.
M.setup = function()
  -- Essentials
  M.setup_sign()
  M.setup_ui()
  M.setup_cmds_and_keymaps()
  M.setup_session_keymaps()

  -- Extensions
  M.setup_virtualtext()
  -- M.setup_breakpoint_persistence()
  M.setup_repl_handlers()
end


-- Resourcing support
if ... == nil then
  M.setup()
end


return M
