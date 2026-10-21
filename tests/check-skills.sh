#!/usr/bin/env bash
# Test spójności skilli i workflow software house'u. Uruchamiany w CI i lokalnie:
#   bash tests/check-skills.sh
# Pilnuje reguł wspólnych, które łatwo zgubić przy edycji jednego skilla.
set -u
cd "$(dirname "$0")/.."
fail=0
err() { echo "BŁĄD: $*"; fail=1; }

# 1. Każdy skill ma reguły mktemp i --repo.
for f in skills/sh-*/SKILL.md; do
  grep -q 'mktemp' "$f" || err "$f: brak reguły plików z mktemp"
  grep -q -- '--repo' "$f" || err "$f: brak reguły jawnego --repo"
done

# 2. Żadne polecenie nie czeka dłużej niż limit narzędzia Bash (540 s w poleceniu).
if grep -nE 'timeout ([6-9][0-9]{2}|[0-9]{4,})\b' skills/*/SKILL.md; then
  err "polecenie z timeout dłuższym niż 540 s (narzędzie Bash przeniesie je w tło)"
fi

# 3. Role dostawy kończą się raportem z linią stanu, którą czytają węzły sh-delivery.
for pair in "sh-inzynier:STAN: GOTOWE" "sh-inzynier:STAN: STOP" \
            "sh-tester:WYNIK: PASS" "sh-tester:WYNIK: FAIL" "sh-tester:STAN: STOP" \
            "sh-reviewer:WERDYKT: APPROVE" "sh-reviewer:WERDYKT: CHANGES" "sh-reviewer:STAN: STOP"; do
  skill=${pair%%:*}; line=${pair#*:}
  grep -qF "$line" "skills/$skill/SKILL.md" || err "$skill: brak linii stanu „$line”"
  grep -qF "value: \"); $line\"" workflows/sh-delivery.yml || err "sh-delivery.yml: brak węzła dla „$line”"
done
for s in sh-inzynier sh-tester sh-reviewer; do
  grep -q 'task report' "skills/$s/SKILL.md" || err "$s: brak raportu cez task report"
  grep -q 'CEZ:DONE' "skills/$s/SKILL.md" || err "$s: brak CEZ:DONE"
  grep -q 'checkout --detach' "skills/$s/SKILL.md" || err "$s: brak pobierania gałęzi PR na odłączonym HEAD"
done

# 4. Workflow wskazuje istniejące skille.
for s in $(grep -ohE 'sh-[a-z]+' workflows/*.yml | sort -u); do
  case "$s" in sh-delivery|sh-sweep|sh-run|sh-notify|sh-control|sh-posprzatane|sh-skills) continue;; esac
  [ -f "skills/$s/SKILL.md" ] || err "workflow wskazuje nieistniejący skill $s"
done

# 5. Skrypty mają poprawną składnię.
for f in bin/*; do bash -n "$f" || err "$f: błąd składni"; done

# 6. Workflow są poprawnym YAML-em w wersji 2.
for f in workflows/*.yml; do
  python3 -c 'import sys,yaml; d=yaml.safe_load(open(sys.argv[1])); assert d.get("version")==2, "brak version: 2"' "$f" \
    || err "$f: niepoprawny YAML albo brak version: 2"
done

[ "$fail" = 0 ] && echo "OK: skille i workflow są spójne."
exit "$fail"
