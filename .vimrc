execute pathogen#infect()
execute pathogen#helptags()

filetype plugin indent on

syntax on

set hlsearch
set ruler
set rulerformat=%60(%f%m\ %c%V\ %p%%%)

" Turn off line wrapping
set nowrap

set backspace=indent,eol,start

set history=20

set autoindent
set smartindent
set ts=4
set tabstop=4
set shiftwidth=4
set hlsearch
set nu
set scrolloff=5
au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

" Okay, I give up. Github and your 8-space tabs on the web ruined diffs.
set expandtab

let mapleader = "-"

vnoremap > > gv
vnoremap < < gv
" Without holding 'shift', make < (now a comma) only shift the selection by a
" single space. Same with > (now a period).
vnoremap <silent> , :call setline(line('.') , substitute(getline('.'), '^\s\=', '', ''))<CR>gv
vnoremap <silent> . :call setline(line('.') , substitute(getline('.'), '^', ' ', ''))<CR>gv

nnoremap <Leader>p :set paste!<CR>
nnoremap <silent> <Leader>sv :so $HOME/.vimrc<CR>

"" Python mappings
" In both visual and normal mode, insert a '#' at the start of a line (to comment it out)
autocmd FileType python vnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '# ', ''))<CR>
autocmd FileType python nnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '# ', ''))<CR>
" In both visual and normal mode, remove a '#' at the start of a line (to uncomment it)
autocmd FileType python vnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs#\s*', '', ''))<CR>
autocmd FileType python nnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs#\s*', '', ''))<CR>
" Put a python debugger statement above the current line using the same leading whitespace as is in the current line
autocmd FileType python nnoremap <buffer> <silent> <Leader>db :call append(line('.') - 1, [substitute(getline('.'), '^\(\s*\).*$', '\1', '') . 'import pdb; pdb.set_trace()  # noqa E702'])<CR>

"" Javascript mappings
" In both visual and normal mode, insert '//' at the start of a line (to comment it out)
autocmd FileType javascript vnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
autocmd FileType javascript nnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
" In both visual and normal mode, remove '//' at the start of a line (to uncomment it)
autocmd FileType javascript vnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>
autocmd FileType javascript nnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>
" Prettier likes 2 spaces instead of 4
autocmd FileType javascript set ts=2
autocmd FileType javascript set tabstop=2
autocmd FileType javascript set shiftwidth=2

"" Golang mappings
" In both visual and normal mode, insert '//' at the start of a line (to comment it out)
autocmd FileType go vnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
autocmd FileType go nnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
" In both visual and normal mode, remove '//' at the start of a line (to uncomment it)
autocmd FileType go vnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>
autocmd FileType go nnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>
" Attempt to build and navigate through errors
autocmd FileType go nnoremap <silent> <Leader>gb :GoBuild<CR>
autocmd FileType go nnoremap <silent> <Leader>gq :cclose<CR>
autocmd FileType go nnoremap <silent> <Leader>gn :cnext<CR>
autocmd FileType go nnoremap <silent> <Leader>gp :cprevious<CR>
" Jump between source and test files
autocmd FileType go nnoremap <silent> <Leader>gt :GoAlternate<CR>
" Jump to definition
autocmd FileType go nnoremap <silent> <Leader>gd :GoDef<CR>
" Search for functions/tags/packages/etc.
autocmd FileType go nnoremap <silent> <Leader>gf :GoDeclsDir<CR>
" Don't expand tabs in go files
autocmd FileType go set noexpandtab

"" CSV mappings
" In normal mode, report what column we're in
autocmd FileType csv nnoremap <buffer> <silent> <Leader>c :CSVWhatColumn!<CR>
autocmd FileType csv nnoremap <buffer> <silent> <Leader>C :CSVWhatColumn<CR>
" In normal mode, highlight or unhighlight the current column
autocmd FileType csv nnoremap <buffer> <silent> <Leader>h :CSVHiColumn<CR>
autocmd FileType csv nnoremap <buffer> <silent> <Leader>H :CSVHiColumn!<CR>
" In normal mode, show or hide the header
autocmd FileType csv nnoremap <buffer> <silent> <Leader>t :Header<CR>
autocmd FileType csv nnoremap <buffer> <silent> <Leader>T :Header!<CR>

"" Clojure mappings
" In both visual and normal mode, insert a ';' at the start of a line (to comment it out)
autocmd FileType clojure vnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '; ', ''))<CR>
autocmd FileType clojure nnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '; ', ''))<CR>
" In both visual and normal mode, remove a ';' at the start of a line (to uncomment it)
autocmd FileType clojure vnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs;\s\=', '', ''))<CR>
autocmd FileType clojure nnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs;\s\=', '', ''))<CR>

"" Gutentags settings
let g:gutentags_ctags_exclude = ["node_modules", ".git", "ext"]
" Gutentags has trouble figuring out tags for clojure files
let g:gutentags_exclude_filetypes = ["clojure"]

