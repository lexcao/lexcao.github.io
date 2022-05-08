---
title: 通过构建全栈待办应用学习 Rust
date: 2022-05-02
tags: [Rust, Practice]
---

# 什么

我想写一篇关于我如何学习Rust的博客。

请原谅我在 2022 年才开始学习这个伟大的编程语言。

为了在实践中学习Rust，我构建了一个全栈待办应用。

你可以在 [这里](https://todos.lexcao.io/) 尝试。相关源码可以在 [GitHub](https://github.com/lexcao/rust_fullstack_todo) 上找到。

现在，我准备写一下它是如何构建的。

# 如何

首先，和大家一样，我也是从 [The Book](https://doc.rust-lang.org/book/) 中学习 Rust。这是一本不应该跳过入门学习 Rust 的好书。

在学习了一些基本的语法之后，我尝试从零开始使用 Rust 构建一个全栈应用，这是一个使用 Rust tokio 的后端服务和一个使用 [Rust WASM（Web Assembly）](https://rustwasm.github.io/docs/book/)的前端页面。

我将分别对这两部分做一个简单的介绍。

### 后端

后台服务是一个的简单的 REST API。使用 [`actix-web`](https://github.com/actix/actix-web) 作为网络框架。

- 我将写另一篇博客，介绍我如何使用 TDD 开发 Rust 后台服务。
- 被 Rust 编译器和 Borrow Checker 教育是一次特别的体验。

对于部署，我使用 [Supabase](https://supabase.com/) 作为 Postgres 服务，使用 [Railway](https://railway.app/) 来运行后台服务 docker 镜像。

### 前端

前端页面有在线和离线数据源，在线是从后台服务器获取数据，而离线是在本地存储。并且有一个按钮来切换它们。

前台由 Rust WASM 和 [`yew`](https://github.com/yewstack/yew) 框架驱动，这是一个类似 React 基于组件构建 Web 应用框架。

- 如果你熟悉 JSX，你可以在使用 Yew 时感到很自在。
- 在 Rust 中编写类似 React 的代码体验良好，而且真的很有趣。
- 但有一些不同之处我想与大家分享，晚点会写一篇博客来谈这个问题，所以敬请关注。

部署的话，是放在 [Vercel](https://vercel.com/) 上进行托管，用 GitHub Action 来实现自动部署。

# 结果

全栈 Rust 的好处之一是共享代码。通过使用 Cargo workspace 功能后端和前端可以共享这个公共包。其中包含了两边都可以使用的 requests 和 models。后端代码在集成测试的时候进行了测试，所以前端代码可以直接使用它而不需要额外测试和编码。

整个开发体验的话就是所有 Rust 代码和一些少量 CSS。整体感觉不错。

非常感谢 Rust 编译器，它是学习 Rust 的一位好老师。

# 相关引用

- [源码](https://github.com/lexcao/rust_fullstack_todo)
- [Rust](https://www.rust-lang.org/)
- [The Book](https://doc.rust-lang.org/book/)
- [WASM](https://rustwasm.github.io/docs/book/)
- [actix-web](https://github.com/actix/actix-web)
- [yew](https://github.com/yewstack/yew)
- [Vercel](https://vercel.com/)
- [Railway](https://railway.app/)
- [Supabase](https://supabase.com/)
