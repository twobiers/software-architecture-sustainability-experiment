#!/usr/bin/env bash

DUT_IP="192.168.178.81"
SSH_HOST_DUT="tobi@$DUT_IP"
SSH_PARAMETER="-o StrictHostKeyChecking=no"
DUT_EXPERIMENT_LOCATION="/home/tobi/software-architecture-sustainability-experiment/case-study-caching"
RAMP_UP_VUS=0
RAMP_DOWN_VUS=0
VUS=200
RAMP_UP_DURATION=10s
RAMP_DOWN_DURATION=10s
DURATION=90s
BENCHMARK_SCRIPT="case-study-caching/benchmark/get_iterative_product_from_id_list.js"
VARIANT="${VARIANT:-no-cache}"
RESULTS_DIR="results/case-study-caching"
SLEEP_TIME=10s
SWARM_MODE=${SWARM_MODE:-false}
SWARM_STACK_NAME="experiment"
SWARM_SERVICE_SCALE=5
SUFFIX=${SUFFIX:-""}
if [ -n "$SUFFIX" ] && [ ! "$SUFFIX" = "-*" ]; then
    SUFFIX="-${SUFFIX}"
fi

export PRODUCTS_FILE="product_ids_1k.json"
export SERVICE_HOST="$DUT_IP:8080"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

setup_dut() {
    echo "[$(current_date)] Resetting DUT"
    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker compose stop"
    if [[ $SWARM_MODE == true ]]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker stack rm experiment"
    fi

    echo "[$(current_date)] Rebooting DUT"

    ssh "$SSH_PARAMETER" $SSH_HOST_DUT "sudo reboot"

    echo "[$(current_date)] Waiting for DUT to come back online"
    sh ./case-study-caching/scripts/waitforssh.sh $SSH_HOST_DUT
    RESULT=$?
    if [ ! $RESULT -eq 0 ]; then
        echo "[$(current_date)] DUT did not come back online"
        exit 1
    fi

    echo "[$(current_date)] Starting Services on DUT"

    if [[ $SWARM_MODE == true ]]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker compose up -d node_exporter"
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && export VARIANT=${VARIANT} && docker stack deploy -c docker-compose.yaml $SWARM_STACK_NAME"
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker service scale ${SWARM_STACK_NAME}_service=$SWARM_SERVICE_SCALE"
        if [[ ! $VARIANT == *"redis"* ]]; then
            ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker service scale ${SWARM_STACK_NAME}_redis=0"
        fi
    else
        #Hacky way to get all services except the one we want to exclude
        excluded_services="XXXXXXXXXXXXXXXXXXXXXXX"

        if [[ ! $VARIANT == *"redis"* ]]; then
            excluded_services="redis"
        fi
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && export VARIANT=${VARIANT} && docker compose config --services | grep -v $excluded_services | xargs docker compose up -d"
    fi
}

cleanup_dut() {
    echo "[$(current_date)] Cleaning up DUT"

    ssh "$SSH_PARAMETER" $SSH_HOST_DUT "cd $DUT_EXPERIMENT_LOCATION && docker compose stop"
    if [[ $SWARM_MODE == true ]]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker stack rm experiment"
    fi
}

run_benchmark() {
    START_INSTANT=$(current_date)
    echo "[$START_INSTANT] Starting Benchmark"

    # We sleep here, because we're scraping metrics from the DUT and we want to make sure that
    # we get metrics from within the interval of the benchmark. 1s is the configured scrape interval
    sleep 1s

    # Reset energy counter
    snmpset -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1 u 0

    k6 run \
        -o experimental-prometheus-rw \
        --summary-export "$RESULTS_DIR/${VARIANT}${SUFFIX}/${START_INSTANT}_k6.json" \
        -u $RAMP_UP_VUS -s $RAMP_UP_DURATION:$VUS -s $DURATION:$VUS -s $RAMP_DOWN_DURATION:$RAMP_DOWN_VUS \
        --quiet \
        $BENCHMARK_SCRIPT

    # Get energy consumption
    # Note that this is measured in Wh, and we probably don't get any meaningful value here as
    # the test is rather short.
    # We probably need to compare the active power values or increase the duration of the test.
    ENERGY_USAGE=$(snmpget -Oqv -v1 -c private 192.168.178.78 1.3.6.1.4.1.28507.43.1.5.1.2.1.13.1)

    # We sleep here, because we're scraping metrics from the DUT and we want to make sure that
    # we get metrics from within the interval of the benchmark. 1s is the configured scrape interval
    sleep 1s

    END_INSTANT=$(current_date)
    echo "[$END_INSTANT] Benchmark Ended"
}

prepare_results_directory() {

    # Prepare the results directory
    [ ! -d "$RESULTS_DIR/${VARIANT}${SUFFIX}" ] && mkdir -p "$RESULTS_DIR/$VARIANT${SUFFIX}"

    if [ ! -f "$RESULTS_DIR/benchmark-log.csv" ]; then
        echo "Start,End,VUS,Duration,Variant,Script,Products,Energy" >$RESULTS_DIR/benchmark-log.csv
    fi

}

log_results() {
    echo "$START_INSTANT,$END_INSTANT,$VUS,$DURATION,${VARIANT}${SUFFIX},$BENCHMARK_SCRIPT,$PRODUCTS_FILE,$ENERGY_USAGE" >>$RESULTS_DIR/benchmark-log.csv
}

prepare_results_directory
setup_dut

sleep $SLEEP_TIME
run_benchmark
sleep $SLEEP_TIME

cleanup_dut
log_results
