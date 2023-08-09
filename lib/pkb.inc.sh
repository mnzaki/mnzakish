#!/bin/bash -
#===============================================================================
#
#          FILE: pkb.sh
#
#         USAGE: ./pkb.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 08.07.2022 15:17:43
#      REVISION:  ---
#===============================================================================

PKB="${PKB:-$HOME/pkb}"
VIDEOS="$(xdg-user-dir VIDEOS || echo "$HOME/Videos")"
MUSIC="$(xdg-user-dir MUSIC || echo "$HOME/Music")"
RECORDINGS="$(xdg-user-dir RECORDINGS || echo "$HOME/recordings")"
ME="$PKB/me"

# Check that `now` exists
#pushd $ME
#echo there
#NOW=$(date +%Y)
#if ! ls -l now | grep -q $NOW; then
#  # and link it if it doesn't
#  mkdir -p "$NOW"
#  ln -srf $NOW now
#fi
#popd
