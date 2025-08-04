  document.addEventListener("DOMContentLoaded", function () {
    var timeZoneSelectorEl = document.getElementById("time-zone-selector");
    timeZone = document.getElementById("time-zone-selector").value;
    var loadingEl = document.getElementById("loading");
    var calendarEl = document.getElementById("calendar");
	var events = {{ $.Site.Data.meetup.events }}
	var timezone_list = {{ $.Site.Data.timezones }}

	timezone_list.forEach(function(timeZone) {
      var optionEl;

      if (timeZone !== 'UTC') { // UTC is already in the list
        optionEl = document.createElement('option');
        optionEl.value = timeZone;
        optionEl.innerText = timeZone;
        timeZoneSelectorEl.appendChild(optionEl);
      }
    });
      function getRladiesEvents(data) {
        let updatedTime = [];
        $.each(data, function (k, v) {
          v.start = moment.tz(v.start, timeZone).format();
          v.end = moment.tz(v.end, timeZone).format();
          updatedTime[k] = v;
        });
        return updatedTime;
      }

    var calendar = new FullCalendar.Calendar(calendarEl, {
  	themeSystem: 'bootstrap',
  	schedulerLicenseKey: 'CC-Attribution-NonCommercial-NoDerivatives',
	  headerToolbar: {
        left: "prev,next",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay,listWeek",
      },
      initialDate: moment().format("YYYY-MM-DD"),
      titleFormat: {
        // will produce something like "Tuesday, September 18, 2018"
        month: "long",
        year: "numeric",
        day: "numeric",
      },
      initialView: "listWeek",
      height: "auto",
      dayMaxEvents: true, // allow "more" link when too many events

      eventDidMount: function (info) {
        var tooltip = new Tooltip(info.el, {
          title: info.event.extendedProps.body,
          placement: "bottom",
          trigger: "hover",
          container: "article",
          html: true
        });
      },

      events: getRladiesEvents(events),
      timeZone: timeZone,

      loading: function (bool) {
        if (bool) {
          loadingEl.style.display = "inline"; // show
        } else {
          loadingEl.style.display = "none"; // hide
        }
      },
	  
	  eventTimeFormat: { hour: '2-digit', minute: '2-digit', hour12: false}
    });

    calendar.render();

    // when the timezone selector changes, dynamically change the calendar option
    timeZoneSelectorEl.addEventListener("change", function () {
      timeZone = document.getElementById("time-zone-selector").value;

      var eventSource = [];
      eventSource = calendar.getEventSources();
      $.each(eventSource, function (key, value) {
        value.remove();
      });
      calendar.addEventSource(getRladiesEvents(events));
      calendar.refetchEvents();
    });
  });

  var x = document.getElementById("time-zone-selector");
  var option = document.createElement("option");
  option.id = "local";
  option.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
  option.innerText = "Local Time Zone";
  x.add(option, x[0]);
  document.getElementById("local").selected = true;
  
  // add the responsive classes after page initialization
  window.onload = function () {
      $('.fc-toolbar.fc-header-toolbar').addClass('row col-xlg-12');
      $('.fc-toolbar-title').addClass('entry-title');
  };
  