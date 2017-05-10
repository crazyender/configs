#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs cmake
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install clang llvm clang-libs cmake
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm cmake
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/liuchengxu/space-vim/master/install.sh)"
git clone https://github.com/powerline/fonts.git ~/.fonts
sh ~/.fonts/install.sh
vim

~/.vim/plugged/YouCompleteMe/install.py --clang-completer --system-libclang

cp ./.vimrc ~/
cp ./.spacevim ~/
cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/
cp ./.gitconfig ~/

