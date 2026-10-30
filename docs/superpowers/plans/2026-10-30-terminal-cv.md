# Terminal-style CV Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the 2018 Friggeri CV with a one-page, terminal-styled A4 CV built in French and English from a single `cv.yaml`.

**Architecture:** `cv.yaml` holds all content; strings that differ per language are `{fr: …, en: …}` maps. `render.py` (PyYAML + Jinja2) resolves one language, LaTeX-escapes every value, and renders `templates/cv.tex.j2` to `build/cv-<lang>.tex`. That file uses macros from `terminal-cv.cls` (fonts, colours, the terminal window, entries, tags), and XeLaTeX compiles it to a PDF. The class owns the *look*; the template only maps data onto macros.

**Tech Stack:** Python 3 (pyenv, local `.venv`), PyYAML, Jinja2, pytest · XeLaTeX via latexmk, fontspec, tcolorbox, xcolor, hyperref · poppler-utils (`pdfinfo`, `pdftotext`, `pdftoppm`) for checks · GNU make.

**Spec:** `docs/superpowers/specs/2026-10-30-terminal-cv-design.md` — read it before starting any task. The approved mockup is the **"Fit to content"** card in `.superpowers/brainstorm/123524-1793372431/content/sidebar-window-v2.html` (open it in a browser to compare).

## Global Constraints

- Exactly **1 A4 page** per language. Page limit beats completeness.
- Outputs: `nicolas-dinquel-cv-fr.pdf`, `nicolas-dinquel-cv-en.pdf` at the repo root, **committed**.
- Fonts: **Noto Sans** (sans) and **Hack** (mono), vendored in `fonts/` and loaded by path. Never rely on system font lookup at compile time.
- Colours: accent `#0b7a5c`, text `#232629`, muted `#5f6772`, border `#cdd0d4`, title bar `#f3f4f6`, dots `#ff5f56` / `#ffbd2e` / `#27c93f`.
- Engine: XeLaTeX. No biblatex/biber.
- No LaTeX markup inside `cv.yaml`; all escaping happens in `render.py`.
- Terminal command strings (`whoami`, `cat contact`, `ls skills/back`, `locale`, `ls ~/homelab`) are identical in both languages; only outputs and `#` comments are translated. Date ranges are `[2016 → now]` in both languages.
- EN wording comes from https://nicolas.dinquel.fr/en/, FR from https://nicolas.dinquel.fr. Don't translate them yourself.
- Work on branch `terminal-cv`. Do not push (GitHub SSH auth is currently broken on this machine).

## Review Focus

1. **LaTeX special characters in content:** `+` and `.` in the email, `#` in comments, `&`, `%`, `_`, `~` (in `~/homelab`), `→`, French accents and `'` must render literally, not break compilation → `test_latex_escape_specials` (Task 1), `test_render_escapes_all_values` (Task 1).
2. **English running longer than French and spilling onto page 2** → `make check` asserts `Pages: 1` for *both* PDFs (Task 3).
3. **Long tokens overflowing the narrow window** (`nicolas.dinquel+cv@gmail.com`, `linkedin.com/in/dinquel`, skill lists) → `make check` fails on any `Overfull \hbox` wider than 1pt in either log (Task 3).
4. **Copy-paste/ATS extraction of contact details** (hyphenation or ligatures breaking the email/URL) → `make check` greps `pdftotext` output for the exact email, `linkedin.com/in/dinquel` and `nicolas.dinquel.fr` (Task 3).
5. **A half-translated YAML entry** (`{fr: …}` with no `en`) silently rendering as a dict or empty string → `test_localize_missing_language_raises` (Task 1) and `test_cv_yaml_fully_translated` (Task 2).

---

### Task 1: Renderer core

**Files:**
- Create: `render.py`, `pyproject.toml` (pytest config only), `tests/test_render.py`, `tests/fixtures/mini.yaml`, `tests/fixtures/mini.tex.j2`, `tests/fixtures/broken.tex.j2`, `requirements.txt`, `.gitignore`, `Makefile` (new; replaces the old one entirely)
- Commit first: `docs/superpowers/specs/2026-10-30-terminal-cv-design.md`, `docs/superpowers/plans/2026-10-30-terminal-cv.md`

