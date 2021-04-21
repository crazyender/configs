set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'

Plugin 'prabirshrestha/async.vim'

Plugin 'prabirshrestha/asyncomplete-lsp.vim'

Plugin 'prabirshrestha/vim-lsp'

Plugin 'ajh17/vimcompletesme'

Plugin 'junegunn/fzf'

Plugin 'rhysd/vim-clang-format'

Plugin 'google/vim-colorscheme-primary'

Plugin 'jremmen/vim-ripgrep'

Plugin 'dominikduda/vim_current_word'

Plugin 'octol/vim-cpp-enhanced-highlight'

Plugin 'crazyender/tabdrop'

Plugin 'jistr/vim-nerdtree-tabs'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

let g:clang_format#code_style = 'file'
let g:clang_format#auto_format = 1
let g:clang_format#auto_format_on_insert_leave = 1
let g:rg_format = '%f:%l:%m'
let g:cpp_class_scope_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
let g:cpp_experimental_template_highlight = 1
let g:nerdtree_tabs_autofind = 1
let g:nerdtree_tabs_focus_on_files = 1
let g:nerdtree_tabs_open_on_console_startup = 2
set completeopt-=preview
set number
set noswapfile
colorscheme desert
syntax on
map wm :NERDTreeTabsToggle<CR>
map ff :FZF<CR>
map <C-]> <plug>(lsp-definition)<CR>
map fs <plug>(lsp-references)<CR>
map fd <plug>(lsp-hover)<CR>
map <tab> :tabnext<CR>
map ' :tabnext<CR>
map ; :tabprevious<CR>
nnoremap <c-s> :w<CR>
inoremap <c-s> <Esc>:w<CR>a
vnoremap <c-s> <Esc>:w<CR>
map ss :Rg --no-ignore -w <cword><CR>
map rg :Rg --no-ignore
map rr :NERDTreeTabsFind<CR>
set mouse=
set ttymouse=

let g:fzf_action = {
  \ 'ctrl-t': ':TabDrop',
  \ 'enter': ':TabDrop',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_buffers_jump = 1

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'allowlist': ['python'],
        \ })
endif

if executable('clangd-12')
    augroup lsp_clangd
        autocmd!
        autocmd User lsp_setup call lsp#register_server({
                    \ 'name': 'clangd',
                    \ 'cmd': {server_info->['clangd-12']},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
                    \ })
        autocmd FileType c setlocal omnifunc=lsp#complete
        autocmd FileType cpp setlocal omnifunc=lsp#complete
        autocmd FileType objc setlocal omnifunc=lsp#complete
        autocmd FileType objcpp setlocal omnifunc=lsp#complete
    augroup end
endif
