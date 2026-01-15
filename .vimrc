" Enable syntax highlighting
syntax on

" Enable filetype detection for syntax highlighting
filetype plugin indent on

" Enable 256 colors in terminal
set t_Co=256

" Set the encoding to UTF-8
set encoding=utf-8

" Set the file encoding to UTF-8
set fileencoding=utf-8

" Show line numbers
set number

" Highlight all instances of searched text
set hlsearch

" Ignore case when searching
set ignorecase

" Make search case-insensitive and highlight matches
set incsearch

" Use 4 spaces instead of tabs
set expandtab
set tabstop=4
set shiftwidth=4

" Enable auto indentation
set autoindent

" Enable smart indentation
set smartindent

" Set the ruler to show the current line and column
set ruler

" Show the current command in the status line
set showcmd

" Set the color scheme to desert
colorscheme torte

" Map Ctrl + S to save the file
nnoremap <C-s> :w<CR>

" Map Ctrl + Q to quit the file
nnoremap <C-q> :q<CR>
