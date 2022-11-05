#!/bin/bash -
#===============================================================================
#
#          FILE: init.sh
#
#         USAGE: ./init.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 08.07.2022 17:02:34
#      REVISION:  ---
#===============================================================================

#set -o nounset                                  # Treat unset variables as an error

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null && pwd )"
export MSH_DIR=${MSH_DIR:-$MY_DIR}
export MSH_HOME=${MSH_HOME:-"$HOME/.msh"}
export MSH_CACHE=${MSH_HOME:-"$HOME/.cache/mnzakish"}

# make $MSH_HOME and $MSH_HOME/bin if it doesn't exist
mkdir -p "$MSH_HOME/bin"
mkdir -p "$MSH_CACHE"

# copy the default configuration if it doesn't exist
# TODO invoke an interactive prompt to do this
if [ ! -f "$MSH_HOME/conf.sh" ]; then
  cp "$MSH_DIR/conf.sh" "$MSH_HOME/conf.sh"
fi
