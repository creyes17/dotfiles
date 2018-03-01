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
vnoremap <silent> <Leader>e :call setline(line('.') , substitute(getline('.'), '^', '#', ''))<CR>
vnoremap <silent> <Leader>E :call setline(line('.') , substitute(getline('.'), '^#', '', ''))<CR>

nnoremap <Leader>p :set paste!<CR>
nnoremap <Leader>sv :so $HOME/.vimrc<CR>

" Syntastic settings
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

" YouCompleteMe settings
"	Let the "Enter" key also select an option from the menu
"let g:ycm_key_list_select_completion = ['<TAB>', '<Down>', '<Enter>']
"	Don't automatically insert/select anything automatically
"set completeopt+=noinsert
"set completeopt+=noselect
" Specify the correct python executable to use
let g:ycm_server_python_interpreter = '/usr/local/bin/python3'
let g:ycm_python_binary_path = '/usr/local/bin/python3'

"Clojure options
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
