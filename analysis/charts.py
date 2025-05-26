import os
from config import *
import pandas as pd
import seaborn as sb
import numpy as np
import matplotlib.ticker as ticker
import matplotlib.pyplot as plt

os.makedirs(CHARTS_DIR, exist_ok=True)
df = pd.read_csv(AGGREGATE_PATH)

sb.set_theme(style="whitegrid")

# Matches the languages' official colors
framework_colors = {
    'vapor': '#f05138',
    'ktor': '#b125ea',
    'express': '#f7df1e'
}

for metric in METRICS:
    for num_threads in THREAD_COUNTS:

        fig, axes = plt.subplots(2, 2, figsize=(8, 8))

        fig.suptitle(f'{METRIC_LABELS[metric]} at {num_threads} concurrent users (mean +/- SD)', fontsize=16, y=0.955)

        for i, scenario in enumerate(SCENARIOS):
            row, col = divmod(i, 2)
            ax = axes[row, col]
            scenario_df = df[(df['Scenario'] == scenario) & (df['Threads'] == num_threads)]

            sb.barplot(
                x='Framework',
                y=metric,
                data=scenario_df,
                ax=ax,
                palette=framework_colors,
                hue='Framework',
                order=FRAMEWORKS,
                hue_order=FRAMEWORKS,
                estimator=np.mean,
                errorbar='sd', # standard deviation error bars
                err_kws = {'linewidth': 1.8}, # width of error bar lines
                capsize=0.2, # edge size of error bars
            )

            ax.set_xticks(range(3))
            ax.set_xticklabels([f.capitalize() for f in FRAMEWORKS], fontsize=12)
            ax.set_xlabel(None)

            ax.set_title(f'Scenario: {scenario}', fontsize=14)
            ax.yaxis.set_major_locator(ticker.MaxNLocator("auto"))

            if col == 0:  # only show label for first column in the grid
                ax.set_ylabel(f"{METRIC_LABELS[metric]} ({UNIT[metric]})", fontsize=14)
            else:
                ax.set_ylabel('')

            ax.tick_params(axis='x', labelsize=12)
            ax.tick_params(axis='y', labelsize=11)
            ax.grid(visible=True, linewidth=1.0)

        fig.tight_layout(rect=[0, 0.03, 1, 0.95])
        file_name = CHARTS_DIR + f'{metric}_{num_threads}.svg'
        plt.savefig(file_name, dpi=600, format='svg', bbox_inches='tight')