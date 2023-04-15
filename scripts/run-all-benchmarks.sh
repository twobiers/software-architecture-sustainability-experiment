#!/usr/bin/env bash

ITERATIONS=1
VARIANTS=("no-cache" "caffeine-cache" "redis-cache" "caffeine-redis-cache")

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

for v in "${VARIANTS[@]}"; do
    echo "[$(current_date)] Running $v"
    for i in $(seq 1 $ITERATIONS); do
        echo "[$(current_date)] Iteration $i"
        export VARIANT=$v
        ./scripts/run-single-benchmark.sh
    done
done
