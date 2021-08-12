---
title: Reactive Overview
date: 2019-11-28
tags: [Reactive, Document]
---

# Reactive Streams

Reactive Streams started as an initiative in late 2013 between engineers at [*Netflix*](https://en.wikipedia.org/wiki/Netflix), [*Pivotal*](https://en.wikipedia.org/wiki/Pivotal_Software) and [*Lightbend*](https://en.wikipedia.org/wiki/Lightbend).

> Reactive Streams is an initiative to provide **a standard for asynchronous stream processing with non-blocking back pressure**. This encompasses efforts aimed at runtime environments (JVM and JavaScript) as well as network protocols.

You can read the origin specification on official website of [*Reactive Streams*](https://www.reactive-streams.org/).

Also, you can read the Chinese translation from [*here*](https://lexcao.github.io/zh/posts/reactive-streams).

##### **Asynchronous stream processing with non-blocking back pressure.**

The Reactive Streams is composed of following:

1. Asynchronous;
2. Stream;
3. Non-blocking;
4. Back pressure.

The Java interfaces, you can find details on [*GitHub*](https://github.com/reactive-streams/reactive-streams-jvm).

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

>  An API for asynchronous programming with observable streams
>
> ReactiveX is a combination of the best ideas from the Observer pattern, the Iterator pattern, and functional programming
>
> -- [*Reactive Extensions*](http://reactivex.io/)

# Project Reactor

> Reactor is a fourth-generation Reactive library for building non-blocking applications on the JVM based on the [*Reactive Streams Specification*](https://github.com/reactive-streams/reactive-streams-jvm)

> * **Composability** and **readability**
> * Data as a **flow** manipulated with a rich vocabulary of **operators**
> * Nothing happens until you **subscribe**
> * **Backpressure** or *the ability for the consumer to signal the producer that the rate of emission is too high*
> * **High level** but **high value** abstraction that is *concurrency-agnostic*
>
> -- [*From Imperative to Reactive Programming*](https://projectreactor.io/docs/core/release/reference/index.html#_from_imperative_to_reactive_programming)

Features:

1. Fully non-blocking.
2. Integrates Java API.
   1. Completable Future
   2. Stream
   3. Duration
3. Flux and Mono.
   1. Flux: A Reactive Streams [`Publisher`](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc/org/reactivestreams/Publisher.html?is-external=true) with rx operators that emits **0 to N** elements, and then completes.
   2. Mono: A Reactive Streams [`Publisher`](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc/org/reactivestreams/Publisher.html?is-external=true) with basic rx operators that completes successfully by emitting **an element**, or with an error.
4. Implements the Reactive Streams specification.

You can find details on [*GitHub*](https://github.com/reactor/reactor-core).

By the way, you can follow the [*Lite Rx API Hands-on*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on) to learn the basic APIs.

And here [*How to Choose Operators*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator).

# Reactor Netty

> `Reactor Netty` offers non-blocking and backpressure-ready `TCP`/`HTTP`/`UDP` clients & servers based on `Netty` framework.
>
> -- [*Reactor Netty*](https://github.com/reactor/reactor-netty)

# Spring Framework WebFlux

> The reactive-stack web framework, Spring WebFlux, was added later in version 5.0. It is fully non-blocking, supports [Reactive Streams](https://www.reactive-streams.org/) back pressure, and runs on such servers as Netty, Undertow, and Servlet 3.1+ containers
>
> -- [*Spring WebFlux*](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html)

#### debug

1. `.checkpoint`
2. `Hooks.onOperatorDebug()`
3. reactor-tools `ReactorDebugAgent` (works in production) java agent



# RSocket

A binary protocol based on Reactive Streams back pressure

Features

1. bi-directional
2. multiplexed
3. message-based
4. binary protocol

Interaction Models

1. request-response (1 to 1)
2. fire and forget (1 to 0 udp)
3. request stream (1 to many pub / sub)
4. request channel (many to many)

Protocol

* WebSocket
* TCP
* UDP



# Summary

Reactive Streams is a specification.

Project Reactor is JVM implementation base on the specification.

Spring WebFlux is Spring framework integration with Project Reactor.

RSocket is binary protocol base on the specification.

# References

* [*Reactive Streams*](https://www.reactive-streams.org/)
* [*Reactive Streams JVM*](https://github.com/reactive-streams/reactive-streams-jvm)
* [*Reactive Extensions*](http://reactivex.io/)
* [*Project Reactor*](https://projectreactor.io)
* [*Reactor Core*](https://github.com/reactor/reactor-core)
* [*Lite Rx API Hands-on*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on)
* [*How to Choose Operators*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator)
* [*Reactor Netty*](https://github.com/reactor/reactor-netty)
* [*Spring WebFlux*](https://docs.spring.io/spring/docs/current/spring-framework-reference/web-reactive.html)



