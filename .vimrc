execute pathogen#infect()

filetype plugin indent on

syntax on

set hlsearch
set ruler

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

let mapleader = "-"

nnoremap U :redo<CR>

vnoremap > > gv
vnoremap < < gv

nnoremap <Leader>p :set paste!<CR>
nnoremap <silent> <Leader>sv :so $HOME/.vimrc<CR>

"" Python mappings
" In both visual and normal mode, insert a '#' at the start of a line (to comment it out)
vnoremap <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^', '#', ''))<CR>
nnoremap <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^', '#', ''))<CR>
" In both visual and normal mode, remove a '#' at the start of a line (to uncomment it)
vnoremap <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^#', '', ''))<CR>
nnoremap <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^#', '', ''))<CR>
" Put a python debugger statement above the current line using the same leading whitespace as is in the current line
nnoremap <silent> <Leader>db :call append(line('.') - 1, [substitute(getline('.'), '^\(\s*\).*$', '\1', '') . 'import pdb; pdb.set_trace()'])<CR>

"" Syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1

let g:syntastic_mode_map = {
	\ "mode": "active",
	\ "active_filetypes": [],
	\ "passive_filetypes": [] }

" Ignore html files
let g:syntastic_ignore_files = ['html$']

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

""Clojure options
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
