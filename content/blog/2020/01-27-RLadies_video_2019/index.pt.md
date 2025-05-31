---
language: pt
translated: no
title: Receita para um vídeo de fim de ano
author: Yanina Bellini Saibene, Alejandra Bellini, and Laura Acion
date: '2020-01-27'
description: ''
tags: 2019
categories: R-Ladies
always_allow_html: yes
slug: receita_para_um_vídeo_de_fim_de_ano
---

Para encerrar o fantástico ano de 2019 das R-Ladies, fizemos um vídeo, se ainda não o viu, aqui está ele:

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Feliz Ano Novo para todas as <a href="https://twitter.com/hashtag/rladies?src=hash&amp;ref_src=twsrc%5Etfw">#rladies</a> e aliadas! <br><br>Vídeo realizado por <a href="https://twitter.com/yabellini?ref_src=twsrc%5Etfw">@yabellini</a> &amp; <a href="https://twitter.com/_lacion_?ref_src=twsrc%5Etfw">@_lacion_</a> , voz <a href="https://twitter.com/AlejaBellini?ref_src=twsrc%5Etfw">@AlejaBellini</a> <a href="https://t.co/QRxuJxLugj">pic.twitter.com/QRxuJxLugj</a></p>&mdash; R-Ladies Global (@RLadiesGlobal) <a href="https://twitter.com/RLadiesGlobal/status/1212451523655065605?ref_src=twsrc%5Etfw">January 1, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>  

Gostou?
Queres saber como o fizemos?
Aqui damos-lhe todos os pormenores:

## Que história vamos contar?

O primeiro passo é decidir que história é que o vídeo vai contar.
Uma mensagem de "fim de ano" tem geralmente três partes:

1) o que o ano trouxe,
2) dar graças pelas realizações do ano, e
3) e felicitar todos aqueles que nos acompanharam durante o nosso passeio à volta do sol.

