# Referências

Coletânea de links úteis para o projeto. Mantida manualmente.

## Claude Code — boilerplates, showcases e exemplos (Python)

Pesquisa realizada em 2026-05-28. Foco: boilerplates/showcases de Claude Code
com exemplos em Python, úteis como referência de `CLAUDE.md`, hooks, skills e agents.

### Showcases (infra completa: hooks, skills, agents, commands)

- [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) — exemplo mais completo: hooks, skills, agents, commands e GitHub Actions. Inclui template de `CLAUDE.md`.
- [mhosavic/claude-code-showcase](https://github.com/mhosavic/claude-code-showcase) — plugins de referência (skills, marketplaces, hooks, subagents, MCP server), tour interativo e currículo de 13 conceitos.
- [diet103/claude-code-infrastructure-showcase](https://github.com/diet103/claude-code-infrastructure-showcase) — skill auto-activation, hooks e agents.
- [ipeterfulop/claude-code-agent-teams-showcase](https://github.com/ipeterfulop/claude-code-agent-teams-showcase) — time de agentes (orquestrador + subagentes + peer review).
- [Plepic-OU/claude-logiq](https://github.com/Plepic-OU/claude-logiq) — projeto-exemplo demonstrando features do Claude Code.

### Boilerplates / templates Python

- [discus0434/python-template-for-claude-code](https://github.com/discus0434/python-template-for-claude-code) — template Python "Claude Code-centric".
- [iepathos/python-claude-code](https://github.com/iepathos/python-claude-code) — starter Python (type hints, pytest, Black/isort/flake8/mypy, `CLAUDE.md` pré-configurado).
- [Kogia-sima/python-project-template2](https://github.com/Kogia-sima/python-project-template2) — Python + Claude Code + Devcontainer.
- [qlemql/claude-code-boilerplate](https://github.com/qlemql/claude-code-boilerplate) — ciclo de vida (dev→release→ops) com stack overlay para Python (17 commands, 7 agents, 6 hooks).
- [Roentek/Claude_Code_Boilerplate_Framework](https://github.com/Roentek/Claude_Code_Boilerplate_Framework) — workspace agêntico pronto pra clonar (tools, rules, MCP servers, workflows).
- [levu304/claude-code-boilerplate](https://github.com/levu304/claude-code-boilerplate) — padrões de código com config Python (Pydantic + strict type checking).

### Relevante para o stack deste projeto (Django / FastAPI)

- [Chdezreyes76/claude-hexagonal-fsd-framework](https://github.com/Chdezreyes76/claude-hexagonal-fsd-framework) — FastAPI (arquitetura hexagonal) + React 19, automação com Claude Code.
- [KingNonso/python-graphql-mcp-server](https://github.com/KingNonso/python-graphql-mcp-server) — MCP server expondo backend GraphQL Django para o Claude.
- [SeydinaBANE/api-starter-skill](https://github.com/SeydinaBANE/api-starter-skill) — skill que faz scaffold de APIs FastAPI/Flask.

### Documentação oficial (Anthropic)

- [Claude Code — Overview](https://code.claude.com/docs/en/overview) — inclui o comando `/init` que gera um `CLAUDE.md` adaptado ao repo.
- [anthropics/claude-code](https://github.com/anthropics/claude-code) — repo oficial; diretório `plugins/` com exemplos de commands e agents.
- [anthropics/claude-cookbooks](https://github.com/anthropics/claude-cookbooks) — notebooks/recipes oficiais, majoritariamente em Python.
- [Claude Docs / Python SDK](https://platform.claude.com/docs/en/home) — SDK `anthropic` ([PyPI](https://pypi.org/project/anthropic/)).

### Blogs e tutoriais

- [CLAUDE.md Best Practices: The 10-Section Template (Blink Blog)](https://blink.new/blog/claude-md-best-practices)
- [The Ideal Project Structure for Claude Code + 8 templates (Sid Saladi)](https://sidsaladi.substack.com/p/the-ideal-project-structure-for-claude)
- [Claude Code Project Templates for Rapid Scaffolding (claudefa.st)](https://claudefa.st/blog/guide/development/project-templates)
- [Claude Code: A Guide With Practical Examples (DataCamp)](https://www.datacamp.com/tutorial/claude-code)
- [aitmpl.com](https://www.aitmpl.com/) — coleção com 1000+ agents, commands, skills e MCPs.
- [github.com/topics/claude-code-template](https://github.com/topics/claude-code-template) — tópico do GitHub com todos os templates.
