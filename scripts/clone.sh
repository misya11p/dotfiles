#!/bin/bash

echo "Cloning dotfiles repository."

cd

[ ! -d ~/.config/git ] && mkdir -p ~/.config/git
touch ~/.config/git/config
git config --global ghq.root ~/.repo

ghq get misya11p/dotfiles
echo "cd $(ghq root)/github.com/misya11p/dotfiles"
