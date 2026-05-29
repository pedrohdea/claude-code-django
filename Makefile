.PHONY: bootstrap dev backend frontend migrate test lint increment slides clean

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

slides:           ## Sobe os slides reveal.js em http://localhost:8000/slides/
	@cd docs/slides && (test -d node_modules || npm install --no-audit --no-fund) && npm start

clean:
	@rm -rf backend/.venv frontend/node_modules backend/db.sqlite3
