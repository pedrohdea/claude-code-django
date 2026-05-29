.PHONY: bootstrap dev backend frontend migrate test lint increment clean

bootstrap:        ## Sobe todo o ambiente (idempotente)
	@bash scripts/bootstrap.sh

dev:              ## Roda backend + frontend juntos
	@bash scripts/dev.sh

backend:
	@cd backend && . .venv/bin/activate && python manage.py runserver

frontend:
	@cd frontend && npm run dev

migrate:
	@cd backend && . .venv/bin/activate && python manage.py makemigrations && python manage.py migrate

test:
	@cd backend && . .venv/bin/activate && pytest
	@cd frontend && npm run test -- --run

lint:
	@cd backend && . .venv/bin/activate && ruff check . && mypy .
	@cd frontend && npm run lint

increment:        ## Aplica increments pendentes
	@bash scripts/apply_increments.sh

clean:
	@rm -rf backend/.venv frontend/node_modules backend/db.sqlite3