A história das R-Ladies seria para realçar as conquistas globais *com números* (afinal de contas, somos pessoas que se dedicam a #rstats e os números da R-Ladies são maravilhosos) e *para agradecer a quem nos acompanhou*.

## Geração do guião e da matéria-prima para o vídeo

O segundo passo é montar o roteiro do vídeo, que terá três cenas.

### Cena um: o alcance global

Os números das secções globais do R-Ladies são apresentados de forma a realçar a forma como nos organizamos.
Também visualizamos o que foi feito e o quanto crescemos em 2019.
Para podermos exprimir essa ideia, escolhemos indicadores concretos das nossas actividades:

- o número de capítulos,
- o número de países,
- o número de membros, e
- o número total de eventos realizados no ano de 2019

Os três primeiros números foram extraídos do [Conselho da Comunidade R-Ladies](https://benubah.github.io/r-community-explorer/rladies.html).
O número de eventos foi calculado utilizando a fórmula [meetupr](https://github.com/rladies/meetupr) desenvolvido por R-Ladies.

Para seguir os nossos passos, a primeira coisa a fazer é carregar os pacotes necessários e gerar as variáveis e funções necessárias:

```
# API KEY of Meetup
# The API keys is soon deprecated more info here: https://www.meetup.com/meetup_api/auth/
Sys.setenv(MEETUP_KEY = "your API Key") 

# Packages needed to work
library(meetupr)
library(purrr)
library(dplyr)
library(tidyr)
library(lubridate)

```

Agora temos de obter todos os grupos de encontro que correspondem ao R-Ladies:

```
# Getting all the R-Ladies groups
all_rladies_groups <- find_groups(text = "r-ladies")

# Cleaning the list
rladies_groups <- all_rladies_groups[grep(pattern = "rladies|r-ladies", 
                                          x = all_rladies_groups$name,
                                          ignore.case = TRUE), ]
```

Com a lista de grupos, procuramos todos os eventos realizados por cada um destes grupos e calculamos o número de eventos:

```
# We get all the events that already took place.

eventos <- rladies_groups$urlname %>%
  map(purrr::slowly(safely(get_events)), event_status='past') %>% transpose()
  
# In eventos we have a list with all the event data: name, date,
# place, description and several more columns of data.
# At the moment the list has two elements: a list with the correct results
# and another with errors. It gives an error when there are no past events in the group.

# We are only interested in the information we had in results. So we keep that information
# The results list has one tibble per group with the events held for that group
# We will put together a single tibble with all the events together

# We create a logical vector with events where there is an error

eventos_con_datos <- eventos$result %>% 
  map_lgl(is_null)

# Filter the correct events with the previous logical vector and then bind all the tibbles
# for their rows in one tibble/list using the map_dfr function of the purrr package

eventos_todos_juntos <- eventos$result[!eventos_con_datos] %>% 
  map_dfr(~ .) 

# We then count the number of events held per year

eventos_todos_juntos %>%
  group_by(year(time)) %>%
  summarise(cantidad = n())

```

Com todos os dados calculados, o texto dessa cena é o seguinte:

*"R-Ladies 2019 em números: Mais de 60 000 membros de 50 países de todo o mundo, organizados em 182 capítulos que realizaram 858 eventos."*

Para ilustrar esta parte da mensagem, o mapa-mundo com a localização de todos os capítulos é uma imagem poderosa, que já utilizámos noutras campanhas.
Gostámos muito da [mapa](https://github.com/rladiescolombo/R-Ladies_world_map) que [R-Senhoras Colombo](https://rladiescolombo.netlify.com/)fez para apresentar o seu capítulo, pelo que utilizámos o seu mapa de base para montar o mapa do vídeo.
Actualizámos as informações para 27/12/2019 e certificámo-nos de que todos os capítulos tinham a latitude e a longitude para serem mapeados.

![](MapaVideo.png)

Este é o código completo para o fazer:

```
library(ggplot2)
library(maptools)
library(tibble)
library(readxl)
library(readr)
data(wrld_simpl)

# This code generates the world map and is taken from the R-Ladies Colombo code
p <- ggplot() +
  geom_polygon(
    data = wrld_simpl,
    aes(x = long, y = lat, group = group), fill = "thistle", colour = "white"
  ) +
  coord_cartesian(xlim = c(-180, 180), ylim = c(-90, 90)) +
  scale_x_continuous(breaks = seq(-180, 180, 120)) +
  scale_y_continuous(breaks = seq(-90, 90, 100))

# R-Ladies Current Chapters: https://github.com/rladies/starter-kit/blob/master/Current-Chapters.csv
# I read the current R-Ladies chapters after downloading it from the web
Current_Chapters <- read_csv(here::here("Current-Chapters.csv"))

# We read a file with the cities of the chapters with the latitude and longitude data
LatLong <- read_excel(here::here("LatLong2019.xlsx")) 

# Join the chapter data with latitude and longitude data
Current_Chapters <- Current_Chapters %>% 
  left_join(LatLong, by = c("City", "State.Region", "Country")) %>%
  filter(!str_detect(Status, 'Retired.*'))

# We add the points of each chapter to the world map
p <- p +
  geom_point(
    data = Current_Chapters, aes(x = Longitude, y = Latitude), color = "mediumpurple1", size
    = 3
  ) 
```

### Cena dois: 100% trabalho voluntário

O objetivo é também apresentar *o número de outras iniciativas de R-Ladies* para além dos capítulos e dos eventos, para nos concentrarmos nas nossas *meios de comunicação, no nosso diretório de especialistas, na nossa rede de revisão e na produção de material educativo*para os nossos encontros, conferências, eventos com outras organizações, etc.
Destacando o esforço do trabalho voluntário para alcançar todos estes resultados.
O [Equipa Global da R-Ladies](https://rladies.org/about-us/team/) forneceu-nos os números referidos no [diretório R-Ladies](https://rladies.org/directory/) e do diretório [rede de avaliação](tinyurl.com/rladiesrevs).
Para calcular o número de seguidores das nossas contas no Twitter, utilizamos o`rtweet` com o seguinte código:

```
# We load the necessary packages
library(dplyr)
library(lubridate)
library(stringr)
library(tidyr)
library(rtweet)

# Get all twitter users that use the the string RLadies
users <- search_users(q = 'RLadies',
                      n = 1000,
                      parse = TRUE)

# Then we must keep the unique users
rladies <- unique(users) %>%
  # The regular expression searches for a string containing the word RLadies or rladies, anywhere
  # in the string  
  filter(str_detect(screen_name, '[R-r][L-l](adies).*') & 
           # Filter users who meet the condition of the regular expression but are not accounts
           # related to R-Ladies
           !screen_name %in% c('RLadies', 'RLadies_LF', 'Junior_RLadies', 'QueensRLadies', 
                               'WomenRLadies', 'Rstn_RLadies13', 'RnRladies')) %>%
  # We keep these three variables that allow us to identify each account
  # with the number of followers each one has
  select(screen_name, location, followers_count)

# We calculate the total number of followers for all accounts
rladies %>% 
  summarise(sum(followers_count))

```

A imagem selecionada para esta parte do vídeo foi tirada em LatinR 2019.
Estávamos a preparar a foto de grupo das R-Ladies e, sem nos apercebermos, formámos um coração!!!
(que foi captado por [TuQmano's](https://twitter.com/TuQmano)olho e câmara).
A imagem representa o crescimento das R-Ladies, também para além da América do Norte e da Europa, e o código que nos move a trabalhar em equipa para o bem-estar das R-Ladies e da comunidade em geral.

![](corazon.png)

O texto final da cena era:

*Temos mais de 65.000 seguidores nas nossas contas do Twitter, 940 especialistas no diretório R-Ladies, 80 revisores internacionais na nossa rede de revisores e produzimos mais de 600 documentos com materiais didácticos. Tudo feito com 100% de trabalho voluntário*

### Terceira cena: votos de felicidades!

Aqui queríamos desejar um bom ano para todas as R-Ladies, e também para todos os aliados que nos acompanharam durante o ano.
A imagem selecionada é o nosso logótipo e o endereço do nosso sítio Web.

O texto para esta cena é:

*Feliz Ano Novo para todas as R-Ladies e seus aliados! Mais informações em rladies dot org*

![](placafinal.png)

### Língua

Como o R-Ladies é uma comunidade global, o vídeo tinha de ser em inglês, a língua que o mundo fala.
Mas porque não também em espanhol?
A comunidade latino-americana do R cresceu muito durante este tempo e isso deve-se em grande parte ao esforço e ao trabalho das R-Ladies nesta região do mundo.
Assim, decidimos gerar o vídeo em ambas as línguas para celebrar este trabalho árduo.
[Laura Acion](https://twitter.com/_lacion_/) foi responsável pela correção e tradução do texto de cada cena.

### Texto, imagens... áudio?

Ora, um vídeo apenas com letras, números e imagens deixaria muitas pessoas fora da nossa mensagem, pelo que decidimos gravar o áudio da mensagem.
Para isso, contámos com a ajuda do génio de [Alejandra Bellini](https://twitter.com/AlejaBellini) que gravou o áudio em espanhol e inglês.
Ela gravou-o através do WhatsApp com um telemóvel, depois usámos [Zamzar](https://www.zamzar.com) para transformar o áudio em MP3 e [Mp3cut](https://mp3cut.net/en/) para cortar o áudio nas partes necessárias para poder sincronizar o áudio com o texto e as imagens de vídeo.

## Terceiro passo: editar ...

Com este plano em mente, chegou a altura de editar o vídeo.
Utilizámos o software Doodly, que fornece música e tipos de letra, para os efeitos de desenho à mão.
A parte mais trabalhosa foi a sincronização do áudio com o desenho dos números e letras.

O resultado foram dois vídeos, um em espanhol e outro em inglês, onde contamos num minuto o que as R-Ladies fizeram durante 2019.
Foi uma tarefa muito divertida, com muitas risadas e tentativas, especialmente a gravação do áudio em inglês.

O vídeo final foi enviado à equipa Global para divulgação nas redes sociais a 31 de dezembro de 2019.

Autoras: Yanina Bellini Saibene, Alejandra Bellini y Laura Acion

[Versão em espanhol](/post/rladies_video_2019/index.es.html)


