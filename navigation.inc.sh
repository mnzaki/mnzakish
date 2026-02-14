#!/bin/bash -
#===============================================================================
#
#          FILE: navigation.inc.sh
#
#         USAGE: source ./navigation.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: Nicolas Jar - Space is Only Noise - Too many kids finding rain in the dust
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 01.08.2022 21:39:06
#      REVISION:  ---
#===============================================================================

NAVIGATION_LOOKAHEAD_DEPTH=7
DIR_LIST_CMD="fd -t d -d $NAVIGATION_LOOKAHEAD_DEPTH"
PATH_LIST_CMD="fd -t f -t l -d $NAVIGATION_LOOKAHEAD_DEPTH"

# fzf completion
if ! type __fzf_defc > /dev/null; then
  if [ -e /usr/share/fzf/completion.bash ]; then
    echo sourcing
    source /usr/share/fzf/completion.bash
  fi
fi

if type __fzf_defc > /dev/null; then
  # and this adds more of that support for some of my custom commands
  more_fzf_cmds="mpv mpvlowlat menow herenow zathura"
  for cmd in $more_fzf_cmds; do
    __fzf_defc "$cmd" _fzf_path_completion "-o default -o bashdefault"
    :
  done
fi

[ -e "$MSH_CACHE/j_hist" ] || touch "$MSH_CACHE/j_hist"
# super sayan jump to directory
function j() {
  local FZF_HIST="$MSH_CACHE/j_hist"
  local BASE="${1:-.}"
  local JUMP_TO="$($DIR_LIST_CMD . "$BASE" | fzf --history="$FZF_HIST")"
  if [[ "$JUMP_TO" != "" ]]; then
    pushd "$JUMP_TO"
    echo -b $JUMP_TO | xsel -b
  fi
}

[ -e "$MSH_CACHE/jf_hist" ] || touch "$MSH_CACHE/jf_hist"
# jump to file and run CMD
function jf() {
  local FZF_HIST="$MSH_CACHE/jf_hist"
  local TARGET_CMD
  local X11_MODIFIER

  local OPTIND=1
  while getopts ":ex" opt
  do
    case $opt in
      e) TARGET_CMD=$EDITOR;;
      x) X11_MODIFIER=1;;
    esac
  done

  shift $((OPTIND-1))

  if [ $# -gt 0 ]; then
    TARGET_CMD="$@"
  fi

  TARGET_CMD="${TARGET_CMD:-"xdg-open"}"

  local JUMP_TO="$($PATH_LIST_CMD . | fzf --history="$FZF_HIST")"
  if [[ "$JUMP_TO" != "" ]]; then
    xsel -b <<<$JUMP_TO
    echo "$JUMP_TO"
    if [ -n "$X11_MODIFIER" -a -n "$DISPLAY" ]; then
      xdotool type "$TARGET_CMD ${JUMP_TO@Q}"
      xdotool key Enter
    else
      $TARGET_CMD "$JUMP_TO"
    fi
  fi
}
