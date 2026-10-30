from pathlib import Path

import pytest
import yaml

from render import LANGS, localize

CV = yaml.safe_load((Path(__file__).parent.parent / "cv.yaml").read_text(encoding="utf-8"))


def _strings(data):
    if isinstance(data, dict):
        for v in data.values():
            yield from _strings(v)
    elif isinstance(data, list):
        for v in data:
            yield from _strings(v)
    elif isinstance(data, str):
        yield data


@pytest.mark.parametrize("lang", LANGS)
def test_cv_yaml_fully_translated(lang):
    localize(CV, lang)


def test_cv_yaml_has_required_sections():
    for key in ("name", "title", "location", "contact", "summary", "labels",
                "skills", "languages", "homelab", "experience", "education"):
        assert key in CV, key
    assert CV["name"] == {"first": "Nicolas", "last": "Dinquel"}
    assert set(CV["labels"]) == {"experience", "education"}
    assert CV["experience"][0]["company"] == "Yupeek"
    assert CV["experience"][0]["end"] == "now"
    assert len(CV["education"]) == 3


def test_cv_yaml_contact_exact():
    assert CV["contact"] == {
        "email": "nicolas.dinquel+cv@gmail.com",
        "website": "nicolas.dinquel.fr",
        "linkedin": "linkedin.com/in/dinquel",
    }


@pytest.mark.parametrize("lang", LANGS)
def test_cv_yaml_has_no_latex(lang):
    for s in _strings(localize(CV, lang)):
        assert "\\" not in s, s


def test_cv_yaml_skill_items_lowercase():
    assert [g["group"] for g in CV["skills"]] == ["back", "front", "data", "ops"]
    for group in CV["skills"]:
        for item in group["items"]:
            assert item == item.lower(), item


def test_cv_yaml_flags_exist():
    root = Path(__file__).parent.parent
    entries = CV["experience"] + CV["education"]
    assert all("flag" in e for e in entries), "every entry shows its country flag"
    for e in entries:
        assert (root / "flags" / f"{e['flag']}.png").is_file(), e["flag"]
