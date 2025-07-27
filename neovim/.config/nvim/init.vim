" skybound neovim setup

"""""""""""""""""""
" LINE NUMBERINGS "
"""""""""""""""""""

" why both? needed for normal number for currline 
" + relative position from normal line
set number
set relativenumber

"""""""""""""""""""""""
" CODE QUALITY CHECKS "
"""""""""""""""""""""""

" to warn when column length > 80
highlight ColorColumn ctermbg=magenta
call matchadd('ColorColumn', '\%81v', 100)
