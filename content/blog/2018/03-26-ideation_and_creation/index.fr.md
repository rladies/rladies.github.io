---
language: fr
translated: no
title: 1. Dans les coulisses de l'action Twitter de R-Ladies IWD2018 !
author: R-Ladies
date: '2018-03-26'
description: 'Partie 1 : Idée et création !'
tags:
- iwd
- twitter
- part1
- 2018
categories:
- IWD
- R-Ladies
slug: 1_dans_les_coulisses_de_l_action_twitter_de_r_ladies_iwd_2018
---

### Raconté par Maëlle Salmon avec des notes de Bea Hernández

Le 8 mars, à l'occasion de la Journée internationale de la femme, nous avons diffusé un flux continu de profils de R-Ladies géniales de [notre annuaire](http://rladies.org/directory/) via [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
C'était une explosion !
Et beaucoup de travail d'équipe aussi !
Dans cet article de blog, nous vous expliquons comment nous avons conçu et réalisé notre action Twitter.

## Une idée semée à l'occasion de la JIF2017 !

L'année dernière, à l'occasion de la journée internationale de la femme, [David Robinson, allié de R-Ladies](https://twitter.com/drob/) [promu](https://twitter.com/drob/status/839564664321282048)des comptes Twitter de femmes data scientists.
J'ai eu l'honneur (Maëlle) de figurer dans ce tweet, et je me souviens encore a) d'avoir été très flattée b) d'avoir vu mon nombre de followers grimper en flèche !
Je suis presque sûre que plusieurs des opportunités que j'ai reçues depuis lors sont au moins en partie liées à ce tweet. [parrainage](https://robinsones.github.io/The-Importance-of-Sponsorship/)par Dave.
J'ai donc voulu lui rendre la pareille cette année !

Le 1er janvier, j'ai réalisé qu'une nouvelle année signifiait une nouvelle JIF et qu'il était donc temps de planifier !
Je voulais que nous organisions une action célébrant de nombreuses femmes R, et pas seulement celles qui reçoivent déjà beaucoup d'attention.
En effet, les sections locales et l'organisation mondiale de R-Ladies ont pour mission d'amplifier les voix des R-Ladies, de toutes les R-Ladies !
Je suis accro à Twitter et j'ai donc immédiatement pensé à un fil Twitter ou à un profil R-Ladies, mais j'ai envisagé que nous identifiions les R-Ladies par le biais d'un sondage.
[Steph Locke](https://twitter.com/stefflocke?lang=es)a eu une bien meilleure idée lorsque j'ai mentionné la mienne dans notre Slack : utiliser les entrées de notre annuaire et en profiter pour promouvoir l'annuaire !
C'est donc devenu notre plan !

## Travailler sur l'annuaire

L'annuaire étant devenu un élément central de notre plan, il a reçu beaucoup d'attention de la part de Bea et des maîtres de l'annuaire, Sheila et Page !

### Plus il y a d'entrées, plus on rit !

Nous avons à nouveau fait de la publicité pour l'annuaire via différents canaux, en particulier notre compte Twitter mondial et les organisateurs des sections locales.
Cela a créé un flux de nouvelles entrées à traiter, ce que Sheila et Page ont fait efficacement.

### L'embellissement de l'annuaire

\*Une note de [Bea](https://twitter.com/chucheria) sur l'embellissement de l'annuaire:\*Après avoir fait les premières captures d'écran "laides", nous (Page, Sheila et moi) avons découvert que nous n'avions pas de méthode pour ajouter des noms, donc les titres et autres informations ont été placés dans le nom.
En plus de la grande police de caractères, le nom était trop long et certaines captures d'écran ont fini par être laides.

Nous avons modifié les informations, mais même après cela, nous avons découvert que la police était différente selon l'auteur de la capture d'écran.
Nous n'avons pas encore trouvé le problème, mais tout porte à croire qu'il s'agit d'un problème de`revealJS`.

Grâce à cela, nous avons de nouvelles procédures pour ajouter de nouveaux fichiers et nous espérons améliorer bientôt le répertoire avec de nouvelles fonctionnalités.

### Exporter le répertoire

Pour la suite du traitement, nous avions besoin du lien direct vers chaque entrée, ainsi que d'autres informations spécifiques à l'entrée, telles qu'une éventuelle adresse Twitter.
Pour cela, nous avons dû nous appuyer à la fois sur un export Wordpress et sur le webscraping de l'annuaire, car l'export n'incluait pas les liens individuels, et ces liens ne pouvaient pas être devinés (par exemple, le mien est <https://rladies.org/spain-rladies/name/maille-salmon/>car j'ai d'abord été enregistré sous le nom de Maille).
Bea et moi avons écrit le code ci-dessous

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
ladies <- dplyr::mutate(ladies, name = stringr::str_replace_all(name, "\\\\'", "'"))
ladies <- dplyr::left_join(ladies, df, by = "name")

# a few issues
ladies$ladies_url[ladies$entry_id == 274] <- "https://rladies.org/ladies-complete-list/name/bianca-furtuna/"

# reformat Twitter handle
ladies <- dplyr::mutate(ladies, twitter = stringr::str_replace(social_network_twitter_url,
                                                                ".*\\/", ""))


```

## Recherche sur le web et compliments au hasard

Que signifie afficher le profil de R-Ladies ?
J'ai décidé qu'une bonne recette pour un tweet était :

- Une capture d'écran de l'entrée de l'annuaire des R-Ladies, puisqu'il s'agit d'une image et qu'il contient des informations importantes sur les talents et les intérêts de chaque R-Lady.

- Les hashtags #rladies et #iwd2018 (Merci à [Heather Turner](http://www.heatherturner.net) pour m'avoir indiqué où trouver le hashtag officiel à l'avance !) pour augmenter la visibilité du flux et promouvoir notre hashtag.

- Des compliments aléatoires pour rendre le forum plus convivial et plus amusant.

- Un lien direct vers l'entrée de l'annuaire pour attirer le trafic vers l'annuaire et permettre au lecteur du tweet d'en savoir plus sur la R-Lady, puisque la plupart des entrées mentionnent d'autres profils tels qu'un site web personnel ou un compte GitHub.

- L'adresse Twitter de la R-Lady, si elle est disponible, afin d'améliorer sa visibilité.

### Préparation des tweets

Une fois que nous avons créé le tableau des R-Ladies avec les URL de leur annuaire direct, la préparation des tweets a consisté à créer des compliments aléatoires qui pouvaient s'appliquer à n'importe quelle R-Lady (oui, toutes les R-Ladies sont géniales et talentueuses !) et à coller tous les textes ensemble.

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

### Le webhooting de l'annuaire

L'annuaire a été photographié à l'aide de l'outil `webshot` et `magick` avec la fonction suivante qui prend l'URL d'une entrée et l'ID d'une R-Lady comme arguments.

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

Toutes les images ont été préparées avant d'être tweetées, afin qu'elles soient prêtes un peu avant la JIF.

## À suivre : Partie 2

Lire la suite Partie 2 : [Déploiement et gestion des robots](/post/deployment/)!


