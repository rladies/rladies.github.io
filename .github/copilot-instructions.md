# RLadies+ Website - AI Coding Instructions

**Accessibility is a high priority.** All changes must maintain or improve WCAG compliance.

## Architecture Overview

Hugo static site with Tailwind CSS 4.1+ theme, data-driven from multiple sources:
- **Local data**: `data/chapters/`, `data/directory/`, `data/global_team/`
- **Remote data**: Fetched at build from `rladies/meetup_archive` (events, chapter metadata) and `rladies/awesome-rladies-creations` (online content listing)
- **Content**: Multilingual (en/es/pt/fr) in `content/` with `_index.{lang}.md` pattern

## Key Commands

```bash
hugo server -D                              # Local dev with drafts
hugo --environment production               # Production build
npm install --prefix themes/hugo-rladiesplus  # Install theme dependencies
npm run build --prefix themes/hugo-rladiesplus  # Build/sync vendor assets
```

## Directory Structure

```
config/_default/     # Hugo config (hugo.yaml, params.yaml, menu.yaml, languages.yaml)
content/             # Markdown content (multilingual)
data/chapters/       # Chapter JSON files (urlname, status, organizers, social_media)
data/directory/      # Directory member JSON files
themes/hugo-rladiesplus/ # Theme with Tailwind CSS 4.1+, Alpine.js, amCharts, FullCalendar
scripts/             # R scripts for Airtable/data processing
```

## CSS Architecture

### Tailwind CSS 4.1+ with @apply
- Entry point: `themes/hugo-rladiesplus/assets/css/main.css`
- Uses CSS-first configuration with `@theme` directive for brand tokens
- Semantic component classes via `@apply` in `assets/css/components/*.css`
- Hugo processes CSS via native `css.TailwindCSS` function
- FontAwesome compiled separately via `assets/scss/fontawesome.scss` → Hugo `toCSS`
- All CSS concatenated and fingerprinted in `layouts/partials/head/head.html`

### Brand Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `--color-primary` | `#881ef9` | Headings, buttons, links, interactive elements |
| `--color-primary-light` | `#a64dfc` | Hover states, lighter accents |
| `--color-primary-dark` | `#6b0fd4` | Active states, darker accents |
| `--color-accent-blue` | `#146af9` | Secondary accent |
| `--color-accent-rose` | `#ff5b92` | Tertiary accent |
| `--color-dark` | `#2f2f30` | Body text (Bastille Black) |
| `--color-light` | `#ededf4` | Light backgrounds (Lavender White) |

### Fonts
- **Body**: Poppins (self-hosted, weights 300-700)
- **Code**: Inconsolata Variable (self-hosted)
- Font files in `static/webfonts/google-fonts/`

### Component Files
Semantic CSS classes live in `assets/css/components/`:
`layout.css`, `nav.css`, `hero.css`, `buttons.css`, `cards.css`, `typography.css`,
`forms.css`, `tables.css`, `badges.css`, `footer.css`, `calendar.css`, `maps.css`,
`syntax.css`, `press.css`, `pagination.css`, `misc.css`

## JavaScript

### Alpine.js
Used for all interactive UI components:
- Navbar mobile toggle: `x-data="{ open: false }"`
- Dropdown menus: `x-data="{ dropOpen: false }"`
- Tab panels: `x-data="{ tab: 'current' }"`
- Collapse/expand: `x-show`, `x-transition`, `x-cloak`

### Other JS
- **counter.js**: Vanilla JS animated counters (requestAnimationFrame)
- **FullCalendar**: Standard theme with custom Tailwind CSS styling (no Bootstrap theme)
- **amCharts 5**: Map visualizations
- **Choices.js**: Enhanced select inputs
- **Shuffle.js**: Filterable grid layouts

No jQuery dependency. No Bootstrap JS.

## Data Patterns

