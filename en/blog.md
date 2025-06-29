---
title: My blog
description: A collection of my thoughts on programming, technology, and the world.
layout: page
lang: en
blog_index: true
permalink: /en/blog/
---

<ul>
    {% assign posts = site.posts | where: "lang", "en" %}
    {% for post in posts %}
    {% unless post.draft == true or post.series %}
    <li class="post-item">
        <a class="post-title" href="{{ post.url }}"><span>{{ post.title }}</span></a>
        <div class="post-date"><i>{{ post.date | date: site.t.en.date_format }}</i></div>
    </li>
    {% endunless %}
    {% endfor %}
</ul>

{% if posts.size == 0 %}
<p>No blog posts available in English.</p>
{% endif %}
