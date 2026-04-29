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

ZDOTDIR_CONFIG='export ZDOTDIR="$HOME"/.config/zsh'
if [ -f /etc/zshenv ]; then
    echo "$ZDOTDIR_CONFIG" | sudo tee -a /etc/zshenv > /dev/null
elif [ -f /etc/zsh/zshenv ]; then
    echo "$ZDOTDIR_CONFIG" | sudo tee -a /etc/zsh/zshenv > /dev/null
else
    echo "Notice: /etc/zshenv or /etc/zsh/zshenv not found. Please set ZDOTDIR manually if needed."
fi

echo "Completed setting up zsh configuration files."
