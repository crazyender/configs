#!/bin/bash
sudo apt install vim-youcompleteme
vam install youcompleteme
echo "let g:ycm_global_ycm_extra_conf = \"~/.vim/.ycm_extra_conf.py\"" >> ~/.vimrc
cp .ycm_extra_conf.py ~/.vim/.ycm_extra_conf.py

