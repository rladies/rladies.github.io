---
language: pt
translated: no
title: 1. Nos bastidores da ação do Twitter do R-Ladies IWD2018!
author: R-Ladies
date: '2018-03-26'
description: 'Parte 1: Ideação e criação!'
tags:
- iwd
- twitter
- part1
- 2018
categories:
- IWD
- R-Ladies
slug: 1_nos_bastidores_da_ação_do_twitter_do_r_ladies_iwd_2018
---

### Contada por Maëlle Salmon com notas de Bea Hernández

No dia 8 de março, Dia Internacional da Mulher, publicámos um feed contínuo de perfis fantásticos de R-Ladies de [do nosso diretório](http://rladies.org/directory/) via [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
Foi um espetáculo!
E muito trabalho de equipa também!
Nesta publicação do blogue, vamos explicar como concebemos e concluímos a nossa ação no Twitter.

## Uma ideia semeada no IWD2017!

No ano passado, no Dia Internacional da Mulher, [David Robinson, aliado do R-Ladies](https://twitter.com/drob/) [promovido](https://twitter.com/drob/status/839564664321282048)contas no Twitter de mulheres cientistas de dados.
Eu (Maëlle) tive a honra de ser mencionada nesse tweet e ainda me lembro de a) me sentir muito lisonjeada b) ver o meu número de seguidores disparar!
Tenho quase a certeza de que algumas das oportunidades que recebi desde então estão, pelo menos em parte, relacionadas com este facto [patrocínio](https://robinsones.github.io/The-Importance-of-Sponsorship/)do Dave.
Por isso, este ano quis retribuir!

No dia 1 de janeiro, apercebi-me de que um novo ano significava um novo IWD, pelo que era altura de planear!
Eu queria que tivéssemos uma ação que celebrasse muitas R-Ladies, não apenas aquelas que já recebem muita atenção.
De facto, os capítulos locais e a organização global do R-Ladies têm a missão de amplificar as vozes das R-Ladies, todas elas!
Sou viciada no Twitter, por isso pensei logo em criar um feed do Twitter para o perfil das R-Ladies, mas imaginei que a identificação das R-Ladies seria feita através de um inquérito.
[Steph Locke](https://twitter.com/stefflocke?lang=es)teve uma ideia muito melhor quando mencionei a minha no nosso Slack: usar entradas do nosso diretório e usar isto como uma oportunidade para promover o diretório!
Assim, este tornou-se o nosso plano!

## Trabalhar no diretório

Uma vez que o diretório se tornou central no nosso plano, recebeu muito carinho da Bea e dos mestres do diretório, Sheila e Page!

### Quanto mais entradas, melhor!

Voltámos a publicitar o anuário através de diferentes canais, em especial a nossa conta global no Twitter e os organizadores das secções locais.
Isto criou um fluxo de novas entradas, que a Sheila e a Page trataram eficazmente.

### Apreciar o diretório

\*Uma nota de [Bea](https://twitter.com/chucheria) sobre como embelezar o diretório:\*Depois de fazer as primeiras capturas de ecrã "feias", nós (Page, Sheila e eu) descobrimos que não tínhamos um método para adicionar nomes, por isso os títulos e outras informações foram colocados no nome.
Para além do tipo de letra grande para o nome, isso tornava o nome demasiado longo e algumas das capturas de ecrã acabaram por ficar feias.

Modificámos a informação, mas mesmo depois disso descobrimos que, dependendo de quem fez a captura de ecrã, o tipo de letra era diferente.
Ainda não encontrámos o problema, mas tudo aponta para um problema com`revealJS`.

Graças a isto, temos novos procedimentos para adicionar novos ficheiros e esperamos melhorar o diretório em breve com novas funcionalidades também.

### Exportar o diretório

Para o processamento posterior, precisávamos da ligação direta a cada entrada e de outras informações específicas da entrada, como um potencial identificador do Twitter.
Para isso, tivemos de recorrer a uma exportação do Wordpress e à recolha de dados na Web da diretoria, porque a exportação não incluía as ligações individuais e estas não podiam ser adivinhadas (por exemplo, a minha é <https://rladies.org/spain-rladies/name/maille-salmon/>porque fui registado pela primeira vez como Maille).
A Bea e eu escrevemos o código abaixo

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

## Webshooting e elogios aleatórios

O que significa publicar o perfil de R-Ladies?
Decidi que uma boa receita para um tweet era:

- Uma captura de ecrã da entrada do diretório das R-Ladies, uma vez que significaria uma imagem e que contém informações importantes sobre os talentos e interesses de cada R-Lady

- As hashtags #rladies e #iwd2018 (Graças a [Heather Turner](http://www.heatherturner.net) por me ter mostrado onde encontrar a hashtag oficial com antecedência!) para aumentar a visibilidade do feed e promover a nossa hashtag.

- Elogios aleatórios para o tornar mais amigável e divertido

- Uma hiperligação direta para a entrada no diretório para direcionar o tráfego para o diretório e permitir que o leitor do tweet vá realmente saber mais sobre a R-Lady, uma vez que a maioria das entradas lista outros perfis, como um sítio Web pessoal ou uma conta GitHub

- O identificador do Twitter da R-Lady, se disponível, para ajudar à sua visibilidade

### Preparar os tweets

Depois de termos criado a tabela das R-Ladies com os seus URLs diretos, preparar os tweets significava apenas criar elogios aleatórios que se podiam aplicar a qualquer R-Lady (sim, todas as R-Ladies são fantásticas e talentosas!) e colar todo o texto.

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

### Webshooting do diretório

O diretório foi capturado pela Web utilizando o `webshot` e `magick` com a seguinte função que recebe o URL de uma entrada e o ID de uma R-Lady como argumentos.

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

Todas as imagens foram preparadas antes do tweet, de modo a estarem prontas um pouco antes do IWD.

## A seguir: Parte 2

Continuar lendo Parte 2: [Implantação e manipulação de bots](/post/deployment/)!