**Interfaces:**
- Produces (in `render.py`):
  - `LANGS: tuple[str, ...] = ("fr", "en")`
  - `localize(data: Any, lang: str, path: str = "") -> Any` — recursively replaces every dict whose key set is exactly `{"fr", "en"}` with its `lang` value. Lists and other dicts are walked; scalars returned unchanged. A dict whose keys are a non-empty subset of `LANGS` but not both raises `KeyError` naming `path` (e.g. `experience[0].bullets[2]`).
  - `latex_escape(value: Any) -> str` — `None` → `""`; otherwise `str(value)` with `\ & % $ # _ { } ~ ^` escaped (`\textbackslash{}`, `\&`, `\%`, `\$`, `\#`, `\_`, `\{`, `\}`, `\textasciitilde{}`, `\textasciicircum{}`). Backslash first.
  - `date_range(start: int | str, end: int | str | None = None) -> str` — `(2016, "now")` → `"[2016 → now]"`, `(2015, 2016)` → `"[2015 → 2016]"`, `(2019)` / `(2019, None)` → `"[2019]"`.
  - `make_env(template_dir: Path) -> jinja2.Environment` — delimiters: block `((*` `*))`, variable `(((` `)))`, comment `((=` `=))`; `finalize=latex_escape`; `undefined=jinja2.StrictUndefined`; `trim_blocks=True`, `lstrip_blocks=True`; filter `daterange` = `date_range`.
  - `render(cv_path: Path, template_path: Path, lang: str) -> str`
  - CLI: `python render.py --lang {fr,en} --cv cv.yaml --template templates/cv.tex.j2 --out build/cv-<lang>.tex` (creates the parent dir).
- Produces (Makefile): `make test` runs pytest inside `.venv`; `.venv` target creates the venv from `requirements.txt` with `python3 -m venv`.

- [ ] **Step 1: Branch and commit the spec and plan**

```bash
git switch -c terminal-cv
git add docs/superpowers/specs/2026-10-30-terminal-cv-design.md docs/superpowers/plans/2026-10-30-terminal-cv.md
git commit -m "docs: terminal CV design and plan"
```

- [ ] **Step 2: Add `requirements.txt`, `.gitignore`, minimal `Makefile` with `.venv` and `test` targets**

`requirements.txt`: `PyYAML`, `Jinja2`, `pytest` (pinned to current versions). `.gitignore`: LaTeX aux files (`*.aux *.log *.out *.fls *.fdb_latexmk *.xdv *.synctex.gz *.bbl *.bcf *.blg *.run.xml`), `build/`, `.venv/`, `__pycache__/`, `.pytest_cache/`, `.superpowers/`. Don't ignore `*.pdf` (outputs are committed).

Run: `make test`
Expected: venv is created, pytest runs, "no tests ran" (exit 5 is fine at this step).

- [ ] **Step 3: Write failing tests in `tests/test_render.py`**

```python
from pathlib import Path
import pytest
from render import localize, latex_escape, date_range, render

FIX = Path(__file__).parent / "fixtures"

def test_localize_picks_language_recursively():
    data = {"title": {"fr": "Formation", "en": "Education"},
            "items": [{"t": {"fr": "a", "en": "b"}}, "plain"], "year": 2016}
    assert localize(data, "en") == {"title": "Education", "items": [{"t": "b"}, "plain"], "year": 2016}

def test_localize_missing_language_raises():
    with pytest.raises(KeyError, match=r"experience\[0\]\.bullets\[1\]"):
        localize({"experience": [{"bullets": [{"fr": "x", "en": "y"}, {"fr": "seul"}]}]}, "en")

def test_latex_escape_specials():
    assert latex_escape("a&b%c$d#e_f{g}h~i^j\\k") == \
        r"a\&b\%c\$d\#e\_f\{g\}h\textasciitilde{}i\textasciicircum{}j\textbackslash{}k"
    assert latex_escape("nicolas.dinquel+cv@gmail.com") == "nicolas.dinquel+cv@gmail.com"
    assert latex_escape("Expérience → d'Epitech") == "Expérience → d'Epitech"
    assert latex_escape(None) == ""

def test_date_range():
    assert date_range(2016, "now") == "[2016 → now]"
    assert date_range(2015, 2016) == "[2015 → 2016]"
    assert date_range(2019) == "[2019]"

def test_render_escapes_all_values():
    out = render(FIX / "mini.yaml", FIX / "mini.tex.j2", "fr")
    assert r"R\&D 100\% \#1" in out
    assert r"\textasciitilde{}/homelab" in out
    assert "[2016 → now]" in out
    assert "{'fr'" not in out and "(((" not in out

def test_render_unknown_variable_fails():
    with pytest.raises(Exception):
        render(FIX / "mini.yaml", FIX / "broken.tex.j2", "fr")
```

