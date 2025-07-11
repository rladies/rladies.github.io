---
language: fr
translated: no
title: Demande de proposition - Développement Javascript (travail contractuel)
author: Athanasia M. Mowinckel
type: blog
date: '2022-03-28'
slug: demande_de_proposition_développement_javascript_travail_contractuel
categories: []
tags: []
lastmod: '2022-03-28T08:41:18+02:00'
keywords: []
description: ''
comment: no
toc: no
autoCollapseToc: no
contentCopyright: no
reward: no
mathjax: no
---

**L'organisation mondiale R-Ladies souhaite implémenter de nouvelles fonctionnalités (en utilisant Javascript) pour une réimplémentation de leur site web, dont le code source peut être trouvé à l'adresse suivante [GitHub](https://github.com/rladies/website).**

R-Ladies aimerait vous inviter à préparer une proposition pour accomplir la tâche susmentionnée qui comprend le calendrier, le coût et les produits livrables.
L'appel d'offres suivant comprend un historique de notre organisation et décrit l'objectif de la refonte, la fonctionnalité souhaitée et les demandes spécifiques relatives à la proposition.
Nous sommes conscients que les détails peuvent être modifiés en fonction des recommandations du fournisseur et/ou de la recherche de solutions plus optimales.
Dans votre proposition, n'hésitez pas à suggérer d'autres solutions lorsque cela est indiqué.

<!--more-->

## Historique de l'entreprise

R-Ladies est une organisation mondiale dont la mission est de promouvoir la diversité des genres dans la communauté R.

La communauté R souffre d'une sous-représentation des genres minoritaires (y compris, mais sans s'y limiter, les femmes cis/trans, les hommes trans, les non-binaires, les genderqueer, les agender) dans tous les rôles et domaines de participation, que ce soit en tant que leaders, développeurs de paquets, conférenciers, participants à des conférences, éducateurs ou utilisateurs (voir les statistiques récentes).

En tant qu'initiative de diversité, la mission de R-Ladies est d'atteindre une représentation proportionnelle en encourageant, en inspirant et en responsabilisant les personnes de genre actuellement sous-représentées dans la communauté R.
L'objectif principal de R-Ladies est donc de soutenir les passionnés de R de sexe minoritaire pour qu'ils réalisent leur potentiel de programmation, en construisant un réseau mondial collaboratif de leaders, de mentors, d'apprenants et de développeurs R pour faciliter le progrès individuel et collectif dans le monde entier.

### Chef de projet

