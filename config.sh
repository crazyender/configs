#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs cmake ctags cscope id-utils powerline git
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install clang llvm clang-libs cmake ctags cscope id-utils powerline git
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm cmake ctags cscope id-utils powerline git
fi

apt-get --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt-get install libclang-dev clang llvm cmake ctags cscope id-utils powerline git
fi

#curl -sLf https://spacevim.org/install.sh | bash
pip install git+git://github.com/powerline/powerline
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv PowerlineSymbols.otf /usr/share/fonts 
mv 10-powerline-symbols.conf /etc/fonts/conf.d/ 
fc-cache -vf /usr/share/fonts/ 

cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/
cp ./.gitconfig ~/ 

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# for vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
cp ./.vimrc ~/
vim +PluginInstall +qall
cd ~/.vim/bundle/YouCompleteMe
./install.py --clang-completer --clangd-completer

