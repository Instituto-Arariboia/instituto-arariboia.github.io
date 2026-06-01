# Instituto Arariboia

Site estático preparado para GitHub Pages com Jekyll. A página institucional fica em `index.html`, a listagem de textos em `publicacoes.html` e as publicações ficam em `_posts`.

## Publicar um texto

Crie um arquivo Markdown em `_posts` usando o formato:

```text
YYYY-MM-DD-titulo-do-texto.md
```

Inclua o cabeçalho:

```yaml
---
title: "Título do texto"
date: 2026-06-01
category: Artigo
summary: "Resumo curto para cards e listagens."
mathjax: true
---
```

Depois escreva o conteúdo em Markdown. Fórmulas LaTeX são aceitas com `$...$` para expressões inline e `$$...$$` para blocos.

Ao enviar o arquivo para a branch `main`, o workflow `.github/workflows/pages.yml` publica o site no GitHub Pages.

Se o site for publicado em uma página de projeto, como `https://usuario.github.io/repositorio/`, ajuste `baseurl` em `_config.yml` para `"/repositorio"`. Para domínio próprio ou página de usuário/organização, mantenha `baseurl` vazio.

## Testar localmente

Execute:

```bash
scripts/test-site.sh
```

O script instala as dependências Ruby declaradas no `Gemfile`, faz um build do Jekyll e inicia o servidor local em:

```text
http://127.0.0.1:4000/
```

Não execute o script com `sudo`. Ele instala as gems localmente em `vendor/bundle`.

O `Gemfile` usa Jekyll diretamente para o ambiente local. A publicação em produção continua sendo feita pelo workflow de GitHub Pages em `.github/workflows/pages.yml`.

Para apenas testar o build sem iniciar servidor:

```bash
scripts/test-site.sh --build-only
```

Se a instalação de gems nativas falhar em Ubuntu/Debian, instale:

```bash
sudo apt update
sudo apt install -y ruby-full ruby-dev build-essential zlib1g-dev
```

Se você já executou o script com `sudo`, alguns arquivos gerados podem ter ficado com dono `root`. Corrija com:

```bash
sudo chown -R "$(id -u):$(id -g)" Gemfile.lock _site .bundle vendor 2>/dev/null || true
```
