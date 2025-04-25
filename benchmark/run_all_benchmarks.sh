#!/bin/bash
DURATION=120

for THREADS in 10 50 100 200 500; do
  for FRAMEWORK in vapor ktor express; do
    for TEST in lipsum json postgres fibonacci; do
      echo "Running $TEST benchmark for $FRAMEWORK with $THREADS threads."
      ./run_benchmark.sh "$FRAMEWORK" "$TEST" "$THREADS" "$DURATION"
      echo "Benchmark done, starting next one."
      sleep 3
    done
  done
done
echo "All benchmarks completed."