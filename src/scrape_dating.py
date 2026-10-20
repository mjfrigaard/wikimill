"""Scrape the online dating services comparison table. Run from the project root: python src/scrape_dating.py"""
import io
import pandas as pd
import requests

url = "https://en.wikipedia.org/wiki/Comparison_of_online_dating_services"
html = requests.get(url, headers={"User-Agent": "wikimill-project/0.1"}).text

tables = pd.read_html(io.StringIO(html), match="Registered users")
dating = tables[0]
dating.columns = [
    "name", "description", "owner", "registered_users", "free",
    "all_features_free", "hetero", "poly", "free_messaging", "std_notification"
]
dating.to_csv("data/dating_services.csv", index=False)
print(dating.head())
