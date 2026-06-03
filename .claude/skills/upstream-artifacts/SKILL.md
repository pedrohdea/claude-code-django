---
name: upstream-artifacts
description: Envia (upstream) as melhorias dos artefatos de Claude Code (.claude, guias, CI) de um repo destino de volta ao claude-code-django, abrindo um PR. Use após melhorar skills/agents/commands/hooks/CI num repo semeado e querer contribuir de volta. Triggers "atualizar claude-code-django", "enviar artefatos upstream", "contribuir skills de volta", "/upstream-artifacts".
---

# Upstream Artifacts

Caminho de **volta** da [`seed-artifacts`](../seed-artifacts/SKILL.md). Aquela skill
**semeia** os artefatos de Claude Code do boilerplate `claude-code-django` **para** um
repo destino; esta aqui pega as **melhorias** feitas no repo destino e as **devolve** ao
boilerplate, abrindo um **PR**.

A skill roda **de dentro do repo destino**, faz o diff do `.claude` local contra o
`claude-code-django`, deixa o usuário escolher item a item o que enviar, **remove as
marcações de seed** ("em fase de implantação") e abre o PR no boilerplate.

O argumento da skill pode conter flags opcionais: `--ref <branch>` (branch base do PR no
boilerplate) e `--only <categorias>` (lista separada por vírgula:
`skills,agents,commands,hooks,configs,guides,ci`).

## Constantes (compartilhadas com `seed-artifacts`)

- **Repo alvo (SSH)**: `git@github.com:pedro-beemon/claude-code-django.git`
- **Repo alvo (HTTPS, fallback)**: `https://github.com/pedro-beemon/claude-code-django.git`
- **Ref/base padrão**: `feat/import-django-vue-boilerplate`
  (⚠️ trocar para `main` quando os artefatos forem mergeados).

## Banner de seed a remover (marcação "em fase de implantação")

A `seed-artifacts` injeta estas marcações ao semear. Ao enviar upstream, **remova-as**
para não poluir o boilerplate.

Markdown (`SKILL.md`, `CLAUDE.md`, `PERSONAL.md`, `best_practices.md`, `README.md`):

```
> ⚠️ **Em fase de implantação — não validado neste repo.**
> TODO: validar e adaptar este artefato ao contexto deste projeto antes de confiar nele.
```

YAML (workflows `.github/workflows/*.yml`) — comentário no topo:

```
# ⚠️ Em fase de implantação — não validado neste repo.
# TODO: validar e adaptar este workflow ao contexto deste projeto antes de habilitar.
```

Remova o bloco contíguo (as 2 linhas) **e** qualquer linha em branco órfã deixada no
lugar. Configs JSON (`settings.json`, `.mcp.json`) nunca recebem banner inline.

## Instruções

### 1. Confirmar intenção

Pergunte ao usuário com `AskUserQuestion` (este é o gatilho explícito da skill):

> "Deseja enviar as atualizações do `.claude` deste repo para o `claude-code-django`
> (abrir PR)?" → **Sim / Não**

Se **Não**, encerrar sem mexer em nada.

### 2. Pré-checks (no repo destino)

- Confirmar que o cwd é um repo git: `git rev-parse --is-inside-work-tree`. Se não for,
  parar e avisar.
- Confirmar que existe um diretório `.claude/`. Se não, não há nada a enviar — encerrar.
- Detectar se o cwd **já é** o próprio `claude-code-django` comparando
  `git remote get-url origin` com as constantes. Se for, avisar que fonte == destino e
  parar (não há upstream a fazer).
- Se existir `.claude/SEEDED.md`, ler para descobrir o ref de origem
  (`Origem: pedro-beemon/claude-code-django @ <REF>`). O arquivo é anexado em seções
  datadas, então pode ter **vários** `Origem:` — use o **mais recente** como base do PR.
  Sem `SEEDED.md`, use o ref padrão (ou `--ref`).

### 3. Buscar a fonte (clone)

Clonar shallow para um tmpdir e limpar ao final. Tentar SSH, com fallback HTTPS:

```bash
SRC="$(mktemp -d)"
git clone --depth 1 --branch "<REF>" git@github.com:pedro-beemon/claude-code-django.git "$SRC" \
  || git clone --depth 1 --branch "<REF>" https://github.com/pedro-beemon/claude-code-django.git "$SRC"
```

Guardar `$SRC`. Garantir limpeza (`rm -rf "$SRC"`) ao final, **mesmo em erro** — só após
o push ter sucesso (Passo 8). Pushar uma branch nova sobre o commit raso funciona para
abrir o PR.

⚠️ Requer **acesso de escrita** ao `claude-code-django` (SSH preferido; HTTPS depende do
`gh auth`).

### 4. Inventário + diff por categoria

A partir de `$SRC`, montar a lista de artefatos por categoria (respeitando `--only`),
mesma tabela origem↔destino da `seed-artifacts`:

| Categoria | Caminho |
|---|---|
| `skills`   | `.claude/skills/*/` (todas, **exceto** `seed-artifacts` e `upstream-artifacts`; e exceto `README.md` solto) |
| `agents`   | `.claude/agents/*.md` |
| `commands` | `.claude/commands/*.md` |
| `hooks`    | `.claude/hooks/*` (incl. `skill-rules.json`, `skill-eval.*`) |
| `configs`  | `.claude/settings.json`, `.mcp.json` |
| `guides`   | `CLAUDE.md`, `PERSONAL.md`, `best_practices.md` |
| `ci`       | `.github/workflows/*.yml` |

