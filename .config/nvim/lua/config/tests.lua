-- Tests
local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-golang")({
 	runner = "gotestsum",
        warn_test_name_dupes = false,
    }),
  }
})

keymap("<leader>t", neotest.run.run, "Test method")
keymap("t<C-r>", neotest.run.run, "Test method")
keymap("t<C-f>", function() neotest.run.run(vim.fn.expand("%")) end, "Run all tests in the current file")
keymap("t<C-s>", neotest.summary.toggle, "Test Summary")
keymap("t<C-o>", neotest.output.open, "Open Output")
keymap("t<C-p>", neotest.output_panel.toggle, "Open Output")
keymap("t<C-d>", function() neotest.run.run({ strategy = 'dap' }) end, "Test method (with debugging)")
