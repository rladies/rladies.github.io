# RLadies+ Website - AI Coding Instructions

**Accessibility is a high priority.** All changes must maintain or improve WCAG compliance.

## Architecture Overview

Hugo static site with Tailwind CSS 4.1+ theme, data-driven from multiple sources:
- **Local data**: `data/chapters/`, `data/directory/`, `data/global_team/`, `data/rblogs/`
- **Remote data**: Fetched at build from `rladies/meetup_archive` (events, chapter metadata)
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

### How Frontmatter Translation Works

babeldown's `deepl_translate_hugo()` only translates **top-level string fields** (`title`, `description`, `summary`). It cannot handle nested YAML structures.

For pages with complex nested frontmatter (FAQ, Involved, Mentoring, etc.), `translate_content.R` runs a second pass that recursively walks nested YAML and translates all string values via `deepl_translate_markdown_string()`.

**Nested fields translated**: `faq`, `pillars`, `sections`, `ctas`
**Keys skipped within nested structures**: `icon`, `url`, `style`, `type`, `layout`, `weight`, `home`, `slug`, `aliases`, `source`, `image`, `outputs`, `cascade`, `date`, `directory_id`, `path`, `alt`

When adding new content types with translatable nested frontmatter, update `NESTED_FIELDS` in `scripts/translate_content.R`. When adding new non-translatable keys within nested structures, update `SKIP_KEYS`.

### Translation Quality: Glossaries and Style

- **Style guide**: `translation/style-guide.md` — defines RLadies+ brand voice for translations (warm, professional, empowering, informal address)
- **Glossaries**: `translation/glossary-en-{es,pt,fr}.csv` — term mappings synced to DeepL automatically via `deepl_upsert_glossary()` before each translation run
- **Style rules**: `translation/deepl-styles.yaml` — stores the DeepL style_id (created in DeepL web UI). Applied to nested frontmatter translation via direct API call. Body text via babeldown uses glossary + formality only.
- **Formality**: DeepL uses `prefer_less` for es, pt, fr (conversational tone matching the brand)
- **Brand terms**: RLadies+, R, Meetup, Slack, GitHub etc. must never be translated (see glossary)
- **Inclusive language**: Translations prefer gender-neutral wording; see style guide for per-language strategies

When adding new brand terms, update the glossary CSVs in `translation/` — they are uploaded to DeepL automatically on the next translation run.

## Build Pipeline

GitHub Actions workflow:
1. R scripts process Airtable data
2. Clone external repos (`directory`, `awesome-rladies-blogs`) for additional data
   - `meetup_archive` data is fetched at Hugo build time via remote resources (see `funcs/merge_chapters.html` using `resources.GetRemote`) and is not cloned
3. Hugo build with environment config
4. Deploy to GitHub Pages (production) or Netlify (preview)

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
