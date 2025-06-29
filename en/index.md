---
layout: page
lang: en
permalink: /en/
title: Home
---

# Hello, I'm Piotr Bednarski.

This blog is not only about programming, but also about my thoughts on the world.

Professionally, I work at the intersection of engineering and AI/ML solutions. I enjoy looking under the hood of systems, searching for ways to optimize and automate. For example, DeepSeek changed the cost-to-performance ratio with its MoE architecture—only 37 billion active parameters out of a total of 671 billion. European startups could follow this path, but often complain about not having access to A100s instead of rethinking their architecture and optimizing their solutions.

If you want to share experiences, talk about any topic, or just chat about technology, [write to me](mailto:kontakt@bednarskiwsieci.pl). I am happy to connect with both beginners and experienced professionals.

## Latest blog posts

{% assign posts = site.posts | where: "lang", "en" | limit: 5 %}
{% if posts.size > 0 %}
<ul>
{% for post in posts %}
  <li class="post-item">
    <a class="post-title" href="{{ post.url }}"><span>{{ post.title }}</span></a>
    <div class="post-date"><i>{{ post.date | date: site.t.en.date_format }}</i></div>
  </li>
{% endfor %}
</ul>
{% else %}
<p>No blog posts available in English.</p>
{% endif %}

<a href="/en/blog/">See all posts →</a>

Also read my blog in [Polish](/pl/).
