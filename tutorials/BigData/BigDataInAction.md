# BigData实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]



# 一、基础软件安装

## 1、安装ZooKeeper

1. 下载

官网地址： https://zookeeper.apache.org/index.html

下载地址： https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/

版本3.5.5带来的坑：https://blog.csdn.net/jiangxiulilinux/article/details/96433560

> wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz --no-check-certificate

这里以cdh版学习：

**注意**：无法避开收费墙下载，暂时无解

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/ZooKeeper
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/zookeeper-3.4.5-cdh5.16.2.tar.gz -C /usr/local/ZooKeeper/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/ZooKeeper/apache-zookeeper-3.7.0-bin/ /usr/local/zoo
```

5. 配置环境变量

在`/etc/profile.d`目录创建`zoo.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/zoo.sh
export ZK_HOME=/usr/local/zoo
export PATH=$ZK_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

6. 目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/zoo/{data,logs}
```

7. 配置文件

- 复制`zoo_sample.cfg`到`zoo.cfg`

```bash
[emon@emon ~]$ cp /usr/local/zoo/conf/zoo_sample.cfg /usr/local/zoo/conf/zoo.cfg
```

- 编辑`zoo.cfg`文件

```bash
[emon@emon ~]$ vim /usr/local/zoo/conf/zoo.cfg 
```

```bash
# [修改]
dataDir=/tmp/zookeeper => dataDir=/usr/local/zoo/data
# [新增]
dataLogDir=/usr/local/zoo/logs
# [新增]修改默认的8080端口
admin.serverPort=8090
```

8. 启动与停止

- 启动（端口号2181）

```bash
[emon@emon ~]$ zkServer.sh start
```

- 校验

```bash
[emon@emon ~]$ jps
44611 QuorumPeerMain
```

- 停止

```bash
[emon@emon ~]$ zkServer.sh stop
```

- 状态

```bash
[emon@emon ~]$ zkServer.sh status
```

9. 连接

- 访问8090端口的服务

```bash
# 比如
http://192.168.1.116:8090/commands/stat
```

- 远程连接

```bash
[emon@emon ~]$ zkCli.sh -server 192.168.1.116:2181
```

- 本地连接

```bash
[emon@emon ~]$ zkCli.sh
```

- 退出（在链接成功后，使用命令quit退出）

```bash
[zk: localhost:2181(CONNECTED) 0] quit
```

## 2、安装kafka（使用外部的ZooKeeper）

1. 下载

官网地址：http://kafka.apache.org/

下载地址：http://kafka.apache.org/downloads

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/2.3.0/kafka_2.12-2.3.0.tgz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Kafka
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/kafka_2.12-2.3.0.tgz -C /usr/local/Kafka/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Kafka/kafka_2.12-2.3.0/ /usr/local/kafka
```

5. 配置环境变量

在`/etc/profile.d`目录创建`kafka.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/kafka.sh
export PATH=/usr/local/kafka/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

6. 目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/kafka/logs
```

7. 配置文件

- 编辑`server.properties`配置文件

```bash
[emon@emon ~]$ vim /usr/local/kafka/config/server.properties 
```

```bash
# [修改]
log.dirs=/tmp/kafka-logs => log.dirs=/usr/local/kafka/logs
```

8. 编写启动停止脚本

- 启动脚本

```bash
[emon@emon ~]$ vim /usr/local/kafka/kafkaStart.sh
```

```bash
# 启动kafka
/usr/local/kafka/bin/kafka-server-start.sh -daemon /usr/local/kafka/config/server.properties
```

- 停止脚本

```bash
[emon@emon ~]$ vim /usr/local/kafka/kafkaStop.sh
```

```bash
# 关闭kafka
/usr/local/kafka/bin/kafka-server-stop.sh -daemon /usr/local/kafka/config/server.properties
```

- 修改可执行权限

```bash
[emon@emon ~]$ chmod +x /usr/local/kafka/kafkaStart.sh 
[emon@emon ~]$ chmod +x /usr/local/kafka/kafkaStop.sh 
```

9. 启动与停止

- 启动

```bash
[emon@emon ~]$ /usr/local/kafka/kafkaStart.sh
```

- 停止

```bash
[emon@emon ~]$ /usr/local/kafka/kafkaStop.sh
```

10. 创建`topic`

- 创建

```bash
[emon@emon ~]$ kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test-kafka-topic
# 命令执行结果
Created topic test-kafka-topic.
```

- 查看topic列表

```bash
[emon@emon ~]$ kafka-topics.sh --list --zookeeper localhost:2181
# 命令执行结果
test-kafka-topic
```

- 查看单个topic详情

```bash
[emon@emon logs]$ kafka-topics.sh --describe --zookeeper localhost:2181 --topic test-kafka-topic
# 命令执行结果
Topic:test-kafka-topic	PartitionCount:1	ReplicationFactor:1	Configs:
	Topic: test-kafka-topic	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
```



11. 测试生产者消费者

- 生产者

```bash
[emon@emon ~]$ kafka-console-producer.sh --broker-list localhost:9092 --topic test-kafka-topic
```

- 消费者

```bash
[emon@emon ~]$ kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-kafka-topic --from-beginning
```

## 3、安装HBase（使用外部的ZooKeeper）

1. 下载

官网地址：https://hbase.apache.org/

下载地址：https://hbase.apache.org/downloads.html

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/2.2.1/hbase-2.2.1-bin.tar.gz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/HBase
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/hbase-2.2.1-bin.tar.gz -C /usr/local/HBase/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/HBase/hbase-2.2.1/ /usr/local/hbase
```

5. 配置环境变量

在`/etc/profile.d`目录创建`hbase.sh`文件：

```
[emon@emon ~]$ sudo vim /etc/profile.d/hbase.sh
export PATH=/usr/local/hbase/bin:$PATH
```

使之生效：

```
[emon@emon ~]$ source /etc/profile
```

6. 目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/hbase/data
```

7. 配置文件

- 配置使用外部的`zookeeper`

```bash
[emon@emon ~]$ vim /usr/local/hbase/conf/hbase-env.sh 
```

```bash
# [修改]
export HBASE_MANAGES_ZK=true => export HBASE_MANAGES_ZK=false
```

- 配置`hbase-site.xml`

```bash
[emon@emon ~]$ vim /usr/local/hbase/conf/hbase-site.xml
```

```xml
<configuration>
    <!-- hbase数据存放的目录，若用本地目录，必须带上file://,否则hbase启动不起来 -->
    <property>
        <name>hbase.rootdir</name>
        <value>file:///usr/local/hbase/data</value>
    </property>

    <!-- zk的位置 -->
    <property>
        <name>hbase.zookeeper.quorum</name>
        <value>localhost</value>
        <description>the pos of zk</description>
    </property>

    <!-- 此处必须为true，不然hbase仍用自带的zk，若启动了外部的zookeeper，会导致冲突，hbase启动不起来 -->
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
</configuration>
```

8. 启动与停止

- 启动（端口号16000）

```bash
[emon@emon ~]$ start-hbase.sh 
```

- 停止

```bash
[emon@emon ~]$ stop-hbase.sh 
```

- 进入hbase命令行

```bash
[emon@emon ~]$ hbase shell
```

