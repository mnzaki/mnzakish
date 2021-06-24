CONCENTRATION_MANTRA=(
  conCENTRATE
  ConcENTRATE
  CONcenTRAtE
  CONCEntrATE
  CONCENtratE
  CONCENTrate
  CONCENtratE
  CONCEntrATE
  CONcenTRAtE
  ConcENTRATE
)
function concentration_grounds {
  date
  cal
}

CCCCount=0
MAX_CCCs=50
CCCCount_direction=1

function concentration {
  EXIT_CODE=${1:-$?}
  if [ $EXIT_CODE -eq 130 ]; then # it was a Control-C
    # so increment the CCCCount
    echo concentrate
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

    NUM_MANTRAS=${#CONCENTRATION_MANTRA[@]}
    CONCENTRATE_TIMES=1
    if [ $CCCCount_direction -eq -1 ]; then
      (( CONC_IDX_OFFSET = (CONC_IDX_OFFSET+2) % NUM_MANTRAS ))
    else
      CONC_IDX_OFFSET=0
    fi
    while [ $CONCENTRATE_TIMES -lt $CCCCount ]; do
      CONC_IDX=$(( (CONCENTRATE_TIMES+CONC_IDX_OFFSET) % NUM_MANTRAS))
      echo ${CONCENTRATION_MANTRA[$CONC_IDX]}
      (( CONCENTRATE_TIMES++ ))
    done
    if [ "$AND_GROUNDS" != "" ]; then
      concentration_grounds
    fi
  else
    CCCCount=0
    AND_GROUNDS=
  fi
}

case "$PROMPT_COMMAND" in
  *concentration*)
    # Do stuff #
    ;;
  *)# or else  #
    PROMPT_COMMAND="concentration;$PROMPT_COMMAND"
    ;;
esac
