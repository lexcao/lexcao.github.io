---
title: 你好 世界
date: 2019-10-01
---

博客配置：

* 静态网页生成器
  * Jekyll 3.8.5
  * Ruby 2.6.0
  * 主题 [lagrange](http://jekyllthemes.org/themes/lagrange/)
* 网页分析
  * Google Aynalysis 
  * Baidu Aynalysis
* 部署
  * GitHub Pages

这是我的第一篇文章，作为最简单的 “你好 世界”，我想记录一下该博客的诞生过程，以及如果你也想搭建一个自己的博客应该怎么做。

本文章将会涉及三个部分：

1. 选择博客类型
2. 准备好所需内容
3. 将他们编排起来



# 第一步 选择博客类型

根据前端网页是否与后台服务器或者数据库交互分为：静态网站 / 动态网站

静态网站：

* 仅依靠 HTML / CSS / JS 
* 没有后台服务器存储数据
* 数据是预先生成的

动态网站：

* 依赖前端 HTML / CSS / JS
* 数据从后台服务器获取
* 能够动态响应用户请求

所以，静态博客：

* 文章预先生成
* 不依赖后台服务器

动态博客：

* 文章从后台服务器获取
* 前端页面动态获取

考虑到刚接触到博客搭建，先从简单的静态博客入手。目前 GitHub 上有很多开源的静态网站生成器，这里我选择使用 `Jekyll`。

选择合适的静态博客生成器请看 [*Jekyll / Hugo / Hexo 比较*]({{ "/zh/posts/jekyll-hugo-hexo" | relative_url }})。

# 第二步 准备好所需内容

准备内容涉及以下方面：

1. 博客文章
2. 博客介绍
3. 作者信息
4. 博客域名

## 博客文章

提前写好文章准备发布

1. GitHub Pages 部署记录（本文 😆）
2. [*Jekyll 不使用插件支持多语言*]({{ "/zh/posts/jekyll-multi-language-without-plugin" | relative_url }})（本博客是中文和英文 😆）
3. [*Jekyll / Hugo / Hexo 比较*]({{ "/zh/posts/jekyll-hugo-hexo" | relative_url }})（本博客用 Jekyll 😆）
4. 如何选择一个英文名（Lex Cao 😆）



## 博客介绍

提前写好博客介绍，博客创建初期可以只包含简略信息，以后再慢慢补充，

详细请看 [关于]({{ "/zh/menu/about.html" | relative_url }})。



## 作者信息

### 笔名

这里我给自己取了一个英文名 `Lex Cao`

取英文名可以参考 [如何选择一个英文名]()

### 博客名

中文名 `代码笔记`

英文名 `CodingNotes`



## 博客域名

`caolixin.com` 中文拼音没实际意义

`lexcao.com` 已经被占用

`thecodingnotes.com` 好像不错，但是有点长



# 第三步 编排起来

## Jekyll

### 安装

相关参考链接

* [*Install on MacOS*](https://jekyllrb.com/docs/installation/macos/)
* [*Jekyll with Bundle*](https://jekyllrb.com/tutorials/using-jekyll-with-bundler/)
* [*Creating a GitHub Pages with Jekyll*](https://help.github.com/en/articles/creating-a-github-pages-site-with-jekyll)

使用到的命令

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

# serve with bundle
$ bundle exec jekyll serve
```

### 主题选择

关于主题，我比较喜欢简约一点。

在相关主题浏览网站：

* [*jekyllthemes.org/*](http://jekyllthemes.org/)
* [*jekyllthemes.io/*](https://jekyllthemes.io/)

找到的心仪的主题：

* [*Lagrange*](http://jekyllthemes.org/themes/lagrange/)
* [*Chalk*](http://jekyllthemes.org/themes/chalk/)
* [*Type*](http://jekyllthemes.org/themes/type/)
* [*Kikofri*](http://jekyllthemes.org/themes/Kikofri/)

选出以上 4 个主题，最后使用 `lagrange` 作为博客主题。

### 插件说明

* GitHub Pages 集成 Jekyll 实现**自动部署**需要插件 `github-pages`。该插件仅允许使用白名单内插件，具体请看[允许插件及版本](https://pages.github.com/versions/)；
* 要想使用自定义插件（白名单以外的插件），不能 GitHub Pages 的自动部署功能，需要将 `_site` 目录放到仓库上，手动实现[自动部署](https://jekyllrb.com/docs/deployment/automated/)；
* 本次是第一次搭建博客，所以选用了 GitHub Pages 的自动部署。

### 多语言配置

多语言配置，需要折腾的地方比较多，详细请看文章

[Jekyll 不使用插件支持多语言]()。


## 部署到 GitHub Pages

[官方教程](https://help.github.com/en/articles/getting-started-with-github-pages)

### 创建一个仓库

仓库名需要按照固定格式 `<user>.github.io`

如：`lexcao.github.io`

### 将文章推到 GitHub

```bash
# 添加远程仓库
$ git remote add origin https://github.com/lexcao/lexcao.github.io.git
$ git push -u origin master
```

### 网站已可以访问

进入仓库设置页面 `Settings` > `Options` > 拉到最下面，

`Your site is published at https://lexcao.github.io/` 博客已经发布成功。

访问 [*https://lexcao.github.io/*](https://lexcao.github.io/) 即可看到。

可以在 [*environment*](https://github.com/lexcao/lexcao.github.io/deployments) 看到博客部署情况，默认配置是 `master` 分支有代码更新会进行自动部署。



## 网站统计

博客可以访问以后，就可以开始接入网站统计相关功能，借助第三方平台。

### Google Analytics

1. 在 [*Google Analytics*](https://analytics.google.com) 创建媒体资源，拿到一个 `UA-xxx-x` ID，并且引入统计代码；
2. 在 [*Google Tag Manager*](https://tagmanager.google.com) 创建跟踪代码，根据上面拿到的 `UA-xxx-x` ID 新增一个 `Google Analytics` 代码跟踪，引入全局统计代码，并发布。
3. 可选择，在 `Google Analytics` 关联 [*Google Search Console*](https://search.google.com/search-console)。

注意事项：

1. `Google Tag Manager` 不允许变量为中文名;
2. 重新发布 GitHub Pages 生效后，如果请求 `js` 文件 `net::ERR_BLOCKED_BY_CLIENT` 错误，关掉广告拦截插件重试。

### Baidu Analytics

在 [百度统计](https://tongji.baidu.com/) 关联上网页，引入统计代码，完成配置。

实时性比 Google 稍微差一点（可能是 `github.io` 这个域名在国外的原因）


# 结语

至此，整个博客已经完美运转了，可以开始专心写文章了 😊。
