# Contribute to the R-Ladies Blog

- [Write a new blog post](#write-a-new-blog-post)
	- [Header of your post](#header-of-your-post)
	- [After you write your post](#after-you-write-your-post)
- [PR your changes](#pr-your-changes)

## Write a new blog post

Create a new file `.Rmd` in the folder **`content > post`**. This folder is watched by the blogdown server and all the `.Rmd` in that folder are rendered to `html`.

The public folder is `public` which is the folder rendered in Netlify. The `public` folder is rendered by Travis, there's no need for it to be on the repository, the CI is capable of generate the `html`s necessary for the blog to work.

### Header of your post

We are going to follow a few rules to set the header of the post to set posts easily discoverable.

- **Title**: Post title. It is the main feature, it shows in the list and the post page.
- **Author**: Post author. It is not visible in the moment. We will work to make it visible and to show in a menu.
- **Date**: Post date. Same as author. The date *must* be static, nothing like `r Sys.Date()`, otherwise everytime the blog is generate a new date is set in the blogpost. The **format must be YYYY-mm-dd**.
- **Description**: Post subtitle. As an example, we used it to set the title of the post series of the 2018 IWD project. It shows in the posts list and in the post page.
- **Tags**: Post tags. They should include meaningful information like date if it is a recurrent project (because dates are not shown anywhere for now). 4 or 5 tags is a good number. [Tags](http://blog.rladies.org/tags/).
- **Categories**: Post categories. Like tags but the theme is more general. They are not visible right now. [Categories](http://blog.rladies.org/categories/).

Example:

```yaml
---
title: "1. Behind the scenes of R-Ladies IWD2018 Twitter action!"
author: "R-Ladies"
date: "2018-03-26"
description: "Part 1: Ideation and Creation!"
tags:
- iwd
- twitter
- part1
- 2018
categories:
- IWD
- R-Ladies
output: html_document
---
```

### After you write your post

1. Upload the `.Rmd` in `content > post`
2. Upload post images in `content > image`
3. If there's any *executable* code within the post upload all data in `content > data` and make sure all the R packages used in your post are also listed in the Imports field of the DESCRIPTION file so that Travis installs them.

**Note**: Don't upload the `html` or the public folder. This is regenerated everytime there's a push to *master*.

## PR your changes

Don't merge your changes immediately, fork the project and work on your branch. After making the PR, assign any of the editors as reviewer.

[This gist](https://gist.github.com/Chaser324/ce0505fbed06b947d962) has extense documentation on the fork + pull request workflow.

### Assign the PR

When the PR is open ([see here](https://github.com/rladies/blog/pulls)) assign the reviewer to **Chrisy** and she can merge the branch once the post is reviewed. 

If you like for an specific someone to review your post assign her the PR too. 