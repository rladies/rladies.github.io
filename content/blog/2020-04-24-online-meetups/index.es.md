---
language: es
translated: no
title: Infraestructura R-Ladies para grupos de Meetup en línea
author: R-Ladies Global Leadership Team
date: '2020-04-24'
description: Infraestructura R-Ladies para grupos de Meetup en línea
tags:
- community
- online-meetups
categories: r-ladies
always_allow_html: yes
output:
  html_document:
    keep_md: yes
slug: infraestructura_r_ladies_para_grupos_de_meetup_en_línea
---

Nuestros capítulos han cancelado las reuniones presenciales debido a la pandemia del virus corona.
Sin embargo, queremos que nuestros miembros puedan seguir conectados y compartir sus últimos descubrimientos y viajes relacionados con R.
Para ayudar a los organizadores de nuestros capítulos a trasladar sus eventos a Internet, hemos decidido proporcionarles una infraestructura de videoconferencia.

Nuestra red ha crecido hasta superar los 160 capítulos en todo el mundo, así que nos preguntábamos cuántas salas de reuniones necesitaríamos.
¿Bastaba con una o tendríamos muchos conflictos de programación?
Qué buena oportunidad para aprovechar nuestra [{meetupr}](https://github.com/rladies/meetupr) y hacernos una idea de la frecuencia con la que se han solapado eventos en el pasado.

### Obtener los datos

```r
#devtools::install_github("rladies/meetupr")
library(meetupr)
library(tidyverse)
library(lubridate)
library(scales)
```

En primer lugar, obtenemos todos los grupos de Meetup de R-Ladies para poder obtener todos sus eventos en un segundo paso.

```r
# get the R-Ladies chapters

groups <- meetupr::find_groups(text = "r-ladies") 

chapters <- groups %>% 
  filter(str_detect(tolower(name), "r-ladies"))
```

Queremos evitar superar el límite de peticiones de la API, por lo que utilizaremos el método [solución](https://github.com/rladies/meetupr/issues/30) publicada por Jesse Mostipak.

```r
# get the events for the chapters

slowly <- function(f, delay = 0.5) {
  function(...) {
    Sys.sleep(delay)
    f(...)
  }
}

events <- map(chapters$urlname,
              slowly(safely(meetupr::get_events)),
              event_status = c("past", "upcoming")) %>% 
  set_names(chapters$name)
```

El uso de `safely()`significa que nuestro mapeo no falla por completo si falla la obtención de los eventos para cualquiera de los capítulos.
Ahora sólo tenemos que extraer los eventos de los capítulos en los que hemos tenido éxito.

```r
all_events <- map_dfr(events, 
                      ~ if (is.null(.$error)) .$result else NULL, 
                      .id = "chapter")
```

### ¿Con qué frecuencia (al mes) se celebran dos o más reuniones de R-Ladies al mismo tiempo?

Lo primero que queremos saber es si es habitual que se celebren dos o más eventos al mismo tiempo.

Para simplificar las cosas, nos fijamos en los sucesos que empiezan al mismo tiempo y, de momento, no nos fijamos en los sucesos que se solapan.
Esto incluye acontecimientos pasados y futuros.

```r
all_events %>% 
  count(time) %>% 
  filter(n > 1) %>% 
  mutate(time = floor_date(time, unit = "months")) %>% 
  count(time) %>% 
  ggplot() + 
  geom_col(aes(time, n)) +
  scale_x_datetime(breaks = scales::date_breaks("1 month"),
                   labels = scales::date_format("%Y-%b")) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
```

![](index.en_files/figure-html/parallel_per_month_vis-1.png)<!-- -->

Así pues, no es raro que haya eventos paralelos de R-Ladies, pero ahora la pregunta es: ¿cuántos eventos se celebran al mismo tiempo?

### ¿Cuántos eventos suelen tener lugar al mismo tiempo?

```r
all_events %>% 
  count(time, name = "simultaneous_events") %>% 
  count(simultaneous_events) %>% 
  arrange(desc(simultaneous_events))
```

```
## # A tibble: 5 x 2
##   simultaneous_events     n
##                 <int> <int>
## 1                   9     1
## 2                   4     1
## 3                   3    16
## 4                   2   144
## 5                   1  1953
```

Una vez tuvimos 9 eventos de R-Ladies al mismo tiempo.
Si nos fijamos en la fecha, veremos que se trataba de las rstudio::conf watch parties (29 de enero de 2020):

```r
all_events %>% 
  count(time, sort = TRUE) %>% 
  top_n(1) 
```

```
## Selecting by n
```

```
## # A tibble: 1 x 2
##   time                    n
##   <dttm>              <int>
## 1 2020-01-29 16:00:00     9
```

Más de 2 eventos paralelos han sido relativamente raros por lo que estamos empezando con una sala de reuniones virtual que nuestros capítulos pueden reservar y esperamos que los conflictos de programación se pueden evitar.

Si eres organizador de R-Ladies y quieres utilizar esta nueva infraestructura, únete al canal #online\_meetups en el Slack de organizadores.
Allí encontrará instrucciones sobre cómo reservar una reunión y consejos para organizar eventos en línea de forma segura.

### Próximos eventos en línea

Si quieres unirte a los eventos de las secciones de R-Ladies de todo el mundo, los próximos eventos son

- 25 de abril R-Ladies Mumbai: [[ONLINE] - Exploración del visual 'Highcharts' en R](https://www.meetup.com/rladies-mumbai/events/270006904/)
- 25 de abril R-Ladies Tampa: [APLAZADO: Flujo de trabajo y transformación de datos ](https://www.meetup.com/rladies-tampa/events/270192107/)
- 25 de abril R-Ladies La Paz: [Grupo de Estudio - R para Ciencia de Datos [Sesión 4]](https://www.meetup.com/rladies-la-paz/events/270212766/)
- 28 de abril R-Ladies Bucarest: [R-Ladies Bucarest Comunidad #8 ](https://www.meetup.com/rladies-bucharest/events/270178279/)
- 28 de abril R-Ladies Gainesville: [Tidy Tuesday: Practicando la Ciencia de Datos en R](https://www.meetup.com/rladies-gainesville/events/268773535/)
- 28 de abril R-Ladies Mid-Mo: [Charla relámpago y taller de abril de Code-RLadies - ¡Virtual!](https://www.meetup.com/rladies-mid-mo/events/268698590/)
- 29 de abril R-Ladies Nueva York: [[Evento en línea] Panel R-Ladies: Todo sobre los blogs](https://www.meetup.com/rladies-newyork/events/270210924/)
- 30 de abril R-Ladies Miami: [De perdedoras a ganadoras](https://www.meetup.com/rladies-miami/events/270087598/)
- 05 de mayo R-Ladies Freiburg: [Martes de orden - Trucos y consejos](https://www.meetup.com/rladies-freiburg/events/270214676/)
- Mayo 06 R-Ladies Chicago: [Learning \& Community Building in Data Science: Conferencias](https://www.meetup.com/rladies-chicago/events/269909895/)

**Todos los eventos de R-Ladies también están listados en <https://www.meetup.com/pro/rladies/>.**


