# Elasticsearch实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

[临时：ES配置文件详解](https://www.cnblogs.com/sunxucool/p/3799190.html)

# 一、配置

## 1、配置说明

- 配置文件位于`/usr/local/elasticsearch/config`目录中
  - `elasticsearch.yml` es的相关配置
  - `jvm.options` jvm的相关参数
  - `log4j2.properties` 日志相关配置

### 1.1、JVM配置

#### 1.1.1、配置堆内存大小

默认的2g调整为256m

```
# -Xms2g
# -Xmx2g
-Xms256m
-Xmx256m
```

### 1.2、es配置

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





