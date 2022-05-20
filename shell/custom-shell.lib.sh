#!/bin/zsh

enableDebug() {
  set -eu -o history -o histexpand -o pipefail
}

trimspaces() {
  xargs <<< $1
}

pinfo() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[32mINFO: $*\e[0m"
}

pwarn() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mWARN: $*\e[0m" 1>&2
}

perror() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mERROR: $*\e[0m" 1>&2
}

lst-zsh-themes() {
  ls "${ZSH}/themes"
}

set-zsh-theme() {
  local theme="${1}"
  [[ -z "${theme}" ]] && { echo "Need to provide theme!" } || {
    echo "Setting theme to: '${theme}' ..."
    sed -i -e "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/g" "${HOME}/.zshrc"
    source "${HOME}/.zshrc"
  }
}
