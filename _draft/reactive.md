# Reactive Streams

Reactive Streams started as an initiative in late 2013 between engineers at [*Netflix*](https://en.wikipedia.org/wiki/Netflix), [*Pivotal*](https://en.wikipedia.org/wiki/Pivotal_Software) and [*Lightbend*](https://en.wikipedia.org/wiki/Lightbend).

> Reactive Streams is an initiative to provide **a standard for asynchronous stream processing with non-blocking back pressure**. This encompasses efforts aimed at runtime environments (JVM and JavaScript) as well as network protocols.

You can read the origin specification on official website of [*Reactive Streams*](https://www.reactive-streams.org/).

Also, you can read the Chinese translation from [*here*](https://lexcao.github.io/zh/posts/reactive-streams).

In this post, I will go through the development of Reactive Streams, then I am going to write more details on each sections I mentioned below in the up coming posts.

1. Reactor Basic
2. Reactor Deep Dive
3. RSocket



##### **Asynchronous stream processing with non-blocking back pressure.**

The Reactive Streams is composed of following:

1. Asynchoronous;
2. Stream;
3. Non-blocking;
4. Back pressure.



The Java interfaces, you can find details on [*GitHub*](https://github.com/reactive-streams/reactive-streams-jvm)

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

### An API for asynchronous programming with observable streams

http://reactivex.io/

RxJava





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
4. implements the Reactive Streams specification.

You can find details on [*GitHub*](https://github.com/reactor/reactor-core).

By the way, you can follow the [*Lite Rx API Hands-on*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on) to learn the basic APIs.

And here [*How to Choose Operators*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator).

# Reactor Netty



# Spring Reactor

WebFlux

#### debug

1. `.checkpoint`
2. `Hooks.onOperatorDebug()`
3. reactor-tools `ReactorDebugAgent` (works in production) java agent



# RSocket

A binary protocol based on Reactive Streams back pressure

features

1. bi-directional
2. multiplexed
3. message-based
4. binary protocol

iteraction models

1. request-response (1 to 1)
2. fire and forget (1 to 0 udp)
3. request stream (1 to many pub / sub)
4. reqeust channel (many to many)

vocabulary

* broker: 
* routing:
* route
* forwarding
* tag
* metadata
* origin

protocol

* webstock
* tcp
* udp

## Back Pressure

#### RequestN

lease

https://www.youtube.com/watch?v=PfbycN_eqhg



# Summary

Reactive Streams specification 

Project Reactor an JVM implementation base on the specification

Spirng Reactor is Spirng framework integration with Project Reactor

RSocket is binary protocol base on the specification

# References

* [*Reactive Streams*](https://www.reactive-streams.org/)
* [*Project Reactor*](https://projectreactor.io)
* [*Reactor Core*](https://github.com/reactor/reactor-core)
* [*Lite Rx API Hands-on*](https://github.com/reactor/lite-rx-api-hands-on#lite-rx-api-hands-on)
* [*How to Choose Operators*](https://projectreactor.io/docs/core/release/reference/index.html#which-operator)



