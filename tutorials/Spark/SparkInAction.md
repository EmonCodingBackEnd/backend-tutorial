# Spark实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装Spark](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#4%E5%AE%89%E8%A3%85spark)



# 二、Spark工作与架构原理

![image-20220203115142762](images/image-20220203115142762.png)



## 2.1、什么是RDD

RDD通常通过Hadoop上的文件，即HDFS文件进行创建，也可以通过程序中的集合来创建。

RDD是Spark提供的核心抽象，全称为 Resillient Distributed Dataset，即弹性分布式数据集。

### 2.1.1、DD的特点

- 弹性：RDD数据默认情况下存放在内存中，但是在内存资源不足时，Spark也会自动将RDD数据写入磁盘。
- 分布式：RDD在抽象上来说是一种元素数据的集合，它是被分区的，每个分区分布在集群中的不同节点上，从而让RDD中的数据可以被并行操作。
- 容错性：RDD最重要的特性就是提供了容错性，可以自动从节点失败中恢复过来。

如果某个节点上的RDD partition，因为节点故障，导致数据丢了，那么RDD会自动通过自己的数据来源，重新计算该partition的数据。



## 2.2、Spark架构相关进程

注意：在这里是以Spark的standalone集群为例进行分析。

- Driver：

我们编写的Spark程序就在Driver（进程）上，由Driver进程负责执行。

Driver进程所在的节点可以是Spark集群的某一个节点或者就是我们提交Spark程序的客户端节点。具体Driver进程在哪个节点上启动是由我们提交任务时指定的参数决定的，这个后面我们会详细分析。

- Master：

集群的主节点中启动的进程。

主要负责集群资源的管理和分配，还有集群的监控等。

- Worker：

集群的从节点中启动的进程。

主要负责启动其他进程来执行具体数据的处理和计算任务。

- Executor：

此进程由Worker负责启动，主要为了执行数据处理和计算。

- Task：

由Executor负责启动的线程，它是真正干活的。



## 2.3、架构原理

![image-20220203121514209](images/image-20220203121514209.png)



## 2.4、Spark任务日志

### 2.4.1、在yarn的web界面查看日志

使用on yarn模式提交Spark任务时，在任务执行中，点击对应任务的Tracking UI列的ApplicationMaster，可以打开Spark界面。

操作路径：在yarn的web界面([http://emon:8088](http://emon:8088/)) ==> 点击对应任务的ApplicationMaster链接（任务执行完成后只能看到history链接）==>点击查看。

如果是history链接，点击进去查看logs链接日志时，会提示`Failed redirect for container_xxx_xxx_xxx_xxx`。

如何解决？开启 Spark HistoryServer 进程。

任意选择一个服务器开启spark的historyserver进程都可以，选择集群内的节点，或者选择spark的客户端节点都可以。

下面我们就在这个spark的客户端节点上启动spark的historyserver进程。

**说明**：该配置基于Hadoop的MapReduce任务日志配置，请先确保MapReduce的任务日志配置OK！

需要修改`spark-defaults.conf`和`spark-env.sh`。

- `spark-defaults.conf`

如果目前尚不存在`spark-defaults.conf`文件，可以从`spark-defaults.conf.template`复制一份重命名为`spark-defaults.conf`。

```bash
[emon@emon ~]$ cp /usr/local/spark/conf/spark-defaults.conf.template /usr/local/spark/conf/spark-defaults.conf
[emon@emon ~]$ vim /usr/local/spark/conf/spark-defaults.conf
```

```properties
# [新增]
spark.eventLog.enabled=true
# [新增]
spark.eventLog.compress=true
# [新增]
spark.eventLog.dir=hdfs://emon:8020/tmp/logs/emon/spark-logs
# [新增]注意里面的emon表示hadoop的用户
spark.history.fs.logDirectory=hdfs://emon:8020/tmp/logs/emon/spark-logs
# [新增]
spark.yarn.historyServer.address=http://emon:18080
# [新增]
spark.yarn.historyServer.allowTracking=true
```

注意：在哪个节点上启动spark的historyserver进程，`spark.yarn.historyServer.address`的值里面就指定哪个节点的主机名信息。

- `spark-env.sh`

```bash
[emon@emon ~]$ vim /usr/local/spark/conf/spark-env.sh
```

```properties
# [新增]
export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.fs.logDirectory=hdfs://emon:8020/tmp/logs/emon/spark-logs"
```

- 确保日志目录存在

```bash
# 如果日志目录不存在，启动时会报错
[emon@emon ~]$ hdfs dfs -mkdir -p hdfs://emon:8020/tmp/logs/emon/spark-logs
```

- 启动

```bash
[emon@emon ~]$ /usr/local/spark/sbin/start-history-server.sh 
```

- 验证

```bash
# 其他进程忽略显示，看到如下进程表示Spark的HistoryServer启动成功
[emon@emon ~]$ jps
17287 HistoryServer
```

- 停止

```bash
[emon@emon ~]$ /usr/local/spark/sbin/stop-history-server.sh 
```

