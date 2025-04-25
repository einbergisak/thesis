#!/bin/bash
FRAMEWORK=$1
TEST=$2
THREADS=$3
DURATION=$4

if [ "$#" -ne 4 ]; then
  echo "Error: Invalid number of arguments"
  echo "Usage: $0 <framework (vapor/ktor/express)> <test (lipsum/json/postgres/fibonacci)> <threads> <duration_in_seconds>"
  exit 1
fi

echo "Running with the following parameters:"
echo "Starting benchmark '$TEST' for $FRAMEWORK with $THREADS threads for $DURATION seconds"

# Launch the containers
docker compose down
docker compose up --build --wait -d $FRAMEWORK db

# Create the results directory if it doesn't exist
mkdir -p results

DOCKER_STATS_OUTPUT_FILE="results/${FRAMEWORK}_${TEST}_T${THREADS}_$(date '+%Y-%m-%d_%H:%M:%S')_DOCKER_STATS.csv"
JMETER_OUTPUT_FILE="results/${FRAMEWORK}_${TEST}_T${THREADS}_$(date '+%Y-%m-%d_%H:%M:%S')_JMETER_RESULTS.csv"

echo "Timestamp,ContainerName,CPUPerc,MemUsage,MemPerc" > "$DOCKER_STATS_OUTPUT_FILE"

# Start the JMeter test, build the image if necessary
docker compose build jmeter

echo "Running JMeter test for $DURATION seconds..."
docker compose run -d --rm jmeter \
  -n -t "/plan.jmx" \
  -Jframework=$FRAMEWORK \
  -Jtest=$TEST \
  -Jthreads=$THREADS \
  -Jduration=$DURATION \
  -Joutput_file="$JMETER_OUTPUT_FILE"

END_TIME=$(( $(date +%s) + DURATION ))

echo "Collecting hardware stats for $DURATION seconds..."

# Collect hardware stats for the specified duration
while [ $(date +%s) -lt $END_TIME ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  STATS=$(docker compose stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$FRAMEWORK")
  echo "$TIMESTAMP,$STATS" >> "$DOCKER_STATS_OUTPUT_FILE"
done

echo "Saved hardware stats to $DOCKER_STATS_OUTPUT_FILE"