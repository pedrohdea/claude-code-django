---
name: seed-artifacts
description: Semeia os artefatos de Claude Code deste boilerplate (skills, agents, commands, hooks, CLAUDE.md, configs, CI) em outro repositório. Use ao montar um repo novo ou padronizar um existente com o mesmo ferramental. Triggers "semear artefatos", "popular skills no repo", "importar setup do Claude", "/seed-artifacts".
---

# Seed Artifacts

Copia os artefatos de Claude Code deste boilerplate (`claude-code-django`) para **outro
repositório**. A skill roda **de dentro do repo destino**, busca a fonte por git, copia
tudo resolvendo conflitos item a item, e marca cada artefato copiado como **"em fase de
implantação / não validado"** com um TODO para o usuário validar e adaptar antes de
confiar.

O argumento da skill pode conter flags opcionais: `--ref <branch>` e
`--only <categorias>` (lista separada por vírgula: `skills,agents,commands,hooks,configs,guides,ci`).

## Constantes

- **Repo fonte (SSH)**: `git@github.com:pedro-beemon/claude-code-django.git`
- **Repo fonte (HTTPS, fallback)**: `https://github.com/pedro-beemon/claude-code-django.git`
- **Ref padrão**: `main`.

## Banner de TODO (marcação "em fase de implantação")

Markdown (`SKILL.md`, `CLAUDE.md`, `PERSONAL.md`, `best_practices.md`):

```
> ⚠️ **Em fase de implantação — não validado neste repo.**
> TODO: validar e adaptar este artefato ao contexto deste projeto antes de confiar nele.
```

YAML (workflows `.github/workflows/*.yml`) — comentário no topo:

```
# ⚠️ Em fase de implantação — não validado neste repo.
# TODO: validar e adaptar este workflow ao contexto deste projeto antes de habilitar.
```

Configs JSON (`settings.json`, `.mcp.json`): **NÃO** alterar o conteúdo (quebraria o
parse). Registrar apenas no checklist `.claude/SEEDED.md`.

## Instruções

### 1. Pré-checks (no repo destino)

- Confirmar que o cwd é um repo git: `git rev-parse --is-inside-work-tree`. Se não for,
  parar e avisar o usuário.
- Verificar working tree: `git status --porcelain`. Se houver mudanças não commitadas,
  recomendar criar uma branch dedicada (`chore/seed-claude-artifacts`) antes de
  prosseguir e confirmar com o usuário.
- Parsear o argumento da skill para extrair `--ref` (default acima) e `--only`
  (default: todas as categorias).

### 2. Buscar a fonte

Clonar shallow para um tmpdir e limpar ao final. Tentar SSH, com fallback HTTPS:

```bash
SRC="$(mktemp -d)"
git clone --depth 1 --branch "<REF>" git@github.com:pedro-beemon/claude-code-django.git "$SRC" \
  || git clone --depth 1 --branch "<REF>" https://github.com/pedro-beemon/claude-code-django.git "$SRC"
```

Guardar `$SRC`. Garantir limpeza (`rm -rf "$SRC"`) ao final, mesmo em erro.

### 3. Inventário

A partir de `$SRC`, montar a lista de artefatos por categoria (respeitando `--only`):

| Categoria | Origem |
|---|---|
| `skills`   | `.claude/skills/*/` (todas, **exceto** `seed-artifacts` — nunca semear a si mesma; e exceto `README.md` solto) |
| `agents`   | `.claude/agents/*.md` |
| `commands` | `.claude/commands/*.md` |
| `hooks`    | `.claude/hooks/*` (incl. `skill-rules.json`, `skill-eval.*`) |
| `configs`  | `.claude/settings.json`, `.mcp.json` |
| `guides`   | `CLAUDE.md`, `PERSONAL.md`, `best_practices.md` |
| `ci`       | `.github/workflows/*.yml` |

> **⚠️ `configs` e `hooks` são sensíveis.** Mesmo quando **não** existem no destino, não
> copie direto: confirme com o usuário, **mostre o conteúdo** e sinalize os conflitos
> conhecidos (ver Passo 4b). O classificador de permissões do harness pode **bloquear** a
> cópia de `settings.json`/`.mcp.json`/hooks executáveis sem autorização explícita.

### 4. Copiar com resolução de conflito por item

Para cada arquivo destino:

- **Não existe no destino** → copiar direto.
- **Já existe** → perguntar ao usuário (uma decisão por item):
  - **pular** — manter o arquivo do destino intacto;
  - **sobrescrever** — substituir pelo da fonte;
  - **mesclar** — mostrar o diff e integrar manualmente preservando o conteúdo local.

Use `AskUserQuestion` agrupando conflitos quando fizer sentido, mas registre a decisão
por arquivo. Crie diretórios faltantes no destino conforme necessário.

### 4b. Categorias sensíveis — confirmar antes de copiar

`configs` (`settings.json`, `.mcp.json`) e `hooks` executáveis exigem **confirmação
explícita** (via `AskUserQuestion`), com o conteúdo à vista, **mesmo sendo novos** no
destino. Conflitos recorrentes a sinalizar:

- `settings.json` → `includeCoAuthoredBy: true` conflita com projetos que proíbem
  `Co-Authored-By`; hooks `PostToolUse` rodam `uv run …` (quebra em `pip`/poetry) e podem
  usar `pyright`/`pytest` ausentes no destino.
- `.mcp.json` → servidores via `npx @anthropic/mcp-*` e MCP de banco com acesso irrestrito
  (`--access-mode=unrestricted`) — risco de segurança; confirmar caso a caso.
