#!/usr/bin/env bash
# Check one built CV: one A4 page, extractable contact details, only vendored fonts, clean log.
# Usage: scripts/check-pdf.sh fr|en
set -uo pipefail

lang=${1:?usage: $0 fr|en}
pdf=nicolas-dinquel-cv-$lang.pdf
log=build/cv-$lang.log
fail=0
err() { echo "check-pdf [$lang]: $*" >&2; fail=1; }

[[ -f $pdf ]] || { echo "check-pdf [$lang]: $pdf not found" >&2; exit 1; }
[[ -f $log ]] || { echo "check-pdf [$lang]: $log not found" >&2; exit 1; }

info=$(pdfinfo "$pdf")
pages=$(awk '/^Pages:/ {print $2}' <<<"$info")
[[ $pages == 1 ]] || err "expected 1 page, got $pages"
awk '/^Page size:/ { if (($3 < 594.28 || $3 > 596.28) || ($5 < 840.89 || $5 > 842.89)) exit 1 }' <<<"$info" \
  || err "page is not A4: $(grep '^Page size:' <<<"$info")"

text=$(pdftotext -layout "$pdf" -)
expected=(nicolas.dinquel+cv@gmail.com linkedin.com/in/dinquel nicolas.dinquel.fr Nicolas Dinquel Yupeek whoami)
case $lang in
  fr) expected+=(Expérience Formation) ;;
  en) expected+=(Experience Education) ;;
esac
for needle in "${expected[@]}"; do
  grep -qF -- "$needle" <<<"$text" || err "text not extractable: '$needle'"
done

stray=$(pdffonts "$pdf" | tail -n +3 | awk '{print $1}' | sed 's/^[A-Z]\{6\}+//' | grep -vE '^(NotoSans|Hack)-' || true)
[[ -z $stray ]] || err "unexpected fonts: $(tr '\n' ' ' <<<"$stray")"

overfull=$(grep -oE 'Overfull \\hbox \(([0-9.]+)pt too wide\)' "$log" | grep -oE '[0-9.]+' | awk '$1 > 1' || true)
[[ -z $overfull ]] || err "overfull hbox wider than 1pt: $(tr '\n' ' ' <<<"$overfull")pt"
grep -q 'Missing character' "$log" && err "missing glyphs: $(grep -m3 'Missing character' "$log")"

[[ $fail == 0 ]] && echo "check-pdf [$lang]: OK"
exit $fail
