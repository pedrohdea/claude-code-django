# Slides do Workshop (reveal.js)

Apresentação em slides de [`docs/APRESENTATION.md`](../APRESENTATION.md), renderizada
com [reveal.js](https://github.com/hakimel/reveal.js). O markdown é a **fonte única**:
editar o doc atualiza os slides — cada heading `#` vira um slide.

## Rodar

```bash
make slides          # da raiz do repo
# ou
cd docs/slides && npm install && npm start
```

Abra <http://localhost:8000/slides/>. Porta alternativa: `PORT=9000 npm start`.

## Atalhos (reveal.js)

- `→` / `←` ou `Espaço` — navegar
- `F` — tela cheia · `Esc` / `O` — visão geral (overview)
- `S` — modo apresentador (speaker notes) · `B` — tela preta
- `?` — todos os atalhos

## Customizar

- **Tema:** troque `theme/black.css` por `white`, `league`, `night`, `solarized`… no
  `<link id="theme">` do [index.html](index.html).
- **Tamanho de fonte / cores:** bloco `<style>` no topo do `index.html`.
- **Quebra de slides:** hoje é 1 slide por `#`. Capítulos longos rolam dentro do slide;
  para paginar melhor, dá para evoluir o split (ex.: quebrar por `**Abertura.**` /
  `**Gancho.**`) no script de carregamento do `index.html`.

## Estrutura

- `index.html` — carrega o markdown via `fetch` e monta os slides.
- `server.mjs` — servidor estático sem dependências (serve `docs/` para o `fetch` do
  `../APRESENTATION.md` funcionar). `npm start` → `node server.mjs`.
- `node_modules/reveal.js` — biblioteca (local, funciona offline). Não versionado.
