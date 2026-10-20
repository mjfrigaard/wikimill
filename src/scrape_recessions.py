"""Scrape the recessions table. Run from the project root: python src/scrape_recessions.py"""
import io
import pandas as pd
import requests

url = "https://en.wikipedia.org/wiki/List_of_recessions_in_the_United_States"
html = requests.get(url, headers={"User-Agent": "wikimill-project/0.1"}).text

tables = pd.read_html(io.StringIO(html), match="GDP decline")
recessions = tables[0]
recessions.columns = [
    "name", "period_range", "duration", "time_since_previous",
    "peak_unemployment", "gdp_decline", "characteristics"
]
recessions.to_csv("data/recessions.csv", index=False)
print(recessions.head())
