# Custom shell functions

enableDebug() {
  set -eu -o history -o histexpand -o pipefail
}

trimSpaces() {
  echo "${1}" | xargs
}

pTimestamp() {
  date "+%F | %X %Z"
}

pInfo() {
  echo -e "[$(pTimestamp)] \e[32mINFO: $*\e[0m"
}

pWarn() {
  echo -e "[$(pTimestamp)] \e[31mWARN: $*\e[0m" 1>&2
}

pError() {
  echo -e "[$(pTimestamp)] \e[31mERROR: $*\e[0m" 1>&2
}

pHLine() {
  printf "%$(tput cols)s\n" | tr " " "-"
}

