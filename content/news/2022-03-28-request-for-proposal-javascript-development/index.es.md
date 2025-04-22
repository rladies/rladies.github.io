---
language: es
translated: no
title: Solicitud de propuesta - Desarrollo de Javascript (Trabajo por contrato)
author: Athanasia M. Mowinckel
type: blog
date: '2022-03-28'
slug: solicitud_de_propuesta_desarrollo_de_javascript_trabajo_por_contrato
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

**La organización mundial R-Ladies desea implementar algunas nuevas funcionalidades (utilizando Javascript) para una reimplementación de su sitio web, cuyo código fuente se puede encontrar en [GitHub](https://github.com/rladies/website).**

A R-Ladies le gustaría invitarle a preparar una propuesta para llevar a cabo la tarea anterior que incluya plazos, costes y resultados.
La siguiente solicitud de propuestas incluye los antecedentes de nuestra organización y describe el propósito del rediseño, su funcionalidad deseada y las solicitudes específicas relacionadas con la propuesta.
Entendemos que los detalles pueden estar sujetos a cambios por recomendación del proveedor y/o investigación de soluciones más óptimas.
En su propuesta, no dude en sugerir alternativas donde se indique.

</más

## Antecedentes de la empresa

R-Ladies, es una organización mundial cuya misión es promover la diversidad de género en la comunidad R.

La comunidad de R sufre una infrarrepresentación de los géneros minoritarios (incluyendo pero no limitándose a mujeres cis/trans, hombres trans, no binarios, genderqueer, agender) en todos los roles y áreas de participación, ya sea como líderes, desarrolladores de paquetes, ponentes en conferencias, participantes en conferencias, educadores o usuarios (ver estadísticas recientes).

Como iniciativa de diversidad, la misión de R-Ladies es lograr una representación proporcional alentando, inspirando y empoderando a las personas de géneros actualmente subrepresentados en la comunidad R.
El objetivo principal de R-Ladies, por lo tanto, es apoyar a los entusiastas de R de géneros minoritarios para que alcancen su potencial de programación, construyendo una red global colaborativa de líderes, mentores, aprendices y desarrolladores de R para facilitar el progreso individual y colectivo en todo el mundo.

### Director del proyecto

[Athanasia Monika Mowinckel](https://drmowinckels.io/)

## Presupuesto

Pedimos a los posibles contratistas que presenten un presupuesto preliminar para su propuesta.
Este presupuesto puede facilitarse en forma de tarifas horarias con una estimación del número de horas necesarias para completar el proyecto.
El trabajo de desarrollo puede ser imprevisible, por lo que entendemos que las horas estimadas hasta la finalización pueden diferir en cierta medida de las estimaciones de la propuesta.

## Calendario

### Plazo de presentación de propuestas

1 de mayo<sup>st</sup>, 2022

### Selección de contratistas

Las selecciones iniciales comienzan inmediatamente después del plazo de respuesta.
Los finalistas serán notificados antes del 15 de junio y tendrán la oportunidad de entrevistarse con el director del proyecto para revisar la propuesta.
La decisión final deberá tomarse antes del comienzo de julio de 2022.

### Inicio del proyecto

Antes: 1 de julio<sup>st</sup> 2022  
Última hora: 1 de septiembre<sup>st</sup> 2022

El director del proyecto no está disponible en agosto, pero se esperan llamadas bimensuales con el director del proyecto durante todo el período del proyecto, así como comunicación asíncrona a través de correo electrónico y GitHub.

## Fecha de lanzamiento deseada

El lanzamiento definitivo de la web está previsto para el 1 de enero<sup>st</sup> 2023, por lo que todos los problemas importantes deberían estar solucionados para el 1 de diciembre de<sup>st</sup>2022\.
Una primera propuesta de solución para los problemas debe desarrollarse antes del 1 de noviembre<sup>st</sup> 2022, para la revisión del código y las pruebas.

## Desafíos

El nuevo sitio web de R-Ladies se está desarrollando utilizando [Hugo](https://gohugo.io/) un generador de sitios web estáticos.
El código fuente completo y la información de compilación pueden encontrarse en [GitHub](https://github.com/rladies/website).
El desarrollo de las plantillas Hugo y la logística de compilación corren a cargo de los desarrolladores de R-Ladies.
Puede encontrar más información sobre la configuración de Hugo para este proyecto en la sección [repo wiki](https://github.com/rladies/website/wiki).
Las partes del proyecto que se implementan en javascript, sin embargo, requieren la atención de algunos expertos.
Los miembros del R-Ladies Global Team no son desarrolladores de Javascript, por lo que el proyecto necesita la supervisión de alguien más experto para asegurarse de que funciona según lo previsto y se implementa con buenas prácticas.

## Objetivos

El experto en javascript trabajará en estrecha colaboración con los desarrolladores de R-Ladies para garantizar el comportamiento deseado del sitio web.
La plataforma principal para el desarrollo es a través de GitHub.

- **[Directorio de R-Ladies](https://pensive-babbage-969fad.netlify.app/directory/)**
  
  - [Lista.js](https://listjs.com/) donde la paginación funciona bien, pero [flechas no](https://github.com/rladies/website/issues/88)
  - [Otras características deseadas](https://github.com/rladies/website/issues/83):
    - Barajar la lista
    - Posibilidad de ampliar la clasificación/limitación de la lista a, por ejemplo, idiomas, lugares, etc.

- **[Calendario de eventos](https://pensive-babbage-969fad.netlify.app/activities/events/)**
  
  - Utiliza [Calendario de Toast UI (TUI)](https://ui.toast.com/tui-calendar)
  - [No compatible con todos los navegadores](https://github.com/rladies/website/issues/90)
  - Investigue si [pueden mostrarse en la hora local del navegador](https://github.com/rladies/website/issues/86)

- **Más general**
  
  - Consolidar las implementaciones generales de JS
  - [Principales bibliotecas javascript](https://github.com/rladies/website/tree/master/themes/hugo-rladies/static/js) utilizadas:
    - List.js
    - Momento.js
    - Tui-calendario.js
    - Bootstrap.js
    - jquery.js
  - podrían necesitar ajustes en su implementación en términos de
    - Rendimiento y solidez
    - Buenas prácticas de aplicación de JS
    - Limpieza general del código

## Criterios de evaluación

El contratista debe documentar experiencia y conocimientos en:

- Desarrollo de javascript para sitios web
- Uso de GitHub para desarrollo colaborativo

Lo siguiente también contará positivamente para cualquier aplicación

- Familiaridad documentada con Hugo
- Representación de minorías en el equipo de desarrollo (en particular, sexo y origen étnico)
- Familiaridad con las principales bibliotecas JS utilizadas
  - List.js
  - Tui-calendario.js
  - Momento.js

## Instrucciones de envío

Si tiene alguna pregunta sobre la presentación o la propia RFP, envíe un correo electrónico a \[ [rfp@rladies.org](mailto:rfp@rladies.org)\]( <mailto:rfp@rladies.org>?
subject=RFP: JS website development) con "RFP: JS website development" en el campo del asunto, y el gestor del proyecto responderá lo antes posible.

Todas las propuestas deberán contener la siguiente información, en el orden especificado:

**Empresa/Bio del contratista**

- Descripción general de la empresa y tipo de trabajo que realiza
- Nombre, dirección, correo electrónico, teléfono, sitio web
- Nº de años en funcionamiento

Biografía del equipo (sólo aplicable a los contratistas de la empresa)\*\*

- Nº de personas (aprox.) que trabajarán en el proyecto del sitio web, sus funciones y responsabilidades
- Tamaño del equipo, biografías, años de experiencia de cada uno, su función, premios/certificaciones
- Recursos adicionales necesarios (por ejemplo, subcontratistas).

**Referencias**

- Principales clientes y fecha de su asociación
- 4-6 referencias de clientes
- 3-5 proyectos relevantes, quién trabajó en cada proyecto, enlace al estudio de caso o URL del sitio web
- Alternativa: enlace a un portafolio

**Propuesta de proyecto**

- Nº de horas y calendario general desde el inicio hasta la finalización (aprox.)
- Posiblemente también se especifique por tema de GitHub directamente
- Si se sugieren bibliotecas js alternativas para la funcionalidad deseada
  - Descripción de por qué la alternativa es una mejor opción
  - Comparación de las características entre las dos opciones competidoras
  - Estimación del tiempo que llevará el cambio de biblioteca en comparación con la búsqueda de una solución con la que se utiliza actualmente.
- Propuesta del flujo de comunicación previsto entre el jefe de proyecto de R-Ladies y el equipo de la empresa

**Presupuesto**  
Estimación de los costes de la propuesta Podría describirse como tarifas horarias y número estimado de horas necesarias

Utilice este formulario para enviar su propuesta: <https://forms.gle/34bHsnDJppLwPstd6>


