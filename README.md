# R-Ladies global blog

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Clone the project](#clone-the-project)
	- [Install the dependecies](#install-the-dependecies)
- [Write a new blog post](#write-a-new-blog-post)
	- [Header of your post](#header-of-your-post)
	- [After you write your post](#after-you-write-your-post)
- [PR your changes](#pr-your-changes)
- [Editors](#editors)
- [Maintainers](#maintainers)

<!-- /TOC -->

## Clone the project

Clone the project.

- SSH: `$ git clone git@github.com:rladies/blog.git`
- HTTPS: `$ git clone https://github.com/rladies/blog.git`

Open the folder in RStudio.

### Install the dependecies

```r
install.packages(c('blogdown', 'magrittr', 'stringr'))
```

## Write a new blog post

Create a new file `.Rmd` in the folder `content > post`. This folder is watched by the blogdown server and all the `.Rmd` in that folder are rendered to `html`.

The public folder is `docs` for convenience. GitHub pages show the `docs` folder or the `gh-pages` branch automatically.

### Header of your post

We are going to follow a few rules to set the header of the post to set posts easily discoverable.

- **Title**: Post title. It is the main feature, it shows in the list and the post page.
- **Author**: Post author. It is not visible in the moment. We will work to make it visible and to show in a menu.
- **Date**: Post date. Same as author.
- **Description**: Post subtitle. As an example, we used it to set the title of the post series of the 2018 IWD project. It shows in the posts list and in the post page.
- **Tags**: Post tags. They should include meaningful information like date if it is a recurrent project (because dates are not shown anywhere for now). 4 or 5 tags is a good number. [Tags](http://blog.rladies.org/tags/).
- **Categories**: Post categories. Like tags but the theme is more general. They are not visible right now. [Categories](http://blog.rladies.org/categories/).

Example:

```yaml
---
title: "1. Behind the scenes of R-Ladies IWD2018 Twitter action!"
author: "R-Ladies"
date: '2018-03-26'
description: 'Part 1: Ideation and Creation!'
tags:
- iwd
- twitter
- part1
- 2018
categories:
- IWD
- R-Ladies
---
```

### After you write your post

Don't upload the `.Rmd` alone, render it with the help of blogdown. If you are working with local data the rest of us won't be able to render your content, so be sure to upload the rendered `html` too.

If you have any question about blogdown or rendering your content, don't hesitate to ask the maintainers and/or editors.

## PR your changes

Don't merge your changes immediately, fork the project and work on your branch. After making the PR, assign any of the editors as reviewer.

## Editors

## Maintainers
