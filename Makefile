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

.PHONY: all fr en check clean
.NOTINTERMEDIATE: build/cv-%.tex
.DEFAULT_GOAL := all

all: $(PDFS)
fr: nicolas-dinquel-cv-fr.pdf
en: nicolas-dinquel-cv-en.pdf

build/cv-%.tex: cv.yaml templates/cv.tex.j2 render.py | $(VENV)
	$(PYTHON) render.py --lang $* --out $@

nicolas-dinquel-cv-%.pdf: build/cv-%.tex terminal-cv.cls $(wildcard fonts/*.ttf)
	TEXINPUTS=$(CURDIR): latexmk -xelatex -cd -interaction=nonstopmode -halt-on-error -silent $<
	cp build/cv-$*.pdf $@

check: all
	@for l in $(LANGUAGES); do scripts/check-pdf.sh $$l || exit 1; done

clean:
	rm -rf build
