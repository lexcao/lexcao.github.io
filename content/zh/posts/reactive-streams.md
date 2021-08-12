---
title: Reactive Streams 规范翻译
date: 2019-11-17
tags: [Reactive, Translation]
---

翻译自 [*Reactive Streams*](https://www.reactive-streams.org/)

# Reactive Streams

> 注：Reactive Streams 直译为响应式流，这里保留英文原词。

*Reactive Streams* 是一项提议，旨在为具有**无阻塞背压的异步处理流**提供标准。这包括针对运行环境（JVM 和 JavaScript）以及网络协议的努力。

*Reactive Streams* 是为了提供一个**无阻塞背压异步流式处理的标准的一个提议**。



## JDK9 java.util.concurrent.Flow

在 JDK 9 的 [*java.util.concurrent.Flow*](https://docs.oracle.com/javase/9/docs/api/java/util/concurrent/Flow.html) 中可用的接口，分别为 1 ：1 语义上各自对应于 Reactive Streams。这意味着将会有一个迁移期，库（Libraries）将采用 JDK 中的新类型，但是由于库的完全语义等效以及 `Reactive Streams <-> Flow` 适配器库和直接与 JDK Flow 类型兼容的 TCK，因此这个迁移期预计会很短。

如果你有兴趣了解有关 *JVM Reactive Streams*，请阅读此 [*文章*](https://github.com/reactive-streams/reactive-streams-jvm/blob/v1.0.3/README.md)



## 问题

在异步系统中，处理流数据（尤其是数量未先确定的的“实时”数据）需要特别注意。最突出的问题是，需要控制资源消耗，这样快速数据源不会压垮流目的地。为了在并行网络主机或一台多核机器上并行地使用计算资源，需要异步。

*Reactive Streams* 的主要目标是管理跨异步边界的流数据交换（考虑将元素传递到另一个线程或线程池），同时确保接收方不强制缓存任意数量的数据。换句话说，**背压**是此模型中不可或缺的一部分，以使在线程之间进行调节的队列收到限制。如果背压的通信是同步的，则异步处理的好处将被抵消（另请看  [*Reactive Manifesto*](http://reactivemanifesto.org/)），因此必须注意对 Reactive Streams 实现的所有方面进行完全无阻塞和异步行为授权。

本说明书旨在允许创建许多符合要求的实现，这些实现通过遵守规则将能够平滑地互相操作，并在流应用程序的整个处理图中保留上述好处和特性。



## 范围

*Reactive Streams* 的范围是找接口、方法和协议的最小集，这些接口、方法和协议将描述实现目标——无阻塞背压的异步处理流，所需要的操作和实体。

端用户 DSLs（领域特定语言）或者协议绑定 API（应用编程接口）有目的地被排除在范围之外，以鼓励和支持可能使用不同编程语言的不同实现，以尽可能地遵循其平台的习惯用法。

我们预计，接受这个 *Reactive Streams* 规范以及它的实现经验将共同导向广泛的集成，例如，包括将来 JDK 版本中的 Java 平台支持或者在将来的网页浏览器中网络协议的支持。

### 工作组

#### 基本含义

基本含义定义了如何通过背压来调节流中元素的传输。元素的传输方式，传输过程中的表现形式或者背压的信号发送方式均不属于本规范的一部分。

#### JVM 接口（已完成）

工作组将基本语义应用于一组编程接口，这些编程接口的主要目的是允许使用共享内存堆在 JVM 内的对象和线程之间传递流，从而实现不同一致性的实现和语言绑定的互操作。

在 2019 年 8 月 23 日，我们发布了针对 JVM 的 *Reactive Streams* 1.0.3 版本，包含了 Java [*API*](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc)， 一个文本 [说明](https://github.com/reactive-streams/reactive-streams-jvm/blob/v1.0.3/README.md#specification), 一个 [*TCK*](https://www.reactive-streams.org/reactive-streams-tck-1.0.3-javadoc) 和 [实现示例](https://www.reactive-streams.org/reactive-streams-examples-1.0.3-javadoc).

1.0.3 的新功能是主 jar 中包含 JDK 9（适配器库）。Maven Central 上提供了相应的代码库：

```
<dependency>
  <groupId>org.reactivestreams</groupId>
  <artifactId>reactive-streams</artifactId>
  <version>1.0.3</version>
</dependency>
<dependency>
  <groupId>org.reactivestreams</groupId>
  <artifactId>reactive-streams-tck</artifactId>
  <version>1.0.3</version>
</dependency>
<dependency>
  <groupId>org.reactivestreams</groupId>
  <artifactId>reactive-streams-tck-flow</artifactId>
  <version>1.0.3</version>
</dependency>
<dependency>
  <groupId>org.reactivestreams</groupId>
  <artifactId>reactive-streams-examples</artifactId>
  <version>1.0.3</version>
</dependency>
```

这些代码的源码在 [*GitHub*](https://github.com/reactive-streams/reactive-streams-jvm/tree/v1.0.3)。请使用 GitHub Issues 来提供反馈。

所有的库和说明都在 [知识共享零](http://creativecommons.org/publicdomain/zero/1.0) 下发布到了公共领域。

在 [这里](https://www.reactive-streams.org/announce-1.0.3) 阅读更多有关 Reactive Streams 1.0.3 相关内容。

#### 实现须知

为了着手实现最终规范，建议先阅读 [*README*](https://github.com/reactive-streams/reactive-streams-jvm/blob/v1.0.3/README.md) 和这个 [Java API 文档](https://www.reactive-streams.org/reactive-streams-1.0.3-javadoc)，然后看一下这个 [规范](https://github.com/reactive-streams/reactive-streams-jvm/blob/v1.0.3/README.md#specification)，再看一下这个 [*TCK*](https://github.com/reactive-streams/reactive-streams-jvm/tree/v1.0.3/tck) 以及 [示例实现](https://github.com/reactive-streams/reactive-streams-jvm/tree/v1.0.3/examples/src/main/java/org/reactivestreams/example/unicast)。如果你对以上有任何问题，请先看一下 [关闭的问题](https://github.com/reactive-streams/reactive-streams-jvm/issues?page=1&state=closed)，如果尚未解决，请打开一个 [新的问题](https://github.com/reactive-streams/reactive-streams-jvm/issues/new)。

这项工作是在 [*reactive-streams-jvm*](https://github.com/reactive-streams/reactive-streams-jvm/) 仓库执行的。

#### JavaScript 接口

这个工作组定义了一组最小的对象属性，用于观察 JavaScript 运行环境中的流元素。目的是提供一个可测试的规范，该规范允许不同实现在同一个运行环境进行互操作。

这项工作是在 [*reactive-streams-js*](https://github.com/reactive-streams/reactive-streams-js/) 仓库执行的。

#### 网路协议

该工作组定义了用于在各种传输介质上传递 Reactive Streams，其中涉及到元素的序列化和反序列化。此类传输媒介例如 TCP，UDP，HTTP 和 WebSockets。

这项工作是在 [*reactive-streams-io*](https://github.com/reactive-streams/reactive-streams-io/) 仓库执行的。


