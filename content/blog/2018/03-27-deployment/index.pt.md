---
language: pt
translated: no
title: 2. Nos bastidores da ação do Twitter do R-Ladies IWD2018!
author: R-Ladies
date: '2018-03-27'
description: 'Parte 2: Implantação e manipulação de bots!'
slug: 2_nos_bastidores_da_ação_do_twitter_do_r_ladies_iwd_2018
tags:
- iwd
- part2
- twitter
- 2018
categories:
- IWD
- R-Ladies
---

### Segundo Kelly O'Briant

No dia 8 de março, Dia Internacional da Mulher, publicámos um feed contínuo de perfis fantásticos de R-Ladies de [nosso diretório](http://rladies.org/directory/) via [@rladies\_iwd2018](https://twitter.com/rladies_iwd2018).
Foi um espetáculo!
E muito trabalho de equipa também!
Nesta publicação do blogue, vamos abordar as fases de implementação e monitorização do nosso projeto.
Também pode ler a [Parte 1](/post/ideation_and_creation/).

## Recapitulação

A melhor parte de ser encarregado da implementação de um projeto é que todo o trabalho árduo já está praticamente feito!
Nesta secção, vou descrever como implementámos e monitorizámos a nossa aplicação do Twitter para o IWD 2018.
As coisas não acabaram por correr exatamente como planeado, mas foram aprendidas lições e conseguimos ajustar o nosso plano de jogo em tempo real, fazendo alguns pequenos compromissos.

Para rever, eis o ponto em que o projeto se encontrava quando chegou a altura de eu entrar no projeto:

*Todo o trabalho árduo já estava feito!*

- Criar uma conta no Twitter e uma aplicação de programador
- Preparar as capturas de ecrã
- Preparar os tweets

*Qual era o meu trabalho:*

- Lançar uma imagem docker/rocker
- Fazer alguns testes
- Começar a enviar tweets no IWD2018
- Cruzar os dedos para o sucesso :)

*O que provavelmente também deveria ter feito:*

- Implementei a aplicação Docker do twitter numa instância na nuvem (para o caso de uma falha de energia aqui em casa)
- Determinámos se teríamos problemas por adicionar identificadores do twitter aos tweets dos bots

## O trabalho

### Iniciar o Docker

*Porquê utilizar o Docker?*

Eu sabia que precisaríamos de estar a twittar durante cerca de 48 horas (a seguir ao 8 de março em todo o mundo) e nunca iria querer ocupar a minha sessão local de R durante dois dias inteiros.
Uma solução simples para este problema é lançar uma instância local do Docker com o R e o RStudio instalados.

*Recursos do Docker*

Comecei a aprender a usar o docker há alguns meses, seguindo [este incrível tutorial de docker/rocker do rOpenSciLabs](http://ropenscilabs.github.io/r-docker-tutorial/).
Recomendo-o vivamente.
Ligar um volume local (sistema de ficheiros) a uma instância docker é super simples e foi basicamente tudo o que precisei de fazer para pôr este projeto a funcionar.

Clonei o repositório do GitHub que usamos para todo o nosso código e dados, vinculei esse volume à instância do docker e iniciei alguns testes no Twitter!

### Enviando os tweets

O meu instinto inicial foi tentar executar o código de tweeting como um script agendado no cron. [O que é cron?](http://www.unixgeeks.org/security/newbie/unix/cron-1.html) Planeei configurar o crontab com [modificando o ficheiro Docker](https://www.ekito.fr/people/run-a-cron-job-with-docker/) para o Rocker.

Mas, mantendo o tema "o simples vence", acabei por utilizar apenas um ciclo for e `Sys.sleep()`.
Eu estava paranoico sobre nossa conta ser marcada como um bot malicioso pelo pessoal do twitter, então achei que ajudaria adicionar alguns "extra\_seconds" a cada ciclo de sono.
Desta forma, não estaríamos a tweetar a cada seis minutos em ponto.
Não faço ideia se isto nos ajudou ou não... ainda fomos bloqueados algumas vezes.

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

### Monitorização e correção da nossa aplicação

A aplicação `tweet_lady` está configurada para retornar `try_tweet`.
No caso de uma falha de tweeting, foi muito útil poder executar rapidamente esta função fora do loop for para ver o tipo de erro.
Nossa aplicação caiu várias vezes (4?) durante nossa tempestade de 48 horas no twitter #IWD, e então eu executei este pequeno pedaço de código muitas vezes enquanto testava e restaurava nossa aplicação:

```r
err <- tweet_lady(tweets[id,]$entry_id, tweets[id,]$tweet, token)
```

As mensagens de erro nem sempre eram muito úteis, mas fazia-me sentir melhor ao vê-las.
Logs são reconfortantes, sabe?
A nossa primeira aplicação foi bloqueada após três horas de tweets, e adivinhámos que o encerramento se devia, em parte, à utilização dos nomes de twitter das senhoras no corpo das mensagens dos tweets.
Teria sido bom continuar a marcar as pessoas nos tweets, mas decidimos remover os identificadores para que a nossa aplicação voltasse a funcionar (e continuasse a funcionar).

A minha maravilhosa amiga R-Ladies, [Hannah Frick](https://twitter.com/hfcfrick) falou-me no Slack e encorajou-nos a apostar na gamificação da marcação manual de identificadores do Twitter.
Isto acabou por ser muito divertido.
Passei*muito*Passei muito tempo a ver o feed e as pessoas estavam sempre a marcar as pessoas antes de eu ter oportunidade!
Estou muito contente com o resultado desta parte - obrigada, Hannah!
E obrigada a todos os que passaram o tempo a marcar pessoas e a escrever mensagens pessoais!

Todos os outros erros que tivemos foram resolvidos trocando os bots da aplicação (tínhamos três), regenerando um token ou uma combinação destas coisas.

### Conclusão da implantação

O Twitter e o funcionamento dos bots do Twitter ainda são um mistério para mim.
É uma arte, uma ciência?
Não faço a mínima ideia.
Ainda bem que este foi um projeto do Dia Internacional da Mulher e não durou uma semana ou um mês!
Dito isto, acho que vou levar comigo, durante muito tempo, a sensação de me envolver com esta maravilhosa e fantástica comunidade #rladies #rstats.
Foi espetacular!
Estou muito contente e grata por esta oportunidade.
Um brinde para conhecer mais R-Ladies fantásticas em 2018!

## A seguir: Parte 3

Continuar lendo Parte 3: [A grande conclusão](/post/conclusion/)!


