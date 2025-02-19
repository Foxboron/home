local neogit = require('neogit')
neogit.setup {
  intergrations = { diffview  = true },
}
-- TODO: Maybe use leader
vim.keymap.set('n', 'gs', ':Neogit<CR>')