- 退出hbase命令行

```bash
hbase(main):014:0> exit
```

## 4、安装Scala

[Scala安装教程](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Scala/ScalaInAction.md)

## 5、安装Hadoop

目录规划：

| 目录                            | 作用                       |
| ------------------------------- | -------------------------- |
| /usr/local/hadoop/tmp           | 存放hadoop的hdfs数据的目录 |
| /usr/local/hadoop/custom/data   | 测试数据                   |
| /usr/local/hadoop/custom/lib    | jar库文件                  |
| /usr/local/hadoop/custom/shell  | 脚本文件                   |
| /usr/local/hadoop/custom/source | 存放spark等等源码的目录    |
|                                 |                            |

### 5.1、Hadoop单节点

#### 5.1.1、安装

1. 下载

Hadoop生态圈的软件下载地址：

https://archive.cloudera.com/cdh5/cdh/5/  （已无法下载）

**注意**：无法避开收费墙下载，暂时无解

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Hadoop
```

3. 解压安装

```bash
[emon@emon ~]$ tar -xzvf /usr/local/src/hadoop-2.6.0-cdh5.16.2.tar.gz -C /usr/local/Hadoop/
```

- hadoop软件包常见目录说明

  - `bin`： hadoop客户端名单

  - `etc/hadoop`： hadoop相关的配置文件存放目录

  - `sbin`： 启动hadoop相关进程的脚本

  - `share`： 常用例子

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/ /usr/local/hadoop
```

5. 配置环境变量

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/hadoop.sh
export HADOOP_HOME=/usr/local/hadoop
export PATH=$HADOOP_HOME/bin:$PATH
```

使之生效：

```
[emon@emon ~]$ source /etc/profile
```

#### 5.1.2、配置

##### 1.HDFS配置

- 确保JAVA_HOME指定到JDK8，查看配置

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/hadoop-env.sh 
```

可以看到`export JAVA_HOME=${JAVA_HOME}`，所以，如果JAVA_HOME环境变量是正确的即可。

- 配置`core-site.xml`

```bash
# 在打开的文件中<configuration>节点内添加属性
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/core-site.xml 
```

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
		<value>hdfs://emon:8020</value>
    </property>
</configuration>
```

- 配置`hdfs-site.xml`

```bash
# 修改副本数量
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/hdfs-site.xml 
```

```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/tmp</value>
    </property>
</configuration>
```

- 修改从节点

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/slaves 
```

```bash
#localhost
emon
```

**注意**：emon是主机名，可以在`/etc/hosts`配置，比如：`192.168.1.116   emon`

2. 启动HDFS

- 格式化HDFS文件系统：第一次执行的时候一定要格式化文件系统，不要重复执行。

```bash
[emon@emon ~]$ hdfs namenode -format
```

```bash
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   user = emon
STARTUP_MSG:   host = emon/192.168.1.116
STARTUP_MSG:   args = [-format]
STARTUP_MSG:   version = 2.6.0-cdh5.16.2
STARTUP_MSG:   classpath =......
......省略......
21/12/26 19:24:01 INFO namenode.NameNode: Caching file names occuring more than 10 times
21/12/26 19:24:01 INFO snapshot.SnapshotManager: Loaded config captureOpenFiles: false, skipCaptureAccessTimeOnlyChange: false, snapshotDiffAllowSnapRootDescendant: true
21/12/26 19:24:01 INFO util.GSet: Computing capacity for map cachedBlocks
21/12/26 19:24:01 INFO util.GSet: VM type       = 64-bit
21/12/26 19:24:01 INFO util.GSet: 0.25% max memory 889 MB = 2.2 MB
21/12/26 19:24:01 INFO util.GSet: capacity      = 2^18 = 262144 entries
21/12/26 19:24:01 INFO namenode.FSNamesystem: dfs.namenode.safemode.threshold-pct = 0.9990000128746033
21/12/26 19:24:01 INFO namenode.FSNamesystem: dfs.namenode.safemode.min.datanodes = 0
21/12/26 19:24:01 INFO namenode.FSNamesystem: dfs.namenode.safemode.extension     = 30000
21/12/26 19:24:01 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.window.num.buckets = 10
21/12/26 19:24:01 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.num.users = 10
21/12/26 19:24:01 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.windows.minutes = 1,5,25
21/12/26 19:24:01 INFO namenode.FSNamesystem: Retry cache on namenode is enabled
21/12/26 19:24:01 INFO namenode.FSNamesystem: Retry cache will use 0.03 of total heap and retry cache entry expiry time is 600000 millis
21/12/26 19:24:01 INFO util.GSet: Computing capacity for map NameNodeRetryCache
21/12/26 19:24:01 INFO util.GSet: VM type       = 64-bit
21/12/26 19:24:01 INFO util.GSet: 0.029999999329447746% max memory 889 MB = 273.1 KB
21/12/26 19:24:01 INFO util.GSet: capacity      = 2^15 = 32768 entries
21/12/26 19:24:01 INFO namenode.FSNamesystem: ACLs enabled? false
21/12/26 19:24:01 INFO namenode.FSNamesystem: XAttrs enabled? true
21/12/26 19:24:01 INFO namenode.FSNamesystem: Maximum size of an xattr: 16384
21/12/26 19:24:01 INFO namenode.FSImage: Allocated new BlockPoolId: BP-1296725921-192.168.1.116-1640517841222
21/12/26 19:24:01 INFO common.Storage: Storage directory /usr/local/hadoop/tmp/dfs/name has been successfully formatted.
21/12/26 19:24:01 INFO namenode.FSImageFormatProtobuf: Saving image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 using no compression
21/12/26 19:24:01 INFO namenode.FSImageFormatProtobuf: Image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 of size 321 bytes saved in 0 seconds .
21/12/26 19:24:01 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
21/12/26 19:24:01 INFO util.ExitUtil: Exiting with status 0
21/12/26 19:24:01 INFO namenode.NameNode: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at emon/192.168.1.116
************************************************************/
```

- 启动HDFS

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/start-dfs.sh 
```

```bash
21/12/26 19:25:51 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Starting namenodes on [emon]
emon: starting namenode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/logs/hadoop-emon-namenode-emon.out
emon: starting datanode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/logs/hadoop-emon-datanode-emon.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/logs/hadoop-emon-secondarynamenode-emon.out
21/12/26 19:26:06 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
```

**说明：**启动日志参见`/usr/local/hadoop/logs`

- 验证1

```bash
[emon@emon hadoop]$ jps
28930 Jps
28456 DataNode
28137 NameNode
28812 SecondaryNameNode
```

- 验证2

**注意**：确保防火墙停止，或者50070端口是放开的！

```bash
[emon@emon ~]$ sudo firewall-cmd --state
not running
```

访问地址：http://repo.emon.vip:50070

- 验证3

```bash
# 执行一个PI求解的任务
[emon@emon ~]$ hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0-cdh5.16.2.jar pi 2 3
```

3. 停止HDFS

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/stop-dfs.sh
```

4. 另外一种启动方式

> start-dfs.sh = 
>
> ​					hadoop-daemons.sh start namenode
>
> ​					hadoop-daemons.sh start datanode
>
> ​					hadoop-daemons.sh start secondarynamenode

