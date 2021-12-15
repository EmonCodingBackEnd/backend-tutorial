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

[Scala安装教程](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Scala/ScalaInAction.md)

## 5、安装Hadoop

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
[emon@emon ~]$ tar -xzvf /usr/local/src/hadoop-2.6.0-cdh5.15.1.tar.gz -C /usr/local/Hadoop/
```

- hadoop软件包常见目录说明

  - `bin`： hadoop客户端名单

  - `etc/hadoop`： hadoop相关的配置文件存放目录

  - `sbin`： 启动hadoop相关进程的脚本

  - `share`： 常用例子

- 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Hadoop/hadoop-2.6.0-cdh5.15.1/ /usr/local/hadoop
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

6. 配置

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
		<value>hdfs://0.0.0.0:8020</value>
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
</configuration>
```

- 修改临时目录位置

```bash
# 创建临时目录
[emon@emon ~]$ mkdir /usr/local/hadoop/tmp
# 修改临时目录
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

**注意**：emon是主机名，可以在`/etc/hosts`配置，比如：`127.0.0.1   emon`

7. 启动HDFS

- 启动HDFS：第一次执行的时候一定要格式化文件系统，不要重复执行。

```bash
[emon@emon ~]$ ll /usr/local/hadoop/tmp/
总用量 0

[emon@emon ~]$ hdfs namenode -format
STARTUP_MSG: Starting NameNode
STARTUP_MSG:   user = emon
STARTUP_MSG:   host = localhost/127.0.0.1
STARTUP_MSG:   args = [-format]
STARTUP_MSG:   version = 2.6.0-cdh5.15.1
...
... 省略 ...
...
21/12/12 21:36:53 INFO namenode.FSNamesystem: Retry cache will use 0.03 of total heap and retry cache entry expiry time is 600000 millis
21/12/12 21:36:53 INFO util.GSet: Computing capacity for map NameNodeRetryCache
21/12/12 21:36:53 INFO util.GSet: VM type       = 64-bit
21/12/12 21:36:53 INFO util.GSet: 0.029999999329447746% max memory 889 MB = 273.1 KB
21/12/12 21:36:53 INFO util.GSet: capacity      = 2^15 = 32768 entries
21/12/12 21:36:53 INFO namenode.FSNamesystem: ACLs enabled? false
21/12/12 21:36:53 INFO namenode.FSNamesystem: XAttrs enabled? true
21/12/12 21:36:53 INFO namenode.FSNamesystem: Maximum size of an xattr: 16384
21/12/12 21:36:53 INFO namenode.FSImage: Allocated new BlockPoolId: BP-156337236-127.0.0.1-1639316213819
21/12/12 21:36:53 INFO common.Storage: Storage directory /usr/local/hadoop/tmp/dfs/name has been successfully formatted.
21/12/12 21:36:53 INFO namenode.FSImageFormatProtobuf: Saving image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 using no compression
21/12/12 21:36:53 INFO namenode.FSImageFormatProtobuf: Image file /usr/local/hadoop/tmp/dfs/name/current/fsimage.ckpt_0000000000000000000 of size 320 bytes saved in 0 seconds .
21/12/12 21:36:53 INFO namenode.NNStorageRetentionManager: Going to retain 1 images with txid >= 0
21/12/12 21:36:53 INFO util.ExitUtil: Exiting with status 0
21/12/12 21:36:53 INFO namenode.NameNode: SHUTDOWN_MSG: 
/************************************************************
SHUTDOWN_MSG: Shutting down NameNode at localhost/127.0.0.1
************************************************************/

[emon@emon ~]$ ll /usr/local/hadoop/tmp/
总用量 0
drwxrwxr-x. 3 emon emon 18 12月 12 21:36 dfs
```

- 启动集群

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/start-dfs.sh 
```

第一次启动的日志，`core-site.xml`配置的是`<value>hdfs://0.0.0.0:8020</value>`

```bash
21/12/12 22:22:04 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Starting namenodes on [0.0.0.0]
The authenticity of host '0.0.0.0 (0.0.0.0)' can't be established.
ECDSA key fingerprint is SHA256:W3BcZcYnY/kGTM4trOACHTRqYeRHSDQL0ND8JYDUAmg.
ECDSA key fingerprint is MD5:b8:de:82:bf:7a:c7:55:50:b2:e9:cf:a7:77:a7:2e:96.
Are you sure you want to continue connecting (yes/no)? yes
0.0.0.0: Warning: Permanently added '0.0.0.0' (ECDSA) to the list of known hosts.
0.0.0.0: starting namenode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.15.1/logs/hadoop-emon-namenode-emon.out
emon: starting datanode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.15.1/logs/hadoop-emon-datanode-emon.out
Starting secondary namenodes [0.0.0.0]
0.0.0.0: starting secondarynamenode, logging to /usr/local/Hadoop/hadoop-2.6.0-cdh5.15.1/logs/hadoop-emon-secondarynamenode-emon.out
21/12/12 22:24:00 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
```



