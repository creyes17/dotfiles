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

nnoremap U :redo<CR>

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

"" Golang mappings
" In both visual and normal mode, insert '//' at the start of a line (to comment it out)
autocmd FileType *.go vnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
autocmd FileType *.go nnoremap <buffer> <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^\s*\zs', '\/\/ ', ''))<CR>
" In both visual and normal mode, remove '//' at the start of a line (to uncomment it)
autocmd FileType *.go vnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>
autocmd FileType *.go nnoremap <buffer> <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^\s*\zs\/\/\s*', '', ''))<CR>

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

"" Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

" Ignore 'line too long' errors
"let g:syntastic_python_flake8_args='--ignore=E501'

" Toggle between python 2 and python 3 for Syntastic
function! Creyes17Py2()
  let g:syntastic_python_flake8_exec = 'flake8-py2'
  let g:syntastic_python_python_exec = 'python2.7'
endfunction

function! Creyes17Py3()
  let g:syntastic_python_flake8_exec = 'flake8-py3'
  let g:syntastic_python_python_exec = 'python3'
endfunction

" Default to python 2
call Creyes17Py2()

" Allow changing between them
nnoremap <Leader>sp2 :call Creyes17Py2()<CR>
nnoremap <Leader>sp3 :call Creyes17Py3()<CR>


let g:syntastic_mode_map = {
	\ "mode": "active",
	\ "active_filetypes": [],
	\ "passive_filetypes": [] }

" Add javascript and html checkers
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_html_checkers = ['htmlhint']
let g:syntastic_html_htmlhint_args = "--config ~/.htmlhintrc"

" Navigate between Syntastic errors
nnoremap <silent> <Leader>sn :lnext<CR>
nnoremap <silent> <Leader>sp :lprev<CR>
nnoremap <silent> <Leader>st :SyntasticToggle<CR>

"" YouCompleteMe settings

"	Let the "Enter" key also select an option from the menu
"let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']
"	Don't automatically insert/select anything automatically
"set completeopt+=noinsert
"set completeopt+=noselect
" Specify the correct python executable to use
"let g:ycm_server_python_interpreter = '/Users/chris/github/creyes17/dotfiles/venv/work/bin/python'
let g:ycm_server_python_interpreter = '/usr/bin/python'

"let g:ycm_python_binary_path = '/usr/local/bin/python3'

"" RainbowParentheses Options
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

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
