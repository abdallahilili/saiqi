#!/usr/bin/env bash
# Outil de DÉVELOPPEMENT uniquement (jamais utilisé au build) :
# copie le socle commun de apps/saiqi_driver (lib/core, test/core, l10n.yaml) vers saiqi_client et saiqi_admin
# pour garder les trois copies alignées. Chaque app reste 100 % autonome : le résultat est commité dans chaque app.
#
# Source de vérité des textes : scripts/l10n/strings/*.mjs  ->  node scripts/l10n/generate.mjs
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/apps/saiqi_driver"

node "$ROOT/scripts/l10n/generate.mjs"
(cd "$SRC" && flutter gen-l10n >/dev/null 2>&1 || true)

for app in saiqi_client saiqi_admin; do
  DST="$ROOT/apps/$app"
  rm -rf "$DST/lib/core" "$DST/test/core"
  mkdir -p "$DST/lib/core" "$DST/test/core"
  cp -R "$SRC/lib/core/." "$DST/lib/core/"
  cp "$SRC/l10n.yaml" "$DST/l10n.yaml"
  if [ -d "$SRC/test/core" ]; then
    cp -R "$SRC/test/core/." "$DST/test/core/"
    # les tests importent le package de l'app : on l'adapte
    find "$DST/test/core" -name '*.dart' -exec sed -i "s/package:saiqi_driver\//package:$app\//g" {} +
  fi
  echo "core synchronisé -> apps/$app"
done
echo "OK"
