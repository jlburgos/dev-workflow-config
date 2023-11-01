#!/bin/bash
set -x
[ -f ${HOME}/.gitconfig ] || ln -s ${PWD}/git/gitconfig ${HOME}/.gitconfig
[ -f ${HOME}/.vimrc ] || ln -s ${PWD}/vim/vimrc ${HOME}/.vimrc
[ -f ${HOME}/.screenrc ]  || ln -s ${PWD}/screen/screenrc ${HOME}/.screenrc
[ -f ${HOME}/.tmux.conf ] || ln -s ${PWD}/tmux/tmux.conf ${HOME}/.tmux.conf
[ -d ${HOME}/.config/nvim ] || {
  [ -d ${HOME}/.config ] || mkdir -p ${HOME}/.config
  ln -s ${PWD}/nvim ${HOME}/.config/nvim
}
