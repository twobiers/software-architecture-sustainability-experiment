#!/usr/bin/env bash

ITERATIONS=30
SWARM_MODE=${SWARM_MODE:-false}
SUFFIX=${SUFFIX:-""}
if [ -n "$SUFFIX" ] && [ ! "$SUFFIX" = "-*" ]; then
    SUFFIX="-${SUFFIX}"
fi
VARIANTS=("no-cache" "caffeine-cache" "redis-cache")

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

for i in $(seq 1 $ITERATIONS); do
    echo "[$(current_date)] Iteration $i"
    for v in "${VARIANTS[@]}"; do
        echo "[$(current_date)] Running $v"
        export VARIANT="$v"
        export SUFFIX="$SUFFIX"
        sh ./case-study-caching/scripts/run-single-benchmark.sh

        RESULT=$?
        if [ ! $RESULT -eq 0 ]; then
            echo "[$(current_date)] Benchmark failed"
        fi
    done
done
