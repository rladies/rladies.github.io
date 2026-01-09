import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';
import momentTimezonePlugin from '@fullcalendar/moment-timezone';
import moment from 'moment';
import 'moment-timezone';
import { Tooltip } from 'bootstrap';

// Make available globally
window.FullCalendar = { Calendar };
window.FullCalendar.plugins = {
    dayGrid: dayGridPlugin,
    timeGrid: timeGridPlugin,
    list: listPlugin,
    interaction: interactionPlugin,
    momentTimezone: momentTimezonePlugin
};
window.moment = moment;
window.Tooltip = Tooltip;