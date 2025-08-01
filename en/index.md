---
layout: page
lang: en
permalink: /en/
title: Home
description: I started my blog to share knowledge, experience, and reflections. I write about what fascinates me, what irritates me, and what I consider important in today's world. I won’t hide that the idea to create such a place came to me after looking through the blog of Sam Altman from OpenAI, which he has been running continuously since 2013. I thought it was worth being inspired by it  —  to create something similar, but in my own style.
---

# Hello, I'm Piotr Bednarski.

This blog is not only about programming, but also about my thoughts on the world.

I started my blog to share knowledge, experience, and reflections. I write about what fascinates me, what irritates me, and what I consider important in today's world. I won’t hide that the idea to create such a place came to me after looking through the blog of [Sam Altman](https://blog.samaltman.com/) from OpenAI, which he has been running continuously since 2013. I thought it was worth being inspired by it — to create something similar, but in my own style.

I'm not an expert in any field, but I have experience in areas to which I've dedicated a lot of time and energy. My adventure with programming began when I was a teenager — I created simple browser-based arcade games, often with friends. Although they weren't very ambitious, one of them gained some popularity on [itch.io](https://itch.io/). Our amateur game studio even made it into the [directory of Polish gamedev studios](https://polskigamedev.weebly.com/lista-a-z.html), appearing on the same list as major companies like 11 bit studios or CD Projekt RED. Today, I regret deleting those projects from the platform — they were my first steps into the world of coding. Perhaps one day I'll manage to recreate them; I have gameplay recordings, so not all is lost. I plan to republish them someday.

Later, I moved on to creating tools for everyday use: applications for managing tasks, notes, or calendars. These were simple solutions, but I wrote them myself — that's when I had my first encounter with the C# language. I created them individually, without a team, and shared them on itch.io. Back then, I never thought about GitHub — I didn't realize how important it is to share code and participate in the developer community.

Before I started making games, I was very interested in electronics. I was fascinated by the stories of Steve Jobs and Steve Wozniak. I played with the [Applesoft BASIC interpreter in a browser](https://www.calormen.com/jsbasic/) — a project by [Joshua Bell](https://github.com/inexorabletash) that greatly inspired me. I spent hours learning the language, experimenting with the graphics functions in BASIC. Reading Jobs' biographies, I started to dream of creating my own programming language and my own computer.

Around that time, I became interested in Arduino and began to explore what different implementations of operating systems on AVR microcontrollers looked like. At that point, however, I didn't have enough knowledge to understand it. I didn't give up — instead, I started creating **CenterScript** (initially called PSPL), which became my first programming language.

The project was amateurish, but it brought me immense joy. Back then, I didn't yet know concepts like abstract syntax trees (AST), parsers, or compilers. Gradually, by reading various sources, I began to understand how it all worked. CenterScript was an interpreted language, designed to be simple and user-friendly. I wrote the interpreter in Node.js, and later added a "compilation" feature — today I would use LLVM, but back then I used an interesting trick: I preprocessed the code into the Dart language, which — according to my research — was easy to implement for my use case (due to its simple syntax and no need for typing). Although Dart wasn't particularly popular at the time, it seemed like a good choice to me.

The key was that after preprocessing, I could compile the Dart code into an executable file. The language itself was not well-organized — there was no concept of a standard library (stdlib), and the whole thing was implemented intuitively, through trial and error, based on my own analyses. I kept the technical documentation by hand, on paper — to this day, I have a thick stack of notes that are a valuable artifact from that time.

It was a very interesting project that I worked on for two years. I eventually gave up on it due to a lack of time. Initially, I wanted to release CenterScript as an educational language to help young people learn the basics of programming. I had already created prototypes of a visual overlay that allowed for block-based programming — in the spirit of Scratch, but based on CenterScript.

You're probably wondering why I'm writing about all this. Well, these experiences taught me things I still use today. Above all, I understood that programming is not just about writing code — it's primarily about problem-solving and creative thinking. It is these skills that have become the foundation of my development in the world of technology.

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