Fixtures: `mini.yaml` with `title: {fr: "R&D 100% #1", en: "…"}`, `path: "~/homelab"`, `start: 2016`, `end: now`; `mini.tex.j2` emitting `\section{((( title )))} ((( path ))) ((( start | daterange(end) )))`; `broken.tex.j2` referencing `((( nope )))`.

- [ ] **Step 4: Run tests and verify they fail**

Run: `make test`
Expected: FAIL with `ModuleNotFoundError: No module named 'render'`.

- [ ] **Step 5: Implement `render.py` per the Interfaces block**

`render()` = `yaml.safe_load` → `localize` → `make_env(template.parent).get_template(template.name).render(**data, lang=lang)`. Put the repo root on `pythonpath` via `pytest.ini`/`pyproject` `[tool.pytest.ini_options] pythonpath = ["."]`.

- [ ] **Step 6: Run tests and verify they pass**

Run: `make test`
Expected: 6 passed.

- [ ] **Step 7: Commit**

```bash
git add render.py tests/ requirements.txt .gitignore Makefile pyproject.toml
git commit -m "feat: YAML to LaTeX renderer with per-language localisation"
```

---

### Task 2: Content in `cv.yaml`

**Files:**
- Create: `cv.yaml`, `tests/test_cv_yaml.py`

**Interfaces:**
- Consumes: `localize`, `LANGS` from Task 1.
- Produces: the schema Task 3's template reads. Values marked *T* are `{fr, en}` maps; others are plain.

```yaml
name: {first: Nicolas, last: Dinquel}
title: T                       # Lead développeur Full-stack / Lead Full-stack Developer
location: Metz, France         # T if the EN site differs
contact: {email: nicolas.dinquel+cv@gmail.com, website: nicolas.dinquel.fr, linkedin: linkedin.com/in/dinquel}
summary: T
labels: {experience: T, education: T}
skills:                        # order = display order
  - {group: back,  items: [python, django, drf, celery, nestjs, php]}
  - {group: front, items: [...]}
  - {group: data,  items: [...]}
  - {group: ops,   items: [...]}
languages:
  - {locale: fr_FR, level: T}  # natif / native
  - {locale: en_US, level: T}  # courant / fluent
homelab: [gitea, docker, home-assistant]
experience:
  - {role: T, company: Yupeek, meta: T, start: 2016, end: now, bullets: [T, ...], tags: [...]}
  - {role: T, company: Etix Everywhere, meta: T, start: 2015, end: 2016, bullets: [T], tags: [angularjs, es6, docker, gulp]}
education:
  - {title: T, meta: T, start: 2011, end: 2016}   # Epitech
  - {title: T, meta: T, start: 2014, end: 2015}   # Keimyung University
  - {title: T, meta: T, start: 2019}              # GOBELINS
```

- [ ] **Step 1: Write failing tests in `tests/test_cv_yaml.py`**

```python
def test_cv_yaml_fully_translated():          # localize(cv, lang) succeeds for every lang in LANGS
def test_cv_yaml_has_required_sections():     # keys above present; experience[0].company == "Yupeek"; end == "now"
def test_cv_yaml_contact_exact():             # email/website/linkedin equal the exact strings above
def test_cv_yaml_has_no_latex():              # no "\\" in any string after localize, for both langs
def test_cv_yaml_skill_items_lowercase():     # every skills[*].items entry == entry.lower(); groups == ["back","front","data","ops"]
```

