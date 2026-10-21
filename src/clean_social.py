"""Clean the social platforms table. Run from the project root: python src/clean_social.py"""
import pandas as pd

social = pd.read_csv("data/social_platforms.csv")
mau_value = pd.to_numeric(social["monthly_active_users"].str.extract(r"([\d.]+)")[0], errors="coerce")
mau_unit = social["monthly_active_users"].str.extract(r"(billion|million)")[0]
social["mau_millions"] = mau_value * mau_unit.map({"billion": 1000, "million": 1})
top_companies = ["Meta Platforms", "Tencent", "ByteDance", "Microsoft", "Alphabet Inc."]
social["company_group"] = social["company"].where(social["company"].isin(top_companies), "Other")

social_clean = social.dropna(subset=["mau_millions"])
social_clean.to_csv("data/social_platforms_clean.csv", index=False)
print(social_clean.head())
