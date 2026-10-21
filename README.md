# wikimill

wikimill is a small Quarto website that scrapes Wikipedia "List of" pages and categories, then cleans and visualizes the data. It covers two themes: topics that shaped the millennial generation (recessions, wage stagnation, platforms that came and went) and Y2K-era internet nostalgia (early browsers, worms, instant messengers).

Live site: https://mjfrigaard.github.io/wikimill/

## Structure

* `table_sources.qmd`: overview of Wikipedia pages scraped directly with `rvest::html_table()` or `pandas.read_html()`.
* `list_sources.qmd`: overview of Wikipedia bulleted lists and categories, scraped through the MediaWiki API.
* `scrape_*.qmd`: the R (`httr2`, `rvest`) and Python (`requests`, `pandas`) scraping code for each topic (`recessions`, `minimum_wage`, `dating`, `malls`, `social`), in tabs.
* `clean_*.qmd`: the R (`dplyr`) and Python (`pandas`) cleaning steps for each topic, in tabs. Callouts note where one language has the edge.
* `viz_*.qmd`: the `ggplot2` visualizations, built on the cleaned CSVs.
* `src/`: standalone R and Python scripts (`scrape_*.R`/`.py`, `clean_*.R`/`.py`, `viz_*.R`) that duplicate the scraping, cleaning, and visualization code in the `.qmd` files. The chunks in `scrape_*.qmd` are set to `eval: false`, so rendering the site never hits Wikipedia. Run the scripts in `src/` from the project root to refresh `data/`.
* `data/`: cached CSVs (raw and cleaned), checked in so the site builds without network access.
* `img/`: figure PNGs saved by the `src/viz_*.R` scripts.

## Scraping method

Pages with a clean HTML table are scraped with `rvest::html_table()` or `pandas.read_html()`. Pages that are bulleted lists or categories have no table to parse, so those go through the MediaWiki API's `categorymembers` endpoint instead, with pagination handled via `cmcontinue` (`httr2::iterate_with_cursor()` in R, a `while` loop in Python).

## Local development

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

Rscript -e 'renv::restore()'

quarto preview
```

`reticulate` is pointed at `.venv` via `.Rprofile`, so `{python}` and `{r}` chunks run in the same document.

To refresh the scraped data in R:

```bash
for t in recessions minimum_wage dating malls social; do
  Rscript src/scrape_$t.R
  Rscript src/clean_$t.R
done
```

Or in Python:

```bash
source .venv/bin/activate
for t in recessions minimum_wage dating malls social; do
  python src/scrape_$t.py
  python src/clean_$t.py
done
deactivate
```

Both produce the same cleaned CSVs.

## Deployment

`.github/workflows/publish.yml` renders the site and deploys it to GitHub Pages via `actions/deploy-pages` on every push to `main`. The repo's Pages source is set to "GitHub Actions," not a `gh-pages` branch.
