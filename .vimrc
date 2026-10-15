" Visuals
set number
set ruler
set colorcolumn=80
highlight ColorColumn ctermbg=grey
syntax on

" Backspace over indent, line breaks, insert start
set backspace=indent,eol,start

" Indentation
set autoindent
set expandtab
set softtabstop=4
set shiftwidth=4

" Search: smart case, highlighted, incremental
set ignorecase
set smartcase
set hlsearch
set incsearch

set mouse=a
set clipboard+=unnamed

" FileTypes
filetype plugin indent on
autocmd FileType markdown setlocal textwidth=80 spell
autocmd FileType yaml setlocal ts=2 sts=2 sw=2
autocmd FileType go setlocal tabstop=4 noexpandtab

" Plugins: git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go
