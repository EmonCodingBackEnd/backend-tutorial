# ElasticStack实战

- 目标

  - 收集Elasticsearch集群的查询语句
  - 分析查询语句的常用语句、相应时长等
- 分析
  - 应用Packetbeat+Logstash完成数据收集工作
  - 使用Kibana+Elasticsearch完成数据分析工作
- 方案

  - Product Cluster
    - Elasticsearch http://192.168.8.116:9200
      - /usr/local/elasticsearch/bin/elasticsearch -Ecluster.name=sniff_search
    - Kibana http://192.168.8.116:5601
      - /usr/local/kibana/bin/kibana
  - Monitoring Cluster
    - Elasticsearch http://192.168.8.116:8200
      - /usr/local/elasticsearch/bin/elasticsearch -Ecluster.name=sniff_search -Ehttp.port=8200 -Epath.data=sniff_search
    - Kibana http://192.168.8.116:8601
      - /usr/local/kibana/bin/kibana -e http://192.168.8.116:8200 -p 8601

  - Production与Monitoring不能是一个集群，否则会进入抓包死循环
- 方案之logstash
  - [emon@emon ~]$ /usr/local/logstash/bin/logstash -f /usr/local/logstash/sniff_search.conf 

```shell
[emon@emon ~]$ vim /usr/local/logstash/sniff_search.conf
```

```shell
input {
  beats {
    port => 5044
  }
}
filter {
  if "search" in [request] {
    grok {
      match => { "request" => ".*\n\{(?<query_body>.*)"}
    }
    grok {
      match => { "path" => "\/(?<index>.*)\/_search"}
    }
  if [index] {
  } else {
    mutate {
      add_field => { "index" => "All" }
    }
  }
    mutate {
      update => { "query_body" => "{%{query_body}"}}
    }
#    mutate {
#      remove_field => [ "[http][response][body]" ]
#    }
}

output {
  #stdout {codec=>rubydebug}
  if "search" in [request]{
    elasticsearch {
      hosts => "127.0.0.1:8200"
    }
  }
}
```

- 方案之packetbeat
  - [emon@emon ~]$ sudo /usr/local/packetbeat/packetbeat -e -c /usr/local/packetbeat/sniff_search.yml -strict.perms=false

```shell
[emon@emon ~]$ vim /usr/local/packetbeat/sniff_search.yml
```

```
packatebeat.interfaces.device: ens33
packatebeat.protocol.http:
  ports: [9200]
  send_request: true
  include_body_for: ["application/json", "x-www-form-urlencoded"]
output.console:
  pretty: true
output.logstash:
  hosts: ["127.0.0.1:5044"]
```