### Chapter JSON (`data/chapters/*.json`)
```json
{
  "urlname": "rladies-city",
  "status": "active|inactive|prospective",
  "country": "Country",
  "city": "City",
  "social_media": {"meetup": "urlname", "email": "city@rladies.org"},
  "organizers": {"current": ["Name"], "former": ["Name"]}
}
```
File naming: `country-city.json` (lowercase, hyphenated)

### Data Merging
`themes/hugo-rladiesplus/layouts/partials/head/data.html` loads all data at build time. Chapter data merges with remote meetup_archive via `funcs/merge_chapters.html` partial to add lat/lon, members, timezone.

## Template Conventions

### Hugo Templating
- Use `with` for nil-safe access: `{{ with .Params.field }}...{{ end }}`
- Access page params via `.Params`, not directly on page object
- `isset` only works on maps (`.Params`), not page objects

### Tailwind + @apply Patterns
- Use semantic component classes (`.card`, `.btn-primary`, `.site-container`) over raw utilities
- Layout: `.site-container`, `.site-section`, `.grid-2` through `.grid-5`
- Cards: `.card`, `.card-body`, `.card-title`, `.card-img-top`
- Buttons: `.btn`, `.btn-primary`, `.btn-outline`, `.btn-sm`, `.btn-lg`
- Add new component classes in `assets/css/components/` using `@apply`

### Accessibility
- Use semantic HTML elements (`<nav>`, `<main>`, `<article>`, `<section>`, `<aside>`)
- Definition lists (`<dl>`) require `<dt>`/`<dd>` pairs - use `<div>` with `<p>` if no labels
- External links: `target="_blank" rel="noopener noreferrer"`
- Icons need `aria-hidden="true"` when decorative, or accessible labels when meaningful
- Images require descriptive `alt` text
- Interactive elements need visible focus states
- Color alone must not convey information (use text/icons too)
- Form inputs need associated `<label>` elements
- Use `#2f2f30` (Bastille Black) for body text — `#881ef9` only for large/interactive elements

## Multilingual Content

Files use language suffix: `_index.en.md`, `_index.es.md`, `_index.pt.md`, `_index.fr.md`

Translation strings in `i18n/{lang}.yaml`. Missing translations auto-generated by `scripts/missing_translations.R` with `translated: no` front-matter.

### Translation Status Front-matter

The `translated` field has three states:
- `translated: yes` — human-verified, shown in production
- `translated: auto` — machine-translated (DeepL), shown only in dev/preview
- `translated: no` — placeholder, not translated

### Translation Workflow

1. When content changes on `main`, the `translate-content.yaml` Action auto-translates via babeldown/DeepL
2. A PR is created with `translated: auto` files
3. Translators claim files via GitHub Issues (Translation Review template)
4. Reviewers change `translated: auto` to `translated: yes` in front-matter
5. Reviewed translations merge to `main` and appear in production

### Translation Scripts
- `scripts/translate_content.R` — auto-translate content files using babeldown/DeepL (uses `translate` renv profile)
- `scripts/translation_status.R` — report translation coverage across all content
- `scripts/missing_translations.R` — generate placeholder files for missing language variants

## Build Pipeline

GitHub Actions workflow:
1. R scripts process Airtable data
2. Clone external repos (`directory`) for additional data
   - `meetup_archive` and `awesome-rladies-creations` data are fetched at Hugo build time via remote resources (`resources.GetRemote`) and are not cloned
3. Hugo build with environment config
4. Deploy to GitHub Pages (production) or Netlify (preview)

### R dependencies (renv)

Each R workflow restores one renv profile (`json`, `production`, `airtable`, `dev`); profile dependencies are declared in `DESCRIPTION` under `Config/renv/profiles/<profile>/dependencies`.

Five invariants keep CI from compiling packages from source on the runner:

