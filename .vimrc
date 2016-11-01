:set autoindent
:set smartindent
:set ts=4
:set tabstop=4
:set shiftwidth=4
:set hlsearch
:set nu
:set scrolloff=5
au BufRead,BufNewFile jquery.*.js set ft=javascript syntax=jquery

:nnoremap U :redo<CR>

:execute pathogen#infect()
