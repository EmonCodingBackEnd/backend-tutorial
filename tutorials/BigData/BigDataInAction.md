# BigData实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]



# 一、基础软件安装

## 1、安装ZooKeeper

1. 下载

官网地址： https://zookeeper.apache.org/index.html

下载地址： https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/

版本3.5.5带来的坑：https://blog.csdn.net/jiangxiulilinux/article/details/96433560

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.5.5/apache-zookeeper-3.5.5-bin.tar.gz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/ZooKeeper
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/apache-zookeeper-3.5.5-bin.tar.gz -C /usr/local/ZooKeeper/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/ZooKeeper/apache-zookeeper-3.5.5-bin/ /usr/local/zoo
```

5. 配置环境变量

在`/etc/profile.d`目录创建`zoo.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/zoo.sh
export PATH=/usr/local/zoo/bin:$PATH
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

1. 下载

官网地址：https://www.scala-lang.org/

下载地址：https://www.scala-lang.org/download/

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Scala
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/scala-2.12.10.tgz -C /usr/local/Scala/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Scala/scala-2.12.10/ /usr/local/scala
```

5. 配置环境变量

在`/etc/profile.d`目录创建`scala.sh`文件：

```
[emon@emon ~]$ sudo vim /etc/profile.d/scala.sh
export SCALA_HOME=/usr/local/scala
export PATH=$SCALA_HOME/bin:$PATH
```

使之生效：

```
[emon@emon ~]$ source /etc/profile
```

6. 校验

```bash
[emon@emon Scala]$ scala -version
Scala code runner version 2.12.10 -- Copyright 2002-2019, LAMP/EPFL and Lightbend, Inc.
```

## 5、安装Spark

### 5.1、基本安装

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

### 5.2、local模式

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

### 5.2、Standalone模式









