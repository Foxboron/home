" Toggle quickfix and location list for vim
" sets a next and prev variable so we can use
" C-n/p to go up and down both the location and quickfix list



let g:windowNext = ""
let g:windowPrev = ""

function! GetBufferList()
  redir =>buflist
  silent! ls!
  redir END
  return buflist
endfunction


function! SetListMaps(pfx)
  if a:pfx == 'c'
    let g:windowNext = "cnext"
    let g:windowPrev = "cprevious"
  endif
  if a:pfx == 'l'
    let g:windowNext = "lnext"
    let g:windowPrev = "lprevious"
  endif
  if a:pfx == ''
    let g:windowNext = ""
    let g:windowPrev = ""
  endif
endfunction


function! ToggleList(bufname, pfx)
  let buflist = GetBufferList()
  for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if bufwinnr(bufnum) != -1
      exec(a:pfx.'close')
      call SetListMaps('')
      return
    endif
  endfor
  if a:pfx == 'l' && len(getloclist(0)) == 0
      echohl ErrorMsg
      echo "Location List is Empty."
      return
  endif
  let winnr = winnr()
  exec(a:pfx.'open')
  call SetListMaps(a:pfx)
  if winnr() != winnr
    wincmd p
  endif
endfunction

nmap <silent> <leader>l :call ToggleList("Location List", 'l')<CR>
nmap <silent> <leader>e :call ToggleList("Quickfix List", 'c')<CR>
