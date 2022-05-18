#!/bin/zsh

function enableDebug() {
  set -eu -o history -o histexpand -o pipefail
}

function trimspaces() {
  sed -e 's/^[[:space:]]*//' <<< $1
}

function trimspaces2() {
  xargs <<< $1
}

function pinfo() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[32mINFO: $*\e[0m"
}

function pwarn() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mWARN: $*\e[0m" 1>&2
}

function perror() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mERROR: $*\e[0m" 1>&2
}

function lst-zsh-themes() {
  ls "${ZSH}/themes"
}

function set-zsh-theme() {
  local theme="${1}"
  [[ -z "${theme}" ]] && { echo "Need to provide theme!" } || {
    echo "Setting theme to: '${theme}' ..."
    sed -i -e "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/g" "${HOME}/.zshrc"
    source "${HOME}/.zshrc"
  }
}
