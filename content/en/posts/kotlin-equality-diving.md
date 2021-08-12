---
title: Kotlin Weird Equality
date: 2020-04-21
tag: [Kotlin, Practice]
---

Recently, I encountered a weird equality question about Kotlin which does not usually get much attention while coding. So here is the thought process.

# Background

The following code snippet is using Kotlin `1.3.72`.

The business logic of it has been removed and only remained the code structure for reproducing the question.



```kotlin
// a enum for state
enum class MyState {
    OK, CANCELED
}

// it might return nullable MyState
fun processing(): MyState? {
    // asuming that it returns the CANCELED state
    return MyState.CANCELED
}

// when processing the state
fun handleState() {
    // the type of state is MyState?
    val state = processing()
    if (state == CANCELED) {
        // if condition counld not reach here
        println("Handle <CANCELED> state")
    }
}
```

The reason why it could not reach the CANCELED condition is the ***import***.

```java
import javax.print.attribute.standard.JobState.CANCELED
// the same name CANCELED is static imported, and the definition is as below:
// public static final JobState CANCELED = new JobState (7);
```

👏 Great, it is so easy to fix it.

😠 But, wait! Why does two mismatched types compile successfully in Kotlin?



# 🤔 Think

❓Question:

* 🤐 Why does it compile successfully when comparing with Kotlin enum and Java static type?

❓❓❓Other questions:

* Is there any mismatch by another class excepting enum?
* How does the enum compile by Kotlin compiler?
* Is this happens in Java? (supposed not)


I have not found anything after searching from *Stack Overflow* and *YouTrack.* Maybe it is not a question.😢

So I started to make an experiment to dive into the equality with mismatched types on Kotlin compiler.



