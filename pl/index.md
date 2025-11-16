---
layout: page
lang: pl
permalink: /pl/
sitemap: false
no_index: true
title: Strona główna
description: Uruchomiłem swój blog, by dzielić się wiedzą, doświadczeniem i refleksjami. Piszę o tym, co mnie fascynuje, co budzi irytację, a także o tym, co uważam za ważne w dzisiejszym świecie. Nie ukrywam, że pomysł stworzenia takiego miejsca pojawił się w mojej głowie po przejrzeniu bloga Sam Altmana z OpenAI, który nieprzerwanie prowadzi go od 2013 roku. Pomyślałem, że warto się tym zainspirować — stworzyć coś podobnego, ale w moim własnym stylu.
---

# Cześć, jestem Piotr Bednarski!

**AI Engineer @ [Useme](https://useme.com) (R&D). Tworzę ciekawe rzeczy w wolnym czasie 🚀**

To blog nie tylko o programowaniu, ale także o moich przemyśleniach dotyczących świata.

Uruchomiłem swój blog, by dzielić się wiedzą, doświadczeniem i refleksjami. Piszę o tym, co mnie fascynuje, co budzi irytację, a także o tym, co uważam za ważne w dzisiejszym świecie. Nie ukrywam, że pomysł stworzenia takiego miejsca pojawił się w mojej głowie po przejrzeniu bloga [Sam Altmana](https://blog.samaltman.com/) z OpenAI, który nieprzerwanie prowadzi go od 2013 roku. Pomyślałem, że warto się tym zainspirować — stworzyć coś podobnego, ale w moim własnym stylu.

Nie jestem ekspertem w żadnej dziedzinie, ale mam doświadczenie w obszarach, którym poświęciłem sporo czasu i energii. Moja przygoda z programowaniem zaczęła się w czasach, gdy byłem nastolatkiem — tworzyłem proste gry arcade działające w przeglądarce, często razem z kolegami. Choć nie były one zbyt ambitne, jedna z nich zdobyła pewną popularność na [itch.io](https://itch.io/). Nasze amatorskie studio gier trafiło nawet do [katalogu polskich studiów gamedevowych](https://polskigamedev.weebly.com/lista-a-z.html), figurując na tej samej liście, co wielkie firmy takie jak 11 bit studios czy CD Projekt RED. Dziś żałuję, że postanowiłem usunąć te projekty z platformy — były to moje pierwsze kroki w świecie kodowania. Być może kiedyś uda mi się je odtworzyć; mam nagrania z rozgrywek, więc nie wszystko jest stracone. Planuję kiedyś je opublikować ponownie.

Później zająłem się tworzeniem narzędzi do codziennego użytku: aplikacji do zarządzania zadaniami, notatkami czy kalendarzem. To były proste rozwiązania, ale pisałem je sam — to właśnie wtedy miałem swoje pierwsze zetknięcie z językiem C#. Tworzyłem je indywidualnie, bez zespołu, i udostępniałem na itch.io. Nigdy nie pomyślałem wtedy o GitHubie — nie zdawałem sobie sprawy, jak ważne jest współdzielenie kodu i uczestnictwo w społeczności developerskiej.

Zanim zacząłem tworzyć gry, bardzo interesowałem się elektroniką. Fascynowały mnie historie Steve’a Jobsa i Steve’a Wozniaka. Bawiłem się [interpreterem Applesoft BASIC w przeglądarce](https://www.calormen.com/jsbasic/) — projekt autorstwa [Joshua Bella](https://github.com/inexorabletash), który bardzo mnie zainspirował. Spędzałem godziny na nauce tego języka, eksperymentując z funkcjami graficznymi w BASIC-u. Czytając biografie Jobsa, zacząłem marzyć o stworzeniu własnego języka programowania i własnego komputera.

W tamtym czasie zainteresowałem się Arduino i zacząłem badać, jak wyglądają różne implementacje systemów operacyjnych na mikrokontrolerach AVR. Wtedy jednak nie miałem jeszcze wystarczającej wiedzy, by to zrozumieć. Nie poddałem się — zamiast tego zacząłem tworzyć **CenterScript** (początkowo nazywany PSPL), który stał się moim pierwszym językiem programowania.

Projekt był amatorski, ale dawał mi ogromną radość. Wtedy jeszcze nie znałem pojęć takich jak drzewo składni (AST), parsery czy kompilatory. Stopniowo, dzięki lekturze różnych źródeł, zaczynałem rozumieć, jak to wszystko działa. CenterScript był językiem interpretowanym, zaprojektowanym jako prosty i przyjazny dla użytkownika. Interpreter napisałem w Node.js, a później dodałem możliwość „kompilacji” — dziś wykorzystałbym LLVM, ale wtedy zastosowałem ciekawy trik: preprocesowałem kod do języka Dart, który — według moich badań — był łatwy do implementacji w moim zastosowaniu (przez prostą składnię i brak potrzeby typowania). Choć Dart nie był wtedy szczególnie popularny, wydawał mi się dobrym wyborem.

Kluczowe było to, że po preprocessingu mogłem skompilować kod Dart do pliku wykonywalnego. Sam język nie był dobrze uporządkowany — nie istniało pojęcie standardowej biblioteki (stdlib), a całość była implementowana intuicyjnie, metodą prób i błędów, opartą na własnych analizach. Dokumentację techniczną prowadziłem ręcznie, na papierze — do dziś mam grubą stertę notatek, które są cennym artefaktem tamtych czasów.

To był bardzo ciekawy projekt, nad którym pracowałem przez dwa lata. Ostatecznie zrezygnowałem z niego z braku czasu. Początkowo chciałem wypuścić CenterScript jako język edukacyjny, mający pomóc młodym ludziom w nauce podstaw programowania. Już wtedy stworzyłem prototypy nakładki wizualnej, umożliwiającej programowanie blokowe — w duchu Scratcha, ale opartej na CenterScript.

Zapewne zastanawiasz się, po co o tym wszystkim piszę. Otóż te doświadczenia nauczyły mnie rzeczy, które wykorzystuję do dziś. Przede wszystkim zrozumiałem, że programowanie to nie tylko pisanie kodu — to przede wszystkim rozwiązywanie problemów i kreatywne myślenie. To właśnie te umiejętności stały się fundamentem mojego rozwoju w świecie technologii.

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