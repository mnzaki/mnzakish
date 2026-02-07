#!/bin/bash -
#===============================================================================
#
#          FILE: taskwiz.sh
#
#         USAGE: ./taskwiz.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: xmessage jq
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 04.08.2022 22:43:15
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error


# TODO move to lib file
function xok {
  xmessage -default okay $@
}
function xyesno {
  xmessage -default yes -buttons yes:0,no:1 $@
}

TASK_NAME="$(dmenu -p "add task")"
# TODO context control
# set current project/tag
TASK_ADD_RES="$(task add "$TASK_NAME")"
if [ ! $? -eq 0 ]; then
  xok "couldn't add task: $TASK_ADD_RES"
  exit 1
fi

TASK_ID="$(echo "$TASK_ADD_RES" | grep -i created |
  sed 's/[^0-9]*\([0-9]*\)[^0-9]*/\1/' # capture the task id
)"

xok "add annotations"

# TODO add annotations to an array
#  display them in the xmessage
#  extract links and `keep` them

function taskwiz_annotate() {
}

function taskwiz_set_project() {
}

function taskwiz_set_tags() {
  

task $TASK_ID annotate
