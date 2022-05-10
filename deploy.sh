#!/bin/bash
set -x
[ -f ${HOME}/.vimrc ] || ln -s ${PWD}/vim/vimrc ${HOME}/.vimrc
[ -f ${HOME}/.screenrc ]  || ln -s ${PWD}/screenrc/screenrc ${HOME}/.screenrc
[ -f ${HOME}/.tmux.conf ] || ln -s ${PWD}/tmux/tmux.conf ${HOME}/.tmux.conf
[ -d ${HOME}/.config/nvim ] || ln -s ${PWD}/nvim ${HOME}/.config/nvim
