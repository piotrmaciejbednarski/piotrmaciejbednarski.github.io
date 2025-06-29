---
title: Mój blog
layout: page
lang: pl
blog_index: true
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

{% if posts.size == 0 %}
<p>Brak wpisów na blogu w języku polskim.</p>
{% endif %}
