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


declare -g _MSH_PVAR_STORE="/tmp/$$/"
_msh_fsdb_pvar_set_store() {
  _MSH_PVAR_STORE="$1"
}

# Persistent Variables backed by files
# - `pvar STUFF $PKB/msh/stuff` to register a var
# - `STUFF+="bla"`
# - `pvar STUFF` to sync value between mem and disk
#     - from mem if not changed since `__pvar_STUFF_mtime`
#     - otherwise from disk
_msh_fsdb_pvar() {
  local VAR_NAME="$1" VAR_FILE="$2"
  local VAR_FILE_VAR_NAME="__pvar_${VAR_NAME}_file"
  local LAST_MTIME_VAR_NAME="__pvar_${VAR_NAME}_mtime"

  if [ -n "$VAR_FILE" ]; then
    # second argument specified so register $VAR_NAME with $VAR_FILE
    if [ -n "$VAR_FILE_VAR_NAME" ]; then
      # this variable was registered before, so let's clear that first
      # to avoid bugs when reusing vars in different contexts
      declare -g $LAST_MTIME_VAR_NAME=
    fi
    declare -g "$VAR_FILE_VAR_NAME"="$VAR_FILE"
  else
    VAR_FILE="${!VAR_FILE_VAR_NAME}"
  fi

  if [ ! -f "$VAR_FILE" ]; then
    # if file doesn't exist then just create it and exit
    echo "${!VAR_NAME@A}" > "$VAR_FILE"
    MTIME="$(stat -c %Y "$VAR_FILE")"
    declare -g "$LAST_MTIME_VAR_NAME"="$MTIME"
    return
  fi

  local LAST_MTIME="${!LAST_MTIME_VAR_NAME}"
  local MTIME="$(stat -c %Y "$VAR_FILE")"

  # synchronize value of var between mem and file
  if [[ -z "$LAST_MTIME" || $MTIME -gt $LAST_MTIME ]]; then
    declare -g "$LAST_MTIME_VAR_NAME"="$MTIME" 
    source <(sed 's/^declare/declare -g/' < $VAR_FILE)
  else
    echo "${!VAR_NAME@A}" > "$VAR_FILE"
  fi
}
