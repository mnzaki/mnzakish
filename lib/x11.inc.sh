#!/bin/bash -
#===============================================================================
#
#          FILE: x11.inc.sh
#
#         USAGE: source `msh lib x11`
#
#   DESCRIPTION: X11 helpers / utilities
#
#       OPTIONS: ---
#  REQUIREMENTS: xdotool
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki <mnzaki@gmail.com>
#  ORGANIZATION:
#       CREATED: 13.10.2021 10:10:34
#      REVISION:  ---
#===============================================================================

_msh_base="$(dirname "${BASH_SOURCE[0]}")/.."
source "$_msh_base/lib/fndispatch.inc.sh"

# Focus an x11 window owned by a process with the given command line
# or execute the command line if no such window
function _msh_focus_or_exec() {
  #debug echo _msh_focus_or_exec "$@"
  if [ -z "$1" ]; then
    return 1
  fi
  if ! _msh_focus_window_cmd "$@"; then
    $@
  fi
}

# Focus an x11 window owned by a process with the given command line
function _msh_focus_window_cmd() {
  #debug echo _msh_focus_window_cmd "$@"
  local cmd="$@"
  if [ -z "$cmd" ]; then
    return 1
  fi

  #debug echo look for $cmd
  local pids="$(command pgrep -f "$cmd")"
  if [ -z "$pids" ]; then
    return 1
  else
    _msh_focus_window_pids $pids
    return 0
  fi
}

# Focus x11 windows owned by a process with the given PIDs
function _msh_focus_window_pids() {
  #debug _msh_focus_window_pids
  if [ ${#@} -eq 0 ]; then
    return 1
  fi
  local pid wid windowids
  for pid in "$@"; do
    windowids=($(xdotool search --pid $pid))

    for wid in "${windowids[@]}"; do
      xdotool set_window --urgency 1 $wid
      xdotool windowactivate $wid
    done
  done
  return 0
}
