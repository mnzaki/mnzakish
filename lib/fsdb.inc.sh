#!/bin/bash -
#===============================================================================
#
#          FILE: fsdb.inc.sh
#
#         USAGE: source ./fsdb.inc.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ed
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 24.12.2022 20:01:38
#      REVISION:  ---
#===============================================================================

# List-In-File: LIF

_msh_fsdb_LIF_push() {
  echo "$2" >> "$1"
}
_msh_fsdb_LIF_push_unique() {
  local LN LINE_NUMS=($(grep -n "$2" "$1" | cut -d: -f1))
  local ED_CMD
  for LN in $LINE_NUMS; do
    ED_CMD+="${LN}d\n"
  done

  ED_CMD+='$a\n'"${2@Q}"
  echo -e "$ED_CMD\n.\nw" | ed -s "$1"
}

_msh_fsdb_LIF_shift() {
  local ED_CMD='0a\n'"$2"
  echo -e "$ED_CMD\n.\nw" | ed -s "$1"
}

_msh_fsdb_LIF_shift_unique() {
  local LN LINE_NUMS=($(grep -n "$2" "$1" | cut -d: -f1))
  local ED_CMD
  for LN in ${LINE_NUMS:-}; do
    ED_CMD+="${LN}d\n"
  done

  ED_CMD+='0a\n'"$2"
  echo -e "$ED_CMD\n.\nw" | ed -s "$1"
}

_msh_fsdb_LIF_get() {
  local ED_CMD
  let ED_CMD=( $2+1 )
  ED_CMD+=p
  echo -e "$ED_CMD" | ed -s "$1"
}

_msh_fsdb_LIF_set() {
  local ED_CMD
  let ED_CMD=( $2+1 )
  ED_CMD+="c\n$3"
  echo -e "$ED_CMD\n.\nw" | ed -s "$1"
}

# Persistent VARiables backed by files
# - `pvar STUFF $PKB/msh/stuff.inc.sh` to register a var and load from disk
# - `STUFF+="bla"`
# - `pvar STUFF` to write value to disk
# - `pvar STUFF =` to re-read value from disk
_msh_fsdb_pvar() {
  local VAR_NAME="$1" VAR_FILE="$2"
  local VAR_FILE_VAR_NAME="__pvar_${VAR_NAME}_file"

  if [ "$VAR_FILE" = '=' ]; then
    VAR_FILE="${!VAR_FILE_VAR_NAME}"
  fi

  if [ -z "$VAR_FILE" ]; then
    # second argument not specified so write to disk
    VAR_FILE="${!VAR_FILE_VAR_NAME}"
    [ -z "$VAR_FILE" ] && return 1
    local VAL_DEC="$(declare -p "$VAR_NAME")"
    echo ${VAL_DEC/declare/declare -g} > "$VAR_FILE"
  else
    # second argument specified so register $VAR_NAME with $VAR_FILE
    # read from disk
    declare -g "$VAR_FILE_VAR_NAME"="$VAR_FILE"
    source "$VAR_FILE"
  fi
}
