# Arquitetura

```
fullstack/
├── backend/                 # Django 6 + DRF (API REST pura em /api/)
│   ├── config/              # settings, urls, wsgi/asgi
│   └── apps/
│       ├── accounts/        # User custom (email), register, /me, JWT
│       └── core/            # Item CRUD (ViewSet), /health
├── frontend/                # Vue 3.5 + Vite 8 (SPA, proxy /api -> :8000)
│   └── src/
│       ├── api/client.ts    # axios + interceptor JWT
│       ├── stores/          # Pinia (auth, items)
│       ├── router/          # vue-router + guard requiresAuth
│       └── views/           # Home, Login, Items
├── scripts/                 # bootstrap idempotente + engine de increments
└── docs/
```

## Fluxo de auth
1. `POST /api/auth/token/` (email+senha) → `access` + `refresh`.
2. Front guarda em `localStorage`, injeta `Authorization: Bearer` via interceptor.
3. Rotas com `meta.requiresAuth` exigem token; guard redireciona p/ `/login`.

## Banco
- Dev: SQLite zero-config (sem `DATABASE_URL`).
- Prod/Postgres: suba `docker-compose up -d db` e defina `DATABASE_URL`.
