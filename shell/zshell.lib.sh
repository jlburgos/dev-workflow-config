# Custom zsh functions for oh-my-zsh

lst-zsh-themes() {
  ls "${ZSH}/themes"
}

set-zsh-theme() {
  local theme="${1}"
  [[ -z "${theme}" ]] && { 
    echo "Need to provide theme!" 
  } || {
    pInfo "Setting theme to: '${theme}' ..."
    sed -i -e "s/^ZSH_THEME=.*/ZSH_THEME=\"${theme}\"/g" "${HOME}/.zshrc"
    source "${HOME}/.zshrc"
  }
}
