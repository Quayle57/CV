# CV

My resume as a one-page A4 PDF, in French and English, with the same terminal look as
[nicolas.dinquel.fr](https://nicolas.dinquel.fr).

- [nicolas-dinquel-cv-fr.pdf](nicolas-dinquel-cv-fr.pdf)
- [nicolas-dinquel-cv-en.pdf](nicolas-dinquel-cv-en.pdf)

## How it works

All content lives in [`cv.yaml`](cv.yaml). `render.py` picks one language, escapes LaTeX
special characters and fills [`templates/cv.tex.j2`](templates/cv.tex.j2). XeLaTeX then
compiles it with [`terminal-cv.cls`](terminal-cv.cls), which holds the whole look (fonts,
colours, terminal window, entries, tags). The fonts (Noto Sans, Hack) are in `fonts/`, so
the build doesn't depend on what's installed.

## Requirements

- TeX Live with XeLaTeX and latexmk (`texlive-scheme-medium` or `texlive-full`)
- poppler-utils (`pdfinfo`, `pdftotext`, `pdffonts`) for `make check`
- Python 3; `make` creates a local `.venv` from `requirements.txt` on first run

## Commands

| Command | What it does |
|---|---|
| `make` | Builds both PDFs |
| `make fr` / `make en` | Builds one language |
| `make check` | Builds, then checks each PDF: one A4 page, contact details extractable as text, only the vendored fonts, no text overflowing its box |
| `make test` | Runs the Python tests (renderer and `cv.yaml` schema) |
| `make clean` | Removes `build/` (the PDFs stay) |

## Editing the content

In `cv.yaml`, a value that differs between languages is a `{fr: …, en: …}` map; anything
else (names, URLs, tech tags) is shared. Write plain text: no LaTeX, `&`, `%`, `#`, `~`
are escaped for you. A map missing one of the two languages fails the build.

The CV must stay on **one page** in both languages. `make check` fails otherwise; trim
wording in `cv.yaml` rather than shrinking the fonts.
