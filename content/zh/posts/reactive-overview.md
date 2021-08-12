---
title: Reactive 概览
data: 2019-11-29
uid: reactive-overview
---

# Reactive Streams

Reactive Streams 在 [*Netflix*](https://en.wikipedia.org/wiki/Netflix) 、[*Pivotal*](https://en.wikipedia.org/wiki/Pivotal_Software) 和 [*Lightbend*](https://en.wikipedia.org/wiki/Lightbend) 工程师于 2013 年底发起这项计划。

> Reactive Streams 是一项提议，为无阻塞背压的异步流提供一个标准。这包括针对运行时环境（JVM 和 JavaScript）以及网络协议上的工作。

你可以在 [*Reactive Streams*](https://www.reactive-streams.org/) 官网网站阅读这个原始规范。

你也可以在 [*这里*](https://lexcao.github.io/zh/posts/reactive-streams) 阅读它的中文翻译。



##### **无阻塞背压的异步流处理**

Reactive Streams 由以下组成：

1. 异步；
2. 流式；
3. 无阻塞；
4. 背压（回压）。



以下是 Java 接口，你可以在 [*GitHub*](https://github.com/reactive-streams/reactive-streams-jvm) 阅读更详细内容。

```java
public interface Publisher<T> {
    public void subscribe(Subscriber<? super T> s);
}

public interface Subscriber<T> {
    public void onSubscribe(Subscription s);
    public void onNext(T t);
    public void onError(Throwable t);
    public void onComplete();
}

public interface Subscription {
    public void request(long n);
    public void cancel();
}

public interface Processor<T, R> extends Subscriber<T>, Publisher<R> {
}
```

# Reactive Extensions

>  用于可观察流的异步编程 API。
>
>  ReactiveX 是来自观察者模式、迭代器模式以及函数式编程的最佳创意组合。
>
>  -- [*Reactive Extensions*](http://reactivex.io/)

# Project Reactor

> Reactor 是第四代 Reactive 函数库，基于 [*Reactive Streams 规范*](https://github.com/reactive-streams/reactive-streams-jvm) 在 JVM 上构建无阻塞应用。

> * **可组合性**和**可读性**
> * 以丰富的操作符方法操作数据**流**
> * **订阅**之前没有任何反应
> * **背压**或者消费者具有通知生产者生产速率过高能力
> * 并发上的高级抽象
>
> -- [*From Imperative to Reactive Programming*](https://projectreactor.io/docs/core/release/reference/index.html#_from_imperative_to_reactive_programming)

功能：

1. 完全无阻塞；
2. 集成 Java API：
   1. `Completable Future`
   2. `Stream`
   3. `Duration`
3. `Flux` 和 `Mono`
   1. `Flux`：一个 Reactive Streams 发布者，具有 rx 操作符，它发出 **0 到 N** 个元素，然后完成。
   2. `Mono`：一个 Reactive Streams 发布者，具有 rx 操作符，发出 **一个** 元素成功完成，或者一个异常。
4. 实现了 Reactive Streams 规范。

你可以在 [*GitHub*](https://github.com/reactor/reactor-core) 阅读更多细节。

当然，你可以根据这个 [*快速上手 Rx API*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on) 来学习基础的接口。

这里有个 [*帮助你如何选择操作符*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator)

# Reactor Netty

> `Reactor Netty` 基于 `Netty` 框架，提供无阻塞和背压就绪的 `TCP`/`HTTP`/`UDP` 客户端和服务端。
>
> -- [*Reactor Netty*](https://github.com/reactor/reactor-netty)

# Spring Reactor WebFlux

> Reactive 技术栈的网络框架，Spring WebFlux，在 5.0版本后期加入。它是完全无阻塞，支持 Reactive Streams 背压，并且在 Netty、Undertow 以及 Servlet .3.1+ 等服务器上运行。
>
> -- [*Spring WebFlux*](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html)

# RSocket

基于 Reactive Sreams 背压的一个**二进制协议**

功能：

1. 双向的
2. 多路复用
3. 基于消息（message driven）
4. 二进制协议

交互模型：

1. 请求-响应（ 1 对 1 ）
2. 发送 - 忘却 （ 1 对 0 UDP）
3. 请求 - 流式（ 1 对多，发布 / 订阅）
4. 请求 - 通道 （多对多）

通信协议

* WebSocket
* TCP
* UDP

# 总结

Reactive Streams 是一个规范。

Project Reactor 是基于规范的 JVM 实现。

Spring WebFlux 是 Spring 框架集成 Project Reactor。

RSocket 是基于规范二进制协议实现。

# 参考链接

* [*Reactive Streams*](https://www.reactive-streams.org/)
* [*Reactive Streams JVM*](https://github.com/reactive-streams/reactive-streams-jvm)
* [*Reactive Extensions*](http://reactivex.io/)
* [*Project Reactor*](https://projectreactor.io)
* [*Reactor Core*](https://github.com/reactor/reactor-core)
* [*快速上手 Rx API*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on)
* [*帮助你如何选择操作符*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator)
* [*Reactor Netty*](https://github.com/reactor/reactor-netty)
* [*Spring WebFlux*](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html)


