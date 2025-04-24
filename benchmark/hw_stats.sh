#!/bin/bash
CONTAINER_NAME=$1
OUTPUT_FILE=$2
DURATION=$3

# print usage
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <container name> <output file> <duration>"
  exit 1
fi

echo "Timestamp,ContainerName,CPUPerc,MemUsage,MemPerc" > "$OUTPUT_FILE"

END_TIME=$(( $(date +%s) + DURATION ))

while [ $(date +%s) -lt $END_TIME ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  STATS=$(docker compose stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$CONTAINER_NAME")
  echo "$TIMESTAMP,$STATS" >> "$OUTPUT_FILE"
done