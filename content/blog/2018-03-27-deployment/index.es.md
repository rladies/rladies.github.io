---
language: es
translated: no
title: 2. ¡Entre bastidores de la acción de R-Ladies IWD2018 en Twitter!
author: R-Ladies
date: '2018-03-27'
description: 'Parte 2: Despliegue y gestión de bots'
slug: 2_entre_bastidores_de_la_acción_de_r_ladies_iwd_2018_en_twitter
tags:
- iwd
- part2
- twitter
- 2018
categories:
- IWD
- R-Ladies
---

### Según Kelly O'Briant

El 8 de marzo, Día Internacional de la Mujer, publicamos una serie continua de perfiles de R-Ladies desde [nuestro directorio](http://rladies.org/directory/) vía [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
¡It was a blast!
Y también mucho trabajo en equipo.
En esta entrada del blog, cubriremos las fases de despliegue y supervisión de nuestro proyecto.
También puedes leer la [Parte 1](/post/ideation_and_creation/).

## Recapitulación

Lo mejor de encargarse del despliegue de un proyecto es que la mayor parte del trabajo duro ya está hecho.
En esta sección, describiré cómo desplegamos y monitorizamos nuestra aplicación de Twitter para IWD 2018.
Las cosas no terminaron saliendo exactamente según lo planeado, pero se aprendieron lecciones y pudimos ajustar nuestro plan de juego sobre la marcha mientras hacíamos algunos compromisos menores.

Para repasar, aquí es donde estaba el proyecto cuando llegó el momento de que yo entrara:

*Todo el trabajo duro ya estaba hecho.*

- Crear una cuenta de twitter y una aplicación para desarrolladores
- Preparar las capturas de pantalla
- Preparación de los tweets

*En qué consistía mi trabajo:*

- Lanzar una imagen docker/rocker
- Haz algunas pruebas
- Empieza a enviar tweets en IWD2018
- Cruza los dedos por el éxito :)

*Lo que probablemente debería haber hecho también:*

- Desplegado la aplicación twitter Docker en una instancia en la nube (en caso de un corte de energía aquí en mi casa)
- Determinamos si tendríamos problemas por añadir nombres de usuario de Twitter a los tweets del bot.

## El trabajo

### Lanzamiento de Docker

*¿Por qué utilizar Docker?*

Sabía que tendríamos que estar twitteando durante unas 48 horas (después del 8 de marzo en todo el mundo) y nunca querría inmovilizar mi sesión local de R durante dos días enteros.
Una solución sencilla a este problema es lanzar una instancia local de Docker con R y RStudio instalados.

*Recursos Docker*

Empecé a aprender a usar Docker hace unos meses siguiendo [este impresionante tutorial docker/rocker de rOpenSciLabs](http://ropenscilabs.github.io/r-docker-tutorial/).
Lo recomiendo encarecidamente.
La vinculación de un volumen local (sistema de archivos) a una instancia de Docker es muy simple, y era básicamente todo lo que necesitaba hacer para poner en marcha este proyecto.

Cloné el repositorio de GitHub que usamos para todo nuestro código y datos, vinculé ese volumen a la instancia Docker ¡y disparé algunas pruebas de Twitter!

### Enviando los Tweets

Mi instinto inicial fue tratar de ejecutar el código de tweets como un script cron programado. [¿Qué es cron?](http://www.unixgeeks.org/security/newbie/unix/cron-1.html) Planeé configurar crontab de la siguiente manera [modificando el archivo Docker](https://www.ekito.fr/people/run-a-cron-job-with-docker/) para Rocker.

Pero siguiendo con el tema de "lo simple triunfa", acabé usando simplemente un bucle for y `Sys.sleep()`.
Yo estaba paranoico acerca de nuestra cuenta de conseguir marcado como un bot malicioso por la gente en twitter, así que pensé que ayudaría a añadir un par de "extra\_seconds" a cada ciclo de sueño.
De esta manera no estaríamos twitteando cada seis minutos en punto.
No tengo ni idea de si esto nos ayudó o no... aún así nos bloquearon unas cuantas veces.

*Código mínimo:*

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

### Supervisión y reparación de nuestra aplicación

El sitio `tweet_lady` está configurada para devolver `try_tweet`.
En el caso de un fallo de tuiteo, fue muy útil poder ejecutar rápidamente esta función fuera del bucle for para ver el tipo de error.
Nuestra aplicación se cayó varias veces (¿4?) durante nuestra tormenta de tweets #IWD de 48 horas, así que ejecuté este pequeño trozo de código muchas veces mientras probaba y restauraba nuestra aplicación:

```r
err <- tweet_lady(tweets[id,]$entry_id, tweets[id,]$tweet, token)
```

Los mensajes de error no siempre fueron de gran ayuda, pero me hizo sentir mejor verlos.
Los registros son reconfortantes, ¿sabes?
Nuestra primera aplicación se bloqueó después de tres horas de tuitear, y supusimos que el cierre se debía en parte al uso de los nombres de usuario de Twitter de las mujeres en el cuerpo de los mensajes de tuit.
Hubiera estado bien seguir etiquetando a la gente en los tuits, pero decidimos eliminar los handles para que nuestra aplicación volviera a funcionar (y siguiera funcionando).

Mi maravillosa amiga R-Ladies, [Hannah Frick](https://twitter.com/hfcfrick) se puso en contacto conmigo a través de Slack y nos animó a probar la gamificación de etiquetar a mano los usuarios de Twitter.
Esto terminó siendo muy divertido.
Me pasé*mucho*y la gente se abalanzaba para etiquetar a la gente antes de que yo tuviera la oportunidad.
Estoy muy contenta con el resultado de esta parte, ¡gracias, Hannah!
Y gracias a todos los que han dedicado su tiempo a etiquetar y escribir mensajes personales.

Todos los demás errores que tuvimos se solucionaron cambiando los bots de aplicación (teníamos tres), regenerando un token o alguna combinación de esas cosas.

### Conclusión del despliegue

Twitter y los bots de Twitter siguen siendo un misterio para mí.
¿Es un arte, una ciencia?
No tengo ni idea.
Me alegro de que haya sido un proyecto del Día Internacional de la Mujer y no haya durado ni una semana ni un mes.
Dicho esto, creo que llevaré conmigo durante mucho tiempo la sensación de haber participado en esta maravillosa y fantástica comunidad de #rladies #rstats.
Ha sido increíble.
Estoy muy contenta y agradecida por esta oportunidad.
¡Brindo por conocer a más increíbles R-Ladies en 2018!

## A continuación: Parte 3

Seguir leyendo Parte 3: [La gran conclusión](/post/conclusion/) ¡!


