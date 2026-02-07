#!/bin/bash
#===============================================================================
#
#          FILE: intention.inc.sh
#
#         USAGE: source ./intention.inc.sh
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

`msh src lib/pkb`
`msh src lib/activity`

if [ "$0" = "$BASH_SOURCE" ]; then
  echo "You are trying to directly invoke intention."
  echo "Intention must be sourced."
  exit 1
fi

# TODO intention stack stored in FILE
#      per tmux session if $TMUX
#      reload from disk if changed since last load
#      reload from disk before applying any changed
#      write to disk on change
#      load from disk on source-ing

STACK_CHAR="${STACK_CHAR:-|}"
# NOTE: INTENTIONS are listed in chronological order
declare -A INTENTIONS
INTENTIONS_DONE=("${INTENTIONS_DONE[@]}")

# TODO make it colorful and zsh compatible
#PS1_ADDITION='\[[38;5;7m[38;1;7m\]$(printdirstack)'
PS1_ADDTION='$(printdirstack)'
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
  local NSTACK=$(($(dirs -p | wc -l)))
  local PRE_INTENTION="${INTENTIONS[$((NSTACK-1))]}"
  INTENTIONS[$((NSTACK-1))]="$PRE_INTENTION\n$INTENTION"
}

function si {
  setintention "$@"
}

function si {
  setintention "$@"
}

function getintentions {
  echo "done:"
  for (( idx=0; idx<${#INTENTIONS_DONE[@]}; idx++ )); do
    echo -e "${INTENTIONS_DONE[$idx]}\n"
  done

  echo -e "\nnow:"
  declare -a STACK
  # STACK is in reverse chrono order
  readarray -t STACK <<<"$(dirs -p)"
  local NSTACK=${#STACK[@]}
  for (( idx=$NSTACK; idx>0; idx-- )); do
    local ENTRY="${STACK[$idx-1]}\n${INTENTIONS[$(($NSTACK-$idx))]}"
    echo -e "$ENTRY\n"
  done
}

function gist {
  declare -a STACK
  readarray -t STACK <<<"$(dirs -p)"
  local IDX=$((${#STACK[@]}-1))
  echo -e "${INTENTIONS[$IDX]#* }"
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
  INTENTIONS_DONE+=("${STACK[0]}${INTENTIONS[$IDX]}")
  unset INTENTIONS[$IDX]
  popd
}

function dn {
  diversiondone
}
