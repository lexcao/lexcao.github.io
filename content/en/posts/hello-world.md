---
title: Hello World
date: 2019-10-01
tags: [Tutorial, Blog]
---

# Hello World

Blog configuration:

* Static Website Generation
  * Jekyll 3.8.5
  * Ruby 2.6.0
  * [Lagrange](http://jekyllthemes.org/themes/lagrange/) theme
* Website Aynalysis
  * Google Analysis
  * Baidu Analysis
* Deployment
  * GitHub Pages

This is my first post, which I would like to note the beginning of the blog as the simplest "hello world" and how to build such blog by yourself.

The article will contain three steps:

1. Choose type of blog
2. Prepare something needed
3. Compose them

# Step 01 Choose Type of Blog

There are static websites and dynamic websites depending on whether the frontend web page interacts with the backend server or database.

Static websites:

* Just HTML / CSS / JS
* No backend server storing data
* Data is pre-generated

Dynamic websites:

* Apply with HTML / CSS / JS
* Fetching data from backend server
* Response user requests dynamically

So, static blog is:

* Posts are pre-generated
* No need for backend server

While dynamic blog is:

* Posts are fetching from backend server
* Fetching occurs in frontend dynamically

Considering this is my first blog building, I choose simple static blog. And I choose `Jekyll` for static website generator as there are so many open source static website generator so far.

To choose appropriate static website generator, please see 

[*Jekyll / Hugo / Hexo Static Comparision*]({{ "/posts/jekyll-hugo-hexo" | relative_url }}).





# Step 02 Prepare Something Needed

Preparation needs 4 parts below:

1. Blog articles;
2. Blog introduction;
3. Author information;
4. Blog domain.

## Several Articles to Post

Several articles should be written and ready to post in advance.

1. *GitHub Pages Deployment Notes* (this article 😆);
2. [*Jekyll Supports Multiple Language without Plugin*]({{ "/posts/jekyll-multi-language-without-plugin" | relative_url }}) (this blog supports English and Chinese 😆);
3. [*Jekyll / Hugo / Hexo Comparision*]({{ "/posts/jekyll-hugo-hexo" | relative_url }}) (this blog  use Jekyll 😆);
4. [*Choose An English Name*]({{ "/posts/choose-english-name" | relative_url }}) (mine is Lex Cao 😆).

## Blog Introduction

Write a `about.html` page in advance which only contains brief information. And add more details in the future.

Detail page, please see [*Abount Me*]({{ "/menu/about.html" | relative_url }})

## Author Information

### Pen name

I choose an English name for myself, `Lex Cao`.

To Choose an English name, please see [*How to choose an English name*]().

### Blog name

English name is `CodingNotes`.

Chinese name is `代码笔记`.

## Blog Domain

`caolixin.com` The Chinese PinYin of my Chinese name with no meaning.

`lexcao.com` Pretty good but already taken.

`thecodingnotes.com` Just ok, and a little bit long.

So, I would keep it for `lexcao.github.io` until a better domain found.



# Step 03 Compose them

## Jekyll

### Install

Relative links:

* [*Install on MacOS*](https://jekyllrb.com/docs/installation/macos/)
* [*Jekyll with Bundle*](https://jekyllrb.com/tutorials/using-jekyll-with-bundler/)
* [*Creating a GitHub Pages with Jekyll*](https://help.github.com/en/articles/creating-a-github-pages-site-with-jekyll)

Used commands:

```bash
# install ruby 2.6.0+
$ xcode-select --install
$ brew install ruby
$ export PATH=/usr/local/opt/ruby/bin:$PATH
$ source ~/.zshrc

# install jekyll & bundler
$ gem install --user-install bundler jekyll
$ export PATH=$HOME/.gem/ruby/2.6.0/bin:$PATH
$ source ~/.zshrc

# init
$ cd /blogs/github-pages-jekyll
$ git init
$ jekyll new .
$ jekyll serve
```

### Theme

Regarding the theme, I would rather be simpler.

Usefull theme gallery: 

* [*jekyllthemes.org/*](http://jekyllthemes.org/)
* [*jekyllthemes.io/*](https://jekyllthemes.io/)

Find liked theme:

* [*Lagrange*](http://jekyllthemes.org/themes/lagrange/)
* [*Chalk*](http://jekyllthemes.org/themes/chalk/)
* [*Type*](http://jekyllthemes.org/themes/type/)
* [*Kikofri*](http://jekyllthemes.org/themes/Kikofri/)

`Lagrange` was the selected theme over 4 themes above finally.

### Plugin Notice

* `github-pages` plugin is needed to automated deployment when GitHub Pages integration Jekyll, which some white-list plugins are limited while deploying. See [*Permit plugins with versions*](https://pages.github.com/versions/);
* The method to use more plugins (not in the white-list) is to push `_site` folder to the repository other than automated deplyment by Github Pages and to [*auto deploy*](https://jekyllrb.com/docs/deployment/automated/) manually.
* I would like to use automated deployment by Github Pages because of the first blog.



### Multiple Language Setting

There are many tricks need to be set, please see

[*Jekyll Supports Multiple Language without Plugin*]().



## Deploy on GitHub

[*Ofiicial tutorial*](https://help.github.com/en/articles/getting-started-with-github-pages)

### Create a Repository

The name of repository should be a fixed pattern `<user>.github.io`.

For example, `lexcao.github.io`

### Push articles to GitHub

```bash
# add remote repository
$ git remote add origin https://github.com/lexcao/lexcao.github.io.git
$ git push -u origin master
```

### It is Ready for Visiting

Go to the settings of the repository `Settings` > `Options` > scroll down to bottom.

If you can see *`Your site is published at https://lexcao.github.io/`* the blog success publishing.

Visit [*https://lexcao.github.io*](https://lexcao.github.io/) to see the website

On repository page, there is a easy way to see every time deployments from [*environment*](https://github.com/lexcao/lexcao.github.io/deployments), which automated deployment is triggered by pushing to `master` branch by default.



## Website Analystic

### Google Analytics

1. Create a media resource from [*Google Analytics*](https://analytics.google.com) to get track ID `UA-xxx-x` and include the tracking code.
2. Create a tracking code in [*Google Tag Manager*](https://tagmanager.google.com), add a `Google Analytics` code tracking based on the `UA-xxx-x` ID you got above, include the global tracking code and pubish.
3. Optional, associate to [*Google Search Console*](https://search.google.com/search-console) with `Google Analytics.

Notice:

1. Variable name of Chiese is not allowed in `Google Tag Manager`;
2. If there is `net::ERR_BLOCKED_BY_CLIENT` error on requesting `js` file after GitHub Pages re-deployment, refresh page without ad block extensions would solve the problem.

### Baidu Analytics

To install tracking of Baidu is much easier, registration then including the code on [*Baidu Analytics*](https://tongji.baidu.com/) page.

Real-time performance is slightly worse than `Google Analytics` (probably the reason why the domain name `github.io` is abroad)



# Done

So far, the entire blog has been running perfectly. It is time to concentrate on writing articles 😊.
