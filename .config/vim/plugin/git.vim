command! -bar Gllogfunc execute 'Gllog --no-patch -L :' . expand('<cword>') . ':%'

fun! LoadGitrebaseBindings()
    nnoremap <buffer> <silent> <C-P> :Pick<cr>
    nnoremap <buffer> <silent> <C-R> :Reword<cr>
    nnoremap <buffer> <silent> <C-E> :Edit<cr>
    nnoremap <buffer> <silent> <C-S> :Squash<cr>
    nnoremap <buffer> <silent> <C-F> :Fixup<cr>

    vnoremap <buffer> <silent> <C-P> :Pick<cr>
    vnoremap <buffer> <silent> <C-R> :Reword<cr>
    vnoremap <buffer> <silent> <C-E> :Edit<cr>
    vnoremap <buffer> <silent> <C-S> :Squash<cr>
    vnoremap <buffer> <silent> <C-F> :Fixup<cr>
endfun
  
augroup vim_gitrebase
  autocmd FileType gitrebase call LoadGitrebaseBindings()
augroup END
