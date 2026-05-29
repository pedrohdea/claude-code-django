# Apresentação de Workshop sobre Arquitetura

# Indice

# Resumo

Sessões de IA começam do zero a cada vez — sem memória, sem contexto, sem as regras
do seu projeto. Este workshop mostra como virar esse jogo tratando os **artefatos de
IA do Claude Code** (CLAUDE.md, skills, hooks, sub-agents, slash commands, plan-mode,
memória e scripts auto-incrementais) como **infraestrutura versionada**: com ownership,
code review e atualização contínua, igual a um pipeline de CI. O princípio-mãe é
simples — *a IA se adapta ao seu projeto, não o contrário.*

Usando como caso real o boilerplate fullstack **Django 6 + Vue 3** deste repositório,
percorremos cada artefato — o que é, quando usar, anti-padrões e template — e montamos,
ao vivo, uma configuração de Claude Code que reduz fricção e preserva contexto entre
sessões.

**Pilares do workshop**

- **Modelo mental em 4 camadas** — regras estáticas (CLAUDE.md), memória aprendida,
  procedimentos (skills) e automação (hooks): saber em qual camada cada instrução vive
  é a decisão mais barata que evita o maior desperdício.
- **Guardrails determinísticos** — hooks que validam, bloqueiam e ativam skills
  automaticamente, sem depender do julgamento do modelo.
- **Workflows reutilizáveis** — skills compostas, slash commands como runbooks e
  sub-agents especialistas que isolam contexto.
- **Contexto que sobrevive** — plan-mode versionado e memória auto-mantida para não
  recomeçar do zero a cada sessão.
- **Ambiente que se mantém sozinho** — automação auto-incremental (bootstrap idempotente
  + increments numerados + arquivo STATE).

# Capítulo 0 — Filosofia

**Abertura.** A primeira decisão de quem trabalha com IA não é técnica, é de postura.

Antes de qualquer ferramenta, uma postura. Trabalhar com IA não é "pedir código para
um robô" nem caçar o prompt mágico — é uma **relação de trabalho** com uma divisão de
papéis bem definida. Entender essa relação é o que separa quem ganha velocidade de quem
só gera retrabalho.

**O colaborador tem um perfil cognitivo peculiar.** A IA tem uma largura de banda enorme:
lê o projeto inteiro em segundos, conhece mil padrões, escreve rápido. Mas tem duas
limitações que moldam tudo:

- **Começa do zero a cada sessão.** Não lembra do que vocês combinaram ontem, das regras
  do seu projeto, das decisões já tomadas — a não ser que isso esteja *escrito em algum
  lugar que ela leia*.
- **É confiante mesmo quando está errada.** Ela não sinaliza incerteza de forma confiável.
  Por isso o **julgamento continua sendo seu**: você valida, você decide o que é "bom o
  suficiente", você assume o risco.

**Daí o insight central: o recurso escasso é o contexto.** Toda a disciplina de trabalhar
bem com IA gira em torno de uma coisa — transferir a sua *intenção* para a IA e
*preservá-la* ao longo do tempo. Não é sobre escrever instruções melhores numa conversa;
é sobre construir um ambiente onde a intenção já está codificada antes da conversa começar.

**Isso muda o seu papel.** Você deixa de ser quem escreve cada linha e passa a ser quem
**dirige a intenção e arquiteta o ambiente**. Você diz *o quê* e *por quê*; o ambiente —
as regras, os procedimentos, a memória — carrega o *como*. Quanto melhor o ambiente, menos
você repete, menos a IA erra, e mais o trabalho fica revisável por humanos.

**Como o trabalho realmente flui.** Na prática, cowork com IA é um ciclo conversacional,
não um pedido único:

1. **Intenção** — você expressa o objetivo e o porquê, não o passo a passo.
2. **Alinhamento** — para algo arriscado ou multi-passo, a IA propõe um plano e vocês
   acertam o rumo *antes* de executar; para algo trivial, pula direto.
3. **Execução** — a IA faz o trabalho dentro dos limites que o ambiente já estabeleceu.
4. **Revisão** — você verifica contra o seu julgamento; a IA não é a autoridade final.
5. **Captura** — o que foi aprendido (um padrão, uma decisão não-óbvia) vira artefato
   persistente, para a próxima sessão não recomeçar do zero.

É esse loop que transforma sessões isoladas e amnésicas em uma **colaboração que melhora
com o tempo**.

