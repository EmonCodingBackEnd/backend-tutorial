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

## 2、Filebeat+Elasticsearch Ingest Node

- Filebeat 缺乏数据转换能力的
- Elasticsearch Ingest Node
  - 新增的node类型
  - 在数据写入es前对数据进行处理
  - pipeline api

## 3、Filebeat Module 简介

- 对于社区常见需求进行配置封装增加易用性
  - Nginx
  - Apache
  - MySQL
- 封装内容
  - filebeat.yml配置
  - ingest node pipeline配置
  - Kibana dashboard