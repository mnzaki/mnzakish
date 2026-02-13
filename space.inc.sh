#!/bin/bash -
#===============================================================================
#
#          FILE: spacetime.sh
#
#         USAGE: ./spacetime.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki <mnzaki@gmail.com>
#  ORGANIZATION:
#       CREATED: 01.07.2021 23:47:11
#      REVISION:  ---
#===============================================================================

#set -o nounset                                  # Treat unset variables as an error

#cs change space
#ct change time
#tl timelog
#sl spacelog

# super sayan jump to directory
function j() {
  BASE=${1:-.}
  JUMP_TO="$(fd -t d -d 4 . "$BASE" | fzf)"
  if [[ "$JUMP_TO" != "" ]]; then
    pushd "$JUMP_TO"
  fi
}

# jump to file and run CMD
function jf() {
  TARGET_CMD=${@-"xdg-open"}
  #if [[ "$TARGET_CMD" == "" ]]; then
    #echo "Usage: jf CMD"
    #echo "fuzzy find a file and run CMD on it"
  #fi
  set -x
  JUMP_TO="$(fd -t f -t l -d 5 . | fzf)"
  set +x
  if [[ "$JUMP_TO" != "" ]]; then
    set -x
    $TARGET_CMD "$JUMP_TO"
    set +x
  fi
  echo -b $JUMP_TO | xsel -b
}

function t() {
  SESSION_NAME=${1:-$(basename `pwd`)}
  tmux attach -t "$SESSION_NAME" ||
  tmux new-session -s "$SESSION_NAME"
}
