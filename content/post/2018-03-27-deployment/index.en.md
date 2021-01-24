---
title: "2. Behind the scenes of R-Ladies IWD2018 Twitter action!"
author: "R-Ladies"
date: '2018-03-27'
description: 'Part 2: Deployment and Bot Wrangling!'
slug: deployment
tags:
- iwd
- part2
- twitter
- 2018
categories:
- IWD
- R-Ladies
output: 
  html_document:
    keep_md: yes
---


### As told by Kelly O'Briant

On March the 8th, International Women's Day, we ran a continuous feed of awesome R-Ladies profiles from [our directory](http://rladies.org/directory/) via [\@rladies_iwd2018](https://twitter.com/rladies_iwd2018). It was a blast! And a lot of team work too! In this blog post, we'll cover the deployment and monitoring stages of our project. You can also read the [Part 1](/post/ideation_and_creation/).

## Recap

The great part about being put in charge of deploying a project, is that all the hard work is mostly done already! In this section, I'll describe how we deployed and monitored our twitter application for IWD 2018. Things didn't end up going exactly as planned, but lessons were learned and we were able to adjust our game plan on the fly while making some minor compromises.

To review, here is where the project stood when it came time for me to jump in:

*All the hard work was taken care of already!*

- Creating a twitter account and developer application
- Preparing the screenshots
- Preparing the tweets

*What my job was:*

- Launch a docker/rocker image
- Do a little testing
- Start sending tweets on IWD2018
- Cross fingers for success :)

*What I probably should have also done:*

- Deployed the Docker twitter app on a cloud instance (in case of a power outage here at my house)
- Determined whether we would get in trouble for adding twitter handles to the bot tweets

## The job

### Launching Docker

*Why use Docker?*

I knew that we would need to be tweeting for roughly 48 hours (following March 8th around the globe) and I would never want to tie up my local R session for two whole days. A simple solution to this problem is to launch a local docker instance with R and RStudio installed.

*Docker Resources*

I started learning how to use docker a few months ago by following [this awesome docker/rocker tutorial from rOpenSciLabs](http://ropenscilabs.github.io/r-docker-tutorial/). I highly recommend it. Linking a local volume (file system) to a docker instance is super simple, and was basically all I needed to do to get this project up and running.

I cloned the GitHub repo we used for all our code and data, linked that volume to the docker instance and fired up some twitter tests!

### Sending the Tweets

My initial instinct was to try and run the tweeting code as a cron scheduled script. [What is cron?](http://www.unixgeeks.org/security/newbie/unix/cron-1.html) I planned to set up crontab by [modifying the Docker file](https://www.ekito.fr/people/run-a-cron-job-with-docker/) for Rocker.

But in keeping with the theme of "simple wins out", I ended up just using a for loop and `Sys.sleep()`. I was paranoid about our account getting flagged as a malicious bot by the folks at twitter, so I thought it would help to add a couple of "extra_seconds" to each sleep cycle. This way we wouldn't be tweeting every six minutes on the dot. I have no idea whether this helped us or not... we still got blocked a few times.

*Minimal Code:*

```r
tweet_lady <- function(entry_id, tweet, token){
  message(entry_id)
  pic_media <- paste0("screenshots/",entry_id,".png")

  try_tweet <- try(rtweet::post_tweet(status = tweet,
                                      token = token,
                                      media = pic_media), silent = TRUE)    

  if(class(try_tweet)[1] == "try-error"){
    print(paste0("Tweeting failed on entry ", entry_id))
  }
  return(try_tweet)  
}


extra_seconds <- function(){
  sample(2:12,1)
}

for (i in 1:433){     # 433 rladies
  lady <- tweets[i,]
  print(lady$tweet)
  tweet_lady(lady$entry_id, lady$tweet, token)
  Sys.sleep(360 + extra_seconds())
}
```

### Monitoring and Fixing our Application

The `tweet_lady` function is set up to return `try_tweet`. In the case of a tweeting failure, it was mighty helpful to be able to quickly run this function outside the for loop to see the error type. Our application went down a number of times (4?) during our 48 hour #IWD twitter storm, and so I ran this little piece of code many times as I tested and restored our app:

```r
err <- tweet_lady(tweets[id,]$entry_id, tweets[id,]$tweet, token)
```

The error messages weren't always all that helpful, but it made me feel better to see them. Logs are comforting, you know? Our first application was blocked after three hours of tweeting, and we guessed that the shutdown was due in part to using ladies' twitter handles in the body of the tweet messages. It would have been nice to continue to tag people in the tweets, but we decided to remove handles in order to get our application running again (and keep it running).

My wonderful R-Ladies friend, [Hannah Frick](https://twitter.com/hfcfrick), hit me up on slack and encouraged us to lean into the gamification of tagging twitter handles by hand. This ended up being really fun. I spent *a lot* of time watching the feed, and people were routinely swooping in to tag people before I ever got the chance! I'm really happy with how this part turned out - thank you Hannah! And thank you to everyone who spent time tagging people and writing personal messages!

All of the other errors we had were fixed by switching application bots (we had three), regenerating a token, or some combination of those things.

### Deployment Conclusion

Twitter and running twitter bots is still mostly a mystery to me. Is it an art, a science? I have no idea. I'm glad that this was an International Women's Day project, and didn't last a week or a month! That being said, I think I'll be carrying the feeling of engaging with this wonderful, fantastic #rladies #rstats community around with me for a long time. It was amazing! I'm so glad and grateful for this opportunity. Here's to meeting more awesome R-Ladies in 2018!


## Next Up: Part 3

Continue Reading Part 3: [The Grand Conclusion](/post/conclusion/)!
