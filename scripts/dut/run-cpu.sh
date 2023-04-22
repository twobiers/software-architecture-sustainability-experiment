#!/usr/bin/env bash

HEADERS="Start,End,Iteration,CPU Cores,CPU Load"
ITERATIONS=1
START_CPU=10
END_CPU=100
CPU_STEP=10
CPU_STRESSORS=$(grep -c processor /proc/cpuinfo)
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
    echo "$START_INSTANT,$END_INSTANT,$1,$2,$3" >>$RESULTS_DIR/cpubench-log.csv
}

prepare_results_directory

for i in $(seq 1 $ITERATIONS); do
    for j in $(seq $CPU_STRESSORS $CPU_STRESSORS); do
        for k in $(seq $START_CPU $CPU_STEP $END_CPU); do
            START_INSTANT=$(current_date)
            echo "[$(current_date)] Running $k CPU Load with $j threads (Iteration $i)"

            sleep $SLEEP_TIME

            # stress-ng --cpu $j -t $DURATION
            stress-ng --cpu $j --cpu-load $k -t $DURATION

            sleep $SLEEP_TIME

            END_INSTANT=$(current_date)
            log_results "$i" "$j" "$k"
        done
    done
done
