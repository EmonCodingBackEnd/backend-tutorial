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
```

8. 启动与停止

- 启动

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

## 2、安装kafka

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
[emon@emon ~]$ mkdir -p /usr/local/kafka/zookeeper/{data,logs}
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

- 编辑`zookeeper.properties`配置文件

```bash
[emon@emon ~]$ vim /usr/local/kafka/config/zookeeper.properties 
```

```bash
# [修改]
dataDir=/tmp/zookeeper => dataDir=/usr/local/kafka/zookeeper/data
# [新增]
dataLogDir=/usr/local/kafka/zookeeper/logs
```

8. 编写启动停止脚本

- 启动脚本

```bash
[emon@emon ~]$ vim /usr/local/kafka/kafkaStart.sh
```

```bash
# 启动zookeeper
/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties &
# 等待3秒后执行
sleep 3
# 启动kafka
/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
```

- 停止脚本

```bash
[emon@emon ~]$ vim /usr/local/kafka/kafkaStop.sh
```

```bash
# 关闭zookeeper
/usr/local/kafka/bin/zookeeper-server-stop.sh /usr/local/kafka/config/zookeeper.properties &
# 等待3秒后执行
sleep 3
# 关闭kafka
/usr/local/kafka/bin/kafka-server-stop.sh /usr/local/kafka/config/server.properties &
```

- 修改可执行权限

```bash
[emon@emon ~]$ chmod +x /usr/local/kafka/kafkaStart.sh 
[emon@emon ~]$ chmod +x /usr/local/kafka/kafkaStop.sh 
```

9. 启动kafka

```bash
[emon@emon ~]$ /usr/local/kafka/kafkaStart.sh
```

10. 创建`topic`

- 创建

```bash
[emon@emon ~]$ kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic test-kafka-topic
# 命令执行结果
Created topic test-kafka-topic.
```

- 查看

```bash
[emon@emon ~]$ kafka-topics.sh --list --zookeeper localhost:2181
# 命令执行结果
__consumer_offsets
test-kafka-topic
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

## 3、安装HBase

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

```bash
[emon@emon ~]$ vim /usr/local/hbase/conf/hbase-site.xml 
```

```xml
<configuration>
    <property>
        <name>hbase.rootdir</name>
        <value>file:///usr/local/hbase/data</value>
    </property>
</configuration>
```

8. 启动与停用

- 启动

```bash
[emon@emon ~]$ start-hbase.sh 
```

- 停用

```bash
[emon@emon ~]$ stop-hbase.sh 
```

- 进入hbase命令行

```bash
[emon@emon ~]$ hbase shell
```











