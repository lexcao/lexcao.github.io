---
title: Kotlin 奇怪的相等现象探究
date: 2020-04-21
---

最近遇到一个平时没怎么关注的 Kotlin 相等问题，决定记录一下探究过程。



# 事由

以下代码片段 Kotlin 版本 `1.3.72`。

还原问题代码，已去除业务逻辑部分，仅保留关键代码，片段如下：

```kotlin
// 有一个状态枚举
enum class MyState {
    OK, CANCELED
}

// 某个处理函数会返回 nullable MyState
fun processing(): MyState? {
		// 假设当前某种情况下返回 取消 这个状态
    return MyState.CANCELED
}

// 在处理状态时
fun handleState() {
		// 此时编译器推断出类型为 State?
    val state = processing()
    if (state == CANCELED) {
        // 当处理 CANCELED 以下代码没有执行
        println("Handle <CANCELED> state")
    }
}
```

当处理 CANCELED 代码没有执行，原因在于***「import」***。

```java
import javax.print.attribute.standard.JobState.CANCELED
// 此处使用静态导入引入了一个其他包中同名的一个静态变量，该变量声明如下
// public static final JobState CANCELED = new JobState (7);
```

解决方法：

```kotlin
// 删除上面的静态引包，换成我们的 MyState
if (state == MyState.CANCELED) { ... }
```

👏拍拍手，这个 BUG 改起来真容易。又可以愉快地摸鱼了呢。

😠等等，作为静态语言面对如此诡异地类型不匹配为什么能够通过编译？



# 🤔思考

❓问题点：

* 🤐 Kotlin 枚举类对比 Java 的一个静态变量，直觉上感觉类型不匹配的情况，为什么能够通过编译？

❓❓❓头上的问号变多了：

* Kotlin 中其他类型会出现这种类似的情况吗？
* Kotlin 编译器具体怎么处理枚举类型的？
* Java 会出现这种情况吗？（应该不会）



在 Stack Overflow 和 YouTrack 搜了一圈，没有找到想要的信息。<br/>
可能是搜索关键字不对😢。

为了探个究竟，通过以下实验研究 Kotlin 编译器类型不匹配行为。

