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









