# Terminal-style CV — Design

Date: 2026-10-30
Repo: `Quayle57/CV` (this repo)

## Intent

The LaTeX CV in this repo stopped being updated around 2018, and the current
CV is now the one on https://nicolas.dinquel.fr. Nicolas wants the LaTeX version back and
better than the website's PDF export: a one-page A4 PDF that **a recruiter can
skim in 10 seconds but that keeps an identity**, the same Linux-terminal
identity as the website.

He also wants **French and English from a single source**, and that source
should be a structured data file (YAML) rather than LaTeX, so the website could
read it one day.

## Goals

- One A4 page per language: `nicolas-dinquel-cv-fr.pdf` and `nicolas-dinquel-cv-en.pdf`.
- Content comes from one YAML file in this repo, with FR/EN text side by side.
- Layout and visual style as approved in the mockups (see "Look" below).
- A single `make` builds both PDFs from a clean checkout.
- Up-to-date content taken from https://nicolas.dinquel.fr (FR and EN versions).

## Non-goals

- Connecting the website to the YAML. "For now" the source of truth is this
  repo; the format should not *prevent* the site from reading it later, but no
  site work happens here.
- Making the PDF match the site's dark theme.
- Multi-page / long-form CV variants.
- Fixing the GitHub SSH `Permission denied (publickey)` problem — separate issue.

## Anti-goals (would be a failure even if it compiles)

- Hard to skim: name, current role, and employer must be found in seconds.
- Gimmicky: terminal flavour stays an accent, the main column is normal prose.
- Spilling onto a second page in either language.
- FR and EN drifting: no content that exists in only one LaTeX file.
- Text that ATS / copy-paste can't extract (no text as images; avoid ligatures or
  glyph tricks that break copy-paste of the email address).

## Look (approved by Nicolas in the visual companion)

Mockup reference: `.superpowers/brainstorm/*/content/sidebar-window-v2.html`,
option **"Fit to content"**. These are browser mockups, not pixel specs; the
proportions and hierarchy matter, not exact point sizes.

**Page:** A4, white, margins ~14 mm, two columns separated by a ~10 mm gap.

**Left column — terminal window (≈29% of the text width):**
- Light window: white background, thin border, small rounded corners.
- Title bar: light grey fill, three small "traffic light" dots
  (red `#ff5f56`, amber `#ffbd2e`, green `#27c93f`), then the title
  `nicolas@dinquel: ~` in muted monospace.
- **Height fits its content**: the window ends after the last command; white
  page below it. It does not stretch to the bottom of the page.
- Contents are command/output pairs in monospace, prompt `$` in the accent colour:
  1. `$ whoami` → **name** in large bold sans-serif on two lines
     ("Nicolas" / "Dinquel") followed by an accent-coloured `_` cursor; then
     the job title in the accent colour.
  2. `$ cat contact` → city, website, LinkedIn, email (each on its own line,
     clickable links).
  3. `$ ls skills/back`, `skills/front`, `skills/data`, `skills/ops` →
     space-separated lowercase skill names.
  4. `$ locale` → `fr_FR  # natif` / `en_US  # courant` (comment in muted colour;
     comment text is translated).
  5. `$ ls ~/homelab` → `gitea docker home-assistant`.
  6. Final line: `$ █`, an accent-coloured block cursor.
- The command strings (`whoami`, `cat contact`, `ls skills/back`…) are the same
  in both languages; only the outputs and `#` comments are translated.

**Right column — main content (sans-serif):**
- Summary paragraph at the top (slightly larger than body text).
- Section headings in monospace: accent `#` then the title
  (`# Expérience` / `# Experience`, `# Formation` / `# Education`).
- Each entry: bold "Role — Company" on the left, monospace muted
  `[2016 → now]` / `[2015 → 2016]` right-aligned on the same line;
  a muted sub-line (e.g. "Groupe Menway · Metz"); short bullets; then a row of
  small monospace **tags** (thin grey border, small radius) listing the tech.
- Education entries: bold title + right-aligned date + one muted sub-line, no
  bullets or tags.
