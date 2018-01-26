#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs cmake ctags cscope id-utils
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install clang llvm clang-libs cmake ctags cscope id-utils
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm cmake ctags cscope id-utils
fi

apt-get --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt-get install libclang-dev clang llvm cmake ctags cscope id-utils
fi

#curl -sLf https://spacevim.org/install.sh | bash

folder=`pwd`
cd ~/
mkdir -p exvim
cd exvim
git clone https://github.com/exvim/main
cd main
sh unix/install.sh
sh unix/replace-my-vim.sh
cd $folder

cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/
cp ./.gitconfig ~/

echo "nnoremap <C-k> <C-W><Up>" >> ~/.vimrc
echo "nnoremap <C-j> <C-W><Down>" >> ~/.vimrc
echo "nnoremap <C-h> <C-W><Left>" >> ~/.vimrc
echo "nnoremap <C-l> <C-W><Right>" >> ~/.vimrc
echo "nnoremap <TAB> :bn <CR>" >> ~/.vimrc
echo "nnoremap <unique> <silent> wm :EXProjectToggle<cr>" >> ~/.vimrc
