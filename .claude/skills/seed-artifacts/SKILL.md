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
- **Ref padrão**: `feat/import-django-vue-boilerplate`
  (⚠️ trocar para `main` quando os artefatos forem mergeados).

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

### 4. Copiar com resolução de conflito por item

Para cada arquivo destino:

- **Não existe no destino** → copiar direto.
- **Já existe** → perguntar ao usuário (uma decisão por item):
  - **pular** — manter o arquivo do destino intacto;
  - **sobrescrever** — substituir pelo da fonte;
  - **mesclar** — mostrar o diff e integrar manualmente preservando o conteúdo local.

Use `AskUserQuestion` agrupando conflitos quando fizer sentido, mas registre a decisão
por arquivo. Crie diretórios faltantes no destino conforme necessário.

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

Imprimir um resumo: copiados / sobrescritos / pulados / mesclados (por categoria) e os
próximos passos:

1. Validar os itens em `.claude/SEEDED.md` (remover o banner de cada artefato ao validar).
2. Revisar `CLAUDE.md` para a stack real do destino (o original é Django + uv + HTMX).
3. Remover skills Django se o destino não for Django (`django-*`, `htmx-patterns`,
   `celery-patterns`, `pytest-django-patterns`).
4. Conferir se os hooks de auto-ativação dependem de Node/scripts e instalar o necessário.
5. Revisar `.claude/settings.json` e `.mcp.json` (permissões, MCP servers) — não recebem
   TODO inline.

## Notas de design

- **Idempotente**: rodar de novo só re-pergunta nos conflitos.
- A skill **nunca semeia a si mesma** (`seed-artifacts`).
- Skills Django são copiadas mesmo em repos não-Django (decisão do usuário); o banner +
  checklist deixam explícito que precisam ser validadas ou removidas.
- O tmpdir do clone é sempre removido ao final.
