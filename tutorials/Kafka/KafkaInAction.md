# Kafka实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装Kafka（外部ZK）](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#2%E5%AE%89%E8%A3%85kafka%E5%A4%96%E9%83%A8zk)



# 二、常用命令

- 创建

```bash
[emon@emon ~]$ kafka-topics.sh --create --bootstrap-server emon:9092 --replication-factor 1 --partitions 1 --topic test
# 命令执行结果
Created topic test.
```

或者：

```bash
[emon@emon ~]$ kafka-topics.sh --create --zookeeper emon:2181 --replication-factor 1 --partitions 1 --topic test
# 命令执行结果
Created topic test.
```

- 查看topic列表

```bash
[emon@emon ~]$ kafka-topics.sh --list --bootstrap-server emon:9092
# 命令执行结果
test
```

- 查看单个topic详情

```bash
[emon@emon ~]$ kafka-topics.sh --describe --bootstrap-server emon:9092 --topic test
# 命令执行结果
Topic: test	PartitionCount: 1	ReplicationFactor: 1	Configs: segment.bytes=1073741824
	Topic: test	Partition: 0	Leader: 0	Replicas: 0	Isr: 0
```

- 删除

```bash
[emon@emon ~]$ kafka-topics.sh --delete --zookeeper emon:2181 --topic ssstopic
# 命令执行结果，提示如果 delete.topic.enable不设置true，执行不产生影响，仅仅标记为deletion
Topic ssstopic is marked for deletion.
Note: This will have no impact if delete.topic.enable is not set to true.
```

- 生产者

```bash
# 打开生产者命令行模式
[emon@emon ~]$ kafka-console-producer.sh --bootstrap-server emon:9092 --topic test
```

- 消费者

```bash
# 打开消费者命令模式
[emon@emon ~]$ kafka-console-consumer.sh --bootstrap-server emon:9092 --topic test --from-beginning
```

- 查看topic的偏移量

```bash
[emon@emon ~]$ kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list emon:9092 --topic test
# 命令执行结果
test:0:59134
```
