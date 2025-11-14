---
title: Kradzież modeli AI przez publiczne API
description: Jak publiczne API AI mogą być wykorzystywane do wyciągania wartościowych modeli - od opisów zdjęć na Facebooku po komercyjne endpointy LLM. Spojrzenie na niewidzialne ataki kosztujące miliony.
layout: post
lang: pl
date: 2025-11-14
permalink: /pl/blog/kradziez-modeli-ai-przez-publiczne-api/
og_image: /assets/img/embed.png
tags:
  - AI Security
  - Machine Learning
  - API Exploitation
---

Każdego dnia miliony ludzi wrzucają zdjęcia na Facebooka i automatycznie generuje się dla nich alternatywny opis: "dwóch mężczyzn w restauracji" albo "kobieta z psem w parku". Ta funkcja nazywa się Automatic Alt Text (stworzona w 2017 roku) i została stworzona z myślą o osobach niewidomych. Ale okazuje się, że można ją wykorzystać w zupełnie inny sposób.

Wyobraź sobie właściciela sklepu internetowego, który potrzebuje opisów do stu tysięcy zdjęć produktów. Może zapłacić kilkaset dolarów zewnętrznej usłudze, zatrudnić ludzi albo... wykorzystać Facebooka. Wystarczy napisać skrypt, który wgrywa zdjęcia jako niepublikowane posty, wyciąga wygenerowane opisy, a potem usuwa posty bez śladu.

Facebook płaci za każde takie wywołanie swojego modelu komputerowego widzenia. Model kosztował miliony dolarów w badaniach i rozwoju, a teraz pracuje za darmo dla cudzego biznesu. Co więcej, właściciel sklepu technicznie nie łamie żadnych zasad - wgrywa zdjęcia na swoją platformę, Facebook sam generuje opisy, więc można je pobrać.

## Gdy twój własny model zaczyna pracować dla konkurencji

Historia nie kończy się na gigantach technologicznych. Załóżmy, że spędziłeś trzy miesiące budując klasyfikator wiadomości. Model analizuje, czy użytkownik próbuje wyciągnąć rozmówcę poza twoją platformę - "napisz do mnie na WhatsApp" powinno zostać zablokowane. Po wielu testach i poprawkach twój model osiąga 95% dokładności.

Udostępniasz prosty endpoint: wysyłasz tekst, dostajesz odpowiedź true lub false. Wydaje się niegroźnie. Ale jeśli ktoś napisze skrypt, który będzie wysyłać dziesiątki tysięcy różnych wiadomości i zapisywać odpowiedzi, może odtworzyć całą logikę twojego modelu. Nie potrzebuje dostępu do kodu ani wag neuronów - wystarczy mu wiedza o tym, jak model reaguje na różne teksty.

Po kilku dniach bombardowania twoim endpointem atakujący ma bazę danych z 50 tysiącami par tekst-odpowiedź. To wystarczy, żeby wytrenować własny model, który będzie działał praktycznie identycznie. Koszt? Kilkadziesiąt dolarów za GPU w chmurze. Twój koszt? Tysiące dolarów za obliczenia plus miesięce pracy nad algorytmem.

Najgorsze jest to, że w logach serwera widzisz tylko zwykłe zapytania HTTP. Nic nie wskazuje na to, że ktoś systematycznie kopiuje twoją pracę. To jak kradzież w galerii sztuki, gdzie złodziej nie zabiera oryginałów - tylko robi im bardzo dokładne zdjęcia i potem drukuje kopie.

## Darmowe modele językowe dla każdego

LM Arena to platforma, gdzie można porównywać różne duże modele językowe. Wpisujesz pytanie, wybierasz model i dostajesz odpowiedź. Brzmi niewinnie, ale pod spodem kryje się publiczny endpoint, który można wykorzystać automatycznie.

Zamiast płacić Anthropic kilkadziesiąt dolarów za milion tokenów Claude'a, można wysyłać zapytania przez LM Arena za darmo. Wystarczy odpowiedni skrypt i proxy do obejścia podstawowych limitów. Niektórzy budują w ten sposób całe aplikacje komercyjne, oszczędzając tysiące dolarów miesięcznie na kosztach API.

LM Arena finansuje się z grantów naukowych i darowizn, żeby udostępnić technologię szerszej publiczności. Domyślam się, że znaczna część ruchu to nie badacze ani studenci, tylko spryciarze wykorzystujący platformę jako darmową infrastrukturę do własnych celów.

## Anatomia niewidzialnego ataku

Dlaczego te ataki są tak skuteczne? Po pierwsze, wyglądają jak normalny ruch. Jeśli ktoś wysyła sto zapytań na godzinę przez kilka dni, może to być po prostu aktywny użytkownik. Dopiero analiza wzorców pokazuje, że teksty mają nieprawdopodobnie wysoką losowość albo że zapytania przychodzą w regularnych odstępach charakterystycznych dla skryptów.

Po drugie, koszt ataku jest znikomy w porównaniu do wartości ukradzionej wiedzy. Wytrenowanie dobrego modelu klasyfikującego to miesiące pracy zespołu, tysiące dolarów za GPU i eksperymenty z różnymi architekturami. Skopiowanie go przez API to kilka godzin pisania skryptu i koszt kilkudziesięciu dolarów za wywołania.

Po trzecie, prawnie sytuacja jest mglistja. Czy wykorzystanie publicznego API zgodnie z dokumentacją, ale w celu odtworzenia modelu, to kradzież własności intelektualnej? Czy "masowe odpytywanie endpointu" narusza Terms of Service, jeśli nie ma określonych limitów? Prawnicy mogą się kłócić latami, a w międzyczasie model już pracuje u konkurencji.

## Kiedy funkcje stają się dziurami

Facebook nie planował, że Automatic Alt Text stanie się darmowym API do opisów produktów. LM Arena nie zakładało, że będzie zasilać komercyjne chatboty. Twój klasyfikator wiadomości miał chronić platformę, a nie uczyć konkurencję.

Problem polega na tym, że każda funkcja AI dostępna publicznie może zostać wykorzystana nie zgodnie z przeznaczeniem. Im prostszy interfejs i im mniej barier, tym łatwiej go zautomatyzować. Co było przewagą konkurencyjną w postaci szybkiej integracji, staje się podatnością umożliwiającą kradzież.

Warto pamiętać o tej dwuznaczności przy projektowaniu własnych rozwiązań. Model udostępniony publicznie to nie tylko funkcjonalność dla użytkowników, ale potencjalnie też darmowe R&D dla kogoś, kto jest wystarczająco sprytny i ma odpowiednie narzędzia.

To nowa kategoria zagrożeń w erze AI - nie exploity ani włamania, tylko systematyczne wykorzystanie tego, co zostało udostępnione legalnie, ale nie zgodnie z intencją twórców. Czasem najlepsze zabezpieczenie to po prostu świadomość, że problem istnieje.