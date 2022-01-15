if &diff
    set nolist
    vnoremap <silent><buffer>dp :diffput<CR> :diffupdate<CR>
    vnoremap <silent><buffer>dg :diffget<CR> :diffupdate<CR>

    highlight DiffAdd ctermfg=194 ctermbg=78 guifg=#d3ebe9 guibg=DarkGreen
    highlight DiffChange guifg=NONE guibg=NONE ctermbg=NONE ctermfg=NONE
endif

