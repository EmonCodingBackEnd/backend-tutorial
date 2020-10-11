# Kafka实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

## 1、下载

官网地址：http://kafka.apache.org/

下载地址：http://kafka.apache.org/downloads

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirror.bit.edu.cn/apache/kafka/2.6.0/kafka_2.12-2.6.0.tgz
```

## 2、创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Kafka
```

### 3、解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/kafka_2.12-2.6.0.tgz -C /usr/local/Kafka/
```

## 4、创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Kafka/kafka_2.12-2.6.0/ /usr/local/kafka
```

## 5、配置环境变量

在`/etc/profile.d`目录创建`kafka.sh`文件：

```
[emon@emon ~]$ sudo vim /etc/profile.d/kafka.sh
export PATH=/usr/local/kafka/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

## 6、目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/kafka/logs
[emon@emon ~]$ mkdir -p /usr/local/kafka/zookeeper/{data,logs}
```

## 7、配置文件

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

## 8、编写启动停止脚本

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

## 9、启动kafka

```bash
[emon@emon ~]$ /usr/local/kafka/kafkaStart.sh 
```

## 10、创建`topic`

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

## 11、测试生产者消费者

- 生产者

```bash
[emon@emon ~]$ kafka-console-producer.sh --broker-list localhost:9092 --topic test-kafka-topic
```

- 消费者

```bash
[emon@emon ~]$ kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-kafka-topic --from-beginning
```