[Athanasia Monika Mowinckel](https://drmowinckels.io/)

## Budget

Nous demandons aux entrepreneurs potentiels de fournir un budget préliminaire pour leur proposition.
Ce budget peut être fourni sous forme de taux horaire avec une estimation du nombre d'heures nécessaires à la réalisation du projet.
Les travaux de développement peuvent être imprévisibles et nous comprenons que le nombre d'heures estimées pour la réalisation du projet puisse s'écarter quelque peu des estimations de la proposition.

## Calendrier

### Date limite de dépôt des propositions

le 1er mai<sup>st</sup>, 2022

### Sélection de l'entrepreneur

Les sélections initiales commencent immédiatement après la date limite de réponse.
Les finalistes devraient être informés avant le 15 juin et avoir la possibilité d'avoir un entretien avec le chef de projet afin d'examiner la proposition.
La décision finale devrait être prise avant le début du mois de juillet 2022.

### Lancement du projet

Au plus tôt : 1er juillet<sup>st</sup> 2022  
Dernière en date : 1er septembre<sup>st</sup> 2022

Le chef de projet n'est pas disponible en août, mais des appels bimensuels avec le chef de projet sont prévus pour la durée du projet, ainsi qu'une communication asynchrone par courriel et GitHub.

## Date de lancement souhaitée

Le lancement définitif du site web est prévu pour le 1er janvier<sup>st</sup> 2023, et à ce titre, tous les problèmes majeurs devraient être résolus d'ici le 1er décembre<sup>stst</sup>2022\.
Une première proposition de solution devrait être élaborée d'ici le 1er novembre.<sup>st</sup> 2022, en vue d'une révision du code et de tests.

## Défis

Le nouveau site web R-Ladies est en cours de développement à l'aide de [Hugo](https://gohugo.io/) un générateur de sites web statiques.
Le code source complet et les informations sur la construction sont disponibles sur [GitHub](https://github.com/rladies/website).
Le développement des modèles Hugo et la logistique de construction sont couverts par les développeurs de R-Ladies.
Plus d'informations sur l'installation d'Hugo pour ce projet peuvent être trouvées dans le fichier [wiki du repo](https://github.com/rladies/website/wiki).
Les parties du projet qui sont implémentées en javascript requièrent cependant l'attention d'un expert.
Les membres de l'équipe mondiale R-Ladies ne sont pas des développeurs Javascript, et le projet a donc besoin d'être supervisé par quelqu'un de plus expert pour s'assurer qu'il fonctionne comme prévu et qu'il est mis en œuvre selon les bonnes pratiques.

## Objectifs

L'expert en javascript travaillera en étroite collaboration avec les développeurs de R-Ladies pour s'assurer que le comportement souhaité du site web est garanti.
La plateforme principale de développement est GitHub.

- **[Répertoire R-Ladies](https://pensive-babbage-969fad.netlify.app/directory/)**
  
  - [Liste.js](https://listjs.com/) où la pagination fonctionne bien, mais [flèches ne fonctionnent pas](https://github.com/rladies/website/issues/88)
  - [Autres caractéristiques souhaitées](https://github.com/rladies/website/issues/83):
    - Mélanger la liste
    - Possibilité d'étendre le tri/la limitation de la liste aux langues, aux lieux, etc.

- **[Calendrier des événements](https://pensive-babbage-969fad.netlify.app/activities/events/)**
  
  - Utilisations [Calendrier Toast UI (TUI)](https://ui.toast.com/tui-calendar)
  - [Non pris en charge par tous les navigateurs](https://github.com/rladies/website/issues/90)
  - Vérifier si [peuvent être affichés à l'heure locale du navigateur](https://github.com/rladies/website/issues/86)

- **Plus général**
  
  - Consolider les implémentations générales de JS
  - [Principales bibliothèques javascript](https://github.com/rladies/website/tree/master/themes/hugo-rladies/static/js) utilisées :
    - List.js
    - Moment.js
    - Tui-calendar.js
    - Bootstrap.js
    - jquery.js
  - pourraient nécessiter des ajustements dans leur mise en œuvre en termes de
    - Performance et robustesse
    - Meilleures pratiques pour la mise en œuvre de JS
    - Ordre général du code

## Critères d'évaluation

L'entrepreneur doit justifier d'une expérience et de connaissances dans les domaines suivants

- Développement de javascript pour les sites web
- Utilisation de GitHub pour le développement collaboratif

Les éléments suivants seront également pris en compte de manière positive dans toute candidature

- Familiarité avérée avec Hugo
- Représentation des minorités dans l'équipe de développement (en particulier le sexe et l'origine ethnique)
- Familiarité avec les principales bibliothèques JS utilisées
  - List.js
  - Tui-calendar.js
  - Moment.js

## Instructions pour la soumission

Si vous avez des questions concernant la soumission ou l'appel d'offres lui-même, veuillez envoyer un courriel à \[ [rfp@rladies.org](mailto:rfp@rladies.org)\]( <mailto:rfp@rladies.org>?
subject=RFP : JS website development) avec "RFP : JS website development" dans le champ "subject", et le responsable du projet répondra dans les meilleurs délais.

Toutes les propositions doivent contenir les informations suivantes, dans l'ordre indiqué :

**Biographie de l'entreprise/du contractant unique**

- Description générale de l'entreprise et du type de travail effectué
- Nom, adresse, courriel, téléphone, site web
- Nombre d'années d'activité

Biographie de l'équipe (applicable uniquement aux entrepreneurs de la société)\*\*

- Nombre de personnes (environ) qui travailleront sur le projet de site web, leurs rôles et responsabilités
- Taille de l'équipe, biographies, années d'expérience de chacun, rôle, récompenses/certificats
- Toute ressource supplémentaire requise pour le soutien (ex : sous-traitants)

**Références**

- Principaux clients et date de leur partenariat
- 4-6 références de clients
- 3-5 projets les plus pertinents, qui a travaillé sur chaque projet, lien vers l'étude de cas ou l'URL du site web
- Autre possibilité : un lien vers un portfolio

**Proposition de projet**

- Nombre d'heures et calendrier général du début à la fin (environ)
- Éventuellement aussi spécifié par la question GitHub directement
- Si vous suggérez d'autres bibliothèques js à utiliser pour la fonctionnalité souhaitée
  - Description de la raison pour laquelle l'alternative est un meilleur choix
  - Comparaison des caractéristiques des deux choix concurrents
  - Estimation du temps que prendra le changement de bibliothèque par rapport à la recherche d'une solution avec la bibliothèque actuellement utilisée
- Proposition de flux de communication entre le chef de projet de R-Ladies et l'équipe de l'entreprise

**Budget**  
Estimation des coûts de la proposition Il peut s'agir de taux horaires et d'une estimation du nombre d'heures nécessaires.

Veuillez utiliser ce formulaire pour envoyer votre proposition : <https://forms.gle/34bHsnDJppLwPstd6>


