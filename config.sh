#!/bin/bash
dnf --version > /dev/null
if [ $? -eq 0 ]; then
    sudo dnf install clang llvm clang-libs cmake ctags cscope
fi

yum --version > /dev/null
if [ $? -eq 0 ]; then
    sudo yum install clang llvm clang-libs cmake ctags cscope
fi

apt --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt install libclang-dev clang llvm cmake ctags cscope
fi

apt-get --version > /dev/null
if [ $? -eq 0 ]; then
    sudo apt-get install libclang-dev clang llvm cmake ctags cscope
fi

folder=`pwd`
cd ~/
mkdir -p exvim
cd exvim
git clone https://github.com/exvim/main
cd main
sh unix/install.sh
sh unix/replace-my-vim.sh
cd ..
wget https://ftp.gnu.org/gnu/idutils/idutils-4.6.tar.xz
tar -xf idutils-4.6.tar.xz
cd idutils-4.6
./configure
make
sudo make install
cd $folder

cp ./.tmux.conf ~/
cp ./.gdbinit ~/
cp ./.bashrc ~/
cp ./.gitconfig ~/

echo "nnoremap <unique> <silent> wm :EXProjectToggle<cr>" >> ~/.vimrc
