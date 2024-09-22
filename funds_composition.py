import numpy as np
import pandas as pd
from tabulate import tabulate

# Given data
asset_classes = ['bonds', 'large_cap', 'us_mid_cap', 'us_small_cap', 'large_foreign', 'emerging', 'commodities', 's&p']
average_returns = [4.44, 7.85, 9.55, 9.22, 2.26, 5.57, -2.62, 7.89]
std_10_yrs = [3.29, 14.32, 17.68, 19.55, 18.21, 23.60, 18.11, 14.74]
risk_profile = [1, 3, 3, 4, 4, 5, 5, 2]
percent_fees = [0.01, 0.003, 0.003, 0.003, 0.01, 0.015, 0.064, 0.005]

# Create a DataFrame for easier data manipulation
df = pd.DataFrame({
    'asset_class': asset_classes,
    'avg_return': average_returns,
    'std_dev': std_10_yrs,
    'risk_profile': risk_profile,
    'fees': percent_fees
})

# Function to create a fund with given optimization priority
def create_fund(risk_category, optimization):
    eligible_assets = df[df['risk_profile'] <= risk_category]
    
    if optimization == 'returns':
        eligible_assets = eligible_assets.sort_values('avg_return', ascending=False)
    elif optimization == 'fees':
        eligible_assets = eligible_assets.sort_values('fees')
    elif optimization == 'goal':
        eligible_assets = eligible_assets.sort_values(['risk_profile', 'avg_return'], ascending=[True, False])
    
    # Determine the number of assets to include
    min_assets = min(3, len(eligible_assets))
    max_assets = len(eligible_assets)
    num_assets = np.random.randint(min_assets, max_assets + 1)
    
    selected_assets = eligible_assets.head(num_assets)
    
    weights = np.random.dirichlet(np.ones(num_assets))
    
    return pd.Series({
        'assets': dict(zip(selected_assets['asset_class'], weights)),
        'weighted_risk': np.sum(selected_assets['risk_profile'] * weights),
        'weighted_return': np.sum(selected_assets['avg_return'] * weights),
        'weighted_fees': np.sum(selected_assets['fees'] * weights)
    })

# Create 15 funds
funds = {}
for risk in range(1, 6):
    for opt in ['returns', 'fees', 'goal']:
        fund_name = f"Risk{risk}_{opt.capitalize()}"
        funds[fund_name] = create_fund(risk, opt)

# Convert funds to DataFrame for easier viewing
funds_df = pd.DataFrame(funds).T
funds_df = funds_df.reset_index()
funds_df.columns = ['Fund Name', 'Asset Allocation', 'Weighted Risk', 'Weighted Return', 'Weighted Fees']

# Format the asset allocation for better readability
funds_df['Asset Allocation'] = funds_df['Asset Allocation'].apply(lambda x: '\n'.join([f"{k}: {v:.2%}" for k, v in x.items()]))

# Format the numerical columns
funds_df['Weighted Risk'] = funds_df['Weighted Risk'].round(2)
funds_df['Weighted Return'] = funds_df['Weighted Return'].round(2)
funds_df['Weighted Fees'] = (funds_df['Weighted Fees'] * 100).round(3).astype(str) + '%'

# Print the table
print(tabulate(funds_df, headers='keys', tablefmt='pipe', showindex=False))

# Optional: Save to CSV
# funds_df.to_csv('funds_analysis.csv', index=False)