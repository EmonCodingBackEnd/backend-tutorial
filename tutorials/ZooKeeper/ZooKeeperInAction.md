# ZooKeeper实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

官网地址： https://zookeeper.apache.org/index.html

下载地址：https://archive.apache.org/dist/zookeeper/

下载地址： https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/



[安装Zookeeper](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#1%E5%AE%89%E8%A3%85zookeeper)

# 二、常用命令

- 远程连接

```bash
[emon@emon ~]$ zkCli.sh -server emon:2181
```

- 本地连接

```bash
[emon@emon ~]$ zkCli.sh
```

- 退出（连接成功后，使用命令quit退出）

```bash
[zk: localhost:2181(CONNECTED) 0] quit
```

- 查看根节点下内容

```bash
[zk: localhost:2181(CONNECTED) 1] ls /
```

- 创建节点test并存储数据hello

```bash
[zk: localhost:2181(CONNECTED) 2] create /test hello
```

- 查看节点test内容

```bash
[zk: localhost:2181(CONNECTED) 6] get /test
# 命令行输出结果
hello
```

- 删除节点

```bash
# 递归删除
[zk: localhost:2181(CONNECTED) 7] deleteall /test
# 普通删除
[zk: localhost:2181(CONNECTED) 7] delete /test
```



# 三、初始ZooKeeper

## 3.1、ZooKeeper简介

- 中间件，提供协调服务
- 作用于分布式系统，发挥其优势，可以为大数据服务
- 支持Java，提供Java和C语言的客户端API

## 3.2、什么是分布式系统

- 很多台计算机组成一个整体，一个整体一致对外并且处理同一个请求
- 内部的每台计算机都可以互相通信（rest/rpc）
- 客户端到服务端的一次请求到响应结束会经历多台计算机

## 3.3、ZooKeeper的特性

- 一致性：数据一致性，数据按照顺序分批入库
- 原子性：事务要么成功要么失败，不会局部化
- 单一视图：客户端连接集群中的任一ZK节点，数据都是一致的

- 可靠性：每次对ZK的操作状态都会保存在服务端
- 实时性：客户端可以读取到ZK服务端的最新数据

## 3.4、ZooKeeper主要目录结构

```bash
# ZooKeeper 3.5.9
$ tree -L 1
```

> .
> ├── bin：主要的一些运行命令
> ├── conf：存放配置文件，其中我们需要修改zoo_sample.cfg（复制为zoo.cfg并修改配置内容）
> ├── data
> ├── docs：文档
> ├── lib：需要依赖的jar包
> ├── LICENSE.txt
> ├── logs
> ├── NOTICE.txt
> ├── README.md
> └── README_packaging.txt







































