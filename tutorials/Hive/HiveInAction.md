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















































