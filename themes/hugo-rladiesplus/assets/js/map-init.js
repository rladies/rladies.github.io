document.querySelectorAll('[data-map-config]').forEach(function (el) {
  var configEl = document.getElementById(el.getAttribute('data-map-config'));
  if (!configEl || typeof am5 === 'undefined') {
    if (typeof am5 === 'undefined') console.error('am5 not loaded');
    return;
  }

  var config = JSON.parse(configEl.textContent);
  var mapId = config.id;
  var points = config.points;
  var countries = config.countries;
  var tooltip = config.tooltip;
  var radius = config.radius || 7;
  var zoom = config.zoom;

  am5.ready(function () {
    var isDark = document.documentElement.classList.contains('dark');
    var root = am5.Root.new(mapId);

    root.setThemes([am5themes_Animated.new(root)]);

    root.container.set("background", am5.Rectangle.new(root, {
      fill: am5.color(isDark ? 0x1a1a2e : 0xffffff),
      fillOpacity: 1
    }));

    var chart = root.container.children.push(
      am5map.MapChart.new(root, {
        projection: am5map.geoEqualEarth()
      })
    );

    var bgSeries = chart.series.push(
      am5map.MapPolygonSeries.new(root, {
        geoJSON: { type: "Sphere" }
      })
    );
    bgSeries.mapPolygons.template.setAll({
      fill: am5.color(isDark ? 0x1a1a2e : 0xffffff),
      stroke: am5.color(isDark ? 0x1a1a2e : 0xffffff),
      strokeWidth: 0
    });

    var polygonSeries = chart.series.push(
      am5map.MapPolygonSeries.new(root, {
        geoJSON: am5geodata_worldLow
      })
    );

    polygonSeries.mapPolygons.template.setAll({
      tooltipText: "{name}",
      fill: am5.color(isDark ? 0x2a2a42 : 0xcccccc),
      stroke: am5.color(isDark ? 0x3a3a55 : 0xffffff),
      strokeWidth: 0.5
    });

    polygonSeries.mapPolygons.template.states.create("hover", {
      fill: am5.color(isDark ? 0x81acf7 : 0x146af9),
      fillOpacity: 1
    });

    var am5Tooltip = am5.Tooltip.new(root, {
      getFillFromSprite: false,
      getLabelFillFromSprite: false
    });
    am5Tooltip.get("background").setAll({
      fill: am5.color(isDark ? 0x1e1e30 : 0xffffff),
      stroke: am5.color(isDark ? 0x3a3a55 : 0xcccccc),
      strokeWidth: 1
    });
    am5Tooltip.label.setAll({
      fill: am5.color(isDark ? 0xededf4 : 0x333333)
    });

    if (countries && countries.length > 0) {
      var countryMap = {};
      countries.forEach(function (country) {
        var isoCode = country.iso;
        if (isoCode && isoCode !== null) {
          countryMap[isoCode.toUpperCase()] = country.count;
        }
      });

      polygonSeries.events.on("datavalidated", function () {
        polygonSeries.mapPolygons.each(function (polygon) {
          var id = polygon.dataItem.get("id");
          if (countryMap[id]) {
            polygon.setAll({
              fill: am5.color(isDark ? 0xbb86f7 : 0x881ef9),
              fillOpacity: isDark ? 0.5 : 0.4,
              tooltipText: "{name}\n" + countryMap[id] + " chapter" + (countryMap[id] > 1 ? "s" : "")
            });
          }
        });
      });
    }

    var pointSeries = chart.series.push(
      am5map.MapPointSeries.new(root, {})
    );

    pointSeries.bullets.push(function () {
      var circleOpts = {
        radius: radius,
        fill: am5.color(isDark ? 0xd4b9f5 : 0x881ef9),
        stroke: am5.color(isDark ? 0x1a1a2e : 0xffffff),
        strokeWidth: isDark ? 2 : 1,
        cursorOverStyle: "pointer"
      };
      if (tooltip) {
        circleOpts.tooltipHTML = tooltip;
      } else {
        circleOpts.tooltipText = "{name}";
      }
      var circle = am5.Circle.new(root, circleOpts);
      circle.set("tooltip", am5Tooltip);
      return am5.Bullet.new(root, { sprite: circle });
    });

    var pointsData = points.map(function (point) {
      return {
        geometry: {
          type: "Point",
          coordinates: [point.longitude, point.latitude]
        },
        name: point.name,
        members: point.members
      };
    });

    pointSeries.data.setAll(pointsData);

    if (zoom) {
      if (zoom.iso) {
        polygonSeries.events.on("datavalidated", function () {
          var country = polygonSeries.getDataItemById(zoom.iso);
          if (country) {
            country.get("mapPolygon").setAll({
              fill: am5.color(isDark ? 0xbb86f7 : 0x881ef9),
              fillOpacity: 0.3
            });
          }
        });
      }

      setTimeout(function () {
        chart.animate({ key: "rotationX", to: -zoom.lon, duration: 1500, easing: am5.ease.out(am5.ease.cubic) });
        chart.animate({ key: "rotationY", to: -zoom.lat, duration: 1500, easing: am5.ease.out(am5.ease.cubic) });
        chart.animate({ key: "zoomLevel", to: zoom.level || 4, duration: 1500, easing: am5.ease.out(am5.ease.cubic) });
      }, 100);
    }
  });
});
