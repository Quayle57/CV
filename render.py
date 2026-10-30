"""Render cv.yaml into a LaTeX file for one language."""

import argparse
from pathlib import Path
from typing import Any

import jinja2
import yaml

LANGS: tuple[str, ...] = ("fr", "en")

_LATEX_SPECIALS = {
    "\\": r"\textbackslash{}",
    "&": r"\&",
    "%": r"\%",
    "$": r"\$",
    "#": r"\#",
    "_": r"\_",
    "{": r"\{",
    "}": r"\}",
    "~": r"\textasciitilde{}",
    "^": r"\textasciicircum{}",
}


def localize(data: Any, lang: str, path: str = "") -> Any:
    """Replace every {fr: ..., en: ...} map with its value for `lang`."""
    if isinstance(data, dict):
        keys = set(data)
        if keys & set(LANGS):
            # Any map with a language key is a translation: exactly fr + en, both non-empty text.
            if keys != set(LANGS):
                raise KeyError(f"{path or '<root>'}: translation must have exactly the keys "
                               f"{', '.join(LANGS)}, got {', '.join(sorted(map(str, keys)))}")
            empty = [k for k in LANGS if not isinstance(data[k], str) or not data[k].strip()]
            if empty:
                raise KeyError(f"{path or '<root>'}: empty translation for {', '.join(empty)}")
            return data[lang]
        return {k: localize(v, lang, f"{path}.{k}" if path else k) for k, v in data.items()}
    if isinstance(data, list):
        return [localize(v, lang, f"{path}[{i}]") for i, v in enumerate(data)]
    return data


def latex_escape(value: Any) -> str:
    if value is None or isinstance(value, (dict, list)):
        raise TypeError(f"cannot render {type(value).__name__} as text: {value!r}")
    return "".join(_LATEX_SPECIALS.get(c, c) for c in str(value))


def date_range(start: int | str, end: int | str | None = None) -> str:
    if end is None:
        return f"[{start}]"
    return f"[{start} → {end}]"


def make_env(template_dir: Path) -> jinja2.Environment:
    env = jinja2.Environment(
        loader=jinja2.FileSystemLoader(template_dir),
        block_start_string="((*",
        block_end_string="*))",
        variable_start_string="(((",
        variable_end_string=")))",
        comment_start_string="((=",
        comment_end_string="=))",
        finalize=latex_escape,
        undefined=jinja2.StrictUndefined,
        trim_blocks=True,
        lstrip_blocks=True,
        keep_trailing_newline=True,
    )
    env.filters["daterange"] = date_range
    return env


def render(cv_path: Path, template_path: Path, lang: str) -> str:
    data = localize(yaml.safe_load(Path(cv_path).read_text(encoding="utf-8")), lang)
    template = make_env(Path(template_path).parent).get_template(Path(template_path).name)
    return template.render(**data, lang=lang)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lang", choices=LANGS, required=True)
    parser.add_argument("--cv", type=Path, default=Path("cv.yaml"))
    parser.add_argument("--template", type=Path, default=Path("templates/cv.tex.j2"))
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(render(args.cv, args.template, args.lang), encoding="utf-8")


if __name__ == "__main__":
    main()
