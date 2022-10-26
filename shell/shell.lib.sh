#!/bin/sh

# Custom shell aliases and functions

# Shell Flags
## Notes: https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425#original-reference
## Notes: http://redsymbol.net/articles/unofficial-bash-strict-mode/

## Aliases

# Enable aliases in shell scripts if 'shopt' command available
[ -x "$(command -v shopt)" ] && {
  shopt -s expand_aliases
}

# Source: https://stackoverflow.com/questions/13195655/bash-set-x-without-it-being-printed
alias setTrace='set -x'
alias unsetTrace='{ set +x; } 2>/dev/null'

## Functions

trimSpaces() {
  printf "${1}" | xargs
}

pTimestamp() {
  date "+%F | %r %Z"
}

pNewLine() {
  printf "\n"
}

pHLine() {
  [ ${#} -eq 0 ] && {
    local -r MAX_LINES=1
  } || {
    local -r MAX_LINES=${1}
  }
  local -r NUM_COLS=$(tput cols)
  local -r NUM_SPACES=$(( ${NUM_COLS} * ${MAX_LINES} ))
  printf "%${NUM_SPACES}s\n" | tr " " "-"
}

pNote() {
  printf "[$(pTimestamp)] \e[1;33mNote: ${*}\e[0m"
}

pNotice() {
  printf "[$(pTimestamp)] \e[32m\e[4mNotice: ${*}\e[0m\e[0m"
}

pInfo() {
  printf "[$(pTimestamp)] \e[32mINFO: ${*}\e[0m"
}

pWarn() {
  printf "[$(pTimestamp)] \e[1;33mWARN: ${*}\e[0m"
}

pError() {
  printf "[$(pTimestamp)] \e[31m\e[4mERROR: ${*}\e[0m\e[0m"
}

pQuery() {
  ## Note: Extra space at the end is intentional
  printf "[$(pTimestamp)] \e[34m\e[4mQuery: ${*}\e[0m\e[0m "
}

waitToContinue() {
  pQuery "Press any key to continue ..."
  local IGNORED_INPUT
  read -n1 IGNORED_INPUT
  printf "\n"
}

ynQuery() {
  while true
  do
    pQuery "${1} [Y/N]"
    read CHOICE
    case ${CHOICE} in
      y|Y) return 0 ;;
      n|N) return 1 ;;
      *) pError "Input '${CHOICE}' is invalid, please try again\n"
    esac
  done
}

remoteCmd() {
  [ "${#}" -ne 1 ] && {
    pError "Need to provide string param containing remote command\n"
    return 1
  }
  pNote "Running remote command via SSH: ${1}\n"
  local -r INIT_CMDS="source .bashrc && source .bash_profile"
  ssh -t ${FYRE_QB} "${INIT_CMDS}; ${1}"
}


rshToDocker() {
  local -r dockerimg=${1}
  [ -z ${dockerimg} ] && {
    echo "Missing docker image"
    return 1
  }
  docker run -it --entrypoint=/bin/sh ${dockerimg}
}

cpFromDocker() {
  local -r dockerimg=${1}
  local -r srcpath=${2}
  local -r dstpath=${3}
  [ -z ${dockerimg} ] && {
    echo "Missing docker image"
    return 1
  }
  [ -z ${srcpath} ] && {
    echo "Missing docker container file path"
    return 1
  }
  [ -z ${dstpath} ] && {
    echo "Missing local host file path"
    return 1
  }
  local -r id=$(docker create ${dockerimg})
  docker cp ${id}:${srcpath} ${dstpath}
  docker rm -v ${id}
}

