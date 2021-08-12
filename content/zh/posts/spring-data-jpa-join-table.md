---
title: Spring Data JPA 多条件动态连表查询
date: 2021-04-04
tags: [Java, Spring, MySQL]
---

# 痛点

项目中使用 Spring Data JPA 作为 ORM 框架的时候，实体映射非常方便。Spring Data Repository 的顶层抽象完全解决单实体的查询，面对单实体的复杂查询，也能使用 `JpaSpecificationExecutor<T>` 构造 `Specification<T>` 轻松应对。

而对于后台管理报表查询需求来说，需要进行连表多条件动态查询的时候，就显得无从下手。因为它并不像 MyBatis 一样能够在 XML 文件中写出动态 SQL 语句。

尽管可以使用 `EntityManager` 动态拼接原生 SQL 语句，但是该方法返回值为 `ResultSet` ，也就是说查出来的实体映射关系需要手动映射（😢这样不太优雅，已经定义出实体，还需要自己去映射）。

所以，本文的目的是，在现有实体关系的基础上，结合 `Specification<T>` 记录下 Spring Data JPA 多条件动态连表查询操作，以及其中的踩坑和优化。

# 基础操作

那么，让我们开始进入代码操作。【[本文所有代码在此](https://github.com/lexcao/spring-data-jpa-join-table)】

## 前置说明

### 相关依赖

- Java 11
- SpringBoot 2.4.2

build.gradle

```groovy
plugins {
    id 'org.springframework.boot' version '2.4.2'
    id 'io.spring.dependency-management' version '1.0.11.RELEASE'
    id 'java'
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    compileOnly 'org.projectlombok:lombok'
    runtimeOnly 'mysql:mysql-connector-java'
    annotationProcessor 'org.projectlombok:lombok'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    testRuntimeOnly 'com.h2database:h2'
}
```

maven.xml

```sql
<build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
          <excludes>
            <exclude>
              <groupId>org.projectlombok</groupId>
              <artifactId>lombok</artifactId>
            </exclude>
          </excludes>
        </configuration>
      </plugin>
    </plugins>
  </build>

<dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
      <groupId>com.h2database</groupId>
      <artifactId>h2</artifactId>
      <scope>runtime</scope>
    </dependency>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>
```

### 模拟场景

三个实体：作者、书、书评。其中，作者与书是一对多的关系，书与书评是一对一的关系（当然书评与读者的评价是一对多的关系，这里省去，仅用一对一来进行演示即可）。

假设有这样的后台查询条件：作者名称、书的发布时间、书评的评分。（这里每个实体取一个字段进行连表查询演示，其他字段同理）。返回书籍列表以及相关表字段。

## 实体关系

### 表结构

```sql
CREATE TABLE `author` (
    `id` VARCHAR(255) PRIMARY KEY,
    `name` VARCHAR(255)
);

CREATE TABLE `book` (
    `id` VARCHAR(255) PRIMARY KEY,
    `publish_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `author_id` VARCHAR(255),
    `review_id` VARCHAR(255)
);

CREATE TABLE `review` (
    `id` VARCHAR(255) PRIMARY KEY,
    `score` INT
);

-- 数据初始化
INSERT INTO `author` (`id`, `name`)
VALUES ('A_1', 'Author_1'),
       ('A_2', 'Author_2'),
       ('A_3', 'Author_3'),
       ('A_4', 'Author_4'),
       ('A_5', 'Author_5');

INSERT INTO `review` (`id`, `score`)
VALUES ('R_1', 20),
       ('R_2', 30),
       ('R_3', 40),
       ('R_4', 50),
       ('R_5', 60),
       ('R_6', 70),
       ('R_7', 80),
       ('R_8', 90);

INSERT INTO `book` (`id`, `author_id`, `review_id`)
VALUES ('B_1', 'A_1', 'R_1'),
       ('B_2', 'A_2', 'R_2'),
       ('B_3', 'A_3', 'R_3'),
       ('B_4', 'A_4', 'R_4'),
       ('B_5', 'A_5', 'R_5'),
       ('B_6', 'A_2', 'R_6'),
       ('B_7', 'A_2', 'R_7'),
       ('B_8', 'A_3', 'R_8');
```

### JPA 实体关系

使用 Java persistence API 构建如下实体关系，其他业务字段省略。

```java
@Data
@Table
@Entity
public class Author {
    @Id
    private String id;
    private String name;
}

@Data
@Table
@Entity
public class Book {
    @Id
    private String id;

    @Column(name = "publish_time")
    private LocalDateTime publishTime;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private Author author;
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "review_id", foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private Review review;
}

