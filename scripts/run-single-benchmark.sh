#!/usr/bin/env bash

DUT_IP="192.168.178.80"
DUT_EXPERIMENT_LOCATION="/home/experiment/software-architecture-sustainability-experiment"
VUS=200
DURATION=30s
BENCHMARK_SCRIPT="benchmark/get_iterative_product_from_id_list.js"
VARIANT="${VARIANT:-no-cache}"
RESULTS_DIR="results"
SLEEP_TIME=10s

export PRODUCTS_FILE="product_ids_1k.json"
export SERVICE_HOST="192.168.178.80:8080"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

setup_dut() {
    echo "[$(current_date)] Preparing DUT"

    #Hacky way to get all services except the one we want to exclude
    excluded_services="XXXXXXXXXXXXXXXXXXXXXXX"

    if [[ ! $VARIANT == *"redis"* ]]; then
        excluded_services="redis"
    fi

    ssh -o StrictHostKeyChecking=no root@$DUT_IP "cd $DUT_EXPERIMENT_LOCATION && docker-compose down && VARIANT=${VARIANT} docker-compose up -d $(docker compose config --services | grep -v "$excluded_services")"
}

cleanup_dut() {
    echo "[$(current_date)] Cleaning up DUT"

    ssh -o StrictHostKeyChecking=no root@$DUT_IP "cd $DUT_EXPERIMENT_LOCATION && docker-compose down"
}

run_benchmark() {
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
}

prepare_results_directory() {

    # Prepare the results directory
    [ ! -d "$RESULTS_DIR/$VARIANT" ] && mkdir -p "$RESULTS_DIR/$VARIANT"

    if [ ! -f "$RESULTS_DIR/benchmark-log.csv" ]; then
        echo "Start, End, VUS, Duration, Variant, Script, Products, Energy" >$RESULTS_DIR/benchmark-log.csv
    fi

}

log_results() {
    echo "$START_INSTANT, $END_INSTANT, $VUS, $DURATION, $VARIANT, $BENCHMARK_SCRIPT, $PRODUCTS_FILE, $ENERGY_USAGE" >>$RESULTS_DIR/benchmark-log.csv
}

prepare_results_directory
setup_dut

sleep $SLEEP_TIME
run_benchmark
sleep $SLEEP_TIME

cleanup_dut
log_results
