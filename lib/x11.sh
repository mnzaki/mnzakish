#!/bin/bash -
#===============================================================================
#
#          FILE: x11.sh
#
#         USAGE: ./x11.sh
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
source "$_msh_base/lib/fndispatch.sh"

# Focus an x11 window owned by a process with the given command line
# or execute the command line if no such window
focus_or_exec() {
  if [ "$1" = "" ]; then
    return 1
  fi
  if ! focus_window_cmd "$@"; then
    $@
  fi
}

# Focus an x11 window owned by a process with the given command line
focus_window_cmd() {
  local cmd="$@"
  if [ "$cmd" = "" ]; then
    return 1
  fi

  local ps_path=$(which ps) # avoid aliases
  local pids="$($ps_path -eo pid,cmd | grep -F "$cmd" | grep -v grep | cut -d" " -f 2)"
  if [ "$pids" = "" ]; then
    return 1
  else
    focus_window_pids $pids
    return 0
  fi
}

# Focus x11 windows owned by a process with the given PIDs
focus_window_pids() {
  if [ "$@" = "" ]; then
    return 1
  fi
  local pid wid windowids
  for pid in "$@"; do
    windowids=($(xdotool search --pid $pid))
    if [ "$windowids" = "" ]; then
      break
    fi

    for wid in "${windowids[@]}"; do
      xdotool set_window --urgency 1 $wid
    done
  done
  return 0
}