Para cada arquivo, **primeiro remova o banner de seed da cópia do destino** (numa cópia
temporária) e só então compare **destino vs fonte** (`git diff --no-index <fonte> <destino-limpo>`).
Não dá para excluir o banner do diff via filtro — limpe antes. Classifique:

- **Novo no destino** (não existe na fonte) → candidato, **default = PULAR**. Arquivos
  novos costumam ser específicos do repo destino (ex.: skill escrita para aquele
  projeto), não melhorias do boilerplate. Mantenha **visualmente separado** dos
  modificados na seleção.
- **Modificado** → candidato a atualizar. Se, após remover o banner, não sobrar
  diferença, é **no-op** — não envie.
- **Igual** → pular.
- **Removido no destino** (existe na fonte, não no destino) → **NÃO** propagar deleção;
  apenas reportar no final.
- **Exclusões fixas**: as meta-skills `seed-artifacts` e `upstream-artifacts` (nunca se
  auto-enviam) e `.claude/SEEDED.md` (checklist local — nunca vai upstream).

⚠️ **Sentido do diff / risco de regressão.** O diff é contra a fonte **atual**, não
contra o ponto de seed (o `SEEDED.md` guarda só o nome da branch, não um SHA — não há
three-way real). Se o boilerplate avançou desde o seed, um arquivo "modificado" pode
estar **mais velho** que a fonte e enviá-lo **regrediria** o boilerplate. A revisão item
a item (Passo 5) é a salvaguarda.

### 5. Seleção item a item

Use `AskUserQuestion` agrupando os candidatos, com **novos** e **modificados** em grupos
separados (os **novos** já vêm desmarcados por default). Para cada item:

- Mostre o diff no sentido **fonte → destino** e deixe **inequívoco**: "isto **SUBSTITUI**
  o arquivo atual do boilerplate".
- **Guias** (`CLAUDE.md` / `PERSONAL.md` / `best_practices.md`) e **configs**
  (`settings.json` / `.mcp.json`) saem com **aviso forte** adicional: o guia/config do
  destino costuma estar adaptado à stack ou às permissões/MCP daquele repo e pode
  clobberar conteúdo do boilerplate. Confirme cada um explicitamente.

Registre a decisão (incluir / pular) por arquivo.

### 6. Aplicar na clone (limpando banners)

Para cada item **selecionado**:

- Copiar a versão do destino para o caminho correto dentro de `$SRC`, criando
  diretórios faltantes.
- **Remover o banner de seed**: bloco markdown logo após o frontmatter em `SKILL.md`;
  topo do arquivo em guias e `README.md`; comentário YAML no topo de workflows.
- **Nunca** copiar `.claude/SEEDED.md`.

### 7. Commit (na clone)

Seguir as convenções do `claude-code-django` e de `~/.claude/CLAUDE.md`:

- Criar branch nova na clone no padrão `{initials}/{description}`
  (ex.: `pa/upstream-claude-artifacts` — confirme as iniciais com o usuário).
- **NUNCA** commitar na branch base.
- Mensagem em Conventional Commits, ex.:
  `chore: upstream .claude improvements from <repo-destino>`.
- **Mostre a mensagem e aguarde aprovação explícita** antes de `git commit`.
- `git add` **por arquivo** (sem `git add -A` / `git add .`).

```bash
git -C "$SRC" checkout -b <initials>/<description>
git -C "$SRC" add <arquivos-específicos>
git -C "$SRC" commit -m "<mensagem aprovada>"
```

### 8. Push + PR

```bash
git -C "$SRC" push -u origin HEAD
```

Depois, abrir o PR **de dentro da clone** (`cd "$SRC"` ou rode o `gh` com o cwd em
`$SRC`). O `origin` da clone já é `pedro-beemon/claude-code-django`, então **não** use
`-R` (pode fazer o `gh` detectar a head errada):

```bash
gh pr create --base "<REF>" --title "<título>" --body "$(cat <<'EOF'
<body>
EOF
)"
```

**Body** deve conter:
- O que mudou, por categoria (adicionados / atualizados).
- Repo destino de origem das melhorias.
- Lista de artefatos enviados.
- Nota de que os banners de seed foram removidos.
- Nota de que deleções **não** foram propagadas (liste-as para ciência).

**Mostre título + body e aguarde aprovação** antes de `gh pr create` (espelha a skill
`commit`). Assignee `pedro-beemon` é opcional.

### 9. Cleanup

Após o push confirmado (branch segura na remote), remover o tmpdir:

```bash
rm -rf "$SRC"
```

### 10. Relatório final

Imprimir um resumo:
- URL do PR.
- Por categoria: enviados / pulados / deleções ignoradas.
- Nº de banners de seed removidos.
- Próximos passos: revisar e mergear o PR no `claude-code-django`.

## Notas de design

- **Idempotente**: rodar de novo só re-faz o diff; se nada mudou, reporta "nada a enviar".
- A skill **nunca** auto-envia as meta-skills (`seed-artifacts`, `upstream-artifacts`).
- Deleções **nunca** são propagadas (só reportadas).
- O tmpdir do clone é sempre removido ao final.
- Espelho exato da `seed-artifacts` — mesmas constantes e inventário; este é o caminho de
  volta.
- **Gap de primeiro uso**: como project skill, ela só "pega carona" em seeds **futuros**
  da `seed-artifacts`. Repos semeados **antes** desta skill existir **não a terão** e só
  poderão invocá-la após re-semear, copiá-la manualmente, ou instalá-la como global.
- **Sem three-way real**: o diff é contra a fonte atual. Pinar o SHA do seed no
  `SEEDED.md` permitiria um merge three-way de verdade no futuro — mas isso é uma mudança
  na `seed-artifacts`, fora do escopo desta skill.
