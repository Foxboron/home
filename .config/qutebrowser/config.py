# Autogenerated config.py
# Documentation:
#   qute://help/configuring.html
#   qute://help/settings.html

c.tabs.background = True
c.spellcheck.languages = ['nb-NO', 'en-US']

config.unbind('u')
config.unbind('d')
config.unbind('@')
config.unbind('q')

config.bind('<ctrl-d>', 'tab-close')
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('F', 'hint all tab-bg')
config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('W', 'set-cmd-text -s :buffer ', mode='normal')


c.url.searchengines = {
    "DEFAULT": "https://duckduckgo.com/?q={}",
    "aur"    : "https://aur.archlinux.org/packages/?K={}",
    "g"      : "https://encrypted.google.com/search?hl=fr&q={}",
    "gt"     : "https://translate.google.com/{}",
    "gm"     : "https://www.google.com/maps?q={}",
    "w"    : "https://en.wikipedia.org/wiki/{}",
    "aw"     : "https://wiki.archlinux.org/?search={}",
    "yt"     : "https://www.youtube.com/results?search_query={}",
    "gh"     : "https://github.com/search?q={}",
    "imdb"   : "http://www.imdb.com/find?s=all&q={}"
}

c.fonts.completion.category = "bold 10pt monospace"
c.fonts.completion.entry = "8pt monospace"
c.fonts.debug_console = "8pt monospace"
c.fonts.downloads = "8pt monospace"
c.fonts.hints = "bold 8pt monospace"
c.fonts.keyhint = "8pt monospace"
c.fonts.messages.error = "8pt monospace"
c.fonts.messages.info = "8pt monospace"
c.fonts.messages.warning = "8pt monospace"
c.fonts.prompts = "8pt monospace"
c.fonts.statusbar = "8pt monospace"
c.fonts.tabs.selected = "8pt monospace"
c.fonts.tabs.unselected = "8pt monospace"

config.bind(',c', 'spawn --userscript stream')
config.bind(',p', 'spawn --userscript open-portal')
config.bind(',s', 'open https://rss.linderud.dev/bookmarklet?uri={url}')

c.editor.command = ['termite', '-e', 'vim {}']

c.qt.workarounds.remove_service_workers = True

# Uncomment this to still load settings configured via autoconfig.yml
config.load_autoconfig(False)

