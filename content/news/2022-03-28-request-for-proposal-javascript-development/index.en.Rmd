---
title: Request for Proposal - Javascript Development (Contract Work)
author: Athanasia M. Mowinckel
date: '2022-03-28'
slug: []
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

**The R-Ladies global organization wants to implement some new functionalities (using Javascript) for a re-implementation of their  website, whose source code may be found on [GitHub](https://github.com/rladies/website).**

R-Ladies would like to invite you to prepare a proposal to accomplish the above task that includes timeline, cost, and deliverables. The following RFP includes a background of our organization and describes the purpose of the redesign, its desired functionality, and specific requests relating to the proposal. We understand that details may be subject to change upon vendor recommendation and/ or research of more optimal solutions. In your proposal, please feel free to suggest alternatives where noted.


<!--more-->


## Company Background
R-Ladies, is a worldwide organisation whose mission is to promote gender diversity in the R community. 

The R community suffers from an underrepresentation of minority genders (including but not limited to cis/trans women, trans men, non-binary, genderqueer, agender) in every role and area of participation, whether as leaders, package developers, conference speakers, conference participants, educators, or users (see recent stats).

As a diversity initiative, the mission of R-Ladies is to achieve proportionate representation by encouraging, inspiring, and empowering people of genders currently underrepresented in the R community. R-Ladies’ primary focus, therefore, is on supporting minority gender R enthusiasts to achieve their programming potential, by building a collaborative global network of R leaders, mentors, learners, and developers to facilitate individual and collective progress worldwide.


### Project Manager
[Athanasia Monika Mowinckel](https://drmowinckels.io/)


## Budget
We ask prospective contractors to provide a preliminary budget for their proposal. This can be provided as hourly rates with estimated amounts of hours to complete the project. Development work can be unpredictable, and we understand that estimated hours to completion might diverge somewhat from proposal estimates. 

## Timeline

### Proposal Deadline
May 1<sup>st</sup>, 2022

### Contractor Selection
Initial selections start immediately after the response deadline. Finalists should be notified by June 15th and given the opportunity for an interview with the project manager to go through the proposal.
Final decision should be made before the start of July 2022.

### Project Kickoff
Earliest: July 1<sup>st</sup> 2022  
Latest: September 1<sup>st</sup> 2022  

The project manager is unavailable in August, but bi-monthly calls with the project manager are expected for the duration of the project period, as well as asynchronous communication through email and GitHub.

## Desired Launch Goal Date
The final launch of the website is scheduled for January 1<sup>st</sup> 2023, and as such all major issues should be fixed by December 1<sup>st</sup> 2022. A first proposed solution for the issues should be developed by November 1<sup>st</sup> 2022, for code review and tests.

## Challenges
The new R-Ladies website is being developed using [Hugo](https://gohugo.io/), a static website generator. The entire source code and build information can be found on [GitHub](https://github.com/rladies/website). The development of the Hugo templates and build logistics are covered by the R-Ladies developers. More information about the Hugo setup for this project can be found in the [repo wiki](https://github.com/rladies/website/wiki). 
The parts of the project that are implemented in javascript, however, require some expert attention. Members of the R-Ladies Global Team are not Javascript developers, and as such the project needs oversight from someone more expert to make sure it is functioning as intended and implemented with good practices. 

## Goals
The javascript expert will work closely with the R-Ladies developers to ensure that wanted website behavior is ensured. The main platform for development is through GitHub.

- **[R-Ladies directory](https://pensive-babbage-969fad.netlify.app/directory/)**
  - [List.js](https://listjs.com/), where pagination is working fine, but [arrows do not](https://github.com/rladies/website/issues/88)   
  - [Other wanted features](https://github.com/rladies/website/issues/83):  
    - Shuffling the list  
    - Possibility to extend list sorting/limiting to for instance language, locations etc.  

- **[Events calendar](https://pensive-babbage-969fad.netlify.app/activities/events/)**  
  - Uses [Toast UI (TUI) calendar](https://ui.toast.com/tui-calendar)  
  - [Not supported in all browsers](https://github.com/rladies/website/issues/90)   
  - Investigate if [events can be displayed in browser local time](https://github.com/rladies/website/issues/86)   

- **More general**  
  - Consolidate the general JS implementations  
  - [Main javascript libraries](https://github.com/rladies/website/tree/master/themes/hugo-rladies/static/js) used:  
    - List.js  
    - Moment.js  
    - Tui-calendar.js  
    - Bootstrap.js  
    - jquery.js  
  - Might need adjustments in their implementation in terms of  
    - Performance and robustness  
    - Best practises for implementing JS  
    - General code tidiness    

## Evaluation criteria
The contractor must document experience and knowledge of:
- Development of javascript for websites  
- Use of GitHub for collaborative development    

The following will also count positively to any application  
- Documented familiarity with Hugo  
- Minority representation on the development team   (particularly gender and ethnicity)  
- Familiarity with the the main JS libraries used  
    - List.js  
    - Tui-calendar.js  
    - Moment.js  


## Submission Instructions

If you have questions regarding the submission or RFP itself, please send an email to [rfp@rladies.org](mailto:rfp@rladies.org?subject=RFP: JS website development) with “RFP: JS website development” in the subject field, and the project manager will respond at their earliest convenience.

All proposals should contain the following information, in the order specified:

**Company/Single contractor bio**  
- General description of the company and type of work you do  
- Name, address, email, phone, website  
- No. of years in operation  

Team bio (only applicable to company contractors)**  
- No. of individuals (approx.) that will work on the website project, their roles & responsibilities  
- Team size, bios, years of experience for each, their role, awards/ certifications  
- Any additional resources required for support (ex: sub-contractors)  

**References**  
- Top clients and when (date) they partnered  
- 4-6 client references  
- 3-5 top relevant projects, who worked on each project, link to case study or website URL  
- Alternatively: a link to a portfolio  

**Project proposal**  
- No. of hours and general timeline from start to completion (approx.)
- Possibly also specified by GitHub issue directly
- If suggesting alternative js libraries to use for the functionality wanted
  - Description of why the alternative is a better choice
  - Comparison of features between the two competing choices
  - Estimate of how much time the switch of library will take compared to finding a solution with the currently used one
- Proposal of expected communication flow between R-Ladies project manager and company team

**Budget**  
Proposal cost estimates
This could be described as hourly rates and estimated number of hours needed

Please, use this form to send your proposal: [https://forms.gle/34bHsnDJppLwPstd6](https://forms.gle/34bHsnDJppLwPstd6)  
