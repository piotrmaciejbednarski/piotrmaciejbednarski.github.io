{% assign lang = page.lang | default: site.default_lang %}
{% assign t = site.t[lang] %}

<div class="navbar">
  <a href="/{{ lang }}/">{{ t.nav.home }}</a>
  <a href="/{{ lang }}/blog/">{{ t.nav.blog }}</a>
  <a href="/{{ lang }}/resources/">{{ t.nav.resources }}</a>
  <a href="/{{ lang }}/favorites/">{{ t.nav.favorites }}</a>
  <a href="/{{ lang }}/mentions/">{{ t.nav.mentions }}</a>
  <a href="/feed.xml">{{ t.nav.rss }}</a>
  
  <!-- Language switcher -->
  <span>
    {% if lang == 'pl' %}
      <a href="/en{{ page.url | remove: '/pl' }}">en</a>
    {% else %}
      <a href="/pl{{ page.url | remove: '/en' }}">pl</a>
    {% endif %}
  </span>
</div>
