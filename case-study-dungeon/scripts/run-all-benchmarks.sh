#!/usr/bin/env bash

ITERATIONS=1
VARIANTS=("microservice" "monolith")

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

for i in $(seq 1 $ITERATIONS); do
    echo "[$(current_date)] Iteration $i"
    for v in "${VARIANTS[@]}"; do
        echo "[$(current_date)] Running Dungeon $v"
        export VARIANT="$v"
        sh ./case-study-dungeon/scripts/run-single-benchmark.sh

        RESULT=$?
        if [ ! $RESULT -eq 0 ]; then
            echo "[$(current_date)] Failed"
        fi
    done
done
