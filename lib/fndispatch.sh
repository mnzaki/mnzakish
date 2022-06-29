#!/bin/bash -
#===============================================================================
#
#          FILE: fndispatch.sh
#
#         USAGE: source ~/.msh/lib/fndispatch.sh
#
#   DESCRIPTION: Dispatch to functions based on the script name
#                useful for `ln -s` to a script that houses a bunch of different
#                functions, instead of a big `case in`
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki <mnzaki@gmail.com>
#  ORGANIZATION:
#       CREATED: 11.10.2021 15:10:49
#      REVISION:  ---
#===============================================================================

# if parent script is being invoked directly (not being sourced)
# then execute the function named by the parent script's file name
function msh_fndispatch() {
  # NOTE: checking against  [-1] (parent shell)
  if [ "$0" = "${BASH_SOURCE[-1]}" ]; then
    COMMAND=$(basename "$0")
    if declare -f $COMMAND &>/dev/null; then
      $COMMAND "$@"
    else
      echo "'$COMMAND' not supported"
      exit 1
    fi
  fi
}

# if the parent shell is being invoked directly (not being sourced)
# then run the supplied command line using 'exec'
# otherwise just run it normally (don't take over the process)
function msh_fndispatch_exec() {
  # NOTE: checking against  [-1] (parent shell)
  if [ "$0" = "${BASH_SOURCE[-1]}" ]; then
    exec $@
  else
    $@
  fi
}
