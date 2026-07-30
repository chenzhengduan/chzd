(function(){
  var themeToggle = document.getElementById('themeToggle');
  if(themeToggle){
    themeToggle.addEventListener('click', function(){
      var isDark = document.documentElement.classList.toggle('dark');
      localStorage.setItem('theme', isDark ? 'dark' : 'light');
    });
  }

  var sidebar = document.getElementById('bookSidebar');
  var overlay = document.getElementById('sidebarOverlay');
  var menuToggle = document.getElementById('menuToggle');
  var sidebarClose = document.getElementById('sidebarClose');
  function openSidebar(){ if(sidebar) sidebar.classList.add('open'); if(overlay) overlay.classList.add('open'); }
  function closeSidebar(){ if(sidebar) sidebar.classList.remove('open'); if(overlay) overlay.classList.remove('open'); }
  if(menuToggle) menuToggle.addEventListener('click', openSidebar);
  if(sidebarClose) sidebarClose.addEventListener('click', closeSidebar);
  if(overlay) overlay.addEventListener('click', closeSidebar);
})();