- [ ] **Step 2: Run tests and verify they fail**

Run: `make test`
Expected: FAIL with `FileNotFoundError` for `cv.yaml`.

- [ ] **Step 3: Write `cv.yaml`**

Fetch both site pages (`curl -sL https://nicolas.dinquel.fr` and `…/en/`; the text is in the HTML) and fill in the schema with the site's wording, condensed per spec §Content: Yupeek 4–5 bullets (products / modernisation / ERP / DevOps+AI, mention earlier internships 2012 & 2014 in `meta` or a bullet), Etix "stage"/"internship" in `meta`. The summary is written in the first person or neutrally, never "Il travaille…".

- [ ] **Step 4: Run tests and verify they pass**

Run: `make test`
Expected: all pass.

- [ ] **Step 5: Commit**

```bash
git add cv.yaml tests/test_cv_yaml.py
git commit -m "feat: bilingual CV content from nicolas.dinquel.fr"
```

---

### Task 3: Class, template, fonts and PDF build

**Files:**
- Create: `terminal-cv.cls`, `templates/cv.tex.j2`, `fonts/` (TTFs + licences), `scripts/check-pdf.sh`
- Modify: `Makefile` (add build/check targets)

**Interfaces:**
- Consumes: CLI from Task 1, schema from Task 2.
- Produces (`terminal-cv.cls`, the macros the template uses):
  - Class option: none. Loads fonts from `\cvfontdir` (set in the template preamble *before* `\documentclass` via `\def\cvfontdir{../fonts/}`; build dir is `build/`).
  - `\begin{cvwindow}{<title bar text>} … \end{cvwindow}` — tcolorbox: white, `border` 0.4pt, ~2pt radius, title bar `#f3f4f6` with three 4–5 pt dots then muted mono title; natural height (fits content).
  - `\cvcmd{<command>}` — new line: accent `$`, space, command, in mono.
  - `\cvname{<first>}{<last>}` — two-line large bold Noto Sans name + accent mono `_`.
  - `\cvout{<text>}` — mono output line; `\cvcomment{<text>}` — muted `# text`.
  - `\cvlink{<url-without-scheme>}{<display>}` — clickable `https://` link, display text unbreakable (use `\mbox`/`\nolinkurl`, never hyphenated).
  - `\cvmail{<address>}` — `mailto:` link, same unbreakable rule.
  - `\cvprompt` — final `$ █` with accent block cursor.
  - `\cvsection{<title>}` — mono, accent `#`, then title.
  - `\cventry{<role — company>}{<daterange>}{<meta>}` — bold left, muted mono date right-aligned on the same line, muted meta line below.
  - `\cvtags{\cvtag{a}\cvtag{b}…}` — small mono tags with `#cdd0d4` border, wrapping.
  - `\cvsummary{<text>}`.
  - Two-column layout: `\cvsidewidth` = 0.29\textwidth, gap ≈ 10 mm, both columns top-aligned.
- Produces (Makefile): `make` / `make all` → both root PDFs; `make fr`, `make en`; `make check`; `make clean` (removes `build/`, keeps PDFs); `make test`.

- [ ] **Step 1: Vendor fonts**

