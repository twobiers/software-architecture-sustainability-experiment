#!/usr/bin/env bash

HEADERS="Start,End,Iteration,Used Memory"
ITERATIONS=1
START_USAGE=0.1
END_USAGE=1
USAGE_STEP=0.05
SLEEP_TIME=2s
DURATION=60s
RESULTS_DIR=results/membench

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

prepare_results_directory() {
    mkdir -p "$RESULTS_DIR"
    if [ ! -f "$RESULTS_DIR/membench-log.csv" ]; then
        echo "$HEADERS" >"$RESULTS_DIR/membench-log.csv"
    fi

}

log_results() {
    echo "$START_INSTANT,$END_INSTANT,$1,$2" >>$RESULTS_DIR/membench-log.csv
}

prepare_results_directory

for i in $(seq 1 $ITERATIONS); do
    for j in $(seq $START_USAGE $USAGE_STEP $END_USAGE); do
        START_INSTANT=$(current_date)
        echo "[$(current_date)] Iteration $i"
        echo "[$(current_date)] Running at $j % of memory usage"

        sleep $SLEEP_TIME

        stress-ng --vm-bytes $(($(awk -v j=$j '/MemAvailable/{printf "%d\n", $2 *j ;}' </proc/meminfo) ))k --vm-keep -m 1 -t $DURATION

        sleep $SLEEP_TIME

        END_INSTANT=$(current_date)
        log_results "$i" "$j"
    done
done