- `hooks` (`skill-eval.*`, `skill-rules.json`) → só funcionam se o `settings.json` os
  referenciar; copiados isolados ficam inertes (sem auto-ativação de skills).

Oferecer 3 caminhos por item: **pular** (registrar no `SEEDED.md`), **instalar adaptado**
(remover `includeCoAuthoredBy`, trocar `uv`→runner do destino, remover MCP arriscado) ou
**instalar como está** (não recomendado).

### 5. Marcar cada artefato copiado (TODO "em fase de implantação")

Aplicar a marcação do topo desta skill a **todo arquivo efetivamente copiado/sobrescrito**:

- `SKILL.md`: inserir o banner markdown **logo após o bloco de frontmatter** (depois do
  segundo `---`), antes do corpo. Não tocar no frontmatter (evita afetar a ativação).
- `CLAUDE.md` / `PERSONAL.md` / `best_practices.md` / `.claude/skills/README.md`:
  banner markdown no topo do arquivo.
- Workflows `.github/workflows/*.yml`: comentário YAML no topo.
- `settings.json` / `.mcp.json`: **não alterar** — apenas registrar no `SEEDED.md`.
- `hooks/*` (scripts): não alterar scripts executáveis; registrar no `SEEDED.md`.

Itens pulados pelo usuário **não** recebem banner.

### 6. Checklist central `.claude/SEEDED.md`

Gerar (ou atualizar, anexando uma nova seção datada) o arquivo no destino:

```markdown
# Artefatos semeados — validação pendente

Origem: pedro-beemon/claude-code-django @ <REF> · Data: <YYYY-MM-DD>

Cada item abaixo foi copiado e está **em fase de implantação**. Valide e adapte ao
contexto deste repositório, depois marque o checkbox.

## Skills
- [ ] onboard
- [ ] ... (uma linha por skill copiada)

## Agents / Commands / Hooks
- [ ] ...

## Configs (NÃO marcados com TODO inline — revisar manualmente)
- [ ] .claude/settings.json
- [ ] .mcp.json

## Guias
- [ ] CLAUDE.md — ⚠️ é Django/uv-específico: adaptar à stack deste repo
- [ ] ...

## CI
- [ ] .github/workflows/<arquivo>.yml
```

Listar apenas os itens efetivamente copiados/sobrescritos nesta execução.

### 7. Índice de skills

Se o destino tiver `.claude/skills/README.md`, anexar as skills novas à tabela; senão,
deixar o rastreio apenas no `SEEDED.md`.

### 8. Relatório final

Imprimir um resumo: copiados / sobrescritos / pulados / mesclados (por categoria).

### 9. Validação e adaptação (obrigatória antes de remover o banner)

O banner só sai **depois** de validar e adaptar o artefato ao destino. Para cada item:

1. **Stack-token sweep** — `grep` por marcas do boilerplate e adaptar/remover. Tokens:
   `uv run`, `pytest`, `factory boy`, `pyright`, `ty check`, `htmx`/`hx-`, e *path-isms*
   (`apps/<app>`, `config/celery`, `config.settings`). Trocar pelo equivalente do destino
   (ex.: `uv run`→`venv`/`pip`; `pytest`+Factory Boy→o test runner real; `apps/`→o layout
   real). **Remover** skills sem aderência (ex.: `htmx-patterns` se não há HTMX;
   `pytest-django-patterns` se o projeto usa `unittest`/outro framework).
2. **Conflitos de convenção (artefatos de workflow)** — `ticket`, `github-workflow`,
   `code-reviewer`, `pr-review`, `pr-summary`, `worktree-commit-merge` codificam as
   convenções de git/PR do boilerplate (branch `{initials}/{desc}`, PR `type(scope):`,
   `Co-Authored-By` embutido, merge direto na `main`). **Conferir contra o `CLAUDE.md` do
   destino** e adaptar: naming de branch, formato de título de PR, regra de aprovação de
   commit, proibição de `Co-Authored-By`, flags de PR. Remover o que conflita de forma
   irreconciliável (ex.: `worktree-commit-merge` em projeto que só usa fluxo de PR).
3. **Remover o banner** de cada artefato validado e marcar `[x]` no `SEEDED.md` (incluir
   uma seção "Removidos" para o que foi descartado, com o motivo).

### 10. Índice no `CLAUDE.md` do destino

Adicionar (ou atualizar) no `CLAUDE.md` do destino um índice **"Artefatos de IA"** com
**link relativo para cada artefato** validado (skills, agents, commands, guias, docs de
processo). Registrar a **regra**: todo artefato novo/removido deve ser refletido no índice
no mesmo PR. Validar os links: `grep -oE '\]\(([^)]+)\)' CLAUDE.md` e conferir que cada
caminho existe.

### 11. `.gitignore`

Garantir que `.claude/settings.local.json` (override pessoal) está no `.gitignore` do
destino — nunca versionar.

## Notas de design

- **Idempotente**: rodar de novo só re-pergunta nos conflitos.
- A skill **nunca semeia a si mesma** (`seed-artifacts`).
- Skills Django são copiadas mesmo em repos não-Django (decisão do usuário); o banner +
  checklist deixam explícito que precisam ser validadas ou removidas.
- O tmpdir do clone é sempre removido ao final.
- **Copiar ≠ validar.** A cópia é mecânica; o valor está no Passo 9 — adaptar à stack e às
  convenções do destino. Banner que fica para sempre = artefato órfão; o objetivo é
  removê-lo após validar.
- **Configs/hooks raramente entram como estão** — `includeCoAuthoredBy`, hooks `uv` e MCP
  irrestrito costumam conflitar; o caminho padrão é "pular" ou "instalar adaptado".
