---
language: es
translated: no
title: 1. ¡Entre bastidores de la acción de R-Ladies IWD2018 en Twitter!
author: R-Ladies
date: '2018-03-26'
description: 'Parte 1: Ideación y creación'
tags:
- iwd
- twitter
- part1
- 2018
categories:
- IWD
- R-Ladies
slug: 1_entre_bastidores_de_la_acción_de_r_ladies_iwd_2018_en_twitter
---

### Contada por Maëlle Salmon con notas de Bea Hernández

El 8 de marzo, Día Internacional de la Mujer, publicamos continuamente perfiles de R-Ladies desde [nuestro directorio](http://rladies.org/directory/) vía [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
¡It was a blast!
Y también mucho trabajo en equipo.
En esta entrada del blog, explicaremos cómo diseñamos y completamos nuestra acción en Twitter.

## ¡Una idea sembrada en IWD2017!

El año pasado en el Día Internacional de la Mujer, [R-Ladies aliado David Robinson](https://twitter.com/drob/) [promovido](https://twitter.com/drob/status/839564664321282048)cuentas de Twitter de científicas de datos.
Yo (Maëlle) tuve el honor de aparecer en este tuit, y aún recuerdo a) sentirme muy halagada b) ¡ver cómo se disparaba mi número de seguidores!
Estoy bastante segura de que muchas de las oportunidades que he recibido desde entonces están relacionadas, al menos en parte, con esto. [patrocinio](https://robinsones.github.io/The-Importance-of-Sponsorship/)de Dave.
Por eso, este año quería devolverle el favor.

El 1 de enero me di cuenta de que un nuevo año significaba un nuevo Día Internacional de la Mujer, ¡así que era hora de planificar!
Quería que tuviéramos una acción que celebrara a muchas mujeres R, no sólo a las que ya reciben mucha atención.
De hecho, las delegaciones locales de R-Ladies y la organización mundial tienen la misión de amplificar las voces de las R-Ladies, ¡de todas ellas!
Soy una adicta a Twitter, así que inmediatamente pensé en crear un perfil de R-Ladies en Twitter, pero me imaginé que podríamos identificar a las R-Ladies a través de una encuesta.
[Steph Locke](https://twitter.com/stefflocke?lang=es)tuvo una idea mucho mejor cuando mencioné la mía en nuestro Slack: ¡utilizar las entradas de nuestro directorio y aprovechar la oportunidad para promocionar el directorio!
Así que éste se convirtió en nuestro plan.

## Trabajando en el directorio

Desde que el directorio pasó a ocupar un lugar central en nuestro plan, Bea y los maestros del directorio, Sheila y Page, le han dedicado mucho cariño.

### ¡Cuantas más entradas, mejor!

Volvimos a anunciar el directorio a través de distintos canales, en particular nuestra cuenta mundial de Twitter y los organizadores de las secciones locales.
Esto generó un flujo de nuevas entradas que Sheila y Page gestionaron con eficacia.

### Embellecer el directorio

\*Una nota de [Bea](https://twitter.com/chucheria) sobre cómo embellecer el directorio:\*Después de hacer las primeras capturas de pantalla "feas", nosotras (Page, Sheila y yo) descubrimos que no teníamos un método para añadir nombres, así que los títulos y otra información se colocaron en el nombre.
Además de la fuente grande para el nombre, esto hizo que el nombre fuera demasiado largo y algunas de las capturas de pantalla terminaron viéndose feas.

Modificamos la información, pero incluso después descubrimos que dependiendo de quién hiciera la captura de pantalla la fuente era diferente.
No hemos encontrado el problema a eso, pero todo apunta a un problema con`revealJS`.

Gracias a esto, tenemos nuevos procedimientos para añadir nuevos archivos y esperamos mejorar el directorio pronto con nuevas características también.

### Exportar el directorio

Para el tratamiento posterior, necesitábamos el enlace directo a cada entrada y otra información específica de la entrada, como un posible identificador de Twitter.
Para ello, tuvimos que recurrir tanto a la exportación de Wordpress como al webscraping del directorio, ya que la exportación no incluía enlaces individuales y éstos no se podían adivinar (por ejemplo, el mío es <https://rladies.org/spain-rladies/name/maille-salmon/>porque primero me registraron como Maille).
Bea y yo escribimos el siguiente código

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

## Webshooting y cumplidos al azar

¿Qué significa publicar el perfil de R-Ladies?
Decidí que una buena receta para un tweet era:

- Una captura de pantalla de la entrada del directorio de R-Ladies, ya que significaría una imagen, y ya que contiene información importante sobre los talentos e intereses de cada R-Lady.

- Los hashtags #rladies y #iwd2018 (Gracias a [Heather Turner](http://www.heatherturner.net) por indicarme de antemano dónde encontrar el hashtag oficial) para aumentar la visibilidad del feed y promocionar nuestro hashtag.

- Elogios al azar para hacerlo más amistoso y divertido.

- Un enlace directo a la entrada del directorio para dirigir el tráfico al directorio y permitir que el lector del tweet realmente vaya a aprender más sobre la R-Lady, ya que la mayoría de las entradas enumeran otros perfiles como un sitio web personal o una cuenta de GitHub.

- La cuenta de Twitter de la R-Lady, si está disponible, para ayudar a su visibilidad.

### Preparación de los tuits

Una vez creada la tabla de las R-Ladies con las URL directas de sus directorios, preparar los tuits sólo significaba crear piropos aleatorios que pudieran aplicarse a cualquier R-Lady (sí, ¡todas las R-Ladies son increíbles y tienen talento!) y pegar todo el texto.

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

### Webshooting del directorio

El directorio se ha sometido a un webshot con el programa `webshot` y `magick` con la siguiente función que toma como argumentos la URL de una entrada y el ID de una R-Lady.

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

Todas las imágenes se prepararon antes de tuitearlas, para que estuvieran listas un poco antes del IWD.

## A continuación: Parte 2

Seguir leyendo Parte 2: [Despliegue y gestión de bots](/post/deployment/) ¡!


