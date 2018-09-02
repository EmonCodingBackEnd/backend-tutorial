# Kibana实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装与运行

## 1、下载

官网：https://www.elastic.co

下载地址页：https://www.elastic.co/downloads/past-releases

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/kibana/kibana-5.6.11-linux-x86_64.tar.gz
```

## 2、创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Kibana
```

## 3、解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/kibana-5.6.11-linux-x86_64.tar.gz -C /usr/local/Kibana/
```

## 4、创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Kibana/kibana-5.6.11-linux-x86_64/ /usr/local/kibana
```

## 5、配置`kibana.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/kibana/config/kibana.yml 
```

```yml
server.host: 0.0.0.0
```

## 6、启动

```shell
[emon@emon ~]$ /usr/local/kibana/bin/kibana
```

## 7、访问

http://localhost:5601



# 二、配置说明

- 配置文件位于`/usr/local/kibana/config/kibana.yml`文件夹中
  - `kibana.yml`关键配置说明
    - `server.host/server.port` 访问kibana用的地址和断开
    - `elasticsearch.url` 待访问elasticsearch的地址
    - 











