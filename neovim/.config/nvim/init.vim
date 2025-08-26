" skybound neovim setup 

" why both? needed for normal number for currline 
" + relative position from normal line
set number
set relativenumber
" adding additional context in the side column
set signcolumn=number

"""""""""""""""""""""""
" CODE QUALITY CHECKS "
"""""""""""""""""""""""

" just making sure
syntax on

" tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" indents
set autoindent
set copyindent

" activate file helpers
filetype plugin indent on


" to warn when column length > 140
set colorcolumn=140

" search
set incsearch
set hlsearch

" scrolling
set scrolloff=5

" clipboard, yy/dd is copy paste
set clipboard=unnamedplus

" menu
set wildmenu
set wildmode=longest:full,full
