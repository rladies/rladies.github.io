---
title: "Events"
---


<div class="code-html">
  <div id="menu">
    <span id="menu-navi">
      <button type="button" class="btn bttn-no-outline action-button move-day" data-action="move-today">Today</button>
      <button type="button" class="btn bttn-no-outline action-button move-day" data-action="move-prev">
        <i class="fa fa-chevron-left"></i>
      </button>
      <button type="button" class="btn bttn-no-outline action-button move-day" data-action="move-next">
        <i class="fa fa-chevron-right"></i>
      </button>
    </span>
    <span id="renderRange" class="render-range"></span>
  </div>
  <br>
  <div id="calendar" style='width:100%; height:600px;'></div>
</div>


<script type="application/json" data-for="calendar">
{"x":
  {
  "options": {
    "calendars":[
      {
        "name":"rladies-barcelona",
        "id":"rladies-barcelona",
        "color":"#a7a9ac",
        "bgColor":"#88398a"
      }
    ],
    "schedules": [
      {
        "category":"time",
        "dueDateClass":"",
        "id":137030,
        "calendarId":"rladies-barcelona","title":"¡Primer evento de R-Ladies Barcelona!","body":"<i class='fa fa-users'><\/i>&emsp;18<br><br><p>Estamos preparando el primer encuentro de #RLadiesBCN! Resérvate para el 21 de noviembre!<\/p> <p>Regístrate <a href=\"https://www.eventbrite.es/e/entradas-primer-evento-de-r-ladies-barcelona-28790330654\">aquí<\/a> para conseguir tu invitación en Eventbrite. Todavía estamos definiendo el lugar, pero...  <br><br> <a href='https://www.meetup.com/rladies-barcelona/events/235064329/' target='_blank'><button class='button'>Event page<\/button><\/a>",
        "start":"2020-12-10 19:00:00",
        "location":"Not announced",
        "type":"past",
        "lat":null,
        "lon":null
      }
      ]
    }
  }
}
</script> 

