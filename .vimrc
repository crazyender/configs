set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'ycm-core/YouCompleteMe'

Plugin 'scrooloose/nerdtree'

Plugin 'junegunn/fzf'

Plugin 'rhysd/vim-clang-format'

Plugin 'google/vim-colorscheme-primary'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
" Open file in new tab
let g:ycm_confirm_extra_conf = 0
let g:ycm_use_clangd = 1
let g:ycm_clangd_uses_ycmd_caching = 0
let g:clang_format#code_style = 'file'
let g:clang_format#auto_format = 1
let g:clang_format#auto_format_on_insert_leave = 1
let g:ycm_clangd_args = []
set completeopt-=preview
set number
set noswapfile
colorscheme desert
"set mouse=
syntax on
map wm :NERDTree<CR>
map <M-O> :FZF<CR>
map <C-]> :YcmCompleter GoTo<CR>
map fs :YcmCompleter GoToReferences<CR>
map <tab> :bn<CR>
map <C-LeftMouse> :YcmCompleter GoTo<CR>