- 验证1

```bash
[emon@emon ~]$ jps
100336 SecondaryNameNode
99658 NameNode
99980 DataNode
```

- 验证2

**注意**：确保防火墙停止，或者50070端口是放开的！

```bash
[emon@emon ~]$ sudo firewall-cmd --state
not running
```

访问地址：http://repo.emon.vip:50070

8. 停止HDFS

```bash
[emon@emon ~]$ /usr/local/hadoop/sbin/stop-dfs.sh 
```

第一次停止的日志，`core-site.xml`配置的是`<value>hdfs://0.0.0.0:8020</value>`

```bash
21/12/12 22:46:41 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Stopping namenodes on [0.0.0.0]
0.0.0.0: stopping namenode
emon: stopping datanode
Stopping secondary namenodes [0.0.0.0]
0.0.0.0: stopping secondarynamenode
21/12/12 22:47:00 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
```

9. 另外一种启动方式

> start-dfs.sh = 
>
> ​					hadoop-daemons.sh start namenode
>
> ​					hadoop-daemons.sh start datanode
>
> ​					hadoop-daemons.sh start secondarynamenode

> ​	stop-dfs.sh = 
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

**备注**：如果`/usr/local/hadoop/etc/hadoop/slaves`配置了主机名，但主机名在`/etc/hosts`定义为`127.0.0.1  emon`会有本地可以查看文件内容，但JavaAPI无法执行open出hdfs文件内容的问题；但如果主机名要配置为`192.168.1.116    emon`这样时，在公司和家里切换麻烦，写了如下切换的脚本。

```bash
[emon@emon ~]$ vim bin/switchHadoopIP.sh 
```

```bash
#!/bin/bash

# 启动或停止hadoop函数
function mgr() {
    startOrStop=$1
    nodeName=$2
    echo -e "\e[1;34m 开始 $startOrStop Hadoop HDFS $nodeName \e[0m"
    /usr/local/hadoop/sbin/hadoop-daemon.sh $startOrStop $nodeName
    result=$?
    if [ $result -ne 0 ]; then
        echo -e "\e[1;31m $startOrStop Hadoop HDFS $nodeName 失败！\e[0m"
        exit 0;
    else
        echo -e "\e[1;34m 成功$startOrStop Hadoop HDFS $nodeName \e[0m"
    fi
}

if [ $# -ne 1 ]; then
    echo -e "\e[1;36m Usage: ./switchHadoopIp.sh env\e[0m"
    echo -e "\e[1;34m env: 表示IP环境 【必须】\e[0m"
    exit 0
fi

house="192.168.1.116   emon"
company="10.0.0.116      emon"

ENV_NAME=$1
# 以变量作为key，获取其变量值
ENV_VALUE=$(eval echo '$'$ENV_NAME)

if [[ -z $ENV_VALUE ]]; then
    echo -e "\e[1;34m env: "$ENV_NAME" 未定义\e[0m"
    exit 0
fi

# 更换主机对应IP地址
echo -e "\e[1;34m 开始执行更换主机IP到环境 " $ENV_NAME"("$ENV_VALUE")\e[0m"
echo 'emon123' | sudo -S sed -i 's/^[^#]*emon$/'"$ENV_VALUE"'/g' /etc/hosts
if [ $? -ne 0 ]; then
    echo -e "\e[1;31m 执行更换主机IP到环境 " $ENV_NAME"("$ENV_VALUE")失败！\e[0m"
    exit 0
else
    echo -e "\e[1;34m 成功执行更换主机IP到环境 " $ENV_NAME"("$ENV_VALUE")\e[0m"
fi

echo -e "\e[1;34m 执行后 /etc/hosts 文件内容如下\e[0m"
cat /etc/hosts

mgr stop datanode

mgr stop namenode

sleep 3

mgr start namenode

mgr start datanode

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

## 6、安装Spark

### 6.1、基本安装

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

### 6.2、local模式

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

### 6.2、Standalone模式



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

