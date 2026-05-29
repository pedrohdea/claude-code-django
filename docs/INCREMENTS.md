# Sistema auto-incremental

O ambiente cresce em **etapas idempotentes**. Nada roda duas vezes.

## Como funciona
- `scripts/bootstrap.sh` só executa o que falta (venv, deps, .env, migrate).
- `scripts/apply_increments.sh` percorre `scripts/increments/NNN_*.sh` em ordem.
- Cada increment aplicado é registrado em `scripts/increments/STATE`.
- Rodar `make increment` de novo pula tudo que já consta no STATE.

## Criar um novo increment
1. Crie `scripts/increments/00X_descricao.sh` (deve ser idempotente também).
2. `make increment` aplica só os pendentes.

Exemplo já incluído: `001_seed_admin.sh` cria o superuser
`admin@example.com / admin12345` se nenhum existir.

## Increments sugeridos (roadmap)
- `002_add_celery.sh` — tasks assíncronas + Redis.
- `003_dockerize_backend.sh` — Dockerfile + entrypoint prod.
- `004_add_e2e.sh` — Playwright no frontend.
