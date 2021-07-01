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
BASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )"

PRE_INTENTION="${PRE_INTENTION:-}"
INTENTION="${INTENTION:-}"
INTENTION_STACK="${INTENTION_STACK:-}"

#mkdir -p $BASE/intentions
#FILE_INTENTION=$(date -Ihours)
#if [ -e "$FILE_INTENTION" ]; then
#  INTENTION="$(cat "$FILE_INTENTION")"
#fi
#

function setintention {
#  echo "$INTENTION" >> "$FILE_INTENTION"
  INTENTION="$(readintention "$@")"
  export INTENTION
  env - INTENTION="$INTENTION" &> /dev/null
}

function intend {
  setintention $@
}

function si {
  setintention $@
}

function appendintention {
  PRE_INTENTION="$INTENTION"
  setintention "$@"
  setintention "$PRE_INTENTION\n$INTENTION"
}

function ai {
  appendintention $@
}

function getintentions {
  echo -e "$PRE_INTENTION$INTENTION"
}

function gist {
  getintentions
}

function gi {
  getintentions
}

function diverge {
  "$BASE/diversion.sh" "$@"
}

function di {
  diverge "$@"
}

function setpreintention {
  PRE_INTENTION="$@\n\n=====================\n\n"
}

function incintentionstack {
  INTENTION_STACK="|$1"
  PS1="$INTENTION_STACK$PS1"
}

function readintention {
  echo "${@:-$(cat -)}"
}

function prepare_next_intention {
  echo 'source "'"$BASE/intention.sh"'"'
  echo 'setpreintention "'"$INTENTION"'"'
  echo 'incintentionstack "'"$INTENTION_STACK"'"'
  echo 'setintention "'"$@"'"'
}
