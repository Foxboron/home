"{{{2 plugin: vimwiki
let g:vimwiki_hl_headers = 1
let g:vimwiki_hl_cb_checked = 1
let g:vimwiki_use_calendar=1
"let g:vimwiki_listsyms = '✗○◐●✓'
let g:vimwiki_folding = ''
let g:vimwiki_auto_chdir = 1
"{{{3 vimwiki:main
let main_wiki = {}
let main_wiki.path = '~/Documents/Notes/main'
let main_wiki.path_html = '~/.cache/vimwiki/main/html'
let main_wiki.automatic_nested_syntaxes = 1
let main_wiki.list_margin = 0
let main_wiki.template_default = 'markdown'
let main_wiki.syntax = 'markdown'
let main_wiki.ext = '.md'
"}}}
"{{{3 vimwiki:blog
let blog_wiki = {}
let blog_wiki.path = '/home/fox/Git/prosjekter/sites/Blog/content/'
let blog_wiki.index = '_main'
let blog_wiki.automatic_nested_syntaxes = 1
let blog_wiki.list_margin = 0
let blog_wiki.template_default = 'markdown'
let blog_wiki.syntax = 'markdown'
let blog_wiki.ext = '.md'
"}}}
"{{{3 vimwiki:secureboot.dev
let secureboot_wiki = {}
let secureboot_wiki.path = '/home/fox/Git/prosjekter/sites/secureboot.dev/src'
let secureboot_wiki.index = 'SUMMARY'
let secureboot_wiki.automatic_nested_syntaxes = 1
let secureboot_wiki.list_margin = 0
let secureboot_wiki.template_default = 'markdown'
let secureboot_wiki.syntax = 'markdown'
let secureboot_wiki.ext = '.md'
"}}}
"{{{3 vimwiki:wiki.linderud.dev
let pubdir_wiki = {}
let pubdir_wiki.path = '/home/fox/Documents/wiki'
let pubdir_wiki.index = 'SUMMARY'
let pubdir_wiki.automatic_nested_syntaxes = 1
let pubdir_wiki.automatic_nested_syntaxes = 1
let pubdir_wiki.list_margin = 0
let pubdir_wiki.template_default = 'markdown'
let pubdir_wiki.syntax = 'markdown'
let pubdir_wiki.ext = '.md'
"}}}
let g:vimwiki_list = [pubdir_wiki, main_wiki, blog_wiki, secureboot_wiki]
hi VimwikiBold term=bold cterm=bold gui=bold ctermfg=178 guifg=#dfaf00
hi VimwikiItalic term=italic cterm=italic gui=italic ctermfg=178 guifg=#dfaf00
"}}}
imap <C-t> <Plug>VimwikiIncreaseLvlSingleItem
imap <C-d> <Plug>VimwikiDecreaseLvlSingleItem
