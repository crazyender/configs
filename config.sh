#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs cmake fish
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install clang llvm clang-libs cmake fish
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm cmake fish
fi

apt-get --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt-get install libclang-dev clang llvm cmake fish
fi

sh -c "$(curl -fsSL https://raw.githubusercontent.com/liuchengxu/space-vim/master/install.sh)"
git clone https://github.com/powerline/fonts.git ~/.fonts
sh ~/.fonts/install.sh
vim
cp ./.vimrc ~/
cp ./.spacevim ~/
cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/
cp ./.gitconfig ~/
vim

~/.vim/plugged/YouCompleteMe/install.py --clang-completer --system-libclang

cp fish_prompt.fish ../.config/fish/functions/


