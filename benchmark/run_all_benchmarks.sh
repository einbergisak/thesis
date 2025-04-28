#!/bin/bash
DURATION=150 # 2 min + 30 sec ramp-up
DELAYMS=0
RAMPUP=30
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
      echo "Benchmark done, starting next one in 10 seconds."
      sleep 10
    done
  done
done
echo "All benchmarks completed."