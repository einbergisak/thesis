#!/bin/bash
CONTAINER_NAME=$1
DURATION=$2

# print usage
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <container name> <duration>"
  exit 1
fi

OUTPUT_FILE="${CONTAINER_NAME}_$(date '+%Y-%m-%d_%H:%M:%S').csv"

echo "Timestamp,ContainerName,CPUPerc,MemUsage,MemPerc" > "$OUTPUT_FILE"

END_TIME=$(( $(date +%s) + DURATION ))

while [ $(date +%s) -lt $END_TIME ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  STATS=$(docker compose stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$CONTAINER_NAME")
  echo "$TIMESTAMP,$STATS" >> "$OUTPUT_FILE"
done

echo "Saved stats to $OUTPUT_FILE"