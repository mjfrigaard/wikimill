# wikimill

A small Quarto website that scrapes Wikipedia "List of" pages and categories, then cleans and visualizes the data. Two themes: topics that shaped the millennial generation (recessions, wage stagnation, platforms that came and went) and Y2K-era internet nostalgia (early browsers, worms, instant messengers).

Live site: https://mjfrigaard.github.io/wikimill/

## Structure

* `table_sources.qmd`: overview of Wikipedia pages scraped directly with `pandas.read_html()`.
* `list_sources.qmd`: overview of Wikipedia bulleted lists and categories, scraped through the MediaWiki API.
* `scrape_*.qmd`: the Python scraping code for each topic (`recessions`, `minimum_wage`, `dating`, `malls`).
* `clean_*.qmd`: the R/dplyr cleaning steps for each topic.
* `viz_*.qmd`: the `ggplot2` visualizations, built on the cleaned CSVs.
* `src/`: standalone Python and R scripts that duplicate the scraping, cleaning, and visualization code in the `.qmd` files. The chunks in `scrape_*.qmd` are set to `eval: false`, so rendering the site never hits Wikipedia. Run the scripts in `src/` from the project root to refresh `data/`.
* `data/`: cached CSVs (raw and cleaned) and figure PNGs, checked in so the site builds without network access.

## Scraping method

Pages with a clean HTML table are scraped with `pandas.read_html()`. Pages that are bulleted lists or categories have no table to parse, so those go through the MediaWiki API's `categorymembers` endpoint instead, with pagination handled via `cmcontinue`.

## Local development

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

Rscript -e 'renv::restore()'

quarto preview
```

`reticulate` is pointed at `.venv` via `.Rprofile`, so `{python}` and `{r}` chunks run in the same document.

To refresh the scraped data:

```bash
source .venv/bin/activate
python src/scrape_recessions.py
python src/scrape_minimum_wage.py
python src/scrape_dating.py
python src/scrape_malls.py
deactivate

Rscript src/clean_recessions.R
Rscript src/clean_minimum_wage.R
Rscript src/clean_dating.R
Rscript src/clean_malls.R
```

## Deployment

`.github/workflows/publish.yml` renders the site and deploys it to GitHub Pages via `actions/deploy-pages` on every push to `main`. The repo's Pages source is set to "GitHub Actions," not a `gh-pages` branch.
