# Repository for the R-Ladies website

<!-- badges: start -->

[![Netlify Status](https://api.netlify.com/api/v1/badges/3bf48c17-2bd3-4452-83cb-0ac808ad745b/deploy-status)](https://app.netlify.com/sites/rladies-dev/deploys)

<!-- badges: end -->

This repository contains the source files for the R-Ladies website.
The site is built with [hugo](https://gohugo.io/) and [netlify](www.netlify.com)

Information about the site internals and setup can be found in the repo [wiki](https://github.com/rladies/website/wiki)

## Contribute to the site development

There are many types of contributions we are happy to receive, for instance:

- [Blog guest entry](https://github.com/rladies/website/wiki/Adding-a-new-blog-entry-or-translation)
- [Add a site language](https://github.com/rladies/website/wiki/Adding-a-new-language)
- [Add a Press appearances](https://github.com/rladies/website/wiki/Adding-press-entries)
- [Adding a chapter](https://github.com/rladies/website/wiki/Adding-a-chapter)
- [Retiring former chapter organizers](https://github.com/rladies/rladies.github.io/wiki/Retiring-former-chapter-organizers)
- [Adding Mentoring program entries](https://github.com/rladies/website/wiki/Adding-entries-to-the-mentoring-program-page)
- [Adding/changing a pretty URL to an R-Ladies form](https://github.com/rladies/website/wiki/Adding-form)
- [Bug reports](https://github.com/rladies/website/issues/new)
- Responding to and/or fixing [issues](https://github.com/rladies/website/issues)

If you want to contribute to the site, the best option is to branch the repo if you have access.
PRs from branches will render previews, while PRs from forks will not.
If you do not have access to branch the repo, fork and PR when ready, and tag @rladies/website for review.

[Learn more about working with a local git copy of the website](https://github.com/rladies/website/wiki/Working-on-a-local-copy)

### Reports of bugs

Please report any bugs or issues on the page on [github issues](https://github.com/rladies/website/issues).
You can also use this same link to request content you feel is missing.
If you would like to give us a hand at fixing some of the issues listed, we would greatly appreciate that.

## Visualisation of build process

```mermaid
graph TB

A[Checkout repository] --> B[Get Hugo version]
B --> C[Install cURL Headers]
C --> D[Setup R]
D --> E[Setup renv]
E --> F["Populate untranslated pages\n(scripts/missing_translations.R)"]

subgraph Site Data
  F --> G["Get directory data\n(rladies/directory)"]
  F --> H["Meetup\n(rladies/meetup_archive)"]
  F --> I["Get blogs list\n(rladies/awesome-rladies-blogs)"]
  G --> J["Clean cloned repos"]
  J --> K["Merge chapter and meetup\n(scripts/get_chapters.R)"]
end

H --> J
I --> J
K --> L[Setup Hugo]
L --> M[Build]

M -->|Production| N[Deploy]

M -->|Preview| O[Install netlify cli]
O --> P[Deploy Netlify]
P --> Q["Notify PR about build"]

```
