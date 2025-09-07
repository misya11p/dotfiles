#!/bin/sh

DOTFILES_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

DIR_BACKUP="$DOTFILES_ROOT/backup/$(date +'%Y%m%d%H%M%S')"
mkdir -p $DIR_BACKUP
cp $HOME/.zshenv $DIR_BACKUP/.zshenv.bak
cp $HOME/.zshrc $DIR_BACKUP/.zshrc.bak

echo "source $DOTFILES_ROOT/zsh/zshenv" >> $HOME/.zshenv
echo "source $DOTFILES_ROOT/zsh/zshrc" >> $HOME/.zshrc
