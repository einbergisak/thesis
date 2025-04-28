#!/bin/bash
FRAMEWORK=$1
TEST=$2
THREADS=$3
DURATION=$4
DELAYMS=$5
RAMPUP=$6

if [ "$#" -ne 6 ]; then
  echo "Error: Invalid number of arguments"
  echo "Usage: $0 <framework (vapor/ktor/express)> <test (lipsum/json/postgres/fibonacci)> <threads> <duration_in_seconds> <delay_in_ms> <rampup_in_seconds>"
  exit 1
fi

echo "Running with the following parameters:"
echo "Starting benchmark '$TEST' for $FRAMEWORK with $THREADS threads for $DURATION seconds, with a delay of $DELAYMS ms and ramp-up time of $RAMPUP seconds."

# Launch the framework and database containers
docker compose down
docker compose up --build --wait -d $FRAMEWORK db

echo "Waiting a few seconds for the containers to initialize properly..."
sleep 10

# Create the results directory if it doesn't exist
mkdir -p results

DOCKER_STATS_OUTPUT_FILE="results/${FRAMEWORK}_${TEST}_T${THREADS}_DOCKER_STATS.csv"
JMETER_OUTPUT_FILE="results/${FRAMEWORK}_${TEST}_T${THREADS}_JMETER_RESULTS.csv"

echo "Timestamp,ContainerName,CPUPerc,MemUsage,MemPerc" > "$DOCKER_STATS_OUTPUT_FILE"

# Start the JMeter test
echo "Running JMeter test for $DURATION seconds..."
docker compose run --build -d --rm jmeter \
  -n -t "/plan.jmx" \
  -Jframework=$FRAMEWORK \
  -Jtest=$TEST \
  -Jthreads=$THREADS \
  -Jduration=$DURATION \
  -Jdelayms=$DELAYMS \
  -Jrampup=$RAMPUP \
  -Joutput_file="$JMETER_OUTPUT_FILE"

END_TIME=$(( $(date +%s) + DURATION ))

echo "Collecting hardware stats for $DURATION seconds."

# Collect hardware stats for the specified duration
while [ $(date +%s) -lt $END_TIME ]; do
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  STATS=$(docker compose stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}}" "$FRAMEWORK")
  echo "$TIMESTAMP,$STATS" >> "$DOCKER_STATS_OUTPUT_FILE"
done

echo "Finished collecting hardware stats, waiting for JMeter to finish."
docker compose wait jmeter

echo "JMeter test finished, shutting down containers."
docker compose down

echo "Benchmarking completed. Results saved to $JMETER_OUTPUT_FILE and $DOCKER_STATS_OUTPUT_FILE"