#!/usr/bin/env bash

VUS=50
DURATION=30s
BENCHMARK_SCRIPT="benchmark/get_single_product.js"
VARIANT="no-cache"
RESULTS_DIR="results"
export PRODUCTS_FILE="product_ids_10k.json"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

[ ! -d "$RESULTS_DIR/$VARIANT" ] && mkdir -p "$RESULTS_DIR/$VARIANT"

START_INSTANT=$(current_date)
echo "[$START_INSTANT] Starting Benchmark"

# Reset energy counter
snmpset -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1 u 0

k6 run \
    -o experimental-prometheus-rw \
    -o "csv=$RESULTS_DIR/$VARIANT/${START_INSTANT}_k6.csv" \
    -o "json=$RESULTS_DIR/$VARIANT/${START_INSTANT}_k6.json" \
    --vus $VUS \
    --duration $DURATION \
    $BENCHMARK_SCRIPT

# Get energy consumption
# Note that this is measured in Wh, and we probably don't get any meaningful value here as
# the test is rather short.
# We probably need to compare the active power values or increase the duration of the test.
ENERGY_USAGE=$(snmpget -Oqv -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1)

END_INSTANT=$(current_date)
echo "[$END_INSTANT] Benchmark Ended"

if [ ! -f "$RESULTS_DIR/benchmark-log.txt" ]; then
    echo "Start, End, VUS, Duration, Variant, Script, Energy" >$RESULTS_DIR/benchmark-log.csv
fi
echo "$START_INSTANT, $END_INSTANT, $VUS, $DURATION, $VARIANT, $BENCHMARK_SCRIPT, $ENERGY_USAGE" >>$RESULTS_DIR/benchmark-log.csv