- Every lockfile — `renv.lock` and `renv/profiles/*/renv.lock` — records the same R version, because `r-lib/actions/setup-r` with `r-version: renv` reads the root `renv.lock` while the workflows restore a profile lockfile.
- Every repository is a dated Posit Package Manager snapshot (`https://packagemanager.posit.co/cran/YYYY-MM-DD`) or an r-universe. A plain CRAN mirror serves source only.
- Every job that restores renv runs on `ubuntu-24.04`, because PPM builds binaries per distro release.
- Every pinned package version is the version that snapshot serves as a *binary* for that image, and no package records a moving repository (PPM's `latest`). PPM keeps older versions only as source, so a lockfile that drifts behind its own snapshot is compiled on the runner.
- PPM builds binaries for the pinned R version at all. The package index is identical for every R version, so the R version is checked against PPM's binaries endpoint. (Asking for a tarball with R's User-Agent is the direct test, but PPM sends no `Vary: User-Agent`, so a CDN edge can answer with whichever variant it cached first — that check passes locally and fails on a runner.)

`scripts/check_renv_consistency.py` enforces all five in the `Validate renv` workflow, and `scripts/install_sysreqs.py` asks PPM which system libraries the profile's packages link against instead of hardcoding them per workflow. Both are covered by `scripts/tests/`, run in the same workflow.

**Refreshing dependencies:** the `Refresh renv lockfiles` workflow runs monthly and on `workflow_dispatch` (optional snapshot date, defaults to yesterday). It re-snapshots every profile on `ubuntu-24.04` and opens a PR with the result, so pins are refreshed on a schedule rather than when CI breaks. Do not snapshot on macOS: PPM's macOS binaries lag its Linux ones, so the versions renv picks there have no Linux binary and CI compiles them from source. The workflow runs `scripts/refresh_renv.R` per profile and then `scripts/pin_renv_snapshot.py`, which sets the R version and snapshot date in the root `renv.lock` and `renv/settings.json`.

`renv` itself is exempt from the binary check: the project bootstraps from the committed `renv/activate.R`, so its version is pinned by that file. Upgrading it means `renv::upgrade()`, not `renv::update()`.

## Common Tasks

### Adding a chapter
Create `data/chapters/country-city.json` with required fields (urlname, status, country, city)

### Modifying layouts
Theme layouts in `themes/hugo-rladiesplus/layouts/`. Override by placing file in root `layouts/` with same path.

### Adding home page sections
Edit `themes/hugo-rladiesplus/layouts/index.html` and create partial in `layouts/partials/home/`

### Adding a CSS component
Create or edit a file in `themes/hugo-rladiesplus/assets/css/components/` using `@apply`, then import it in `assets/css/main.css`.

## Reviewing New Content

### Automated Checks
PRs trigger `check-jsons.yaml` workflow validating JSON against schemas in `scripts/json_shema/`:
- `chapter.json` - Required: status, country, city, social_media, organizers.current
- `global-team.json` - Team member validation
- `mentoring.json` - Mentoring program validation

### Chapter PRs (`data/chapters/*.json`)
1. Verify filename matches pattern: `country-city.json` (lowercase, hyphenated)
2. Check `urlname` matches actual Meetup group URL
3. Validate `status` is one of: `active`, `inactive`, `prospective`
4. Ensure `social_media.meetup` matches `urlname`
5. Confirm `organizers.current` array has at least one name

### Blog PRs (`content/blog/YYYY/MM-DD-slug/`)
1. Front matter has: title, author, date, description
2. Images in same folder, referenced with relative paths
3. Tags exist or are appropriate new additions
4. For translations: `translated: yes` and correct language suffix

### Directory PRs (from `rladies/directory` repo)
Previews triggered via workflow_dispatch with artifact ID. Check:
- Profile photo displays correctly
- Social media links work
- Location renders on map

### Preview Deployments
- PRs get Netlify preview: `https://d{directory}-b{blogs}-r{runid}--rladies-dev.netlify.app`
- Bot comments preview link on PR
- Check: page renders, no Hugo warnings, links work, images load

## Style Guide

- RLadies+ primary: `#881ef9` (defined in `themes/hugo-rladiesplus/assets/css/main.css` as `--color-primary`)
- Fonts: Poppins (body), Inconsolata (code)
- Icons: FontAwesome 6 (`fa-solid fa-*`, `fa-brands fa-*`)
