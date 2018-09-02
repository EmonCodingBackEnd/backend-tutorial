# Beats实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、简介

- Lightweight Data Shipper
  - Filebeat 日志文件
  - Metricbeat 度量数据
  - Packetbeat 网络数据
  - Winlogbeat Windows数据
  - Heartbeat 健康检查

## 1、Filebeat简介

### 1.1、安装

1. 下载

官网： <https://www.elastic.co/>

下载地址页： <https://www.elastic.co/downloads>

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.6.11-linux-x86_64.tar.gz
```

2. 创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Filebeat
```

3. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/filebeat-5.6.11-linux-x86_64.tar.gz -C /usr/local/Filebeat/
```

4. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Filebeat/filebeat-5.6.11-linux-x86_64/ /usr/local/filebeat
```

5. 配置`filebeat.yml`

备份：

```shell
[emon@emon ~]$ cp -a /usr/local/filebeat/filebeat.yml /usr/local/filebeat/filebeat.yml.bak 
```

编辑：

```shell
[emon@emon ~]$ vim /usr/local/filebeat/filebeat.yml
```

```yaml
# 保留内容
filebeat.prospectors:
- input_type: stdin
output.console:
  pretty: true
```

6. 测试

```shell
[emon@emon ~]$ head -n 2 /usr/local/nginx/logs/access.log | /usr/local/filebeat/filebeat -e -c /usr/local/filebeat/filebeat.yml
```



### 1.2、处理流程

- 处理流程
  - 输入 Input
  - 处理 Filter
  - 输出 Output

![Beats入门](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/ElasticStack/Beats/images/20180902193823.png)

- Filebeat Input 配置简介
  - yaml 语法
  - input_type
    - log
    - stdin

```yaml
filebeat.prospectors:
  - input_type: log
    paths:
      - /var/log/apache/httpd-*.log
  - input_type: log
  	paths:
      - /var/log/messages
      - /var/log/*.log
```



- Filebeat Output 配置简介
  - Console
  - Elasticsearch
  - Logstash
  - Kafka
  - Redis
  - File

```yaml
output.elasticsearch:
  hosts: ["http://localhost:9200"]
  username: "admin"
  passwor: "s3cr3t"
```

```yaml
output.console:
  pretty: true
```

- Filebeat Filter 配置简介
  - Input 时处理
    - Include_lines
    - exclude_lines
    - exclude_files
  - Output 前处理 --Processor
    - drop_event
    - drop_fields
    - Decode_json_fields
    - Include_fields

```yaml
processors:
  - drop_event:
    when:
      regexp:
        message: "^DBG"
  - decode_json_fields:
    fields: ["inner"]
```

### 1.3、Filebeat+Elasticsearch Ingest Node

- Filebeat 缺乏数据转换能力的
- Elasticsearch Ingest Node
  - 新增的node类型
  - 在数据写入es前对数据进行处理
  - pipeline api

### 1.4、Filebeat Module 简介

- 对于社区常见需求进行配置封装增加易用性
  - Nginx
  - Apache
  - MySQL
- 封装内容
  - filebeat.yml配置
  - ingest node pipeline配置
  - Kibana dashboard
- 最佳实践参考



### 1.5、Filebeat收集nginx log

- 通过stdin收集日志
- 通过console输出结果



## 2、Packetbeat简介

- 实时抓取网络包
- 自动解析应用层协议
  - ICMP（v4 and v6）
  - DNS
  - HTTP
  - MySQL
  - Redis
  - ......
- Wireshark

### 2.1、安装

1. 下载

官网： <https://www.elastic.co/>

下载地址页： <https://www.elastic.co/downloads>

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/beats/packetbeat/packetbeat-5.6.11-linux-x86_64.tar.gz
```

2. 创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Packetbeat
```

3. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/packetbeat-5.6.11-linux-x86_64.tar.gz -C /usr/local/Packetbeat/
```

4. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Packetbeat/packetbeat-5.6.11-linux-x86_64/ /usr/local/packetbeat
```

5. 配置`packetbeat.yml`

复制一份，进行调整：

```shell
[emon@emon ~]$ grep -v "#" /usr/local/packetbeat/packetbeat.yml > /usr/local/packetbeat/es.yml
[emon@emon ~]$ vim /usr/local/packetbeat/es.yml 
```

内容如下：

```shell
packetbeat.interfaces.device: ens33
packetbeat.protocols.http:
  ports: [9200]
  send_request: true
  include_body_for: ["application/json", "x-www-form-urlencoded"]
output.console:
  pretty: true
```

6. 测试

```shell
[emon@emon ~]$ sudo /usr/local/packetbeat/packetbeat -e -c /usr/local/packetbeat/es.yml -strict.perms=false
```

然后在网页访问Elasticsearch： http://192.168.8.116:9200/



### 2.2、Packetbeat解析http协议

- 解析elasticsearch http请求

```yaml
packetbeat.interfaces.device: lo0
packetbeat.protocols.http: ports: [9200]
send_request: true
include_body_for: ["application/json","x-www-form-urlencoded"]
output.console:
  pretty: true
```

- 运行

```
sudo ./packetbeat -e -c es.yml -strict.perms=false
```





## 