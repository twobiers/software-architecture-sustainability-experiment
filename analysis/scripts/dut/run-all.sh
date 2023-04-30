#!/usr/bin/env bash

ITERATIONS=3

current_date() {
    # date +"%Y-%m-%d_%H-%M-%S"
    date +%s
}

for i in $(seq 1 $ITERATIONS); do
    echo "[$(current_date)] Iteration $i"

    echo "[$(current_date)] Running CPU Benchmark"
    sh ./analysis/scripts/dut/run-cpu.sh

    echo "[$(current_date)] Running Memory Benchmark"
    sh ./analysis/scripts/dut/run-membench.sh

    echo "[$(current_date)] Running Disk Benchmark"
    sh ./analysis/scripts/dut/run-iobench.sh

    echo "[$(current_date)] Running Network Benchmark"
    sh ./analysis/scripts/dut/run-netbench-lo.sh
done
