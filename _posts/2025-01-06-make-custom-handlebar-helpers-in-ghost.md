---
title: Make Custom Handlebar Helpers in Ghost
description: How to extend Ghost themes with custom Handlebars helpers, both by modifying the source code and without it.
layout: post
lang: en
date: 2025-01-06
permalink: /en/blog/make-custom-handlebar-helpers-in-ghost/
og_image: /assets/img/embed.png
tags:
  - Ghost
  - Handlebars
  - Web Development
  - JavaScript
  - Theming
---

This article is for many developers and theme creators who find the standard helpers offered by [Ghost](https://ghost.org/docs/themes/helpers/) insufficient. It is completely normal to look for ways to extend the capabilities of our themes that use Handlebars provided by Ghost. Before publishing this article and finding a solution for my theme, I searched the entire internet and conducted an analysis of Ghost's source code myself.

## Method 1 (modifying core code)

I discovered that it is possible to extend Ghost's source code with additional helpers. I achieved this by adding a new directory in `current/core/frontend/apps`. I used the example of an existing “app” called `amp`, whose code is very simple, to start creating a new helper available in the theme. In these existing apps, the structure is straightforward because helpers are registered in `lib/helpers`. At the end of the process, you need to add the name of your directory in `apps` to `current/core/shared/config/overrides.json` in the `apps.internal` JSON section.

An example content of the `index.js` file in our app would be:

```js
const path = require('path');

module.exports = {
    activate: function activate(ghost) {
        ghost.helperService.registerDir(path.resolve(__dirname, './lib/helpers'));
    }
};
```

Next, in the `lib` directory of this app, we create a folder named `helpers`. Inside, we create a new file, which will be the name of the helper to be called in a Handlebars template. For example, let's name it `uppercase.js`.

Below is an example of such a helper's code, which simply converts the letters of the given text in the helper argument to uppercase:

```js
// sorry for hardcoded path, but it works
// use `module-alias` to avoid this
const {SafeString, escapeExpression} = require('../../../../services/handlebars');

module.exports = function uppercase(text) {
    return text.toUpperCase();
};
```

Don't forget to add the name of the application directory to `current/core/shared/config/overrides.json`. After restarting Ghost, everything should be ready.

## Method 2 (without modifying core code)

I recently developed this method, and you can apply it not only on self-hosted Ghost but also on Ghost instances offered by hosting providers. In the latter case, it requires appropriate architectural planning and purchasing a small server that will act as a proxy for your final Ghost instance.

**The architecture we will use in this method:**
Nginx server ← Node.js middleware ← Ghost instance

The user's browser sends a request to the Nginx server, which contains the upstream of middleware. All requests, regardless of location, will be proxied to the middleware.

The middleware is an Express server running in Node.js with the added [express-http-proxy](https://github.com/villadora/express-http-proxy) library, which significantly simplifies the work. We configure the proxy to communicate with the Ghost instance. The **express-http-proxy** library has a `userResDecorator` property that we can use to "decorate the response of the proxied server". We can modify the response from Ghost before sending it to the user's browser.

Our `userResDecorator` will be asynchronous so as not to block the main thread. We’ll return to the topic of asynchronous processing when creating helpers. For now, you need to know that not everything the user's browser requests needs to be decorated. Therefore, the first step will be to check the `content-type` header of the response from Ghost. You can do this as follows and then compare if it is `text/html` to decorate only HTML documents returned to the user:

```js
// Where 'proxyRes' is your proxy response inside 'userResDecorator'
const contentType = proxyRes.headers['content-type'] || '';
if (!contentType.includes('text/html')) {
    // Return original content if response is not 'text/html'
    return proxyResData;
}

let htmlContent = proxyResData.toString('utf8');
// Do something with 'htmlContent' and return
return htmlContent;
```

In this conditional statement, we can start modifying `htmlContent`, but why do we need it? Let’s start by building the foundation for our custom helper in the Ghost theme!

In this article, I will create a custom helper in the `index.hbs` file (homepage) of my theme. In a visible location in the Handlebars template, I add an example custom helper, naming it {% raw %}`{{hello_world}}`{% endraw %}.

⚠️ Then, I place it in a visible spot on the homepage — but notice what happens when I refresh the Ghost page!

```html
{% raw %}{{!< default}}{% endraw %}
<div class="gh-container">
  <h1>Ghost homepage</h1>
  {% raw %}<p>{{hello_world}}</p>{% endraw %}
</div>
```

After refreshing, I get an error message from Ghost because the {% raw %}`{{hello_world}}`{% endraw %} helper doesn’t exist in Ghost's default helpers. For our logic to work, we must escape this helper so that it’s not treated as a helper by Ghost’s built-in Handlebars.

The **correct way** is to write this helper as {% raw %}`\{{hello_world}}`{% endraw %}. This way, Ghost treats it as plain text. After refreshing the Ghost homepage, you should see the plain text {% raw %}`{{hello_world}}`{% endraw %}. If this happens, you are on the right track. Let’s now return to the middleware server file, where we will use the response decorator.

⚠️ Remember to escape custom helpers in your theme! Don’t forget to add the `\` character.

```js
let htmlContent = proxyResData.toString('utf8');
```

In this variable, we have the response from the Ghost instance as the full HTML of the page. Imagine that this response is the homepage of your Ghost instance. The HTML content will also include our plain text {% raw %}`{{hello_world}}`{% endraw %}, which is displayed as plain text. If our custom helper is in this form, we can compile it using [Handlebars.js](https://handlebarsjs.com/) in our middleware. Remember to install the library first via a package manager, e.g., npm: `npm install handlebars` and add it to your code: `const handlebars = require("handlebars");`.

```js
// Compile response HTML with Handlebars, and return rendered template
let htmlContent = proxyResData.toString('utf8');
const template = handlebars.compile(htmlContent);
htmlContent = template({});
```

Wow! We now have compiled and rendered HTML using Handlebars.js — but we’re not done yet. We still need to register our custom helper {% raw %}`{{hello_world}}`{% endraw %}. Add the following code, preferably after initializing Handlebars.js:

```js
// Returns 'Hello from middleware!' with the current timestamp
handlebars.registerHelper('hello_world', function (options) {
   return `Hello from middleware! ${new Date().toISOString()}`;
});
```

After restarting the middleware server and registering the above helper, you should see the rendered helper in the browser with the text returned by our helper and the current date and time.

At this stage, you can extend your Ghost theme with additional custom helpers, which you will add to the middleware server code.

### Security

At some point, you may want to return various things with your helpers. By default, the library protects against XSS attacks, but when you use the `SafeString` method, this protection stops working. Avoid using it whenever possible.

Another thing! Imagine a user adds such a helper in the comments section under a post and adds malicious content in the parameter. Be mindful of security. For example, if you render every HTML completely, you could be vulnerable to XSS attacks. It’s recommended to compile and render Handlebars.js in specific, closed areas. You can use the [cheerio](https://cheerio.js.org/) library for parsing HTML and rendering Handlebars where necessary. Here’s an example of how you can secure yourself by modifying the previous rendering code:

```js
// Render handlebars only inside <div> with id='render'
let htmlContent = proxyResData.toString('utf8');
const $ = cheerio.load(htmlContent);

const container = $('div[id="render"]');
const template = handlebars.compile(container.html());
container.html(template({}));

// Remember to not return htmlContent;
return $.html();
```

In this code, our custom helpers and Handlebars are rendered only within a `<div>` container with `id='render'`. So, anywhere else on the webpage or theme outside this container, helpers will not be processed, introducing significant security. Don’t forget to install the library beforehand with `npm install cheerio` and add `const cheerio = require('cheerio');` at the start of your script.

### Asynchronous Processing

If you intend to create dynamic helpers that return more complex data, you’ll probably need to implement asynchronous helpers in Handlebars over time. This is useful in cases like:

- Fetching values from a database (e.g., Ghost database)
- Sending API requests and processing their responses

You can use an extension called [handlebars-async-helpers](https://www.npmjs.com/package/handlebars-async-helpers) for this purpose. It enables asynchronous operations in Handlebars.js, making potentially lengthy and dynamic tasks possible. Here’s a simple example of how you can implement asynchronous processing in your middleware:

```js
// Register async helpers with Handlebars
const hb = asyncHelpers(handlebars);

hb.registerHelper('hello_world', async function (options) {
  // You can use await's here!
  // ...
});
```

Remember to add the library initialization at the start of your script: `const asyncHelpers = require('handlebars-async-helpers');`. If you encounter issues installing it due to version conflicts between `handlebars-async-helpers` and `handlebars`, simply downgrade `handlebars` to `^4.7.6`. Unfortunately, the async helper library hasn’t been maintained for a while, but it still works in practice.

### Database Communication and Objects

⚠️ This won't work on many hosting providers, including 'Ghost Pro' which don't share database access with customers.

If you want to make database queries in Ghost to fetch, for example, the current post, it’s possible and not difficult. You can use a library like [knex](https://knexjs.org/), which is a clear and fast SQL query builder. Remember that you’ll need `handlebars-async-helpers` for this. Configure `knex` properly to connect to Ghost’s database.

Initialize `knex` as the `db` variable and try the following code:

```js
// Return current post title from database
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

Then, in the `post.hbs` template of the Ghost theme, add the following helper:
```
{% raw %}\{{post_title uuid="{{uuid}}"}}{% endraw %}
```
In this example, {% raw %}`{{uuid}}`{% endraw %} will be retrieved and passed as a helper available in Ghost, filling the `uuid` field of our helper and causing the post title to be displayed by the custom helper.

You can also use `axios` to make HTTP requests to the Ghost Content API, but this is significantly slower than direct database communication.

### Performance

I know that a middleware-based solution might not be the best in terms of speed, but I personally use this solution and haven’t noticed a significant drop in page load times. The average response time for a single request was under 100ms (according to `express-status-monitor`), and I use a custom helper that retrieves some values from the database on every page.

You can, of course, add caching mechanisms to improve middleware performance or use alternative solutions instead of `express-http-proxy`.

### Implementation of Architecture

Use Docker or another containerization mechanism. I’ve used it in my project, and it works great. Add Ghost and database images for Ghost, Nginx, and a Node.js image. Connect them to a shared network (`driver: bridge`), configure Nginx and the Node.js server accordingly — it’s all very simple!