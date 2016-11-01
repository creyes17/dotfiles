execute pathogen#infect()

filetype plugin indent on

syntax on

set hlsearch
set ruler

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

nnoremap U :redo<CR>

vnoremap > > gv
vnoremap < < gv
