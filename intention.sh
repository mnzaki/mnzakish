#!/bin/bash
#===============================================================================
#
#          FILE: intention.sh
#
#         USAGE: source ./intention.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 24.06.2021 23:13:05
#      REVISION:  ---
#===============================================================================

if [ "$0" = "$BASH_SOURCE" ]; then
  echo "You are trying to directly invoke intention."
  echo "Intention must be sourced."
  exit 1
fi

#set -o nounset                                  # Treat unset variables as an error
MSHBASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )"

STACK_CHAR="${STACK_CHAR:-|}"
INTENTIONS=("${INTENTIONS[@]}")
INTENTIONS_DONE=("${INTENTIONS_DONE[@]}")

PS1="${PS1/'$(printdirstack)'/}"
export PS1='$(printdirstack)'"$PS1"

function printdirstack {
  local STACK=(`dirs -p`)
  local STACK="${STACK[@]/*/$STACK_CHAR}"
  echo -n ${STACK// /}
}

function readintention {
  echo "${@:-$(cat -)}"
}

function setintention {
  local INTENTION="$(readintention "$@")"
  local STACK=(`dirs -p`)
  local PRE_INTENTION="${INTENTIONS[ (( ${#STACK[@]} - 1 )) ]}"
  INTENTIONS[(( ${#STACK[@]} - 1 ))]="$PRE_INTENTION\n$INTENTION"
}

function si {
  setintention "$@"
}

function getintentions {
  local STACK=(`dirs -p`)
  local STACKN=${#STACK[@]}
  for (( idx=0; idx<$STACKN; idx++ )); do
    echo -n ${STACK[(($idx))]}
    echo -e "${INTENTIONS[$STACKN - idx - 1]}\n"
  done

  echo "previously:"
  echo -e "\n${INTENTIONS_DONE[@]}"
}

function gist {
  getintentions
}

function gi {
  getintentions
}

function diverge {
  pushd $1
  setintention
}

function di {
  diverge "${@:-.}"
}

function diversiondone {
  local STACK=(`dirs -p`)
  local IDX=$((${#STACK[@]} - 1))
  INTENTIONS_DONE+=("${STACK[$IDX]}${INTENTIONS[$IDX]}")
  INTENTIONS[$IDX]=''
  popd
}

function dn {
  diversiondone
}
