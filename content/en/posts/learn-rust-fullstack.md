---
title: Learn Rust by Building a Full-stack Todo Application
date: 2022-05-01
tags: [Rust, Practice]
---

# What

I want to write a blog about how I learned Rust.

Please forgive me that I just started learning such a great programming language in 2022.

To learn Rust by doing, I have built a full-stack todo application.

You can try it [here](https://todos.lexcao.io). The source code is available at [GitHub](https://github.com/lexcao/rust_fullstack_todo).

Here I am going to write about how to build it.

# How

Firstly, as everyone beginning, I learn Rust from [the book](https://doc.rust-lang.org/book/) as well. It is an awesome book to start learning Rust, and you should not skip it.

After learning some basic grammar,  I try to start building a todo application all in Rust from the beginning, which is a backend server from Rust tokio and a frontend page from [Rust WASM (Web Assembly)](https://rustwasm.github.io/docs/book/).

I am going to give a brief introduction to each of these two parts.

### Backend

A backend server is a simple web server for REST endpoints. I use [`actix-web`](https://github.com/actix/actix-web) for the web framework, which is **extremely fast web framework for Rust.**

- I will write another blog about how I develop a Rust web server by using TDD.
- It is a great experience that is taught by the Rust compiler and borrow checker.

For deployment, I am using [Supabase](https://supabase.com/) as Postgres service and [Railway](https://railway.app/) to ship server docker image.

### Frontend

The todo application has both online and offline data sources, for online is fetching data from the backend server, while offline is in local storage. And I made a button to switch them.

The frontend is powered by Rust WASM and [`yew`](https://github.com/yewstack/yew) framework, which is a React-like functional component framework for building web applications.

- If you are familiar with JSX you could feel quite at home when using Yew.
- It is a great experience to write React-like code in Rust, and it is really fun.
- But there are some differences I want to share, I am also going to write a blog to talk about it. so stay tuned.

For deployment, I am hosting on [Vercel](https://vercel.com/) with GitHub action to deploy automatically.

# Outcome

One of the benefits of full-stack Rust is sharing code. I made a common library through Cargo workspace, in which the backend and frontend can share the common package. The common library contains requests and models which can be used by both sides. And it is tested by the backend when integration test, so the frontend can use it without additional coding and testing.

The whole development experience is all Rust and a little CSS. I enjoy it.

Thanks to the Rust compiler, it is a great teacher to teach learning Rust.

# References

- [Source code](https://github.com/lexcao/rust_fullstack_todo)
- [Rust](https://www.rust-lang.org/)
- [The Book](https://doc.rust-lang.org/book/)
- [WASM](https://rustwasm.github.io/docs/book/)
- [actix-web](https://github.com/actix/actix-web)
- [yew](https://github.com/yewstack/yew)
- [Vercel](https://vercel.com/)
- [Railway](https://railway.app/)
- [Supabase](https://supabase.com/)
