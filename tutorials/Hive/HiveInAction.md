# Hive实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装Hive](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#6%E5%AE%89%E8%A3%85hivecdh%E7%89%88)

# 二、Hive详解

## 2.1、什么是Hive

Hive是建立在Hadoop上的数据仓库基础架构。它提供了一系列的工具，可以用来进行数据提取转化加载，可以简称为ETL。

Hive定义了简单的类SQL查询语言，称为HQL，它允许熟悉SQL的用户直接查询Hadoop中的数据，同时，这个语言也允许熟悉MapReduce的开发者开发自定义的MapReduce任务来处理内建的SQL函数无法完成的复杂的分析任务。

Hive中包含的有SQL解析引擎，它会将SQL语句转译成M/R Job，然后在Hadoop中执行。

通过这里的分析我们可以了解到Hive可以通过sql查询Hadoop中的数据，并且sql底层也会转化成MapReduce任务，所以Hive是基于Hadoop的。

## 2.2、Hive的数据存储

Hive的数据存储基于Hadoop的HDFS，Hive没有专门的数据存储格式。

Hive默认可以直接加载文本文件（TextFile），还支持SequenceFile，RCFile等文件格式。

针对普通文本数据，我们在创建表时，只需要指定数据的列分隔符与行分隔符，Hive即可解析里面的数据。

## 2.3、Hive的系统架构

![image-20220129130122009](images/image-20220129130122009.png)

- 用户接口：包括CLI、JDBC/ODBC、WebGUI
  - CLI：即Shell命令行，表示我们可以通过shell命令行操作Hive
  - JDBC/ODBC：是Hive的Java操作方式，与使用传统数据库JDBC的方式类似。
- 元数据存储（Metastore）：注意，这里的存储是名词，Metastore表示是一个存储系统。Hive中的元数据包括表的相关信息，Hive会将这些元数据存储在Metastore中，目前Metastore只支持mysql、derby。
- Driver：包含 编译器、优化器、执行器。编译器、优化器、执行器可以完成Hive的查询语句从词法分析、语法分析、编译、优化以及查询计划的生成。生成的查询计划最终存储在HDFS中，并在随后由MapReduce调用执行。
- Hadoop：Hive会使用HDFS进行存储，利用MapReduce进行计算。Hive的数据存储在HDFS中，大部分的查询由MapReduce完成（特例：select * from table 不会生成MapReduce任务，如果在SQL语句后面再增加where过滤条件就会生成MapReduce任务了。）

在这里需要注意一点：从Hive2开始，其实官方就不建议默认使用MapReduce引擎了，而是建议使用Tez引擎或者是Spark引擎，不过目前一直到最新的3.x版本中MapReduce还是默认的执行引擎。

### 2.3.1、大数据计算引擎

- 第一代：MapReduce

- 第二代：Tez

  - > 它是源于MapReduce，主要和Hive结合在一起使用。

- 第三代：Spark

  - > Spark在当时属于一个划时代的产品，改变了之前基于磁盘的计算思路，而是采用内存计算。
    >
    > 注意：Spark也是支持在YARN上执行的。

- 第四代：Flink

  - > Flink是一个可以支持纯实时数据计算的计算引擎，在实时计算领域要优于Spark。
    >
    > 注意：Flink也是支持在YARN上执行的。

所以发现没有，MapReduce、Tez、Spark、Flink这些计算引擎都是支持在yarn上执行的，所以说Hadoop2中对架构的拆分是非常明智的。

### 2.3.2、Metastore

- Metastore：是Hive元数据的集中存放地。
- 元数据包括表的名字，表的列和分区及其属性，表的数据所在目录等。
- Metastore默认使用内嵌的Derby数据库作为存储引擎，推荐使用MySQL数据库作为外置存储引擎。

### 2.3.3、Hive VS MySQL

|              | Hive       | MySQL    |
| ------------ | ---------- | -------- |
| 数据存储位置 | HDFS       | 本地磁盘 |
| 数据格式     | 用户定义   | 系统决定 |
| 数据更新     | 不支持     | 支持     |
| 索引         | 有，但较弱 | 有       |
| 执行         | MapReduce  | Executor |
| 执行延迟     | 高         | 低       |
| 可扩展性     | 高         | 低       |
| 数据规模     | 大         | 小       |

### 2.3.4、数据库 VS 数据仓库

- 数据库：传统的关系型数据库主要应用在基本的事务处理，例如银行交易；支持增删改查。
- 数据仓库：主要做一些复杂的分析操作，侧重决策支持，相对数据库而言，数据仓库分析的数据规模要大得多；只支持查询。
- 数据库与数据仓库的本质区别就是 `OLTP` 与 `OLAP` 的区别。



### 2.3.5、OLTP VS OLAP

