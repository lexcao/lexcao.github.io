---
title: 一次线程死锁排查记录
date: 2020-03-21
tags: [Java, Thread, Problem]
---

# 背景

某次发版之后，线上服务低概率出现某台实例接口响应超时，具体表现为：

* `/health` 接口超时报警；
* 线程死锁，Tomcat 线程池吃满；
* 服务完全无响应。

保留下当前 heap dump 和 thread stack 后，临时重启服务器恢复正常。

```bash
# heap dump
$ jmap -dump:format=b,file=dump.hprof [pid]
# thread stack
jstack [pid] > stack.txt
```



接下来简单记录一下排查结果。
<br/>（此文为回忆所写，当时排查的思考细节和过程已省略）

# 排查

## heap dump

### 使用工具

Eclipse + MAT

### 安装

```bash
# 安装 eclipse
$ brew cask install eclipse-java
# 安装 eclipse MAT
$ brew cask install mat # 是的，这个就是 eclipse-mat
```

### 相关连接

* [***Eclipse***](https://projects.eclipse.org/projects/eclipse)

* [***Eclipse MAT***](https://www.eclipse.org/mat/)

### 使用

1. 把 `heap dump` 文件 `dump.hprof` 导入到 MAT。

2. 发现有一个名称为 `Spring-Async-Scheduler` 异步队列占用特别大。【TODO 图片】

这里排查方向有了：异步调用相关。



## thread stack

### 使用工具

直接作为 txt 打开，或者使用 `IDEA` 自带的线程栈分析。



### 使用

1. 打开 IDEA 菜单栏  `Analyze > Analyze Stack Trace or Thread Dump`；
2. 复制 `thread.txt` 内容到窗口区；
3. 官方说明 ***[IDEA Analyze Stacktrace](https://www.jetbrains.com/help/idea/2019.3/analyze-stacktrace-dialog.html?utm_campaign=IC&utm_medium=link&utm_source=product&utm_content=2019.3)*** ；
4. 如果是同一个项目的调用栈，IDEA 支持跳转到具体的方法，强烈推荐👍。
5. 【TODO 图片】

### 排查

通过 IDEA 中友好的线程栈信息可见，【TODO 截图】

* `Tomcat-NIO` 全部 200 个线程都在等待，没有线程继续处理后续的请求；

* `Spring-Async`  全部 4 个线程也在等待；

```
"async-1" #151 prio=5 os_prio=0 tid=0x00007f18001a1000 nid=0x94 waiting on condition [0x00007f17be9ea000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x00000000e176e988> (a java.util.concurrent.CompletableFuture$Signaller)
	
"async-2" #152 prio=5 os_prio=0 tid=0x00007f18001a4800 nid=0x95 waiting on condition [0x00007f17be8e9000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x00000000e177c3c8> (a java.util.concurrent.CompletableFuture$Signaller)

"async-3" #153 prio=5 os_prio=0 tid=0x00007f18001dc800 nid=0x96 waiting on condition [0x00007f17be7e8000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x00000000e1794a08> (a java.util.concurrent.CompletableFuture$Signaller)

"async-4" #160 prio=5 os_prio=0 tid=0x00007f182002d800 nid=0x9d waiting on condition [0x00007f17be0e1000]
   java.lang.Thread.State: WAITING (parking)
	at sun.misc.Unsafe.park(Native Method)
	- parking to wait for  <0x00000000e176e958> (a java.util.concurrent.CompletableFuture$Signaller)
```

### 为什么 Spring-Async-Pool 线程池只有 4 个线程

查看 `@EnablePooledAsync > AsyncAutoConfigurer > PooledAsyncProperties`

```kotlin
// 默认配置如下 
// 核心线程池大小
var corePoolSize: Int = Runtime.getRuntime().availableProcessors()
// 最大线程池大小
var maxPoolSize: Int = Math.max(Runtime.getRuntime().availableProcessors() shl 2, 64)
// 队列容量
var queueCapacity: Int = 500_00
```

这个自动配置类是平台组提供的通用组件，默认是使用 CPU 核数。

已知服务器配置为 4 核，所以核心线程池数量为 4。

### 🤔思考

4 个异步线程队列等待，Tomcat 的 200 个线程也在等待。

* 会不会是异步调用中出现循环等待造成死锁？
    * （需要看一下这次版本上线新增的异步调用代码）
* 有没有可能在异步调用途中发生异常？
* 可以根据 Tomcat 中已经阻塞的线程看下具体是哪些接口引起？



## 查看代码

新上线的异步代码嫌疑最大，这里定位到一个调用异步方法，已删除业务逻辑，提取出以下代码结构：

```kotlin
@GetMapping("/test")
fun test() {
    val future = async { 
        fetch(listOf(1,2,3))
    }

    future.await() // #2
}

fun fetch(ids: List<Long>): DTO {
    return async { doFetch() }.await() // #1
}
```

简单说一下上面代码的调用，`async` 内调用 `fetch()` 方法，而里面嵌套了一个 `async` 调用。

* 这里调用方可能并不知道 `fetch()` 函数里面已经开启了一个异步调用，出现异步嵌套调用的现象。

下面分析一下「异步内调用异步」为什么会出现相互等待导致线程死锁。

已知当前声明的 `Async-Pool` 线程池线程数为 4 个：

1. 并发请求出现，同时出现 4个以上 `#1` 在等待
2. `#1` 处产生的异步调用进入 `Asnyc-Pool-Queue` 中排队
3. `#2` 处等待 `#1` 中的返回
4. `#1` 在等待其子任务
5. `#2` 在等待 `#1`
6. 但是队中等待的只有 `#2`，`#1` 的子任务还在排队中
7. 出现相互等待的情况，导致无限等下去了

```
这里简单模拟了一下异步队列里面的任务情况
1. 当前队列为空
> async-pool - []
> async-pool-queue - []
2. 一个请求进来
> async-pool - [#2, #1]
> async-pool-queue - []
3. 多个请求顺序进来 - 理想情况
> async-pool - [#2, #1, #2, #1]
> async-pool-queue - [#2, #1]

---- 以下是异常情况
4. 当多个请求并发进来 - 实际上
> async-pool - [#2, #2, #2, #2]
> async-pool-queue - [#1, #1, #1, #1, #1] --> 此处触发无限等待
```



## 结论

异步里面嵌套异步的情况，如果两个异步使用同一个异步队列，在并发情况下会出现异步线程相互等待导致死锁问题。

解决方案：

1. 使用同一个线程池的异步线程禁止嵌套调用；
2. 如果需要异步嵌套异步调用，两个异步需要拥有不同的异步队列。



# 参考链接

* [***Eclipse***](https://projects.eclipse.org/projects/eclipse)
* [***Eclipse MAT***](https://www.eclipse.org/mat/)
* **[JStack](https://docs.oracle.com/javase/7/docs/technotes/tools/share/jstack.html)**
* ***[IDEA Analyze Stacktrace](https://www.jetbrains.com/help/idea/2019.3/analyze-stacktrace-dialog.html?utm_campaign=IC&utm_medium=link&utm_source=product&utm_content=2019.3)***
