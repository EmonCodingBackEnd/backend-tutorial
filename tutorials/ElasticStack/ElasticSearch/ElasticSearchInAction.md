# Elasticsearch实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装与运行

## 1、 安装依赖

请确保安装了JDK1.8，安装方式参考： [JDK1.8安装参考](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md)

打开后搜索 **安装JDK** 即可。

## 2、下载

官网： https://www.elastic.co/

下载地址页： https://www.elastic.co/downloads

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.tar.gz
```

## 3、创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Elasticsearch
```

## 4、解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/elasticsearch-6.4.0.tar.gz -C /usr/local/Elasticsearch/
```

## 5、创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Elasticsearch/elasticsearch-6.4.0/ /usr/local/elasticsearch
```

## 6、配置`elasticsearch.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch/config/elasticsearch.yml 
```

```yaml
network.host: 0.0.0.0
```

## 7、解决启动问题

### 7.1、问题一

- 问题描述

```
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
```

- 解决办法

```shell
[emon@emon ~]$ sudo vim /etc/security/limits.conf
```

```shell
# 配置内容，其中emon是启动elasticsearch的用户，如果不确定是什么用户，也可以替换为*表示所有
emon             soft    nofile          1024
emon             hard    nofile          65536
```

**需要重新登录emon用户生效**

### 7.1、问题二

- 问题描述

```
[2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
```

- 解决方法

```shell
# 查看
[emon@emon ~]$ sudo sysctl -a|grep vm.max_map_count
# 打开文件
[emon@emon ~]$ sudo vim /etc/sysctl.conf 
```

```shell
# 配置内容
vm.max_map_count=655360
```

```shell
# 使配置生效
[emon@emon ~]$ sudo sysctl -p
```

## 8、启动

```shell
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch
```

## 9、访问

http://192.168.8.116:9200

```json
{
    name: "lcbwrZv",
    cluster_name: "elasticsearch",
    cluster_uuid: "ABJ6uTR5QzmePntR8VuxnA",
    version: {
        number: "6.4.0",
        build_flavor: "default",
        build_type: "tar",
        build_hash: "595516e",
        build_date: "2018-08-17T23:18:47.308994Z",
        build_snapshot: false,
        lucene_version: "7.4.0",
        minimum_wire_compatibility_version: "5.6.0",
        minimum_index_compatibility_version: "5.0.0"
    },
    tagline: "You Know, for Search"
}
```





