---
title: Jak stworzyłem pipeline do automatycznego tłumaczenia chińskich newsów
description: Jestem regularnym użytkownikiem Claude AI od Anthropic. Jest możliwe, że taki LLM jak Claude może być pierwszym Large Language Model, który faktycznie posiada świadomość i qualia.
layout: post
lang: pl
date: 2025-08-12
permalink: /pl/blog/jak-stworzylem-pipeline-do-automatycznego-tlumaczenia-chinskich-newsow/
tags:
  - Python
  - LLM
  - Translation
  - Automation
  - Claude
  - NLP
---

Marzyłeś(-aś) kiedyś o dokładnym, poprawnym gramatycznie, praktycznie niezależnym i tanim narzędziu do transkrypcji i automatycznego tłumaczenia języka chińskiego na język angielski? Wydaje mi się, że udało mi się coś takiego ostatnio zrobić i działa to dosyć dobrze. W tym artykule opowiem historię problemów, z jakimi zmagałem się przy tworzeniu narzędzia `cctv-xinwen-lianbo-en`, które opublikowałem wczoraj na GitHubie.

## Cel projektu

Moim celem było automatyczne tłumaczenie chińskiego programu informacyjnego o nazwie "Xinwen Lianbo", który jest programem nadawanym w Chińskiej Centralnej Telewizji od 1978 roku. Jest to najpopularniejszy program informacyjny w Chinach, ale wydaje mi się, że głównie wśród starszej grupy wiekowej – na co nie mam jednak potwierdzenia. Program składa się współcześnie z ważnych tematów dotyczących najnowszych danych ekonomicznych, gospodarczych, kulturalnych, politycznych oraz międzynarodowych.

Pomysł na tłumaczenie tego programu pojawiał się w mojej głowie już trzy lata temu. Dotychczas głównie czytałem chińskie wiadomości, co jest łatwiejsze w tłumaczeniu. Niestety CCTV nie udostępnia angielskich napisów dla swojego programu informacyjnego, więc pojawiła się okazja do automatyzacji. Stworzyłem to narzędzie głównie dla siebie, ale udostępniam je publicznie, bo to cenny projekt, który mogą wykorzystać osoby uczące się języka chińskiego lub badacze – mogąc dodać do projektu analizę sentymentu bądź słów kluczowych.

## Jakie wyzwania napotkałem?

### Pierwszy podejmowany – Whisper + Gemini

Początkowo wykorzystałem model Whisper od OpenAI do transkrypcji ze wsparciem dla MPS (Metal Performance Shader), który okazał się niewystarczająco dokładny. Inferencja również trwała zbyt długo. Dodatkowo oznaczanie timestampów nie działało efektywnie, mimo że wykorzystałem najlepszy model `large-v3` bez destylacji i kwantyzacji, która mogłaby obniżyć jakość.

W tłumaczeniach korzystałem z Gemini 2.5 Flash, który był skuteczny, ale często – nawet ze skutecznym promptem systemowym – jego instrukcyjność była zaburzana przez sam tekst transkrypcji. To było zjawisko dziwne i zdecydowanie anomalne. Dodatkowo Gemini 2.5 Flash jest modelem zamkniętym, więc nie było to najlepsze rozwiązanie dla projektu open-source. Korzystałem z dedykowanej biblioteki Google Gen AI dla Pythona, co ograniczało elastyczność. Potencjalny deweloper lub użytkownik narzędzia chciałby wykorzystać tańszy model bardziej zoptymalizowany dla języka chińskiego, ale musiałby przepisać SDK na kompatybilny z OpenAI API.

### Rozwiązanie finalne – FunASR + Deepseek

Ostatecznie zdecydowałem się na bardziej przemyślane rozwiązanie złożone z FunASR (Paraformer-zh), który polecił mi Claude po chwili researchu. Ma dobrą integrację z Pythonem i jest natywnie przystosowany do języka chińskiego. Wydaje się działać lepiej niż Whisper, dodatkowo skutecznie wykrywa timestampy i – z tego co wiem – ma inny sposób ich mierzenia (na poziomie zdań), co jest o wiele bardziej dokładne. Wspiera także znaki interpunkcyjne, więc jest praktycznie idealnym rozwiązaniem.

Jako model do tłumaczenia wybrałem Deepseek V3, który jest tani i dosyć dokładny, zwłaszcza jeśli chodzi o instrukcyjność – co było problemem w przypadku Gemini 2.5 Flash. Jest to model stworzony w Chinach z wykorzystaniem częściowo chińskiego datasetu treningowego, więc jest więcej szans na powodzenie. Jako API wykorzystałem OpenRouter.