[「点击跳转到结果部分」](#conclusion)



# 🔬实验

## 第一步 实验预期

先看下各自的相等（***equality***）语法说明：

Java 中，

* `==` 比较的是两个对象的引用，也就是内存地址。内存地址相同的前提是两个对象必须是同一种类型；
* `equals()` 比较的是两个对象的内容。

Kotlin 中，

> In Kotlin there are two types of equality:
> Structural equality (a check for equals()).
>
>   * `a == b` => a?.equals(b) ?: (b === null)
>
>
> Referential equality (two references point to the same object);
>   * `a === b` => a and b point to the same object
>
> --- [kotlin equality](https://kotlinlang.org/docs/reference/equality.html)
>
> 以下是简单翻译：
>
> Kotlin 中有两种类型的相等：
>
> 结构相等（对 equals() 的检查）
>
> * `a == b` => `a?.equals(b) ?: (b === null)`
>
> 引用相等（两个引用指向同一对象）
>
> * `a === b` => a 和 b 指向同一对像

简单来说，

* Java 中的 `==` 对应 Kotlin `===`；
* Kotlin 中的 `==` 包含 Java `equals` 和 `==`。



先设置一个预期：

Java 中的相等，

* `equals()` 成功通过编译，程序正常运行；
  * 方法入参是 `Object`，不同类型相比不会报错。
* `==`  不能编译；
  * 引用相同前提需要对象相同。

Kotlin 中的相等，

* `===` 不能编译；
  * 与 Java 的 `==` 行为一致，引用相同前提需要对象相同。
* `==` 不能编译；
  * `a?.equals(b) ?: (b === null)` 这里 `equals` 入参是 `Any?` 能够通过编译，但是后面会对比对象引用，凭直觉来看，有对比引用的话，如果类型不一致，不能编译。



## 第二步 收集变量

通过上面复现出的问题梳理出以下变量：

| variable     | values                                                       |
| ------------ | ------------------------------------------------------------ |
| 条件判断语句 | Kotlin: if / when \| Java: if / switch                       |
| 表达式对象   | Kotlin: class / enum class / object <br />Java: class / enum / static field |
| 表达式声明   | K - K / J - J / J - K                                        |



## 第三步 初步筛选

对于条件判断语句，

* Kotlin 的 if 和 when 的行为一致，所以这里可以只使用 if；
* Java 中 switch 仅支持 enum / String / primitive ，再加上对于 enum 有严格类型校验（语法层面，当 `switch(enum)` case 语句就处于该 enum 的上下文，只能使用该 enum 中定义的值。不考虑，同样只使用 if。

``` 
if (condition) {}
```

对于相等判断，

* Java 使用 `==` 和 `equals()`；
* Kotlin 仅使用 `==` （`===` 行为与 Java 中 `==` 一致，故省略）。

对于表达式对象，每个实验对象定义 a / b ，b 用于同类型时备用。

| 表达式<br/>对象      | Java                          | Kotlin                                 |
| --------------- | ----------------------------- | -------------------------------------- |
| class           | MyJavaClassA / MyJavaClassB   | MyKotlinClassA / MyKotlinClassB        |
| enum            | RetentionPolicy / ElementType | AnnotationRetention / AnnotationTarget |
| object / static | JobState / JobStateReason     | MyKotlinObjectA / MyKotlinObjectB      |

```
public class MyJavaClassA {} // MyJavaClassA.java

public class MyJavaClassB {} // MyJavaClassB.java

class MyKotlinClassA // MyKotlinClassA.kt

class MyKotlinClassB // MyKotlinClassB.kt

object MyKotlinObject // MyKotlinObjectA

object MyKotlinObject // MyKotlinObjectB

// RetentionPolicy      : java.lang.annotation.RetentionPolicy
// ElementType          : java.lang.annotation.ElementType
// AnnotationRetention  : kotlin.annotation.AnnotationRetention
// AnnotationTarget     : kotlin.annotation.AnnotationTarget
// JobState             : javax.print.attribute.standard.JobState
// JobStateReason       : javax.print.attribute.standard.JobStateReason
```

对于表达式声明，还需要新增一个 Kotlin 中 nullable 类型

``` 
// 总共有以下几类
J - J
K - K
K? - K?

J - K
J - K?
K - K?
```



## 第四步 验证框架

```
// java 验证代码
public class JavaGenerated {
		void if_JavaClass_To_JavaClass(MyJavaClassB a) {
    		if (a.equals(new MyJavaClassA())) {
    		} else if (a == new MyJavaClassA()) {
    		}
  	}
}

// kotlin 验证代码
class KotlinGenerated {
  	fun if_JavaClass_To_JavaClass(a: MyJavaClassB) {
    		if (a == MyJavaClassA()) {
    		}
  	}
}
```



## 第五步 编码验证

有了上面的模版之后，就可以根据变量开始编码验证。

面对多种的变量组合的情况，手动编写大量的模版代码非常的劳累。

所以利用工具，使用 [*JavaPoet*](https://github.com/square/javapoet) 和 [*KotlinPoet*](https://github.com/square/kotlinpoet) 来生成代码。

(花了一天来写自动生成代码逻辑，完成后感到一阵空虚，为什么要花那么多的时间折腾，手动复制粘贴早写完了。)



😭这里大致说以下生成的思路：

```
1. 分别枚举出需要测试的三种类型，JavaCase 和 KotlinCase
2. JavaCase 和 KotlinCase 中相两两组合 得到 java-kotlin
3. 根据 java-kotlin 再次组合 5 种情况
    * J 2 J
    * J 2 K
    * K 2 K
    * K? 2 K
    * K? 2 J
4. 根据 java-kotlin-pairs 生成对应的 KotlinIf 和 JavaIf 方法
5. 根据方法，通过 JavaPoet 和 KotlinPoet 代码
```

生成后的代码挺多的，感兴趣的去看，这两个文件：
* [*JavaGenerated.java*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/java/io/github/lexcao/equality/generated/JavaGenerated.java)
* [*KotlinGenerated.kt*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/kotlin/io/github/lexcao/equality/generated/KotlinGenerated.kt)



## 第六步 观察结果

> 环境如下
>
> * Java Version 1.8.0_172 
> * Kotlin Version 1.3.72
> * IDEA Version 2020.1

这里结果大致分为两类：
* **[error]** ，不能编译。编译器告警，在 IDEA 中红色波浪线标出；
* **[warning]** ，能够编译。IDEA 告警，以黄色背景高亮。

### JavaGenerated.java

完全符合预期，
* `==` 不能编译；
* `equals()` 能够编译，另外 IDEA 给出友好提醒。

|  type       | ==                                      | equals                              |
| ---------- | --------------------------------------- | ----------------------------------- |
| Class      | **[error]** Operator '==' <br/>cannot be applied | **[warning]** inconvertible types       |
| Static     | **[error]** Operator '==' <br/>cannot be applied | **[warning]** inconvertible types       |
| Enum       | **[error]** Operator '==' <br/>cannot be applied | **[warning]** condition is always false |

#### KotlinGenerated.kt

部分符合预期，
* `===` 不能编译；
* `==` 对于 Kotlin 的 Class / Static 不能编译。

|   type       | ==                                                           |
| ---------- | ------------------------------------------------------------ |
| Class      | **[error]** EQUALITY_NOT_APPLICABLE,<br/>Operator '==' cannot be applied |
| Static     | **[error]** EQUALITY_NOT_APPLICABLE,<br/>Operator '==' cannot be applied |
| Enum       | **[warning]** INCOMPATIBLE_ENUM_COMPARISON,<br/>Comparison of incompatible enums is always unsuccessful |

不符合预期，
* Java Class / Static 可以编译；
* Enum 可以编译。

下面是相关代码：

```kotlin
fun if_JavaClass_To_JavaClass(a: MyJavaClassB) {
    if (a == MyJavaClassA()) {
    }
}

fun if_JavaStatic_To_JavaStatic(a: JobStateReason) {
    if (a == JobState.CANCELED) {
    }
}

fun if_NullableKotlinEnum_To_JavaStatic(a: AnnotationRetention?) {
    if (a == JobState.CANCELED) {
    }
}
```

以上情况可以归纳为：
* Java 对象类型(Class/Static)，能通过编译；
    * JavaClass_To_JavaClass
    * JavaStatic_To_JavaStatic
* 可空的 Kotlin 枚举类型对应 Java 静态类型，能通过编译；
    * NullableKotlinEnum_To_JavaStatic

大致梳理出以下疑问点：
2. Class / Static 的对比为什么比 Java 的 equals 更严格？
3. 为什么 Enum 的对比可以通过编译，没有像上面那么严格？
4. 使用两个不同的 Java 的对象对比，为什么可以通过编译？
5. nullable 的枚举类为什么可以与 Java 的静态类型对比？


## 第七步 探究原因 <a name="conclusion" />


再回顾一下 Kotlin 官方文档中对相等（***equality***）的定义：

```
a == b => a?.equals(b) ?: (b === null)
a === b => a and b point to the same object
```

### 1. Class / Static 的对比为什么比 Java 的 equals 更严格？

（目前没有想清楚原因）TODO ：这里应该去看 Kotlin 编译器在处理 `EQUALITY_NOT_APPLICABLE` 这个报错。



### 2. 为什么 Enum 的对比可以通过编译，没有像上面那么严格？

在 Java 中 `enum` 其实是语法糖，最终会被编译为范型类。
```java
abstract class Enum<E extends Enum<E>> { ... }
`````

Kotlin 不例外，`enum class` 也是语法糖，最终会被编译为范型类。
```kotlin
abstract class Enum<E : Enum<E>> { ... }
```

当两个枚举对比的时候，相当与是同一个类的不同范型，所以能够通过编译，不会出现类型不匹配问题。

这里，IDEA 告警 `INCOMPATIBLE_ENUM_COMPARISON` 给出友好提示。



### 3. 使用两个不同的 Java 的对象对比，为什么可以通过编译？

Kotlin 中有严格的 `Nullable / Notnull` 语法。

当与 Java 的类进行互相调用时，由于 Java 中的 `Null` 信息不确定，编译器无法推断出 Java 类的具体 `Null` 信息(默认视为 `Nullable`)。
<br/>可以在 IDEA 的智能类型推断中看到 `!` 的标识。
<br/>（在 Java 中显式使用 JetBrains 提供的 `@Nullable / @NotNull` 这两个注解，可以让 Kotlin 编译器正确推断出 `Null` 信息）
【TODO，提供 IDEA 截图更好】

所以两个 `Nullable` 类型的进行比较的时候，会走到 `b === null` 这个判断，不会报错，能够编译。



### 4. Kotlin nullable 的枚举类为什么可以与 Java 的静态类型对比？

进行上述前置探索，终于到这次问题的终点。结合上面的结论，总结如下：

1. 枚举类编译后是同一个 `Enum` 类；
2. Java 的静态类型 `Null` 信息未知；
3. 两个 `Nullable` 类型进行对比，会走到 `b === null` 判断，不会报错，能够编译。

```kotlin
// 给 Java 的类明确的 Null 信息
// IDEA 出现友好警告 [INCOMPATIBLE_ENUM_COMPARISON]
fun if_NullableKotlinEnum_To_JavaStatic(a: AnnotationRetention?) {
    // 使用 !! 告诉编译器，明确 Null 信息是 Notnull
    if (a == JobState.CANCELED!!) {
        // [INCOMPATIBLE_ENUM_COMPARISON] Comparison of incompatible enums 
        // 'AnnotationRetention?' and 'JobState' is always unsuccessful
    }
}
```



# 👀总结

* 整个探求真相的过程还是很有趣的；
* 最后知道真相后，还是自己太菜了，基础知识没有完全掌握；
* 深入探究了 Kotlin 和 Java 的相等和枚举相关的内容；
* 下一步：趁着这股好奇心，去了解 Kotlin 编译器的相等类型判断源码。



# 🔗相关链接

* [***GitHub Source Code***](https://github.com/lexcao/kotlin-java-equality-palyground)
* [***Kotlin Equality Docs***](https://kotlinlang.org/docs/reference/equality.html)
*  [*JavaPoet*](https://github.com/square/javapoet)
* [*KotlinPoet*](https://github.com/square/kotlinpoet) 
* [*JavaGenerated.java*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/java/io/github/lexcao/equality/generated/JavaGenerated.java)
* [*KotlinGenerated.kt*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/kotlin/io/github/lexcao/equality/generated/KotlinGenerated.kt)
