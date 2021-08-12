---
title: Jekyll / Hugo / Hexo Comparison
date: 2019-10-29
tags: [Tutorial, Blog]
---

It is hard to choose a suitable static website generator, especially when you want to build website like blog for the first time. This is my first time to build a blog and have not enough time to go through some popular generators, which I have chosen `Jekyll` at the beginning but it is not a best one. In the future I am going to try another generators.

Here is some brief information I found from Google and hope it should be useful for you to decide starting up on what generator.

I have selected three generators from GitHub, which are

* [*Jekyll*](https://jekyllrb.com/)
* [*Hugo*](https://gohugo.io/)
* [*Hexo*](https://hexo.io/)

# WHAT is Static Website Generator

1. HTML files;
2. no server side processing or database communication;
3. more secure than any dynamic website;
4. super scaling when used with CDN;
5. caching will bring more effective than dynamic pages;
6. super fast to require.



# [*Jekyll*](https://jekyllrb.com/)

* built in **Ruby**;
* supported by **GitHub**;
* use **GitHub Pages** for free to host.

## Pros

1. free and open source;
2. RubyGems supports to build themes as gems;
3. easy and simple to use;
4. great GitHub Pages support;
5. comes with default and decent minimal theme out of box.

## Cons

As your website content grows, the build process becomes significantly slower.

## Feature

* `Liquid` template engine;
* `Gem` based themes;
* `Markdown` and `YAML` format support;
* `Sass` pre-processing customize;
* `CoffeeScript` support by official plugin.



# [*Hugo*](https://gohugo.io)

* built in **Go**.

## Pros

1. free and open source;
2. speed, fast speed, engineered and optimized for speed;
3. many built-in support;
   1. dynamic API driven content;
   2. unlimited content types;
   3. shortcakes, a flexible alternative to Markdown;
   4. i18n;
   5. redirection with aliases;
   6. pagination.
4. pre-made Go templates and patterns;
5. dependency free (no need Go installed, bc it's pre-compiled binary);
6. powerful content model.

## Cons

1. themes use Go templates so need to be familiar with Go;
2. no ship with default theme;
3. lack for extensibility and plugins(because Go is compiled language).

## Features

* `Go` template;
* `i18n`;
* supporting dynamic `API`;



# [*Hexo*](https://hexo.io)

* built in **Node.js**.

## Pros

* also fast;
* easy to deploy on GitHub Pages;
* Chinese (maybe cons for non-Chinese);
* Chinese community.

## Cons

* non-English.

## Features

* `EJS` template engine;
* supporting `Chinese`;
* friendly with `HTML + CSS + Javascript`.

# I am using

**Jekyll**

## What I like

1. Huge number of free themes and plugins;
2. There are many tutorial for the beginners;
3. Deploy on GitHub Pages without any skills.

## What I dislike

1. It is not supported by GitHub Pages to many plugins;
2. I18n is not supported.



By the way, the build speed is not considered for me because of the small count of articles at the moment, which I might change to other generator when it becomes slightly slow on building with Jekyll in the future.

The rank of speed among three generators are `Hugo > Hexo > Jekyll`.

The next generator would be `Hugo` in the future and I would update this post.



# References

* [How to Choose the Right Static Generator: Jekyll vs. Hugo vs. Hexo](https://www.techiediaries.com/jekyll-hugo-hexo/)
* [*Static Gen*](https://www.staticgen.com/)