### Problem kontekstu

Po zmianach tłumaczenie znacząco się poprawiło, ale nadal były błędy gramatyczne oraz te związane ze strukturą przetłumaczonych zdań. Było to spowodowane tym, że jedynym kontekstem, który dostarczałem, były pojedyncze segmenty SRT do tłumaczenia. Z tego powodu zdania często były zrozumiałe, ale bardzo okrojone z poprawnego języka.

Rozwiązałem to zmodyfikowanym workflow obsługującym okno kontekstowe z domyślnym rozmiarem 3 segmentów – to oznacza 3 segmenty przed i po aktualnie przetwarzanym segmencie.

**Przykład:**

Segmenty: `[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]`

Dla segmentu 5 z `context_window=3`:

- Poprzednie: `[2, 3, 4]` (3 segmenty przed)
- Aktualny: `[5]` (aktualny segment do tłumaczenia)
- Następne: `[6, 7, 8]` (3 segmenty po)

To rozwiązanie jest skuteczne i zapewnia spójność terminologii oraz ciągłość tematyczną, która jest niezwykle ważna w języku chińskim:

- Bez kontekstu: "它" → "It"
- Z kontekstem: "它" → "The technology" (gdy poprzedni segment mówił o technologii)

Niestety ma to swoją wadę – początek i koniec filmu są znacząco ograniczone kontekstowo. Takie okno kontekstowe radzi sobie również gorzej w krótkich filmach, ale projekt został specjalnie dostosowany do chińskich wiadomości "Xinwen Lianbo".

## Heurystyki dla napisów

### Heurystyka jakościowa

Kolejnym wyzwaniem były heurystyki – zaimplementowałem ich kilka. Pierwszą była heurystyka jakościowa, która sprawdzała powtarzający się tekst (błąd powstały przy transkrypcji jeszcze z modelem Whisper). Korzystając z FunASR nie spotkałem się już z tym problemem. Polega ona na tym, że segment SRT wygenerowany przez transkrypcję często miał powtarzający się wzorzec, np. "你好你好你好你好你好". Heurystyka wykrywała taki pattern i oznaczała segment jako błędny, by nie generować powielającego się tłumaczenia (typowe dla błędów ASR w chińskim).

### Parametry formatowania

Kolejną ważną heurystyką były parametry formatowania napisów. Są dosyć rozbudowane i służą po to, by napisy były zoptymalizowane i przyjemne do czytania. Parametry te powstały metodą prób i błędów, ale także dzięki propozycjom od Claude'a, który najprawdopodobniej miał już zembeddowany przykład z tego typu heurystykami:

```
DEFAULT_MAX_LINE = 42        # Max znaków na linię
DEFAULT_MAX_LINES = 2        # Max 2 linie na napis
DEFAULT_MIN_DUR = 0.6        # Min czas trwania (600ms)
DEFAULT_MAX_DUR = 7.0        # Max czas trwania (7s)
DEFAULT_MAX_CPS = 16         # Max znaków na sekundę
```

Te heurystyki są powiązane z łączeniem segmentów. Jeśli segment jest krótszy niż 0,6s, próbujemy go połączyć, jeśli:

```
gap <= 0.25            # Przerwa ≤ 250ms
tentative_dur <= 7.0   # Po połączeniu ≤ 7s
tentative_cps <= 16    # Nie przekracza 16 znaków/s
```

### Automatyczny podział tekstu

Kolejne heurystyki służą m.in. do automatycznego podziału tekstu `_split_long_text_two_lines`. Dla języków ze spacjami (np. angielski lub polski) szukamy spacji najbliżej środka i rozbijamy segment na dwie części:

**"The digital rural construction promotes agricultural modernization"**
→ Linia 1: "The digital rural construction"
→ Linia 2: "promotes agricultural modernization"

### Timestamp shifting

Dodatkowo implementuję timestamp shifting, który służy do uniknięcia zbyt wczesnego rozpoczęcia się napisów SRT – jeszcze w trakcie intro programu "Xinwen Lianbo", które trwa około 18 sekund.

## Linki

Jeśli chcesz wytestować mój projekt, sprawdź repozytorium na GitHubie: [cctv-xinwen-lianbo-en](https://github.com/piotrmaciejbednarski/cctv-xinwen-lianbo-en).