@Data
@Table
@Entity
public class Review {
    @Id
    private String id;
}
```

相关解释：

- `@Data` Lombok 注解，自动生成 getter、setter、hashcode、equals
- `@Table` `@Entity` `@Id` `@Column` `@JoinColumn` 均为 persistence API
- `@ManyToOne` 实体映射关系 多对一
- `@OneToOne` 实体映射关系 一对一

在实际业务中，连表的时候不一定是查询多个实体的全部字段，为了不影响原有实体关系的正常映射，这里单独声明一个类 `BookJoin` 来映射查询条件返回。优雅的实现 Spring Data JPA 连表操作，这样做的好处是：

- 只有 SELECT 查询出来的字段，才需要在实体里面声明出来
- JOIN ON 后面的条件，需要在实体里面声明出来
- 再根据 Specification 中的 query.join 来进行 JOIN

以下是连表实体 `BookJoin.java` 文件

```java
@Data
@Entity
@Table(name = "book")
public class BookJoin {

    @Id
    private String id;

    @Column(name = "publish_time")
    private LocalDateTime publishTime;

    @ManyToOne
    @JoinColumn(name = "author_id", foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private Author author;
    @OneToOne
    @JoinColumn(name = "review_id", foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private Review review;

    @Data
    @Entity
    @Table(name = "author")
    public static class Author {
        @Id
        private String id;
        private String name;
    }

    @Data
    @Entity
    @Table(name = "review")
    public static class Review {
        @Id
        private String id;
        private Integer score;
    }
}
```

## 构建测试环境

为了演示多条件查询结果，这里使用 JUnit 来进行单元测试

> SpringBoot x JUnit 单元测试更详细的内容，请看另一篇博客

```java
/**
 *  given:
 *      empty query
 *  then:
 *      paged data
 */
@Test
void multiQuery() {
    var spec = BookJoinSpec.multiQuery(emptyQuery());
    var page = PageRequest.of(0, 5);
    queryBySpecMethod(spec, page);
}

private Page<BookJoin> queryBySpecMethod(Specification<BookJoin> spec, PageRequest pageRequest) {
    var books = repo.findAll(spec, pageRequest);

    assertThat(books.getNumberOfElements()).isGreaterThan(0);

    books.getContent().forEach(it -> {
            assertThat(it).isNotNull();
						// 访问结果集的属性，验证是否懒加载
            assertThat(it.getAuthor().getName()).isNotNull();
            assertThat(it.getReview().getScore()).isNotNull();
        }
    );

    return books;
}
```

# 连表操作

如何进行声明式连表查询，这里讲演示各种写法的不同， 以及各个参数所起的作用，最后会给出一个最终版本作为最佳实践参考。

## 01 版本

```java
static Specification<BookJoin> multiQuery_01(BookJoinQuery param) {
    return (root, query, cb) -> {
        var predicates = new LinkedList<Predicate>();

        root.join("author");
        root.join("review");

        // ...
    };
}
```

通过以上的单元测试，打印出的 SQL 如下

```sql
Hibernate:
SELECT `bookjoin0_`.`id` AS `id1_1_`, `bookjoin0_`.`author_id` AS `author_i3_1_`,
    `bookjoin0_`.`publish_time` AS `publish_2_1_`, `bookjoin0_`.`review_id` AS `review_i4_1_`
FROM `book` `bookjoin0_`
         INNER JOIN `author` `bookjoin_a1_` ON `bookjoin0_`.`author_id` = `bookjoin_a1_`.`id`
         INNER JOIN `review` `bookjoin_r2_` ON `bookjoin0_`.`review_id` = `bookjoin_r2_`.`id`
WHERE 1 = 1
LIMIT ? OFFSET ?
Hibernate:
SELECT `bookjoin_a0_`.`id` AS `id1_0_0_`, `bookjoin_a0_`.`name` AS `name2_0_0_`
FROM `author` `bookjoin_a0_`
WHERE `bookjoin_a0_`.`id` = ?
Hibernate:
SELECT `bookjoin_r0_`.`id` AS `id1_2_0_`, `bookjoin_r0_`.`score` AS `score2_2_0_`
FROM `review` `bookjoin_r0_`
WHERE `bookjoin_r0_`.`id` = ?
Hibernate:
SELECT `bookjoin_r0_`.`id` AS `id1_2_0_`, `bookjoin_r0_`.`score` AS `score2_2_0_`
FROM `review` `bookjoin_r0_`
WHERE `bookjoin_r0_`.`id` = ?
Hibernate:
SELECT `bookjoin_a0_`.`id` AS `id1_0_0_`, `bookjoin_a0_`.`name` AS `name2_0_0_`
FROM `author` `bookjoin_a0_`
WHERE `bookjoin_a0_`.`id` = ?
Hibernate:
SELECT `bookjoin_r0_`.`id` AS `id1_2_0_`, `bookjoin_r0_`.`score` AS `score2_2_0_`
FROM `review` `bookjoin_r0_`
WHERE `bookjoin_r0_`.`id` = ?
```

可以看到：

- 数据总共查出来 3 条，结果执行的 SQL 语句有 7 条
- 分别是：1 条连表查询，3 条 `author` 表的单查询，3 条 `review` 表的单查询

## 02 版本 - 使用 fetch 优化

使用 `fetch` 替代 `join`

- `join` 仅连表查询，返回的主实体的所有属性，可以理解为 `SELECT book.*`
- `fetch` 连表查询 + 快加载，返回连表所有实体的属性，可以理解为 `SELECT *`

```java
static Specification<BookJoin> multiQuery_02(BookJoinQuery param) {
    return (root, query, cb) -> {
	      // ...

        root.fetch("author");
        root.fetch("review");
				// ...
    };
}
```

通过以上的单元测试，打印出的 SQL 如下

```sql
Hibernate:
SELECT `bookjoin0_`.`id` AS `id1_1_0_`, `bookjoin_a1_`.`id` AS `id1_0_1_`, `bookjoin_r2_`.`id` AS `id1_2_2_`,
    `bookjoin0_`.`author_id` AS `author_i3_1_0_`, `bookjoin0_`.`publish_time` AS `publish_2_1_0_`,
    `bookjoin0_`.`review_id` AS `review_i4_1_0_`, `bookjoin_a1_`.`name` AS `name2_0_1_`,
    `bookjoin_r2_`.`score` AS `score2_2_2_`
FROM `book` `bookjoin0_`
         INNER JOIN `author` `bookjoin_a1_` ON `bookjoin0_`.`author_id` = `bookjoin_a1_`.`id`
         INNER JOIN `review` `bookjoin_r2_` ON `bookjoin0_`.`review_id` = `bookjoin_r2_`.`id`
WHERE 1 = 1
LIMIT ? OFFSET ?
```

可以看到：

- 执行的 SQL 只有 1 条
- SELECT 中的字段包括连表的字段

### 踩坑 - 分页问题

创建一个新的单元测试，直接使用 `fetch` 分页报错

```java
@Test
void multiQuery_02() {
    var spec = BookJoinSpec.multiQuery_02(emptyQuery());
    var page = PageRequest.of(0, 5);
    assertThatThrownBy(() -> queryBySpecMethod(spec, page))
				.hasCauseInstanceOf(QueryException.class);
}
```

当使用 `fetch` 再进行分页的时候，会报以下错误

```java
Caused by: org.hibernate.QueryException: query specified join fetching, but the owner of the fetched association was not present in the select list.
```

原因分析：

- 实际报错出现在 count 语句，错误信息表示该 count 语句返回值没有找到具体的映射属性

解决方法：

- 针对分页的 count 查询语句单独做处理，代码如下

```java
static Specification<BookJoin> multiQuery_02_fix(BookJoinQuery param) {
    return (root, query, cb) -> {
	      // ...

				if (Long.class.equals(query.getResultType()) || long.class.equals(query.getResultType())) {
	          root.join("author");
	          root.join("review");
	      } else {
	          root.fetch("author");
	          root.fetch("review");
	      }
				// ...
    };
}
```

### 注意

可能疑问「上面 BookJoin 实体里面声明关系不是 `fetch = FetchType.LAZY` ，没有指明是懒加载，为什么连表查询的时候还是没有加载出来」。

原因是 JPA 里面 `join` 机制处理，原理大致是这样的：

1. 根据 `join` 和 `fetch` 生成不同的 `JpaQL` 语句，差别在于 `join` 与 `join fetch`

```
-- fetch 生成的 JpaQL 语句
select generatedAlias0 from BookJoin as generatedAlias0 inner join fetch generatedAlias0.author as generatedAlias1 inner join fetch generatedAlias0.review as generatedAlias2 where 1=1

-- join 生成的 JpaQL 语句
select generatedAlias0 from BookJoin as generatedAlias0 inner join generatedAlias0.author as generatedAlias1 inner join generatedAlias0.review as generatedAlias2 where 1=1
```

2. `JpaQL` 语句根据 `join fetch` 转换为 `HQL` 再转换为最终的 SQL 语句，通过 `QueryTranslatorImpl` 类，在 `doCompile` 方法看到完整转换过程，部分代码如下

```java
// QueryTranslatorImpl
// doCompile -> analyze -> HqlSqlBaseWalker.statement -> selectStatement
// selectClause -> fromClause -> fromElementList -> fromElement -> joinElement

// HqlSqlWalker.java createFromJoinElement  #367
// DotNode 此处设置 fetch
DotNode dot = (DotNode) path;
JoinType hibernateJoinType = JoinProcessor.toHibernateJoinType( joinType );
dot.setJoinType( hibernateJoinType );    // Tell the dot node about the join type.
dot.setFetch( fetch );
// Generate an explicit join for the root dot node.   The implied joins will be collected and passed up
// to the root dot node.
dot.resolve( true, false, alias == null ? null : alias.getText() );

// 解析阶段
// selectStatement -> query -> processQuery
// 上面的报错在此处  SelectClause.java #212
if ( !fromElementsForLoad.contains( origin ) && !fromElementsForLoad.contains( fromElement.getFetchOrigin() ) )
    throw new QueryException(
        "query specified join fetching, but the owner " +
		"of the fetched association was not present in the select list " +
		"[" + fromElement.getDisplayText() + "]"
	);
}
```

## 03 版本 - 加上条件筛选

创建一个新的单元测试，筛选一下 Join 条件

```java
@Test
void multiQuery_03() {
    var query = BookJoinQuery.builder()
        .authorName("Author_2")
        .build();
    var spec = BookJoinSpec.multiQuery_03(query);
    var page = PageRequest.of(0, 5);

    var result = queryBySpecMethod(spec, page);
    var givenAuthor = result.getContent().get(0).getAuthor();
    assertThat(givenAuthor.getName()).isEqualTo("Author_2");
}
```

具体的连表查询条件如下

```java
static Specification<BookJoin> multiQuery_03(BookJoinQuery param) {
    return (root, query, cb) -> {
        var predicates = new LinkedList<Predicate>();

        if (Long.class.equals(query.getResultType()) || long.class.equals(query.getResultType())) {
            root.join("author");
            root.join("review");
        } else {
            root.fetch("author");
            root.fetch("review");
        }

        if (null != param.getBookPublishTime()) {
            predicates.add(cb.equal(root.get("publishTime"), param.getBookPublishTime()));
        }

        if (null != param.getAuthorName()) {
            predicates.add(cb.equal(root.get("author").get("name"), param.getAuthorName()));
        }

        if (null != param.getReviewScore()) {
            predicates.add(cb.equal(root.get("review").get("score"), param.getReviewScore()));
        }

        query.where(predicates.toArray(new Predicate[0]));

        return query.getRestriction();
    };
}
```

## 总结连表操作

1. 需要 `SELECT` 查询出来的字段，通过单独的类 `BookJoin` 映射出来
2. 使用 `fetch` 直接加载连表中的其他字段，此处注意分页还需要使用 `join`
3. 对于连表字段筛选，使用 `root.get("author").get("name")` 即可

## 注意

上面使用的示例是针对【强一对一关系】所以使用默认的连接类型 `INNER JOIN`

当然也可以使用左外连接（右外连接不支持）

```java
root.join("author", JoinType.LEFT);
root.fetch("author", JoinType.LEFT);
```

# 扩展阅读

- [Advanced Spring Data JPA - Specifications and Querydsl](https://spring.io/blog/2011/04/26/advanced-spring-data-jpa-specifications-and-querydsl)
- [REST Query Language with Spring Data JPA Specifications](https://www.baeldung.com/rest-api-search-language-spring-data-specifications)
- [Spring Data JPA Specification DSL for Kotlin](https://github.com/consoleau/kotlin-jpa-specification-dsl)

# 🔗 链接

- [Github source](https://github.com/lexcao/spring-data-jpa-join-table)
- [Spring Data JPA使用Specification](https://www.jianshu.com/p/659e9715d01d)

# 👀总结

- 使用 SpringJPA 来写动态多条件连表查询，通过代码来控制 SQL 语句，需要对 JPA 以及 Hibernate 相关 API 相对熟练才可以写出优质的 SQL 语句生成。
- 和 MyBatis 可以直接拼接 SQL 的相比，各有应用场景。
- 整体来说用代码来写 JPA 的动态查询，对于习惯 SQL 语句的人来说，还是感觉隔了一层。
- 对于这样的分页连表查询，个人感觉还是 MyBatis 舒服一点，简单。
