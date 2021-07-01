#!/bin/bash
#===============================================================================
#
#          FILE: diversion.sh
#
#         USAGE: ./diversion.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 24.06.2021 23:13:05
#      REVISION:  ---
#===============================================================================

if [ "$0" != "$BASH_SOURCE" ]; then
  echo "You are trying to source diversion"
  echo "Diversion must be directly invoked"
  exit 1
fi

set -o nounset                                  # Treat unset variables as an error
BASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )"

source $BASE/intention.sh
echo DIVERSION_NOTES=
DIVERSION_NOTES="$(readintention)"
bash --rcfile <(
  echo 'cd "'$1'"'
  cat ~/.bashrc
  prepare_next_intention "$DIVERSION_NOTES"
) -i
echo -e "$DIVERSION_NOTES\n"
echo -e "== INTENTION_STACK ==\n\n$(getintentions)\n"
