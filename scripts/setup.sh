#!/bin/bash

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

DIR_BACKUP="$DOTFILES_ROOT/backup/$(date +'%Y%m%d%H%M%S')"
mkdir -p $DIR_BACKUP

[ ! -d "$HOME/.config/zsh" ] && mkdir -p "$HOME/.config/zsh"
touch "$HOME/.zshenv"
touch "$HOME/.zshrc"
touch "$HOME/.config/zsh/.zshenv"
touch "$HOME/.config/zsh/.zshrc"

mv $HOME/.zshenv $DIR_BACKUP/.zshenv.bak
mv $HOME/.zshrc $DIR_BACKUP/.zshrc.bak
mv $HOME/.config/zsh/.zshenv $DIR_BACKUP/.zshenv_config.bak
mv $HOME/.config/zsh/.zshrc $DIR_BACKUP/.zshrc_config.bak

echo "source $DOTFILES_ROOT/zsh/zshenv" > $HOME/.config/zsh/.zshenv
echo "source $DOTFILES_ROOT/zsh/zshrc" > $HOME/.config/zsh/.zshrc
echo 'export ZDOTDIR="$HOME"/.config/zsh' | sudo tee -a /etc/zshenv > /dev/null

echo "Completed setting up zsh configuration files."
