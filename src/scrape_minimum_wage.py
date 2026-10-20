"""Scrape the minimum wage table. Run from the project root: python src/scrape_minimum_wage.py"""
import io
import pandas as pd
import requests

wage_html = requests.get(
    "https://en.wikipedia.org/wiki/List_of_countries_by_minimum_wage",
    headers={"User-Agent": "wikimill-project/0.1"}
).text
tables = pd.read_html(io.StringIO(wage_html), match="Minimum wage")
wage = tables[0]
wage.columns = ["_".join(c for c in col if "Unnamed" not in c).strip("_")
                for col in wage.columns.to_flat_index()]
wage.to_csv("data/minimum_wage.csv", index=False)
print(wage.head())
