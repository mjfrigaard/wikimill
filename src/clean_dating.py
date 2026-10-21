"""Clean the dating services table. Run from the project root: python src/clean_dating.py"""
import pandas as pd

dating = pd.read_csv("data/dating_services.csv")
users_raw = dating["registered_users"].str.extract(r"(\d{1,3}(?:,\d{3})+)")[0]
dating["registered_users_n"] = pd.to_numeric(users_raw.str.replace(",", ""))
leftover = pd.Series(
    [r.replace(u, "", 1) if pd.notna(u) else None for r, u in zip(dating["registered_users"], users_raw)],
    index=dating.index, dtype="object"
)
dating["users_year"] = pd.to_numeric(leftover.str.extract(r"(\d{4})")[0]).astype("Int64")
dating["free_clean"] = dating["free"].str.extract(r"^(Yes|No|Maybe)", flags=2)[0]
dating["all_features_free_clean"] = dating["all_features_free"].str.extract(r"^(Yes|No|Maybe)", flags=2)[0]

dating_clean = (
    dating.dropna(subset=["registered_users_n"])
    .drop_duplicates(subset="name")
)
dating_clean.to_csv("data/dating_services_clean.csv", index=False)
print(dating_clean.head())
