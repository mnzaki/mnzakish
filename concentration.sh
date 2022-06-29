#!/bin/bash
#===============================================================================
#
#          FILE: concentration.sh
#
#         USAGE: source ./concentration.sh
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

if [ "$0" = "$BASH_SOURCE" ]; then
  echo "You are trying to directly invoke concentration."
  echo "Concentration must be sourced."
  exit 1
fi

#set -o nounset                                  # Treat unset variables as an error

BASE="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" &> /dev/null && pwd )"
source "$BASE/intention.sh"

CONCENTRATION_MANTRA=(
  conCENTRATE
  ConcENTRATE
  COncenTRATE
  CONCEntraTE
  CONCENtratE
  CONCENTrate
  CONCENtratE
  CONCEntrATE
  CONcenTRAtE
  ConcENTRATE
  conCENTRATE
)

CONCENTRATION_MANTRA=(
  kkkKAAASSSS
  SssseEEEFFF
  KKkkaaaASSS
  SSSseeffFFF
  CONCEntratE
  CONCENTrate
  CONCENtratE
  CONCEntrATE
  CONcentRATE
  KKkkaaaASSS
  SssseEEEFFF
)

function concentration_grounds {
  #echo -e "-----------\n$DIVERSION_NOTES\n-----------"
  date
  cal
}

CCCCount=0
MAX_CCCs=50
CCCCount_direction=1
CONC_IDX_OFFSET=0
AND_GROUNDS=

function concentration {
  local EXIT_CODE=${1:-$?}

  if [ $EXIT_CODE -eq 130 ]; then # it was a Control-C
    # so increment the CCCCount
    (( CCCCount = CCCCount + CCCCount_direction ))
    # and check
    if [ $CCCCount -ge $MAX_CCCs ]; then
      AND_GROUNDS=1
      CCCCount_direction=-1
      (( CCCCount-- ))
    elif [ $CCCCount -le 0 ]; then
      CCCCount_direction=1
      (( CCCCount++ ))
    fi

    local NUM_MANTRAS=${#CONCENTRATION_MANTRA[@]}
    local CONCENTRATION_TIMES=1
    if [ $CCCCount_direction -eq -1 ]; then
      (( CONC_IDX_OFFSET = (CONC_IDX_OFFSET+2) % NUM_MANTRAS ))
    else
      (( CONC_IDX_OFFSET = (CONC_IDX_OFFSET+1) % NUM_MANTRAS ))
    fi

    if [ $CONCENTRATION_TIMES -lt $CCCCount ]; then
      ((CONCENTRATION_TIMES++))
      paste -d ' ' <(
        echo concentrate
        while [ $CONCENTRATION_TIMES -lt $CCCCount ]; do
          local CONC_IDX=$(( (CONCENTRATION_TIMES+CONC_IDX_OFFSET) % NUM_MANTRAS))
          echo ${CONCENTRATION_MANTRA[$CONC_IDX]}
          (( CONCENTRATION_TIMES++ ))
        done
      ) <(getintentions | head -n $((CCCCount-1)) )
      if [ "$AND_GROUNDS" != "" ]; then
        concentration_grounds
      fi
      ((CONC_IDX_OFFSET++))
    fi
  else
    CCCCount=0
    AND_GROUNDS=
  fi
}

PROMPT_COMMAND=${PROMPT_COMMAND:-}
case "$PROMPT_COMMAND" in
  *concentration*)
    # Do stuff #
    ;;
  *)# or else  #
    PROMPT_COMMAND="concentration;$PROMPT_COMMAND"
    ;;
esac
