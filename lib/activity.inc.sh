#!/bin/bash -
#===============================================================================
#
#          FILE: activity.inc.sh
#
#         USAGE: `msh src lib/activity`
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 09.02.2023 15:19:55
#      REVISION:  ---
#===============================================================================

ACTIVITIES_DIR="$PKB/activity"
CACHE_DIR="$MSH_CACHE/activity"
ACTIVITY_SLUG=
ACTIVITY_DIR=
ACTIVITY_CACHE_DIR=
ACTIVITY=
ACTIVITIES=

#TERMINAL_CMD="${TERMINAL:-xterm} -g 120x20 -c fzfmenu -z 18"

mkdir -p "$ACTIVITIES_DIR" "$CACHE_DIR"

_msh_activity__ls() {
  ACTIVITIES=($(command ls -1t "$ACTIVITIES_DIR"))
}
_msh_activity__ls
_msh_activity_ls() {
  _msh_activity__ls
  echo "${ACTIVITIES[*]}"
}


_msh_activity__vars() {
  ACTIVITY_SLUG=${ACTIVITY// /-}
  ACTIVITY_DIR="$ACTIVITIES_DIR/$ACTIVITY"
  ACTIVITY_CACHE_DIR="$CACHE_DIR/$ACTIVITY"
  #_msh_fsdb_pvar ACTIVITY_WM_IDX "$ACTIVITY_DIR/wm_idx"
}

_msh_activity__set() {
  ACTIVITY="${1}"
  _msh_activity__vars

  [ ! -d "$ACTIVITY_CACHE_DIR" ] && mkdir -p "$ACTIVITY_CACHE_DIR"

  # ensure activity dir exists and is initialized
  if [ -d "$ACTIVITY_DIR" ]; then
    # activity pre-exists, update modification time
    touch -c "$ACTIVITY_DIR"
  else
    # activity is new, initialize it
    mkdir -p "$ACTIVITY_DIR/notes"
    echo "# ${ACTIVITY}" > "$ACTIVITY_DIR/capture.md"
  fi


  #  -f --force
  #  -s --symbolic
  #  -r --relative
  #  -n --no-dereference
  #ln -fsrn "$ACTIVITY_DIR" "$CUR_ACTIVITY_LINK"

  # When activity is newly started, capture:
  # - what programs are run from dmenu-recent
  # - what taskwarrior context is changed to
  # - taskwarrior:
  # - context
    # - tasks started

  # if activity old, replay captured
  ##
}

