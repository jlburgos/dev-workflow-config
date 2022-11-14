#!/bin/sh

#############################
#############################
# Custom shell aliases and functions
#############################
#############################

# Shell Flags
## Notes: https://gist.github.com/mohanpedala/1e2ff5661761d3abd0385e8223e16425#original-reference
## Notes: http://redsymbol.net/articles/unofficial-bash-strict-mode/

#############################
## ALIASES
#############################

# Enable aliases in shell scripts if 'shopt' command available
[ -x "$(command -v shopt)" ] && {
  shopt -s expand_aliases
}

# Source: https://stackoverflow.com/questions/13195655/bash-set-x-without-it-being-printed
alias setTrace='set -x'
alias unsetTrace='{ set +x; } 2>/dev/null'

#############################
## SCRIPTING METHODS
#############################

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
  local MAX_LINES=1
  [ ${#} -ne 0 ] && {
    local MAX_LINES=${1}
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

runCmd() {
  local cmd=${1}
  [ -z ${cmd} ] && {
    pError 'ERROR: Require cmd as first argument!\n'
    return 1
  }
  printf "+ ${cmd}\n"
  eval "${cmd}"
}

remoteCmd() {
  [ "${#}" -ne 2 ] && {
    pError "Need to provide SSH target and remote command as two string parameters\n"
    return 1
  }
  local -r SSH_TARGET=${1}
  local -r SSH_COMMAND=${2}
  pNote "Connecting remote host via ${1} to run remote command :: ${2}\n"
  ssh -t ${SSH_TARGET} "${SSH_COMMAND}"
}

#############################
## DOCKER METHODS
#############################

rshToDocker() {
  local -r dockerimg=${1}
  [ -z ${dockerimg} ] && {
    pError "Missing docker image\n"
    return 1
  }
  docker run -it --entrypoint=/bin/sh ${dockerimg}
}

cpFromDocker() {
  local -r dockerimg=${1}
  local -r srcpath=${2}
  local -r dstpath=${3}
  [ -z ${dockerimg} ] && {
    pError "Missing docker image\n"
    return 1
  }
  [ -z ${srcpath} ] && {
    pError "Missing docker container file path\n"
    return 1
  }
  [ -z ${dstpath} ] && {
    pError "Missing local host file path\n"
    return 1
  }
  local -r id=$(docker create ${dockerimg})
  docker cp ${id}:${srcpath} ${dstpath}
  docker rm -v ${id}
}

#############################
## GIT METHODS
#############################

gbranch() {
  git rev-parse --abbrev-ref=strict HEAD
}
