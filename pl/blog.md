---
title: Mój blog
layout: page
description: Przeczytaj moje wpisy na blogu o AI, uczeniu maszynowym, inżynierii oprogramowania i nie tylko.
lang: pl
blog_index: true
sitemap: false
no_index: true
permalink: /pl/blog/
---

<ul>
    {% assign posts = site.posts | where: "lang", "pl" %}
    {% for post in posts %}
    {% unless post.draft == true or post.series %}
    <li class="post-item">
        <a class="post-title" href="{{ post.url }}"><span>{{ post.title }}</span></a>
        <div class="post-date"><i>{{ post.date | date: site.t.pl.date_format }}</i></div>
    </li>
    {% endunless %}
    {% endfor %}
</ul>

## Wykorzystuje modele językowe

Wpisy na blogu są oryginalnie pisane najczęściej w języku polskim, później tłumaczone na język angielski (lub odwrotnie). Stosuję modele językowe (Gemini 2.5 Flash) tylko, by przyśpieszyć proces tłumaczenia, ale również by tekst się lepiej czytało (składniowo i gramatycznie).

Ludzie mają skłonność do błędów w pisaniu, a modele językowe mogą pomóc w ich wychwytywaniu i poprawianiu. Dzięki nim teksty są bardziej spójne i zrozumiałe.

Nie ma w tym nic złego, dopóki nie jest to wykorzystywane do pisania całych artykułów! Jeśli chcesz przeczytać wpisy w języku angielskim, przejdź do [mojego bloga w języku angielskim](/en/blog/).

{% if posts.size == 0 %}
<p>Brak wpisów na blogu w języku polskim.</p>
{% endif %}
