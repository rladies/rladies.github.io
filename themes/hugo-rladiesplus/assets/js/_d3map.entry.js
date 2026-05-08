import { geoEqualEarth, geoPath, geoCentroid } from 'd3-geo';
import { select } from 'd3-selection';
import { zoom, zoomIdentity } from 'd3-zoom';
import 'd3-transition';
import { feature } from 'topojson-client';
import world from 'world-atlas/countries-110m.json';
import iso from 'iso-3166-1';

var alpha2ToNumeric = {};
iso.all().forEach(function (entry) {
  alpha2ToNumeric[entry.alpha2] = entry.numeric;
});

window.__d3map = {
  geoEqualEarth,
  geoPath,
  geoCentroid,
  select,
  zoom,
  zoomIdentity,
  feature,
  world,
  alpha2ToNumeric
};
