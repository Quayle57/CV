from pathlib import Path

import jinja2
import pytest

from render import date_range, latex_escape, localize, render

FIX = Path(__file__).parent / "fixtures"


def test_localize_picks_language_recursively():
    data = {
        "title": {"fr": "Formation", "en": "Education"},
        "items": [{"t": {"fr": "a", "en": "b"}}, "plain"],
        "year": 2016,
    }
    assert localize(data, "en") == {"title": "Education", "items": [{"t": "b"}, "plain"], "year": 2016}


def test_localize_missing_language_raises():
    with pytest.raises(KeyError, match=r"experience\[0\]\.bullets\[1\]"):
        localize({"experience": [{"bullets": [{"fr": "x", "en": "y"}, {"fr": "seul"}]}]}, "en")


def test_latex_escape_specials():
    assert latex_escape("a&b%c$d#e_f{g}h~i^j\\k") == (
        r"a\&b\%c\$d\#e\_f\{g\}h\textasciitilde{}i\textasciicircum{}j\textbackslash{}k"
    )
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
    with pytest.raises(jinja2.UndefinedError):
        render(FIX / "mini.yaml", FIX / "broken.tex.j2", "fr")
