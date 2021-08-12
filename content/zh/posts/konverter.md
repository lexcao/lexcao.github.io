---
title: 使用 KAPT 生成 Kotlin Data Class 转换器
date: 2020-04-13
---

# 背景
Web 后台开发中，对于一个实体的操作会衍生出多个类似的对象进行操作（避免直接使用实体），由此出现相关名词
* 持久化对象，即实体 PO(*Persistent Object*)
* 传输对象 DTO(*Data Transfer Object*)
* 业务对象 BO(*Business Object*)
* 展示对象 VO(*View Object*)
* 等等……
这些对象大多数直接从实体里面裁剪几个字段，比如，在一次创建订单请求中以订单实体（OrderEntity）为例，经历如下流程：

```
1. 接收请求体 CreateOrderRequest
2. 根据 OrderQuery 构造查询对象查询订单
3. 构造 OrderEntity 进行持久化操作
4. 构造 OrderBO 进行下游消费
5. 返回响应体 CreateOrderResponse
```

可见，从 OrderEntity 衍生出 4 个对象，仅仅是对订单的实体的部分裁剪，但是要编写很多重复的代码（复制也行）。当然，如果是新增字段的话可以使用继承解决。

在 Kotlin Web 后台开发中，data class 的语法特性带来很多优势，但还是避免不了创建类似的重复对象。
所以 `Konverter` 诞生于此，解决实体对象裁剪问题。还有另一个功能那就是自动生成两个实体间的转换方法。
> 注意：目前只支持 Kotlin，并且生成的转换方法是通过扩展函数实现