**O princípio-mãe que amarra tudo:** *a IA se adapta ao seu projeto, não o contrário.* É
por isso que, nos próximos capítulos, tratamos cada artefato (CLAUDE.md, skills, hooks,
memória…) como **infraestrutura versionada** — peças duráveis, com ownership e review, e
não prompts descartáveis. A filosofia vem primeiro; as ferramentas são só a forma de
executá-la.

**Gancho.** Essa postura nasce de um problema concreto e diário — a amnésia da IA a cada sessão.

# Capítulo 1 — Por que isso importa: o problema do contexto zero

**Abertura.** Toda sessão de IA nasce sem saber nada do seu projeto — e isso custa caro.

A filosofia do capítulo anterior tem uma consequência incômoda e muito concreta: **toda
sessão de IA nasce amnésica**. Por padrão, a IA não sabe nada do seu projeto até você
contar — de novo, e de novo, e de novo.

**O custo disso aparece de várias formas:**

- **Re-explicação eterna.** A cada sessão você repete o stack, as convenções, onde as
  coisas moram, o que pode e o que não pode. Tempo gasto contando o que já era para ser
  sabido.
- **Decisões re-derivadas (e divergentes).** Sem registro do que já foi decidido, a IA
  reinventa a solução — às vezes diferente da de ontem. O resultado é inconsistência que
  vira dívida técnica.
- **Conhecimento preso na conversa.** O que vocês descobriram juntos vive no chat. Quando
  a sessão acaba — ou o contexto estoura e é resumido — esse conhecimento evapora.
- **Teto de produtividade.** O modo de falha clássico: "a IA é brilhante por 20 minutos e
  depois esquece tudo." Você nunca sai do eterno recomeço.

**O ponto que vira a chave:** nada disso é limitação do modelo — é limitação do
*ambiente*. O contexto não precisa ser redigitado a cada vez; ele pode ser **um ativo
persistente**, escrito uma vez e relido automaticamente em toda sessão.

É exatamente isso que o resto do workshop entrega: um conjunto de artefatos que tornam
intenção, regras e conhecimento **duráveis**. Quando o contexto vira infraestrutura, a IA
para de recomeçar do zero — e começa a compor em cima do que já foi feito.

**Gancho.** A saída é organizar o contexto em camadas — o modelo mental do próximo capítulo.

# Capítulo 2 — O modelo mental: as 4 camadas de artefato

**Abertura.** Não existe "o" artefato salvador; existem camadas, cada uma com seu propósito.

Se o problema é contexto zero, a solução não é *um* artefato — é saber que existem
**camadas** de artefato, cada uma com uma persistência e um propósito diferentes. A
decisão mais barata que você toma (e a que mais evita desperdício) é: *em qual camada
esta instrução vive?*

| # | Camada | Artefato | Quando carrega | Para quê |
|---|--------|----------|----------------|----------|
| 1 | Regras estáticas | `CLAUDE.md` | sempre, no início da sessão | verdades não-negociáveis do projeto |
| 2 | Memória aprendida | `MEMORY.md` (auto memory) | início da sessão (~200 linhas / 25KB) | padrões que a IA inferiu sozinha |
| 3 | Procedimentos | Skills (`SKILL.md`) | sob demanda, quando invocados | workflows reutilizáveis com julgamento |
| 4 | Automação | Hooks (`settings.json`) | em eventos do ciclo de vida | ações determinísticas, zero-variância |

**Por que separar importa.** Cada camada paga um custo diferente. O `CLAUDE.md` é lido
em *todo* turno — então tudo que mora ali infla o contexto inicial. A memória é inferida
e pode ser podada — então não serve para regras duras. Hook é zero-variância — então não
pode conter julgamento. Skill carrega só quando chamada — ideal para procedimentos
ocasionais. Colocar a instrução na camada errada não dá erro; só desperdiça contexto,
dinheiro e confiabilidade, silenciosamente.

**O teste prático — onde colocar uma instrução:**

- Precisa ser verdade em *todo* turno? → **CLAUDE.md**
- Procedimento que você só usa *às vezes*? → **Skill**
- Script que deve rodar *automaticamente*, sem julgamento? → **Hook**
- Precisa de julgamento dentro de limites? → **Skill**. Variância zero? → **Hook**.
- Encheria o contexto principal ou é trabalho especializado? → delega a um **Sub-agent**.

