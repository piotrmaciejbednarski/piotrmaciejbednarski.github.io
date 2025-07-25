---
title: Stworzyłem biblioteki, które usprawniają pracę z tekstem i LLM
description: Zauważyłem, że to pole jest bardzo zaniedbane – niektóre biblioteki nie są aktualizowane od roku lub dziesięciu lat, a nadal sporo osób z nich korzysta. Dlatego pomyślałem, że coś nowego, co znajdzie zastosowanie w NLP dla projektów Node.js, wstrzeli się w niszę i wypełni pewną lukę technologiczną.
layout: post
lang: pl
date: 2025-07-25
permalink: /pl/blog/i-have-created-libraries-that-enhance-working-with-text-and-llms/
---

Dawno nie pisałem na blogu, ale w końcu mam o czym pisać. Musicie się przyzwyczaić do mojego podejścia – nie chciałbym tutaj pisać o rzeczach nieistotnych lub mało znaczących. Nie chciałbym też opowiadać bezpośrednio o tym, co robię w pracy i zawodzie, ale bardziej publikować rzeczy, które po pierwsze mogę udostępniać, a po drugie uważam za ciekawe do podzielenia się ze światem.

Ostatnio pracowałem nad jednym pomysłem na projekt, który mógłby być mocno rewolucyjny, ale odłożyłem go na bok po wykonaniu prototypu i dobrej dokumentacji. Zapewne o nim opowiem w przyszłości, ale zdradzę, że udostępnienie go światu spowodowałoby zmianę tego, co uważamy potocznie za reverse engineering – w kontekście cyfrowych układów scalonych. Więcej na ten moment nie mogę zdradzić, ale wyczekujcie artykułu na ten temat! Zapewne jeśli ukończę ten projekt, to wraz z nim pojawi się preprint w arXiv, więc pewnie myślicie, że to coś innowacyjnego (i takie będzie!).

