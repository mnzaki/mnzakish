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
#        AUTHOR: Mina Nagy Zaki <mnzaki@gmail.com>
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

STACK_CHAR="${STACK_CHAR:-|}"
INTENTIONS=("${INTENTIONS[@]}")
INTENTIONS_DONE=("${INTENTIONS_DONE[@]}")

PS1_ADDITION='\[[38;5;7m\]\[[38;1;7m\]$(printdirstack)'
PS1="${PS1/"$PS1_ADDITION"/}"
export PS1="$PS1_ADDITION""$PS1"

function printdirstack {
  local NSTACK=$(dirs -p | wc -l)
  printf "%0.s$STACK_CHAR" $(eval echo {1..$NSTACK})
}

function readintention {
  local INTENTION="${@:-$(cat -)}"
  echo `date -Imin` "$INTENTION"
}

function setintention {
  local INTENTION="$(readintention "$@")"
  local NSTACK=$(dirs -p | wc -l)
  local PRE_INTENTION="${INTENTIONS[ (( $NSTACK - 1 )) ]}"
  INTENTIONS[(( $NSTACK - 1 ))]="$PRE_INTENTION\n$INTENTION"
}

function si {
  setintention "$@"
}

function getintentions {
  declare -a STACK
  readarray -t STACK <<<"$(dirs -p)"
  local STACKN=${#STACK[@]}
  for (( idx=0; idx<$STACKN; idx++ )); do
    echo -n ${STACK[(($idx))]}
    echo -e "${INTENTIONS[$STACKN - idx - 1]}\n"
  done

  echo "previously:"
  for (( idx=0; idx<${#INTENTIONS_DONE[@]}; idx++ )); do
    echo -e "${INTENTIONS_DONE[$idx]}\n"
  done
}

function gist {
  readarray -t STACK <<<"$(dirs -p)"
  local STACKN=${#STACK[@]}
  echo -e "${INTENTIONS[$STACKN-2]#* }"
}

function gistcommit {
  git commit -m "$(gist)" --edit
}

function gi {
  getintentions
}

function diverge {
  pushd "$1"
  setintention
}

function di {
  diverge "${@:-.}"
}

function diversiondone {
  declare -a STACK
  readarray -t STACK <<<"$(dirs -p)"
  local IDX=$((${#STACK[@]} - 1))
  INTENTIONS_DONE+=("${STACK[$IDX-1]}${INTENTIONS[$IDX]}")
  INTENTIONS[$IDX]=''
  popd
}

function dn {
  diversiondone
}
