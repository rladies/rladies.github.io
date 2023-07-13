
# Repository for the R-Ladies website

<!-- badges: start -->

[![Netlify Status](https://api.netlify.com/api/v1/badges/3bf48c17-2bd3-4452-83cb-0ac808ad745b/deploy-status)](https://app.netlify.com/sites/rladies-dev/deploys)


<!-- badges: end -->

This repository contains the source files for the R-Ladies website. 
The site is built with [hugo](https://gohugo.io/) and [netlify](www.netlify.com)

Information about the site internals and setup can be found in the repo [wiki](https://github.com/rladies/website/wiki)

## Contribute to the site development
There are many types of contributions we are happy to receive, for instance:
- [Site and page translations](https://github.com/rladies/website/wiki/Adding-a-new-language)   
- [Bug reports](https://github.com/rladies/website/issues/new)  
- Responding to and/or fixing [issues](https://github.com/rladies/website/issues)  

If you want to contribute to the site, the best option is to branch the repo if you have access. 
PRs from branches will render previews, while PRs from forks will not. 
If you do not have access to branch the repo, fork and PR when ready, and tag @drmowinckels for review. 
She will get to it asap.

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
M --> N[Deploy]
```