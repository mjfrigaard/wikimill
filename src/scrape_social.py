"""Scrape the most popular social platforms table. Run from the project root: python src/scrape_social.py"""
import io
import pandas as pd
import requests

url = "https://en.wikipedia.org/wiki/List_of_most_popular_social_platforms"
html = requests.get(url, headers={"User-Agent": "wikimill-project/0.1"}).text

tables = pd.read_html(io.StringIO(html))
social = next(t for t in tables if "Country[b]" in t.columns and "No." not in t.columns)
social.columns = ["name", "company", "country", "launched", "monthly_active_users", "other_metrics"]
social.to_csv("data/social_platforms.csv", index=False)
print(social.head())
