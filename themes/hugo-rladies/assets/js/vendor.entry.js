// assets/js/vendor.entry.js
// Entry file for bundling vendor JS with esbuild.
// This file lives in `assets/` so Hugo users who don't run npm still see it in the repo.

// If you want to bundle from npm packages, ensure they've been installed in the theme folder
// (themes/hugo-rladies) with `npm install`.

import $ from 'jquery';
import moment from 'moment';
import 'moment-timezone';
import FullCalendar from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import listPlugin from '@fullcalendar/list';
import interactionPlugin from '@fullcalendar/interaction';
import * as bootstrap from 'bootstrap';
import '@popperjs/core';
import 'bootstrap-multiselect';
import Shuffle from 'shufflejs';

// Expose expected globals for existing non-module code
window.jQuery = window.$ = $;
window.moment = moment;
if (moment && moment.tz) window.moment.tz = moment.tz;
window.FullCalendar = FullCalendar;
// expose useful FullCalendar plugin constructors
window.FullCalendarPlugins = {
    dayGrid: dayGridPlugin,
    timeGrid: timeGridPlugin,
    list: listPlugin,
    interaction: interactionPlugin,
};

// Bootstrap and Popper are reachable via imports above; expose bootstrap on window for legacy code
// Expose bootstrap API on window so legacy code can call e.g. new bootstrap.Tooltip(...)
window.bootstrap = window.bootstrap || bootstrap;

// expose multiselect plugin if available (bootstrap-multiselect attaches to jQuery.fn)
if (window.jQuery && window.jQuery.fn && window.jQuery.fn.multiselect) {
    window.bootstrapMultiselect = window.jQuery.fn.multiselect;
}

// expose Shuffle
window.Shuffle = Shuffle;

// Optional flag to indicate the bundle loaded
window.__RLADIES_VENDOR_BUNDLE = true;
