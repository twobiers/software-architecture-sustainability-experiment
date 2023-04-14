#!/usr/bin/env bash

VUS=50
DURATION=30s
BENCHMARK_SCRIPT="benchmark/get_single_product.js"
VARIANT="no-cache"
RESULTS_DIR="results"

current_date() {
    date +"%Y-%m-%d_%H-%M-%S"
}

[ ! -d "$RESULTS_DIR/$VARIANT" ] && mkdir -p "$RESULTS_DIR/$VARIANT"

START_INSTANT=$(current_date)
echo "[$START_INSTANT] Starting Benchmark"

k6 run \
    -o experimental-prometheus-rw \
    -o "csv=$RESULTS_DIR/$VARIANT/$START_INSTANT.csv" \
    -o "json=$RESULTS_DIR/$VARIANT/$START_INSTANT.json" \
    --vus $VUS \
    --duration $DURATION \
    $BENCHMARK_SCRIPT

END_INSTANT=$(current_date)
echo "[$END_INSTANT] Benchmark Ended"

echo "Start: $START_INSTANT, END: $END_INSTANT, VUS: $VUS, DURATION: $DURATION, VARIANT: $VARIANT, SCRIPT: $BENCHMARK_SCRIPT" >>$RESULTS_DIR/benchmark-log.txt
