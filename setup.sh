#!/bin/bash

mkdir -p $HOME/.local/src/
git clone https://github.com/carterprince/dotfiles $HOME/.local/src/dotfiles
cd $HOME/.local/src/dotfiles
./install.sh
