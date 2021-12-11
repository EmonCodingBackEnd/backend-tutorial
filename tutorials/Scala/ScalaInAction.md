# Maven实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

1. 请确保JDK8或者JDK11已安装

```bash
[emon@emon ~]$ java -version
```

2. 下载

官网地址：https://scala-lang.org/

下载地址：https://scala-lang.org/download/

旧版下载地址：https://scala-lang.org/download/all.html

这里下载2.12.10经典版

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz
```

3. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Scala
```

4. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/scala-2.12.10.tgz -C /usr/local/Scala/
```

5. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Scala/scala-2.12.10/ /usr/local/scala
```

6. 配置环境变量

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/scala.sh
export SCALA_HOME=/usr/local/scala
export PATH=$SCALA_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

7. 校验

```bash
[emon@emon ~]$ scala -version
Scala code runner version 2.12.10 -- Copyright 2002-2019, LAMP/EPFL and Lightbend, Inc.
[emon@emon ~]$ scala
Welcome to Scala 2.12.10 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_251).
Type in expressions for evaluation. Or try :help.

scala> 1+2
res0: Int = 3
```



