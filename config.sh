#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install  git cmake tmux vim
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install git cmake tmux vim 
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install git cmake tmux vim
fi

apt-get --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt-get install git cmake tmux vim
fi

cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp ./.vimrc ~/
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --clangd-completer

