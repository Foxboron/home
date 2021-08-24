" Taken from
" https://github.com/sophiabrandt/dotfiles/blob/main/vim/custom/autocmds.vim
func! s:setup_ls(...) abort
    let l:servers = lsp#get_allowed_servers()

    for l:server in l:servers
        let l:cap = lsp#get_server_capabilities(l:server)

        if has_key(l:cap, 'completionProvider')
            setlocal completefunc=lsp#complete
        endif

        if has_key(l:cap, 'hoverProvider')
            setlocal keywordprg=:LspHover
        endif

        if has_key(l:cap, 'referencesProvider')
            nmap <silent><buffer>gn <plug>(lsp-next-reference)
            nmap <silent><buffer>gp <plug>(lsp-previous-reference)
        endif

        if has_key(l:cap, 'implementationProvider')
            nmap <silent><buffer>gI <plug>(lsp-implementation)
        endif

        if has_key(l:cap, 'codeActionProvider')
            nmap <silent><buffer>ga <plug>(lsp-code-action)
        endif

        if has_key(l:cap, 'definitionProvider')
            nmap <silent><buffer>gd <plug>(lsp-definition)
            nmap <silent><buffer>gk <plug>(lsp-peek-definition)
        endif

        if has_key(l:cap, 'typeDefinitionProvider')
            nmap <silent><buffer>gt <plug>(lsp-type-definition)
        endif

        if has_key(l:cap, 'signatureHelpProvider')
            nmap <silent><buffer>gm <plug>(lsp-signature-help)
        endif

        if has_key(l:cap, 'documentSymbolProvider')
            nmap <silent><buffer>go <plug>(lsp-document-symbol)
        endif

        if has_key(l:cap, 'renameProvider')
            nmap <silent><buffer>gr <plug>(lsp-rename)
        endif

        if has_key(l:cap, 'workspaceSymbolProvider')
            nmap <silent><buffer>gw <plug>(lsp-workspace-symbol)
        endif

    endfor
endfunc

augroup LSC
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'gopls',
                \ 'cmd': {_->['gopls']},
                \ 'allowlist': ['go']
                \})

    autocmd User lsp_server_init call <SID>setup_ls()
    autocmd BufEnter * call <SID>setup_ls()
augroup END
