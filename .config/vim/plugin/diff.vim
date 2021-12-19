if &diff
    set nolist
    vnoremap <silent><buffer>dp :diffput<CR>
    vnoremap <silent><buffer>dg :diffget<CR>

    " highlight DiffText   ctermbg=NONE guifg=NONE guibg=NONE
    " highlight DiffChange guifg=NONE guibg=NONE ctermbg=NONE
    " highlight DiffAdd    ctermbg=NONE ctermfg=46  cterm=NONE guibg=NONE guifg=#00FF00 gui=NONE
    " highlight DiffDelete ctermbg=NONE ctermfg=196 cterm=NONE guibg=NONE guifg=#FF0000 gui=NONE

    " hi link diffLine String
    " hi link diffSubname Normal

    highlight DiffAdd    cterm=BOLD guifg=NONE guibg=DarkGreen
    highlight DiffDelete cterm=BOLD guifg=NONE guibg=DarkRed
    highlight DiffChange guifg=NONE guibg=#195466
    highlight DiffText   guifg=NONE guibg=#195466

endif

