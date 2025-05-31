---
language: fr
translated: no
title: 2. Dans les coulisses de l'action Twitter de R-Ladies IWD2018 !
author: R-Ladies
date: '2018-03-27'
description: 'Partie 2 : Déploiement et gestion des robots !'
slug: 2_dans_les_coulisses_de_l_action_twitter_de_r_ladies_iwd_2018
tags:
- iwd
- part2
- twitter
- 2018
categories:
- IWD
- R-Ladies
---

### Tel que raconté par Kelly O'Briant

Le 8 mars, à l'occasion de la Journée internationale de la femme, nous avons diffusé un flux continu de profils de R-Ladies géniales de [notre annuaire](http://rladies.org/directory/) via [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
C'était une explosion !
Et beaucoup de travail d'équipe aussi !
Dans cet article de blog, nous allons couvrir les étapes de déploiement et de suivi de notre projet.
Vous pouvez également lire le [Partie 1](/post/ideation_and_creation/).

## Récapitulation

L'avantage d'être chargé du déploiement d'un projet, c'est que le plus gros du travail est déjà fait !
Dans cette section, je vais décrire comment nous avons déployé et surveillé notre application Twitter pour la JIF 2018.
Les choses ne se sont pas déroulées exactement comme prévu, mais des leçons ont été tirées et nous avons pu ajuster notre plan de match à la volée tout en faisant quelques compromis mineurs.

Pour résumer, voici où en était le projet lorsqu'il a été temps pour moi d'intervenir :

*Tout le travail était déjà fait !*

- Création d'un compte twitter et d'une application développeur
- Préparation des captures d'écran
- Préparation des tweets

*En quoi consistait mon travail ?*

- Lancer une image docker/rocker
- Faire quelques tests
- Commencez à envoyer des tweets sur IWD2018
- Croisez les doigts pour réussir :)

*Ce que j'aurais probablement dû faire aussi :*

- Déploiement de l'application Docker twitter sur une instance cloud (en cas de coupure de courant chez moi)
- Déterminé si nous aurions des problèmes en ajoutant des handles twitter aux tweets du bot.

## Le travail

### Lancement de Docker

*Pourquoi utiliser Docker ?*

Je savais que nous aurions besoin de tweeter pendant environ 48 heures (après le 8 mars dans le monde entier) et je ne voulais pas bloquer ma session R locale pendant deux jours entiers.
Une solution simple à ce problème est de lancer une instance locale de Docker avec R et RStudio installés.

*Ressources Docker*

J'ai commencé à apprendre à utiliser Docker il y a quelques mois en suivant les instructions suivantes [cet impressionnant tutoriel docker/rocker de rOpenSciLabs](http://ropenscilabs.github.io/r-docker-tutorial/).
Je le recommande vivement.
Lier un volume local (système de fichiers) à une instance de docker est super simple, et c'est tout ce que j'ai eu à faire pour mettre en place ce projet et le faire fonctionner.

J'ai cloné le repo GitHub que nous avons utilisé pour tout notre code et nos données, j'ai lié ce volume à l'instance Docker et j'ai lancé quelques tests Twitter !

### Envoi des tweets

Mon premier réflexe a été d'essayer d'exécuter le code d'envoi de tweets sous la forme d'un script cron programmé. [Qu'est-ce qu'un cron ?](http://www.unixgeeks.org/security/newbie/unix/cron-1.html) J'avais prévu de configurer crontab en [modifiant le fichier Docker](https://www.ekito.fr/people/run-a-cron-job-with-docker/) pour Rocker.

Mais pour rester dans le thème de la simplicité, je me suis contenté d'une boucle for et de `Sys.sleep()`.
J'étais paranoïaque à l'idée que notre compte soit signalé comme un bot malveillant par les gens de Twitter, alors j'ai pensé qu'il serait utile d'ajouter quelques "extra\_seconds" à chaque cycle de sommeil.
Ainsi, nous n'aurions pas à tweeter toutes les six minutes pile.
Je ne sais pas si cela nous a aidés ou non... nous avons quand même été bloqués plusieurs fois.

*Code minimal :*

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

### Contrôler et corriger notre application

L'application `tweet_lady` est configurée pour renvoyer `try_tweet`.
Dans le cas d'un échec de tweeting, il était très utile de pouvoir exécuter rapidement cette fonction en dehors de la boucle for pour voir le type d'erreur.
Notre application est tombée en panne un certain nombre de fois (4 ?) pendant les 48 heures de notre tempête de tweets #IWD, et j'ai donc exécuté ce petit bout de code à de nombreuses reprises lorsque j'ai testé et restauré notre application :

```r
err <- tweet_lady(tweets[id,]$entry_id, tweets[id,]$tweet, token)
```

Les messages d'erreur n'étaient pas toujours très utiles, mais cela me rassurait de les voir.
Les logs sont réconfortants, vous savez ?
Notre première application a été bloquée après trois heures de tweet, et nous avons deviné que la fermeture était due en partie à l'utilisation des handles twitter des femmes dans le corps des messages tweetés.
Il aurait été agréable de continuer à taguer des personnes dans les tweets, mais nous avons décidé de supprimer les poignées afin de faire fonctionner notre application à nouveau (et de la maintenir en fonctionnement).

Ma merveilleuse amie R-Ladies, [Hannah Frick](https://twitter.com/hfcfrick) m'a contacté sur Slack et nous a encouragé à nous pencher sur la gamification de l'étiquetage manuel des handles Twitter.
Cela s'est avéré très amusant.
J'ai passé*beaucoup*J'ai passé beaucoup de temps à regarder le flux, et les gens s'empressaient de taguer les gens avant même que je n'en aie l'occasion !
Je suis vraiment contente de la tournure qu'a pris cette partie - merci Hannah !
Et merci à tous ceux qui ont pris le temps de taguer des personnes et d'écrire des messages personnels !

Toutes les autres erreurs que nous avons eues ont été résolues en changeant de robot d'application (nous en avions trois), en régénérant un jeton ou en combinant plusieurs de ces éléments.

### Conclusion sur le déploiement

Twitter et l'utilisation de bots Twitter sont encore un mystère pour moi.
S'agit-il d'un art, d'une science ?
Je n'en sais rien.
Je suis heureuse que ce projet ait été réalisé dans le cadre de la Journée internationale de la femme et qu'il n'ait pas duré une semaine ou un mois !
Cela dit, je pense que je garderai longtemps en moi le sentiment de m'être engagée avec cette merveilleuse et fantastique communauté #rladies #rstats.
C'était incroyable !
Je suis tellement heureuse et reconnaissante d'avoir eu cette opportunité.
Je vous souhaite de rencontrer d'autres R-Ladies géniales en 2018 !

## À suivre : Partie 3

Lire la suite Partie 3 : [La grande conclusion](/post/conclusion/)!


