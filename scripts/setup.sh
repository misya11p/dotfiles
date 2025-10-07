#!/bin/bash

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

DIR_BACKUP="$DOTFILES_ROOT/backup/$(date +'%Y%m%d%H%M%S')"
mkdir -p $DIR_BACKUP

[ ! -d "$HOME/.config/zsh" ] && mkdir -p "$HOME/.config/zsh"
touch "$HOME/.zshenv"
touch "$HOME/.zshrc"
touch "$HOME/.config/zsh/.zshenv"
touch "$HOME/.config/zsh/.zshrc"

cp $HOME/.zshenv $DIR_BACKUP/.zshenv.bak
cp $HOME/.zshrc $DIR_BACKUP/.zshrc.bak
cp $HOME/.config/zsh/.zshenv $DIR_BACKUP/.zshenv_config.bak
cp $HOME/.config/zsh/.zshrc $DIR_BACKUP/.zshrc_config.bak

cat $HOME/.zshenv >> $HOME/.config/zsh/.zshenv
cat $HOME/.zshrc >> $HOME/.config/zsh/.zshrc

echo "source $DOTFILES_ROOT/zsh/zshenv" >> $HOME/.config/zsh/.zshenv
echo "source $DOTFILES_ROOT/zsh/zshrc" >> $HOME/.config/zsh/.zshrc

rm $HOME/.zshenv
rm $HOME/.zshrc

if [ -f /etc/zshenv ]; then
    echo 'export ZDOTDIR="$HOME"/.config/zsh' | sudo tee -a /etc/zshenv > /dev/null
elif [ -f /etc/zsh/zshenv ]; then
    echo 'export ZDOTDIR="$HOME"/.config/zsh' | sudo tee -a /etc/zsh/zshenv > /dev/null
else
    echo "Could not find /etc/zshenv or /etc/zsh/zshenv. Please set ZDOTDIR manually."
fi

echo "Completed setting up zsh configuration files."