# 是什么
通过 [*KAPT(Kotlin Annotation Processing Tool*](https://kotlinlang.org/docs/reference/kapt.html]) 注解处理以及 [*Kotlin Poet*](https://github.com/square/kotlinpoet) 代码生成，实现自动生成对实体的相关裁剪的对象。
主要有两个注解：
* `@Konvertable` 生成裁剪的实体以及对应的转换方法
* `@Konvert` 单独针对某个类生成转换方法

废话不多说来看怎么使用。

# 怎么用

## 1. 引入依赖

```
// for build.gradle.kts
repositories {
    maven("https://jitpack.io")
}

dependencies {
    kapt("com.github.lexcao:konverter:master-SNAPSHOT")
    implementation("com.github.lexcao:konverter-annotation:master-SNAPSHOT")
}

// for build.gradle
repositories {
    maven { url 'https://jitpack.io' }
}

dependencies {
    kapt 'com.github.lexcao:konverter:master-SNAPSHOT'
    implementation 'com.github.lexcao:konverter-annotation:master-SNAPSHOT'
}
```

## 2. 在需要转换的类上加上注解

```
@Konvertable(
    To(name = "LoginDTO", pick = ["username", "password"]),
    To(name = "UserListDTO", omit = ["password"])
)
@Konvert(to = UserVO::class)
data class UserEntity(
    val id: Long,
    @Konvert.Field("name")
    val username: String,
    val password: String,
    @Konvert.By(GenderEnumConverter::class)
    val gender: Int
)
```

## 3. 生成的代码如下：

```
// @Konvertable
/**
 *  Auto generated code by @Konvertable
 */
data class LoginDTO(
  val username: String,
  val password: String
)

/**
 *  Auto generated code by @Konvertable
 */
data class UserListDTO(
  val id: Long,
  val username: String,
  val gender: Int
)

/**
 *  Auto generated code by @Konvert
 */
fun UserEntity.toLoginDTO(username: String = this@toLoginDTO.username, password: String =
    this@toLoginDTO.password): LoginDTO = LoginDTO(username=username,password=password)

/**
 *  Auto generated code by @Konvert
 */
fun LoginDTO.toUserEntity(
  id: Long = 0L,
  username: String = this@toUserEntity.username,
  password: String = this@toUserEntity.password,
  gender: Int = 0
): UserEntity = UserEntity(id=id,username=username,password=password,gender=gender)

/**
 *  Auto generated code by @Konvert
 */
fun UserEntity.toUserListDTO(
  id: Long = this@toUserListDTO.id,
  username: String = this@toUserListDTO.username,
  gender: Int = this@toUserListDTO.gender
): UserListDTO = UserListDTO(id=id,username=username,gender=gender)

/**
 *  Auto generated code by @Konvert
 */
fun UserListDTO.toUserEntity(
  id: Long = this@toUserEntity.id,
  username: String = this@toUserEntity.username,
  password: String = "",
  gender: Int = this@toUserEntity.gender
): UserEntity = UserEntity(id=id,username=username,password=password,gender=gender)

/**
 *  Auto generated code by @Konvert
 */
fun UserEntity.toRegisterDTO(
  username: String = this@toRegisterDTO.username,
  password: String = this@toRegisterDTO.password,
  gender: Int = this@toRegisterDTO.gender
): RegisterDTO = RegisterDTO(username=username,password=password,gender=gender)

/**
 *  Auto generated code by @Konvert
 */
fun RegisterDTO.toUserEntity(
  id: Long = 0L,
  username: String = this@toUserEntity.username,
  password: String = this@toUserEntity.password,
  gender: Int = this@toUserEntity.gender
): UserEntity = UserEntity(id=id,username=username,password=password,gender=gender)
```

```
// @Konvert
// 转换为如下对象
data class UserVO(
    val id: String,
    val name: String,
    val gender: GenderEnum
)

enum class GenderEnum {
    MALE, FEMALE;
}

object GenderEnumConverter : Konvert.KonvertBy<Int, GenderEnum> {
    override fun Int.forward(): GenderEnum {
        return GenderEnum.values()[this]
    }

    override fun GenderEnum.backward(): Int {
        return this.ordinal
    }
}

// 生成的代码
**
 *  Auto generated code by @Konvert
 */
fun UserEntity.toUserVO(
  id: String = this@toUserVO.id.toString(),
  name: String = this@toUserVO.username,
  gender: GenderEnum = with(GenderEnumConverter) { this@toUserVO.gender.forward() }
): UserVO = UserVO(id=id,name=name,gender=gender)

/**
 *  Auto generated code by @Konvert
 */
fun UserVO.toUserEntity(
  id: Long = this@toUserEntity.id.toLong(),
  username: String = this@toUserEntity.name,
  password: String = "",
  gender: Int = with(GenderEnumConverter) { this@toUserEntity.gender.backward() }
): UserEntity = UserEntity(id=id,username=username,password=password,gender=gender)
```

## 相关 API 说明
转换规则
* 如果转换至 String 类型，原类型不匹配时会调用 `toString()`
* 如果转换至基础数据类型，转换字段缺失时会使用默认类型
* 如果转换至允许为 null 类型，原类型不匹配时会使用默认值 null
* 如果转换至引用类型（String 除外）或者找不到映射需要在转换方法显式赋值

# 下一步
* 代码重构，新增测试用例
* 支持引用类型默认值
* 支持嵌套对象
* 支持 Java
* 已知 BUG 修复
* 支持映射失败字段获取原类型的构造函数参数默认值，或者成员变量默认值（目前 Kotlin KAPT 已支持获取[成员变量默认值](https://youtrack.jetbrains.com/issue/KT-30164)，暂不支持获取[函数参数默认值](https://youtrack.jetbrains.com/issue/KT-29355)）

# 已知 BUG
* 相同 name 在 @Konvertable 冲突
* @Konvertable 参数合法性校验以及友好报错
* KonvertBy 目前使用 Class 报错或者使用 Companion 报错

# 最后
Konverter 源码在 [GitHub](https://github.com/lexcao/konverter)

相关的样例代码 [GitHub](https://github.com/lexcao/konverter-demo)
