#!/usr/bin/env bash

DUT_IP="192.168.178.80"
SSH_HOST_DUT="tobi@$DUT_IP"
SSH_PARAMETER="-o StrictHostKeyChecking=no"
DUT_EXPERIMENT_LOCATION="/home/tobi/Repos/th-koeln/software-architecture-sustainability-experiment/case-study-dungeon"
MONOLITH_DOCKERFILE="local-dev-environment/docker-compose.monolith.yaml"
MICROSERVICES_DOCKERFILE="local-dev-environment/docker-compose.yaml"
NODE_EXPORTER_COMPOSE_FILE="docker-compose.yaml"
RESULTS_DIR="results/case-study-dungeon"
SLEEP_TIME_SERVICE_UP=60s
SLEEP_TIME_GAME_START=10s
SLEEP_TIME=10s
GAME_DURATION=20m
HURL_ARGS="--connect-to localhost:8080:$DUT_IP:8080"
VARIANT="${VARIANT:-monolith}"

export RABBITMQ_HOST="$DUT_IP"
export GAME_URL="http://$DUT_IP:8080"

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

setup_dut() {
    echo "[$(current_date)] Resetting DUT"
    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE stop"
    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE rm -v -f"

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

    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $NODE_EXPORTER_COMPOSE_FILE up -d"
    if [ "$VARIANT" = "monolith" ]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE up -d"
    elif [ "$VARIANT" = "microservice" ]; then
        ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MICROSERVICES_DOCKERFILE up -d"
    fi
}

cleanup_dut() {
    echo "[$(current_date)] Cleaning up DUT"

    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE stop"
    ssh "$SSH_PARAMETER" "$SSH_HOST_DUT" "cd $DUT_EXPERIMENT_LOCATION && docker-compose -f $MONOLITH_DOCKERFILE -f $MICROSERVICES_DOCKERFILE rm -v -f"
}

run_game() {
    # We need to wait a bit for the services to be up and running
    sleep $SLEEP_TIME_SERVICE_UP

    # End game if exists
    echo "Ending game if one is running. Note that it is allowed to fail."
    hurl $HURL_ARGS "./case-study-dungeon/local-dev-environment/requests/game_end.hurl" --variable gameId="$(hurl $HURL_ARGS ./case-study-dungeon/local-dev-environment/requests/game_get_all.hurl | jq -r '.[0].gameId')"

    # Shutdown players because why not
    echo "Starting players."
    docker compose -f "./case-study-dungeon/local-dev-environment/docker-compose.players.yaml" stop
    docker compose -f "./case-study-dungeon/local-dev-environment/docker-compose.players.yaml" rm -v -f
    docker compose -f "./case-study-dungeon/local-dev-environment/docker-compose.players.yaml" up -d

    # Create a short game
    echo "Creating game"
    hurl $HURL_ARGS ./case-study-dungeon/local-dev-environment/requests/game_create_short.hurl

    # Wait for the players to join (should be instant, but just to be sure)
    echo "Waiting for players to connect."
    sleep $SLEEP_TIME_GAME_START

    START_INSTANT=$(current_date)
    echo "[$START_INSTANT] Starting Game"

    # Start the game
    hurl $HURL_ARGS "./case-study-dungeon/local-dev-environment/requests/game_start.hurl" --variable gameId="$(hurl $HURL_ARGS ./case-study-dungeon/local-dev-environment/requests/game_get_all.hurl | jq -r '.[0].gameId')"

    sleep $GAME_DURATION

    # End the game
    echo "Ending game."
    hurl $HURL_ARGS "./case-study-dungeon/local-dev-environment/requests/game_end.hurl" --variable gameId="$(hurl $HURL_ARGS ./case-study-dungeon/local-dev-environment/requests/game_get_all.hurl | jq -r '.[0].gameId')"

    END_INSTANT=$(current_date)
    echo "[$END_INSTANT] Benchmark Game ended"

    docker compose -f "./case-study-dungeon/local-dev-environment/docker-compose.players.yaml" stop
    docker compose -f "./case-study-dungeon/local-dev-environment/docker-compose.players.yaml" rm -v -f
}

prepare_results_directory() {
    [ ! -d "$RESULTS_DIR" ] && mkdir -p "$RESULTS_DIR"
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
