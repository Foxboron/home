command! -nargs=1 FindTagsQ call s:FindTagsQ(<f-args>)
function! s:FindTagsQ(name)
  " Retrieve tags of the 'f' kind
  let tags = taglist(a:name)
  "let tags = filter(tags, 'v:val["kind"] == "f"')

  " Prepare them for inserting in the quickfix window
  let qf_taglist = []
  for entry in tags
    call add(qf_taglist, {
          \ 'pattern':  entry['cmd'],
          \ 'filename': entry['filename'],
          \ 'text': entry['name'],
          \ 'lnum': entry['line'],
          \ })
  endfor

  " Place the tags in the quickfix window, if possible
  if len(qf_taglist) > 0
    call setqflist(qf_taglist)
  else
    echo "No tags found for ".a:name
  endif
endfunction
