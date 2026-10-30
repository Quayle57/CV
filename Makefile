VENV   := .venv
PYTHON := $(VENV)/bin/python

.PHONY: test

$(VENV): requirements.txt
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install -q -r requirements.txt
	touch $(VENV)

test: $(VENV)
	$(PYTHON) -m pytest -q

LANGUAGES := fr en
PDFS      := $(LANGUAGES:%=nicolas-dinquel-cv-%.pdf)
TEXS      := $(LANGUAGES:%=build/cv-%.tex)

# Reproducible PDFs: dates and IDs come from the last commit, not the clock,
# so rebuilding unchanged content leaves the committed PDFs untouched.
export SOURCE_DATE_EPOCH := $(or $(shell git log -1 --format=%ct 2>/dev/null),0)
export FORCE_SOURCE_DATE := 1

.PHONY: all fr en check clean
.DEFAULT_GOAL := all

all: $(PDFS)
fr: nicolas-dinquel-cv-fr.pdf
en: nicolas-dinquel-cv-en.pdf

# Static pattern rule: the .tex files are explicit targets, never intermediate,
# so they are regenerated after `make clean` even though the PDFs are committed.
$(TEXS): build/cv-%.tex: cv.yaml templates/cv.tex.j2 render.py | $(VENV)
	$(PYTHON) render.py --lang $* --out $@

nicolas-dinquel-cv-%.pdf: build/cv-%.tex terminal-cv.cls $(wildcard fonts/*.ttf) $(wildcard flags/*.png)
	TEXINPUTS=$(CURDIR): latexmk -xelatex -cd -interaction=nonstopmode -halt-on-error -silent $<
	cp build/cv-$*.pdf $@

check: all
	@for l in $(LANGUAGES); do scripts/check-pdf.sh $$l || exit 1; done

clean:
	rm -rf build
