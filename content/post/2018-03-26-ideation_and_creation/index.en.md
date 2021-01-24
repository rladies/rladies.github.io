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
output: 
  html_document:
    keep_md: yes
---

### As told by Maëlle Salmon with notes from Bea Hernández

On March the 8th, International Women's Day, we ran a continuous feed of awesome R-Ladies profiles from [our directory](http://rladies.org/directory/) via [\@rladies_iwd2018](https://twitter.com/rladies_iwd2018). It was a blast! And a lot of team work too! In this blog post, we'll explain how we designed and completed our Twitter action.

## An idea sown on IWD2017!

Last year on International Women's day, [R-Ladies ally David Robinson](https://twitter.com/drob/) [promoted](https://twitter.com/drob/status/839564664321282048) Twitter accounts of female data scientists. I (Maëlle) had the honor to be featured in this tweet, and still remember a) being very flattered b) seeing my followers count skyrocket! I'm pretty sure quite a few of the opportunities I received since then are at least partly related to this [sponsorship](https://robinsones.github.io/The-Importance-of-Sponsorship/) by Dave. Therefore, I wanted to pay it forward this year!

On January the 1st I realized that new year meant new IWD so it was time to plan! I wanted us to have an action celebrating many R-Ladies, not only those who already receive much attention. Indeed, R-Ladies local chapters and global organization have a mission to amplify the voices of R-Ladies, all of them! I am a Twitter addict so I immediately thought of having a Twitter feed ot R-Ladies profile, but I envisioned our identifying the R-Ladies via a survey. [Steph Locke](https://twitter.com/stefflocke?lang=es) got a much better idea when I mentioned mine in our Slack: using entries from our directory and using this as an opportunity to promote the directory! So this became our plan!

## Working on the directory

Since the directory became central in our plan, it got a lot of love from Bea and directory masters Sheila and Page!

### The more entries the merrier!

We advertised the directory again via different channels, in particular our global Twitter account and the organizers of local chapters. This created a flow of new entries to be tackled which Sheila and Page did efficiently.

### Prettifying the directory

*A Note from [Bea](https://twitter.com/chucheria) on Prettifying the Directory:* After doing the first "ugly" screenshots, we (Page, Sheila, and I) discovered we didn't have a method for adding names, so titles and other info were placed in the name. In addition to the big font for the name, it made the name too long and some of the screenshots ended up looking ugly.

We modified the information, but even after that we discovered that depending on who made the screenshot the font was different. We haven't found the problem to that, but everything points to an issue with `revealJS`.

Thanks to this, we have new procedures to add new files and we hope to improve the directory soon with new features too.

### Exporting the directory

For further processing, we needed the direct link to each entry, and other entry-specific information such as a potential Twitter handle. For that, we had to rely on both a Wordpress export and webscraping the directory because the export didn't include individual links, and these links couldn't be guessed (for instance mine is https://rladies.org/spain-rladies/name/maille-salmon/ because I was first entered as Maille). Bea and I wrote the code below

```r
url <- read_html("https://rladies.org/ladies-complete-list/")

ladies_name <- url %>%
  html_nodes("strong > a") %>%
  html_attr("title")

ladies_url <- url %>%
  html_nodes("strong > a") %>%
  html_attr("href")

df <- tibble::tibble(name = ladies_name,
                     ladies_url = ladies_url)

# export from the Wordpress plugin
ladies <- readr::read_csv("data/cn-export-all-02-02-2018.csv")
ladies <- janitor::clean_names(ladies)

# helper function
past_if_nonvoid <- function(vector){
  glue::collapse(vector[!is.na(vector)], sep = " ")
}

# write the name to make it correspond to scraped names
ladies <- dplyr::group_by(ladies, entry_id) %>%
  dplyr::mutate(name = past_if_nonvoid(c(honorific_prefix, first_name, middle_name, last_name,
                                         honorific_suffix))) %>%
  dplyr::ungroup() %>%
  dplyr::select(name, dplyr::everything())

# join two tables to get URLS
ladies <- dplyr::mutate(ladies, name = stringr::str_replace_all(name, "\\\\'", "’"))
ladies <- dplyr::left_join(ladies, df, by = "name")

# a few issues
ladies$ladies_url[ladies$entry_id == 274] <- "https://rladies.org/ladies-complete-list/name/bianca-furtuna/"

# reformat Twitter handle
ladies <- dplyr::mutate(ladies, twitter = stringr::str_replace(social_network_twitter_url,
                                                                ".*\\/", ""))


```


## Webshooting and random complimenting

What does posting R-Ladies profile mean? I decided a good recipe for a tweet was:

* A screenshot of the R-Ladies directory entry, since it'd mean an image, and since it contains important information about the talents and interests of each R-Lady

* The #rladies and #iwd2018 hashtags (Thanks to [Heather Turner](http://www.heatherturner.net) for showing me where to find the official hashtag in advance!) to increase visibility of the feed and to promote our hashtag.

* Random compliments to make it friendlier and more fun

* A direct link to the directory entry to drive traffic to the directory and allow the tweet reader to really go learn more about the R-Lady, since most entries list other profiles such as a personal website or GitHub account

* The Twitter handle of the R-Lady if available to help their visibility

### Preparing the tweets

Once we had created the table of R-Ladies with their direct directory URLs, preparing the tweets only meant creating random compliments that could apply to any R-Lady (yes, all R-Ladies are awesome and talented!) and gluing all text together.

```r
# templates
templates <- c("Do you know this adjective R-Lady?",
               "What a adjective R-Lady!",
               "Aren't you impressed by this adjective R-Lady?!",
               "Let's get inspired by this adjective R-Lady!",
               "Have you heard of this adjective R-Lady?!",
               "Find out more about this adjective R-Lady!",
               "This R-Lady is adjective!",
               "Read more about how adjective this R-Lady is!",
               "It's an honour to feature this adjective R-Lady!",
               "Another adjective R-Lady!",
               "One more adjective R-Lady!")

adjectives <- c("awesome", "fantastic", "spunky", "wondrous",
                "majestic", "amazing", "wise",
                "awe-inspiring",
                "badass", "bright", "smart", "brilliant", "clever",
                "luminous", "phenomenal", "remarkable",
                "talented", "incredible", "cool", "top-notch")

# get as many sentences as there are ladies
combinations <- expand.grid(templates, adjectives)
combinations <- dplyr::mutate_all(combinations, as.character)
create_sentence <- function(template, adjective){
  stringr::str_replace(template, "adjective", adjective)
}

sentences <- purrr::map2_chr(combinations$Var1, combinations$Var2,
                             create_sentence)
set.seed(42)
# the first one is chosen, this way it's not "another" or "one more"
sentences <- c(sentences[1],
               sample(sentences, nrow(ladies) - 1, replace = TRUE))

# add actual tweet text
ladies <- dplyr::mutate(ladies,
                        url = ladies_url,
                        tweet = sentences,
                        tweet = ifelse(!is.na(twitter),
                                          paste0(tweet, " @", twitter), tweet),
                        tweet = paste(tweet, url, "#rladies #iwd2018"))

# save tweets
ladies <- dplyr::select(ladies, ladies_url, name, entry_id, tweet)
readr::write_csv(ladies, path = "data/ready_tweets.csv")

```

### Webshooting the directory

The directory was webshot using the `webshot` and `magick` package, with the following function that takes the URL to an entry and the ID of a R-Lady as arguments.

```r
get_shot <- function(url, person){
  # webshoot the directory
  webshot::webshot(url, selector = "#cn-list-body", expand = 10)
  # read the webshot image to modify it
  img <- magick::image_read("webshot.png")
  height <- magick::image_info(img)$height
  # crop, add purple border and save the image
  img %>%
    magick::image_crop(paste0("700x", height, "+0+70")) %>%
    magick::image_border("#88398A", "10x10") %>%
    magick::image_write(paste0("screenshots/", person, ".png"))
  # cleans
  file.remove("webshot.png")
}
```
All images were prepared before tweeting, so that they were ready a bit before IWD.

## Next Up: Part 2

Continue Reading Part 2: [Deployment and Bot Wrangling](/post/deployment/)!
