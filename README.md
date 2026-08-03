# lyndeno.ca

The source for [lyndeno.ca](https://lyndeno.ca) — a [Hugo](https://gohugo.io)
static site with a custom theme, built and deployed reproducibly with Nix.

## Layout

```
.
├── flake.nix              # Nix build: `website` package + `og-image` generator
├── flake.lock
├── config.toml            # Site config: baseURL, params, menu, taxonomies, markup
├── archetypes/            # Front-matter template for `hugo new`
├── content/               # All page + post content (Markdown)
│   ├── _index.md          # Home page
│   ├── about.md           # /about
│   ├── consulting.md      # /consulting
│   ├── resume.md          # /resume (redirects to the PDF on GitHub)
│   └── posts/             # Blog posts, filed by YYYY/MM-Mon/
│       └── 2026/01-Jan/2026-01-16-nixos-repart-image.md
├── static/                # Copied verbatim to the site root
│   ├── CNAME              # Custom domain for GitHub Pages (lyndeno.ca)
│   └── assets/img/        # avatar.jpg, favicons/ (og-default.jpg is generated)
├── themes/lsanche/        # The custom theme
│   ├── assets/css/style.css   # All styling (fingerprinted at build time)
│   ├── layouts/
│   │   ├── _default/           # baseof, single, list, terms, redirect
│   │   │   └── _markup/         # render hooks (code blocks)
│   │   ├── partials/           # head, sidebar, footer, metadata, tags,
│   │   │                       #   schema (JSON-LD), icon
│   │   ├── index.html          # Home template
│   │   └── index.json          # Client-side search index (/index.json)
│   └── theme.toml
└── .github/workflows/deploy.yml   # CI: nix build → GitHub Pages
```

Notable details:

- **URLs** follow the content path, e.g. `content/posts/2026/01-Jan/...md` →
  `/posts/2026/01-jan/.../`. Old Jekyll URLs are preserved via `aliases` in each
  post's front matter.
- **Search** is client-side: `index.json` emits a JSON index that the script in
  `baseof.html` fetches and filters live.
- **SEO**: `partials/head.html` emits Open Graph / Twitter meta and
  `partials/schema.html` emits JSON-LD structured data.

## Building and developing

```bash
# Live-reload dev server (add -D to include drafts)
hugo server

# Reproducible production build (output in ./result)
nix build .#website

# Dev shell with hugo + imagemagick on PATH
nix develop
```

Deployment is automatic: pushing to `master` triggers
`.github/workflows/deploy.yml`, which runs `nix build .#website` and publishes
the result to GitHub Pages.

## The social-share banner (og-image)

The 1200×630 link-preview image (`static/assets/img/og-default.jpg`) is **not
committed** — it is generated from `static/assets/img/avatar.jpg` by the
`og-image` Nix package (see `flake.nix`). The production build regenerates it
automatically, but for a local `hugo server` preview you need a copy on disk.

Regenerate the local copy (e.g. after a fresh clone, or after editing the
avatar or the banner's design in `flake.nix`):

```bash
nix build .#og-image && cp -L result static/assets/img/og-default.jpg
```

## Writing a post

Posts live under `content/posts/`, organized `YYYY/MM-Mon/`. Create one with:

```bash
hugo new posts/2026/07-Jul/2026-07-29-my-new-post.md
```

That seeds the front matter from `archetypes/default.md`. A typical post header:

```yaml
---
title: My New Post
date: 2026-07-29 09:00:00 -0600
categories: [Tutorials]        # shown in post metadata
tags: [nix, linux]             # lowercase; power related-posts + search
draft: true                    # remove (or set false) to publish
---

Post body in Markdown…
```

Notes:

- **Drafts** (`draft: true`) are hidden from the built site; preview them with
  `hugo server -D`.
- **Tags** drive both the "Related posts" section and search, so keep them
  lowercase and relevant. They show only on the post page, not in listings.
- To **preserve an old URL**, add an `aliases` list — Hugo emits a redirect:
  ```yaml
  aliases:
    - /posts/my-old-slug/
  ```

### Giving a post its own share image

By default every page uses the generated `og-default.jpg` banner for link
previews. To override it for a specific post, drop an image in
`static/assets/img/` and reference it with the `image` front-matter key:

```yaml
---
title: My New Post
date: 2026-07-29 09:00:00 -0600
image: /assets/img/my-post-banner.png
---
```

The path is site-relative (resolved to an absolute URL at build time) and is
used for `og:image`, `twitter:image`, and the JSON-LD `image`. For the best
previews use a wide image (ideally 1200×630); the explicit banner dimensions
are only emitted when the default banner is in use.
