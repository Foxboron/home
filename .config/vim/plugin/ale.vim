if &diff
    finish
endif
let g:ale_set_popups=1
let g:ale_hover_to_popup=1
let g:ale_linters = {}
let g:ale_linters = {
\ 'go':              ['gopls', 'staticcheck'],
\ 'python':          ['flake8', 'black'],
\}
let g:ale_fixers = {
\ 'python': ['black'],
\}
let g:ale_rust_rls_toolchain = 'stable'
let g:ale_sign_column_always = 1
