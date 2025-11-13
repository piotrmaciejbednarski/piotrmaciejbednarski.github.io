    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {% if page.tags and page.tags.size > 0 %}
    <meta name="keywords" content="{{ page.tags | join: ', ' }}, piotr bednarski, bednarski, piotrmaciejbednarski">
    {% else %}
    <meta name="keywords" content="piotr bednarski, bednarski, piotrmaciejbednarski, bednarski blog, blog piotra bednarskiego">
    {% endif %}
    <meta name="contact" content="{{ site.email }}" />
    <meta name="language" content="en" />
    <meta property="og:type" content="website" />
    <meta property="og:image" content="{{ page.og_image | default: site.default_og_image | absolute_url }}" />
    {% seo title=false %}
    <title>{{ page.title | default: site.title }}</title>
    
    {%- comment -%} hreflang tags for bilingual content {%- endcomment -%}
    {%- if page.layout == "post" and page.lang -%}
        {%- assign current_permalink = page.permalink -%}
        {%- if page.lang == "en" -%}
            {%- assign alt_lang = "pl" -%}
            {%- assign alt_permalink = current_permalink | replace: "/en/blog/", "/pl/blog/" -%}
        {%- elsif page.lang == "pl" -%}
            {%- assign alt_lang = "en" -%}
            {%- assign alt_permalink = current_permalink | replace: "/pl/blog/", "/en/blog/" -%}
        {%- endif -%}
        {%- for post in site.posts -%}
            {%- if post.permalink == alt_permalink -%}
    <link rel="alternate" hreflang="{{ page.lang }}" href="{{ site.url }}{{ current_permalink }}" />
    <link rel="alternate" hreflang="{{ alt_lang }}" href="{{ site.url }}{{ alt_permalink }}" />
    <link rel="alternate" hreflang="x-default" href="{{ site.url }}{{ current_permalink }}" />
                {%- break -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endif -%}
    <link rel="icon" type="image/x-icon" href="/favicon.ico">
    <meta name="theme-color" content="#ffffff">
