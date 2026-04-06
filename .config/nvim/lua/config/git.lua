local actions = require('diffview.actions')
require('diffview').setup({
  enhanced_diff_hl = true,

  -- View configuration
  view = {
    default = {
      layout = 'diff2_horizontal', -- Side-by-side diff
      winbar_info = false,
    },
    merge_tool = {
      layout = 'diff4_mixed',
      disable_diagnostics = true,
      winbar_info = true,
    },
    file_history = {
      layout = 'diff2_horizontal',
      winbar_info = false,
    },
  },

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


-- TODO: is this nice?
require("blame").setup()
vim.keymap.set("n", "gb", ":BlameToggle<CR>", {})

-- git fetch -p origin "+refs/pull/*/head:refs/remotes/${remote}/pull/*" "+refs/merge-requests/*/head:refs/remotes/${remote}/merge-requests/*"

local a = require("plenary.async")

local logger = require("neogit.logger")

-- neogit library
local git = require("neogit.lib.git")
local util = require("neogit.lib.util")
local event = require("neogit.lib.event")
local notification = require("neogit.lib.notification")

local FuzzyFinderBuffer = require("neogit.buffers.fuzzy_finder")

-- Diffview
local dv_lib = require("diffview.lib")
local dv_utils = require("diffview.utils")


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

function diff_mr(popup)
  local options = util.deduplicate(
    util.merge(
      git.cli["for-each-ref"]
        .format("%(align:35)%(refname:short)%(end) - %(objectname:short) - %(align:40)%(contents:subject)%(end) - %(authorname) (%(committerdate:relative))")
        .sort("-committerdate")
        .arg_list({
          "--no-merged=HEAD",
          "**/merge-requests/*",
          "**/pull/*"
        })
        .call({ hidden = true }).stdout
    )
  )

  local mrpr = FuzzyFinderBuffer.new(options):open_async {
    prompt_prefix = "Diff...",
    refocus_status = false,
  }

  local ref = vim.split(mrpr, " ")[1]

  if not ref then
    return
  end

  local view = dv_lib.file_history(nil, '--range=..' .. ref)
  if view then
    view:open()
  end
end

require("gitsigns").setup({
on_attach = function(bufnr)
    local gitsigns = require('gitsigns')

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    map('n', '<leader>hs', gitsigns.stage_hunk)
    map('n', '<leader>hr', gitsigns.reset_hunk)

    map('v', '<leader>hs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('v', '<leader>hr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end)

    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hi', gitsigns.preview_hunk_inline)

    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)

    map('n', '<leader>hd', gitsigns.diffthis)

    map('n', '<leader>hD', function()
      gitsigns.diffthis('~')
    end)

    map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
    map('n', '<leader>hq', gitsigns.setqflist)

    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
    map('n', '<leader>tw', gitsigns.toggle_word_diff)

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
})

local neogit = require('neogit')
neogit.setup {
  builders = {
    NeogitFetchPopup = function(builder)
      builder:action('f', 'MR/PR Fetch', fetch_all_mrpr)
    end,
    NeogitDiffPopup = function(builder)
      builder:action('f', 'MR/PR Diff', diff_mr)
    end,
  },
  use_per_project_settings = false,
  initial_branch_name = "morten/",
  graph_style = "unicode",
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

