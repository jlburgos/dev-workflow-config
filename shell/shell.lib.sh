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
alias setTrace='set -o xtrace'
alias unsetTrace='{ set +o xtrace; } 2>/dev/null'

# Source: https://stackoverflow.com/questions/749544/pipe-to-from-the-clipboard-in-a-bash-script
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"


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

getUserInput() {
  [ ${#} -lt 1 ] && {
    pError "Need to provide two params: (1) Sink variable name and (2) Optional custom prompt"
    return 1;
  }
  pQuery "${2:-Please enter the value you want to set} "
  read ${1}
}

waitToContinue() {
  pQuery "${1:-Press any key to continue ...}"
  local IGNORED_INPUT
  [[ -n $ZSH_VERSION ]] && {
    read -k1 IGNORED_INPUT
  } || {
    read -n1 IGNORED_INPUT
  }
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
  [[ -z ${cmd} ]] && {
    pError 'ERROR: Require cmd as first argument!\n'
    return 1
  }
  printf "+ ${cmd}\n"
  eval "${cmd}"
}

remoteCmd() {
  [[ "${#}" -ne 2 ]] && {
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

rshToDockerImage() {
  local -r dockerimg=${1}
  [[ -z ${dockerimg} ]] && {
    pError "Missing docker image\n"
    return 1
  }
  docker run -it --entrypoint=/bin/sh ${dockerimg}
}

rshToDockerContainer() {
  local -r containerid=${1}
  [[ -z ${containerid} ]] && {
    pError "Missing container id\n"
    return 1
  }
  docker exec -it ${containerid} \\bin\\bash
}

cpFromDocker() {
  local -r dockerimg=${1}
  local -r srcpath=${2}
  local -r dstpath=${3}
  [[ -z ${dockerimg} ]] && {
    pError "Missing docker image\n"
    return 1
  }
  [[ -z ${srcpath} ]] && {
    pError "Missing docker container file path\n"
    return 1
  }
  [[ -z ${dstpath} ]] && {
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

gBranch() {
  git rev-parse --abbrev-ref=strict HEAD
}

gBranchUpstream() {
  #git remote show origin | sed -n '/HEAD branch/s/.*: //p'
  git remote show origin | awk '/HEAD branch/ {print $NF}'
}

gDiffStatus() {
  git status -v | bat --language=diff
}

gDiffRemote() {
  git diff origin/$(gBranch) $(gBranch) | bat --language=diff
}

gDiffLocalUpstream() {
  git diff $(gBranchUpstream) $(gBranch) | bat --language=diff
}

gDiffRemoteUpstream() {
  git diff origin/$(gBranchUpstream) $(gBranch) | bat --language=diff
}

gUndoLastCommit() {
  git reset --soft HEAD~1
}

#############################
## SHELL METHODS
#############################

backup() {
  for filepath in "${@}"
  do
    cp -var ${filepath} ${filepath}.bak
  done
}

cdback() {
  local -r dirname="${1}"
  [[ -z ${dirname} ]] && {
    pError "Missing required parameter: Parent Directory Name\n"
    return 1
  }
  ## Note: https://stackoverflow.com/questions/22537804/retrieve-a-word-after-a-regular-expression-in-shell-script
  ##       ZSH uses ${match} for array while bash has ${BASH_REMATCH}.
  ## Note: https://stackoverflow.com/questions/1335815/how-to-slice-an-array-in-bash
  ##       Made use of nested ${..} bash constructs to rebuild directory path.
  ## Note: Had to do the bash version a bit differently due to "substitution error" with nested ${..} construct.
  ##       Also, array indexing was different between zsh and bash for some reason...
  local -r pattern="^(.+)\/(${dirname})\/(.*)$"
  [[ ${PWD} =~ ${pattern} ]] && {
    [[ -n $ZSH_VERSION ]] && cd "${${match[@]:0:2}/ //}" || cd "$(printf ${BASH_REMATCH[@]:1:2} | tr ' ' '/')"
  } || {
    pError "Parent Directory '${dirname}' could not be found\n"
  }
}

nvimfind() {
  local -r filename="${1}"
  local -r filepaths=$(find . -name "${filename}")
  [[ -z ${filepaths} ]] && {
    pError "No file found matching search name \"${filename}\"\n"
  } || {
    nvim -p "${filepaths}"
  }
}

cdfile() {
  local -r filename="${1}"
  local -r dirpath=$(find . -name "${filename}" -print -quit)
  [[ -z ${dirpath} ]] && {
    pError "No file found matching search name \"${filename}\"\n"
  } || {
    cd "$(dirname "${dirpath}")"
  }
}

filescontaining() {
  grep -ir "${1}" ${2:-.} | grep -v "^Binary file" | cut -d ':' -f1 | sort | uniq
}
