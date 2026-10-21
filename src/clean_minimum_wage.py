"""Clean the minimum wage table. Run from the project root: python src/clean_minimum_wage.py"""
import pandas as pd

wage = pd.read_csv("data/minimum_wage.csv")
wage_clean = wage.filter(regex="Country|Annual_Nominal").iloc[:, :2]
wage_clean.columns = ["country", "annual_wage_usd"]
wage_clean["annual_wage_usd"] = pd.to_numeric(wage_clean["annual_wage_usd"], errors="coerce")
wage_clean = wage_clean.dropna(subset=["annual_wage_usd"])
wage_clean.to_csv("data/minimum_wage_clean.csv", index=False)
print(wage_clean.head())
