---
title: Niestandardowe helpery Handlebars w Ghost
description: Jak rozszerzyć możliwości motywów Ghost o niestandardowe helpery Handlebars, zarówno poprzez modyfikację kodu źródłowego, jak i bez niej.
layout: post
lang: pl
date: 2025-01-06
permalink: /pl/blog/niestandardowe-helpery-handlebar-w-ghost/
lang_alternate: /en/blog/make-custom-handlebar-helpers-in-ghost/
tags:
  - Ghost
  - Handlebars
  - Web Development
  - JavaScript
  - Theming
---

Ten artykuł jest przeznaczony dla wielu programistów i twórców motywów, którzy uważają, że standardowe helpery oferowane przez [Ghost](https://ghost.org/docs/themes/helpers/) są niewystarczające. Całkowicie normalne jest szukanie sposobów na rozszerzenie możliwości naszych motywów korzystających z Handlebars dostarczanych przez Ghost. Przed opublikowaniem tego artykułu i znalezieniem rozwiązania dla mojego motywu przeszukałem cały internet i sam przeanalizowałem kod źródłowy Ghost.

## Metoda 1 (modyfikacja kodu źródłowego)

Odkryłem, że można rozszerzyć kod źródłowy Ghost o dodatkowe helpery. Osiągnąłem to, dodając nowy katalog w `current/core/frontend/apps`. Skorzystałem z przykładu istniejącej „aplikacji” o nazwie `amp`, której kod jest bardzo prosty, aby rozpocząć tworzenie nowego helpera dostępnego w motywie. W tych istniejących aplikacjach struktura jest prosta, ponieważ helpery są rejestrowane w `lib/helpers`. Na końcu procesu należy dodać nazwę swojego katalogu w `apps` do `current/core/shared/config/overrides.json` w sekcji JSON `apps.internal`.

Przykładowa zawartość pliku `index.js` w naszej aplikacji wyglądałaby tak:

```js
const path = require('path');

module.exports = {
    activate: function activate(ghost) {
        ghost.helperService.registerDir(path.resolve(__dirname, './lib/helpers'));
    }
};
```

Następnie w katalogu `lib` tej aplikacji tworzymy folder o nazwie `helpers`. W środku tworzymy nowy plik, który będzie nazwą helpera wywoływanego w szablonie Handlebars. Na przykład nazwijmy go `uppercase.js`.

Poniżej znajduje się przykład kodu takiego helpera, który po prostu zamienia litery podanego tekstu w argumencie helpera na wielkie litery:

```js
// przepraszam za hardcodowaną ścieżkę, ale działa
// użyj `module-alias`, aby tego uniknąć
const {SafeString, escapeExpression} = require('../../../../services/handlebars');

module.exports = function uppercase(text) {
    return text.toUpperCase();
};
```

Nie zapomnij dodać nazwy katalogu aplikacji do `current/core/shared/config/overrides.json`. Po ponownym uruchomieniu Ghost wszystko powinno być gotowe.

## Metoda 2 (bez modyfikacji kodu źródłowego)

Ostatnio opracowałem tę metodę i można ją zastosować nie tylko na samodzielnie hostowanym Ghost, ale także na instancjach Ghost oferowanych przez dostawców hostingu. W tym drugim przypadku wymaga to odpowiedniego planowania architektonicznego i zakupu małego serwera, który będzie działał jako proxy dla Twojej końcowej instancji Ghost.

**Architektura, której użyjemy w tej metodzie:**
Serwer Nginx ← Middleware Node.js ← Instancja Ghost

Przeglądarka użytkownika wysyła żądanie do serwera Nginx, który zawiera upstream middleware. Wszystkie żądania, niezależnie od lokalizacji, będą przekazywane do middleware.

Middleware to serwer Express działający w Node.js z dodaną biblioteką [express-http-proxy](https://github.com/villadora/express-http-proxy), która znacznie upraszcza pracę. Konfigurujemy proxy do komunikacji z instancją Ghost. Biblioteka **express-http-proxy** ma właściwość `userResDecorator`, której możemy użyć do „ozdobienia odpowiedzi serwera proxy”. Możemy zmodyfikować odpowiedź od Ghost przed jej wysłaniem do przeglądarki użytkownika.

Nasz `userResDecorator` będzie asynchroniczny, aby nie blokować głównego wątku. Wrócimy do tematu asynchronicznego przetwarzania podczas tworzenia helperów. Na razie musisz wiedzieć, że nie wszystko, co przeglądarka użytkownika żąda, musi być dekorowane. Dlatego pierwszym krokiem będzie sprawdzenie nagłówka `content-type` odpowiedzi od Ghost. Możesz to zrobić w następujący sposób, a następnie porównać, czy jest to `text/html`, aby dekorować tylko dokumenty HTML zwracane użytkownikowi:

```js
// Gdzie 'proxyRes' to odpowiedź proxy wewnątrz 'userResDecorator'
const contentType = proxyRes.headers['content-type'] || '';
if (!contentType.includes('text/html')) {
    // Zwróć oryginalną zawartość, jeśli odpowiedź nie jest 'text/html'
    return proxyResData;
}

let htmlContent = proxyResData.toString('utf8');
// Zrób coś z 'htmlContent' i zwróć
return htmlContent;
```

W tym warunku możemy zacząć modyfikować `htmlContent`, ale dlaczego tego potrzebujemy? Zacznijmy od budowy podstaw dla naszego niestandardowego helpera w motywie Ghost!

W tym artykule utworzę niestandardowy helper w pliku `index.hbs` (strona główna) mojego motywu. W widocznym miejscu w szablonie Handlebars dodaję przykład niestandardowego helpera, nazywając go {% raw %}`{{hello_world}}`{% endraw %}.

⚠️ Następnie umieszczam go w widocznym miejscu na stronie głównej — ale zauważ, co się dzieje, gdy odświeżam stronę Ghost!

```html
{% raw %}{{!< default}}{% endraw %}
<div class="gh-container">
  <h1>Strona główna</h1>
  {% raw %}<p>{{hello_world}}</p>{% endraw %}
</div>
```

Po odświeżeniu otrzymuję komunikat o błędzie od Ghost, ponieważ {% raw %}`{{hello_world}}`{% endraw %} helper nie istnieje w domyślnych helperach Ghost. Aby nasza logika działała, musimy spowodować, aby nie był traktowany jako helper przez wbudowany Handlebars Ghost.

**Poprawny sposób** to zapisanie tego helpera jako {% raw %}`\{{hello_world}}`{% endraw %}. W ten sposób Ghost traktuje go jako zwykły tekst. Po odświeżeniu strony głównej Ghost powinieneś zobaczyć zwykły tekst {% raw %}`{{hello_world}}`{% endraw %}. Jeśli tak się stanie, jesteś na dobrej drodze. Wróćmy teraz do pliku serwera middleware, gdzie użyjemy dekoratora odpowiedzi.

⚠️ Pamiętaj, aby escape'ować niestandardowe helpery w swoim motywie! Nie zapomnij dodać znaku `\`.

```js
let htmlContent = proxyResData.toString('utf8');
```

W tej zmiennej mamy odpowiedź od instancji Ghost jako pełny HTML strony. Wyobraź sobie, że ta odpowiedź to strona główna Twojej instancji Ghost. Zawartość HTML będzie również zawierać nasz zwykły tekst {% raw %}`{{hello_world}}`{% endraw %}, który jest wyświetlany jako zwykły tekst. Jeśli nasz niestandardowy helper jest w tej formie, możemy go skompilować za pomocą [Handlebars.js](https://handlebarsjs.com/) w naszym middleware. Pamiętaj, aby najpierw zainstalować bibliotekę za pomocą menedżera pakietów, np. npm: `npm install handlebars` i dodać ją do swojego kodu: `const handlebars = require("handlebars");`.

```js
// Skompiluj odpowiedź HTML za pomocą Handlebars i zwróć wyrenderowany szablon
let htmlContent = proxyResData.toString('utf8');
const template = handlebars.compile(htmlContent);
htmlContent = template({});
```

Wow! Teraz mamy skompilowany i wyrenderowany HTML za pomocą Handlebars.js — ale to jeszcze nie koniec. Musimy jeszcze zarejestrować nasz niestandardowy helper {% raw %}`{{hello_world}}`{% endraw %}. Dodaj następujący kod, najlepiej po inicjalizacji Handlebars.js:

```js
// Zwraca 'Hello from middleware!' z aktualnym znacznikiem czasu
handlebars.registerHelper('hello_world', function (options) {
   return `Hello from middleware! ${new Date().toISOString()}`;
});
```

Po ponownym uruchomieniu serwera middleware i zarejestrowaniu powyższego helpera powinieneś zobaczyć wyrenderowany helper w przeglądarce z tekstem zwróconym przez nasz helper i aktualną datą oraz godziną.

Na tym etapie możesz rozszerzyć swój motyw Ghost o dodatkowe niestandardowe helpery, które dodasz do kodu serwera middleware.

### Bezpieczeństwo

W pewnym momencie możesz chcieć zwracać różne rzeczy za pomocą swoich helperów. Domyślnie biblioteka chroni przed atakami XSS, ale gdy używasz metody `SafeString`, ta ochrona przestaje działać. Unikaj jej używania, kiedy to możliwe.

Inna sprawa! Wyobraź sobie, że użytkownik dodaje taki helper w sekcji komentarzy pod postem i dodaje złośliwą zawartość w parametrze. Zwracaj uwagę na bezpieczeństwo. Na przykład, jeśli renderujesz cały HTML, możesz być podatny na ataki XSS. Zaleca się kompilowanie i renderowanie Handlebars.js w określonych, zamkniętych obszarach. Możesz użyć biblioteki [cheerio](https://cheerio.js.org/) do parsowania HTML i renderowania Handlebars tam, gdzie to konieczne. Oto przykład, jak możesz się zabezpieczyć, modyfikując poprzedni kod renderowania:

```js
// Renderuj handlebars tylko wewnątrz <div> z id='render'
let htmlContent = proxyResData.toString('utf8');
const $ = cheerio.load(htmlContent);

const container = $('div[id="render"]');
const template = handlebars.compile(container.html());
container.html(template({}));

// Pamiętaj, aby nie zwracać htmlContent;
return $.html();
```

W tym kodzie nasze niestandardowe helpery i Handlebars są renderowane tylko w kontenerze `<div>` z `id='render'`. Więc gdziekolwiek indziej na stronie lub motywie poza tym kontenerem helpery nie będą przetwarzane, wprowadzając znaczące bezpieczeństwo. Nie zapomnij wcześniej zainstalować biblioteki za pomocą `npm install cheerio` i dodać `const cheerio = require('cheerio');` na początku swojego skryptu.

### Asynchroniczne przetwarzanie

Jeśli zamierzasz tworzyć dynamiczne helpery, które zwracają bardziej złożone dane, prawdopodobnie będziesz musiał z czasem zaimplementować asynchroniczne helpery w Handlebars. Jest to przydatne w przypadkach takich jak:

- Pobieranie wartości z bazy danych (np. bazy danych Ghost)
- Wysyłanie żądań API i przetwarzanie ich odpowiedzi

Możesz użyć rozszerzenia o nazwie [handlebars-async-helpers](https://www.npmjs.com/package/handlebars-async-helpers) do tego celu. Umożliwia ono asynchroniczne operacje w Handlebars.js, czyniąc potencjalnie długotrwałe i dynamiczne zadania możliwymi. Oto prosty przykład, jak możesz zaimplementować asynchroniczne przetwarzanie w swoim middleware:

```js
// Zarejestruj asynchroniczne helpery w Handlebars
const hb = asyncHelpers(handlebars);

hb.registerHelper('hello_world', async function (options) {
  // Możesz używać tutaj await!
  // ...
});
```

Pamiętaj, aby dodać inicjalizację biblioteki na początku swojego skryptu: `const asyncHelpers = require('handlebars-async-helpers');`. Jeśli napotkasz problemy z instalacją z powodu konfliktów wersji między `handlebars-async-helpers` a `handlebars`, po prostu obniż wersję `handlebars` do `^4.7.6`. Niestety, biblioteka async helper nie była utrzymywana przez jakiś czas, ale nadal działa w praktyce.

### Komunikacja z bazą danych i obiekty

⚠️ To nie zadziała u wielu dostawców hostingu, w tym 'Ghost Pro', którzy nie udostępniają dostępu do bazy danych klientom.

Jeśli chcesz wykonywać zapytania do bazy danych Ghost, aby na przykład pobrać aktualny post, jest to możliwe i niezbyt trudne. Możesz użyć biblioteki takiej jak [knex](https://knexjs.org/), która jest przejrzystym i szybkim konstruktorem zapytań SQL. Pamiętaj, że będziesz potrzebować `handlebars-async-helpers` do tego. Skonfiguruj `knex` odpowiednio, aby połączyć się z bazą danych Ghost.

Zainicjalizuj `knex` jako zmienną `db` i wypróbuj następujący kod:

```js
// Zwróć tytuł aktualnego posta z bazy danych
hb.registerHelper('post_title', async function (options) {
  const uuid = options.hash.uuid;
  try {
    const { title } = await db("posts")
      .select("title")
      .where("uuid", uuid)
      .limit(1)
      .first();
    return title;
  } catch (error) { return `Error: ${error.message}`; }
});
```

Następnie w szablonie `post.hbs` motywu Ghost dodaj następujący helper:
```
{% raw %}\{{post_title uuid="{{uuid}}"}}{% endraw %}
```
W tym przykładzie {% raw %}`{{uuid}}`{% endraw %} zostanie pobrane i przekazane jako helper dostępny w Ghost, wypełniając pole `uuid` naszego helpera i powodując wyświetlenie tytułu posta przez niestandardowy helper.

Możesz również użyć `axios`, aby wykonywać żądania HTTP do Ghost Content API, ale jest to znacznie wolniejsze niż bezpośrednia komunikacja z bazą danych.

### Wydajność

Wiem, że rozwiązanie oparte na middleware może nie być najlepsze pod względem szybkości, ale osobiście używam tego rozwiązania i nie zauważyłem znaczącego spadku czasu ładowania strony. Średni czas odpowiedzi dla pojedynczego żądania wynosił poniżej 100ms (według `express-status-monitor`), a używam niestandardowego helpera, który na każdej stronie pobiera pewne wartości z bazy danych.

Możesz oczywiście dodać mechanizmy buforowania, aby poprawić wydajność middleware lub użyć alternatywnych rozwiązań zamiast `express-http-proxy`.

### Implementacja architektury

Użyj Dockera lub innego mechanizmu konteneryzacji. Użyłem go w swoim projekcie i działa świetnie. Dodaj obrazy Ghost i bazy danych dla Ghost, Nginx oraz obraz Node.js. Połącz je w wspólną sieć (`driver: bridge`), skonfiguruj odpowiednio Nginx i serwer Node.js — wszystko jest bardzo proste!