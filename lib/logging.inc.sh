#!/bin/bash -
#===============================================================================
#
#          FILE: logging.inc.sh
#
#         USAGE: ./logging.inc.sh
#
#   DESCRIPTION: simple and effective logging
#                coutesy of https://gist.github.com/hilbix/1ec361d00a8178ae8ea0
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Mina Nagy Zaki (mnzaki), mnzaki@gmail.com
#  ORGANIZATION: mnzaki.com
#       CREATED: 07.12.2022 18:46:30
#      REVISION:  ---
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

OOPS()
{
echo "OOPS: $*" >&2
exit 1
}

NOTE()
{
echo "NOTE: $*" >&2
}
