require("tokyonight").setup({
  style = "night",
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
    functions = { italic = false },
  },
  on_colors = function(colors)
    colors.hint = colors.orange
    colors.error = "#ff0000"
  end
})


vim.api.nvim_set_keymap('', '<Space>', '<Nop>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.termguicolors = true

vim.opt.clipboard = 'unnamedplus'

vim.cmd.colorscheme('tokyonight')


-- TODO: Fix to lua
vim.cmd([[

set number
set relativenumber
set ruler
set cursorline
set noshowmode
set shortmess=IatO
set list

set splitright

set ignorecase
set smartcase

set hidden

set scrolloff=10

set completeopt=menu,menuone,popup,noselect,noinsert

"nnoremap <silent> <C-J> }
"nnoremap <silent> <C-K> {
"vnoremap <silent> <C-J> }
"vnoremap <silent> <C-K> {
" Omit jumps from jumptable
noremap <silent> <C-J> :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
noremap <silent> <C-K> :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>
vnoremap <silent> <C-J> :<C-u>execute "keepjumps norm! " . v:count1 . "}"<CR>
vnoremap <silent> <C-K> :<C-u>execute "keepjumps norm! " . v:count1 . "{"<CR>

cnoremap <C-K> <Up>
cnoremap <C-J> <Down>
cnoremap <C-A> <Home>
cnoremap <C-E> <End>

" Maybe problematic?
nnoremap <C-I> <C-I>
nnoremap <Tab><Tab> <C-^>

" Emacs things

nnoremap + <C-a>
nnoremap - <C-x>
vnoremap + <C-a>gv
vnoremap - <C-x>gv
noremap <C-A> ^
noremap <C-E> $
noremap <C-Q> %

" Fold?
nnoremap          zf zMzvzz
nnoremap          zz za
nnoremap <silent> zj :silent! normal! zc<cr>zjzvzz
nnoremap <silent> zk :silent! normal! zc<cr>zkzvzz[z"

" Buffers
nnoremap <leader>j  :bprev<CR>
nnoremap <leader>k  :bnext<CR>
nnoremap <leader>c  :bw<CR>

nnoremap <leader>tc  :tabclose<CR>
]])
