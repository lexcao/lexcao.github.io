---
title: Generate Converter for Kotlin Class by KAPT
date: 2020-04-13
tags: [Practice, Kotlin, Backend, Library]
---

# Background

In web backend development, the operation of an entity need to code a number of similar classes to handle request (avoiding the direct use of entities), which resulting in related terminology:
* PO (*Persistent Object*)
* DTO (*Data Transfer Object*)
* BO (*Business Object*)
* VO (*View Object*)

Most of these classes trim a few fields directly from the entity. For example, by using `OrderEntity` in a request to create an order, it would process like following:

```
1. Receive request body `CreateOrderRequest` as DTO
2. Construct `OrderQuery` as BO to query orders
3. Construct `QueryEntity` as PO for the order persistent
4. Construct `OrderBO` as BO for further service consumption
5. Respond body `CreateOrderResponse` as VO
```  

You will see, there are 4 classes derived from OrderEntity which are just partial cropping of the entity, but a lot of repetitive code has to be written (yes, you can copy and paste). Of course, you should use inheritance if there is going to be a new field differed from OrderEntity.

In web backend development with Kotlin, the syntax features of the `data class` offer many advantages (getter, setter, equals, hashCode...), however, you can't avoid creating similar duplicate classes. 

So, `Konverter` is here to solve classes which trimmed fields from entity. Additionally, it supports to generate the conversion functions between two classes. 

> Note, till now it only supports on Kotlin, because the generated code of conversion function implemented by extension function and only generating Kotlin code.

# What is Konverter
Konverter is automated generating the classes which trimmed from entity, and those conversion functions by [*KAPT (Kotlin Annotation Processing Tool*](https://kotlinlang.org/docs/reference/kapt.html]) annotation processing and [*Kotlin Poet*](https://github.com/square/kotlinpoet) code generating.

There are two main annotations: 
* `@Konvertable` generates trimmed classes and respondent converter;
* `@Konvert` generates the converter for specified class.

Let's see how it works.

# How to use

## 1. Add dependency
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

## 2. Add annotations
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

## 3. Then `compileKotlin` to process generation
### For `@Konvertable`
```
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
### For `@Konvert`
```
// the class to convert to
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

// generated code
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

## API notes
the rules of conversion and generation
* If converting to String type, it will use toString() while the type is not match;
* If converting to primitive type, it will use default value of primitive type when missing;
* If converting to nullable type, it will use null for default value when missing;
* It will need be assigned explicitly when converting to reference type (excepting String) or unknown type.

# What next

* code optimization and test case
* support the default value of object and collection
* support nested class
* support for Java
* fix bugs
* support for using the default value of parameters on constructors or fields on class from original when missing (from now, Kotlin KAPT is only support for [*default value of fields*](https://youtrack.jetbrains.com/issue/KT-30164), but not for [*parameters*](https://youtrack.jetbrains.com/issue/KT-29355))

# Source code
* [Konverter in Github](https://github.com/lexcao/konverter)
* [Konverter-demo in Github](https://github.com/lexcao/konverter-demo)
