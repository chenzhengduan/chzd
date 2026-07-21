(function () {
  "use strict";

  var index = null;
  var indexUrl = null;

  function resolveIndexUrl() {
    // Prefer same-origin relative path (works for http(s) deployments)
    // Detect site root depth by finding '/classical-poems/' in pathname
    var path = location.pathname.replace(/\\/g, "/");
    var pos = path.indexOf("/classical-poems/");
    var root = pos >= 0 ? path.slice(0, pos) : "";
    return root + "/search/search_index.json";
  }

  function loadIndex(cb) {
    if (index) return cb(index);
    var url = resolveIndexUrl();
    indexUrl = url;
    var x = new XMLHttpRequest();
    x.open("GET", url, true);
    x.onload = function () {
      try { index = JSON.parse(x.responseText); } catch (e) { index = { docs: [] }; }
      cb(index);
    };
    x.onerror = function () { index = { docs: [] }; cb(index); };
    x.send();
  }

  function escapeHTML(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
    });
  }

  function siteRoot() {
    var path = location.pathname.replace(/\\/g, "/");
    var pos = path.indexOf("/classical-poems/");
    return pos >= 0 ? path.slice(0, pos) : "";
  }

  function highlight(text, terms) {
    var html = escapeHTML(text);
    terms.forEach(function (t) {
      if (!t) return;
      var re = new RegExp("(" + t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&") + ")", "gi");
      html = html.replace(re, '<mark>$1</mark>');
    });
    return html;
  }

  function search(query) {
    if (!index) return [];
    var terms = (query || "").trim().split(/[\s\u3000、，。]+/).filter(Boolean);
    if (!terms.length) return [];
    var scored = [];
    index.docs.forEach(function (d) {
      if (d.location.indexOf("classical-poems") < 0) return;
      // skip the poems hub index page (guide text would pollute results)
      if (/classical-poems\/?$/.test(d.location)) return;
      var title = d.title || "";
      var text = (d.text || "").replace(/<[^>]+>/g, " ");
      var score = 0;
      terms.forEach(function (t) {
        var tl = t.toLowerCase();
        if (title.toLowerCase().indexOf(tl) >= 0) score += 100;
        if (text.toLowerCase().indexOf(tl) >= 0) score += 10;
      });
      if (score > 0) {
        var loc = d.location;
        if (loc.indexOf("/") !== 0) loc = "/" + loc;
        scored.push({ loc: loc, title: title, text: text.slice(0, 80), score: score, terms: terms });
      }
    });
    scored.sort(function (a, b) { return b.score - a.score; });
    return scored.slice(0, 30);
  }

  function buildUI() {
    if (document.querySelector(".poems-search-overlay")) return;
    var overlay = document.createElement("div");
    overlay.className = "poems-search-overlay";
    overlay.innerHTML =
      '<div class="poems-search-modal">' +
      '<div class="poems-search-bar">' +
      '<input type="search" placeholder="搜诗名、诗人、朝代、类型…" autocomplete="off" />' +
      '<button class="poems-search-close" aria-label="关闭">✕</button>' +
      '</div>' +
      '<ol class="poems-search-results"></ol>' +
      '</div>';
    document.body.appendChild(overlay);

    var input = overlay.querySelector("input");
    var results = overlay.querySelector(".poems-search-results");
    var closeBtn = overlay.querySelector(".poems-search-close");

    function close() { overlay.classList.remove("is-open"); input.value = ""; results.innerHTML = ""; }
    function open() { overlay.classList.add("is-open"); setTimeout(function () { input.focus(); }, 30); }

    overlay.addEventListener("click", function (e) { if (e.target === overlay) close(); });
    closeBtn.addEventListener("click", close);
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
    });

    var debounce = null;
    input.addEventListener("input", function () {
      clearTimeout(debounce);
      debounce = setTimeout(function () {
        var q = input.value;
        if (!q.trim()) { results.innerHTML = ""; return; }
        loadIndex(function () {
          var hits = search(q);
          if (!hits.length) {
            results.innerHTML = '<li class="poems-search-empty">没有匹配的结果</li>';
            return;
          }
          results.innerHTML = hits.map(function (h) {
            var href = h.loc;
            if (href.charAt(0) === "/") href = href.slice(1);
            var fullHref = siteRoot() + "/" + href;
            return '<li><a href="' + fullHref + '">' +
              '<strong>' + highlight(h.title, h.terms) + '</strong>' +
              '<span>' + highlight(h.text, h.terms) + '</span>' +
              '</a></li>';
          }).join("");
        });
      }, 120);
    });

    // expose open
    document.querySelectorAll(".poems-topbar__search").forEach(function (el) {
      el.style.cursor = "pointer";
      el.addEventListener("click", open);
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", buildUI);
  } else {
    buildUI();
  }
})();