**As três lentes.** As camadas (e os artefatos derivados — sub-agents, slash commands,
plans) se organizam em três movimentos do ciclo de vida, que dão a estrutura do resto do
workshop:

- **CRIAR** — produzir o artefato certo, no lugar certo (CLAUDE.md, hooks, commands,
  sub-agents, skills, plan-mode).
- **PRESERVAR** — manter contexto e memória sãos ao longo do tempo (memória, planning).
- **AUTOMATIZAR** — fazer o ambiente crescer e se manter sozinho (hooks, automação
  auto-incremental).

> Guarde a tabela das 4 camadas: cada capítulo a seguir aprofunda uma delas. Quando bater
> a dúvida "onde isso deveria morar?", volte aqui.

**Gancho.** Começamos pela Camada 1, a base de tudo: o CLAUDE.md.

# Capítulo 3 — CLAUDE.md em camadas

**Abertura.** O CLAUDE.md é a primeira coisa que a IA lê — e jogar tudo nele é o erro mais comum.

O `CLAUDE.md` é o primeiro arquivo que a IA lê — e a tentação é jogar tudo nele. Não faça.
Um `CLAUDE.md` que tenta cobrir regras de negócio, convenções de cada subsistema e
exemplos longos sofre de três males: **sinal afoga em ruído** (a IA leva minutos só lendo),
**drift silencioso** (o código de um módulo evolui mas a regra na raiz não, e a IA opera
com instrução obsoleta) e **acoplamento** (mudar a regra de um subsistema exige editar o
arquivo que todo mundo lê).

**Princípio: organize em 2–3 camadas.**

- **`CLAUDE.md` raiz** — regras invioláveis + ponteiros. Curto (idealmente < 1500 linhas),
  estável, raramente editado.
- **`<app|package>/CLAUDE.md`** — detalhes táticos da unidade (convenções de models,
  regras de migration, query patterns), editados pelo dono. Em Django, "unidade" = app.
- **(Opcional) per-submódulo** — só quando o submódulo tem invariantes próprias.

A raiz **referencia** as camadas inferiores; **nunca duplica** o conteúdo delas — duas
fontes de verdade sempre divergem.

**Regras de ouro:** toda regra tem um **comando de verificação** associado (senão vira
religião); evite instruções negativas vagas ("seja cuidadoso"), que a IA não sabe quando
aplicou; use `/init` para gerar o esqueleto inicial. Quando a raiz passar de ~1500 linhas,
é sinal de extrair para camadas.

> Neste repo: a `CLAUDE.md` raiz fixa stack, comandos, convenções de git e regras críticas
> (FBVs, error handling, HTMX), e aponta para as skills sob demanda — exatamente o padrão
> "raiz enxuta + ponteiros".

**Gancho.** Mas regra escrita depende de disciplina; o próximo capítulo a automatiza com hooks.

# Capítulo 4 — Hooks como guardrails

**Abertura.** Regra que depende da boa vontade da IA falha; hook é regra que se aplica sozinha.

Convenção escrita em markdown depende da disciplina da IA em segui-la — e ela esquece.
**Hook é automação determinística em torno de uma tool call**: fecha o loop em < 2s, dentro
da mesma turn, sem esperar o CI quebrar 10 minutos depois.

- **Pre-tool hooks bloqueiam** — disparam *antes* da call; se a operação viola um invariante,
  retornam não-zero e a ação é abortada.
- **Post-tool hooks corrigem ou alertam** — disparam *depois*; auto-fix do que é seguro
  (format, sort imports), erro claro do que não dá pra corrigir sozinho.

**Cinco propriedades inegociáveis:** idempotente (rodar 3× = mesmo resultado), rápido
(> 2s síncrono mata a fluência), **fail-loud** (hook que silencia warning é pior que hook
ausente), matcher restrito por glob, e mensagem de erro que diz **o que fazer** — não só
"violation". E lembre: hook é *otimização*, não a única defesa — o CI roda o mesmo check.

**Três guardrails que pagam sozinhos** (alinhados com as regras deste repo e do
`CLAUDE.md` global):

