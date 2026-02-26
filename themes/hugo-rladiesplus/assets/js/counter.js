(function () {
  var elements = document.querySelectorAll('.count');
  if (elements.length === 0) return;

  var observer = new IntersectionObserver(function (entries) {
    entries.forEach(function (entry) {
      if (!entry.isIntersecting) return;
      var el = entry.target;
      observer.unobserve(el);

      var countTo = parseInt(el.getAttribute('data-count'), 10);
      var startTime = null;
      var duration = 1000;

      function step(timestamp) {
        if (!startTime) startTime = timestamp;
        var progress = Math.min((timestamp - startTime) / duration, 1);
        el.textContent = Math.floor(countTo * progress);
        if (progress < 1) {
          requestAnimationFrame(step);
        } else {
          el.textContent = countTo;
        }
      }

      requestAnimationFrame(step);
    });
  }, { threshold: 0.1 });

  elements.forEach(function (el) { observer.observe(el); });
})();
