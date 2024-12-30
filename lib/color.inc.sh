#!/bin/bash -
#===============================================================================
#
#          FILE: color.inc.sh
#
#         USAGE: source $(msh lib color)
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 30.09.2022 04:18:55
#      REVISION:  ---
#===============================================================================

msh_colored() {
  local BG_T=49 # RESET/Transparent

  if [ ${#@} -eq 0 ]; then
    echo -ne "\e[0;${BG_T}m"
    return
  fi

  local BG_K=40 BG_R=41 BG_G=42
  local BG_Y=43 BG_B=44 BG_P=45
  local BG_C=46 BG_W=47
  local K=30 R=31 G=32
  local Y=33 B=34 P=35
  local C=36 W=37

  local FG=${1} BG=${2}
  shift 2
  local MSG="$@"

  local FG_COLOR=${FG:0:1} FG_TYPE=${FG:1:1}
  FG_COLOR=${!FG_COLOR} # `!` is dereference: use "$FG_COLOR" as a variable name

  local BG_COLOR=BG_${BG}
  BG_COLOR=${!BG_COLOR}

  if [ "$MSG" != "" ]; then
    MSG+="\e[0m"
  fi
  echo -ne "\e[${FG_TYPE};${FG_COLOR};${BG_COLOR}m${MSG}"
}

msh_colored_rgb() {
  local R="$1" G="$2" B="$3"
  shift 3
  local MSG="$@"
  if [ "$MSG" != "" ]; then
    MSG+="\e[0m"
  fi
  echo -ne "\e[38;2;$R;$G;$B;255m${MSG}"
}

msh_colored_rgba() {
  local R="$1" G="$2" B="$3" A="$4"
  shift 4
  local MSG="$@"
  if [ "$MSG" != "" ]; then
    MSG+="\e[0m"
  fi
  echo -ne "\e[38;2;$R;$G;$B;${A}m${MSG}"
}
