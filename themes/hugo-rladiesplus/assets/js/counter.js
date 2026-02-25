function counter() {
  var elements = document.querySelectorAll('.count');
  if (elements.length === 0) return;

  var firstEl = elements[0];
  var oTop = firstEl.getBoundingClientRect().top + window.scrollY - window.innerHeight;

  if (window.scrollY > oTop) {
    elements.forEach(function(el) {
      if (el.dataset.animated) return;
      el.dataset.animated = 'true';

      var countTo = parseInt(el.getAttribute('data-count'), 10);
      var start = parseInt(el.textContent, 10) || 0;
      var startTime = null;
      var duration = 1000;

      function step(timestamp) {
        if (!startTime) startTime = timestamp;
        var progress = Math.min((timestamp - startTime) / duration, 1);
        el.textContent = Math.floor(start + (countTo - start) * progress);
        if (progress < 1) {
          requestAnimationFrame(step);
        } else {
          el.textContent = countTo;
        }
      }

      requestAnimationFrame(step);
    });
  }
}

window.addEventListener('scroll', counter);
