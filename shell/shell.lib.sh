#!/usr/bin/env bash
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
[[ -x "$(command -v shopt)" ]] && {
  shopt -s expand_aliases
}

# Source: https://stackoverflow.com/questions/13195655/bash-set-x-without-it-being-printed
alias setTrace='set -o xtrace'
alias unsetTrace='{ set +o xtrace; } 2>/dev/null'

# Source: https://stackoverflow.com/questions/749544/pipe-to-from-the-clipboard-in-a-bash-script
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"

COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[0;33m'
COLOR_YELLOW_BOLD='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'

BLINK='\033[5m'
UNDERLINE='\033[4m'
EFFECT_NONE='\033[0m'

## Identify build system
if [[ -x "$(command -v podman)" ]]
then
  CONTAINER_CLI=podman
else
  CONTAINER_CLI=docker
fi

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
  [[ ${#} -ne 0 ]] && {
    local MAX_LINES=${1}
  }
  local -r NUM_SPACES=$(( $(tput cols) * ${MAX_LINES} ))
  printf "%${NUM_SPACES}s\n" | tr " " "-"
}

pHeader() {
  local -r lenOfString=$(( ${#1} + 8 ))
  printf "%${lenOfString}s\n" | tr " " "-"
  echo "--- ${1} ---"
  printf "%${lenOfString}s\n" | tr " " "-"
}

pNote() {
  printf "[$(pTimestamp)] ${COLOR_YELLOW_BOLD}${UNDERLINE}Note: ${*}${EFFECT_NONE}${EFFECT_NONE}"
}

pQuery() {
  ## Note: Extra space at the end is intentional!
  printf "[$(pTimestamp)] ${COLOR_BLUE}${UNDERLINE}${BLINK}Query: ${*}${EFFECT_NONE}${EFFECT_NONE}${EFFECT_NONE} "
}

pInfo() {
  printf "[$(pTimestamp)] ${COLOR_GREEN}INFO: ${*}${EFFECT_NONE}"
}

pWarn() {
  printf "[$(pTimestamp)] ${COLOR_YELLOW}WARN: ${*}${EFFECT_NONE}"
}

pError() {
  printf "[$(pTimestamp)] ${COLOR_RED}${UNDERLINE}ERROR: ${*}${EFFECT_NONE}${EFFECT_NONE}"
}

getUserInput() {
  [[ ${#} -lt 2 ]] && {
    pError "Need to provide two params: (1) Sink variable name and (2) the user prompt."
    return 1;
  }
  pQuery "${2} "
  read ${1}
}

waitToContinue() {
  pQuery "${1:-Press any key to continue ...}"
  local IGNORED_INPUT
  [[ -n $ZSH_VERSION ]] && read -k1 IGNORED_INPUT || read -n1 IGNORED_INPUT
  printf "\n"
}

ynQuery() {
  while true
  do
    pQuery "${1} [Y/N]"
    read CHOICE
    case ${CHOICE} in
      y|Y)
        return 0
        ;;
      n|N)
        return 1
        ;;
      *)
        pError "Input '${CHOICE}' is invalid, please try again\n"
    esac
  done
}

runCmd() {
  local cmd=${1}
  [[ -z ${cmd} ]] && {
    pError 'ERROR: Require cmd as first argument!\n'
    return 1
  }
  pInfo "+ ${cmd}\n"
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
## CONTAINER METHODS
#############################

rshToContainerImage() {
  local -r containerimg=${1}
  [[ -z ${containerimg} ]] && {
    pError "Missing container image\n"
    return 1
  }
  ${CONTAINER_CLI} run -it --entrypoint=/bin/sh ${containerimg}
}

rshIntoContainer() {
  local -r containerid=${1}
  [[ -z ${containerid} ]] && {
    pError "Missing container id\n"
    return 1
  }
  ${CONTAINER_CLI} exec -it ${containerid} \\bin\\bash
}

createContainerFromImg() {
  local -r containerimg=${1}
  [[ -z ${containerimg} ]] && {
    return 1
  }
  ${CONTAINER_CLI} create ${containerimg}
}

cpFromContainer() {
  local -r containerimg=${1}
  local -r srcpath=${2}
  local -r dstpath=${3}
    pError "Missing container image\n"
  [[ -z ${containerimg} ]] && {
    return 1
  }
  [[ -z ${srcpath} ]] && {
    pError "Missing container container file path\n"
    return 1
  }
  [[ -z ${dstpath} ]] && {
    pError "Missing local host file path\n"
    return 1
  }
  local -r id=$(${CONTAINER_CLI} create ${containerimg})
  ${CONTAINER_CLI} cp ${id}:${srcpath} ${dstpath}
  ${CONTAINER_CLI} rm -v ${id}
}

#############################
## GIT METHODS
#############################

gitBranch() {
  git rev-parse --abbrev-ref=strict HEAD
}

gitBranchUpstream() {
  #git remote show origin | sed -n '/HEAD branch/s/.*: //p'
  git remote show origin | awk '/HEAD branch/ {print $NF}'
}

gitDiffFile() {
  [[ $# -lt 1 ]] && {
    pError "Need to provide a filename!\n"
    return 1
  }
  git diff -- $(find . -iname ${1})
}

gitDiffTool() {
  git difftool --no-prompt
}

gitDiffStatus() {
  git status -v | bat --language=diff
}

gitDiffRemote() {
  git diff origin/$(gitBranch) $(gitBranch) | bat --language=diff
}

gitDiffLocalUpstream() {
  git diff $(gitBranchUpstream) $(gitBranch) | bat --language=diff
}

gitDiffRemoteUpstream() {
  git diff origin/$(gitBranchUpstream) $(gitBranch) | bat --language=diff
}

gitDiffFileRemoteUpstream() {
  [[ -z ${1} ]] && {
    pError "Need to provide path to file!\n"
    return 1
  }
  git diff origin/$(gitBranchUpstream) $(gitBranch) -- ${1} | bat --language=diff
}

gitUndoLastCommit() {
  git reset --soft HEAD~1
}

#############################
## SHELL METHODS
#############################

ln_for_usr() {
  local -r filepath=$(realpath "${1}")
  [[ -z "${1}" || -z "${filepath}" ]] && {
    pError "No valid filepath provided\n"
    return 1
  }
  local -r filename=$(echo "${filepath}" | rev | cut -d '/' -f1 | rev)
  set -o xtrace
  sudo ln -s "${filepath}" "/usr/local/bin/${filename/.sh/}"
}

backup() {
  for filepath in "${@}"
  do
    cp -va ${filepath} ${filepath}.bak
  done
}

softdelete() {
  local -r filepath=$(realpath -q "${1}")
  [[ -z "${1}" || -z "${filepath}" ]] && {
    pError "No valid filepath was found for argument '${1}'"
    return 1
  }
  local -r new_filepath="/tmp/$(echo -n "${filepath}" | tr '/' '_')"
  mv -v ${filepath} ${new_filepath}
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
  [[ ! ${PWD} =~ ${pattern} ]] && {
    pError "Parent Directory '${dirname}' could not be found\n"
    return 1
  }
  [[ -n $ZSH_VERSION ]] && cd "${${match[@]:0:2}/ //}" || cd "$(printf ${BASH_REMATCH[@]:1:2} | tr ' ' '/')"
}

nvimfind() {
  local -r filename="${1}"
  local -r filepaths=$(find . -name "${filename}")
  [[ -z ${filepaths} ]] && {
    pError "No file found matching search name \"${filename}\"\n"
    return 1
  }
  nvim -p "${filepaths}"
}

cdfile() {
  local -r filename="${1}"
  local -r dirpath=$(find . -name "${filename}" -print -quit)
  [[ -z ${dirpath} ]] && {
    pError "No file found matching search name \"${filename}\"\n"
    return 1
  }
  cd "$(dirname "${dirpath}")"
}

filescontaining() {
  [[ -z "${1}" ]] && {
    pError "Missing the pattern argument!\n"
    return 1;
  }
  local -r pattern="${1}"
  local -r dirpath="${2:-.}"
  grep -ir "${pattern}" "${dirpath}" | grep -v "^Binary file" | cut -d ':' -f1 | sort | uniq
}

overwriteWithCopy() {
  local -r filepath="${1}"
  [[ -z ${filepath} ]] && {
    pError "Missing valid filepath!\n"
    return 1
  }
  [[ ! -f ${filepath} ]] && {
    pError "There is no valid file: \"${filepath}\"\n"
    return 2
  }
  local -r newpath=$(find . -type f -name $(basename ${filepath}) | grep -v "${filepath}")
  [[ $(echo -e "${newpath}" | wc -l) -gt 1 ]] && {
    pError "Found multiple matches for $(basename ${filepath}) ...\n"
    echo -e "${newpath}"
    return 2
  }
  [[ ! -f ${newpath} ]] && {
    pError "Found no such file $(basename ${filepath}) in any sub-directories!\n"
    return 3
  }
  mv -vf ${filepath} ${newpath}
}
