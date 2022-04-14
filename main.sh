#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------
# HARD-CODED PARAMETERS
CONCURRENT_MAX=3  # maximum number of scripts to run in parallel
RUN_WAIT_TIME=1 # time to wait in-between consecutive runs, set to at least 1 (seconds)
CHECK_WAIT_TIME=10  # time to wait in-between checks of active processes (seconds)
# OPTIONS
total=${1:-5}  # total number of scripts to run is passes as the first argument, defaults to 5
# ----------------------------------------------------------------------------------------------------------------------

# a log directory is created in the "logs" folder with the current date, all logs will stored there
LOGSDIR="./logs/logs_`date +"%Y-%m-%d"`"
mkdir -p "$LOGSDIR" # the -p option will create the nested structure

counter=1 # the counter for the while loop
while [ $counter -le $total ]
do
  # create an empty list, this will store the PID of active processes
  active_list=()
  active_n=0  # number of currently active processes
  remaining=$((total-counter+1))  # remaining number of processes to launch from the total
  # if the number of the remaining processes to launch is lower than then the maximum number of processes to launch,
  # then set $CONCURRENT_MAX to $remaining
  # this stops the following loop from launching extra processes when $total is not a multiple of $CONCURRENT_MAX
  # i.e. when modulus($total, $CONCURRENT_MAX)!=0
  if [ $remaining -lt $CONCURRENT_MAX ]
  then
    CONCURRENT_MAX=$remaining
  fi

  # launch scripts
  while [ $active_n -lt $CONCURRENT_MAX ]
  do
    TIMESTAMP=`date +"%Y-%m-%d_%H-%M-%S"`
    LOGFILE="$LOGSDIR/$TIMESTAMP.txt"
    # run the program with selected options in background ("&")
    # program stdout is redirected to $LOGFILE

    # ------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------
    # YOUR SCRIPT AND ITS OPTIONS HERE!
    time_to_sleep=$((10+counter)) # the option to pass to the script is variable, can be anything else
    python script_example.py -t $time_to_sleep \
      > $LOGFILE &
    # ------------------------------------------------------------------------------------------------------------------
    # ------------------------------------------------------------------------------------------------------------------

    # add PID of command that just launched to list
    pid="$!"
    active_list+=("$pid")
    echo "init > [$pid] @ $LOGFILE | counter:$counter "
    # increase counters
    ((counter++))
    ((active_n++))
    # sleep at least 1 sec to avoid creating same timestamp
    sleep $RUN_WAIT_TIME
  done

  # check whether active processes have terminated
  exst=true
  while [ $exst = true ]
  do
    exst=false
    ct=0
    for kpid in "${active_list[@]}"
    do
      if [ -d "/proc/${kpid}" ]
      then
        exst=true
        ((ct++))
        echo -n "[$kpid] O | "  # display 0 if process is still active
      else
        echo -n "[$kpid] X | "  # display 1 if process is not active
      fi
    done
    echo "$ct/$CONCURRENT_MAX running"
    # wait 10 seconds before checking again the active processes
    sleep $CHECK_WAIT_TIME
  done

  dn=$((counter-1))
  echo "$dn/$total done"
done

echo "All done!!"
