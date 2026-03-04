# RLadies+ Translation Style Guide

This guide defines the voice, tone, and conventions for translating RLadies+ content.
It applies to both machine translation (DeepL) and human review.

## Brand Voice

RLadies+ communicates in a **warm, professional, and empowering** tone.
Translations must preserve this — never become colder, more formal, or more distant than the original.

### Core Principles

1. **Welcoming over formal** — The tone is encouraging and approachable, not academic or bureaucratic.
2. **Active voice** — Keep the action-oriented feel ("Join a chapter" not "A chapter can be joined").
3. **Direct address** — Use "you" (tú/vous/você) to maintain personal connection. Prefer informal address (tú over usted, tu over vous) unless the language/region strongly favours formal.
4. **Inclusive language** — Use gender-inclusive forms wherever the target language allows. See language-specific notes below.
5. **Enthusiastic** — Keep exclamation marks where the original has them. The enthusiasm is genuine, not performative.
6. **"We" for the organisation** — RLadies+ speaks as a collective ("We welcome", "Our mission").

### Formality

DeepL formality setting: **"less"** for es, pt, fr (conversational, approachable tone).

The brand sits between casual and formal. It is:
- Professional enough for organisational communication
- Warm enough that newcomers feel welcome
- Never stiff, bureaucratic, or condescending

## Terms That Must Not Be Translated

Keep these in English (or their original form) in all languages:

- **RLadies+** — Always written as-is, capital R and L, plus sign attached
- **R** — The programming language, always capitalised
- **Meetup** — When referring to the platform (lowercase "meetup" for the general concept can be translated)
- **Slack**, **GitHub**, **Mastodon**, **Bluesky** — Platform names
- **useR!** — The conference name
- **posit::conf** — Conference name
- **Bioconductor**, **CRAN**, **RStudio**, **Shiny**, **tidyverse** — R ecosystem proper nouns
- **Code of Conduct** — Use the established translation in each language (see glossary), never paraphrase

## Terms With Specific Translations

See the glossary CSV files in `translation/` for the authoritative term mappings per language.
Key categories:

### Community Roles
- **organiser** — Use the established translation; apply inclusive gender forms
- **speaker** — Use gender-neutral or inclusive forms where possible
- **mentor/mentee** — Some languages have adopted these as loanwords

### Organisation Concepts
- **chapter** — Has a specific translation in each language (capítulo/chapitre), do not use "grupo" or "section"
- **Global Team** — Use the established translation, always capitalised
- **community member** — Never "user" for people; "user" is for software only
- **minority genders** — This is a specific inclusive framework; translate the concept faithfully, do not substitute with "women" or "diverse genders"

### Technical Terms
- **R package** — Has language-specific translations
- **open source** — Some languages keep the English term (French), others translate (Spanish, Portuguese)
- **abstract** (as in conference abstract) — Use the academic/conference term in each language

## Gender-Neutral and Inclusive Language

RLadies+ is a gender diversity organisation. Our language must reflect that.
**Prefer gender-neutral wording wherever the target language allows.**

### General Principles

1. **Default to neutral** — When referring to people in general (community members, participants, contributors), choose gender-neutral constructions first. Only use gendered forms when no natural neutral alternative exists.
2. **Avoid masculine generics** — Never use the masculine form as a stand-in for mixed or unknown groups. This applies to all target languages.
3. **Restructure before splitting** — Rewriting a sentence to avoid gendered forms entirely is usually better than using split forms (e.g., "quienes organizan" is more readable than "los/las organizadores/as").
4. **Use plural or collective nouns** — "the organising team" instead of "the organisers", "the community" instead of "members", "people who speak" instead of "speakers" — when the result reads naturally.
5. **Respect the reader** — Inclusive language should feel natural, not performative or distracting. If an inclusive form makes a sentence awkward or hard to read, find a different construction.

### Strategies by Language

#### Spanish (es)
- **Preferred**: Neutral reformulations — "personas organizadoras", "quienes participan", "la comunidad"
- **Acceptable**: Split forms (organizador/a, usuario/a) when restructuring is awkward
- **Avoid**: Masculine generic ("los usuarios"), -x endings ("usuarixs"), -e endings ("usuaries") — these are not yet widely accepted in formal contexts
- Use **tú** (informal "you") for direct address, not usted

#### Portuguese (pt)
- **Preferred**: Neutral reformulations — "pessoas que organizam", "quem participa", "a comunidade"
- **Acceptable**: Split forms (organizador/a) when restructuring is awkward
- **Avoid**: Masculine generic ("os usuários"), -x endings ("usuárixs")
- Use **você** for direct address (works for both PT-PT and PT-BR)

#### French (fr)
- **Preferred**: Neutral reformulations — "les personnes qui organisent", "la communauté", "l'équipe"
- **Acceptable**: Point médian (·) for roles where no neutral form exists: organisateur·rice, utilisateur·rice
- **Avoid**: Masculine generic ("les utilisateurs"), parenthetical feminisation ("les utilisateur(rice)s")
- Use **tu** for direct address (informal, aligned with community tone)
- For plural groups, prefer inclusive doublets or point médian over masculine generic