- `[2016 → now]`: "now" is kept in both languages (it's a terminal idiom).
  *(Designer's call; builder may switch to "aujourd'hui" if it looks wrong in FR.)*

**Typography & colour (taken from the website's light theme, `styles-*.css`):**
| Token | Value | Use |
|---|---|---|
| sans font | **Noto Sans** | body, name, headings' text |
| mono font | **Hack** | terminal window, section headings, dates, tags |
| accent | `#0b7a5c` | prompts `$`, `#`, cursors, job title in window |
| text | `#232629` | body |
| muted | `#5f6772` | dates, sub-lines, `#` comments, window title |
| border | `#cdd0d4` | window border, tag border |
| title bar fill | `#f3f4f6` (or site `--surface-2` `#dee0e2` if it reads better) | |

The mockups used Source Sans + JetBrains Mono and a slightly brighter green;
switching to the site's Noto Sans / Hack / `#0b7a5c` is the designer's call to
match the site and should not change the look meaningfully.

## Content

**Source:** https://nicolas.dinquel.fr (FR) and https://nicolas.dinquel.fr/en/
(EN). Both serve their text directly in the HTML. Use the English page's wording
for EN rather than translating from FR. Use the full FR summary from the site
(it is cut short below). As of 2026-10-30 the FR content is:

- Name: Nicolas Dinquel. Title: Lead développeur Full-stack. Location: Metz, France.
- Contact: `nicolas.dinquel+cv@gmail.com`, `linkedin.com/in/dinquel`, `nicolas.dinquel.fr`.
- Summary: "Développeur web depuis plus de dix ans, diplômé d'Epitech…" (from
  the site; write it in the first person or neutral, not "Il travaille…").
- Experience:
  - Lead développeur Full-stack, Yupeek (groupe Menway), Metz, 2016 → now
    (earlier internships there in 2012 and 2014 — mention in the sub-line or
    one bullet, don't list as separate entries). Products: ReservoirJobs
    (Django, Angular SSR), ReservoirJobs CFA, CVthèque (Elasticsearch), internal
    REST API, Recrut (DRF, Angular), WordPress plugin. Modernisation:
    AngularJS → Angular, 15 → 20; Django 2 → 4; jQuery → ES6 + Webpack; PHP 8.3
    ExtJS ERP tests & refactoring; front-end performance. DevOps & AI: Docker
    multi-stage, GitLab CI, Elasticsearch, Celery, AI-assisted development.
  - Développeur front-end, Etix Everywhere, Luxembourg, 2015 → 2016
    (year-only dates even though the site shows months; "stage"/internship
    goes in the muted sub-line, as in the mockup, not in the title).
    Front-end of a centralised technical management tool for data centres.
    Tags: AngularJS, ES6, Docker, Gulp.
- Education: Epitech, Expert en technologies de l'information, 2011–2016,
  Nancy & Paris · Keimyung University, year abroad, 2014–2015, Daegu, South
  Korea · GOBELINS, UX Design training (72 h), 2019, Paris.
- Skills: back: Python, Django, DRF, Celery, NestJS, PHP, WordPress · front:
  Angular, Vue.js, TypeScript, RxJS, Angular Material, SSR, HTML/SCSS, UX
  design · data: PostgreSQL, MySQL, Elasticsearch · ops: Docker, GitLab CI,
  nginx, Linux, Git, Claude Code.
- Languages: French native, English fluent.
- Homelab: Gitea, Docker, Home Assistant.

**Dropped from the old LaTeX CV:** age/driving licence, TOEIC score, IUT DUT,
Sailendra, Systemics Labs, separate Yupeek 2012/2014 entries, IDE/OS lists,
the flag images (`flags/`), the old LinkedIn URL and GitHub link.

**Editing for one page:** the full site content will probably not fit. The
builder condenses bullets (Yupeek ≈ 4–5 bullets, as in the mockup) and may
drop low-value skill items (e.g. Angular Material, Git) to fit. The page limit
wins over completeness.

## How it's built (decided)

- **Content:** `cv.yaml` at the repo root. Every human-language string is
  either a plain string (same in both languages: names, tech, URLs) or a map
  `{fr: …, en: …}`. Keep the schema simple and readable by a future
  TypeScript/Angular consumer (no YAML anchors/tags tricks, no LaTeX inside
  the YAML; the renderer escapes special characters).
- **Renderer:** a small Python script (Python is Nicolas's daily language)
  using PyYAML + Jinja2 that renders a LaTeX template once per language into
  `build/cv-<lang>.tex`. Use Jinja delimiters that don't clash with LaTeX
  (e.g. `\VAR{}` / `\BLOCK{}` style or `((* *))`).
- **LaTeX:** compiled with **XeLaTeX** (already the repo's engine; LuaLaTeX is
  acceptable if the builder has a concrete reason). `latexmk` is available.
  The window can be drawn with `tcolorbox` (installed); two columns with
  minipages or `paracol` (installed). No biblatex/biber (the old class pulled
  it in and it was erroring).
- **Fonts:** vendor Noto Sans and Hack (both OFL/MIT, freely redistributable)
  into `fonts/` and load them by file path with `fontspec`, so the build
  doesn't depend on installed system fonts. Locally only JetBrains Mono Nerd
  Font is installed system-wide; Source Sans Pro exists only as the TeX
  package.
- **Python deps:** `requirements.txt` (PyYAML, Jinja2). Jinja2 isn't
  installed globally; the Makefile creates/uses a local `.venv`. `uv` is not
  installed; pyenv is.
- **Makefile:** `make` → both PDFs; `make fr` / `make en`; `make clean`.
  Outputs: `nicolas-dinquel-cv-fr.pdf`, `nicolas-dinquel-cv-en.pdf` at the
  repo root (or `dist/`, builder's call).
- **Repo hygiene:** add a `.gitignore` covering LaTeX aux files, `build/`,
  `.venv/`, and `.superpowers/`. Delete the old `friggeri-cv.cls`,
  `dtklogos.sty`, `placeholder.jpg`, `flags/` and the old `.tex` once the new
  build works (they stay in git history). Update `README.md` with build
  instructions. Whether to commit the generated PDFs is the builder's call;
  leaning *yes* so the site can link to them.
- PDF metadata: title, author, language set per PDF (hyperref).

## Left to the builder

- Exact point sizes, spacings, and the YAML schema details.
- How to draw the dots/cursor (TikZ, tcolorbox title, or glyphs).
- How to enforce one page (e.g. a check in the Makefile that fails if
  `pdfinfo` reports more than one page is welcome but optional).
- Final wording cuts to fit one page.
