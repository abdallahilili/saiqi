# SAIQI — commandes de développement (nécessite make ; sous Windows : Git Bash / WSL / choco install make)
SUPABASE ?= npx --yes supabase

.PHONY: db-start db-stop db-reset db-push db-check run-client run-driver run-admin test analyze sync-core

db-start:
	$(SUPABASE) start
db-stop:
	$(SUPABASE) stop
db-reset:
	$(SUPABASE) db reset
db-push:
	$(SUPABASE) db push
# Validation sans Docker (PostgreSQL embarqué + shim pgTAP)
db-check:
	cd scripts/db-check && npm install --no-audit --no-fund && node run.mjs
# Tests pgTAP réels (Docker + supabase start requis)
db-test:
	$(SUPABASE) test db

run-client:
	cd apps/saiqi_client && flutter run --dart-define-from-file=.env
run-driver:
	cd apps/saiqi_driver && flutter run --dart-define-from-file=.env
run-admin:
	cd apps/saiqi_admin && flutter run --dart-define-from-file=.env

analyze:
	cd apps/saiqi_client && flutter analyze
	cd apps/saiqi_driver && flutter analyze
	cd apps/saiqi_admin && flutter analyze

test:
	cd apps/saiqi_client && flutter test
	cd apps/saiqi_driver && flutter test
	cd apps/saiqi_admin && flutter test
	$(MAKE) db-check

sync-core:
	bash scripts/sync_core.sh
