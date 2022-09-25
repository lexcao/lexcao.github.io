---
title: Spring Data JPA 多条件连表查询最佳实践
date: 2022-09-25
tags: [Java, Kotlin, Spring, JPA]
---

# 背景

本文是 [Spring Data JPA 多条件连表查询](/zh/posts/spring-data-jpa-join-table) 文章的最佳实践总结。

### 解决什么问题？

使用 Spring Data JPA 需要针对多条件进行连表查询的场景不使用原生 SQL 或者 HQL 的时候，仅仅通过 JpaSpecificationExecutor<T> 构造 Specification<T> 动态条件语句来实现类型安全的多条件查询。

### 说明

相关上下文背景请前往 [前文](/zh/posts/spring-data-jpa-join-table) 了解。
这里再提一下接下来示例会用到的场景：

三个实体：作者、书、书评。其中，作者与书是一对多的关系，书与书评是一对一的关系（当然书评与读者的评价是一对多的关系，这里省去，仅用一对一来进行演示即可）。

假设有这样的后台查询条件：作者名称、书的发布时间、书评的评分。（这里每个实体取一个字段进行连表查询演示，其他字段同理）。返回书籍列表以及相关表字段。

【[本文所有代码在此](https://github.com/lexcao/spring-data-jpa-join-table)】

# 最佳实践

1. 需要 `SELECT` 查询的字段，通过单独的 Java Bean 进行映射
   * 利用 JPA 的自动实体映射结果集
2. `@EntityGraph` 注解标注返回实体需要 Fetch 的字段
   * 无需再手动针对连表进行 `fetch`，解决 N+1 问题
3. JOIN ON 查询条件使用 `join().on()` 拼接
    ```java
    Join<Object, Object> author = root.join("author");
    author.on(cb.equal(author.get("name"), param.getAuthorName()));
    ```
4. WHERE 查询条件使用 `query.where()` 拼接
    ```java
    query.where(cb.equal(root.get("publishTime"), param.getBookPublishTime()));
    ```

# 代码示例

## 针对 Repository
1. 需要 `override` 已有 `findAll` 方法，使用 `@EntityGraph` 注解
2. 使用 `@EntityGraph` 注解，标注额外属性需要 fetch
```java
// BookJoinRepository.java
@Repository
public interface BookJoinRepository extends 
    JpaRepository<BookJoin, String>, JpaSpecificationExecutor<BookJoin> {
    @Override
    @EntityGraph(attributePaths = { "author", "review" })
    Page<BookJoin> findAll(Specification<BookJoin> spec, Pageable pageable);
}
```

## 针对 Specification

1. WHERE 查询条件使用 `query.where()` 拼接
2. JOIN ON 查询条件使用 `join().on()` 拼接
```java
static Specification<BookJoin> multiQuery_04(BookJoinQuery param) {
    return (root, query, cb) -> {
        if (null != param.getBookPublishTime()) {
            query.where(cb.equal(root.get("publishTime"), param.getBookPublishTime()));
        }

        if (null != param.getAuthorName()) {
            Join<Object, Object> author = root.join("author");
            author.on(cb.equal(author.get("name"), param.getAuthorName()));
        }

        if (null != param.getReviewScore()) {
            Join<Object, Object> review = root.join("review");
            review.on(cb.equal(review.get("score"), param.getReviewScore()));
        }
        return query.getRestriction();
    };
}
```
## 结果 SQL 语句

```sql
select bookjoin0_.id           as id1_1_0_,
       bookjoin_a1_.id         as id1_0_1_,
       bookjoin_r2_.id         as id1_2_2_,
       bookjoin0_.author_id    as author_i3_1_0_,
       bookjoin0_.publish_time as publish_2_1_0_,
       bookjoin0_.review_id    as review_i4_1_0_,
       bookjoin_a1_.name       as name2_0_1_,
       bookjoin_r2_.score      as score2_2_2_
from book bookjoin0_
       inner join author bookjoin_a1_ on bookjoin0_.author_id = bookjoin_a1_.id 
                                      and (bookjoin_a1_.name = ?)
       inner join review bookjoin_r2_ on bookjoin0_.review_id = bookjoin_r2_.id 
                                      and (bookjoin_r2_.score = ?)
where bookjoin0_.publish_time = ? limit ?
```

当然，这里案例使用的是 `INNER JOIN`，对于 `LEFT JOIN` 也是生效的。
```java
Join<Object, Object> author = root.join("author", JoinType.LEFT);
author.on(cb.equal(author.get("name"), param.getAuthorName()));

// left outer join author bookjoin_a1_ on 
// bookjoin0_.author_id = bookjoin_a1_.id 
// and (bookjoin_a1_.name = ?)
```

# 链接

* [Spring Data JPA 多条件连表查询](/zh/posts/spring-data-jpa-join-table)
* [Add annotation which will automatically add join fetch to query](https://github.com/spring-projects/spring-data-jpa/issues/2382)


