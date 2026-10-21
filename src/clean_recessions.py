"""Clean the recessions table. Run from the project root: python src/clean_recessions.py"""
import pandas as pd

generations = pd.DataFrame({
    "generation": [
        "Greatest Generation", "Silent Generation", "Baby Boomers",
        "Generation X", "Millennials", "Generation Z"
    ],
    "birth_start": [1901, 1928, 1946, 1965, 1981, 1997],
    "birth_end": [1927, 1945, 1964, 1980, 1996, 2012],
})
generations["entry_start"] = generations["birth_start"] + 22
generations["entry_end"] = generations["birth_end"] + 22
generations["generation_label"] = (
    generations["generation"] + "\nentered "
    + generations["entry_start"].astype(str) + "–" + generations["entry_end"].astype(str)
)
generations["band_label"] = generations["generation"].str.replace(" ", "\n", n=1)
generations["band_start"] = pd.to_datetime(generations["entry_start"].clip(lower=1944).astype(str) + "-01-01")
generations["band_end"] = pd.to_datetime((generations["entry_end"].clip(upper=2025) + 1).astype(str) + "-01-01")
generations["band_mid"] = (
    generations["band_start"] + (generations["band_end"] - generations["band_start"]) / 2
).dt.floor("D")
generations["shade"] = (generations.index + 1) % 2 == 0

names = {
    1945: "Demobilization", 1948: "Tightening", 1953: "Korea", 1957: "Eisenhower",
    1960: "Rates", 1969: "Vietnam", 1973: "Oil", 1980: "Volcker", 1981: "Iran",
    1990: "Gulf", 2001: "Dotcom", 2007: "Subprime", 2020: "Pandemic",
}
eras = {
    2001: "Dot-com bust", 2007: "Financial crisis", 2008: "Financial crisis",
    2009: "Financial crisis", 2020: "COVID-19",
}

recessions = pd.read_csv("data/recessions.csv")
recessions["period_range"] = recessions["period_range"].str.replace(r"\[\d+\]", "", regex=True)
recessions["start_date"] = pd.to_datetime(
    recessions["period_range"].str.extract(r"^([A-Za-z]+ \d{4})")[0], format="%B %Y"
)
recessions["end_date"] = pd.to_datetime(
    recessions["period_range"].str.extract(r"([A-Za-z]+ \d{4})$")[0], format="%B %Y"
)
recessions["start_year"] = recessions["start_date"].dt.year
recessions["end_year"] = recessions["end_date"].dt.year
recessions["gdp_decline_pct"] = pd.to_numeric(
    recessions["gdp_decline"].str.extract(r"([\d.]+)")[0], errors="coerce"
)
recessions["peak_unemployment_pct"] = pd.to_numeric(
    recessions["peak_unemployment"].str.extract(r"([\d.]+)")[0], errors="coerce"
)
recessions = recessions.dropna(subset=["start_year", "end_year", "gdp_decline_pct"])
recessions = recessions[recessions["start_year"] >= 1945].astype({"start_year": int, "end_year": int})
recessions["name"] = recessions["start_year"].map(names).fillna(recessions["name"])
recessions["era"] = recessions["start_year"].map(eras).fillna("Other")
years = recessions["start_year"].astype(str).where(
    recessions["start_year"] == recessions["end_year"],
    recessions["start_year"].astype(str) + "–" + recessions["end_year"].astype(str)
)
recessions["label"] = recessions["name"] + " (" + years + ")"

# pandas has no overlap join: cross join every pair, then keep the overlaps
recessions = (
    recessions.merge(generations, how="cross")
    .query("start_year <= entry_end and end_year >= entry_start")
)
recessions.to_csv("data/recessions_clean.csv", index=False)
print(recessions.head())
