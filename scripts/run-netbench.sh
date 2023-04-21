#!/usr/bin/env bash

DUT_IP="192.168.178.79"
SSH_HOST_DUT="tobi@$DUT_IP"
SSH_PARAMETER="-o StrictHostKeyChecking=no"
MEGABIT=1000000
START_BITRATE=$((1 * MEGABIT))
END_BITRATE=$((100 * MEGABIT))
STEP_BITRATE=$((5 * MEGABIT))
RESULTS_DIR="results/netbench"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

prepare_results_directory() {
    mkdir -p "$RESULTS_DIR"
    if [ ! -f "$RESULTS_DIR/iobench-log.csv" ]; then
        echo "Start,End,Bitrate,Adapter" >"$RESULTS_DIR/netbench-log.csv"
    fi
}

ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "iperf3 -s &"

for ((bitrate = START_BITRATE; bitrate <= END_BITRATE; bitrate += STEP_BITRATE)); do
    echo "[$(current_date)] Running iperf3 with $bitrate"
    START_INSTANT=$(current_date)
    iperf3 -c $DUT_IP -b $bitrate -t 60
    END_INSTANT=$(current_date)

    echo "$START_INSTANT,$END_INSTANT,$bitrate,enp7s0" >>"$RESULTS_DIR/netbench-log.csv"
done