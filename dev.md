# Development Notes

This file records what was changed in this project and how the site is intended to be developed and published.

## Goal

The task in `program.md` asked for a website for Instituto Arariboia based on the existing brainstorm in `instituto_arariboia_work_summary.md` and the first sketch in `arariboia_site/`.

The required publishing model was:

- Hostable on GitHub Pages.
- Mostly static HTML, CSS, and JavaScript.
- Markdown-based publishing for posts.
- Support for LaTeX formulas in posts.

## Chosen Approach

The site was converted into a GitHub Pages-compatible Jekyll site.

This is a good fit because GitHub Pages supports Jekyll natively, and Jekyll gives the project a simple publishing workflow:

1. Create a Markdown file in `_posts`.
2. Add front matter with title, date, category, and summary.
3. Push to GitHub.
4. GitHub Pages builds and publishes the site.

No custom backend is required.

## Files Added

### `_config.yml`

Main Jekyll configuration.

It defines:

- Site title and description.
- Portuguese language setting.
- Sao Paulo timezone.
- Post permalink format.
- Kramdown Markdown rendering.
- MathJax math engine support.
- Default layout and MathJax behavior for posts.
- Excluded files that should not be copied into the generated site.

### `_layouts/default.html`

Shared page shell used by the site.

It contains:

- HTML document structure.
- Metadata.
- Google Fonts.
- Global stylesheet link.
- MathJax loading when enabled.
- Fixed header and navigation.
- Footer with Instagram, YouTube, and contact links.

### `_layouts/post.html`

Shared layout for Markdown posts.

It provides:

- Post title.
- Category.
- Date.
- Summary.
- Rendered Markdown content.
- Link back to the publications index.

### `index.html`

Main homepage.

It keeps the visual direction from the original sketch:

- Institutional hero.
- About section.
- Mission section.
- Areas of activity.
- Featured publications.
- Institutional team section.
- Support/contact section.

The featured publications section now reads from Jekyll posts instead of being purely hardcoded.

### `publicacoes.html`

Publications index page at `/publicacoes/`.

It lists all Markdown posts from `_posts`, showing:

- Category.
- Date.
- Title.
- Summary or excerpt.
- Link to the full publication.

### `_posts/2026-06-01-prudencia-razao-para-a-acao.md`

Sample Markdown post.

It demonstrates:

- Required front matter.
- Normal Markdown text.
- Inline LaTeX with `$...$`.
- Display LaTeX with `$$...$$`.

### `assets/css/styles.css`

Main stylesheet for the Jekyll site.

It extends the original `arariboia_site/styles.css` visual system and adds styles for:

- Publications index.
- Post pages.
- Post typography.
- Code snippets.
- Empty states.
- Page hero sections.

### `.github/workflows/pages.yml`

GitHub Actions workflow for GitHub Pages deployment.

It:

- Runs on pushes to `main`.
- Builds the Jekyll site.
- Uploads the generated `_site` artifact.
- Deploys to GitHub Pages.

### `.gitignore`

Ignores generated Jekyll and local dependency files:

- `_site/`
- `.jekyll-cache/`
- `.sass-cache/`
- `.bundle/`
- `vendor/`

### `README.md`

User-facing publishing instructions.

It explains:

- How to create new Markdown posts.
- Which front matter fields to use.
- How to write LaTeX formulas.
- How GitHub Pages deployment works.
- When to set `baseurl` for project pages.

### `Gemfile`

Defines the local Ruby dependencies used to build the site consistently with GitHub Pages.

It includes:

- `jekyll`
- `kramdown-parser-gfm`
- `webrick`

### `scripts/test-site.sh`

Executable local test helper.

It:

- Checks for Ruby and RubyGems.
- Installs Bundler if needed.
- Installs Ruby gems into `vendor/bundle` instead of the system Ruby path.
- Refuses to run as root unless `ALLOW_ROOT=1` is explicitly set.
- Detects root-owned generated paths left by previous sudo runs.
- Runs `bundle install` when dependencies are missing.
- Builds the Jekyll site with `bundle exec jekyll build --trace`.
- Starts a local Jekyll server at `http://127.0.0.1:4000/`.

Useful commands:

```bash
scripts/test-site.sh
scripts/test-site.sh --build-only
scripts/test-site.sh --host 0.0.0.0 --port 4001
```

## Existing Files Preserved

The original sketch was preserved in:

- `arariboia_site/index.html`
- `arariboia_site/styles.css`

The template zip was also left in place:

- `arariboia_site_template.zip`

These are excluded from the generated Jekyll site through `_config.yml`.

## Publishing New Posts

Create a file in `_posts` using this filename format:

```text
YYYY-MM-DD-title-slug.md
```

Example:

```text
2026-06-01-prudencia-razao-para-a-acao.md
```

