#!/bin/bash -
#===============================================================================
#
#          FILE: time.sh
#
#         USAGE: ./time.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 01/12/2026 06:25:58 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

PLAYER=${PLAYER:-mpv}

function mpvsept() {
  local SEP="$1"
  shift
  local SEQ="$@"
  for ITEM in "$SEQ"; do
    echo "$SEQ" "$SEP"
  done | xargs $PLAYER
}
