---
title: Jekyll 不使用插件支持多语言
date: 2019-10-26
---

# 实现目标 

* 支持多语言，英文为主，中文为辅；
* 当访问 `/` 根目录下页面，比如 `/about.html` `/posts/hello-world` 显示英文页面；
* 当访问 `/zh/` 目录下页面，比如 `/zh/about.html` `/zh/posts/hello-world` 显示中文页面；
* 当访问 `../hello-world` 文章时，可以通过链接跳转到对应语言页面；
* `archive` 和 `index` 页面中仅显示出当前语言页面。

# 相关缺陷

* 404 页面无法配置，只能在 `404.html` 页面写上两种语言；
* 支持多语言文章的分页插件 `jekyll-paginate-v2` 没在 GitHub Pages 支持的插件白名单内，目前本博客首页不支持分页。多语言分页详见[下文](#paginate)；
* 多语言时间表示有点麻烦，需要做一些字符串处理工作，能实现但是不太优雅，具体可以参考 [*Jekyll-Date-Formatting*](http://alanwsmith.com/jekyll-liquid-date-formatting-examples)。

# 开始配置

最初，我搜索到 `i18n` 插件 [*Jekyll-Multiple-Languages-Plugin*](https://github.com/kurtsson/jekyll-multiple-languages-plugin)。

该仓库的 Star 数是多语言插件中最多的，同时里面也列出了相关其他多语言插件，已经比较完善，不想折腾的可以直接使用。

目前我为了简单和可定制化，同时省略掉插件中不必要的功能，选择使用自定义规则来实现多语言功能。

## 1. 单个博文配置

每一篇文章和页面需要定义两个属性：

* `uid` 标示文章唯一，一篇文章的中文版本和英文版本 `uid` 相同；
  * 注意：`uid` 可以设置为任意命名，比如 `document_id` 。
* `locale` 标示文章语言，一篇文章被渲染后作为哪种语言展示。

所以每篇文章的 `Front Matter` 新增如下设置

```yaml
---
uid: hello-world
locale: zh
---
```

## 2. 对于文章 posts

每篇文章都需要在 `Front Matter` 中写上 `locale` 重复多余。**不要重复自己**。我准备使用不同文件夹来区分不同语言的文章，然后在配置文件设置 `locale` 的默认值。

在 `_posts` 目录下创建 `zh` 文件夹用于存放中文文章。当访问 `/zh/posts/xxx` 时即展示中文页面。

（当然，也可以设置不同的目录，参照以下配置进行设置不同的 `path` ）

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

* #1 未指定 `scope` 全局默认：所有文章 `posts` 和页面 `pages` 默认 `en`；
* #2 指定 `scope` 路径 `_posts/zh/**` 下 `posts` 类型：`zh`。

## 3. 对于页面中通用的字符串

导航栏中 `归档` `关于` 或者 `下一页` 等这样的通用字符串。

使用 `site.data` 功能来实现，在 `/_data` 目录下创建 `locales` 文件夹，并分别创建 `en.yml` 和 `zh.yml` 用于存放英文和中文字符串。

```yaml
# /_data/locales/en.yml 文件中
menu:
  about: About
  archive: Archive

# /_data/locales/zh.yml 文件中
menu:
  about: 关于
  archive: 归档
```

配置好这些字符串后，在需要替换文字的地方使用

```html
<nav class="menu-content">
  <a href="/about">{{ site.data.locales[page.locale].menu.about }}</a>
</nav>
```

## 4. 对于页面 pages

一些通用页面：`archive.html` `about.html` 等 `pages` 类型。

单独在项目根目录下创建一个文件夹 `_zh`，并作为 `collection` 来配置

```yaml
collections:
  zh: 
    output: true
```

在 `_zh` 文件夹下创建对应页面

* `/menu/archive.html`
* `/menu/about.html`

## 5. 语言选择器

用于在不同语言的文章或页面中根据 `locale` 进行切换。

在 `_includes` 文件夹下添加一个新文件 `language-selector.html`。

遍历 `posts`、 `pages` 和 `collections` 找到相应的语言页面

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

* #1 仅在有 `uid` 的页面显示语言选择器
* #2 拼接 `posts` `pages` `zh` 数组，找到 `uid` 对应的页面，根据 `local` 排序
* #3 过滤掉 `/pages/` 目录下页面
* #4 拿到 `locale` 对应的语言文字，如 `EN` `中`

## 6. 归档页面

需要手动多虑掉非本语言页面的文章。

`post.next` 提供便捷获取下一篇文章的方法，但是在多语言文章中无法保证 `locale` 的一致性，需要作出如下修改

```html
<!-- archive.html -->

<!-- 使用 posts 的下标，而不用 post.next -->
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

核心思想：先根据 `locale` 过滤，遍历的时候使用下标而不是 `post.next`。

## 7. 多语言 SEO

在 `_includes` 文件夹下面创建一个新页面 `language-seo.html`。

通过 `hreflang` 指示对应的语言


```html
{% assign posts = site.posts | where:"uid", page.uid | sort: 'locale' %}
{% for post in posts %}
  <link rel="alternate" hreflang="{{ post.locale }}" href="{{ post.url }}" />
{% endfor %}
```

并且在 `head.html` 引用

```html
<!-- Language SEO -->
{% include language-seo.html %}
```

## 最后

我省略了一些不重要的常规配置，源码请看 [*GitHub: lexcao.github.io*](https://github.com/lexcao/lexcao.github.io)

# 相关参考链接

* [*Jekyll Multiple Language Plugin*](https://github.com/kurtsson/jekyll-multiple-languages-plugin)
* [*Making Jekyll Multilingual*](https://www.sylvaindurand.org/making-jekyll-multilingual/)
* [*Multi-Languages-with-Jekyll*](http://meumobi.github.io/jekyll/2019/06/05/multi-languages-with-jekyll.html)
* [*Deploy A Multi-Language Jekyll Site*](http://meumobi.github.io/jekyll/2019/06/05/multi-languages-with-jekyll.html)
* [*jekyll-paginate-v2*](https://github.com/sverrirs/jekyll-paginate-v2/blob/master/README-GENERATOR.md)

# 另一件事

## 多语言支持分页

旧的分页插件 `jekyll-pagination-v1` 无法根据筛选条件过滤已经不再适合，不能在对应的语言页面显示对应的语言文章列表。

如果想在多语言下支持分页，可以使用 `jekyll-pagination-v2`。我上面提到过 Github Pages 插件 [白名单列表](https://pages.github.com/versions/) 不支持该插件，如果需要使用就需要 [手动实现部署](https://jekyllrb.com/docs/deployment/automated/)。以下是如何配置使用 `jekyll-pagination-v2`

### Gemfile 安装

```bash
$ gem 'jekyll-paginate-v2'
```

### _config.yml 配置

注意：`v2` 和 `v1` 的配置不兼容，需要按照如下配置做相应修改

```yaml
plugins: 
  - jekyll-paginate-v2
  
pagination:
  enabled: true
  per_page: 5
  permalink: /page/:num/
  sort_reverse: true
```

### pages 页面配置

首页 `index.html` 进行分页，需要添加如下配置

```yaml
# /index.html
---
pagination: 
  enabled: true # 是的，这里还需要再次开启一次
  locale: en
---
```

`pagination.locale` 此处用来配置分页筛选条件，根据页面的 `locale` 字段进行过滤。这也是我在 `Front Matter` 用 `locale` 字段来标志语言的原因，复用。

对应的，在 `_zh` 文件夹下面创建中文首页 `index.html`。

```yaml
# /_zh/index.html
---
permalink: /zh/ # 此处是为了让首页不显示 .html 后缀
pagination: 
  enabled: true
  locale: zh
---
```

注意：我在这里配置的时候，遇到一个问题，当我把 `index.html` 放到 `_zh` 文件夹后，分页 `locale` 筛选不起作用，目前还没解决。

临时解决方案是将 `zh/index.html` 放在根目录，并改名为 `index_zh.html`。

### 分页使用

使用没有变化，和 `v1` 一样的使用方式，详细请看 [*Pagination*](https://jekyllrb.com/docs/pagination/)

### 相关参考链接

* [Jekyll-Paginate-v2](https://github.com/sverrirs/jekyll-paginate-v2)
* [Jekyll-Paginate-V2 Filter Locales](https://github.com/sverrirs/jekyll-paginate-v2/blob/master/README-GENERATOR.md#filtering-locales)