👉 ***[Jump to conclusion directly](#conclusion)***.



# 🔬Experiment

## Step01 Setting Expectations

Let's have a look at the definition of equality in Java and Kotlin.

In Java,

* `==` compares the references between two objects. It is requires the two objects are in the same type before comparing.
* `equals()` compares the content between two objects.

In Kotlin,

> In Kotlin there are two types of equality:
> 
> 
> Structural equality (a check for equals()).
>
>   * `a == b` => a?.equals(b) ?: (b === null)
>
>
> Referential equality (two references point to the same object);
>   * `a === b` => a and b point to the same object
>
> --- *[kotlin equality](https://kotlinlang.org/docs/reference/equality.html)*

In a short,

* The `==` in Java is equivalent to `===` in Kotlin;
* The `==` in Kotlin combines `equals()` and `==` in Java.

The expectations are:

In Java,

* `equals()` compiles successfully and runs as usual.
  * The parameter of `equal()` is `Object`, no type mismatch errors.
* `==` does not compile.
  * Equality between reference types require they are same types.

In Kotlin,

* `===` does not compile.
  * The behavior is same to `==` in Java as above.
* `==` does not compile.
  * There is reference comparison between two objects, so does not compile when type mismatch as Java does.



## Step02 Collecting Variables

The variables collected from the above code are:

| variable     | values                                                       |
| ------------ | ------------------------------------------------------------ |
| control flow | Kotlin: if / when \| Java: if / switch                       |
| subjects     | Kotlin: class / enum class / object <br />Java: class / enum / static field |
| condition    | K - K / J - J / J - K                                        |



## step03 Basic Filtering

For control flow,

* to use `if` for the same behaviors on `if` and `when` in Kotlin.
* to use `if` in Java for the functionality of `switch` which only supports for enum / string / primitive type in Java.

```
if (condition) {}
```

For equality,

* to use `== ` and `equals()` in Java.
* to use `==` in Kotlin, while `===` is omitted for `==` in Java.

For subjects, there are two subjects of a and b on each type.

| subjects        | Java                          | Kotlin                                 |
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

For condition, Kotlin nullable type need to consider.

```
// So, here we have
J - J
K - K
K? - K?

J - K
J - K?
K - K?
```



## step04 Verifying Template

```
// Java code JavaGenerated.java
public class JavaGenerated {
    void if_JavaClass_To_JavaClass(MyJavaClassB a) {
        if (a.equals(new MyJavaClassA())) {
        } else if (a == new MyJavaClassA()) {
        }
  	}
}

// Kotlin code KotlinGenerated.kt
class KotlinGenerated {
    fun if_JavaClass_To_JavaClass(a: MyJavaClassB) {
        if (a == MyJavaClassA()) {
        }
  	}
}
```



## step05 Coding

By using the template above, it is time to start coding with those variables.

It is really repeated and tedious to write such templates for the occasion which there are so many combinations of the variables.

So here I decide to use [*JavaPoet*](https://github.com/square/javapoet) and [*KotlinPoet*](https://github.com/square/kotlinpoet) to generate code.

```
1. Enumerate three types for test for JavaCase and KotlinCase respectively
2. Combine JavaCase and KotlinCase two by two to get java-kotlin
3. Combine condition according to java-kotlin
    * J 2 J
    * J 2 K
    * K 2 K
    * K? 2 K
    * K? 2 J
4. Generate functions or methods of KotlinIf and JavaIf according to the conditions
5. Generate Java and Kotlin files according to JavaPoet and KotinPoet
```

The generated code is quite a lot, if you are interested, check following files:

* [*JavaGenerated.java*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/java/io/github/lexcao/equality/generated/JavaGenerated.java)
* [*KotlinGenerated.kt*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/kotlin/io/github/lexcao/equality/generated/KotlinGenerated.kt)



## step06 Watching Result

> Environment:
>
> * Java Version 1.8.0_172 
> * Kotlin Version 1.3.72
> * IDEA Version 2020.1

There are two types of results:

* **[error]** does not compile. The compiler will error, which is under read wavy line in IDEA.
* **[warning]** compiles fine.The IDEA will warn, which is highlighted by yellow in IDEA.

### JavaGenerated.java

Exactly as expected,

* `==` does not compile.
* `equals()` compiles fine, additionally, there is a friendly warning in IDEA.

| type   | ==                                               | equals                                  |
| ------ | ------------------------------------------------ | --------------------------------------- |
| Class  | **[error]** Operator '==' <br/>cannot be applied | **[warning]** inconvertible types       |
| Static | **[error]** Operator '==' <br/>cannot be applied | **[warning]** inconvertible types       |
| Enum   | **[error]** Operator '==' <br/>cannot be applied | **[warning]** condition is always false |

### KotlinGenerated.kt

Partially as expected,

* `===` does not compile.
* `==` does not compile on Class / Static from Kotlin.

| type   | ==                                                           |
| ------ | ------------------------------------------------------------ |
| Class  | **[error]** EQUALITY_NOT_APPLICABLE,<br/>Operator '==' cannot be applied |
| Static | **[error]** EQUALITY_NOT_APPLICABLE,<br/>Operator '==' cannot be applied |
| Enum   | **[warning]** INCOMPATIBLE_ENUM_COMPARISON,<br/>Comparison of incompatible enums is always unsuccessful |

Not as expected,

* Class / Static from Java compiles fine.
* Enum compiles fine.

Here are the relevant codes:

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

It is described as follows:

* Java class types (Class / Static) compile fine.
  * JavaClass_To_JavaClass
  * JavaStatic_To_JavaStatic
* It compiles fine when **Nullable** Kotlin enum to Java static type.
  * NullableKotlinEnum_To_JavaStatic

Then, the questions are:

* Why is the equality between Class in Kotlin stricter than that in Java?
* Why does the equality between enums compile fine?
* Why is it possible to compile fine when comparing between two different Java classes?
* Why is it possible to compile fine when comparing between Kotlin nullable enum  to Java static type?



## step07 Finding Why <a name="conclusion"/>

Let's recap the definition of ***equality*** from Kotlin official docs.

```
a == b => a?.equals(b) ?: (b === null)
a === b => a and b point to the same object
```

### 1. Why is the equality between Class / Static in Kotlin stricter than that in Java?

(Not found yet) TODO: Maybe it could overview the source code to find how the compiler warns `EQUALITY_NOT_APPLICABLE` in Kotlin.



### 2. Why does the comparison between enums compile fine?

In Java, `enum` is actually a syntactic sugar and will eventually be compiled into a generic class.

```java
abstract class Enum<E extends Enum<E>> { ... }
```

In Kotlin with no exception, `enum class` is also syntactic sugar and will be compiled into a generic class.

```kotlin
abstract class Enum<E : Enum<E>> { ... }
```

When comparing with two enums, it goes to compare between same `Enum` class but with different generic type. So it could compile fine and there would be no errors about type mismatch.

Additionally, IDEA gives a friendly warning about `INCOMPATIBLE_ENUM_COMPARISON`.



### 3. Why is it possible to compile fine when comparing between two different Java classes?

There is strict `Nullable / Notnull` syntax in Kotlin.

When calling Java from Kotlin, the compiler could not inference the `Null` info of it, `Nullable` as default, for the undetermined `Null` info of Java class.

There would be a `!` from IDEA type inference when calling from Java. It indicates that the `Null` info is unknown.

(Additionally, It is possible to inference the correct `Null` info from Kotlin compiler by using the annotations that are `@Nullable / @Notnull` provided by JetBrains in Java code)

[TODO add some screenshots]

So, when comparing with two `Nullable` types, it goes to `b === null` condition and compiles fine.



### 4. Why is it possible to compile fine when comparing between Kotlin nullable enum  to Java static type?

From exploration above, it finally gets to the point. Here are the conclusions:

1. There would be a same `Enum` type after compiling enums.
2. The `Null` info of the Java static type is unknown.
3. When comparing with two `Nullable` types, it compiles fine.

```kotlin
// It goes a friendly warning which is [INCOMPATIBLE_ENUM_COMPARISON]
// after telling the Null info of Java static type to the compiler
fun if_NullableKotlinEnum_To_JavaStatic(a: AnnotationRetention?) {
    // By using !! to tell it is NotNull
    if (a == JobState.CANCELED!!) {
        // [INCOMPATIBLE_ENUM_COMPARISON] Comparison of incompatible enums 
        // 'AnnotationRetention?' and 'JobState' is always unsuccessful
    }
}
```



# 👀 Summary

* It is fun and interesting for the process of experiment.
* The knowledge of foundation in Kotlin equality is not solid.
* Deep dived into the equality and enum of Kotlin and Java.
* What's next: to learn about the equality of Kotlin compiler's source code.



# 🔗 Links

* [***Github Source Code***](https://github.com/lexcao/kotlin-java-equality-palyground)
* [***Kotlin Equality Docs***](https://kotlinlang.org/docs/reference/equality.html)
* [*JavaPoet*](https://github.com/square/javapoet)
* [*KotlinPoet*](https://github.com/square/kotlinpoet) 
* [*JavaGenerated.java*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/java/io/github/lexcao/equality/generated/JavaGenerated.java)
* [*KotlinGenerated.kt*](https://github.com/lexcao/kotlin-equality/blob/generated/src/main/kotlin/io/github/lexcao/equality/generated/KotlinGenerated.kt)