"" Syntastic settings
set statusline+=%{gutentags#statusline()}
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_aggregate_errors = 1

let g:syntastic_mode_map = {
	\ "mode": "active",
	\ "active_filetypes": [],
	\ "passive_filetypes": [] }

" Python settings
let g:syntastic_python_flake8_args='--max-line-length=120'
let g:syntastic_python_pylint_post_args="--py3k --reports=n"

" Add javascript and html checkers
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_html_checkers = ['htmlhint']
let g:syntastic_html_htmlhint_args = "--config ~/.htmlhintrc"
let g:syntastic_python_checkers = ['flake8', 'pylint']

" Navigate between Syntastic errors
nmap <silent> <Leader>sn :lnext<CR>
nmap <silent> <Leader>sp :lprev<CR>
nmap <silent> <Leader>st :SyntasticToggle<CR>

"" Markdown Settings
" Use github-style markdown
" NOTE: This option requires a network connection. Set to 0 if you need this
"       offline
let vim_markdown_preview_github=1

" Display images and generate previews only when hotkey is used
let vim_markdown_preview_toggle=1

" Normally the documentation says you should use vim_markdown_preview_hotkey
" here instead, but that doesn't seem to work. Just setting this up manually
autocmd Filetype markdown,md map <buffer> <Leader>m :call Vim_Markdown_Preview_Local()<CR>
let vim_markdown_preview_hotkey='<Leader><Leader><Leader>' "Something I'm unlikely to use accidentally
" Use Chrome instead of Safari for previews
let vim_markdown_preview_browser='Google Chrome'
" Remove the generated preview html file after use
let vim_markdown_preview_temp_file=1

"" YouCompleteMe settings

"	Let the "Enter" key also select an option from the menu
"let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']

"	Don't automatically insert/select anything automatically
"set completeopt+=noinsert
"set completeopt+=noselect

" Let clangd fully control code completion
let g:ycm_clangd_uses_ycmd_caching = 0
" Use installed clangd, not YCM-bundled clangd which doesn't get updates.
let g:ycm_clangd_binary_path = exepath("clangd")

" Don't autocomplete TODO files.
let g:ycm_filetype_blacklist = { 'todo': 1 }

"" UltiSnips settings
" XXX Disabling these until I figure out how to use ulti snips
"nmap <silent> <Leader>ue :UltiSnipsEdit<CR>
"let g:UltiSnipsExpandTrigger="<Leader>ut"
"let g:UltiSnipsEditSplit="horizontal"

"" CtrlP Settings for file searching
" Force Ctrl P to index as many files as it finds in the project
let g:ctrlp_max_files=0
" Force Ctrl P to go very deep into directory structures
let g:ctrlp_max_depth=40
" Ignore node_modules and python compiled files
let g:ctrlp_custom_ignore = 'node_modules\|\.pyc$'


"" Vim-Prettier settings
" Use the globally installed prettier
let g:prettier#exec_cmd_path = "/usr/local/bin/prettier"
" Don't use the quickfix for parsing warnings. (This is already done by eshint)
let g:prettier#quickfix_enabled = 0
" Automatically run when saving javascript, css, markdown, or html files.
let g:prettier#autoformat = 0
autocmd BufWritePre *.js,*.jsx,*.es6,*.less,*.scss,*.sass,*.css,*.md,*.html Prettier

"" RainbowParentheses Options
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

"" Vim-TODO-List Settings
" See :help VimTodoListUsage for more information
" Prevent items from jumping around in the list
let g:VimTodoListsMoveItems = 0
" Disable current-item highlighting. (Note: This is not the best solution.
" Should instead figure out how to get 'set nocursorline' to run after the
" plugin sets cursorline. Or fork the plugin to use a parameter to determine
" if it should use cursorline.)
autocmd FileType todo highlight Cursorline cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
autocmd FileType todo highlight CursorlineNR cterm=NONE ctermfg=NONE ctermbg=NONE gui=NONE guifg=NONE guibg=NONE
" Add a timestamp to completed items
"let g:VimTodoListsDatesEnabled = 1

"" VimAck settings
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Change colors so dark red and red aren't right next to each other
let g:rbpt_colorpairs = [
	\ ['darkcyan',    'RoyalBlue3'],
	\ ['darkred',     'SeaGreen3'],
	\ ['darkmagenta', 'DarkOrchid3'],
	\ ['brown',       'firebrick3'],
	\ ['gray',        'RoyalBlue3'],
	\ ['Darkblue',    'SeaGreen3'],
	\ ['darkgreen',   'DarkOrchid3'],
	\ ['darkcyan',    'firebrick3'],
	\ ['darkred',     'RoyalBlue3'],
	\ ['darkmagenta', 'SeaGreen3'],
	\ ['brown',       'DarkOrchid3'],
	\ ['gray',        'firebrick3'],
	\ ['Darkblue',    'RoyalBlue3'],
	\ ['darkgreen',   'SeaGreen3'],
	\ ['darkcyan',    'DarkOrchid3'],
	\ ['red',         'firebrick3'],
	\ ]


"" Other Colors
hi Visual  term=reverse ctermbg=7 guibg=LightGrey guifg=Black ctermfg=0

autocmd FileType text AnsiEsc
