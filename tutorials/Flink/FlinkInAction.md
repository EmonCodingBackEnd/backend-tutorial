#  Flink实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装Spark](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#4%E5%AE%89%E8%A3%85spark)



# 二、快速了解Flink

## 2.1、什么是FLink

Apache Flink是一个开源的分布式、高性能、高可用，准确的流处理框架。

- 分布式：表示Flink程序开源运行在很多台机器上；
- 高性能：表示Flink处理性能比较高；
- 高可用：表示Flink支持程序的自动重启机制；
- 准确的：表示Flink可以保证处理数据的准确性。

Flink支持流处理和批处理，虽然我们刚才说了Flink是一个流处理框架，但是它也支持批处理。其实对对于Flink而言，它是一个流处理框架，批处理只是流处理的一个极限特例而已。

![官方流程图](images/flink-home-graphic.png)

左边是数据源，从这里面可以看出来，这些数据是实时产生的一些日志，或者是数据库、文件系统、KV存储系统中的数据。

中间是Flink，负责对数据进行处理。

右边是目的地，Flink可以将计算好的数据输出到其他应用中，或者存储系统中。

## 2.2、Flink架构图

下面我们来看一下Flink的架构图。

![image-20220303092702254](images/image-20220303092702254.png)

首先图片最下面表示Flink的一些部署模式，支持Local和集群（Standalone，YARN），也支持在云上部署。

往上一层是Flink的核心，分布式的流处理引擎。

再往上面是Flink的API和类库。

主要有两大块API，DataStream API和DataSet API，分别做流处理和批处理。

针对DataStream API这块，支持复杂事件处理，和table操作，其实也是支持SQL操作的。

针对DataSet API，支持FlinkML机器学习，Gelly图计算，table操作，这块也是支持SQL操作的。

其实从这可以看出来，Flink也是有自己的生态圈的，里面包含了实时计算、离线计算、机器学习、图计算、Table和SQL计算等等。

所以说它和Spark还是有点像的，不过它们两个的底层计算引擎是有本质区别的。



## 2.3、Flink三大核心组件

- Data Source：数据源（负责接收数据）
- Transformations：算子（负责对数据进行处理）
- Data Sink：输出组件（负责把计算好的数据输出到其他存储介质中）



## 2.4、Flink的流处理与批处理

记下来我们来分析一下Flink这个计算引擎的核心内容。

- 在大数据处理领域，批处理和流处理一般被认为是两种不同的任务，一个大数据框架一般会被设计为只能处理其中一种任务。

例如Storm只支持流处理任务，而MapReduce、Spark只支持批处理任务。Spark Streaming是Spark之上支持流处理任务的子系统，看似是一个特例，其实并不是——Spark Streaming采用了一种micro-batch的架构，就是把输入的数据流切分成细粒度的batch，并为每一个batch提交一个批处理的Spark任务，所以Spark Streaming本质上执行的还是批处理任务，和Storm这种流式的数据处理方式是完全不同的。

- Flink通过灵活的执行引擎，能够同时支持批处理和流处理

在执行引擎这一层，流处理系统与批处理系统最大的不同在于节点之间的数据传输方式。

对于一个流处理系统，其节点间数据传输的标准模型是：当一条数据被处理完成后，序列化到缓存中，然后立刻通过网络传输到下一个节点，由下一个节点继续处理。

这就是典型的一条一条处理。

而对于一个批处理系统，其节点间数据传输的标准模型是：当一条数据被处理完成后，序列化到缓存中，并不会立刻通过网络传输到下一个节点，当缓存写满的时候，就持久化到本地硬盘上，当所有数据都被处理完成后，才开始将处理后的数据通过网络传输到下一个节点。

这两种数据传输模式是两个极端，对应的是流处理系统对低延迟的要求和批处理系统对高吞吐量的要求Flink的执行引擎采用了一种十分灵活的方式，同时支持了这两种传输模型。

Flink以固定的缓存块为单位进行网络数据传输，用户可以通过缓存块超时值指定缓存块的传输时机。如果缓存块的超时值为0，则Flink的数据传输方式类似前面所说的流处理系统的标准模型，此时系统可以获得最低的处理延迟。

如果缓存块的超时值为无限大，则Flink的数据传输方式类似前面所说的批处理系统的标准模型，此时系统可以火鹅最高的吞吐量。

这样就比较灵活了，其实底层还是流失计算模型，批处理只是一个极限特例而已。

看一下这个图中显示的三种数据传输模型。

