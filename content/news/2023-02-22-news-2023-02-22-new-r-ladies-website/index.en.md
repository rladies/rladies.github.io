---
title: New R-Ladies Website
author: Athanasia M. Mowinckel
date: '2023-02-22'
slug: news/2023-02-22-new-r-ladies-website
categories:
  - R-Ladies
tags: []
---


We are thrilled to announce the release of our new R-Ladies website!

It's been a long journey, with many people involved, and we are happy to be able to finally share with you this new site and some new content.

<!--more-->

There were some key issues we wanted to resolve with our webpage, that we could not easily maintain with the Wordpress site we had going:

- Multilingual website 
  - This is not the easiest to maintain with Wordpress
- Very slow directory
  - The database was just too slow and heavy, page loading time was horrible
- Integrate the blog into the website
  - The blog was a Blogdown site maintained through Github and Netlify
- Easier long-term maintenance and collaboration
  - Wordpress would require making a user for every person that wanted to contribute to the site
  - Changing to something hosted on GitHub would mean easier community help and collaboration

## History

The work already started in 2019, with Bea Hernandez, Daloha Rodríguez-Molina and Maëlle Salmon.
The initial work was in making a [blogdown](https://bookdown.org/yihui/blogdown/) website, which utilises [Hugo](https://gohugo.io/) and Rmarkdown integration.
It was a natural place to start porting our Wordpress site into something more common to use in our community. 
Additionally, the Wordpress site was requiring more and more maintenance, and in particular our [R-Ladies directory](https://www.rladies.org/directory/) was so slow we were getting reports of people not using it because the loading time of the page was so long!

In 2020, I (Athanasia Mowinckel) was on-boarded to the website team, initially to maintain the Wordpress site while the new Hugo site was being built.
After just a little while, I also started working on the blogdown site. 

In mid-2020 we decided that the webpage was better served as a pure Hugo site, not as blogdown. 
At that point, it was due to some Hugo features not existing in Blogdown (yet) that we wanted to utilise for the website.
These were settings for multi-lingual websites we really wanted to take advantage of.
Furthermore, since only the blog would ever need code execution, having a site build that does not need R means a much faster build, and easier to maintain.

Then Covid hit, and we all felt the stress of that period.
Development went slow, and things dragged out.
Thankfully, the Leadership contacted me and asked if I needed help to get the last pieces in place, and that we could set aside a little budget to hire help for the javascript pieces I was struggling with.

We [announced](https://130--rladies-dev.netlify.app/news/2022-03-28-request-for-proposal-javascript-development/) the need, and hired Ben Ubah to help me get the last crucial pieces in place. Finally, we were nearing completion!

## Release & new features!

We have now released the new website and are thrilled about how it works so far!
The theme is well suited to us, and the content is much easier to deal with now that we can collaborate through GitHub.
It's also made it possible to integrate the website with certain other automatic pipelines, which enables us to have a couple of new features to the website from before!

- [Events page](https://www.rladies.org/activities/events/) with a calendar of R-Ladies events
  - These are fetched daily from meetup through their API
- [Direcotry page](https://www.rladies.org/directory/) which is actually fast!
  - Updated and maintained in another private repository with Airtable integration
- [Blog](https://www.rladies.org/blog/) where we welcome contributing posts and cross-posts!
  - We'd love to see the blog revived and used by our community to show their skills and fun things they are doing with R!
- [News page](https://www.rladies.org/news/) where the R-Ladies Global team can announce important notices about the global governance of our community

And more!

## Future work & call for community help

There are still some things we are working on in the background, that we hope will improve the experience of our website, and also fulfil obligations we have promised previously.

### Multilingual webpage
We have set the website up to be multilingual, and have some development content for French, Spanish and Portuguese.
But, there is still a long way to go before we get to a point where these languages are well enough translated and enough content has been translated, for the language to be released in the production website.
Also, we are assuming that once we start having more translated content, we will see areas where the code needs fixing for proper multilingual support.

We hope with community help we can make an effort to cover the major languages used by our community.

### Directory improvements

#### Updating entries
The directory has been ported from wordpress with some rather elaborate and hacky scripts to get the content working for our new website.
This means, that for quite a lot of the entries, the content looks weird and out of place on the new website.
The best way to update your own entry in the directory, is to locate your entry and fill out the [form](https://airtable.com/shr54Z3BqfRJqypZ7) for updating the directory.
This way, we can create a better and more unified directory for all!

#### Better search / filtering

Currently, we are using a fuzzy search for the directory.
While this does help somewhat, it can give odd results and it can be hard to find exactly what you are after.

We are working on making better search and filtering functions for the directory, and if you have suggestions of how you would like to search it, we [value your input](https://github.com/rladies/rladies.github.io/issues).

### Adding new pages

There are quite some pages we are eager to start work on, so we can provide the best information available to our community and Funders.
We promised certain resources in our [BML](https://130--rladies-dev.netlify.app/news/2020-06-06-blm/) statement, and we are keenly aware that we have yet to fulfil this.
Also, we know that our funders regularly want summaries of our activities, and we hoe to make a page dedicated to this type of information.

If there are pages you feel should exist, [please do let us know](https://github.com/rladies/rladies.github.io/issues) and we will consider your proposals.

## Final thoughts from the main developer

It has been an amazing journey for me to work on this website. 
I've learned so much, and I am thrilled to finally see it go "live".
I look forward to the continued development, and we will be announcing the need for new website team members in not too long, to help me with the translation efforts, in revitalising the blog and in taking over the general maintenance of the new website.

![](rladies.jpg)
