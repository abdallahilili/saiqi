#!/usr/bin/env bash
# Outil de DÉVELOPPEMENT uniquement (jamais utilisé au build) :
# copie apps/saiqi_driver/lib/core/ vers saiqi_client et saiqi_admin pour garder les copies alignées.
# Chaque app reste 100 % autonome : le résultat de la copie est commité dans chaque app.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/apps/saiqi_driver/lib/core"
for app in saiqi_client saiqi_admin; do
  DST="$ROOT/apps/$app/lib/core"
  rm -rf "$DST"
  mkdir -p "$DST"
  cp -R "$SRC/." "$DST/"
  echo "core synchronisé -> apps/$app/lib/core"
done
# Fichiers de configuration communs
for app in saiqi_client saiqi_admin; do
  cp "$ROOT/apps/saiqi_driver/l10n.yaml" "$ROOT/apps/$app/l10n.yaml"
done
echo "OK"
