#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/liuchengxu/space-vim/master/install.sh)"
git clone https://github.com/powerline/fonts.git ~/.fonts
sh ~/.fonts/install.sh
vim

~/.vim/plugged/YouCompleteMe/install.py --clang-completer --system-libclang

cp ./.vimrc ~/.vimrc
cp ./.spacevim ~/.spacevim
