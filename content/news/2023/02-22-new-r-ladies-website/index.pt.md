---
language: pt
translated: no
title: Novo sítio Web das R-Ladies
author: Athanasia M. Mowinckel
type: blog
date: '2023-02-22'
slug: novo_sítio_web_das_r_ladies
categories: R-Ladies
tags: []
---

É com grande entusiasmo que anunciamos o lançamento do nosso novo sítio Web R-Ladies!

Foi uma longa jornada, com muitas pessoas envolvidas, e estamos felizes por podermos finalmente partilhar convosco este novo site e alguns novos conteúdos.

<!-mais-->

A Liderança e a Equipa Global do R-Ladies querem expressar a nossa sincera gratidão à Mo pelo seu incrível trabalho no desenvolvimento do novo site do R-Ladies.
Mo dedicou muitas horas de trabalho árduo e invisível para alcançar este importante marco.

Os seus conhecimentos técnicos foram fundamentais para a concretização deste projeto.
Dedicou muito cuidado à criação de uma interface profissional e bonita, mas também à criação de fluxos de trabalho de atualização sustentáveis para humanos e máquinas.
O novo sítio Web representa uma melhoria significativa em relação ao anterior e temos a certeza de que irá melhorar a nossa capacidade de nos ligarmos e servirmos a nossa comunidade de R-Ladies em todo o mundo.

Muito obrigada, Mo!

***

Havia alguns problemas importantes que queríamos resolver com a nossa página web, que não conseguíamos manter facilmente com o site Wordpress que tínhamos:

- Sítio Web multilingue: Esta não é a manutenção mais fácil com o Wordpress
- Diretório muito lento: A base de dados era demasiado lenta e pesada, o tempo de carregamento das páginas era horrível
- Integrar o blogue no sítio Web: O blogue era um sítio Blogdown mantido através do Github e do Netlify
- Manutenção e colaboração mais fáceis a longo prazo: O Wordpress exigiria a criação de um utilizador para cada pessoa que quisesse contribuir para o sítio
  - Mudar para algo alojado no GitHub significaria uma ajuda e colaboração mais fáceis para a comunidade

## Histórico