- OLTP(On-Line Transaction Processing)：操作型处理，成为联机事务处理，也可以成为面向交易的处理系统，它是针对具体业务在数据库联机的日常操作，通常对少数记录进行查询、修改。用户较为关心操作的相应时间、数据的安全性、完整性等问题。
- OLAP(On-Line Analytical Processing)：分析型处理，称为联机分析处理，一般针对某些主题历史数据进行分析，支持管理决策。



## 2.4、Hive的使用

操作Hive可以在Shell命令行下操作，或者是使用JDBC代码的方式操作。

### 2.4.1、命令行方式

- hive命令
- beeline命令：需要开启 `hiveserver2` 服务

### 2.4.2、JDBC方式

启动 `hiveserver2`服务后，可通过编程方式JDBC连接到hive。

### 2.4.3、Set命令的使用

在hive命令行中可以使用`set`命令临时设置一些参数的值，其实就是临时修改`hive-site.xml`中参数的值。

不过通过set命令设置的参数只在当前会话有效，退出重新打开就无效了。

如果想要对当前机器上的当前用户有效的话可以把命令配置在`~/.hiverc`文件中。



在`hive-site.xml`中有一个参数是`hive.cli.print.current.db`，这个参数可以显示当前所在的数据库名称，默认值为 false。

```sql
hive> set hive.cli.print.current.db=true;
hive (default)> 
```

还有一个参数`hive.cli.print.header`可以控制获取结果的时候显示字段名称，这样看起来会比较清晰。

```sql
hive (default)> select * from t1;
OK
1	zs
Time taken: 1.641 seconds, Fetched: 1 row(s)

hive (default)> set hive.cli.print.header=true;

hive (default)> select * from t1;
OK
t1.id	t1.name
1	zs
Time taken: 0.138 seconds, Fetched: 1 row(s)
```

以上两个可以作为个人习惯，放入`~/.hiverc`即可！

```bash
[emon@emon ~]$ vim ~/.hiverc
set hive.cli.print.current.db=true;
set hive.cli.print.header=true;
```

### 2.4.4、Hive的日志冲突

```bash
[emon@emon ~]$ hive
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/HBase/hbase-1.2.0-cdh5.16.2/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/Hadoop/hadoop-3.3.1/share/hadoop/common/lib/slf4j-log4j12-1.7.30.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.slf4j.impl.Log4jLoggerFactory]
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/Hive/apache-hive-3.1.2-bin/lib/log4j-slf4j-impl-2.10.0.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/Hadoop/hadoop-3.3.1/share/hadoop/common/lib/slf4j-log4j12-1.7.30.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: See http://www.slf4j.org/codes.html#multiple_bindings for an explanation.
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]
Hive Session ID = e0884b82-ce89-4fa4-a44c-d7d9cdaf8bdf

Logging initialized using configuration in jar:file:/usr/local/Hive/apache-hive-3.1.2-bin/lib/hive-common-3.1.2.jar!/hive-log4j2.properties Async: true
Hive Session ID = 49b99f56-45ad-46d1-8552-46b7c39502fb
Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
hive (default)>
```

我们每次进入hive命令行时都会有这么一堆日志，看着不简洁，如何去掉？

日志显示有重复的日志依赖，这里可以Hadoop之外的日志jar引入：

```bash
SLF4J: Class path contains multiple SLF4J bindings.
SLF4J: Found binding in [jar:file:/usr/local/HBase/hbase-1.2.0-cdh5.16.2/lib/slf4j-log4j12-1.7.5.jar!/org/slf4j/impl/StaticLoggerBinder.class]
SLF4J: Found binding in [jar:file:/usr/local/Hadoop/hadoop-3.3.1/share/hadoop/common/lib/slf4j-log4j12-1.7.30.jar!/org/slf4j/impl/StaticLoggerBinder.class]
```

去掉重复的日志依赖：

```bash
[emon@emon ~]$ mv /usr/local/hive/lib/log4j-slf4j-impl-2.10.0.jar /usr/local/hive/lib/log4j-slf4j-impl-2.10.0.jar.bak
[emon@emon ~]$ mv /usr/local/hbase/lib/slf4j-log4j12-1.7.5.jar /usr/local/hbase/lib/slf4j-log4j12-1.7.5.jar.bak
```

再次进入hive命令行，就正常了：

```bash
[emon@emon ~]$ hive
Hive Session ID = 5b863280-c7f2-44e3-a0de-42805288283b

Logging initialized using configuration in jar:file:/usr/local/Hive/apache-hive-3.1.2-bin/lib/hive-common-3.1.2.jar!/hive-log4j2.properties Async: true
Hive Session ID = 938ca9dd-83d0-4122-a694-e4113b5f969d
Hive-on-MR is deprecated in Hive 2 and may not be available in the future versions. Consider using a different execution engine (i.e. spark, tez) or using Hive 1.X releases.
hive (default)>
```















































