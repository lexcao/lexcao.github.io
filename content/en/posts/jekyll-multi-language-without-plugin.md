---
title: Jekyll Multi-Language without Plugin
date: 2019-10-27
tags: [Tutorial, English, Blog]
---

# Goal

* Support multi-language, mainly in English and supplemented by Chinese;
* When visiting pages begin with `/`, e.g. `/about.html`, `/posts/hello-world`, English pages would be  shown;
* When visiting pages began with `/zh/`, e.g. `/zh/about.html`, `/zh/posts/hello-world`, Chinese pages would be shown;
* When visiting `../hello-world` posts, corresponding langugage posts would be jumped via the link;
* Posts which are specified language would only be shown in `archive` and `index` pages.



# Defect

* As `404.html` page was not supported for separate language file, two langugage content would be shown on it at the same time.
* The `jekyll-paginate-v2`, a plugin supports pagination for multi-language, is not supported by GitHub Pages. So the blog has not been supported pagination so far. See details [*below*](#pagination).
* It is a little bit tricky to show date in multi-language way. Some string formatting work should be taken as it is able to have done that but is not a better way. Please see [*Jekyll Date Formatting*](http://alanwsmith.com/jekyll-liquid-date-formatting-examples).



# Setup

Firstly, I found a `i18n` plugin [*Jekyll Multiple Languages Plugin*](https://github.com/kurtsson/jekyll-multiple-languages-plugin).

The number of stars in this plugin is the most among multi-language plugins, and there are many other related multi-language plugins listed. You can use it without hesitate if you don't want to setup custom configuration.

Currently for simplistic and customize, and also omitting unnecessary features in the plugin, I choose to use custom rules to support multi-language.

## 1. Single Post Setting

There are two properties needed to added for every posts and pages 

* `uid` for unique post whose English and Chinese are the same `uid`;
  * Note: `uid` can be declared in any other name, e.g `document_id`.
* `locale` for language symbol which specify what pages should be shown.

So add configuration in `Front Matter` of every posts

```yaml
---
uid: hello-world
locale: zh
---
```



## 2. For Posts

It is very redundant that `locale` has to be added in `Front Matter` every posts at every time. **Do not repeat yourself**. I am going to use different folders to distinguish posts in different languages and set a default value to `locale` in config file.

Create `zh` folder to store Chinese posts in `_posts` directory, which origin `_posts` folder is used to store English posts. When visiting `/zh/posts/some-posts` Chinese pages are shown.

(Of course, follow below to set another `path` to use different directory)

```yaml
defaults:
  - values: #1 
      locale: en
  - scope: #2
      path: _posts/zh/**
      type: posts
    values:
      locale: zh
```

* #1 not set for `scope` means global default: all posts and pages are default to `en`;
* #2 set for `scope` means in the path of `_posts/zh/**`: all posts are default to `zh`.



## 3. For Common String

The common string is such as `Archive` and `About` from menu or `Next Page`.

By the feature of `site.data`, create `locales` folder in `/_data` directory, and create `en.yaml` and `zh.yaml` for storing English and Chinese string.

```yaml
# in /_data/locales/en.yml
menu:
  about: About
  archive: Archive

# in /_data/locales/zh.yml
menu:
  about: 关于
  archive: 归档
```

Replace the old words specified by `locale`

```html
<nav class="menu-content">
  <a href="/about">{{ site.data.locales[page.locale].menu.about }}</a>
</nav>
```



## 4. For Pages

The pages are `archive.html` and `about.html` such `page` type in Jekyll.

As use of `collection`, `_zh` folder need to be created independently in root directory.

```yaml
collections:
  zh: 
    output: true
```

And create corresponding files in `_zh` folder

* `/menu/archive.html`
* `/menu/about.html`



## 5. Language Selector

The selector is a button for switching pages or posts between different `locale`.

Create a new file named `language-selector.html` in `_includes` folder.

Finding corresponding language page from `posts`, `pages` and `collections`.

```html
{% if page.uid %} <!-- #1 -->
<div class="language-selector">
  {% assign postsOrPages = site.posts <!-- #2 -->
    | concat: site.pages  
    | concat: site.zh 
    | where: "uid", page.uid 
    | sort: "locale" %}
  {% for item in postsOrPages %}
  {% unless item.url contains '/page/' %} <!-- #3 -->
  <a href="{{ item.url }}" class="{{ item.locale }}">
    {{ site.data.locales[item.locale].name }} <!-- #4 -->
  </a>
  {% endunless %}
  {% endfor %}
</div>
{% endif %}
```

* #1 Selector is shown only on `uid` existed;
* #2 Concat the list of `posts`, `pages` and `zh` to find the same `uid` pages;
* #3 Filter the pages not in `/pages/` folder;
* #4 Get the common string of language symbol form `locale`



## 6. For Archive Page

The posts should be filtered in specified `locale` language manually in `archive.html`.

There is a convenient method to get the next post by `post.next` which dose not guarantee the same `locale` posts shown in one page. Should do an alternative way

```html
<!-- archive.html -->

<!-- use the index of posts instead of post.next -->
{% assign posts = site.posts | where: "locale", page.locale %}

{% for index in (0..posts.size) limit: posts.size %}
	{% assign post = posts[index] %}
	{% assign prevIndex = index | minus: 1 %}
	{% assign prev = posts[prevIndex] %}

	{% capture year %}{{ post.date | date: '%Y' }}{% endcapture %}
	{% capture prevYear %}{{ prev.date | date: '%Y' }}{% endcapture %}

	{% if year != prevYear or index == 0 %}
		<h3>{{ year }}</h3>
	{% endif %}

	<li itemscope>
  	<a href="{{ post.url }}">{{ post.title }}</a>
  	<p class="post-date"><span>{{ post.date | date: "%B %-d" }}</span></p>
	</li>
{% endfor %}
```

The key point is that using the `index` of posts after filtered by `locale` instead of `post.next`.



## 7. Multi-Language SEO

Create a new page named `language-seo.html` in `_included` folder to specify corresponding language pages by `hreflang`.

```html
{% assign posts = site.posts | where:"uid", page.uid | sort: 'locale' %}
{% for post in posts %}
  <link rel="alternate" hreflang="{{ post.locale }}" href="{{ post.url }}" />
{% endfor %}
```

As well as include in `head.html`.

```html
<!-- Language SEO -->
{% include language-seo.html %}
```



## Lastly
 
Some unimportant and regular configuration are omitted, please to see the [*Source: lexcao.github.io*](https://github.com/lexcao/lexcao.github.io) if you want to learn the full setup.



# References

* [*Jekyll Multiple Language Plugin*](https://github.com/kurtsson/jekyll-multiple-languages-plugin)
* [*Making Jekyll Multilingual*](https://www.sylvaindurand.org/making-jekyll-multilingual/)
* [*Multi Languages with Jekyll*](http://meumobi.github.io/jekyll/2019/06/05/multi-languages-with-jekyll.html)
* [*Deploy A Multi-Language Jekyll Site*](http://meumobi.github.io/jekyll/2019/06/05/multi-languages-with-jekyll.html)
* [*Jekyll-Paginate-V2*](https://github.com/sverrirs/jekyll-paginate-v2/blob/master/README-GENERATOR.md)


# One More Thing

## Support Pagination

The old pagination plugin `jekyll-pagination-v1` is no longer suitable for the short of filtering by the criteria. It is not able to show the one language list of posts on specified language.

Fortunately, `jekyll-pagination-v2` announced to support pagination on multi-language way. As I mentioned above, the [*permitted plugins*](https://pages.github.com/versions/) provided by GitHub Pages does not contain this plugin. Which you need to [*deploy automated manually*](https://jekyllrb.com/docs/deployment/automated/) if you want to use. Here are setup `jekyll-pagination-v2`.

### Gemfile install

```bash
$ gem 'jekyll-paginate-v2'
```

### _config.yaml setup

Note: the configuration of `v2` and `v1` is not compatible.

```yaml
plugins: 
  - jekyll-paginate-v2
  
pagination:
  enabled: true
  per_page: 5
  permalink: /page/:num/
  sort_reverse: true
```

### pages configs

You need add more configuration in `Front Matter` of `index.html` to paginate.

```yaml
# /index.html
---
pagination: 
  enabled: true # yes, enable is needed here
  locale: en
---
```

`pagination.locale` is to specify the criteria of the language according to `locale` of the pages. I use `locale` for my custom rules for multi-language so that the pagination use the same filed for reusable.

Correspondly, create `index.html` in `_zh` folder.

```yaml
# /_zh/index.html
---
permalink: /zh/ # I don't like suffix of .html so do this
pagination: 
  enabled: true
  locale: zh
---
```

Note: I came cross a problem here that the pagination was not working after I put the `index.html` into `_zh` folder, which has not been solved yet.

The temporary solution was to put `zh/index.html` file to the root directory, and renamed to `index_zh.html`.

### paginating

The use of paginating is as same as the `v1` does. Please see [*Pagination*](https://jekyllrb.com/docs/pagination/).

### References

* [Jekyll-Paginate-v2](https://github.com/sverrirs/jekyll-paginate-v2)
* [Jekyll-Paginate-V2 Filter Locales](https://github.com/sverrirs/jekyll-paginate-v2/blob/master/README-GENERATOR.md#filtering-locales)
