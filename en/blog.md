---
title: My blog
description: Read my blog posts about AI, machine learning, software engineering, and more.
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

## I use language models

Posts on the blog are usually originally written in Polish and then translated into English (or vice versa). I use language models (Gemini 2.5 Flash) only to speed up the translation process, but also to make the text more readable (syntactically and grammatically).

People tend to make writing mistakes, and language models can help catch and correct them. This makes the texts more coherent and understandable.

There is nothing wrong with this as long as it is not used to write entire articles! If you want to read posts in Polish language, go to [my blog in Polish](/pl/blog/).

{% if posts.size == 0 %}
<p>No blog posts available in English.</p>
{% endif %}
