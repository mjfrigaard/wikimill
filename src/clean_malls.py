"""Clean the defunct malls table. Run from the project root: python src/clean_malls.py"""
import pandas as pd

malls = pd.read_csv("data/defunct_malls.csv")
malls["status"] = pd.Categorical(
    malls["status"], categories=["Demolished", "Abandoned", "Defunct"], ordered=True
)
malls_clean = (
    malls.sort_values("status", kind="stable")
    .drop_duplicates(subset="title")
)
malls_clean.to_csv("data/defunct_malls_clean.csv", index=False)
print(malls_clean["status"].value_counts())
