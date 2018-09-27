# Elasticsearch实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

[临时：ES配置文件详解](https://www.cnblogs.com/sunxucool/p/3799190.html)

# 一、安装、配置与运行

## 1、安装与运行

### 1.1、 安装依赖

请确保安装了JDK1.8，安装方式参考： [JDK1.8安装参考](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md)

打开后搜索 **安装JDK** 即可。

### 1.2、下载

官网： https://www.elastic.co/

下载地址页： https://www.elastic.co/downloads

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.0.tar.gz
```

### 1.3、创建安装目录

```shell
[emon@emon ~]$ mkdir /usr/local/Elasticsearch
```

### 1.4、解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/elasticsearch-6.4.0.tar.gz -C /usr/local/Elasticsearch/
```

### 1.5、创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/Elasticsearch/elasticsearch-6.4.0/ /usr/local/elasticsearch
```

### 1.6、配置`elasticsearch.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch/config/elasticsearch.yml 
```

```yaml
network.host: 0.0.0.0
```

### 1.7、解决启动问题

#### 1.7.1、问题一

- 问题描述

```
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
```

- 解决办法

```shell
[emon@emon ~]$ sudo vim /etc/security/limits.conf
```

```
# 配置内容，其中emon是启动elasticsearch的用户，如果不确定是什么用户，也可以替换为*表示所有
emon             soft    nofile          1024
emon             hard    nofile          65536
```

**需要重新登录emon用户生效**

#### 1.7.2、问题二

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

### 1.8、启动

```shell
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch
```

### 1.9、访问

http://192.168.8.116:9200

```
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

## 2、配置说明

- 配置文件位于`/usr/local/elasticsearch/config`目录中
  - `elasticsearch.yml` es的相关配置
  - `jvm.options` jvm的相关参数
  - `log4j2.properties` 日志相关配置

### 2.1、JVM配置

#### 2.1.1、配置堆内存大小

默认的2g调整为256m

```
# -Xms2g
# -Xmx2g
-Xms256m
-Xmx256m
```

### 2.2、es配置

- `elasticsearch.yml`关键配置说明
  - `cluster.name` 集群名称，以此作为是否统一集群的判断条件
  - `node.name` 节点名称，以此作为集群中不同节点的区分条件
  - `network.host/http.port` 网络地址和断开，用于http和transport服务使用
  - `path.data` 数据存储地址
  - `path.log` 日志存储地址

- Development与Production模式说明
  - 以transport的地址是否绑定在localhost为判断标准 network.host
  - Development模式下在启动时会以warning的方式提示配置检查异常
  - Production模式下在启动时会以error的方式提示配置检查异常并退出

- 参数修改的第二种方式
  - bin/elasticsearch -Ecluster.name=<cluster_name> -Ehttp.port=19200

# 二、本地启动集群的方式

## 1、通过调整启动参数，配置集群

```shell
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch -Ecluster.name=emon -Enode.name=master
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch -Ecluster.name=emon -Enode.name=slave1 -Ehttp.port=8200 -Epath.data=slave1nodes -Ediscovery.zen.ping.unicast.hosts="0.0.0.0:9300"
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch -Ecluster.name=emon -Enode.name=slave2 -Ehttp.port=7200 -Epath.data=slave2nodes -Ediscovery.zen.ping.unicast.hosts="0.0.0.0:9300"
```

验证集群：

http://192.168.8.116:8200/_cat/nodes?v

http://192.168.8.116:7200/_cluster/stats

## 2、通过调整配置文件，配置集群

### 2.1、配置主节点

- 配置`elasticsearch.yml`

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch/config/elasticsearch.yml
```

```yaml
cluster.name: emon
node.name: master
# 表示该节点具有成为master的权利，但不一定就是master
node.master: true
network.host: 0.0.0.0
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch/config/jvm.options 
```

```
#-Xms2g
#-Xmx2g
-Xms256m
-Xmx256m
```

- 启动

```shell
[emon@emon ~]$ /usr/local/elasticsearch/bin/elasticsearch
```

### 2.2、配置从节点之一

- 配置`elasticsearch.yml`

```shell
[emon@emon ~]$ cp -r /usr/local/elasticsearch/ /usr/local/Elasticsearch/elasticsearch-5.6.11-slave1
[emon@emon ~]$ ln -s /usr/local/Elasticsearch/elasticsearch-5.6.11-slave1/ /usr/local/elasticsearch-slave1
[emon@emon ~]$ vim /usr/local/elasticsearch-slave1/config/elasticsearch.yml 
```

```yaml
cluster.name: emon
node.name: slave1
network.host: 0.0.0.0
http.port: 8200
discovery.zen.ping.unicast.hosts: ["0.0.0.0"]
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch-slave1/config/jvm.options 
```

```shell
#-Xms2g
#-Xmx2g
-Xms256m
-Xmx256m
```

- 启动

```shell
[emon@emon ~]$ /usr/local/elasticsearch-slave1/bin/elasticsearch
```

### 2.3、配置从节点之二

- 配置`elasticsearch.yml`

```shell
[emon@emon ~]$ cp -r /usr/local/elasticsearch/ /usr/local/Elasticsearch/elasticsearch-5.6.11-slave1
[emon@emon ~]$ ln -s /usr/local/Elasticsearch/elasticsearch-5.6.11-slave2/ /usr/local/elasticsearch-slave2
[emon@emon ~]$ vim /usr/local/elasticsearch-slave2/config/elasticsearch.yml 
```

```yaml
cluster.name: emon
node.name: slave2
network.host: 0.0.0.0
http.port: 7200
discovery.zen.ping.unicast.hosts: ["0.0.0.0"]
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch-slave2/config/jvm.options 
```

```shell
#-Xms2g
#-Xmx2g
-Xms256m
-Xmx256m
```

- 启动

```shell
[emon@emon ~]$ /usr/local/elasticsearch-slave2/bin/elasticsearch
```

# 三、概念

### 1、常用术语

- Document 文档数据，是可以被索引的基本数据单位=>相当于一条表的记录
- Index 索引，含有相同属性的文档集合=>相当于数据库
- Type 索引中的数据类型，可以定义一个或多个类型，文档必须属于一个类型=>相当于数据表
- Field 字段，文档的属性
- Query DSL 查询语法
- 分片 每个索引都有多个分片，每个分片是一个Lucene索引
- 备份 拷贝一个分片，就完成了分片的备份

### 2、Elasticsearch CRUD

- Create 创建文档

请求：

```
POST /accounts/person/1
{
  "name": "John",
  "lastname": "Doe",
  "job_description": "Systems administrator and Linux specialit"
}
```

应答：

```json
{
  "_index": "accounts",
  "_type": "person",
  "_id": "1",
  "_version": 1,
  "result": "created",
  "_shards": {
    "total": 2,
    "successful": 2,
    "failed": 0
  },
  "created": true
}
```

 - Read 读取文档

请求：

```
GET /accounts/persion/1
```

应答：

```json
{
  "_index": "accounts",
  "_type": "person",
  "_id": "1",
  "_version": 1,
  "found": true,
  "_source": {
    "name": "John",
    "lastname": "Doe",
    "job_description": "Systems administrator and Linux specialit"
  }
}
```

- Update 更新文档

请求：

```
POST /accounts/person/1/_update
{
  "doc": {
    "job_description": "Systems administrator and Linux specialist"
  }
}
```

应答：

```json
{
  "_index": "accounts",
  "_type": "person",
  "_id": "1",
  "_version": 2,
  "result": "updated",
  "_shards": {
    "total": 2,
    "successful": 2,
    "failed": 0
  }
}
```

- Delete 删除文档

请求：

```
DELETE /accounts/person/1
```

应答：

```json
{
  "found": true,
  "_index": "accounts",
  "_type": "person",
  "_id": "1",
  "_version": 4,
  "result": "deleted",
  "_shards": {
    "total": 2,
    "successful": 2,
    "failed": 0
  }
}
```

### 3、Elasticsearch Query

- Query String

```
GET accounts/person/_search?q=John
```

- Query DSL

```json
GET accounts/person/_search
{
  "query": {
    "term": {
      "name": {
        "value": "John"
      }
    }
  }
}
```

# 四、风格

## 1、RESTFul API

### 1.1、API基本格式

```http://<ip>:<port>/<索引>/<类型>/<文档id>
http://<ip>:<port>/<索引>/<类型>/<文档id>
```

### 1.2、常用HTTP动词

GET/PUT/POST/DELETE

## 2、索引创建

### 2.1、非结构化创建

### 2.2、结构化创建

使用Postman：

1. 请求

```
PUT http://192.168.8.116:9200/emon
```

```json
{
	"settings": {
		"number_of_shards": 3,
		"number_of_replicas": 1
	},
	"mappings": {
		"man": {
			"properties": {
				"name": {
					"type": "text"
				},
				"country": {
					"type": "keyword"
				},
				"age": {
					"type": "integer"
				},
				"date": {
					"type": "date",
					"format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
				}
			}
		},
		"woman": {
			
		}
	}
}
```

2. 应答

```json
{
    "acknowledged": true,
    "shards_acknowledged": true,
    "index": "emon"
}
```

## 3、插入文档

### 3.1、指定文档ID插入

使用Postman：

1. 请求

```
PUT http://192.168.8.116:9200/emon/man/1
```

```json
{
	"name": "emon",
	"country": "China",
	"age": 30,
	"date": "1987-06-15"
}
```

2. 应答

```json
{
    "_index": "emon",
    "_type": "man",
    "_id": "1",
    "_version": 1,
    "result": "created",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    },
    "created": true
}
```

### 3.2、自动文档ID插入

使用Postman：

1. 请求

```
POST http://192.168.8.116:9200/emon/man/
```

```json
{
	"name": "emon",
	"country": "China",
	"age": 40,
	"date": "1977-06-15"
}
```

2. 应答

```json
{
    "_index": "emon",
    "_type": "man",
    "_id": "AWXQKoieP04X6-zU3MjS",
    "_version": 1,
    "result": "created",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    },
    "created": true
}
```

## 4、修改文档

### 4.1、直接修改文档

使用Postman：

1. 请求

```
POST http://192.168.8.116:9200/emon/man/1/_update
```

```json
{
	"doc": {
		"name": "Your Smile"
	}
}
```

2. 应答

```json
{
    "_index": "emon",
    "_type": "man",
    "_id": "1",
    "_version": 2,
    "result": "updated",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    }
}
```

### 4.2、脚本修改文档

- 第一种方式

使用Postman：

1. 请求

```
POST http://192.168.8.116:9200/emon/man/1/_update
```

```json
{
	"script": {
		"lang": "painless",
		"inline": "ctx._source.age += 10"
	}
}
```

2. 应答

```json
{
    "_index": "emon",
    "_type": "man",
    "_id": "1",
    "_version": 3,
    "result": "updated",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    }
}
```

- 第二种方式

使用Postman：

1. 请求

```
POST http://192.168.8.116:9200/emon/man/1/_update
```

```json
{
	"script": {
		"lang": "painless",
		"inline": "ctx._source.age = params.age",
		"params": {
			"age": 100
		}
	}
}
```

2. 应答

```json
{
    "_index": "emon",
    "_type": "man",
    "_id": "1",
    "_version": 4,
    "result": "updated",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    }
}
```

## 5、删除

### 5.1、删除文档

使用Postman：

1. 请求

```
DELETE http://192.168.8.116:9200/emon/man/1
```

2. 应答

```json
{
    "found": true,
    "_index": "emon",
    "_type": "man",
    "_id": "1",
    "_version": 5,
    "result": "deleted",
    "_shards": {
        "total": 2,
        "successful": 2,
        "failed": 0
    }
}
```

### 5.2、删除索引

使用Postman：

1. 请求

```
DELETE http://192.168.8.116:9200/emon
```

2. 应答

```json
{
    "acknowledged": true
}
```

## 6、查询

### 6.0、查询的依赖索引创建

- 创建索引

```
PUT http://192.168.8.116:9200/book
```

```json
{
	"settings": {
		"number_of_shards": 5,
		"number_of_replicas": 1
	},
	"mappings": {
		"novel": {
			"properties": {
				"word_count": {
					"type": "integer"
				},
				"author": {
					"type": "keyword"
				},
				"title": {
					"type": "text"
				},
				"publish_date": {
					"type": "date",
					"format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
				}
			}
		}
	}
}
```

- 创建文档

```
# 其中，${ID}需要手动调整为具体的ID
PUT PUT http://192.168.8.116:9200/book/novel/${ID}
```

```json
# ID=1
{
	"word_count": "1000",
	"author": "张三",
	"title": "移魂大法",
	"publish_date": "2000-10-01"
}
# ID=2
{
	"word_count": "2000",
	"author": "李三",
	"title": "Java入门",
	"publish_date": "2010-10-01"
}
# ID=3
{
	"word_count": "2000",
	"author": "张四",
	"title": "Python入门",
	"publish_date": "2005-10-01"
}
# ID=4
{
	"word_count": "1000",
	"author": "李四",
	"title": "Elasticsearch大法好",
	"publish_date": "2017-08-01"
}
# ID=5
{
	"word_count": "5000",
	"author": "王五",
	"title": "菜谱",
	"publish_date": "2001-10-01"
}
# ID=6
{
	"word_count": "10000",
	"author": "赵六",
	"title": "简谱",
	"publish_date": "1997-01-01"
}
# ID=7
{
	"word_count": "1000",
	"author": "张三丰",
	"title": "太极拳",
	"publish_date": "1997-01-01"
}
# ID=8
{
	"word_count": "3000",
	"author": "瓦力",
	"title": "Elasticsearch入门",
	"publish_date": "2017-08-20"
}
# ID=9
{
	"word_count": "3000",
	"author": "很胖的瓦力",
	"title": "Elasticsearch精通",
	"publish_date": "2017-08-15"
}
# ID=10
{
	"word_count": "1000",
	"author": "牛魔王",
	"title": "芭蕉扇",
	"publish_date": "2000-10-01"
}
# ID=11
{
	"word_count": "1000",
	"author": "孙悟空",
	"title": "七十二变",
	"publish_date": "2000-10-01"
}
```



### 6.1、简单查询



### 6.2、条件查询

### 6.3、聚合查询



# 六、插件

创建目录，保存插件：

```shell
[emon@emon ~]$ mkdir /usr/local/Elasticsearch/ThirdPlugins
```

安装bzip2的解压工具：

```shell
[emon@emon ~]$ sudo yum install -y bzip2
```

## 1、elasticsearch-head

1. 运行

```shell
[emon@emon ~]$ cd /usr/local/Elasticsearch/ThirdPlugins/
[emon@emon ThirdPlugins]$ git clone git@github.com:mobz/elasticsearch-head.git
[emon@emon ThirdPlugins]$ cd elasticsearch-head/
[emon@emon elasticsearch-head]$ npm install
[emon@emon elasticsearch-head]$ npm run start
```

2. 配置 Elasticsearch 跨域访问

```shell
[emon@emon ~]$ vim /usr/local/elasticsearch/config/elasticsearch.yml 
```

```shell
# 追加
http.cors.enabled: true
http.cors.allow-origin: "*"
```

3. 访问测试

http://192.168.8.116:9100/

## 2、cerebro插件

1. 运行

```
[emon@emon ~]$ wget -cP /usr/local/src https://github.com/lmenezes/cerebro/releases/download/v0.8.1/cerebro-0.8.1.tgz
[emon@emon ~]$ tar -zxvf /usr/local/src/cerebro-0.8.1.tgz -C /usr/local/Elasticsearch/ThirdPlugins/
[emon@emon ~]$ ln -s /usr/local/Elasticsearch/ThirdPlugins/cerebro-0.8.1/ /usr/local/Elasticsearch/cerebro
[emon@emon ~]$ /usr/local/Elasticsearch/cerebro/bin/cerebro
```

2. 访问测试

http://192.168.8.116:9000




