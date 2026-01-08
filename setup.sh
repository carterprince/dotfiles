#!/bin/bash

sudo pacman -S --noconfirm --needed git
mkdir -p $HOME/.local/src/
git clone https://github.com/carterprince/dotfiles $HOME/.local/src/dotfiles || true
cd $HOME/.local/src/dotfiles
git pull
./install.sh
