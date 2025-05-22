import os
import pandas as pd
from config import *
import pingouin as pg

ALPHA = 0.05

STATISTICAL_TESTS_DIR = OUTPUT_DIR + 'statistical_tests/'
os.makedirs(STATISTICAL_TESTS_DIR, exist_ok=True)

df = pd.read_csv(AGGREGATE_PATH)

# Sort by framework, so that the Games-Howell test will be listed in the same order
df['Framework'] = pd.Categorical(df['Framework'], categories=FRAMEWORKS, ordered=True)
df = df.sort_values(by=['Framework'])

welch_results = []
gh_results = []
zero_variance = []
for scenario in SCENARIOS:
    for num_threads in THREAD_COUNTS:
        for  metric in METRICS:
            # Filter for the specific scenario and thread count
            test_df = df[
                (df['Scenario'] == scenario) &
                (df['Threads'] == num_threads)]

            # Skip statistical tests if variance for this metric is zero for any framework
            zero_variance_found = False
            for framework, values in test_df.groupby('Framework', observed=True)[metric]:
                if len(set(values)) == 1: # all values are the same
                    zero_variance_found = True
                    zero_variance.append({
                        'Framework': framework,
                        'Scenario': scenario,
                        'Threads': num_threads,
                        'Metric': metric,
                    })
                    break

            if zero_variance_found:
                welch_results.append({
                    'Metric': metric,
                    'Scenario': scenario,
                    'Threads': num_threads,
                    'p-unc': None,
                    'F': None,
                    'np2': None,
                })
                continue

            welch_res = pg.welch_anova(data=test_df,dv=metric, between='Framework')
            welch_results.append({
                'Metric': metric,
                'Scenario': scenario,
                'Threads': num_threads,
                'p-unc': welch_res['p-unc'][0] if not welch_res.empty else None,
                'F': welch_res['F'][0] if not welch_res.empty else None,
                'np2': welch_res['np2'][0] if not welch_res.empty else None,
            })

            unit = UNIT[metric] if UNIT[metric] != '%' else '\%'

            # Perform pairwise Games-Howell post-hoc test, only if Welch's ANOVA is significant
            if welch_res['p-unc'][0] < ALPHA:
                gh_res = pg.pairwise_gameshowell(data=test_df, dv=metric, between='Framework')
                for index, row in gh_res.iterrows():
                    gh_results.append({
                        'Metric': metric,
                        'Scenario': scenario,
                        'Threads': num_threads,
                        'Comparison': f"{row['A'][:2].capitalize()}/{row['B'][:2].capitalize()}", # First two letters of A/B
                        'p-corr': row['pval'],
                        f'meandiff': row['diff']
                    })

welch_df = pd.DataFrame(welch_results)
gh_df = pd.DataFrame(gh_results)

print("Skipped due to zero variance:")
for item in zero_variance:
    print(f"Framework: {item['Framework']}, scenario: {item['Scenario']}, threads: {item['Threads']}, metric: {item['Metric']}")

welch_df.sort_values(by=['Metric', 'Threads','Scenario'], inplace=True)
gh_df.sort_values(by=['Metric', 'Threads','Scenario'], inplace=True)

welch_df.to_csv(STATISTICAL_TESTS_DIR+"welch.csv", index=False)
gh_df.to_csv(STATISTICAL_TESTS_DIR+"games_howell.csv", index=False)

# scenarios in italics for latex output
welch_df['Scenario'] = welch_df['Scenario'].apply(lambda x: f"\\textit{{{x}}}")
gh_df['Scenario'] = gh_df['Scenario'].apply(lambda x: f"\\textit{{{x}}}")

for metric in METRICS:
    welch_df[welch_df['Metric'] == metric].drop(columns=['Metric']).to_latex(
        STATISTICAL_TESTS_DIR+"welch_"+metric.lower()+".tex",
        index=False,
        float_format=lambda x: "0" if x == 0 else ("%.2e" % x if abs(x) < 0.01 else "%.2f" % x),
        caption="Welch's ANOVA results for "+metric+".",
        label="tab:welch_"+metric.lower(),
        position='htbp',
    )
    gh_df[gh_df['Metric'] == metric].rename(columns={'meandiff': f'meandiff ({unit})'}).drop(columns=['Metric']).to_latex(
        STATISTICAL_TESTS_DIR+"games_howell_"+metric.lower()+".tex",
        index=False,
        float_format=lambda x: "0" if x == 0 else ("%.2e" % x if abs(x) < 0.01 else "%.2f" % x),
        caption="Games-Howell post-hoc test results for "+metric+".",
        label="tab:games_howell_"+metric.lower(),
        position='htbp',
    )