Use this front matter:

```yaml
---
title: "Título do texto"
date: 2026-06-01
category: Artigo
summary: "Resumo curto para cards e listagens."
mathjax: true
---
```

Then write the post body in Markdown.

Inline formulas:

```markdown
$a^2 + b^2 = c^2$
```

Display formulas:

```markdown
$$
\int_a^b f(x)\,dx = F(b) - F(a)
$$
```

## Dev And Prod Sites With GitHub Pages

It is possible to have dev and prod versions, but GitHub Pages only publishes one Pages site per repository through the repository's Pages setting.

Recommended options:

### Option 1: Two Repositories

Use one repository for production and one for development.

Example:

- `instituto-arariboia-site` for production.
- `instituto-arariboia-site-dev` for development.

This is the simplest and clearest setup if both sites must be publicly available at stable URLs.

Production might be:

```text
https://institutoarariboia.org
```

Development might be:

```text
https://usuario.github.io/instituto-arariboia-site-dev/
```

### Option 2: One Repository, Two Branches, One Published Site

Use:

- `main` for production.
- `dev` for development.

Only one branch is configured as the live GitHub Pages source at a time.

This is useful for normal development workflow, but it does not give you two public GitHub Pages sites from the same repository.

### Option 3: One Repository, GitHub Actions Preview Artifacts

Keep production deployed to GitHub Pages from `main`, and use GitHub Actions to build the `dev` branch as an artifact.

This gives you downloadable previews, but not a stable public dev URL.

### Option 4: GitHub Pages For Prod, Another Static Host For Dev

Use GitHub Pages for production and a preview host for development, such as:

- Netlify deploy previews.
- Vercel preview deployments.
- Cloudflare Pages preview deployments.

This gives the best preview workflow if pull-request previews are important.

## Recommended Workflow For This Project

For a small institutional site, the recommended setup is:

1. Use `main` as production.
2. Use a `dev` branch for changes.
3. Open pull requests from `dev` into `main`.
4. Let GitHub Pages deploy only from `main`.
5. If a public dev site is required, create a second repository dedicated to the dev deployment.

This keeps production stable while preserving a simple publishing workflow.

## Verification Performed

The following checks were run locally:

- YAML parsing for `_config.yml`, workflow YAML, and front matter.
- Liquid template parsing for layouts and pages.
- Markdown parsing for the sample post.

A full local `jekyll build` was attempted, but the environment does not have the Ruby development headers required by one native gem. The GitHub Actions Pages environment should provide the correct build environment for deployment.

## Latest Content Update

The institutional copy from `infos.md` was incorporated into the homepage.

Changes made:

- Replaced the placeholder "Sobre o Instituto" text in `index.html`.
- Expanded the about area into sections for the Institute's identity, foundation, and activities.
- Updated the patron section with Martim Afonso Arariboia copy.
- Updated the areas of activity to match the stated formation lines: cultura clássica, história brasileira, and teoria política e social.
- Replaced the placeholder contact email with `institutoarariboia@gmail.com`.
- Added `info.md` and `infos.md` to `_config.yml` excludes so source notes are not published as raw site files.

## Portinari Image Update

The visual placeholders were replaced with local images fetched from the Projeto Portinari catalogue.

Files added:

- `assets/images/portinari-brasil.jpeg`
- `assets/images/portinari-indio.jpeg`
- `assets/images/portinari-pau-brasil.jpeg`
- `assets/images/portinari-indios-carregando-pau-brasil.jpeg`
- `IMAGE_SOURCES.md`

Usage:

- Homepage hero uses `Brasil`.
- Patron section uses `Índio`.
- Featured publication image uses `Pau-Brasil`.

The homepage includes visible attribution links to the catalogue pages for the images shown.

## Publish Folder

A deploy-ready folder named `institutoarariboia.github.io` was created.

It contains the files relevant for a GitHub Pages repository:

- Jekyll config and pages.
- Layouts and posts.
- CSS and image assets.
- GitHub Pages workflow.
- README, development notes, image source notes, and local test script.

It intentionally excludes earlier scratch/template files such as `program.md`, `instituto_arariboia_work_summary.md`, `arariboia_site/`, `arariboia_site_template.zip`, and generated build output.

## Header Logo Update

The header brand mark was changed from the placeholder text `IA` to the Instituto Arariboia profile image.

Files changed:

- `_layouts/default.html`
- `assets/css/styles.css`
- `assets/images/logo-arariboia.jpg`
- `IMAGE_SOURCES.md`

## Institutional Section Hidden

The placeholder `Institucional` section was removed from the homepage for now.

Changes made:

- Removed the `#equipe` section from `index.html`.
- Removed the `Equipe` navigation link from `_layouts/default.html`.
