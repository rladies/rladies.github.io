# Contribute to the R-Ladies Blog

- [Clone the project](#clone-the-project)
	- [Install the dependecies](#install-the-dependecies)
- [Write a new blog post](#write-a-new-blog-post)
	- [Header of your post](#header-of-your-post)
	- [After you write your post](#after-you-write-your-post)
- [PR your changes](#pr-your-changes)


<!-- /TOC -->

## Clone the project

```sh
# Clone
git clone https://github.com/rladies/blog.git

# Enter
cd blog/

# replace my_branch with any name you like
# will now be working on a copy of the main repo
git checkout -b my_branch
```

Open the folder in RStudio.


### Install the dependecies

```r
install.packages('blogdown')
```

## Write a new blog post

Use the blogdown addin in RStudio to create a new post. 
`Addin` -> `New post`

Fill inn the fields with the relevant information. 

We are going to follow a few rules to set the header of the post to set posts easily discoverable.

- **Title**: Post title. It is the main feature, it shows in the list and the post page.
- **Author**: Post author. It is not visible in the moment. We will work to make it visible and to show in a menu.
- **Date**: Post date. Same as author. The date *must* be static, nothing like `r Sys.Date()`, otherwise everytime the blog is generate a new date is set in the blogpost. The **format must be YYYY-mm-dd**.
- **Description**: Post subtitle. As an example, we used it to set the title of the post series of the 2018 IWD project. It shows in the posts list and in the post page.
- **Tags**: Post tags. They should include meaningful information like date if it is a recurrent project (because dates are not shown anywhere for now). 4 or 5 tags is a good number. [Tags](http://blog.rladies.org/tags/).
- **Categories**: Post categories. Like tags but the theme is more general. They are not visible right now. [Categories](http://blog.rladies.org/categories/).

All of the information will be shown in the post yaml, and can also be edited later.

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
---
```

Your post will be created in a folder within `content/post` and you can add all the files you need for you post here. 
Any images, data files or other things you need to include in your post, add them directly in the folder.

As you write you post, remember to `knit` your post so have a look at how it looks like! 
The blogdown site will use the markdown file created from your knitted `Rmd` on the site, not your `Rmd` itself.
You can preview the entire site with your post with `blogdown::serve_site()`. 

### After you write your post

Once your post looks as you want it to on your local machine, it's time to get it online!
In the RStudio git pane, add your post folder, commit with a message, and push it online!

You can also do this in the terminal in RStudio

```sh
# Add the post
git add content/post/2020-01-01-my-post

# Add a commit message to the post
git commit -m "my commit message"

# Push changes online (replace my_branch with your branch name)
git push --set-upstream origin my_branch
```


## PR your changes
Once you have pushed your changes online, make a [Pull request (PR)](https://github.com/rladies/blog/pulls) to the master branch.
You can follow the build of the site with your post in [GitHub actions](https://github.com/rladies/blog/actions), and see the previewed page once it is done building by looking at the Netlify section of the build.

When the PR is open ([see here](https://github.com/rladies/blog/pulls)) assign the reviewer to **Chrisy** and she can merge the branch once the post is reviewed. 
If you like for an specific someone to review your post assign her the PR too. 
