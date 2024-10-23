import numpy as np
import pandas as pd
from scipy.optimize import minimize

# Define Asset Classes and Return Ranges (min_return, avg_return, max_return in %)
asset_classes = ['Bonds', 'Large Cap', 'US Mid Cap', 'US Small Cap', 'Foreign Ex', 'Emerging', 'Commodities', 'Market ETF']
return_ranges = {
    'Bonds': (3.94, 4.44, 4.94),
    'Large Cap': (7.35, 7.85, 8.35),
    'US Mid Cap': (9.05, 9.55, 10.05),
    'US Small Cap': (8.72, 9.22, 9.72),
    'Foreign Ex': (1.76, 2.26, 2.76),
    'Emerging': (5.07, 5.57, 6.07),
    'Commodities': (3.12, -2.62, -2.12),
    'Market ETF': (7.39, 7.89 , 8.39)
}
# Define Asset Objectives and Target Returns (these are only target returns, not actual returns)
asset_objectives = {
    'General Savings': 5,
    'Home Ownership': 7,
    'Family Planning': 8,
    'Retirement': 9,
    'Unknown': 11
}

# Function to generate random returns within the defined range for each asset class
def generate_random_returns(return_ranges):
    return np.array([np.random.uniform(low, high) for low, _, high in return_ranges.values()])

# Constraint to ensure that weights sum to 1 (fully allocated)
def constraint(weights):
    return np.sum(weights) - 1

# Adaptive Regularization: Penalize allocations that are far from mid-values, scaled by target proximity
def regularization(weights, achieved_return, target_return, target_mid=0.15, scale_factor=10):
    penalty = np.sum((weights - target_mid)**2)
    return scale_factor * penalty / max(np.abs(target_return - achieved_return), 0.1)

# Add randomness to weights to avoid being trapped at uniform allocation
def add_perturbation(weights, factor=0.01):
    return weights + np.random.uniform(-factor, factor, size=len(weights))

# Objective Function: Minimize the difference between achieved return and target return
def objective(weights, random_returns, target_return, reg_factor=1):
    portfolio_return = np.dot(weights, random_returns)
    penalty = regularization(weights, portfolio_return, target_return)
    return penalty + (target_return - portfolio_return) ** 2

# Initial equal allocation across all asset classes, plus some random perturbation
initial_weights = add_perturbation(np.ones(len(asset_classes)) / len(asset_classes))

# Set bounds for each asset class allocation between 5% and 25%
bounds = [(0.05, 0.25) for _ in range(len(asset_classes))]

# Create a list to store the rows of the join table
rows = []

# Loop through each asset objective and optimize allocation to achieve its target return
for obj_id, (obj, target_return) in enumerate(asset_objectives.items(), start=1):
    # Generate random returns for this iteration (same for all objectives)
    random_returns = generate_random_returns(return_ranges)
     
    # Perform optimization to find optimal weights
    result = minimize(objective, initial_weights, args=(random_returns, target_return),
                      method='SLSQP', bounds=bounds, constraints={'type': 'eq', 'fun': constraint})
    
    # Get the optimized weights
    optimal_weights = result.x
    
    # Store the results in the join table format
    for class_id, weight in enumerate(optimal_weights, start=1):
        rows.append([class_id, obj_id, weight * 100])

# Convert the rows into a DataFrame
df = pd.DataFrame(rows, columns=['asset_class_id', 'asset_objective_id', 'allocation_perc'])

# Save the DataFrame as a CSV file
csv_file_path = 'asset_allocations_join_table.csv'
df.to_csv(csv_file_path, index=False)

print(f"Join table CSV saved to {csv_file_path}.")
