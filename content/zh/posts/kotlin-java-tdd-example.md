---
title: Kotlin/Java TDD 开发流程记录
date: 2021-05-03
tags: [Kotlin, Java, TDD]
---

通过使用 Kotlin / Java 中 Junit5 和 Mockito 测试框架，在预约功能中演示 TDD 开发流程。

# TDD 介绍

**TDD（Test-Driven Development）**
是一种开发流程，中文是「测试驱动开发」。用一句白话形容，就是「先写测试再开发」。先写测试除了能确保测试程式的撰写，还有一个好处：有助于在开发初期厘清程式介面如何设计。详细理论知识可以前往 Wiki 了解，这里不再过多介绍。

- [测试驱动开发](https://zh.wikipedia.org/wiki/%E6%B5%8B%E8%AF%95%E9%A9%B1%E5%8A%A8%E5%BC%80%E5%8F%91)
- [Test Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)

## TDD 开发流程（5步）

术语说明：

- 红灯 - Failure - 测试用例失败
- 绿灯 - Success - 测试用例成功
- 重构 - Refactor - 重构功能代码

具体步骤：

1. 选定一个功能，编写测试用例
2. 执行测试，得到【红灯】
3. 编写满足测试用例的功能代码
4. 再次执行，得到【绿灯】
5. 【重构】代码

小结：

对于每一个功能，在【红灯】-【绿灯】-【重构】间来回循环往复，不断得到完善。

# 前置工作

## 代码说明

- 使用 Kotlin 语言（会有相对应的 Java 代码）
- 使用到的测试框架
    - Running: `JUnit5`
    - Mock:  `MockK` / `Mockito`
    - Assertion: `Kotest` / `AssertJ`
- 只涉及 TDD 的具体流程，不涉及单元测试如何编写（可以看 SpringBoot 单元测试各层）

## 功能介绍

假设一个用户预约的场景。

- 用户可以创建一个预约
- 同一个时间点，只有一个用户可以下单成功

## 使用到的库


{{< switch-tab >}}
```kotlin
plugins {
    java
    id("io.freefair.lombok") version "6.0.0-m2"
    kotlin("jvm") version "1.5.0-RC"
}

group = "io.github.lexcao"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))

    // for Java mocking and assertion
    testImplementation("org.mockito:mockito-core:3.9.0")
    testImplementation("org.assertj:assertj-core:3.19.0")

    // for Kotlin mocking and assertion
    testImplementation("io.mockk:mockk:1.11.0")
    testImplementation("io.kotest:kotest-assertions-core:4.4.3")

    testImplementation("org.junit.jupiter:junit-jupiter-api:5.6.0")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine")
}

tasks {
    test {
        useJUnitPlatform()
    }
}
```

```groovy
plugins {
    id 'java'
    id 'org.jetbrains.kotlin.jvm' version '1.5.0-RC'
    id "io.freefair.lombok" version "6.0.0-m2"
}

group 'io.github.lexcao'
version '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib"

    // for Java mocking and assertion
    testImplementation 'org.mockito:mockito-core:3.9.0'
    testImplementation 'org.assertj:assertj-core:3.19.0'

    // for Kotlin mocking and assertion
    testImplementation 'io.mockk:mockk:1.11.0'
    testImplementation 'io.kotest:kotest-assertions-core:4.4.3'

    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.6.0'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine'
}

test {
    useJUnitPlatform()
}
```
{{< /switch-tab  >}}

# ReservationService

## 前置

提前创建以下空文件，避免代码无法运行

- Reservation.java
- ReservationService.java
- ReservationRepository.java

## Red - 01 - 编写单元测试

执行单元测试，显示【红灯】，代码分支：

* kotlin-red-01
* java-red-01

{{< switch-tab >}}

```kotlin
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
internal class ReservationServiceImplTest {

    private val service: ReservationService = ReservationServiceImpl()

    @Nested
    inner class MakeReservation {

        private val time: LocalDateTime = LocalDateTime.of(2021, 5, 1, 21, 30)

        @Test
        fun shouldSuccess() {
            // given
            val reservation = Reservation(name = "Tom", time = time)

            // actual
            val reserved: Reservation = service.makeReservation(reservation)

            // expect
            reserved shouldBe reservation
        }
    }
}

```

```java
class ReservationServiceImplTest {

    private ReservationService service;

    @BeforeEach
    void setup() {
        service = new ReservationServiceImpl();
    }

    @Nested
    class
    MakeReservation {

        private final
        LocalDateTime time = LocalDateTime.of(2021, 5, 1, 21, 30);

        @Test
        void shouldSuccess() {
            // given
            Reservation reservation = new Reservation("Tome", time);

            // actual
            Reservation reserved = service.makeReservation(reservation);

            // expect
            assertThat(reserved).isEqualTo(reservation);
        }
    }
}
```

{{</ switch-tab >}}

## Green - 01 - 编写实现

执行单元测试，显示【绿灯】，代码分支：

- kotlin-green-01
- java-green-01

{{< switch-tab >}}

```kotlin
class ReservationServiceImpl : ReservationService {
    override fun makeReservation(reservation: Reservation): Reservation {
        return reservation
    }
}

```

```java
public class ReservationServiceImpl implements ReservationService {
    @Override
    public Reservation makeReservation(Reservation reservation) {
        return reservation;
    }
}
```

{{</ switch-tab >}}

## Red - 02 - 加入功能 - 完善单元测试

（注意：持久化层目前不需要关心，在这里使用 mock 相关功能）

加入持久化逻辑，完善代码，显示【红灯】，代码分支：

- kotlin-red-02
- java-red-02

{{< switch-tab >}}

```kotlin
private val mockRepository: ReservationRepository = mockk()
private val service: ReservationService = ReservationServiceImpl(mockRepository)

@AfterEach
fun clear() {
    clearAllMocks()
}

@Test
fun shouldSuccess() {
    // given
    every { mockRepository.save(any()) } returns reservation

    // verify
    verifySequence {
        mockRepository.save(reservation)
    }

    // ...
}
```

```java
class ReservationServiceImplTest {
    @BeforeEach
    void setup() {
        mockRepository = Mockito.mock(ReservationRepository.class);
        service = new ReservationServiceImpl(mockRepository);
    }

    @Test
    void shouldSuccess() {
        // given
        given(mockRepository.save(any())).willReturn(reservation);

        // verify
        then(mockRepository).should().save(reservation);

        // ...
    }
}
```

{{</ switch-tab >}}

## Green - 02 - 编写实现 - 完善功能

代码分支：

- kotlin-green-02
- java-green-02

{{< switch-tab >}}

```kotlin
override fun makeReservation(reservation: Reservation): Reservation {
    return repository.save(reservation)
}
```

```java
class ReservationServiceImpl implements ReservationService {
    @Override
    public Reservation makeReservation(Reservation reservation) {
        return repository.save(reservation);
    }
}
```

{{</ switch-tab >}}

## Red - 03 - 边界测试

当同一时间内已有预约的情况下，代码分支：

- kotlin-red-03
- java-red-03

{{< switch-tab >}}

```kotlin
@Test
fun shouldSuccess() {
    // given ...
    every { mockRepository.findByTime(time) } returns null

    // verify ...
    mockRepository.findByTime(time)
}

@Test
fun shouldFailure() {
    // given
    val reservation = Reservation(name = "Tom", time = time)
    every { mockRepository.findByTime(time) } returns reservation

    // actual
    shouldThrow<ReservationTimeNotAvailable> {
        service.makeReservation(reservation)
    }

    // verify
    verifySequence {
        mockRepository.findByTime(time)
        mockRepository.save(reservation) wasNot Called
    }
}
```

```java
class ReservationServiceImplTest {

    @Test
    void shouldSuccess() {
        // given
        given(mockRepository.findByTime(time)).willReturn(Optional.empty());

        // verify
        then(mockRepository).should().findByTime(time);
    }

    @Test
    void shouldFailure() {
        // given
        Reservation reservation = new Reservation("Tome", time);
        given(mockRepository.findByTime(time)).willReturn(Optional.of(reservation));
        given(mockRepository.save(any())).willReturn(reservation);

        // actual
        assertThatThrownBy(() -> service.makeReservation(reservation))
            .isExactlyInstanceOf(ReservationTimeNotAvailable.class);

        // verify
        then(mockRepository).should().findByTime(time);
        then(mockRepository).shouldHaveNoMoreInteractions();
    }
}
```

{{</ switch-tab >}}

## Green - 03 - 完善边界检查

{{< switch-tab >}}

```kotlin
override fun makeReservation(reservation: Reservation): Reservation {
    val
        mayBeReserved = repository.findByTime(reservation.time)
    if (mayBeReserved != null) {
        throw ReservationTimeNotAvailable
    }

    return repository.save(reservation)
}
```

```java
class ReservationServiceImpl implements ReservationService {
    @Override
    public Reservation makeReservation(Reservation reservation) {
        if (repository.findByTime(reservation.getTime()).isPresent()) {
            throw new ReservationTimeNotAvailable();
        }
        return repository.save(reservation);
    }
}
```

{{</ switch-tab >}}

## Refactor - 简单的小重构

别忘了，重构完之后，运行一遍单元测试，【绿灯】。代码分支：

- kotlin-refactor

```kotlin
override fun makeReservation(reservation: Reservation): Reservation {
    repository.findByTime(reservation.time)?.run {
        throw ReservationTimeNotAvailable
    }

    return repository.save(reservation)
}
```

## 小结

一个简单的小功能通过 TDD 开发流程就此开发完成。

**[完整代码](https://github.com/lexcao/tdd-testing-example)**

# 🔗 参考链接

- [测试驱动开发](https://zh.wikipedia.org/wiki/%E6%B5%8B%E8%AF%95%E9%A9%B1%E5%8A%A8%E5%BC%80%E5%8F%91)
- [Test Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)
- [TDD 開發五步驟，帶你實戰 Test Driven Development 範例](https://tw.alphacamp.co/blog/tdd-test-driven-development-example)
- [自動軟體測試-tdd-與-bdd](https://yurenju.medium.com/%E8%87%AA%E5%8B%95%E8%BB%9F%E9%AB%94%E6%B8%AC%E8%A9%A6-tdd-%E8%88%87-bdd-464519672ac5)
- [spring-boot-testing](https://www.baeldung.com/spring-boot-testing)
- [testing-web-layer](https://spring.io/guides/gs/testing-web/)
