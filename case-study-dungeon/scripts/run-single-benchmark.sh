#!/usr/bin/env bash

DUT_IP="192.168.178.79"
SSH_HOST_DUT="tobi@$DUT_IP"
SSH_PARAMETER="-o StrictHostKeyChecking=no"
DUT_EXPERIMENT_LOCATION="/home/tobi/software-architecture-sustainability-experiment/case-study-dungeon"
MONOLITH_DOCKERFILE="local-dev-environment/docker-compose.monolith.yml"
MICROSERVICES_DOCKERFILE="local-dev-environment/docker-compose.yml"
RESULTS_DIR="results/case-study-dungeon"
SLEEP_TIME=60s

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

setup_dut() {
    echo "[$(current_date)] Resetting DUT"
    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE stop"

    echo "[$(current_date)] Rebooting DUT"

    ssh "$SSH_PARAMETER" $SSH_HOST_DUT "sudo reboot"

    echo "[$(current_date)] Waiting for DUT to come back online"
    sh ./case-study-dungeon/scripts/waitforssh.sh $SSH_HOST_DUT
    RESULT=$?
    if [ ! $RESULT -eq 0 ]; then
        echo "[$(current_date)] DUT did not come back online"
        exit 1
    fi

    echo "[$(current_date)] Starting Services on DUT"

    if [ "$VARIANT" = "monolith" ]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE up -d"
    elif [ "$VARIANT" = "microservice" ]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MICROSERVICES_DOCKERFILE up -d"
    fi
}

cleanup_dut() {
    echo "[$(current_date)] Cleaning up DUT"

    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE stop"
}

run_game() {
    START_INSTANT=$(current_date)
    echo "[$START_INSTANT] Starting Game"

    # We need to wait a bit for the services to be up and running
    sleep 60s

    docker compose -f ./case-study-dungeon/local-dev-environment/docker-compose.players.yaml up -d

    # Create a short game
    hurl ./case-study-dungeon/local-dev-environment/requests/game_create_short

    # Wait for the players to join (should be instant, but just to be sure)
    sleep 10s

    # Start the game
    hurl "./case-study-dungeon/local-dev-environment/requests/game_start.hurl --variable gameId=$(hurl ./case-study-dungeon/local-dev-environment/requests/game_get_all.hurl | jq -r '.[0].gameId')"

    # End the game
    hurl "./case-study-dungeon/local-dev-environment/requests/game_end.hurl --variable gameId=$(hurl ./case-study-dungeon/local-dev-environment/requests/game_get_all.hurl | jq -r '.[0].gameId')"

    END_INSTANT=$(current_date)
    echo "[$END_INSTANT] Benchmark Game"

    docker compose -f ./case-study-dungeon/local-dev-environment/docker-compose.players.yaml stop
}

prepare_results_directory() {
    if [ ! -f "$RESULTS_DIR/benchmark-log.csv" ]; then
        echo "Start,End,Variant" >$RESULTS_DIR/benchmark-log.csv
    fi
}

log_results() {
    echo "$START_INSTANT,$END_INSTANT,${VARIANT}" >>$RESULTS_DIR/benchmark-log.csv
}

prepare_results_directory
setup_dut

sleep $SLEEP_TIME
run_game
sleep $SLEEP_TIME

cleanup_dut
log_results