| Hook | Tipo | O que faz |
|---|---|---|
| **Ruff Auto-Fix** | PostToolUse em `*.py` | `ruff check --fix` + `ruff format`; bloqueia se sobrar violação |
| **Migration Append-Only Guard** | PreToolUse | Bloqueia editar migration já commitada — crie uma nova |
| **No-commit-on-main Guard** | PreToolUse em `git commit` | Bloqueia commit em `main`/`master` e manda criar feature branch |

> O hook de `UserPromptSubmit` que ativa skills por path (visto neste próprio workshop)
> é outro exemplo vivo: determinístico, rápido, e sugere o procedimento certo na hora certa.

**Gancho.** Quando o procedimento é repetível mas exige julgamento, ele vira runbook — o próximo tema.

# Capítulo 5 — Slash commands como runbooks

**Abertura.** Workflow que mora só na cabeça de cada um vira tribal knowledge — e caos no review.

Tarefas multi-step recorrentes (revisar PR, preparar release, fazer dependency bump) viram
**tribal knowledge**: cada engenheiro tem a sua sequência mental, ninguém concorda em qual
gate vem primeiro, e o CI vira a única fonte de verdade — tarde demais.

**Um slash command é um runbook executável.** Tem `Goal` (uma frase), `Default scope`
(`git diff main...HEAD` é o padrão razoável), inputs com defaults, **stages numeradas com
gates verificáveis**, exit signals (sucesso/falha distinguíveis) e **anti-scope** (o que o
comando *não* faz — isso força composição em vez de um comando "faz-tudo").

**Quando vale:** workflow com 3+ passos, executado 1+ vez por semana, feito de formas
diferentes por pessoas diferentes, ou onde pular um passo custa caro.

**Anti-padrões:** comando "do everything" sem stages (não dá pra pausar/retomar); comando
sem matriz de gates ("roda revisão" sem critério de sucesso vira teatro); comando que
*duplica* uma skill (comando = orquestração; skill = procedimento — misturar dilui os dois).

> O `CLAUDE.md` global deste usuário descreve um workflow Jira de 7 steps (setup → branch →
> explore → TDD plan → implement → manual test → wrap up). Esse é o candidato perfeito a
> virar um `/work-on-jira <KEY>` orquestrador — com checkpoints humanos explícitos e
> reusando a skill `/commit` em vez de reescrever a lógica.

**Gancho.** Quando o runbook fica grande demais, vale delegar parte dele a um especialista dedicado.

# Capítulo 6 — Sub-agents especialistas

**Abertura.** Investigação grande polui o contexto principal; o especialista isolado resolve isso.

Quando uma investigação cresce — varrer 50 arquivos, revisar um diff de 1500 linhas,
auditar boundaries — três problemas aparecem: **poluição do context window** (o resultado
da busca degrada o raciocínio das próximas turns), **briefing repetitivo** (você reescreve
o mesmo prompt toda vez) e **serialização forçada** (revisões independentes esperam na fila).

**Sub-agent é um especialista com contexto isolado:** tools restritas (não acessa tudo —
protege contra ação fora de escopo), uma `description` que serve de gatilho (o agente
principal sabe quando delegar), system prompt em primeira pessoa com expertise específica,
e um ciclo *recebe briefing → devolve report* que **não polui o main**. Investigações
independentes podem ser despachadas em **paralelo** — multiplica throughput sem custar
contexto.

**Quando NÃO criar sub-agent:** tarefa one-off (use `Explore` ou `general-purpose`); tarefa
que precisa interagir com o usuário no meio (sub-agents são autocontidos); tarefa que
duplica uma skill (skill é mais leve). Sub-agents devem ser preferencialmente **read-only**,
retornando relatório estruturado (severidade · arquivo:linha · problema · sugestão).

> Padrão maduro: um comando orquestrador (`/deep-review`) despacha N sub-agents read-only em
> paralelo (guardian de arquitetura, checador de invariantes, revisor de schema) e consolida
> os relatórios — sem nunca encher o contexto principal.

**Gancho.** Procedimentos com julgamento, porém, pedem algo mais leve que um agente: a skill.

# Capítulo 7 — Skills compostas

**Abertura.** Procedimento detalhado não cabe no CLAUDE.md — ele carrega só quando o gatilho casa.

