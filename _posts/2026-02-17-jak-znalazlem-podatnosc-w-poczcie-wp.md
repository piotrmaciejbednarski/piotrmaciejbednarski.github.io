---
title: Jak znalazłem podatność w poczcie WP?
description: Krótka historia odkrycia luki Stored XSS w poczcie WP i O2 oraz procesu raportowania podatności.
layout: post
lang: pl
date: 2026-02-17
permalink: /pl/blog/jak-znalazlem-podatnosc-w-poczcie-wp/
og_image: /assets/img/embed.png
tags:
  - Web Security
  - XSS
  - Bug Bounty
  - WP.pl
  - O2.pl
image:
  path: /assets/img/xsswp/Animation.gif
  width: 600
  height: 400
---

<img class="post-image" width="600" height="400" src="/assets/img/xsswp/Animation.gif" alt="XSS w poczcie WP - animacja">

Około tydzień temu (raport wysłany 10 lutego 2026) znalazłem podatność w poczcie WP i O2 (O2 tak naprawdę korzysta z tego samego interfejsu webowego i infrastruktury co poczta WP - Wirtualnej Polski).

Ostatnie publiczne wzmianki o lukach XSS w poczcie WP pojawiają się w 2012 roku na stronie [Niebezpiecznika](https://niebezpiecznik.pl/post/xss-y-i-csrf-w-poczcie-wp/) – co ciekawe, lukę tę znalazł wtedy Jakub Zoczek, który aktualnie pracuje w [Securitum](https://securitum.pl/). Trzeba sobie jednak zdawać sprawę, że wtedy poczta WP działała zupełnie inaczej niż dzisiaj.

Współcześnie WP pisze na nowoczesnym stacku frontendowym: **Chakra UI + Radix UI + React**. W tamtych czasach (2012) był to raczej CSS pisany z palca i JQuery, co doskonale pokazuje różnice między technologiami współczesnymi a przeszłością. W sumie ciekawiło mnie, czy samemu mógłbym znaleźć taką lukę – nawet gdyby była mało znacząca, to jest fajnym "smaczkiem", który można wrzucić do portfolio.

## Pierwsze kroki: security.txt

Przed testowaniem podatności należy sprawdzić, czy firma oficjalnie posiada informacje kontaktowe do działu security. Skonstruowałem sobie do tego prosty Google Dork, z którego możecie sami skorzystać dla dowolnej firmy (zastąpcie domenę): `inurl:"/.well-known/security.txt" inurl:wp.pl`

Niestety, często brakuje jasnych informacji o tym, jak należy szukać podatności i czy firma na to pozwala. To bywa "szarą strefą". Kluczową zasadą jest etyka: o ile zgłosisz podatność, nie wykorzystasz jej w złych celach i nie będziesz testować na kontach osób trzecich, zazwyczaj nie będziesz mieć problemów. Ja dokładnie tak poczyniłem i na potrzeby testów stworzyłem sobie konto testowe.

## Poszukiwania i publiczne source mapy

Fakt szukania podatności po stronie frontendu znacznie ułatwiły dostępne publicznie **source mapy** (pochodzące z Webpacka). Dla atakującego to prawdziwy skarb, bo pozwalają na odtworzenie oryginalnego kodu (z komentarzami autorów!) TypeScript z minifikowanego JavaScriptu. W przypadku Poczty WP pozwoliło to na precyzyjną lokalizację miejsca renderowania wartości.

W kodzie natrafiłem na klasyczny problem: programiści zastosowali `dangerouslySetInnerHTML` w React do renderowania treści HTML bezpośrednio z API, **całkowicie pomijając etap sanityzacji**. Co ciekawe, nawet gdyby sanityzacja była wdrożona, domyślna konfiguracja popularnych bibliotek (jak DOMPurify) bez jawnego zdefiniowania restrykcyjnej listy `FORBID_TAGS` (np. dla tagów `iframe`, `object`, `embed`) i tak pozwoliłaby na przemycenie payloadu. Dopiero połączenie poprawnej sanityzacji po stronie frontendu (dobrą praktyką jest również sanityzować po stronie backendu) wraz z aktualizacją polityki blokowanych tagów skutecznie wyeliminowało lukę.

## Scenariusz persistence: Stored XSS

Najciekawszym aspektem luki była jej trwałość. Wykorzystując klasyczny payload XSS z tagiem `<iframe>` z atrybutem `srcdoc`, można było wstrzyknąć kod do bazy danych. Taka podatność typu **Stored XSS** ma jedną kluczową zaletę z punktu widzenia atakującego: przetrwa unieważnienie wszystkich sesji i zmianę hasła przez ofiarę.

Wystarczyło jedno żądanie `POST` pod endpoint `/api/v1/signatures`, aby dodać złośliwy payload do sygnatury użytkownika. Co ciekawe, wspomniany endpoint nie weryfikował nagłówka `XSRF-TOKEN` (choć przed atakami CSRF chronił atrybut `SameSite=Lax` ciasteczka sesji).

Za każdym razem, gdy użytkownik otwierał modal wyboru sygnatury ("Więcej" -> "Wybierz sygnaturę") w oknie kompozycji wiadomości, złośliwy kod wykonywał się w kontekście jego sesji (same-origin). Atak był całkowicie niewidoczny dla użytkownika – payload nie generował żadnych wizualnych artefaktów w DOM (np. brakujących obrazków).

## Raport i reakcja firmy

Dział SOC (Security Operations Center) Wirtualnej Polski zareagował bardzo szybko. Błyskawicznie dostałem odpowiedź, a luka została już naprawiona (w wersji 8.199.4). Mimo braku oficjalnego programu "Bug Bounty", przysłali mi nawet drobny prezent w ramach podziękowania.

Jest to dla mnie świetny przykład, że warto zgłaszać takie znaleziska w sposób profesjonalny, nawet jeśli firma nie ma publicznej listy nagród.

(To jest artykuł typu responsible disclosure po naprawieniu błędu. Nie ujawniam tu wrażliwych szczegółów technicznych, które mogłyby zaszkodzić firmie).