![image-20220303164044353](images/image-20220303164044353.png)

第一个：一条一条处理；

第二个：一批一批处理；

第三个：按照缓存块进行处理，缓存块可以无限小，也可以无限大，这样就可以同时支持流处理和批处理了。

## 2.5、Storm VS SparkStreaming VS Flink

接下来我们来对比一下目前大数据领域中的三种实时计算引擎。

| 产品     | Storm         | SparkStreaming | Flink        |
| -------- | ------------- | -------------- | ------------ |
| 模型     | Native        | Micro-Batching | Native       |
| 产品     | Storm         | SparkStreaming | Flink        |
| 语义     | At-least-once | Exactly-once   | Exactly-once |
| 容错机制 | Ack           | Checkpoint     | Checkpoint   |
| 状态管理 | 无            | 基于DStream    | 基于操作     |
| 延时     | Low           | Medium         | Low          |
| 吞吐量   | Low           | High           | High         |

解释：

Native：表示来一条数据处理一条数据；

Mirco-Batch：表示划分小批，一小批一小批的处理数据；

组合式：表示是基础API，例如实现一个求和操作都需要写代码实现，比较麻烦，代码量会比较多；

声明式：表示提供的是封装后的高阶函数，例如filter、count等函数，可以直接使用，比较方便，代码量比较少。

## 2.6、实时计算框架如何选择

1：需要关注流数据是否需要进行状态管理；

2：消息语义是否有特殊要求At-least-once或者Exectly-once；

3：小型独立的项目，需要低延迟的场景，建议使用Storm；

4：如果项目中已经使用了Spark，并且秒级别的实时处理可以满足需求，建议使用SparkStreaming；

5：要求消息语义为Exectly-once，数据量较大，要求高吞吐低延迟，需要进行状态管理，建议选择Flink。



# 三、Flink快速上手使用

## 3.1、Flink任务日志

使用on yarn模式提交Flink任务时，在任务执行中，点击对应任务的Tracking UI列的ApplicationMaster，可以打开Flink界面。

操作路径：在yarn的web界面([http://emon:8088](http://emon:8088/)) ==> 点击对应任务的ApplicationMaster链接（任务执行完成后只能看到history链接）==>点击查看。

如果是history链接，点击进去是看不到flink内容的。

如何解决？开启Flink HistoryServer进程。

任意选择一个服务器开启，选择集群内的节点或者Flink的客户端节点都可以。

下面我们就在这个Flink的客户端节点上启动Flink的historyserver进程。

**说明**：该配置基于Hadoop的MapReduce任务日志配置，请先确保MapReduce的任务日志配置OK！

- `flink-conf.yml`

```bash
[emon@emon ~]$ vim /usr/local/flink/conf/flink-conf.yaml 
```

```yaml
# [新增]
#jobmanager.archive.fs.dir: hdfs:///completed-jobs/
jobmanager.archive.fs.dir: hdfs://emon:8020/tmp/logs/flink-jobs/
# [新增]
#historyserver.web.address: 0.0.0.0
historyserver.web.address: emon
# [新增]
#historyserver.web.port: 8082
historyserver.web.port: 8082
# [新增]
#historyserver.archive.fs.dir: hdfs:///completed-jobs/
historyserver.archive.fs.dir: hdfs://emon:8020/tmp/logs/flink-jobs/
# [新增]
#historyserver.archive.fs.refresh-interval: 10000
historyserver.archive.fs.refresh-interval: 10000
```

注意：在哪个节点上启动Flink的historyserver进程，`historyserver.web.address`的值里面就指定哪个节点的主机名信息。

- 确保日志目录存在

由于不是在根目录(hdfs://emon:8020/)下创建日志目录，需要确保目录已存在。

```bash
# 如果日志目录不存在，启动时会报错
[emon@emon ~]$ hdfs dfs -mkdir -p hdfs://emon:8020/tmp/logs/flink-jobs
```

- 启动

```bash
[emon@emon ~]$ /usr/local/flink/bin/historyserver.sh start
# 命令行输出结果
Starting historyserver daemon on host emon.
```

- 验证

```bash
# 其他进程忽略显示，看到如下进程表示Flink的HistoryServer启动成功
[emon@emon ~]$ jps
13682 HistoryServer
```

访问：

http://emon:8082/#/overview

- 停止

```bash
[emon@emon ~]$ /usr/local/flink/bin/historyserver.sh stop
# 命令行输出结果
Stopping historyserver daemon (pid: 13682) on host emon.
```



















































































