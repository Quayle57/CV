VENV   := .venv
PYTHON := $(VENV)/bin/python

.PHONY: test

$(VENV): requirements.txt
	python3 -m venv $(VENV)
	$(PYTHON) -m pip install -q -r requirements.txt
	touch $(VENV)

test: $(VENV)
	$(PYTHON) -m pytest -q
