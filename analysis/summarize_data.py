import pandas as pd
import os
import re
from constants import *

# Parse docker stats memory usage output to MiB with regex
def parse_memory(mem_str):
    if not isinstance(mem_str, str):
        print("not a string")
        return None
    match = re.match(r"(\d+\.?\d*)([KMG])iB", mem_str.strip())
    if not match:
        print(f"Failed to parse memory string: {mem_str}")
        return None

    val, unit = match.groups()
    val = float(val)
    unit = unit.upper()

    if unit.startswith('K'):
        return val / 1024
    elif unit.startswith('G'):
        return val * 1024
    elif unit.startswith('M'):
        return val
    return None

all_results = []

for run_id in range(1, NUM_RUNS + 1):
    run_folder = os.path.join(RUNS_DIR, f'run_{run_id}')
    print(f"Processing {run_folder}")

    if not os.path.isdir(run_folder):
        print(f"Error: folder not found: {run_folder}.")
        continue

    for framework in FRAMEWORKS:
        for scenario in SCENARIOS:
            for thread_count in THREAD_COUNTS:

                jmeter_file = os.path.join(run_folder, f"{framework}_{scenario}_T{thread_count}_JMETER_RESULTS.csv")
                docker_file = os.path.join(run_folder, f"{framework}_{scenario}_T{thread_count}_DOCKER_STATS.csv")

                if not os.path.exists(jmeter_file):
                    print(f"JMeter file not found: {jmeter_file} in run {run_id}")
                    continue
                if not os.path.exists(docker_file):
                    print(f"Docker Stats file not found: {docker_file} in run {run_id}")
                    continue

                docker_df = pd.read_csv(docker_file, header=0)
                jmeter_df = pd.read_csv(jmeter_file, header=0)

                docker_df['Timestamp'] = pd.to_numeric(docker_df['Timestamp']) / 1000000  # Docker logs as nanoseconds, convert to ms
                jmeter_df['timeStamp'] = pd.to_numeric(jmeter_df['timeStamp'])

                # Normalize timestamps to start from 0
                initial_timestamp = docker_df['Timestamp'].iloc[0]
                docker_df['Timestamp'] = (docker_df['Timestamp'] - initial_timestamp)
                jmeter_df['timeStamp'] = (jmeter_df['timeStamp'] - initial_timestamp)

                # Filter out rows from the ramp-up period, as well as any rows after the test is considered finished
                docker_df = docker_df[(docker_df['Timestamp'] >= RAMPUP_DURATION*1000) & (docker_df['Timestamp'] <= (TEST_DURATION+RAMPUP_DURATION)*1000)]
                jmeter_df = jmeter_df[(jmeter_df['timeStamp'] >= RAMPUP_DURATION*1000) & (jmeter_df['timeStamp'] <= (TEST_DURATION+RAMPUP_DURATION)*1000)]

                # Remove percentage sign
                docker_df['CPUPerc_val'] = docker_df['CPUPerc'].astype(str).str.replace('%', '', regex=False).astype(float)

                # Normalize CPU percentage to 0-100 range
                docker_df['CPUPerc_val'] = docker_df['CPUPerc_val'] / DEDICATED_CPU_CORES
                avg_cpu = docker_df['CPUPerc_val'].mean()

                docker_df['MemMiB'] = docker_df['MemUsage'].apply(parse_memory)
                avg_mem = docker_df['MemMiB'].mean()

                jmeter_df['success'] = jmeter_df['success'] == True
                successful_requests = jmeter_df['success'].sum()
                total_requests = len(jmeter_df)
                errors = total_requests - successful_requests

                throughput = successful_requests / TEST_DURATION
                error_rate = (errors / total_requests * 100)

                # Calculate latency only for successful requests
                successful_df = jmeter_df[jmeter_df['success']]
                avg_latency = successful_df['Latency'].mean()
                tail_latency95 = successful_df['Latency'].quantile(95 / 100.0)
                tail_latency99 = successful_df['Latency'].quantile(99 / 100.0)

                all_results.append({
                    'Framework': framework,
                    'Scenario': scenario,
                    'Threads': thread_count,
                    'RunID': run_id,
                    'TotalRequests': total_requests,
                    'SuccessfulRequests': successful_requests,
                    'Throughput': throughput,
                    'AvgLatency': avg_latency,
                    'TailLatency95': tail_latency95,
                    'TailLatency99': tail_latency99,
                    'TotalErrors': errors,
                    'ErrorRate': error_rate,
                    'AvgCPU': avg_cpu,
                    'AvgMemoryMiB': avg_mem
                })

# convert list of dictionaries to DataFrame
final_df = pd.DataFrame(all_results)

final_df.to_csv(AGGREGATE_PATH, index=False)

# Also output average values for each metric
avg_df = final_df.groupby(['Framework', 'Scenario', 'Threads']).agg({
    'Throughput': 'mean',
    'AvgLatency': 'mean',
    # 'TailLatency95': 'mean',
    'TailLatency99': 'mean',
    'ErrorRate': 'mean',
    'AvgCPU': 'mean',
    'AvgMemoryMiB': 'mean'
})

# Round to 2 decimal places
avg_df = avg_df.round(2)
avg_df = avg_df.sort_values(by=['Scenario', 'Threads', 'Framework'])

avg_df.to_csv(AVERAGE_PATH)
print(f"Done, saved to: {AGGREGATE_PATH} and {AVERAGE_PATH} respectively")