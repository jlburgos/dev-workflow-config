# Custom shell functions

enableDebug() {
  set -eu -o history -o histexpand -o pipefail
}

trimSpaces() {
  xargs <<< $1
}

pInfo() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[32mINFO: $*\e[0m"
}

pWarn() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mWARN: $*\e[0m" 1>&2
}

pError() {
  echo -e "[$(date "+%F | %X %p %Z")] \e[31mERROR: $*\e[0m" 1>&2
}

pHLine() {
  printf "%$(tput cols)s\n" | tr " " "-"
}

