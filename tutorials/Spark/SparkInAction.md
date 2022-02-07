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
spark.eventLog.dir=hdfs://emon:8020/tmp/logs/spark-events
# [新增]
spark.history.fs.logDirectory=hdfs://emon:8020/tmp/logs/spark-events
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
export SPARK_HISTORY_OPTS="-Dspark.history.ui.port=18080 -Dspark.history.fs.logDirectory=hdfs://emon:8020/tmp/logs/spark-events"
```

- 确保日志目录存在

```bash
# 如果日志目录不存在，启动时会报错
[emon@emon ~]$ hdfs dfs -mkdir -p hdfs://emon:8020/tmp/logs/spark-events
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

可访问如下地址：

http://emon:18080

- 停止

```bash
[emon@emon ~]$ /usr/local/spark/sbin/stop-history-server.sh 
```



## 2.5、RDD持久化与共享变量

### 2.5.1、RDD持久化

- RDD持久化原理

Spark中有一个非常重要的功能就是可以对RDD进行持久化。

当对RDD执行持久化操作时，每个节点都会讲自己操作的RDD的partition数据持久化到内存中，并且在之后对该RDD的反复使用中，直接使用内存中缓存的partition数据。

这样的话，针对一个RDD反复执行多个操作的场景，就只需要对RDD计算一次即可，后面直接使用该RDD，而不需要反复计算多次该RDD。

正常情况下RDD的数据使用过后是不会一直保存的，巧妙使用RDD持久化，在某些场景下，对Spark应用程序的性能有很大提升。特别是对于迭代式算法和快速交互式应用来说，RDD持久化，是非常重要的。

要持久化一个RDD，只需要调用它的 cache() 或者 persist() 方法就可以了。

在该RDD第一次被计算出来时，就会直接缓存在每个节点中。而且Spark的持久化机制还是自动容错的，如果持久化的RDD的任何partition数据丢失了，那么Spark会自动通过其源RDD，使用transformation算子重新计算该partition的数据。

cache()和persist()的区别在于：
cache()是persist()的一种简化方式:  cache() = persist() = persist(StorageLevel.MEMORY_ONLY)

- RDD持久化策略

| 策略                             | 介绍                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| MEMORY_ONLY                      | 以非序列化的方式持久化在JVM内存中                            |
| MEMORY_AND_DISK                  | 同上，但是当某些partition无法存储在内存中时，会持久化到磁盘中 |
| MEMORY_ONLY_SER                  | 同MEMORY_ONLY，但是会序列化                                  |
| MEMORY_AND_DISK_SET              | 同MEMORY_AND_DISK，但是会序列化                              |
| DISK_ONLY                        | 以非序列化的方式完全存储到磁盘上                             |
| MEMORY_ONLY_2、MEMORY_AND_DISK_2 | 尾部加了2的持久化级别，表示会将持久化数据复制一份，保存到其他节点，从而在数据丢失时，不需要重新计算，只需要使用备份数据即可。 |

- 如何选择RDD持久化策略

Spark提供了多种持久化级别，主要是为了在CPU和内存消耗之间进行取舍。

下面是一些通用的持久化级别的选择建议：

1. 优先使用MEMORY_ONLY，纯内存速度最快，而且没有序列号不需要消耗CPU进行反序列化操作，缺点就是比较耗内存。
2. MEMORY_ONLY_SER，将数据进行序列化存储，纯内存操作还是非常快，只是在使用的时候需要消耗CPU进行反序列化。

> 注意：
>
> 如果需要进行数据的快速失败恢复，那么就选择带有后缀为_2的策略，进行数据的备份，这样在失败时，就不需要重新计算了。
>
> 能不使用DISK相关的策略，就不要使用，因为有的时候，从磁盘读取数据，还不如重新计算一次。

### 2.5.2、共享变量

- 共享变量的工作原理

Spark还有一个非常重要的特性就是共享变量。

默认情况下，如果在一个算子函数中使用到了某个外部的变量，那么这个变量的值会被拷贝到每个task中。此时每个task只能操作自己的那份变量数据。如果多个task想要共享某个变量，那么这种方式是做不到的。

- Spark提供了两种共享变量

一种是Broadcast Variable（广播变量）

另一种是Accumulator（累加变量）

#### 2.5.2.1、Broadcast Variable

Broadcast Variable会将使用到的变量，仅仅为每个节点拷贝一份，而不会为每个task都拷贝一份副本，因此其最大的作用，就是减少变量到各个节点的网络传输消耗，以及在各个节点上的内存消耗。

通过调用SparkContext的broadcast()方法，针对某个变量创建广播变量。

**注意：广播变量，是只读的。**

然后在算子函数内，使用到广播变量时，每个节点只会拷贝一份副本。可以使用广播变量的value()方法获取值。

![image-20220206135413083](images/image-20220206135413083.png)



## 2.6、sortByKey如何实现全局排序



![image-20220207121651821](images/image-20220207121651821.png)

