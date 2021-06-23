CCCCount=0
MAX_CCCs=8
function concentration {
  EXIT_CODE=${1:-$?}
  if [ $EXIT_CODE -eq 130 ]; then # it was a Control-C
    # so increment the CCCCount
    echo concentrate
    (( CCCCount++ ))
    # and check
    if [ $CCCCount -ge $MAX_CCCs ]; then
      AND_AGAIN_AND_AGAIN=$((CCCCount/MAX_CCCs))

      if [ $AND_AGAIN_AND_AGAIN -ge 13 ]; then
        AND_PRINT_CAL='cal'
      fi

      while [ $AND_AGAIN_AND_AGAIN -ge 2 ]; do
        if [ $AND_AGAIN_AND_AGAIN -ge 3 ]; then
          echo ConCENtraTe
          if [ $AND_AGAIN_AND_AGAIN -ge 5 ]; then
            echo CONcenTRATE
            if [ $AND_AGAIN_AND_AGAIN -ge 8 ]; then
              echo CONCENTRATE
              if [ $AND_AGAIN_AND_AGAIN -ge 10 ]; then
                echo CoNcEnTrAtE
                if [ $AND_AGAIN_AND_AGAIN -ge 13 ]; then
                  echo cOnCeNtRaTe
                  (( CCCCount = CCCCount - 11*MAX_CCCs ))
                  #concentration $EXIT_CODE
                fi
              fi
            fi
          fi
        fi
        (( AND_AGAIN_AND_AGAIN-- ))
      done
      $AND_PRINT_CAL
    fi
  else
    CCCCount=0
    AND_PRINT_CAL=
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
