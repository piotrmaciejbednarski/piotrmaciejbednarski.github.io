---
layout: page
lang: pl
permalink: /pl/
title: Strona główna
---

# Cześć, jestem Piotr Bednarski!

To blog nie tylko o programowaniu, ale także o moich przemyśleniach dotyczących świata.

Zawodowo działam na styku inżynierii i pracy z rozwiązaniami AI/ML. Fascynuje mnie zaglądanie pod maskę systemów, szukanie miejsc do optymalizacji i automatyzacji. Przykład? DeepSeek zrewolucjonizował stosunek kosztów do wydajności dzięki architekturze MoE – tylko 37 miliardów aktywnych parametrów przy 671 miliardach ogółem. Europejskie startupy mogłyby pójść tą drogą, ale częściej narzekają na brak dostępu do A100, zamiast przemyśleć architekturę i optymalizację swoich rozwiązań.

Jeśli masz ochotę wymienić się doświadczeniami, porozmawiać na dowolny temat lub po prostu pogadać o technologii, [napisz do mnie](mailto:kontakt@bednarskiwsieci.pl). Chętnie nawiążę kontakt zarówno z osobami początkującymi, jak i doświadczonymi specjalistami.

## Najnowsze wpisy na blogu

{% assign posts = site.posts | where: "lang", "pl" | limit: 5 %}
{% if posts.size > 0 %}
<ul>
{% for post in posts %}
  <li class="post-item">
    <a class="post-title" href="{{ post.url }}"><span>{{ post.title }}</span></a>
    <div class="post-date"><i>{{ post.date | date: site.t.pl.date_format }}</i></div>
  </li>
{% endfor %}
</ul>
{% else %}
<p>Brak wpisów na blogu w języku polskim.</p>
{% endif %}

<a href="/pl/blog/">Zobacz wszystkie wpisy →</a>

Przeczytaj także mój blog w [języku angielskim](/en/).