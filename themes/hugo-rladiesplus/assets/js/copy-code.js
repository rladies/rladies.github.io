document.addEventListener('DOMContentLoaded', function () {
  if (!navigator.clipboard || !navigator.clipboard.writeText) return;

  var blocks = document.querySelectorAll('.highlight');
  if (blocks.length === 0) return;

  var copyIcon = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="5" width="9" height="9" rx="1.5"/><path d="M3 11V3.5A1.5 1.5 0 0 1 4.5 2H10"/></svg>';
  var checkIcon = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 8.5l3.5 3.5L13 4.5"/></svg>';
  var errorIcon = '<svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4l8 8M12 4l-8 8"/></svg>';

  blocks.forEach(function (block) {
    var code = block.querySelector('code');
    if (!code || block.querySelector('.copy-code-btn')) return;

    block.classList.add('has-copy-btn');

    var btn = document.createElement('button');
    btn.type = 'button';
    btn.className = 'copy-code-btn';
    btn.setAttribute('aria-label', 'Copy code to clipboard');
    btn.innerHTML = '<span class="copy-code-icon">' + copyIcon + '</span><span class="copy-code-label">Copy</span>';
    block.appendChild(btn);

    btn.addEventListener('click', function () {
      navigator.clipboard.writeText(code.innerText).then(
        function () { setState(btn, 'success', checkIcon, 'Copied'); },
        function () { setState(btn, 'error', errorIcon, 'Copy failed'); }
      );
    });
  });

  function setState(btn, state, icon, label) {
    btn.dataset.state = state;
    btn.querySelector('.copy-code-icon').innerHTML = icon;
    btn.querySelector('.copy-code-label').textContent = label;
    if (btn._copyTimer) clearTimeout(btn._copyTimer);
    btn._copyTimer = setTimeout(function () {
      delete btn.dataset.state;
      btn.querySelector('.copy-code-icon').innerHTML = copyIcon;
      btn.querySelector('.copy-code-label').textContent = 'Copy';
    }, 2000);
  }
});
