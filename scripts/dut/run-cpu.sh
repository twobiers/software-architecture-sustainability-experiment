#!/usr/bin/env bash

HEADERS="Start,End,Iteration,CPUs"
ITERATIONS=1
START_CPU=1
END_CPU=$(grep -c processor /proc/cpuinfo)
CPU_STEP=1
SLEEP_TIME=2s
DURATION=60s
RESULTS_DIR=results/cpubench

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

prepare_results_directory() {
    mkdir -p "$RESULTS_DIR"
    if [ ! -f "$RESULTS_DIR/cpubench-log.csv" ]; then
        echo "$HEADERS" >"$RESULTS_DIR/cpubench-log.csv"
    fi

}

log_results() {
    echo "$START_INSTANT,$END_INSTANT,$1,$2" >>$RESULTS_DIR/cpubench-log.csv
}

prepare_results_directory

for i in $(seq 1 $ITERATIONS); do
    for j in $(seq $START_CPU $END_CPU $CPU_STEP); do
        START_INSTANT=$(current_date)
        echo "[$(current_date)] Iteration $i"
        echo "[$(current_date)] Running at $j CPUs"

        sleep $SLEEP_TIME

        stress-ng --cpu $j -t $DURATION
        # stress-ng --cpu $j --cpu-load 100 --cpu-method matrixprod -t $DURATION

        sleep $SLEEP_TIME

        END_INSTANT=$(current_date)
        log_results "$i" "$j"
    done
done
