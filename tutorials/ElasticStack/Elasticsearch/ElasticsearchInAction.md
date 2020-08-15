# Elasticsearch实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

[临时：ES配置文件详解](https://www.cnblogs.com/sunxucool/p/3799190.html)

# 一、使用`canal`同步数据

**canal [kə'næl]**，译意为水道/管道/沟渠，主要用途是基于 MySQL 数据库增量日志解析，提供增量数据订阅和消费。

基于日志增量订阅和消费的业务包括

- 数据库镜像
- 数据库实时备份
- 索引构建和实时维护(拆分异构索引、倒排索引等)
- 业务 cache 刷新
- 带业务逻辑的增量数据处理

[canal github地址](https://github.com/alibaba/canal)

以上是`canal`的官方说明文档。

## 1、安装

下载`canal`，共有4部分：

[各组件下载地址](https://github.com/alibaba/canal/releases)

- canal.adapter-1.1.4.tar.gz
  - 订阅deployer服务，适配到各个数据存储库，比如mysql/kafka/elasticsearch/hbase等
- canal.admin-1.1.4.tar.gz
  - 为canal提供整体配置管理、节点运维等面向运维的功能
- canal.deployer-1.1.4.tar.gz
  - canal的deployer服务
- canal.example-1.1.4.tar.gz
  - 订阅`deployer`服务的客户端演示版示例

整体安装的目录规划：

```bash
[emon@emon ~]$ mkdir -pv /usr/local/canal/{adapter,admin,deployer,example}
```

### 1.1、部署`deployer`服务

- 对于自建`MySQL`服务，需要开启`Binlog`写入功能

```bash
[emon@emon ~]$ sudo vim /usr/local/mysql/etc/my.cnf
```

```bash
log-bin = /usr/local/mysql/binlogs/mysql-bin
binlog_format = row
server-id=1
```

- 授权`canal`链接`MySQL`账号具有作为MySQL slave的权限，，如果已有账户可直接`grant`

```bash
-- 创建备份用户
create user 'backup'@'%' identified by 'XXX';
-- 授权备份用户
grant select,replication slave,replication client ON *.* TO 'backup'@'%';
-- 刷新生效
flush privileges;
```

- 演示用的MySQL库实例与表

```sql
-- 创建数据库
CREATE DATABASE IF NOT EXISTS canaldb DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 使用数据库
use canaldb;

-- 创建数据表
drop table if exists loginfo;

/*==============================================================*/
/* Table: loginfo                                               */
/*==============================================================*/
create table loginfo
(
   id                   bigint(20) not null comment '主键ID',
   log_type             tinyint not null comment '日志类型',
   content              varchar(1000) not null comment '日志内容',
   deleted              tinyint not null default 0 comment '记录状态
            0-未删除
            1-已删除',
   create_time          datetime not null default current_timestamp comment '创建时间',
   modify_time          datetime not null default current_timestamp on update current_timestamp comment '更新时间',
   version              int not null default 0 comment '版本信息',
   primary key (id)
);

alter table loginfo comment '日志信息表';

-- 初始化数据
INSERT into loginfo (id, log_type, content, deleted, create_time, modify_time, version) VALUES(1, 1, '202008152033记录该文档', 0, '2020-08-15 20:34:12.0', '2020-08-15 20:34:12.0', 0);
INSERT INTO loginfo (id, log_type, content, deleted, create_time, modify_time, version) VALUES(2, 1, 'canal达到单机生产可用的效果', 0, '2020-08-15 20:34:57.0', '2020-08-15 20:34:57.0', 0);
```

- 下载

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://github.com/alibaba/canal/releases/download/canal-1.1.4/canal.deployer-1.1.4.tar.gz
```

- 解压

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/canal.deployer-1.1.4.tar.gz -C /usr/local/canal/deployer/
```

```bash
[emon@emon ~]$ ls /usr/local/canal/deployer/
bin  conf  lib  logs
```

- 配置`canal.properties

[配置文件详解](https://blog.csdn.net/my201110lc/article/details/80765356)

```bash
[emon@emon ~]$ vim /usr/local/canal/deployer/conf/canal.properties 
```

```properties
# 修改
canal.destinations = example
=>
canal.destinations = develop
```

- 复制`conf/example`配置文件进行修改

```bash
[emon@emon ~]$ cp -R /usr/local/canal/deployer/conf/example/ /usr/local/canal/deployer/conf/develop
[emon@emon ~]$ vim /usr/local/canal/deployer/conf/develop/instance.properties 
```

```properties
# 修改
canal.instance.master.address=127.0.0.1:3306
=>
canal.instance.master.address=192.168.1.66:3306
# 修改
canal.instance.dbUsername=canal
canal.instance.dbPassword=canal
=>
canal.instance.dbUsername=backup
canal.instance.dbPassword=xxx
# 修改：注意，\\.是.的转义;.*\\..*表示任何schema的任何表
canal.instance.filter.regex=.*\\..*
=>
canal.instance.filter.regex=canaldb\\..*
```

- 启动

```bash
[emon@emon ~]$ /usr/local/canal/deployer/bin/startup.sh
```

- 查看server日志

```bash
[emon@emon ~]$ vim /usr/local/canal/deployer/logs/canal/canal.log 
```

```
2020-08-15 20:40:49.945 [main] INFO  com.alibaba.otter.canal.deployer.CanalLauncher - ## set default uncaught exception handler
2020-08-15 20:40:49.991 [main] INFO  com.alibaba.otter.canal.deployer.CanalLauncher - ## load canal configurations
2020-08-15 20:40:50.003 [main] INFO  com.alibaba.otter.canal.deployer.CanalStarter - ## start the canal server.
2020-08-15 20:40:50.049 [main] INFO  com.alibaba.otter.canal.deployer.CanalController - ## start the canal server[192.168.1.66(192.168.1.66):11111]
2020-08-15 20:40:51.278 [main] INFO  com.alibaba.otter.canal.deployer.CanalStarter - ## the canal server is running now ......
2020-08-15 20:40:51.383 [canal-instance-scan-0] INFO  com.alibaba.otter.canal.deployer.CanalController - auto notify start example successful.
```

- 查看instance的日志

```bash
[emon@emon ~]$ vim /usr/local/canal/deployer/logs/develop/develop.log 
```

```
2020-08-15 21:16:46.942 [main] INFO  c.a.otter.canal.instance.spring.CanalInstanceWithSpring - start CannalInstance for 1-develop
2020-08-15 21:16:46.952 [main] WARN  c.a.o.canal.parse.inbound.mysql.dbsync.LogEventConvert - --> init table filter : ^canaldb\..*$
2020-08-15 21:16:46.952 [main] WARN  c.a.o.canal.parse.inbound.mysql.dbsync.LogEventConvert - --> init table black filter :
2020-08-15 21:16:46.961 [main] INFO  c.a.otter.canal.instance.core.AbstractCanalInstance - start successful....
2020-08-15 21:16:47.054 [destination = develop , address = /192.168.1.66:3306 , EventParser] WARN  c.a.o.c.p.inbound.mysql.rds.RdsBinlogEventParserProxy - ---> begin to find start position, it will be long time for reset or first position
2020-08-15 21:16:47.055 [destination = develop , address = /192.168.1.66:3306 , EventParser] WARN  c.a.o.c.p.inbound.mysql.rds.RdsBinlogEventParserProxy - prepare to find start position just show master status
2020-08-15 21:16:47.658 [destination = develop , address = /192.168.1.66:3306 , EventParser] WARN  c.a.o.c.p.inbound.mysql.rds.RdsBinlogEventParserProxy - ---> find start position successfully, EntryPosition[included=false,journalName=mysql-bin.000244,position=5841,serverId=1,gtid=,timestamp=1597497385000] cost : 593ms , the next step is binlog dump
```

- 关闭

```bash
[emon@emon ~]$ /usr/local/canal/deployer/bin/stop.sh
```




# 三、概念

## 1、常用术语

- Document 文档数据，是可以被索引的基本数据单位=>相当于一条表的记录
- Index 索引，含有相同属性的文档集合=>相当于数据库
- Type 索引中的数据类型，可以定义一个或多个类型，文档必须属于一个类型=>相当于数据表
- Field 字段，文档的属性
- Query DSL 查询语法
- 分片 每个索引都有多个分片，每个分片是一个Lucene索引
- 备份 拷贝一个分片，就完成了分片的备份

## 2、Elasticsearch CRUD

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

## 3、Elasticsearch Query

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