O trabalho já começou em 2019, com Bea Hernandez, Daloha Rodríguez-Molina e Maëlle Salmon.
O trabalho inicial consistiu em fazer um [blogdown](https://bookdown.org/yihui/blogdown/) que utiliza o sítio Web [Hugo](https://gohugo.io/) e a integração do R markdown.
Foi um sítio natural para começar a transformar o nosso site Wordpress em algo mais comum na nossa comunidade.
Além disso, o site Wordpress estava a exigir cada vez mais manutenção e, em particular, o nosso [diretório R-Ladies](https://www.rladies.org/directory/) estava tão lento que estávamos a receber relatos de pessoas que não o utilizavam porque o tempo de carregamento da página era muito longo!

Em 2020, eu (Athanasia Mowinckel) fui integrada na equipa do sítio Web, inicialmente para manter o sítio Wordpress enquanto o novo sítio Hugo estava a ser construído.
Passado pouco tempo, comecei também a trabalhar no sítio blogdown.

Em meados de 2020, decidimos que a página web seria melhor servida como um sítio Hugo puro, e não como blogdown.
Nessa altura, isso deveu-se a algumas caraterísticas do Hugo que não existiam na Blogdown (ainda) e que queríamos utilizar no sítio Web.
Tratava-se de configurações para sítios multilingues que queríamos aproveitar.
Nessa altura, apercebi-me que estava muito empenhado em fazer com que toda a espinha dorsal do Hugo funcionasse para a R-Ladies, e isso significaria criar o nosso próprio tema personalizado, em vez de algo pré-fabricado.

Foi então que surgiu o Covid, e todos nós [sentimos o stress desse período](https://www.rladies.org/news/2020-11-23-reduced-service-note/).
O desenvolvimento foi lento e as coisas arrastaram-se.
Felizmente, a Liderança contactou-me e perguntou-me se eu precisava de ajuda para colocar as últimas peças no lugar, e que podíamos reservar um pequeno orçamento para contratar ajuda para as peças de javascript com que eu estava a ter dificuldades.

Nós [anunciámos](https://rladies.org/news/2022-03-28-request-for-proposal-javascript-development/) a necessidade, e contratámos [Ben Ubah](https://github.com/benubah)para me ajudar a colocar as últimas peças cruciais no sítio.
Finalmente, estávamos quase a terminar!

## Lançamento e novas funcionalidades!

Já lançámos o novo sítio Web e estamos entusiasmados com o seu funcionamento até agora!
O tema é bem adequado para nós e é muito mais fácil lidar com o conteúdo agora que podemos colaborar através do GitHub.
Também foi possível integrar o sítio Web com outras condutas automáticas, o que nos permite ter algumas funcionalidades novas no sítio Web!

- [Página de eventos](https://www.rladies.org/activities/events/) com um calendário de eventos do R-Ladies: Estes são obtidos diariamente do meetup através da sua API
- [Página de diretório](https://www.rladies.org/directory/) que é de facto rápida! Atualizado e mantido noutro repositório privado com integração no Airtable
- [Blogue](https://www.rladies.org/blog/) onde aceitamos contribuições e posts cruzados: Gostaríamos de ver o blogue reavivado e utilizado pela nossa comunidade para mostrar as suas capacidades e coisas divertidas que estão a fazer com o R!
- [Página de notícias](https://www.rladies.org/news/) onde a equipa do R-Ladies Global pode anunciar avisos importantes sobre a governação global da nossa comunidade

E mais!

## Trabalho futuro e pedido de ajuda à comunidade

Ainda há algumas coisas em que estamos a trabalhar em segundo plano, que esperamos venham a melhorar a experiência do nosso sítio Web e também a cumprir obrigações que prometemos anteriormente.
Temos um [wiki do sítio Web](https://github.com/rladies/rladies.github.io/wiki) com mais informações sobre a configuração do sítio Web e a forma como as pessoas podem contribuir para o mesmo.

### Página Web multilingue

Configurámos o sítio Web para ser multilingue e temos alguns conteúdos em desenvolvimento para francês, espanhol e português.
No entanto, ainda há um longo caminho a percorrer até chegarmos a um ponto em que estas línguas estejam suficientemente bem traduzidas e em que tenha sido traduzido conteúdo suficiente para que a língua seja lançada no sítio Web de produção.
Além disso, partimos do princípio de que, assim que começarmos a ter mais conteúdo traduzido, veremos áreas em que o código precisa de ser corrigido para um suporte multilingue adequado.

Esperamos que, com a ajuda da comunidade, possamos fazer um esforço para cobrir as principais línguas utilizadas pela nossa comunidade.
A wiki do site tem a sua própria secção para [contribuir com traduções de línguas do sítio](https://github.com/rladies/rladies.github.io/wiki/Adding-a-new-language).
É provável que tenha de ser trabalhado para ser mais explícito quanto às necessidades, mas esperamos que constitua um guia de partida.

### Melhorias no diretório

#### Atualização de entradas

O diretório foi transferido do Wordpress com alguns scripts bastante elaborados e complicados para que o conteúdo funcione no nosso novo sítio Web.
Isto significa que, para muitas das entradas, o conteúdo parece estranho e deslocado no novo sítio Web.
A melhor maneira de atualizar a sua própria entrada no diretório é localizar a sua entrada e preencher o formulário [formulário](https://airtable.com/shr54Z3BqfRJqypZ7) para atualizar a lista.
Desta forma, podemos criar um diretório melhor e mais unificado para todos!

#### Melhor pesquisa / filtragem

Atualmente, estamos a utilizar uma pesquisa difusa para o diretório.
Embora ajude um pouco, pode dar resultados estranhos e pode ser difícil encontrar exatamente o que se pretende.

Estamos a trabalhar para melhorar as funções de pesquisa e filtragem do diretório e, se tiver sugestões de como gostaria de o pesquisar, nós [valorizamos o seu contributo](https://github.com/rladies/rladies.github.io/issues).

### Adicionar novas páginas

Há algumas páginas em que estamos ansiosos por começar a trabalhar, para podermos fornecer a melhor informação disponível à nossa comunidade e aos financiadores.
Prometemos alguns recursos na nossa [BML](https://rladies.org/news/2020-06-06-blm/) e temos plena consciência de que ainda não os cumprimos.
Além disso, sabemos que os nossos financiadores querem regularmente resumos das nossas actividades e queremos criar uma página dedicada a este tipo de informação.

Se houver páginas que ache que devam existir, [por favor, informe-nos](https://github.com/rladies/rladies.github.io/issues) e analisaremos as vossas propostas.

## Considerações finais do promotor principal

Trabalhar neste sítio Web foi uma viagem fantástica para mim.
Aprendi imenso e estou entusiasmado por finalmente o ver a funcionar.
Aguardo com expetativa o desenvolvimento contínuo e, dentro em breve, anunciaremos a necessidade de novos membros para a equipa do sítio Web, para me ajudarem nos esforços de tradução, na revitalização do blogue e na manutenção geral do novo sítio Web.

![](rladies.jpg)


