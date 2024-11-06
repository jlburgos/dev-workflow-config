#!/bin/bash

## Should run script from current directory
current_dir="$(realpath $(pwd))"
script_dir="$(dirname "$(realpath "$0")")"
[ "$current_dir" == "$script_dir" ] || {
  echo "Error: This script must be run from the directory it is located in."
  echo "Current Directory: ${current_dir}"
  echo "Script  Directory: ${script_dir}"
  exit 1
}

set -o xtrace

## Common git stuff
[ -f ${HOME}/.gitconfig ] || ln -s ${PWD}/git/gitconfig ${HOME}/.gitconfig

## Terminal stuff
[ -f ${HOME}/.shell.lib ] || ln -s ${PWD}/shell/shell.lib ${HOME}/.shell.lib
[ -f ${HOME}/.screenrc ]  || ln -s ${PWD}/screen/screenrc ${HOME}/.screenrc
[ -f ${HOME}/.tmux.conf ] || ln -s ${PWD}/tmux/tmux.conf ${HOME}/.tmux.conf

## Favorite editor stuff
[ -f ${HOME}/.vimrc ] || ln -s ${PWD}/vim/vimrc ${HOME}/.vimrc
[ -d ${HOME}/.config/nvim ] || {
  mkdir -p ${HOME}/.config
  ln -s ${PWD}/nvim ${HOME}/.config/nvim
}

## Shell stuff
[ -f ${HOME}/.config/oh-my-zsh/custom/themes/custom-ys.zsh-theme ] || {
  [ -d ${HOME}/.config/oh-my-zsh] || ln -s ${HOME}/.oh-my-zsh ${HOME}/.config/oh-my-zsh
  ln -s ${PWD}/zsh/custom-ys.zsh-theme ${HOME}/.config/oh-my-zsh/custom/themes/custom-ys.zsh-theme 
}
