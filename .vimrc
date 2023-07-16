" Visuals (line numbers, column bar, syntax)
set number
set ruler
set colorcolumn=80
highlight ColorColumn ctermbg=grey
syntax on

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
autocmd FileType markdown setlocal textwidth=80
autocmd FileType markdown setlocal spell
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent

