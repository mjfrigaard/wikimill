"""Scrape the defunct malls category. Run from the project root: python src/scrape_malls.py"""
import pandas as pd
import requests

API = "https://en.wikipedia.org/w/api.php"


def fetch_category_members(category):
    params = {
        "action": "query", "list": "categorymembers",
        "cmtitle": f"Category:{category}", "cmlimit": 500,
        "format": "json"
    }
    members = []
    while True:
        resp = requests.get(API, params=params, headers={"User-Agent": "wikimill-project/0.1"}).json()
        members.extend(resp["query"]["categorymembers"])
        if "continue" not in resp:
            break
        params["cmcontinue"] = resp["continue"]["cmcontinue"]
    return pd.DataFrame(members)[["title"]]


if __name__ == "__main__":
    categories = {
        "Defunct_shopping_malls_in_the_United_States": "Defunct",
        "Demolished_shopping_malls_in_the_United_States": "Demolished",
        "Abandoned_shopping_malls_in_the_United_States": "Abandoned",
    }
    malls = pd.concat(
        [fetch_category_members(cat).assign(status=label) for cat, label in categories.items()],
        ignore_index=True
    )
    malls.to_csv("data/defunct_malls.csv", index=False)
    print(malls.head())
