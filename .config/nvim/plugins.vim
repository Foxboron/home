call plug#begin('~/.config/nvim/bundle')
    Plug 'junegunn/vim-plug'

    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

    Plug 'nvim-treesitter/nvim-treesitter'

    " Debugger
    Plug 'mfussenegger/nvim-dap'
    Plug 'nvim-telescope/telescope-dap.nvim'
    Plug 'theHamsta/nvim-dap-virtual-text'
    Plug 'rcarriga/nvim-dap-ui'
    Plug 'jonboh/nvim-dap-rr'
    Plug 'leoluz/nvim-dap-go'

    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-git'
    Plug 'NeogitOrg/neogit'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'FabijanZulj/blame.nvim'

    Plug 'tpope/vim-unimpaired'


    Plug 'arcticicestudio/nord-vim'
    " Plug 'airblade/vim-gitgutter'
    Plug 'sindrets/diffview.nvim'

    " Telescope
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-telescope/telescope-live-grep-args.nvim'

    " Statusline
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'SmiteshP/nvim-navic'


    " Lsp
    Plug 'neovim/nvim-lspconfig'

    "Snippets
    Plug 'L3MON4D3/LuaSnip'
    Plug 'rafamadriz/friendly-snippets'
    Plug 'benfowler/telescope-luasnip.nvim'

    " Completion
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'

    Plug 'saadparwaiz1/cmp_luasnip'

    " Tests
    Plug 'nvim-neotest/nvim-nio'
    Plug 'nvim-neotest/neotest'
    Plug 'fredrikaverpil/neotest-golang'

    Plug 'folke/trouble.nvim'
    Plug 'folke/todo-comments.nvim'

    " Vimwiki
    Plug 'vimwiki/vimwiki', {'on' : ['VimwikiIndex', 'VimwikiUISelect'], 'for': 'wiki' }
    Plug 'OXY2DEV/markview.nvim'

    Plug 'nvim-tree/nvim-web-devicons'

call plug#end()

lua require("luasnip.loaders.from_vscode").lazy_load()
lua require("gitsigns").setup()
