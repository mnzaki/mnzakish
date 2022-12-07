#!/bin/bash -
#===============================================================================
#
#          FILE: util.sh
#
#         USAGE: ./util.sh
#
#   DESCRIPTION: Calculate relative path from A to B, returns true on success
#                Example: ln -s "$(relpath "$A" "$B")" "$B"
#                courtesy of https://gist.github.com/hilbix/1ec361d00a8178ae8ea0
#       OPTIONS: pathA pathB
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 08.09.2022 00:47:00
#      REVISION:  ---
#===============================================================================

relpath() {
  local X Y A
  # We can create dangling softlinks
  X="$(readlink -m -- "$1")" || return
  Y="$(readlink -m -- "$2")" || return
  X="${X%/}/"
  A=""
  # See http://stackoverflow.com/questions/2564634/bash-convert-absolute-path-into-relative-path-given-a-current-directory
  while   Y="${Y%/*}"
          [ ".${X#"$Y"/}" = ".$X" ]
  do
          A="../$A"
  done
  X="$A${X#"$Y"/}"
  X="${X%/}"
  echo "${X:-.}"
}
