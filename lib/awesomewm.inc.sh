#!/bin/bash -
#===============================================================================
#
#          FILE: awesomewm.inc.sh
#
#         USAGE: ./awesomewm.inc.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 04.02.2023 21:49:48
#      REVISION:  ---
#===============================================================================

# for debugging in awesome-client
# awful=require('awful'); naughty=require('naughty')
# function lt(t) local s=""; for k,v in pairs(t) do s = s .. k .. " " end return s end
# return lt(awful.tag.history)

_msh_gen_bindings() {
  local TARGET="$1" NUMARGS=${2:-0} CODE="$3"
  local FNARGS= CURARG=1

  while [ $CURARG -le $NUMARGS ]; do
    FNARGS+="'\$"$CURARG"'"
    [ $CURARG -ne $NUMARGS ] && FNARGS+=", "
    let CURARG=(CURARG+1)
  done

  CODE="${CODE//FNARGS/$FNARGS}"

  eval "_msh_$TARGET() { $CODE; }"
}

_msh_awesomewm_bind() {
  _msh_gen_bindings wm_$1 ${2:-0} "awesome-client \"require('extra').workspace_groups.$1(FNARGS)\""
}

_msh_awesomewm_bind get_current_group_idx
_msh_awesomewm_bind get_free_group_idx
_msh_awesomewm_bind get_current_group_purpose

_msh_awesomewm_bind view_group_by_purpose 1
_msh_awesomewm_bind set_current_group_purpose 1
