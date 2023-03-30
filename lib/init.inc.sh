#!/bin/bash -
#===============================================================================
#
#          FILE: init.sh
#
#         USAGE: source `msh lib init`
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
export MSH_CONFIG=${MSH_CONFIG:-"$HOME/.config/msh"}
export MSH_CACHE=${MSH_CACHE:-"$HOME/.cache/msh"}
export MSH_LOCAL=${MSH_LOCAL:-"$HOME/.local/share/msh"}

source "$MSH_DIR/lib/util.inc.sh"

# ensure dirs exist
mkdir -p "$MSH_CONFIG" "$MSH_CACHE" "$MSH_LOCAL"

# copy the default configuration if it doesn't exist
# TODO invoke an interactive prompt to do this
if [ ! -f "$MSH_CONFIG/conf.inc.sh" ]; then
  cp "$MSH_DIR/conf.inc.sh" "$MSH_CONFIG/conf.inc.sh"
fi