### Examples

| Instead of | Write |
|---|---|
| "the user should..." | "you should..." (direct address avoids gendered nouns) |
| "he or she can join" | "you can join" or "anyone can join" |
| "contributors and their wives" | "contributors and their partners" |
| "los organizadores deben..." (es) | "quienes organizan deben..." or "el equipo organizador debe..." |
| "les utilisateurs peuvent..." (fr) | "vous pouvez..." or "les personnes inscrites peuvent..." |

## Content-Specific Guidance

### Mission & Values Text
- Translate precisely — these are core organisational statements
- "promote gender diversity in the R community" must be conveyed faithfully
- "reach their programming potential" is about empowerment, not literal physical reaching

### FAQ & How-To Content
- Keep the conversational question-answer format
- Preserve the encouraging, reassuring tone ("Yes! You can...", "Absolutely.")
- Adapt idioms to the target language rather than translating literally

### Blog Posts & News
- Maintain the author's tone — blog posts vary from tutorial to personal essay
- Keep Markdown formatting intact (bold, links, code blocks)
- Do not translate code snippets, function names, or package names

### Calls to Action
- Keep CTAs short and action-oriented
- "Get Involved" → use the established translation from the glossary
- Button labels should be imperative mood, matching the original energy

## Review Checklist for Human Translators

When reviewing an auto-translated page:

- [ ] **Tone**: Does it feel warm and welcoming, not cold or bureaucratic?
- [ ] **Brand terms**: Are RLadies+, R, platform names kept as-is?
- [ ] **Glossary terms**: Are community terms (chapter, organiser, etc.) translated consistently?
- [ ] **Inclusive language**: Are gender-inclusive forms used correctly for this language?
- [ ] **Formality**: Is the register informal/conversational, not overly formal?
- [ ] **Active voice**: Are sentences active, not passive?
- [ ] **Markdown**: Are links, bold, code blocks, and shortcodes intact?
- [ ] **Idioms**: Are idioms adapted (not literally translated)?
- [ ] **Numbers & dates**: Are they formatted for the target locale?
- [ ] **Code**: Are code snippets, function names, and package names untranslated?

## How This Guide Is Applied During Translation

The translation pipeline applies this guide at multiple levels:

### Automatic (every translation run)
- **Glossary** — Term mappings from the CSV files are synced to DeepL and enforced during translation. This covers brand terms, community roles, and technical vocabulary.
- **Formality** — DeepL's `prefer_less` formality setting is applied for es, pt, fr to keep the conversational tone.
- **Style context** — A condensed version of this guide's key principles (tone, gender-neutral language, informal address, language-specific strategies) is passed to DeepL's `context` parameter for nested frontmatter translation (FAQ, pillars, sections, CTAs). This influences DeepL's word choices without being translated itself and is not billed.

### Optional (if configured)
- **DeepL Style Rules** — If a style rule is created in the DeepL web UI (https://deepl.com/custom-rules), the `style_id` in `translation/deepl-styles.yaml` is applied to nested frontmatter. The DeepL UI is limited to structured rules, so this complements the context parameter rather than replacing it.

### Human review only
- The full detail of this guide (gender-neutral strategies per language, content-specific guidance, review checklist) is too rich for any API parameter. Human reviewers should consult this guide when reviewing auto-translated pages.

### What each layer covers

| Layer | Body text | Nested frontmatter | Scope |
|---|---|---|---|
| Glossary | Yes | No (direct API) | Exact term mappings |
| Formality | Yes | Yes | Conversational register |
| Style context | No (babeldown) | Yes | Tone, gender-neutral hints |
| Style rules | No (babeldown) | Yes (if configured) | Structured DeepL rules |
| This guide | Human review | Human review | Full brand voice detail |

## DeepL Style Rules

The RLadies+ DeepL account has a single shared style rule set that encodes brand voice instructions for the translation engine.
Style rules are created in the DeepL web UI at https://deepl.com/custom-rules.

The style_id is stored in `translation/deepl-styles.yaml` and applied during nested frontmatter translation (FAQ, pillars, sections, CTAs).
Body text translated via babeldown uses glossary + formality but not style rules (babeldown does not yet support `style_id`).

### Suggested style rule instructions for the DeepL UI

Use these as custom instructions when creating the style rule:

> Use a warm, welcoming, and empowering tone. Address the reader informally using tú (Spanish), tu (French), or você (Portuguese). Prefer gender-neutral language: use collective nouns and neutral reformulations instead of masculine generics. Keep the tone conversational and encouraging, never bureaucratic or academic. Preserve brand terms like RLadies+, R, and Meetup without translation.

## Updating This Guide

When adding new brand terms or translations, update:
1. The glossary CSV files in `translation/glossary-en-{lang}.csv`
2. Glossaries are synced to DeepL automatically — `translate_content.R` calls `deepl_upsert_glossary()` before each translation run, uploading the latest CSV to the DeepL account
3. If you update the style rule in the DeepL UI, the style_id in `translation/deepl-styles.yaml` only needs updating if it changes
4. The `get_style_context()` function in `translate_content.R` if the condensed context preamble needs updating
5. This style guide if conventions change
