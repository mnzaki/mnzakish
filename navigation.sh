#!/bin/bash -
#===============================================================================
#
#          FILE: navigation.sh
#
#         USAGE: ./navigation.sh
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

#set -o nounset                                  # Treat unset variables as an error

NAVIGATION_LOOKAHEAD_DEPTH=7
DIR_LIST_CMD="fd -t d -d $NAVIGATION_LOOKAHEAD_DEPTH"
PATH_LIST_CMD="fd -t f -t l -d $NAVIGATION_LOOKAHEAD_DEPTH"

# fzf completion
source /usr/share/fzf/completion.bash
# fzf is a fuzzy finder, with completion for bash on **<TAB>
_fzf_compgen_path() {
  echo "$1"
  command $PATH_LIST_CMD "$1"
}
_fzf_compgen_dir() {
  echo "$1"
  command $DIR_LIST_CMD "$1"
}

# and this adds more of that support for some of my custom commands
more_fzf_cmds="mpv mpvlowlat menow herenow zathura"
for cmd in $more_fzf_cmds; do
  __fzf_defc "$cmd" _fzf_path_completion "-o default -o bashdefault"
done

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
  local TARGET_CMD="${@-"xdg-open"}"
  #if [[ "$TARGET_CMD" == "" ]]; then
    #echo "Usage: jf CMD"
    #echo "fuzzy find a file and run CMD on it"
  #fi
  set -x
  local JUMP_TO="$($PATH_LIST_CMD . | fzf --history="$FZF_HIST")"
  set +x
  if [[ "$JUMP_TO" != "" ]]; then
    set -x
    $TARGET_CMD "$JUMP_TO"
    set +x
  fi
  echo -b $JUMP_TO | xsel -b
}