Instruções procedurais ("como criar um endpoint", "como adicionar um model", "como escrever
um plano") incham a `CLAUDE.md` se moram nela — a IA lê tudo sempre, mesmo quando não vai
usar. **Skill é o procedimento que carrega só quando o gatilho casa.**

Uma boa skill tem **frontmatter declarativo** (`name`, `description`, `when_to_use`), é
**invocada on-demand**, **compõe-se** com outras (uma skill de `brainstorming` chama
`writing-plans` no fim) e tem **hard-gates** quando o risco exige ("não escreva código antes
de aprovar o plano" precisa ser GATE, não sugestão).

Skills vivem em dois lugares: **repo-specific** (`.claude/skills/`, amarradas a este projeto)
e **compartilhadas** (genéricas: TDD, debugging sistemático, writing-plans).

**Anti-padrões:** skill que repete o que já está na `CLAUDE.md` (duas fontes de verdade);
skill sem `when_to_use` claro (a IA não sabe quando invocar); skill que **sobrescreve
feedback do usuário** — skill é diretriz, não dogma: *o usuário sempre ganha*.

> Este repo já trata skills como cidadãs de primeira classe: `systematic-debugging`,
> `django-extensions`, `onboard`, `ticket`, `pr-review`, `code-quality`, `docs-sync`,
> `worktree-commit-merge` — cada uma um procedimento revisável, descobrível e versionado.

**Gancho.** Antes de executar qualquer procedimento sério, porém, vem o plano — e ele se versiona.

# Capítulo 8 — Plan-mode versionado

**Abertura.** Plano sem versionamento é rascunho que se perde — e o racional some junto.

Sem versionamento, planos viram rascunhos descartáveis: você escreve, executa e perde. Dois
meses depois, quando a feature dá problema, ninguém lembra o *porquê* das decisões — a única
fonte é o diff, sem racional.

**Trate o plano como deliverable, não rascunho:**

- **Diretório dentro do repo** (`.claude/plans/`), não user-scope — senão some na revisão.
- **Auto-save** no plan mode — o agente escreve o plano no arquivo automaticamente.
- **Git é o índice canônico** — `git log -- .claude/plans/` é a história.
- **Commits referenciam o plano** (`Implements plan: .claude/plans/<file>.md`).

**Quando aplicar:** tarefa com 3+ fases ou que toca 3+ subsistemas; decisão que exige
racional que sobrevive ao diff (trade-offs, alternativas rejeitadas); feature que múltiplos
engenheiros vão tocar em sessões diferentes. Todo plano carrega `Context`, `Decisões`,
`Verificação` e `Fases` — sem isso, não dá pra retomar um mês depois.

> O plano que originou esta apresentação foi escrito exatamente assim: um arquivo em
> `plansDirectory`, com Context, decisões fechadas com o usuário e seção de verificação.

**Gancho.** Plano preserva o racional de uma tarefa; a memória preserva o aprendizado entre todas.

# Capítulo 9 — Memória auto-mantida

**Abertura.** Sem memória, toda correção que você faz hoje se perde até amanhã.

Sem memória persistente, toda sessão recomeça do zero: o usuário re-explica preferências,
correções não duram ("não faça X" e a IA faz X de novo amanhã) e o aprendizado não se
acumula. A memória resolve isso — desde que tenha **higiene**.

**Quatro tipos, cada um com semântica clara:**

| Tipo | Conteúdo |
|---|---|
| **user** | Quem é o usuário — função, expertise, preferências |
| **feedback** | Correções e validações de approach (com o porquê e o como aplicar) |
| **project** | Estado/decisões do projeto não deriváveis do código |
| **reference** | Onde buscar info externa (dashboards, tickets, docs) |

`MEMORY.md` é **índice** — uma linha por memória, conteúdo em arquivos separados. Memórias
de `feedback`/`project` registram o porquê para sobreviver a edge cases.

**Higiene é a manutenção primária:** *podar* memória obsoleta antes de adicionar nova; rodar
`/compact` entre 70–90% de uso; e **nunca duplicar** na `CLAUDE.md` o que a IA já memorizou —
cada linha duplicada é um slot desperdiçado. E o anti-padrão mais comum: **não salve padrões
de código na memória** — isso já está no repo; leia o repo.

> Esta apresentação está sendo construída sobre memória persistente: o relacionamento entre
> o repo showcase e o boilerplate, e a sua preferência por trabalhar docs passo-a-passo,
> vieram de memórias gravadas em sessões anteriores.

**Gancho.** Memória guarda o que aprendemos; o próximo capítulo disciplina como planejamos.

# Capítulo 10 — Princípios de planning

**Abertura.** Plano genérico cobre o happy path e esquece o que quebra em produção.

Planos genéricos cobrem o happy path e esquecem o resto: edge cases (input vazio, race
conditions, timezone), admin surface para novos models, atualização de docs, testes para
business rules, e a fase de hardening. O resultado é um PR que "funciona" mas viola
invariantes silenciosamente — ou cria abstração com 1 call site e dívida técnica imediata.

**Planning não é arte, é checklist.** Princípios verificáveis para toda mudança não-trivial:

1. **Simples primeiro** — duas linhas similares > abstração prematura.
2. **Mapeie happy path E edge cases** — vazios, malformados, permissões, falhas parciais.
3. **Modelo novo shipa com admin surface completo** (list + detail + edit + delete).
4. **Docs fazem parte da mudança** — comportamento mudou, doc muda no mesmo PR.
5. **Challenge over-engineering** — toda abstração precisa de 2+ call sites *hoje*.
6. **Use skills antes de planejar** — `brainstorming`/`writing-plans`/`systematic-debugging`.
7. **Testes para business rules** — calculator, state machine, eligibility.
8. **Fases com checkpoints** — a última fase é sempre **hardening**, nunca "ship it".
9. **Paralelize trabalho independente** — múltiplas tool calls numa só mensagem.

"Não-trivial" = toca > 1 subsistema, ou introduz invariante, ou tem efeito user-visible.

> Estes princípios moram na `CLAUDE.md` raiz (não numa skill isolada), porque devem valer
> em *todo* plano — é a Camada 1 do modelo mental do Capítulo 2 em ação.

**Gancho.** Com o plano sob controle, falta o ambiente crescer sozinho — sem passos manuais.

# Capítulo 11 — Automação auto-incremental

**Abertura.** Setup manual não escala nem se reproduz; o ambiente precisa crescer em passos rastreáveis.

Setup e evolução de projeto acumulam passos manuais (venv, deps, migração, seed admin,
Celery). Sem disciplina, cada um vira não-reproduzível ("funciona na minha máquina"),
não-idempotente (rodar de novo duplica/quebra) e sem rastreabilidade (ninguém sabe o que
já foi aplicado).

**Dois mecanismos fazem o ambiente crescer sozinho, sem regressão:**

- **Bootstrap idempotente** — detecta o que já existe e só completa o que falta (venv, deps,
  `.env`, migração). Roda quantas vezes quiser sem quebrar o estado.
- **Engine de increments** — cada capacidade nova entra como `NNN_descricao.sh` (também
  idempotente); o aplicado é gravado em `STATE`; rodar de novo **pula** o que já consta.

**Detalhes que importam:** zero-padding na numeração (`001_`, senão `10` ordena antes de
`2`); **nunca editar** um increment já aplicado — crie um novo `NNN`; e o CI roda o mesmo
lint/test do ambiente local. Onboarding vira "clone + 1 comando".

> Este repo *é* o case study: `scripts/bootstrap.sh` idempotente +
> `scripts/increments/` com `apply_increments.sh`, `STATE` e `001_seed_admin.sh`. É o
> padrão do `make bootstrap` que sobe o ambiente inteiro do zero.

**Gancho.** Chega de teoria: o próximo capítulo mostra tudo isso junto num repo real.

# Capítulo 12 — Case study: boilerplate Django 6 + Vue 3

**Abertura.** Aqui os artefatos saem do conceito e viram um repo que você pode clonar hoje.

Aqui os artefatos param de ser conceito e viram um repo que você pode clonar. O boilerplate
deste repositório é um fullstack real **Django 6 + DRF** (backend API em `/api/`, auth JWT,
`apps/accounts` e `apps/core`) + **Vue 3.5 + Vite** (SPA com Pinia, vue-router e interceptor
de JWT), e — mais importante para nós — uma **configuração de Claude Code** que põe os 11
capítulos anteriores para trabalhar juntos:

| Camada / artefato | No repo |
|---|---|
| Regras estáticas (Cap. 2–3) | `CLAUDE.md` raiz: stack, comandos, convenções, regras críticas |
| Hooks (Cap. 4) | guardrails de lint/migration/branch + ativação de skills por path |
| Skills (Cap. 7) | `onboard`, `ticket`, `pr-review`, `code-quality`, `docs-sync`, `systematic-debugging`… |
| Plan-mode (Cap. 8) | `plansDirectory` versionado no repo |
| Memória (Cap. 9) | índice + memórias `feedback`/`project`/`reference` |
| Automação (Cap. 11) | `scripts/bootstrap.sh` + `scripts/increments/` + `STATE` |

**A lição central:** nenhum artefato isolado faz a diferença — o ganho vem da **composição**.
O hook sugere a skill; a skill respeita o `CLAUDE.md`; o plano vira commit; o commit dispara
o guardrail; a memória preserva o que aprendemos. O ambiente inteiro é versionado, revisável
e cresce em increments rastreáveis.

> Demo ao vivo: `make bootstrap` sobe tudo; abrir uma tarefa aciona a skill `onboard`/`ticket`;
> um plano em plan-mode vira commit que passa pelos guardrails. O repo é, ao mesmo tempo, o
> produto e a documentação executável da tese.

**Gancho.** Ver tudo pronto impressiona, mas ninguém adota de uma vez — vem a estratégia por fases.

# Capítulo 13 — Adoção por fase: Dia 0 → Mês 3

**Abertura.** Adotar tudo no dia 1 é receita para desistir; o segredo é avançar por fases.

Ninguém adota tudo isso de uma vez — quem tenta, desiste. A regra é **distribuir em fases**,
provando valor em cada uma antes de avançar.

**Dia 0 — Fundação (1 dia).** `CLAUDE.md` raiz com o mínimo (gates obrigatórios, stack,
arquitetura, planning principles); `plansDirectory` configurado; bootstrap "clone + 1
comando". *Resultado: a IA já entra sabendo o básico do projeto.*

**Semana 1 — Guardrails (3–5 dias).** 1–2 hooks de PostToolUse (auto-format + lint);
`<app>/CLAUDE.md` nos apps com convenção própria; `scripts/increments/` + `STATE`. *Resultado:
erros mecânicos param de chegar no review.*

**Mês 1 — Runbooks (1–2 semanas).** 3–5 slash commands para workflows recorrentes; catálogo
em `WORKFLOWS.md`; PreToolUse hooks para invariantes críticas; 1–2 skills repo-specific.
*Resultado: o conhecimento tribal vira procedimento executável.*

**Mês 3 — Especialização (2–4 semanas).** 2–3 sub-agents (review, schema, invariantes);
um comando orquestrador (`/deep-review`, `/prepare-pull-request`); memória persistente para
feedback recorrente; skills compostas em pipeline. *Resultado: o ambiente trabalha como um
time de especialistas.*

> Comece pelo que mais dói hoje. Se o problema é "a IA esquece as regras", Dia 0. Se é "erros
> bobos no review", Semana 1. A ordem é um guia, não um dogma.

**Gancho.** No caminho, alguns erros se repetem tanto que merecem um capítulo só para eles.

# Capítulo 14 — Anti-padrões e armadilhas

**Abertura.** Conhecer os acertos ajuda; evitar os erros recorrentes ajuda ainda mais.

Os erros mais comuns, consolidados. Se você só lembrar de uma coisa do workshop, lembre de
evitar estes:

- **Instrução na camada errada.** Procedimento on-demand na `CLAUDE.md` (lido sempre, infla
  contexto); regra inviolável só na memória (que pode ser podada). → Capítulo 2 resolve.
- **Mesma instrução em duas camadas.** Duas fontes de verdade que divergem com o tempo.
- **Instruções negativas vagas** ("seja cuidadoso com X"). Não-verificáveis — a IA não sabe
  quando aplicou. Troque por comando de verificação + hook de bloqueio.
- **Regra sem comando de verificação.** "Siga a convenção Y" sem como provar conformidade
  vira religião.
- **Hook onde precisa de julgamento**, ou hook lento (> 2s), ou hook que silencia warning.
  Hook é zero-variância e fail-loud — ou não é hook.
- **Sub-agent sem tools restritas** — vira `general-purpose` disfarçado e perde a vantagem.
- **Skill que sobrescreve feedback do usuário** — skill é diretriz, não dogma.
- **Memória sem o porquê** ou `MEMORY.md` inchado — não sobrevive a edge cases, ou estoura
  o contexto inicial.
- **`CLAUDE.md` desatualizado** — *pior do que nenhum*: se ele descreve um monólito e o
  sistema já são seis serviços, toda sugestão sai sutilmente errada.
- **Plano sem `Context`/`Verificação`/fases** — não dá pra retomar nem auditar depois.

> O padrão atravessa todos: **o que não é verificável, não é confiável.** Toda regra,
> comando, hook e plano deve ter um sinal observável de "deu certo".

**Gancho.** Evitados os erros de hoje, vale olhar para onde o Claude Code está indo.

# Capítulo 15 — Oportunidades futuras e evolução

**Abertura.** O que é experimental hoje vira padrão em meses — manter um radar é parte do trabalho.

Claude Code evolui rápido: o que é experimental hoje vira estável em meses. Mantenha um
radar — *projeção fundamentada, não doutrina* (🔮).

**Hoje, no radar.** Janela de 1M de contexto (planos longos viáveis); **fast mode** (output
rápido sem perder capacidade); família **Claude 4.x** com trade-offs claros (Opus para
planning/review, Sonnet para implementação, Haiku para hooks/scripts); IDE extensions
movendo parte do workflow do CLI para o editor; MCP servers maduros (Slack, Notion, GitHub).

**Amanhã, com gate (beta).** Output styles por tipo de tarefa; **Agent SDK / Managed Agents**
(session persistence, memory stores, background); plugins que empacotam commands + skills +
agents juntos; marketplace de MCP servers.

**Experimentos 🔮.** Hooks dinâmicos por tipo de arquivo; skills cross-repo via submódulos/
pacotes; telemetria de uso de skills (quais economizam mais tempo?); memory sharing no nível
do time; execução paralela de planos em worktrees com merge da melhor implementação.

**Sunset — não introduza mais.** Instruções negativas vagas; comandos sem matriz de gates;
sub-agents sem tools restritas; memórias sem o porquê; `CLAUDE.md` monolítica > 2000 linhas.

> Política: revise este radar a cada 6 meses. Item sem fonte oficial fica em "experimento";
> item que não evolui em 3 revisões é aposentado. O ambiente de IA é infraestrutura viva —
> trate a evolução dele como você trata a do seu pipeline de CI.

**Gancho.** Fechado o radar, é hora de amarrar a tese que atravessou todos os capítulos.

# Conclusão

Começamos com um problema concreto: **toda sessão de IA nasce do zero**. A resposta não foi
um prompt mais esperto, e sim uma mudança de postura — **tratar os artefatos de IA como
infraestrutura versionada**, com ownership, review e atualização contínua.

O fio condutor foi sempre o mesmo: *contexto é um ativo*, e cada artefato é uma forma de
torná-lo durável. O modelo das **4 camadas** diz onde cada instrução vive; as **3 lentes**
(Criar → Preservar → Automatizar) organizam o ciclo de vida; e o **princípio-mãe** amarra
tudo — *a IA se adapta ao seu projeto, não o contrário*.

O ganho real não vem de nenhum artefato isolado, mas da **composição**: hooks que sugerem
skills, skills que respeitam o `CLAUDE.md`, planos que viram commits que passam por
guardrails, memória que preserva o aprendizado. O boilerplate Django + Vue mostrou isso
num repo que você pode clonar hoje.

> Se a IA recomeça do zero, a culpa é do ambiente — e o ambiente é seu para construir.

# Next Steps

**Para você, ainda hoje:**

- **Clone o boilerplate** e rode `make bootstrap` — veja o ambiente inteiro subir com um
  comando, e os artefatos de Claude Code já configurados.
- **Adote o Dia 0** (Capítulo 13) no seu projeto: um `CLAUDE.md` raiz enxuto + `plansDirectory`
  versionado. É uma tarde de trabalho e já corta a re-explicação eterna.

**Nas próximas semanas:**

- Avance pelas fases **Semana 1 → Mês 3** conforme a dor: guardrails primeiro, depois runbooks,
  depois especialistas.
- Use o [best_practices.md](../best_practices.md) como referência viva — cada capítulo tem
  Problema → Princípio → Anti-padrões → Template → Checklist de adoção.

**Para manter vivo:**

- Reserve a revisão semestral do radar de evolução (Capítulo 15).
- Trate cada `CLAUDE.md`, skill, hook e plano como código: revisado, versionado, atualizado.

> Material de apoio: `best_practices.md` (o guia completo), `docs/ARCHITECTURE.md` (o
> boilerplate) e `docs/REFERENCES.md` (showcases e docs oficiais para se aprofundar).
