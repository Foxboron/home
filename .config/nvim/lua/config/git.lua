local actions = require('diffview.actions')
require('diffview').setup({
  keymaps = {
        view = {
          { 'n', 'q', function() vim.cmd("tabclose") end, { desc = 'Close diffview' } },
        },
        file_panel = {
          { 'n', 'q', function() vim.cmd("tabclose") end, { desc = 'Close diffview' } },
        },
        file_history_panel = {
          { 'n', 'q', function() vim.cmd("tabclose") end, { desc = 'Close diffview' } },
        },
      },
})
vim.keymap.set('n', 'gq', ':DiffviewClose<CR>')


-- TODO: is this nice?
require("blame").setup()
vim.keymap.set("n", "gb", ":BlameToggle<CR>", {})

-- git fetch -p origin "+refs/pull/*/head:refs/remotes/${remote}/pull/*" "+refs/merge-requests/*/head:refs/remotes/${remote}/merge-requests/*"

local git = require("neogit.lib.git")
local a = require("plenary.async")
local git = require("neogit.lib.git")
local logger = require("neogit.logger")
local notification = require("neogit.lib.notification")
local util = require("neogit.lib.util")
local event = require("neogit.lib.event")


local function fetch_from(name, remote, branch, args)
  notification.info("Fetching from " .. name)
  local res = git.fetch.fetch_interactive(remote, branch, args)

  if res and res:success() then
    a.util.scheduler()
    notification.info("Fetched from " .. name, { dismiss = true })
    logger.debug("Fetched from " .. name)
    event.send("FetchComplete", { remote = remote, branch = branch })
  else
    logger.error("Failed to fetch from " .. name)
  end
end


function fetch_all_mrpr(popup)
  local upstream = git.branch.upstream_remote()
  fetch_from(upstream, "origin", "", { 
    "+refs/pull/*/head:refs/remotes/origin/pull/*",
    "+refs/merge-requests/*/head:refs/remotes/origin/merge-requests/*"
  })
end

local neogit = require('neogit')
neogit.setup {
  builders = {
    NeogitFetchPopup = function(builder)
      builder:action('f', 'MR/PR Fetch', fetch_all_mrpr)
    end,
  },
  use_per_project_settings = false,
  initial_branch_name = "morten/",
  graph_style = "unicode",
  intergrations = { 
    telescope = true,
    diffview  = true 
  },
  git_services = {
    ["gitlab.archlinux.org"] = {
      pull_request = "https://gitlab.archlinux.org/${owner}/${repository}/merge_requests/new?merge_request[source_branch]=${branch_name}",
      commit = "https://gitlab.archlinux.org/${owner}/${repository}/-/commit/${oid}",
      tree = "https://gitlab.archlinux.org/${owner}/${repository}/-/tree/${branch_name}?ref_type=heads",
    },
  },
}

-- TODO: Maybe use leader
vim.keymap.set('n', 'gs', ':Neogit<CR>')

