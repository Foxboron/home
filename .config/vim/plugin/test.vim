let g:vimspector_install_gadgets = [ 'vscode-go' ]
let g:vimspector_sign_priority = {
  \    'vimspectorBP':         999,
  \    'vimspectorBPCond':     999,
  \    'vimspectorBPDisabled': 999,
  \    'vimspectorPC':         999,
  \ }
let g:vimspector_enable_mappings = 'HUMAN'


" function! s:SetUpUI() abort
"   call win_gotoid( g:vimspector_session_windows.output )
"   q
" endfunction

" augroup VimspectorCustom
"   au!
"   autocmd User VimspectorUICreated call s:SetUpUI()
" augroup END

" Custom mappings while debuggins {{{
let s:mapped = {}

function! s:OnJumpToFrame() abort
  if has_key( s:mapped, string( bufnr() ) )
    return
  endif

  nmap <silent> <buffer> K <Plug>VimspectorBalloonEval
  nmap <silent> <buffer> tt <Plug>VimspectorContinue
  nmap <silent> <buffer> tj <Plug>VimspectorStepOver
  nmap <silent> <buffer> ti <Plug>VimspectorStepInto
  nmap <silent> <buffer> to <Plug>VimspectorStepOut
  nmap <silent> <buffer> tg <Plug>VimspectorRunToCursor
  nmap <silent> <buffer> tq :call vimspector#Reset( { 'interactive': v:true } )<CR>
  nmap <silent> <buffer> <LocalLeader>k <Plug>VimspectorUpFrame
  nmap <silent> <buffer> <LocalLeader>j <Plug>VimspectorDownFrame

  let s:mapped[ string( bufnr() ) ] = &l:modifiable
  setlocal nomodifiable
endfunction

function! s:OnDebugEnd() abort

  let original_buf = bufnr()
  let hidden = &hidden

  try
    set hidden
    for bufnr in keys( s:mapped )
      try
        execute 'noautocmd buffer' bufnr

        silent! nunmap <buffer> K
        silent! xunmap <buffer> K
        silent! nunmap <buffer> tt
        silent! nunmap <buffer> tj
        silent! nunmap <buffer> ti
        silent! nunmap <buffer> to
        silent! nunmap <buffer> tg
        silent! nunmap <buffer> tq
        silent! nunmap <buffer> <LocalLeader>k
        silent! nunmap <buffer> <LocalLeader>j

        let &l:modifiable = s:mapped[ bufnr ]
      endtry
    endfor
  finally
    execute 'noautocmd buffer' original_buf
    let &hidden = hidden
  endtry

  let s:mapped = {}
endfunction

augroup VimspectorCustomMappings
  au!
  autocmd User VimspectorJumpedToFrame call s:OnJumpToFrame()
  autocmd User VimspectorDebugEnded call s:OnDebugEnd()
augroup END

function! VimspectorGoTest(cmd)
    let path = expand('%')
    let position = {}
    let position['file'] = path
    let position['line'] = path == expand('%') ? line('.') : 1
    let position['col']  = path == expand('%') ? col('.') : 1
    let name = test#base#nearest_test(position, g:test#go#patterns)
    call vimspector#LaunchWithSettings( #{ configuration: 'test', TestName: name["test"][0]} )
endfunction

let g:test#custom_strategies = {
  \ 'go-test': function('VimspectorGoTest'),
  \ }

let test#vim#term_position = "below 10"
let test#strategy = 'vimterminal'

nmap <silent> t<C-d> :TestNearest -strategy=go-test<CR>
nmap <silent> t<C-r> :TestNearest -v<CR>
nmap <silent> t<C-f> :TestFile<CR>
nmap <silent> tt :call vimspector#Launch()<CR>