Opublikowałem niedawno dwie biblioteki, z których bardzo się cieszę. Pierwsza z nich to [text-similarity-node](https://github.com/piotrmaciejbednarski/text-similarity-node) – biblioteka napisana w C++17 dla Node.js (wykorzystuje [NAPI](https://nodejs.org/api/n-api.html), by używać funkcji języka C++ w języku JavaScript). Ta biblioteka udostępnia wiele algorytmów porównywania tekstów i co najważniejsze, ma niskie zużycie pamięci oraz wykorzystania garbage collectora, a także jest dosyć wydajna w rzeczywistym świecie, choć niektóre implementacje JavaScript ją przewyższają.

Moja biblioteka celowo ma wysoką abstrakcję w C++, co znacznie obniża jej wydajność, a narzut czasowy NAPI na każdą operację w JavaScript powoduje, że mam spore ograniczenia narzucone technicznie. Mimo wszystko jest stosunkowo wydajna i bardzo dobrze się skaluje w operacjach na dużych długościach stringów, co jest wielkim plusem mojej biblioteki. Aktualnie pracuję nad przepisaniem mojej biblioteki na WASM + Rust (z użyciem narzędzia [wasm-pack](https://github.com/drager/wasm-pack)) bez warstwy abstrakcji (chcę się skupić na low-level) i wstecznej kompatybilności, a także zgodności algorytmicznej z referencyjną biblioteką (o tym za chwile). Na szczęście mam już doświadczenie w pisaniu kodu Rust, dla przykładu napisałem [bibliotekę Rust dla obsługi zasilaczy awaryjnych](https://github.com/piotrmaciejbednarski/megatec-ups-control), którą polecam sprawdzić. Jeśli korzystałeś kiedyś z zasilaczy awaryjnych to na pewno zetknąłeś się z oprogramowaniem UPSilon 2000 - ja przeniosłem funkcjonalność tego programu do biblioteki, która operuje niskopoziomowo, a całość odtworzyłem przez inżynierie wsteczną. Jeśli się uda, to text-similarity-node będzie świetną alternatywą wobec większości alternatywnych bibliotek wykonanych w JavaScript. Żeby poinformować moich użytkowników, którzy korzystają z biblioteki stworzyłem skrypt postinstall, który informuje ich o planowanych działaniach.

Miałem wielki problem – jak zweryfikować, czy moje implementacje algorytmiczne działają poprawnie (zgodnie z teorią)? Wykorzystałem więc [TextDistance](https://github.com/life4/textdistance) w Pythonie, która jest cenioną i sprawdzoną biblioteką. Wykonuje ona mniej więcej to samo co moja biblioteka, a jej wewnętrzne implementacje różnych algorytmów (pochodzące z różnych repozytoriów bądź Wikipedii) pozwoliły mi oszczędzić pracę i dodatkowo zweryfikować moje algorytmy, sprawdzając, czy referencyjna biblioteka odpowiada mniej więcej tymi samymi wynikami.

Osiągnąłem 95% skuteczność poza algorytmem Cosine Similarity, ponieważ w mojej bibliotece inaczej rozwiązałem kwestię tokenizacji. Jakie było moje zdziwienie, gdy okazało się, że Cosine Similarity w TextDistance to tak naprawdę Ochiai coefficient! Powinni nazwać ten algorytm bezpośrednio, zamiast ogólnie nazywać klasę `[Cosine(_BaseSimilarity)](https://github.com/life4/textdistance/blob/d6a68d61088a40eef5c88191ccf79323dbf34850/textdistance/algorithms/token_based.py#L182)`. Jest to jeden z najmniej ustandaryzowanych sposobów mierzenia podobieństwa tekstów.

Pojawiły się również problemy z pakowaniem tej biblioteki, gdyż nigdy wcześniej tego nie robiłem. Sama biblioteka Node.js nie stanowi problemu, ale gdy łączysz to z C++ i NAPI, całość zaczyna się komplikować. Nie chciałem udostępniać biblioteki, którą każdy musi kompilować na swoim sprzęcie – co wymaga czasu i instalacji różnych narzędzi oraz samego kompilatora. Na szczęście jakiś dobry człowiek na tej ziemi stworzył package [prebuildify](https://github.com/prebuild/prebuildify), który pozwala dostarczać zbudowane artefakty (.node) za pomocą node-gyp (narzędzia do kompilowania native addons dla Node.js) bezpośrednio w NPM package. Po instalacji użytkownik korzysta z odpowiedniego prebuilt binary zbudowanego dla platformy, z której korzysta, i całość wygląda jak instalacja zwykłego package JavaScriptowego.

Przewidziałem tam platformy x64/arm64 dla Windows, Linux i macOS, które są budowane przez GitHub Actions (na który wydałem sporo pieniędzy, zanim udało mi się to wszystko przetestować – najbardziej uciążliwe było testowanie kompilacji na Windowsie i częste problemy ze stripowaniem wbudowanym w prebuildify). W mojej bibliotece zaimplementowałem również [SIMD](https://en.wikipedia.org/wiki/Single_instruction,_multiple_data), ale tak naprawdę nie zweryfikowałem jeszcze, czy w pełni działa – niektóre funkcje nie korzystają w pełni z SIMD, ale uważam to za dobry początek. Zauważyłem gdzieś w internecie, że poleca się używanie SIMD do native addonów, więc spróbowałem to zrobić, ale weryfikację (zapewne benchmark z SIMD i bez SIMD) wykonam dopiero niedługo. Cóż, przynajmniej jestem szczery…

Tak naprawdę benchmark w moim projekcie (zrealizowany dzięki [tinybench](https://github.com/tinylibs/tinybench), który wydaje się bardziej precyzyjny i lżejszy od benchmark.js) pokazuje, że moja biblioteka radzi sobie nawet nieźle, choć często zawodzi pod względem ops/s (operacji na sekundę), ale różnice pozostają niewidoczne w realnych aplikacjach. Plusem jest to, że niezależnie od skalowania danych wejściowych mam przewidywalną wydajność i stabilność, a także lepsze zarządzanie pamięcią, asynchroniczne API i pełną obsługę Unicode oraz konfiguracji biblioteki – czego nie mają inne biblioteki Node.js. Z tego powodu mogę powiedzieć, że moja biblioteka zdecydowanie jest bardziej rozbudowana i efektywna w realnych projektach.

Zauważyłem, że to pole jest bardzo zaniedbane – niektóre biblioteki nie są aktualizowane od roku lub dziesięciu lat, a nadal sporo osób z nich korzysta. Dlatego pomyślałem, że coś nowego, co znajdzie zastosowanie w NLP dla projektów Node.js, wstrzeli się w niszę i wypełni pewną lukę technologiczną.

Druga biblioteka, którą opublikowałem, to naprawdę lekka i prosta implementacja funkcjonalności nazwanej „Structured Outputs” w OpenAI API. W skrócie chodzi o to, że często chcemy, by LLM zwrócił nam odpowiedź w formie strukturalnej, np. JSON lub modelu Pydantic (w praktyce jest to to samo, bo wykonujemy serializację modelu Pydantic do JSON).

Przedstawiam wam [structllm](https://github.com/piotrmaciejbednarski/structllm)! To bardzo prosta biblioteka do Pythona 3.x, która korzysta z [LiteLLM](https://github.com/BerriAI/litellm) jako uniwersalnego klienta obsługującego wielu providerów w jednolitym formacie OpenAI API. To oznacza, że z tego samego API i formatu możemy komunikować się z modelami Anthropic, Gemini, Vertex, Cohere, Mistral czy modelami z OpenRoutera.

StructLLM pozwala zaimplementować „Structured Outputs” z OpenAI i działa na następującej zasadzie:

Podajemy model [Pydantic](https://docs.pydantic.dev/latest/), w którym chcemy otrzymać wyjściowy wynik z LLM. Pod powłoką wstrzykujemy do system prompta serializowaną strukturę tego modelu Pydantic:

```
"You must respond with a valid JSON object that conforms exactly "
"to the following schema. "
"IMPORTANT: Do not use Markdown formatting, just return the JSON "
"object directly.\\n\\n"
f"JSON Schema:\\n{json.dumps(schema, indent=2)}"
```

Następnie wrzucamy to do system prompta w konwersacji z ustawionym top_p i temperature na 0.1 (dla przewidywalności i małej kreatywności, ponieważ wykonujemy zadanie typu strukturalnego). Podajemy w konwersacji prośbę, np.:

```python
messages = [
    {"role": "system", "content": "Extract the event information."},
    {
        "role": "user",
        "content": "Alice and Bob are going to a science fair on Friday.",
    },
]
```

LLM odpowie nam w taki sposób, w jaki zdefiniowaliśmy model Pydantic, zgodnie z typowaniem i strukturą, a biblioteka automatycznie parsuje odpowiedź z LLM jako JSON i zamienia z powrotem na BaseModel Pydantic.

Bardzo proste, ale działa i potrzebowałem tego w jednym projekcie, nad którym pracuję w pracy, dlatego w sumie pojawiła się idea stworzenia tego projektu.

Dodatkowo w kilku projektach zauważyłem, że programiści często źle konfigurują swój prompt systemowy do strukturalnego wyjścia LLM i bezpośrednio ładują czystą odpowiedź z LLM jako JSON bez żadnego parsowania. Po prostu zakładają, że odpowiedź LLM będzie wyłącznie strukturalna, więc moja biblioteka stara się wszystko ujednolicić i zapewnić parsowanie, walidację i wszystko, co potrzebne do prostego zadania związanego ze strukturalnym wyjściem z LLM.

Nie reklamowałem za bardzo moich nowych bibliotek, więc zapewne rozpoznawalność pojawi się z czasem. Przy okazji powiem, że zacząłem commitować do repozytorium [FluxLang](https://github.com/kvthweatt/FluxLang) – to jakiś kompilator dla języka programowania opartego na LLVM, który tworzy jakiś programista w formie hobby. Delikatnie pomogłem mu, jak tylko mogłem, przez uporządkowanie jego projektu i dodanie kilku feature do jego kompilatora. Powoli też rozwijam jego bibliotekę standardową języka. Widziałem ten projekt na HackerNews (Y Combinator) w formie reklamy, więc postanowiłem, że dołożę swoją cegiełkę.
