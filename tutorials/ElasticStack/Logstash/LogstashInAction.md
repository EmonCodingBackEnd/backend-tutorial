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

### 1.1、安装依赖

请确保安装了JDK1.8，安装方式参考： [JDK1.8安装参考](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md)

打开后搜索 **安装JDK** 即可。

### 1.2、下载

官网： <https://www.elastic.co/>

下载地址页： <https://www.elastic.co/downloads>

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/logstash/logstash-5.6.11.tar.gz
```

### 1.3、创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Logstash
```

### 1.4、解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/logstash-5.6.11.tar.gz -C /usr/local/Logstash/
```

### 1.5、创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Logstash/logstash-5.6.11/ /usr/local/logstash
```

### 1.6、配置`logstash.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/logstash/config/logstash.yml 
```

```
http.host: "0.0.0.0"
```

### 1.7、准备一个`logstash.conf`配置文件

```shell
[emon@emon logstash]$ vim nginx_logstash.conf
```

```
input {
  stdin { }
}

filter {
  grok {
    match => {
      "message" => '%{IPORHOST:remote_ip} - %{DATA:user_name} \[%{HTTPDATE:time}\] "%{WORD:request_action} %{DATA:reques} HTTP/%{NUMBER:http_version}" %{NUMBER:response} %{NUMBER:bytes} "%{DATA:referrer}" "%{DATA:agent}"'
    }
  }

  date {
    match => [ "time", "dd/MM/YYYY:HH:mm:ss Z" ]
    locale => en
  }

  geoip {
    source => "remote_ip"
    target => "geoip"
  }

  useragent {
    source => "agent"
    target => "user_agent"
  }
}

output {
  stdout {
    codec => rubydebug
  }
}
```

### 1.8、测试

```shell
[emon@emon ~]$ head -n 2 /usr/local/nginx/logs/access.log | /usr/local/logstash/bin/logstash -f /usr/local/logstash/nginx_logstash.conf 
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







# 二、配置说明

## 1、JVM配置

### 1.1、配置堆内存大小

默认的1g调整为256m

```
#-Xms1g
#-Xmx1g
-Xms256m
-Xmx256m
```

