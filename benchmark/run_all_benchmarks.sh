#!/bin/bash
DURATION=150 # 2 min + 30 sec ramp-up
DELAYMS=0
RAMPUP=30
for i in {1..10}; do
  for THREADS in 4 200 500; do
    if [ "$THREADS" -eq 4 ]; then
      DELAYMS=1000
    elif [ "$THREADS" -eq 200 ]; then
      DELAYMS=250
    elif [ "$THREADS" -eq 500 ]; then
      DELAYMS=0
    fi
    for FRAMEWORK in vapor ktor express; do
      for TEST in lipsum json postgres fibonacci; do
        ./run_benchmark.sh "$FRAMEWORK" "$TEST" "$THREADS" "$DURATION" "$DELAYMS" "$RAMPUP"
        echo "Benchmark done for $FRAMEWORK with test $TEST and $THREADS threads (Run #$i). Waiting for 10 seconds before starting the next one"
        sleep 10
      done
    done
  done
  mkdir -p "results/run_$i"
  mv results/*.csv "results/run_$i/"
  echo "All benchmarks for run $i completed, moving results to results/run_$i/"
done
echo "All benchmarks completed."