> stop-dfs.sh = 
>
> ​					hadoop-daemons.sh stop namenode
>
> ​					hadoop-daemons.sh stop datanode
>
> ​					hadoop-daemons.sh stop secondarynamenode

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode
[emon@emon ~]$ /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode

[emon@emon ~]$ /usr/local/hadoop/sbin/hadoop-daemon.sh stop datanode
[emon@emon ~]$ /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode
```

##### 2.YARN配置

1. 配置

- 配置`mapred-site.xml`

```bash
[emon@emon ~]$ cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/mapred-site.xml
```

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

- 配置`yarn-site.xml`

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/yarn-site.xml 
```

```xml
<configuration>

<!-- Site specific YARN configuration properties -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <!-- 配置该属性为了解决错误 Caused by: java.io.IOException: Exceeded MAX_FAILED_UNIQUE_FETCHES; bailing-out. -->
    <property>
        <name>yarn.nodemanager.local-dirs</name>
        <value>/usr/local/hadoop/tmp/nm-local-dir</value>        
    </property>
</configuration>
```

2. 启动

- 启动YARN

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/start-yarn.sh 
```

```bash
starting yarn daemons
starting resourcemanager, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/logs/yarn-emon-resourcemanager-emon.out
emon: starting nodemanager, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/logs/yarn-emon-nodemanager-emon.out
```

**说明：**启动日志参见`/usr/local/hadoop/logs`

- 验证1

```bash
[emon@emon hadoop]$ jps
29632 Jps
28456 DataNode
28137 NameNode
29001 ResourceManager
29483 NodeManager
28812 SecondaryNameNode
```

- 验证2

访问地址：http://repo.emon.vip:8088

3. 停止YARN

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/stop-yarn.sh 
```

4. 另外一种方式

> start-yarn.sh=
>
> ​					yarn-daemon.sh start resourcemanager
>
> ​					yarn-daemon.sh start nodemanager

> stop-yarn.sh=
>
> ​					yarn-daemon.sh stop resourcemanager
>
> ​					yarn-daemon.sh stop nodemanager

### 5.3、Hadoop集群

#### 5.3.1、Hadoop集群规划

- 节点情况
  - HDFS
    - NN：NameNode
    - DN：DataNode
  - YARN
    - RM：ResourceManager
    - NM：NodeManager

| 机器名 | IP1-家庭      | IP2-公司   | 部署内容       |
| ------ | ------------- | ---------- | -------------- |
| emon   | 192.168.1.116 | 10.0.0.116 | NN、DN、RM、NM |
| emon2  | 192.168.1.117 | 10.0.0.117 | DN、NM         |
| emon3  | 192.168.1.118 | 10.0.0.118 | DN、NM         |

- hostname配置情况

```bash
[emon@emon ~]$ sudo vim /etc/hosts
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```

```bash
[emon@emon2 ~]$ sudo vim /etc/hosts
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```

```bash
[emon@emon3 ~]$ sudo vim /etc/hosts
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```

#### 5.3.2、前置安装

##### 1.配置SSH免密登录

<font color="gree">每一台服务器都需要安装Hadoop。</font>

- 检查SSH keys是否存在：（每一台服务器都需要做）

```bash
[emon@emon ~]$ ls -a ~/.ssh
```

- 如果不存在，生成SSH keys：（每一台服务器都需要做）

```bash
[emon@emon ~]$ ssh-keygen -t rsa -b 4096 -C "[邮箱]"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/emon/.ssh/id_rsa):`[默认]` 
Created directory '/home/emon/.ssh'.
Enter passphrase (empty for no passphrase): `[输入口令，其他用户切换到emon会提示输入]`
Enter same passphrase again: `[确认口令]`
Your identification has been saved in /home/emon/.ssh/id_rsa.
Your public key has been saved in /home/emon/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:IRg9u6Ha0s6oUfHDqGjS2Tn4UWS+kRO2mDYyWP9wjHQ liming20110711@163.com
The key's randomart image is:
+---[RSA 4096]----+
|    ..           |
|     oo          |
|  o o Eo.        |
| o B @o= .       |
|. = %.XoS        |
|.+ B.O.+         |
|=.++= o          |
|o.o+oo           |
|...o+            |
+----[SHA256]-----+
```

- 拷贝emon服务器公钥到其他服务器：（仅emon服务器需要做）

```bash
[emon@emon ~]$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon
[emon@emon ~]$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon2
[emon@emon ~]$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon3
```

- 验证从emon服务器登录到emon、emon2、emon3免密登录

```bash
[emon@emon ~]$ ssh emon
[emon@emon ~]$ ssh emon2
[emon@emon ~]$ ssh emon3
```

##### 2.JDK安装

<font color="gree">每一台服务器都需要安装Hadoop。</font>

