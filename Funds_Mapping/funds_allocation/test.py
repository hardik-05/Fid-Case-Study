import pulp

# Data
available_amounts = {
    1: 1595307227.82,
    2: 2772916982.18,
    3: 4136493517.30,
    4: 4110378798.18,
    5: 1528559151.75,
    6: 1790428251.49,
    7: 1540715225.66,
    8: 3351837482.83
}

percent_of_fund = {
    1: 0.04,
    2: 0.23,
    3: 0.18,
    4: 0.08,
    5: 0.22,
    6: 0.0,
    7: 0.0,
    8: 0.24
}

# Create the problem variable
prob = pulp.LpProblem("Maximize_Total_Investment", pulp.LpMaximize)

# Define the decision variable Z (total investable amount)
Z = pulp.LpVariable("Total_Investable_Amount", lowBound=0, cat="Continuous")

# Constraints: Each individual investable amount (a_i * Z) must be less than or equal to the available amount
for i in available_amounts.keys():
    prob += percent_of_fund[i] * Z <= available_amounts[i], f"Max_Investment_in_Asset_Class_{i}"

# Objective function: Maximize Z
prob += Z, "Maximize_Total_Investment"

# Solve the problem
prob.solve()

# Print the results
print(f"Total Maximized Investment (Z): {pulp.value(prob.objective)}")
for i in available_amounts.keys():
    print(f"Investable Amount in Asset Class {i} = {percent_of_fund[i] * pulp.value(prob.objective)}")

