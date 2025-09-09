
// DHDV UI Pack - site.js
(function(){
  const $ = sel => document.querySelector(sel);
  const menuBtn = $('#menuBtn');
  const nav = $('#navlinks');
  const themeBtn = $('#themeBtn');

  if(menuBtn){
    menuBtn.addEventListener('click', () => {
      nav.classList.toggle('open');
      menuBtn.setAttribute('aria-expanded', nav.classList.contains('open'));
    });
  }

  const applyTheme = t => {
    if(t === 'dark') document.documentElement.classList.add('dark');
    else document.documentElement.classList.remove('dark');
  };

  // init theme from storage or system
  const stored = localStorage.getItem('theme');
  if(stored) applyTheme(stored);
  if(themeBtn){
    themeBtn.addEventListener('click', () => {
      const next = document.documentElement.classList.contains('dark') ? 'light' : 'dark';
      localStorage.setItem('theme', next);
      applyTheme(next);
    });
  }

  // Tiny client-side search (placeholder)
  const q = new URLSearchParams(location.search).get('q');
  if(q && $('#q')) $('#q').value = q;

})();
