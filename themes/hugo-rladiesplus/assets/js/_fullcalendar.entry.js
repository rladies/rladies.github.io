import { Calendar, createPlugin } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';

function makeFormatter(timeZone) {
    return new Intl.DateTimeFormat('en-US', {
        timeZone: timeZone,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
    });
}

function partsToArray(parts) {
    var map = {};
    parts.forEach(function (p) { map[p.type] = parseInt(p.value, 10); });
    return [
        map.year,
        map.month - 1,
        map.day,
        map.hour === 24 ? 0 : map.hour,
        map.minute,
        map.second,
        0
    ];
}

class IntlTimeZoneImpl {
    constructor(timeZoneName) {
        this.timeZoneName = timeZoneName;
        this.formatter = makeFormatter(timeZoneName);
    }

    offsetForArray(a) {
        var utcMs = Date.UTC(a[0], a[1], a[2], a[3] || 0, a[4] || 0, a[5] || 0, a[6] || 0);
        var localParts = partsToArray(this.formatter.formatToParts(new Date(utcMs)));
        var localMs = Date.UTC(localParts[0], localParts[1], localParts[2], localParts[3], localParts[4], localParts[5]);
        return (localMs - utcMs) / 60000;
    }

    timestampToArray(ms) {
        return partsToArray(this.formatter.formatToParts(new Date(ms)));
    }
}

var intlTimezonePlugin = createPlugin({
    name: 'intl-timezone',
    namedTimeZonedImpl: IntlTimeZoneImpl
});

window.FullCalendar = { Calendar };
window.FullCalendar.plugins = {
    dayGrid: dayGridPlugin,
    timeGrid: timeGridPlugin,
    list: listPlugin,
    interaction: interactionPlugin,
    intlTimezone: intlTimezonePlugin
};
