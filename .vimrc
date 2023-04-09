" Globals
set autoindent
set expandtab|  " Use the appropriate number of spaces to insert a <Tab>.
set softtabstop=4
set shiftwidth=4
set number
set ruler|      " Show the line and column number of the cursor position
set colorcolumn=80
highlight ColorColumn ctermbg=grey
syntax on

" FileTypes
augroup my_markdown_settings
  autocmd!|     " Clears all existing autocmds in this group
  autocmd FileType markdown setlocal textwidth=80
  autocmd FileType markdown setlocal spell
augroup END
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab autoindent

