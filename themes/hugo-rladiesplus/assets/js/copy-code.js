(function () {
  if (!navigator.clipboard || !navigator.clipboard.writeText) return;

  document.addEventListener('click', function (e) {
    var btn = e.target.closest && e.target.closest('.copy-code-btn');
    if (!btn) return;
    var wrapper = btn.closest('.code-block');
    if (!wrapper) return;
    var code = wrapper.querySelector('code');
    if (!code) return;

    navigator.clipboard.writeText(code.innerText).then(
      function () { showToast(btn.dataset.successMsg || 'Code copied', 'success'); },
      function () { showToast(btn.dataset.errorMsg || 'Copy failed', 'error'); }
    );
  });

  function showToast(text, state) {
    var container = document.getElementById('toast-container');
    if (!container) return;
    var toast = document.createElement('div');
    toast.className = 'toast toast-' + state;
    toast.setAttribute('role', state === 'error' ? 'alert' : 'status');
    toast.textContent = text;
    container.appendChild(toast);
    requestAnimationFrame(function () {
      toast.classList.add('toast-visible');
    });
    setTimeout(function () {
      toast.classList.remove('toast-visible');
      setTimeout(function () { toast.remove(); }, 250);
    }, 2000);
  }
})();
