" Visuals (line numbers, column bar, syntax)
set number
set ruler
set colorcolumn=80
highlight ColorColumn ctermbg=grey
syntax on

" Enables character deletion to moving to prev line
set backspace=indent,eol,start

" Indentation
set autoindent
set expandtab
set softtabstop=4
set shiftwidth=4

" Case-insensitive, and highlighted search matches
set ignorecase
set smartcase
set hlsearch
set incsearch

" Mouse support for selecting text and resizing windows
set mouse=a

" Enable system clipboard
set clipboard+=unnamed

" FileTypes
filetype plugin indent on
autocmd FileType markdown setlocal textwidth=80
autocmd FileType markdown setlocal spell
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent
autocmd FileType go setlocal tabstop=4 noexpandtab

" Vim Plugins (place in filepath ~/.vim/pack/plugins)
"
" git clone https://github.com/fatih/vim-go.git ~/.vim/pack/plugins/start/vim-go

