#!/bin/bash
DURATION=$1

if [ -z "$DURATION" ]; then
  echo "Usage: $0 <duration_in_seconds>"
  exit 1
fi

# Print $FRAMEWORK $TEST $THREADS $DURATION variables
echo "Running with the following parameters:"
echo "FRAMEWORK: $FRAMEWORK (Docker compose container name)"
echo "TEST: $TEST"
echo "THREADS: $THREADS"

OUTPUT_FILE="${FRAMEWORK}_${TEST}_T${THREADS}_$(date '+%Y-%m-%d_%H:%M:%S').csv"

echo "Timestamp,ContainerName,CPUPerc,MemUsage,MemPerc" > "$OUTPUT_FILE"

END_TIME=$(( $(date +%s) + DURATION ))

while [ $(date +%s) -lt $END_TIME ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  STATS=$(docker compose stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$FRAMEWORK")
  echo "$TIMESTAMP,$STATS" >> "$OUTPUT_FILE"
done

echo "Saved stats to $OUTPUT_FILE"