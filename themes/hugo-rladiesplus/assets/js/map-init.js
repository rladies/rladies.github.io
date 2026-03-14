document.querySelectorAll('[data-map-config]').forEach(function (el) {
  var d3map = window.__d3map;
  var configEl = document.getElementById(el.getAttribute('data-map-config'));
  if (!configEl || !d3map) {
    if (!d3map) console.error('d3map not loaded');
    return;
  }

  var config = JSON.parse(configEl.textContent);
  var mapId = config.id;
  var points = config.points;
  var countries = config.countries;
  var tooltip = config.tooltip;
  var radius = config.radius || 7;
  var initialZoom = config.zoom;

  function themeColors(dark) {
    return {
      bg: dark ? '#1a1a2e' : '#ffffff',
      countryFill: dark ? '#2a2a42' : '#cccccc',
      countryStroke: dark ? '#3a3a55' : '#ffffff',
      countryHover: dark ? '#81acf7' : '#146af9',
      highlightHover: dark ? '#d4b9f5' : '#a855f7',
      tooltipBg: dark ? '#1e1e30' : '#ffffff',
      tooltipStroke: dark ? '#3a3a55' : '#cccccc',
      tooltipLabel: dark ? '#ededf4' : '#333333',
      highlight: dark ? '#bb86f7' : '#c084fc',
      highlightOpacity: dark ? 0.5 : 0.4,
      pointFill: dark ? '#d4b9f5' : '#881ef9',
      pointStroke: dark ? '#1a1a2e' : '#ffffff',
      pointStrokeWidth: dark ? 2 : 1
    };
  }

  var container = document.getElementById(mapId);
  if (!container) return;
  container.style.position = 'relative';
  container.style.overflow = 'hidden';

  var worldData = d3map.feature(d3map.world, d3map.world.objects.countries);

  var countryMap = {};
  if (countries && countries.length > 0) {
    countries.forEach(function (c) {
      if (c.iso) {
        var numId = d3map.alpha2ToNumeric[c.iso.toUpperCase()];
        if (numId) countryMap[numId] = c;
      }
    });
  }

  var zoomNumId = null;
  if (initialZoom && initialZoom.iso) {
    zoomNumId = d3map.alpha2ToNumeric[initialZoom.iso.toUpperCase()] || null;
  }

  var W = 960, H = 500;
  var isDark = document.documentElement.classList.contains('dark');
  var colors = themeColors(isDark);

  var projection = d3map.geoEqualEarth().fitSize([W, H], { type: 'Sphere' });
  var pathGen = d3map.geoPath(projection);

  function isHighlighted(d) {
    return countryMap[d.id] || (zoomNumId && d.id === zoomNumId);
  }

  function countryFill(d, c) {
    if (isHighlighted(d)) return c.highlight;
    return c.countryFill;
  }

  function countryOpacity(d, c) {
    if (zoomNumId && d.id === zoomNumId) return 0.3;
    if (countryMap[d.id]) return c.highlightOpacity;
    return 1;
  }

  var svg = d3map.select(container)
    .append('svg')
    .attr('viewBox', '0 0 ' + W + ' ' + H)
    .attr('preserveAspectRatio', 'xMidYMid meet')
    .style('width', '100%')
    .style('height', '100%')
    .style('display', 'block')
    .style('cursor', 'grab');

  var bgRect = svg.append('rect')
    .attr('width', W)
    .attr('height', H)
    .attr('fill', colors.bg);

  var g = svg.append('g');

  var countryPaths = g.selectAll('path')
    .data(worldData.features.filter(function (f) { return f.id !== '010'; }))
    .enter()
    .append('path')
    .attr('d', pathGen)
    .attr('fill', function (d) { return countryFill(d, colors); })
    .attr('fill-opacity', function (d) { return countryOpacity(d, colors); })
    .attr('stroke', colors.countryStroke)
    .attr('stroke-width', 0.5)
    .style('cursor', 'pointer')
    .style('transition', 'fill 0.15s, fill-opacity 0.15s')
    .on('mouseenter', function (event, d) {
      if (isHighlighted(d)) {
        d3map.select(this).attr('fill', colors.highlightHover).attr('fill-opacity', 0.8);
      } else {
        d3map.select(this).attr('fill', colors.countryHover).attr('fill-opacity', 1);
      }
      var text = d.properties.name;
      if (countryMap[d.id]) {
        var c = countryMap[d.id];
        text = d.properties.name + '\n' + c.count + ' chapter' + (c.count > 1 ? 's' : '');
      }
      showTooltip(event, text);
    })
    .on('mousemove', function (event) {
      moveTooltip(event);
    })
    .on('mouseleave', function (event, d) {
      d3map.select(this)
        .attr('fill', countryFill(d, colors))
        .attr('fill-opacity', countryOpacity(d, colors));
      hideTooltip();
    });

  var pointData = (points || []).map(function (p) {
    return {
      coords: projection([p.longitude, p.latitude]),
      name: p.name,
      members: p.members
    };
  }).filter(function (p) { return p.coords; });

  var pointCircles = g.selectAll('circle')
    .data(pointData)
    .enter()
    .append('circle')
    .attr('cx', function (d) { return d.coords[0]; })
    .attr('cy', function (d) { return d.coords[1]; })
    .attr('r', radius)
    .attr('fill', colors.pointFill)
    .attr('stroke', colors.pointStroke)
    .attr('stroke-width', colors.pointStrokeWidth)
    .style('cursor', 'pointer')
    .on('mouseenter', function (event, d) {
      var text;
      if (tooltip) {
        text = tooltip.replace(/\{(\w+)\}/g, function (_, key) {
          return d[key] !== undefined ? d[key] : '';
        });
      } else {
        text = d.name;
      }
      showTooltip(event, text);
    })
    .on('mousemove', function (event) {
      moveTooltip(event);
    })
    .on('mouseleave', function () {
      hideTooltip();
    });

  var tooltipDiv = d3map.select(container)
    .append('div')
    .style('position', 'absolute')
    .style('pointer-events', 'none')
    .style('padding', '6px 10px')
    .style('border-radius', '6px')
    .style('font-size', '13px')
    .style('line-height', '1.4')
    .style('white-space', 'pre-line')
    .style('opacity', 0)
    .style('transition', 'opacity 0.15s')
    .style('z-index', 10);

  applyTooltipColors(colors);

  function applyTooltipColors(c) {
    tooltipDiv
      .style('background', c.tooltipBg)
      .style('border', '1px solid ' + c.tooltipStroke)
      .style('color', c.tooltipLabel)
      .style('box-shadow', '0 2px 8px rgba(0,0,0,0.15)');
  }

  function showTooltip(event, content) {
    tooltipDiv.html(content).style('opacity', 1);
    moveTooltip(event);
  }

  function moveTooltip(event) {
    var rect = container.getBoundingClientRect();
    var x = event.clientX - rect.left + 12;
    var y = event.clientY - rect.top - 10;
    if (x + 160 > rect.width) x = x - 170;
    if (y < 0) y = 10;
    tooltipDiv.style('left', x + 'px').style('top', y + 'px');
  }

  function hideTooltip() {
    tooltipDiv.style('opacity', 0);
  }

  var currentScale = 1;

  var zoomBehavior = d3map.zoom()
    .scaleExtent([1, 20])
    .on('start', function (event) {
      if (event.sourceEvent) svg.style('cursor', 'grabbing');
    })
    .on('zoom', function (event) {
      g.attr('transform', event.transform);
      currentScale = event.transform.k;
      g.selectAll('circle')
        .attr('r', radius / currentScale)
        .attr('stroke-width', colors.pointStrokeWidth / currentScale);
      g.selectAll('path').attr('stroke-width', 0.5 / currentScale);
    })
    .on('end', function (event) {
      if (event.sourceEvent) svg.style('cursor', 'grab');
    });

  svg.call(zoomBehavior);
  svg.on('dblclick.zoom', null);

  if (initialZoom) {
    var zoomScale = initialZoom.level || 4;
    var center = projection([initialZoom.lon, initialZoom.lat]);
    if (center) {
      var t = d3map.zoomIdentity
        .translate(W / 2 - center[0] * zoomScale, H / 2 - center[1] * zoomScale)
        .scale(zoomScale);

      svg.call(zoomBehavior.transform, d3map.zoomIdentity);
      svg.transition()
        .duration(1500)
        .call(zoomBehavior.transform, t);
    }
  }

  window.addEventListener('themechange', function (e) {
    var c = themeColors(e.detail.theme === 'dark');
    bgRect.attr('fill', c.bg);

    countryPaths
      .attr('fill', function (d) { return countryFill(d, c); })
      .attr('fill-opacity', function (d) { return countryOpacity(d, c); })
      .attr('stroke', c.countryStroke);

    pointCircles
      .attr('fill', c.pointFill)
      .attr('stroke', c.pointStroke)
      .attr('stroke-width', c.pointStrokeWidth / currentScale);

    applyTooltipColors(c);
    colors = c;
  });
});