Copy from the system (already installed): `/usr/share/fonts/google-noto/NotoSans-{Regular,Italic,Bold,SemiBold}.ttf` and `/usr/share/fonts/source-foundry-hack-fonts/Hack-{Regular,Bold}.ttf` into `fonts/`, plus their licence texts (`OFL.txt` for Noto; Hack's `LICENSE.md` — find via `rpm -ql google-noto-sans-fonts source-foundry-hack-fonts | grep -i licen`, or the upstream repos).

- [ ] **Step 2: Write `scripts/check-pdf.sh <lang>` (the failing check)**

For `nicolas-dinquel-cv-<lang>.pdf` and `build/cv-<lang>.log`, exit non-zero with a clear message if:
- `pdfinfo` reports anything other than `Pages: 1`, or the page size isn't A4 (`595.28 x 841.89 pts`, ±1);
- `pdftotext -layout` output lacks any of: `nicolas.dinquel+cv@gmail.com`, `linkedin.com/in/dinquel`, `nicolas.dinquel.fr`, `Nicolas`, `Dinquel`, `Yupeek`, `whoami`; and, per language, `Expérience` + `Formation` (fr) or `Experience` + `Education` (en);
- `pdffonts` lists any font other than NotoSans* / Hack* (catches fallback fonts);
- the log contains `Overfull \hbox (` with a width > 1pt, or `Missing character`.

Wire `make check: all` to run it for both languages.

Run: `make check`
Expected: FAIL (no PDF exists yet).

- [ ] **Step 3: Implement `terminal-cv.cls`, `templates/cv.tex.j2`, and the Makefile build rules**

Rule: `build/cv-%.tex` ← `cv.yaml templates/cv.tex.j2 render.py .venv`; `nicolas-dinquel-cv-%.pdf` ← `build/cv-%.tex terminal-cv.cls fonts/*` via `latexmk -xelatex -cd -interaction=nonstopmode -halt-on-error build/cv-%.tex`, then copy `build/cv-%.pdf` to the root name. Template sets `\hypersetup{pdftitle={<name> — <title>}, pdfauthor={Nicolas Dinquel}, pdflang={fr-FR|en-US}}` and `\setmainlanguage` via polyglossia (or the babel equivalent) so FR hyphenation applies. The sidebar contents and order are spec §Look (left column) items 1–6. The main column contains summary, `\cvsection{labels.experience}` entries with bullets and tags, then `\cvsection{labels.education}` entries.

- [ ] **Step 4: Build and run the check**

Run: `make clean && make && make check`
Expected: both PDFs are built and `check-pdf.sh` passes for fr and en. If a page overflows, cut bullet wording or minor skills in `cv.yaml` (spec: the page limit beats completeness) rather than shrinking fonts below ~8.5pt body / ~7pt window.

- [ ] **Step 5: Visual comparison with the mockup**

Run: `pdftoppm -png -r 80 nicolas-dinquel-cv-fr.pdf build/preview-fr` (and the same for en), then view the PNGs next to the "Fit to content" mockup.
Expected: same hierarchy. The window is ~29% wide, ends after `$ █` with white below; the name is the most prominent element; dates are right-aligned; tags sit under each job. Fix anything that diverges.

- [ ] **Step 6: Commit**

```bash
git add terminal-cv.cls templates/ fonts/ scripts/ Makefile cv.yaml nicolas-dinquel-cv-fr.pdf nicolas-dinquel-cv-en.pdf
git commit -m "feat: terminal-style CV class, template and bilingual PDF build"
```

---

### Task 4: Remove the old CV and document the build

**Files:**
- Delete: `friggeri-cv.cls`, `dtklogos.sty`, `placeholder.jpg`, `flags/`, `nicolas-dinquel-cv.tex`, and the untracked `nicolas-dinquel-cv.{aux,bbl,bcf,blg,log,out,pdf,run.xml}`
- Modify: `README.md`

**Interfaces:**
- Consumes: Makefile targets from Tasks 1 and 3.

- [ ] **Step 1: Delete the old files**

`git rm` the tracked ones; `rm` the untracked build leftovers listed above (look at `git status` first; delete nothing else).

- [ ] **Step 2: Rewrite `README.md`**

Cover: what it is (FR/EN terminal-style CV from `cv.yaml`), requirements (TeX Live with XeLaTeX + latexmk, poppler-utils, Python 3), `make` / `make fr` / `make en` / `make check` / `make test` / `make clean`, how to edit content (`{fr:, en:}` maps, plain strings for shared values), and the one-page rule.

- [ ] **Step 3: Verify from a clean state**

Run: `git status --short` (only intended changes), then `make clean && rm -rf .venv && make && make check && make test`
Expected: everything passes from scratch; `git status` shows no stray generated files.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "chore: remove Friggeri CV, document new build"
```
(`git rm` in Step 1 already staged the deletions.)
