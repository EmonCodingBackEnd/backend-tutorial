# ElasticStack实战

- 目标

  - 收集Elasticsearch集群的查询语句
  - 分析查询语句的常用语句、相应时长等

- 方案

  - 应用Packetbeat+Logstash完成数据收集工作
  - 使用Kibana+Elasticsearch完成数据分析工作

- 方案

  - Product Cluster
    - Elasticsearch http://192.168.8.116:9200
    - Kibana http://192.168.8.116:5601
  - Monitoring Cluster
    - Elasticsearch http://192.168.8.116:8200
      - bin/elasticsearch -Ecluster.name=sniff_search -Ehttp.port=8200 -Epath.diff=sniff
    - Kibana http://192.168.8.116:8601
      - bin/kibana -e http://192.168.8.116:8200 -p 8601

  - Production与Monitoring不能是一个集群，否则会进入抓包死循环

- 方案之logstash

```
input { beats { port => 5044 }}
```

```
filter {
  if "search" in [request] {
    grok {match => {"request" => ".*\n\{(?<query_body>.*)"}}
    grok {match => {"path" => "V(?<index>.*)V_search"}}
    if[index] {} else { mutate { add_field => {"index" => "All"}}}
    mutate {update => { "query_body" => "{%{query_body}"}}
  }
}
```

```
output {
  if "search" in [request] {
    elasticsearch { hosts => "192.168.8.116:8200"}
  }
}
```