[安装JDK](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md#1%E5%AE%89%E8%A3%85jdk)

##### 3.安装Hadoop

<font color="gree">每一台服务器都需要安装Hadoop。</font>

[安装Hadoop](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#5%E5%AE%89%E8%A3%85hadoop)

- 确保JAVA_HOME指定到JDK8，查看配置

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/hadoop-env.sh 
```

可以看到`export JAVA_HOME=${JAVA_HOME}`，所以，如果JAVA_HOME环境变量是正确的即可。



#### 5.3.3、配置

<font color="gree">每一台服务器都需要安装Hadoop。</font>

- 配置`core-site.xml`

```bash
# 在打开的文件中<configuration>节点内添加属性
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/core-site.xml 
```

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
		<value>hdfs://emon:8020</value>
    </property>
</configuration>
```

- 配置`hdfs-site.xml`

<center><font color="red">单节点参考hdfs-site.xml.singlebak；集群参考hdfs-site.xml.clusterbak</font></center>

```bash
# 修改副本数量，由于默认副本系统是3，也可以不用修改了
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/hdfs-site.xml 
```

```xml
<configuration>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/usr/local/hadoop/tmp/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/usr/local/hadoop/tmp/dfs/data</value>
    </property>
</configuration>
```

- 修改从节点

<center><font color="red">单节点参考slaves.singlebak；集群参考slaves.clusterbak</font></center>

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/slaves 
#localhost
emon
emon2
emon3
```

- 配置`mapred-site.xml`

```bash
[emon@emon ~]$ cp /usr/local/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/hadoop/etc/hadoop/mapred-site.xml
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/mapred-site.xml
```

```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
```

- 配置`yarn-site.xml`

```bash
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/yarn-site.xml 
```

```xml
<configuration>

<!-- Site specific YARN configuration properties -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <!-- 配置该属性为了解决错误 Caused by: java.io.IOException: Exceeded MAX_FAILED_UNIQUE_FETCHES; bailing-out. -->
    <property>
        <name>yarn.nodemanager.local-dirs</name>
        <value>/usr/local/hadoop/tmp/nm-local-dir</value>        
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>emon</value>
    </property>
</configuration>
```

#### 5.3.4、格式化与启动

<font color="gree">仅emon这个主服务器执行如下命令。</font>

##### 1.格式化HDFS

- 格式化HDFS文件系统：第一次执行的时候一定要格式化文件系统，不要重复执行。

```bash
[emon@emon ~]$ hdfs namenode -format
# 或者
[emon@emon ~]$ hadoop namenode -format
```

```bash
DEPRECATED: Use of this script to execute hdfs command is deprecated.
Instead use the hdfs command for it.

21/12/26 17:38:12 INFO namenode.NameNode: STARTUP_MSG: 
/************************************************************
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   user = emon
STARTUP_MSG:   host = emon/192.168.1.116
STARTUP_MSG:   args = [-format]
STARTUP_MSG:   version = 2.6.0-cdh5.16.2
STARTUP_MSG:   classpath =......
......省略......
21/12/26 17:38:12 INFO namenode.NameNode: Caching file names occuring more than 10 times
21/12/26 17:38:12 INFO snapshot.SnapshotManager: Loaded config captureOpenFiles: false, skipCaptureAccessTimeOnlyChange: false, snapshotDiffAllowSnapRootDescendant: true
21/12/26 17:38:12 INFO util.GSet: Computing capacity for map cachedBlocks
21/12/26 17:38:12 INFO util.GSet: VM type       = 64-bit
21/12/26 17:38:12 INFO util.GSet: 0.25% max memory 889 MB = 2.2 MB
21/12/26 17:38:12 INFO util.GSet: capacity      = 2^18 = 262144 entries
21/12/26 17:38:12 INFO namenode.FSNamesystem: dfs.namenode.safemode.threshold-pct = 0.9990000128746033
21/12/26 17:38:12 INFO namenode.FSNamesystem: dfs.namenode.safemode.min.datanodes = 0
21/12/26 17:38:12 INFO namenode.FSNamesystem: dfs.namenode.safemode.extension     = 30000
21/12/26 17:38:12 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.window.num.buckets = 10
21/12/26 17:38:12 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.num.users = 10
21/12/26 17:38:12 INFO metrics.TopMetrics: NNTop conf: dfs.namenode.top.windows.minutes = 1,5,25
21/12/26 17:38:12 INFO namenode.FSNamesystem: Retry cache on namenode is enabled
21/12/26 17:38:12 INFO namenode.FSNamesystem: Retry cache will use 0.03 of total heap and retry cache entry expiry time is 600000 millis
21/12/26 17:38:12 INFO util.GSet: Computing capacity for map NameNodeRetryCache
21/12/26 17:38:12 INFO util.GSet: VM type       = 64-bit
21/12/26 17:38:12 INFO util.GSet: 0.029999999329447746% max memory 889 MB = 273.1 KB
21/12/26 17:38:12 INFO util.GSet: capacity      = 2^15 = 32768 entries
21/12/26 17:38:12 INFO namenode.FSNamesystem: ACLs enabled? false
21/12/26 17:38:12 INFO namenode.FSNamesystem: XAttrs enabled? true
21/12/26 17:38:12 INFO namenode.FSNamesystem: Maximum size of an xattr: 16384
21/12/26 17:38:12 INFO namenode.FSImage: Allocated new BlockPoolId: BP-2013064118-192.168.1.116-1640511492651
21/12/26 17:38:12 INFO common.Storage: Storage directory /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/tmp/dfs/name has been successfully formatted.
21/12/26 17:38:12 INFO namenode.FSImageFormatProtobuf: Saving image file /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 using no compression
21/12/26 17:38:12 INFO namenode.FSImageFormatProtobuf: Image file /usr/local/Hadoop/hadoop-2.6.0-cdh5.16.2/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 of size 320 bytes saved in 0 seconds .
21/12/26 17:38:12 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
21/12/26 17:38:12 INFO util.ExitUtil: Exiting with status 0
21/12/26 17:38:12 INFO namenode.NameNode: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at emon/192.168.1.116
************************************************************/
```

##### 2.启动HDFS与停止

- 启动

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/start-dfs.sh 
```

- 验证1

```bash
# jps查看进程
[emon@emon ~]$ jps
14707 Jps
13909 NameNode
14232 DataNode
14589 SecondaryNameNode
# 查看hdfs路径
[emon@emon ~]$ hadoop fs -ls  /
# 上传文件
[emon@emon ~]$ hadoop fs -put /usr/local/hadoop/README.txt /
```

**说明：**执行上传文件时如果报错：

>21/12/26 17:42:50 INFO hdfs.DFSClient: Exception in createBlockOutputStream
>java.io.IOException: Bad connect ack with firstBadLink as 192.168.1.118:50010

请检查emon2和emon3是否防火墙已关闭！`[emon@emon2 ~]$]$ sudo systemctl status firewalld`

- 验证2

http://repo.emon.vip:50070

- 停止

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/stop-dfs.sh 
```



##### 3.启动YARN与停止

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/start-yarn.sh
```

- 验证1

```bash
[emon@emon Hadoop]$ jps
19472 SecondaryNameNode
20480 NodeManager
18792 NameNode
19115 DataNode
19998 ResourceManager
20846 Jps
```

- 验证2

http://repo.emon.vip:8088

- 验证3

```bash
# 执行一个PI求解的任务
[emon@emon ~]$ hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.6.0-cdh5.16.2.jar pi 2 3
```

- 停止

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/stop-yarn.sh
```

##### 4.启动停止顺序

遵循：先启动的后停止，后启动的先停止！

启动HDFS->启动YARN

停止YARN->停止HDFS



### 5.8、Hadoop环境切换

**备注**：如果`/usr/local/hadoop/etc/hadoop/slaves`配置了主机名，但主机名在`/etc/hosts`定义为`127.0.0.1  emon`会有本地可以查看文件内容，但JavaAPI无法执行open出hdfs文件内容的问题；但如果主机名要配置为`192.168.1.116    emon`这样时，在公司和家里切换麻烦，写了如下切换的脚本。

```bash
[emon@emon ~]$ vim bin/switchHadoopIP.sh 
```

```bash
#!/bin/bash

source /home/emon/bin/switchHosts.sh

if [ $? -ne 0 ]; then
    echo -e "\e[1;31m 失败！\e[0m"
    exit 0
else
    echo -e "\e[1;34m 成功！\e[0m"
fi

# 启动或停止hadoop函数
function mgr() {
    cmd=$1
    startOrStop=$2
    nodeName=$3
    echo -e "\e[1;34m 开始执行命令 $cmd $startOrStop $nodeName \e[0m"
    if [ -n $nodeName ]; then
        $cmd $startOrStop $nodeName
    elif [ -n $startOrStop ]; then
        $cmd $startOrStop
    else
        $cmd
    fi
    result=$?
    if [ $result -ne 0 ]; then
        echo -e "\e[1;31m 执行命令 $cmd $startOrStop $nodeName 失败！\e[0m"
        exit 0;
    else
        echo -e "\e[1;34m 执行命令 $cmd $startOrStop $nodeName 成功！\e[0m"
    fi
}

mgr /usr/local/hadoop/sbin/hadoop-daemon.sh stop datanode

mgr /usr/local/hadoop/sbin/hadoop-daemon.sh stop namenode

sleep 3

mgr /usr/local/hadoop/sbin/hadoop-daemon.sh start namenode

mgr /usr/local/hadoop/sbin/hadoop-daemon.sh start datanode

sleep 5

mgr /usr/local/hadoop/sbin/stop-yarn.sh

mgr /usr/local/hadoop/sbin/start-yarn.sh

echo -e "\e[1;32m 成功启动Hadoop HDFS，对应环境 " $ENV_NAME"("$ENV_VALUE")\e[0m"
```

- 切换到house环境

```bash
[emon@emon ~]$ ~/bin/switchHadoopIP.sh house
```

- 切换到company环境

```bash
[emon@emon ~]$ ~/bin/switchHadoopIP.sh company
```

### 5.9、Hadoop学习碰到的问题

- 问题1

  - 问题描述

  ```tex
  [ERROR] method:org.apache.hadoop.util.Shell.getWinUtilsPath(Shell.java:425)
  Failed to locate the winutils binary in the hadoop binary path
  java.io.IOException: Could not locate executable null\bin\winutils.exe in the Hadoop binaries.
  ```

  - 问题原因

  原因：window本地无法获取hadoop的配置

  - 解决办法

  下载： https://archive.apache.org/dist/hadoop/core/hadoop-2.6.0/ 并解压到本地 【废弃】

  下载： https://github.com/srccodes/hadoop-common-2.2.0-bin/tree/master/bin 并解压到本地

  ```bash
  # dirPathOfBinParent 是指 hadoop-common-2.2.0-bin 解压后的包含bin的那个目录路径
  System.setProperty("hadoop.home.dir", "dirPathOfBinParent");
  ```

- 问题2

  - 问题描述

  ```bash
  Exception in thread "main" java.lang.UnsatisfiedLinkError: org.apache.hadoop.io.nativeio.NativeIO$Windows.access0(Ljava/lang/String;I)Z
  ```

  - 问题原因

  ```tex
  出现原因：在新版本的windows系统中，会取消部分文件，某些功能无法支持。本地的NativeIO无法写入，我们需要再写一个NativeIO的类，放入代码片段的包中；
  ```

  - 解决办法

  **留白留白留白留白留白**



## 6、安装Hive

### 6.1、基本安装

1. 下载

Hadoop生态圈的软件下载地址：

https://archive.cloudera.com/cdh5/cdh/5/ （已无法下载）

**注意**：无法避开收费墙下载，暂时无解

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Hive
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/hive-1.1.0-cdh5.16.2.tar.gz -C /usr/local/Hive/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Hive/hive-1.1.0-cdh5.16.2/ /usr/local/hive
```

5. 配置环境变量

```
[emon@emon ~]$ sudo vim /etc/profile.d/hive.sh
export HIVE_HOME=/usr/local/hive
export PATH=$HIVE_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

### 6.2、配置

1. 配置

- `hive-env.sh`

```bash
[emon@emon ~]$ cp /usr/local/hive/conf/hive-env.sh.template /usr/local/hive/conf/hive-env.sh
[emon@emon ~]$ vim /usr/local/hive/conf/hive-env.sh
```

```bash
# 修改HADOOP_HOME
HADOOP_HOME=/usr/local/hadoop
```

- `hive-site.xml`

```bash
[emon@emon ~]$ vim /usr/local/hive/conf/hive-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
		<value>jdbc:mysql://emon:3306/hivedb?createDatabaseIfNotExist=true</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
		<value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
		<value>flyin</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
		<value>Flyin@123</value>
    </property>
</configuration>
```

- 拷贝mysql驱动包到`$HIVE_HOME/lib`目录

```bash
[emon@emon ~]$ cp /usr/local/src/mysql-connector-java-5.1.27-bin.jar /usr/local/hive/lib/
```

2. 启动hive命令行

```sql
# 进入CLI
[emon@emon ~]$ hive
......
Logging initialized using configuration in jar:file:/usr/local/Hive/hive-1.1.0-cdh5.16.2/lib/hive-common-1.1.0-cdh5.16.2.jar!/hive-log4j.properties
WARNING: Hive CLI is deprecated and migration to Beeline is recommended.
hive> show databases;
OK
default
hive> create database test_db;
OK
Time taken: 0.12 seconds
hive> show databases;
OK
default
test_db
```

3. MySQL库情况

```sql
[emon@emon ~]$ mysql -uflyin -pFlyin@123 -hemon
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| architectdb        |
| flyindb            |
| hivedb             |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
7 rows in set (0.01 sec)

mysql> use hivedb;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+--------------------+
| Tables_in_hivedb   |
+--------------------+
| cds                |
| database_params    |
| dbs                |
| func_ru            |
| funcs              |
| global_privs       |
| part_col_stats     |
| partitions         |
| roles              |
| sds                |
| sequence_table     |
| serdes             |
| skewed_string_list |
| tab_col_stats      |
| tbls               |
| version            |
+--------------------+
16 rows in set (0.00 sec)

mysql> select * from dbs where name='default' \G;
*************************** 1. row ***************************
          DB_ID: 1
           DESC: Default Hive database
DB_LOCATION_URI: hdfs://0.0.0.0:8020/user/hive/warehouse
           NAME: default
     OWNER_NAME: public
     OWNER_TYPE: ROLE
1 row in set (0.00 sec)
```



### 6.9、Hive学习碰到的问题

- 问题1

  - 如果在hive命令行执行卡主，一定要看hive日志，默认`/tmp/${user.name}`，比如我这里的`/tmp/emon`目录下

  ```bash
  [emon@emon ~]$ tailf /tmp/emon/hive.log
  ```

- 问题2

  - 问题描述

  ```bash
  # 如果碰到如下问题，请修改mysql中hive数据库的编码
  hive> create table helloworld(id int, name string) row format delimited fields terminated by '\t';
  FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. MetaException(message:An exception was thrown while adding/validating class(es) : Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. This includes storage overhead, check the manual. You have to change some columns to TEXT or BLOBs
  com.mysql.jdbc.exceptions.jdbc4.MySQLSyntaxErrorException: Row size too large. The maximum row size for the used table type, not counting BLOBs, is 65535. This includes storage overhead, check the manual. You have to change some columns to TEXT or BLOBs
  ```

  - 问题原因

  编码问题导致的 **Row size too large**

  - 解决办法

  ```bash
  # 修改mysql中hive对应数据库编码，这里是 hivedb
  mysql> alter database hivedb character set latin1;
  Query OK, 1 row affected (0.00 sec)
  
  mysql> flush privileges;
  Query OK, 0 rows affected (0.00 sec)
  
  ```

  ># 还没完，如果已经碰到了上面的错误，在后续级联删除hive库时，会碰到卡主的情况，日志显示错误：
  >
  >Specified key was too long; max key length is 3072 bytes
  >
  ># 怎么办？
  
  第一步：在mysql命令行下，检查hive对应数据库中的tbls表：
  
  ```sql
  mysql> show create table tbls;
  ```
  
  如果发现编码还是`utf8mb4_unicode_ci`，而不是`latin1`，那就是原因了。
  
  第二步：删除hive对应数据库重新创建
  
  ```sql
  mysql> create database hivedb character set latin1;
  ```
  
  OK！

## 7、安装Spark

### 7.1、基本安装

1. 下载

官网地址：http://spark.apache.org/

下载地址：http://spark.apache.org/downloads.html

各个版本：https://archive.apache.org/dist/spark/

![1570272639317](images/1570272639317.png)

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.4/spark-2.4.4-bin-hadoop2.7.tgz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Spark
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/spark-2.4.4-bin-hadoop2.7.tgz -C /usr/local/Spark/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Spark/spark-2.4.4-bin-hadoop2.7/ /usr/local/spark
```

5. 配置环境变量

在`/etc/profile.d`目录创建`spark.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/spark.sh
export SPARK_HOME=/usr/local/spark
export PATH=$SPARK_HOME/bin:$PATH
```

使之生效：

```
[emon@emon ~]$ source /etc/profile
```

6. 修改日志级别（推荐使用默认的WARN）

- 复制

```bash
[emon@emon ~]$ cp /usr/local/spark/conf/log4j.properties.template /usr/local/spark/conf/log4j.properties
```

- 编辑

```bash
[emon@emon ~]$ vim /usr/local/spark/conf/log4j.properties
```

比如，调整为INFO级别：

```bash
log4j.logger.org.apache.spark.repl.Main=INFO
```

### 7.2、local模式

- 进入local模式

```bash
emon@emon ~]$ spark-shell 
19/10/05 19:06:45 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Using Spark's default log4j profile: org/apache/spark/log4j-defaults.properties
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://emon:4040
Spark context available as 'sc' (master = local[*], app id = local-1570273742184).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.4.4
      /_/
         
Using Scala version 2.11.12 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_171)
Type in expressions to have them evaluated.
Type :help for more information.

scala> 
```

- jps查看JAVA进程

```bash
[emon@emon ~]$ jps
60273 Jps
60202 SparkSubmit
15854 jar
```

- 查看60202进程下端口，访问4040端口

```bash
[emon@emon ~]$ sudo netstat -tnlp|grep 60202
tcp6       0      0 :::4040                 :::*                    LISTEN      60202/java          
tcp6       0      0 192.168.1.116:37676     :::*                    LISTEN      60202/java          
tcp6       0      0 192.168.1.116:32793     :::*                    LISTEN      60202/java 
```

http://192.168.1.116:4040

- 退出local模式

```bash
scala> :quit
```

### 7.2、Standalone模式



# 二、各组件常用命令

## 1、hdfs常用命令

- 查看文件

```bash
[emon@emon ~]$ hadoop fs -ls /
```

- 查看文件2

```bash
# 如果写入文件时不指定 /，等于于写入了 /user/emon
[emon@emon ~]$ hadoop fs -ls 
# 等效于
[emon@emon ~]$ hadoop fs -ls /user/emon
```

- 递归查看文件

```bash
[emon@emon ~]$ hadoop fs -ls -R /hdfsapi/test
```

- 存放文件

```bash
[emon@emon ~]$ echo "this is a test txt" > test.txt 
[emon@emon ~]$ hadoop fs -put test.txt /
```

- 查看文件内容

```bash
[emon@emon ~]$ hadoop fs -cat /test.txt
或者
[emon@emon ~]$ hadoop fs -text /test.txt
```

- 从本地拷贝文件到hdfs

```bash
[emon@emon ~]$ echo "this is a copy txt" > copy.txt
[emon@emon ~]$ hadoop fs -copyFromLocal copy.txt /
```

- 从本地移动文件到hdfs

```bash
[emon@emon ~]$ echo "this is a move txt" > move.txt
[emon@emon ~]$ hadoop fs -moveFromLocal move.txt /
```

- 获取文件

```bash
[emon@emon ~]$ hadoop fs -get /move.txt
```

- 创建目录

```bash
[emon@emon ~]$ hadoop fs -mkdir /hdfs-test
# 递归创建
[emon@emon ~]$ hadoop fs -mkdir -p /wordcount/input
```

- 移动文件到目录或改名

```bash
[emon@emon ~]$ hadoop fs -mv /test.txt /hdfs-test
```

- 拷贝文件到新文件

```bash
[emon@emon ~]$ hadoop fs -cp /hdfs-test/test.txt /hdfs-test/test.txt.bak
```

- 合并文件

```bash
# 把hdfs的/hdfs-test目录下所有文件合并到本地目录下t.txt文件中
[emon@emon ~]$ hadoop fs -getmerge /hdfs-test ./t.txt
```

- 删除文件

```bash
[emon@emon ~]$ hadoop fs -rm /copy.txt
Deleted /copy.txt
```

- 删除空目录

```bash
# 仅能删除空目录
[emon@emon ~]$ hadoop fs -rmdir /hdfs-test
```

- 删除目录

```bash
[emon@emon ~]$ hadoop fs -rmr /hdfs-test
rmr: DEPRECATED: Please use 'rm -r' instead.
Deleted /hdfs-test
```

## 2、hive

**基本概念定义**

| 符号   | 含义        |
| ------ | ----------- |
| hive>  | hive命令行  |
| mysql> | mysql命令行 |



### 2.1、Hive数据抽象/结构

- database：HDFS一个目录
  - table：HDFS一个目录
    - data：文件
    - partition：分桶，HDFS一个目录
      - data：文件
      - bucket：分桶，HDFS一个目录



### 2.2、数据定义语言（DDL）

**DDL：Hive Data Definition Language**

#### 2.2.1、数据库操作

- 清屏

```sql
hive (default)> !clear;
```

- 创建数据库

语法格式：

```sql
CREATE [REMOTE] (DATABASE|SCHEMA) [IF NOT EXISTS] database_name
  [COMMENT database_comment]
  [LOCATION hdfs_path]
  [MANAGEDLOCATION hdfs_path]
  [WITH DBPROPERTIES (property_name=property_value, ...)];
```

示例1：使用默认hdfs路径

```sql
hive> create database if not exists hive;
```

```bash
mysql> select * from dbs where name='hive' \G;
*************************** 1. row ***************************
          DB_ID: 6
           DESC: NULL
DB_LOCATION_URI: hdfs://0.0.0.0:8020/user/hive/warehouse/hive.db
           NAME: hive
     OWNER_NAME: emon
     OWNER_TYPE: USER
1 row in set (0.00 sec)
```

示例2：指定hdfs路径

```sql
hive> create database if not exists hive2 location '/test/location';
```

```sql
mysql> select * from dbs where name='hive2' \G;
*************************** 1. row ***************************
          DB_ID: 7
           DESC: NULL
DB_LOCATION_URI: hdfs://0.0.0.0:8020/test/location
           NAME: hive2
     OWNER_NAME: emon
     OWNER_TYPE: USER
1 row in set (0.00 sec)
```

示例3：

```sql
hive> create database if not exists hive3 with dbproperties('creator'='lm');
```

```sql
hive> desc database extended hive3;
OK
hive3		hdfs://0.0.0.0:8020/user/hive/warehouse/hive3.db	emon	USER	{creator=lm}
Time taken: 0.019 seconds, Fetched: 1 row(s)
```

- 删除数据库

语法格式：

```sql
DROP (DATABASE|SCHEMA) [IF EXISTS] database_name [RESTRICT|CASCADE];
```

示例1：如果数据库有表，会报错无法删除 `message:Database test_db is not empty. One or more tables exist`

```sql
hive (default)> drop database if exists hive3;
```

示例2：如果数据库有表，可以级联删除，而不会报错！

```sql
hive (test_db)> drop database if exists test_db cascade;
```

- 查看所有数据库

语法格式：

```sql
SHOW (DATABASES|SCHEMAS) [LIKE 'identifier_with_wildcards'];
```

示例1：

```sql
hive (default)> show databases;
```

示例2：

```sql
hive (default)> show databases like 'hive*';
```

- 查询数据库详情

语法格式：

```sql
DESCRIBE DATABASE [EXTENDED] db_name;
```

示例1：默认

```sql
hive> desc database hive3;
OK
hive3		hdfs://0.0.0.0:8020/user/hive/warehouse/hive3.db	emon	USER	
Time taken: 0.026 seconds, Fetched: 1 row(s)
```

示例2：显示扩展信息

```sql
hive> desc database extended hive3;
OK
hive3		hdfs://0.0.0.0:8020/user/hive/warehouse/hive3.db	emon	USER	{creator=lm}
Time taken: 0.019 seconds, Fetched: 1 row(s)
```

- 设置显示当前库

```sql
hive> set hive.cli.print.current.db;
hive.cli.print.current.db=false
hive> set hive.cli.print.current.db=true;
hive (default)> 
```



#### 2.2.2、表操作

- 创建表

语法格式：

```sql

CREATE [TEMPORARY] [EXTERNAL] TABLE [IF NOT EXISTS] [db_name.]table_name    -- (Note: TEMPORARY available in Hive 0.14.0 and later)
  [(col_name data_type [column_constraint_specification] [COMMENT col_comment], ... [constraint_specification])]
  [COMMENT table_comment]
  [PARTITIONED BY (col_name data_type [COMMENT col_comment], ...)]
  [CLUSTERED BY (col_name, col_name, ...) [SORTED BY (col_name [ASC|DESC], ...)] INTO num_buckets BUCKETS]
  [SKEWED BY (col_name, col_name, ...)                  -- (Note: Available in Hive 0.10.0 and later)]
     ON ((col_value, col_value, ...), (col_value, col_value, ...), ...)
     [STORED AS DIRECTORIES]
  [
   [ROW FORMAT row_format] 
   [STORED AS file_format]
     | STORED BY 'storage.handler.class.name' [WITH SERDEPROPERTIES (...)]  -- (Note: Available in Hive 0.6.0 and later)
  ]
  [LOCATION hdfs_path]
  [TBLPROPERTIES (property_name=property_value, ...)]   -- (Note: Available in Hive 0.6.0 and later)
  [AS select_statement];   -- (Note: Available in Hive 0.5.0 and later; not supported for external tables)
 
CREATE [TEMPORARY] [EXTERNAL] TABLE [IF NOT EXISTS] [db_name.]table_name
  LIKE existing_table_or_view_name
  [LOCATION hdfs_path];
 
data_type
  : primitive_type
  | array_type
  | map_type
  | struct_type
  | union_type  -- (Note: Available in Hive 0.7.0 and later)
 
primitive_type
  : TINYINT
  | SMALLINT
  | INT
  | BIGINT
  | BOOLEAN
  | FLOAT
  | DOUBLE
  | DOUBLE PRECISION -- (Note: Available in Hive 2.2.0 and later)
  | STRING
  | BINARY      -- (Note: Available in Hive 0.8.0 and later)
  | TIMESTAMP   -- (Note: Available in Hive 0.8.0 and later)
  | DECIMAL     -- (Note: Available in Hive 0.11.0 and later)
  | DECIMAL(precision, scale)  -- (Note: Available in Hive 0.13.0 and later)
  | DATE        -- (Note: Available in Hive 0.12.0 and later)
  | VARCHAR     -- (Note: Available in Hive 0.12.0 and later)
  | CHAR        -- (Note: Available in Hive 0.13.0 and later)
 
array_type
  : ARRAY < data_type >
 
map_type
  : MAP < primitive_type, data_type >
 
struct_type
  : STRUCT < col_name : data_type [COMMENT col_comment], ...>
 
union_type
   : UNIONTYPE < data_type, data_type, ... >  -- (Note: Available in Hive 0.7.0 and later)
 
row_format
  : DELIMITED [FIELDS TERMINATED BY char [ESCAPED BY char]] [COLLECTION ITEMS TERMINATED BY char]
        [MAP KEYS TERMINATED BY char] [LINES TERMINATED BY char]
        [NULL DEFINED AS char]   -- (Note: Available in Hive 0.13 and later)
  | SERDE serde_name [WITH SERDEPROPERTIES (property_name=property_value, property_name=property_value, ...)]
 
file_format:
  : SEQUENCEFILE
  | TEXTFILE    -- (Default, depending on hive.default.fileformat configuration)
  | RCFILE      -- (Note: Available in Hive 0.6.0 and later)
  | ORC         -- (Note: Available in Hive 0.11.0 and later)
  | PARQUET     -- (Note: Available in Hive 0.13.0 and later)
  | AVRO        -- (Note: Available in Hive 0.14.0 and later)
  | JSONFILE    -- (Note: Available in Hive 4.0.0 and later)
  | INPUTFORMAT input_format_classname OUTPUTFORMAT output_format_classname
 
column_constraint_specification:
  : [ PRIMARY KEY|UNIQUE|NOT NULL|DEFAULT [default_value]|CHECK  [check_expression] ENABLE|DISABLE NOVALIDATE RELY/NORELY ]
 
default_value:
  : [ LITERAL|CURRENT_USER()|CURRENT_DATE()|CURRENT_TIMESTAMP()|NULL ] 
 
constraint_specification:
  : [, PRIMARY KEY (col_name, ...) DISABLE NOVALIDATE RELY/NORELY ]
    [, PRIMARY KEY (col_name, ...) DISABLE NOVALIDATE RELY/NORELY ]
    [, CONSTRAINT constraint_name FOREIGN KEY (col_name, ...) REFERENCES table_name(col_name, ...) DISABLE NOVALIDATE 
    [, CONSTRAINT constraint_name UNIQUE (col_name, ...) DISABLE NOVALIDATE RELY/NORELY ]
    [, CONSTRAINT constraint_name CHECK [check_expression] ENABLE|DISABLE NOVALIDATE RELY/NORELY ]
```

语法说明：

`EXTERNAL`：外部表，默认是内部表

示例1：

```sql
hive (default)> create table emp(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int
) row format delimited fields terminated by '\t';
```

示例2：

```sql
hive (default)> create table dept(
deptno int,
dname string,
loc string
) row format delimited fields terminated by '\t';
```

示例3：

```sql
hive (default)> create table emp1 as select * from emp;
```

示例4：

```sql
hive (default)> create table emp2 as select empno, ename, job, deptno from emp;
```

示例5：外部表

```sql
hive (default)> create external table emp_external(
empno int,
ename string,
job string,
mgr int,
hiredate string,
sal double,
comm double,
deptno int
) row format delimited fields terminated by '\t'
location '/external/emp';
```

示例6：外部表，带分区

```sql
hive (default)> create external table trackinfo(
ip string,
url string,
sessionId string,    
time string,
country string,
province string,
city string,
pageId string
) partitioned by (day string)
row format delimited fields terminated by '\t'
location '/project/trackinfo';
```

- 修改表名字

语法格式：

```sql
ALTER TABLE table_name RENAME TO new_table_name;
```

示例1：

```sql
hive (default)> alter table emp rename to emp2;
```

- 删除表

语法格式：

```sql
DROP TABLE [IF EXISTS] table_name [PURGE];     -- (Note: PURGE available in Hive 0.14.0 and later)
```

语法说明：

> 内部表删除：HDFS上的数据被删除，并且MySQL中对应的Meta也被删除
>
> 外部表删除：仅删除MySQL中对应的Meta，但不会删除HDFS上的数据

示例1：

```sql
hive> drop table if exists emp;
```

- 查询表详情

语法格式：

```sql
DESCRIBE [EXTENDED|FORMATTED] 
  table_name[.col_name ( [.field_name] | [.'$elem$'] | [.'$key$'] | [.'$value$'] )* ];
                                        -- (Note: Hive 1.x.x and 0.x.x only. See "Hive 2.0+: New Syntax" below)
```

示例1

```sql
hive> desc emp;
```

示例2：查看详情

```sql
hive> desc extended emp;
```

示例3：格式化查询详情

```sql
hive (default)> desc formatted emp;
```

**说明**：格式化查询时，输出内容中`# Detailed Table Information`信息包含的`Table Type`的值含义如下：

| 字段                                   | 含义   |
| -------------------------------------- | ------ |
| Table Type:         	MANAGED_TABLE  | 内部表 |
| Table Type:         	EXTERNAL_TABLE | 外部表 |

### 2.3、数据操作语言之创建（DML）

**Hive Data Manipulation Language**

数据准备：注意，分隔符是`\t`，使用`cat -A file`时应该可以看到`^I`字符表示的tab，如果不是，导入时会出现NULL数据。

```bash
[emon@emon ~]$ vim /usr/local/hadoop/custom/data/emp.txt 
```

```tex
7369	SMITH	CLERK	7902	1980-12-17	800.00		20
7499	ALLEN	SALESMAN	7698	1981-2-20	1600.00	300.00	30
7521	WARD	SALESMAN	7698	1981-2-22	1250.00	500.00	30
7566	JONES	MANAGER	7839	1981-4-2	2975.00		20
7654	MARTIN	SALESMAN	7698	1981-9-28	1250.00	1400.00	30
7698	BLAKE	MANAGER	7839	1981-5-1	2850.00		30
7782	CLARK	MANAGER	7839	1981-6-9	2450.00		10
7788	SCOTT	ANALYST	7566	1987-4-19	3000.00		20
7839	KING	PRESIDENT		1981-11-17	5000.00		10
7844	TURNER	SALESMAN	7698	1981-9-8	1500.00	0.00	30
7876	ADAMS	CLERK	7788	1987-5-23	1100.00		20
7900	JAMES	CLERK	7698	1981-12-3	950.00		30
7902	FORD	ANALYST	7566	1981-12-3	3000.00		20
7934	MILLER	CLERK	7782	1982-1-23	1300.00		10
8888	HIVE	PROGRAM	7839	1988-1-23	10300.00		
```

```sql
[emon@emon ~]$ vim /usr/local/hadoop/custom/data/dept.txt 
```

```sql
10	ACCOUNTING	NEW YORK
20	RESEARCH	DALLAS
30	SALES	CHICAGO
40	OPERATIONS	BOSTON
```

- 加载文件到表

语法格式：

```sql
LOAD DATA [LOCAL] INPATH 'filepath' [OVERWRITE] INTO TABLE tablename [PARTITION (partcol1=val1, partcol2=val2 ...)]
```

语法说明：

`local`：本地系统，如果没有local那么就是指的HDFS的路径。

`overwrite`：是否数据覆盖，如果没有那么就是数据追加。

示例1：

```sql
hive (default)> load data local inpath '/usr/local/hadoop/custom/data/emp.txt' overwrite into table emp;
hive (default)> load data local inpath '/usr/local/hadoop/custom/data/dept.txt' overwrite into table dept;
```

示例2：

```sql
# 注意，HDFS文件被使用后会删除
hive (default)> load data inpath 'hdfs://emon:8020/data/emp.txt' overwrite into table emp;
```

示例3：加载到带分区的表

```sql
# 注意，HDFS文件被使用后会删除
hive (default)> load data inpath 'hdfs://emon:8020/project/input/etl' overwrite into table trackinfo partition(day='2013-07-21');
```

- 基于查询覆盖已存在表数据

语法格式：

```sql
INSERT OVERWRITE TABLE tablename1 [PARTITION (partcol1=val1, partcol2=val2 ...) [IF NOT EXISTS]] select_statement1 FROM from_statement;
INSERT INTO TABLE tablename1 [PARTITION (partcol1=val1, partcol2=val2 ...)] select_statement1 FROM from_statement;
```

示例1：table必须先存在

```sql
hive (default)> insert overwrite table emp1 if not exists select * from emp;
```

示例2：table必须先存在

```sql
hive (default)> insert into table emp1 select * from emp;
```

示例3：

```sql
hive> insert overwrite table trackinfo_province_stat partition(day='2013-07-21')
select province,count(*) as cnt from trackinfo where day='2013-07-21' group by province;
```

- 基于查询写数据到本地或者HDFS文件系统

语法格式：

```sql
INSERT OVERWRITE [LOCAL] DIRECTORY directory1
  [ROW FORMAT row_format] [STORED AS file_format] (Note: Only available starting with Hive 0.11.0)
  SELECT ... FROM ...
```

示例1：

```sql
hive (default)> insert overwrite local directory '/tmp/hive/' row format delimited fields terminated by '\t' select empno, ename, sal, deptno from emp;
```



### 2.4、数据查询语言（DQL）

**Hive Data Query Language**

- 查询

语法格式：

```sql
[WITH CommonTableExpression (, CommonTableExpression)*]    (Note: Only available starting with Hive 0.13.0)
SELECT [ALL | DISTINCT] select_expr, select_expr, ...
  FROM table_reference
  [WHERE where_condition]
  [GROUP BY col_list]
  [ORDER BY col_list]
  [CLUSTER BY col_list
    | [DISTRIBUTE BY col_list] [SORT BY col_list]
  ]
 [LIMIT [offset,] rows]
```

示例1：

```sql
hive> select * from emp;
```

示例2：

```sql
hive> select ename, empno, deptno from emp where deptno=10 limit 1;
```

示例3：

```sql
hive> select deptno, avg(sal) avg_sal from emp group by deptno having avg_sal>2000;
```

示例4：

```sql
hive> select e.empno, e.ename, e.sal, e.deptno from emp e join dept d on e.deptno=d.deptno;
```

示例5：对带分区的表，指定查询分区

```sql
hive> select * from trackinfo where day='2013-07-21' limit 5;
```

- 执行计划

语法格式：

```sql
EXPLAIN [EXTENDED|CBO|AST|DEPENDENCY|AUTHORIZATION|LOCKS|VECTORIZATION|ANALYZE] query
```

示例1：

```sql
hive> explain select e.empno, e.ename, e.sal, e.deptno from emp e join dept d on e.deptno=d.deptno;
```

示例2：

```sql
hive> explain extended select e.empno, e.ename, e.sal, e.deptno from emp e join dept d on e.deptno=d.deptno;
```

