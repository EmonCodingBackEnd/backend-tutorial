# Logstash实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、简介

- Data Shipper
  - ETL
  - Extract
  - Transform
  - Load

## 1、安装

### 1.1、下载

官网： <https://www.elastic.co/>

下载地址页： <https://www.elastic.co/downloads>

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/logstash/logstash-5.6.11.tar.gz
```

### 1.2、创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Logstash
```

### 1.3、解压安装

```shell

```

### 1.4、创建软连接

```shell

```



## 2、处理流程

- Input
  - file
  - redis
  - beats
  - kafka
- Filter
  - grok
  - mutate
  - drop
  - date
- Output
  - stdout
  - elasticsearch
  - redis
  - kafka

### 2.1、处理流程 -- Input 和 Output 配置

```
input {file {path => "/tmp/abc.log"}}
```

```
output {stdout{codec => rubydebug}}
```

### 2.2、处理流程 -- Filter配置

- Grok
  - 基于正则表达式提供了丰富可重用的模式（pattern）
  - 基于此可以将非结构化数据作结构化处理
- Date
  - 将字符串类型的时间字段转换为时间戳类型，方便后续数据处理
- Mutate
  - 进行增加、修改、删除、替换等字段相关的处理
- ......

#### 2.2.1 配置Grok示例

```
==>待处理文本
55.3.244.1 GET /index.html 15824 0.043
==>Grok表达式
%{IP:client} %{WORD:method} %{URIPATHPARAM:request} %{NUMBER:bytes} %{NUMBER:duration}
==>结果
{
    "client": "55.3.244.1",
    "method": "GET",
    "request": "/index.html",
    "bytes": 15824,
    "duration": 0.043
}
```

#### 2.2.2、