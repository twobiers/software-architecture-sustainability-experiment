#!/usr/bin/env bash

RESULTS_DIR="results/base"
DURATION="5m"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

mkdir -p $RESULTS_DIR

# Reset energy counter
snmpset -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1 u 0

START_INSTANT=$(current_date)

sleep $DURATION

END_INSTANT=$(current_date)
ENERGY_USAGE=$(snmpget -Oqv -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1)

if [ ! -f "$RESULTS_DIR/baseline.csv" ]; then
    echo "Start,End,Duration,Energy" >$RESULTS_DIR/baseline.csv
fi

echo "$START_INSTANT,$END_INSTANT,$DURATION,$ENERGY_USAGE" >>$RESULTS_DIR/baseline.csv
