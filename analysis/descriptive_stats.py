import os
import pandas as pd
from config import *

DESCRIPTIVE_DIR = OUTPUT_DIR + 'descriptive/'
os.makedirs(DESCRIPTIVE_DIR, exist_ok=True)

descriptive_results = []
df = pd.read_csv(AGGREGATE_PATH)

# Save as one CSV file per metric
for metric in METRICS:
    # Group by config, leaves one row per run
    descriptive_stats_df = df.groupby(['Framework', 'Scenario', 'Threads'])[metric].agg(
        Mean='mean',
        SD='std',
    ).reset_index()
    descriptive_stats_df['Framework'] = pd.Categorical(descriptive_stats_df['Framework'], categories=FRAMEWORKS, ordered=True)
    descriptive_stats_df['Scenario'] = pd.Categorical(descriptive_stats_df['Scenario'], categories=SCENARIOS, ordered=True)
    descriptive_stats_df.sort_values(by=['Threads', 'Scenario', 'Framework'], inplace=True)
    descriptive_stats_df = descriptive_stats_df[['Threads', 'Scenario', 'Framework', 'Mean', 'SD']]

    unit = UNIT[metric] if UNIT[metric] != '%' else '\%'
    descriptive_stats_df.rename(columns={'Mean': f'Mean ({unit})', 'SD': f'SD ({unit})'}, inplace=True)

    descriptive_stats_df.to_csv(DESCRIPTIVE_DIR+'descriptive_'+metric.lower()+'.csv', index=False)
    # scenarios in italics for latex output
    descriptive_stats_df['Scenario'] = descriptive_stats_df['Scenario'].apply(lambda x: f"\\textit{{{x}}}")
    descriptive_stats_df.to_latex(
        DESCRIPTIVE_DIR+'descriptive_'+metric.lower()+'.tex',
        index=False,
        float_format="%.2f",
        label='tab:descriptive_'+metric.lower(),
        caption='Descriptive statistics for '+METRIC_LABELS[metric]+'.',
        position='htbp',
    )