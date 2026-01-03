// Entry point for bundling vendor libraries with esbuild.
// Keep this file minimal: import libraries you need and export or attach
// to window if other legacy scripts expect globals.

import $ from 'jquery';
import moment from 'moment';
import 'moment-timezone';
import { Calendar } from '@fullcalendar/core';
import dayGridPlugin from '@fullcalendar/daygrid';

// attach globals for existing scripts that expect them
window.jQuery = window.$ = $;
window.moment = moment;
window.FullCalendar = { Calendar, dayGridPlugin };

// set a flag so templates can detect the bundle at runtime
window.__RLADIES_VENDOR_BUNDLE = true;
