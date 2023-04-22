#!/usr/bin/env bash

GIGABIT=1000000000
START_BITRATE=$((1 * GIGABIT))
END_BITRATE=$((30 * GIGABIT))
STEP_BITRATE=$((1 * GIGABIT))
RESULTS_DIR="results/netbench"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

prepare_results_directory() {
    mkdir -p "$RESULTS_DIR"
    if [ ! -f "$RESULTS_DIR/netbench-log.csv" ]; then
        echo "Start,End,Bitrate,Adapter" >"$RESULTS_DIR/netbench-log.csv"
    fi
}

iperf3 -s &
IPERF_SERVER_ID=$!

for ((bitrate = START_BITRATE; bitrate <= END_BITRATE; bitrate += STEP_BITRATE)); do
    echo "[$(current_date)] Running iperf3 with $bitrate"
    START_INSTANT=$(current_date)
    iperf3 -c localhost -b $bitrate -t 60
    END_INSTANT=$(current_date)

    echo "$START_INSTANT,$END_INSTANT,$bitrate,lo" >>"$RESULTS_DIR/netbench-log.csv"
done

kill $IPERF_SERVER_ID
