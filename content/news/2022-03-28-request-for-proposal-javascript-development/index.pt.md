---
language: pt
translated: no
title: Pedido de Proposta - Desenvolvimento de Javascript (Contrato de Trabalho)
author: Athanasia M. Mowinckel
type: blog
date: '2022-03-28'
slug: pedido_de_proposta_desenvolvimento_de_javascript_contrato_de_trabalho
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

**A organização global R-Ladies pretende implementar algumas novas funcionalidades (utilizando Javascript) para uma reimplementação do seu sítio Web, cujo código fonte pode ser encontrado em [GitHub](https://github.com/rladies/website).**

A R-Ladies gostaria de o convidar a preparar uma proposta para realizar a tarefa acima referida que inclua o calendário, o custo e os resultados.
O seguinte RFP inclui um historial da nossa organização e descreve o objetivo da remodelação, a funcionalidade desejada e os pedidos específicos relacionados com a proposta.
Compreendemos que os pormenores podem estar sujeitos a alterações mediante recomendação do fornecedor e/ou pesquisa de soluções mais adequadas.
Na sua proposta, sinta-se à vontade para sugerir alternativas quando indicado.

<!-mais-->

## Histórico da empresa

A R-Ladies é uma organização mundial cuja missão é promover a diversidade de género na comunidade R.

A comunidade R sofre de uma sub-representação de géneros minoritários (incluindo mas não se limitando a mulheres cis/trans, homens trans, não-binários, genderqueer, agender) em todos os papéis e áreas de participação, quer como líderes, programadores de pacotes, oradores de conferências, participantes em conferências, educadores ou utilizadores (ver estatísticas recentes).

Como uma iniciativa de diversidade, a missão do R-Ladies é alcançar uma representação proporcional, encorajando, inspirando e capacitando pessoas de géneros atualmente sub-representados na comunidade R.
O foco principal do R-Ladies é, portanto, apoiar os entusiastas do R de géneros minoritários para que atinjam o seu potencial de programação, construindo uma rede global colaborativa de líderes, mentores, alunos e programadores do R para facilitar o progresso individual e coletivo em todo o mundo.

### Gestor de projeto

[Athanasia Monika Mowinckel](https://drmowinckels.io/)

## Orçamento

Pedimos aos candidatos a empreiteiros que forneçam um orçamento preliminar para a sua proposta.
Este pode ser fornecido sob a forma de taxas horárias com uma estimativa do número de horas necessárias para concluir o projeto.
O trabalho de desenvolvimento pode ser imprevisível e compreendemos que as horas estimadas para a conclusão podem divergir um pouco das estimativas da proposta.

## Cronograma

### Prazo para apresentação de propostas

1 de maio<sup>st</sup>, 2022

### Seleção do contratante

As selecções iniciais começam imediatamente após o prazo de resposta.
Os finalistas devem ser notificados até 15 de junho e ter a oportunidade de realizar uma entrevista com o gestor do projeto para analisar a proposta.
A decisão final deve ser tomada antes do início de julho de 2022.

### Início do projeto

O mais cedo possível: 1 de julho<sup>st</sup> 2022  
Último: 1 de setembro<sup>st</sup> 2022

O gestor do projeto está indisponível em agosto, mas prevêem-se chamadas bimestrais com o gestor do projeto durante todo o período do projeto, bem como comunicação assíncrona através de correio eletrónico e GitHub.

## Data desejada para o objetivo de lançamento

O lançamento definitivo do sítio Web está previsto para 1 de janeiro<sup>st</sup> 2023 e, como tal, todos os principais problemas devem ser corrigidos até 1 de dezembro<sup>st</sup>2022\.
Uma primeira proposta de solução para as questões deve ser desenvolvida até 1 de novembro<sup>st</sup> 2022, para revisão e testes de código.

## Desafios

O novo sítio Web do R-Ladies está a ser desenvolvido utilizando [Hugo](https://gohugo.io/) um gerador de sítios Web estáticos.
O código-fonte completo e as informações de compilação podem ser encontrados em [GitHub](https://github.com/rladies/website).
O desenvolvimento dos modelos Hugo e a logística de construção são cobertos pelos programadores do R-Ladies.
Mais informações sobre a configuração do Hugo para este projeto podem ser encontradas no [repo wiki](https://github.com/rladies/website/wiki).
As partes do projeto que são implementadas em javascript, no entanto, requerem alguma atenção especializada.
Os membros da Equipa Global das R-Ladies não são programadores de Javascript e, como tal, o projeto precisa da supervisão de alguém mais especializado para garantir que está a funcionar como pretendido e implementado com boas práticas.

## Objectivos

O perito em javascript trabalhará em estreita colaboração com os programadores da R-Ladies para garantir que o comportamento desejado do sítio Web é assegurado.
A principal plataforma de desenvolvimento é o GitHub.

- **[Diretório R-Ladies](https://pensive-babbage-969fad.netlify.app/directory/)**
  
  - [Lista.js](https://listjs.com/) onde a paginação está a funcionar bem, mas [as setas não funcionam](https://github.com/rladies/website/issues/88)
  - [Outras caraterísticas pretendidas](https://github.com/rladies/website/issues/83):
    - Baralhar a lista
    - Possibilidade de alargar a ordenação/limitação da lista a, por exemplo, língua, localizações, etc.

- **[Calendário de eventos](https://pensive-babbage-969fad.netlify.app/activities/events/)**
  
  - Utilizações [Calendário da Toast UI (TUI)](https://ui.toast.com/tui-calendar)
  - [Não suportado em todos os browsers](https://github.com/rladies/website/issues/90)
  - Investigar se [os eventos podem ser apresentados na hora local do navegador](https://github.com/rladies/website/issues/86)

- **Mais geral**
  
  - Consolidar as implementações gerais de JS
  - [Principais bibliotecas javascript](https://github.com/rladies/website/tree/master/themes/hugo-rladies/static/js) utilizadas:
    - List.js
    - Momento.js
    - Tui-calendar.js
    - Bootstrap.js
    - jquery.js
  - Podem precisar de ajustes na sua implementação em termos de
    - Desempenho e robustez
    - Melhores práticas de implementação de JS
    - Limpeza geral do código

## Critérios de avaliação

O contratante deve comprovar a sua experiência e conhecimentos em matéria de:

- Desenvolvimento de javascript para sítios Web
- Utilização do GitHub para desenvolvimento colaborativo

Os seguintes elementos também contam positivamente para qualquer candidatura

- Familiaridade documentada com o Hugo
- Representação de minorias na equipa de desenvolvimento (em particular, género e etnia)
- Familiaridade com as principais bibliotecas JS utilizadas
  - List.js
  - Tui-calendário.js
  - Moment.js

## Instruções de apresentação

Se tiver dúvidas sobre a apresentação ou o próprio RFP, envie uma mensagem de correio eletrónico para \[ [rfp@rladies.org](mailto:rfp@rladies.org)\]( <mailto:rfp@rladies.org>?
subject=RFP: JS website development) com "RFP: JS website development" no campo do assunto, e o gestor de projeto responderá o mais rapidamente possível.

Todas as propostas devem conter as seguintes informações, pela ordem especificada:

**Biografia da empresa/contratante individual**

- Descrição geral da empresa e do tipo de trabalho efectuado
- Nome, morada, e-mail, telefone, sítio Web
- N.º de anos de atividade

Biografia da equipa (apenas aplicável a contratantes da empresa)\*\*

- Número de pessoas (aprox.) que trabalharão no projeto do sítio Web, respectivas funções e responsabilidades
- Dimensão da equipa, biografias, anos de experiência de cada um, função, prémios/certificações
- Quaisquer recursos adicionais necessários para apoio (por exemplo, subcontratantes)

**Referências**

- Principais clientes e quando (data) estabeleceram a parceria
- 4-6 referências de clientes
- 3-5 projectos relevantes de topo, quem trabalhou em cada projeto, ligação para o estudo de caso ou URL do sítio Web
- Em alternativa: uma ligação para um portefólio

**Proposta de projeto**

- Número de horas e calendário geral desde o início até à conclusão (aprox.)
- Possivelmente também especificado diretamente pela questão do GitHub
- Se sugerir bibliotecas js alternativas a utilizar para a funcionalidade pretendida
  - Descrição da razão pela qual a alternativa é uma melhor escolha
  - Comparação das caraterísticas entre as duas opções concorrentes
  - Estimativa do tempo necessário para a mudança de biblioteca em comparação com a procura de uma solução com a biblioteca atualmente utilizada
- Proposta do fluxo de comunicação esperado entre o gestor de projeto da R-Ladies e a equipa da empresa

**Orçamento**  
Estimativas de custos da proposta Pode ser descrito como taxas horárias e número estimado de horas necessárias

Utilize este formulário para enviar a sua proposta: <https://forms.gle/34bHsnDJppLwPstd6>


