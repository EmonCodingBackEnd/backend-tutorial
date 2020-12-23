# MongoDB实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

1. 下载

下载地址： <https://www.mongodb.com/download-center/community>

下载地址列表：https://www.mongodb.com/download-center/community/releases/archive

![1568993780255](images/1568993780255.png)

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.4.1.tgz
```

*MongoDB有三种模式：standalone，replica set， shareded cluster*

## 1.1 standalone安装

1. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/MongoDB
```

2. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/mongodb-linux-x86_64-rhel70-4.4.1.tgz -C /usr/local/MongoDB/
```

3. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/MongoDB/mongodb-linux-x86_64-rhel70-4.4.1/ /usr/local/mongodb
```

4. 配置环境变量

在`/etc/profile.d`目录创建`mongodb.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/mongodb.sh
export PATH=/usr/local/mongodb/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

5. 数据库目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/mongodb/{db,log,conf}
```

6. 配置文件

```bash
[emon@emon ~]$ vim /usr/local/mongodb/conf/mongodb.conf
```

```bash
# 数据文件存放目录，默认： /data/db/
dbpath=/usr/local/mongodb/db
# 日志文件
logpath=/usr/local/mongodb/log/mongodb.log
# 端口，默认27017，MongoDB的默认服务TCP端口
port=27017
# 以守护程序的方式启动，即在后台运行
fork=true
# 日志追加
logappend=true
# 是否认证
auth=false
# 远程连接要指定ip，不然无法连接；0.0.0.0表示不限制ip访问，并开启对应端口
bind_ip=0.0.0.0
```

7. 启动与停止

- 启动

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/mongodb.conf 
或
[emon@emon ~]$ mongod -f /usr/local/mongodb/conf/mongodb.conf 
```

- 停止

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/mongodb.conf --shutdown
```

8. 设置启动项

```bash
[emon@emon ~]$ sudo vim /usr/lib/systemd/system/mongod.service
```

```bash
[Unit]
    Description=mongodb
    After=network.target remote-fs.target nss-lookup.target
[Service]
    Type=forking
    ExecStart=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf
    ExecReload=/bin/kill -s HUP $MAINPID
    ExecStop=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf --shutdown
    PrivateTmp=true
[Install]
    WantedBy=multi-user.target
```

- 加载启动项

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
```

- 启动mongodb

```bash
[emon@emon ~]$ sudo systemctl start mongod
```

- 停止mongodb

```bash
[emon@emon ~]$ sudo systemctl stop mongod
```

9. 设置用户名密码

- 命令行下添加用户

```bash
> admin
> db.createUser({
	user: "root",
	pwd: "root123",
	roles: [{role:"root", db:"admin"}]
})
```

- 查看用户

```bash
> show users
```

- 修改配置

```bash
# 打开配置，修改如下
[emon@emon ~]$ vim /usr/local/mongodb/conf/mongodb.conf
```

```bash
# 是否认证
auth=true
```

- 重启服务

```bash
[emon@emon ~]$ sudo systemctl restart mongod
```

- 登录数据库

```bash
# 方式一
use admin
db.auth('root', 'root123')
# 方式二
mongo admin -u root -p root123
```

- 配置一个仅能访问test数据库的用户

```bash
> use test
> db.createUser({
	user: "test",
	pwd: "test123",
	roles: [{role:"readWrite", db:"test"}]
})
```

# 二、命令

## 2.1、 概念对比

| RDBMS         | MongoDB                      |
| ------------- | ---------------------------- |
| 数据库        | 数据库                       |
| 表格          | 集合                         |
| 行            | 文档                         |
| 列            | 字段                         |
| 表联合        | 嵌入文档                     |
| 主键          | 主键（MongoDB提供了key为_id) |
| Mysqld/Oracle | mongod                       |
| mysql/sqlplus | mongo                        |

## 2.2、数据类型

| 数据类型           | 描述                                     |
| ------------------ | ---------------------------------------- |
| String             | 字符串                                   |
| Integer            | 整形数值                                 |
| Boolean            | 布尔值                                   |
| Double             | 双精度浮点值                             |
| Min/Max keys       | 将一个值与BSON最低值和最高值对比         |
| Array              | 用于将数组或列表或多个值存储为一个键     |
| Timestamp          | 时间戳                                   |
| Object             | 用于内嵌文档                             |
| Null               | 用于创建空值                             |
| Symbol             | 符号                                     |
| Date               | 日期时间                                 |
| Object ID          | 对象ID。用于创建文档的ID                 |
| Binary Data        | 二进制数据                               |
| Code               | 代码类型。用于在文档中存储JavaScript代码 |
| Regular expression | 正则表达式类型                           |

## 2.3、 基本命令

- 打开命令行

```bash
mongo
```

### 1、数据库操作

- 创建数据库或切换数据库

语法格式： `use <dbname>`

在MongoDB中，集合只有在内容插入后才会创建！

```bash
> use test
> db.test.insert({"name":"菜鸟教程"})
```

- 删除数据库

语法格式： `db.dropDatabase()`

```bash
# 删除当前数据库
> db.dropDatabase()
```

- 查看所有数据库

```bash
> show dbs
```

**说明：**

`admin`: 从权限的角度来看，这是“root”数据库。要是将一个用户添加到这个数据库，这个用户自动继承所有数据库的权限。一些特定的服务器端命令也只能从这个数据库运行，比如列出所有的数据库或者关闭服务器。

`local`: 这个数据永远不会被复制，可以用来存储限于本地单台服务器的任意集合

`config`: 当Mongo用于分片设置时，config数据库在内部使用。用于保存分片的相关信息。

- 显示当前数据库

```bash
> db
```



### 2、集合操作

- 创建集合

语法格式：` db.createCollection(name, options)`

参数说明：

`name`: 要创建的集合名词

`options`: 可选参数，指定有关内存大小及索引的选项，描述如下：

| 字段   | 类型 | 描述                                                         |
| ------ | ---- | ------------------------------------------------------------ |
| capped | 布尔 | （可选）如果为true，则创建固定集合。固定集合是指有固定大小的集合，当达到最大值时，它会自动覆盖最早的文档。当该值为true时，必须指定size参数。 |
| size   | 数值 | （可选）为固定集合指定一个最大值，即字节数。如果capped为true，也需要指定该字段。 |
| max    | 数值 | （可选）指定固定集合中包含文档的最大数量。                   |

在插入文档时，MongoDB首先检查固定集合的size字段，然后检查max字段。

```bash
> use test
> db.createCollection("runoob")
```

- 查看集合

```bash
> show collections
# 或者
> show tables
```

- 自动创建集合

在MongoDB中，你不需要创建集合。当你插入文档时，MongoDB会自动创建集合。

```bash
# 如下命令会自动创建col集合
> db.col.insert({"name":"菜鸟教程"})
```

- 删除集合

语法格式： `db.<colname>.drop()`

如果成功删除则返回true；否则返回false

```bash
# 删除col集合
> db.col.drop()
```



### 3、文档操作

- 插入单个文档

语法格式：

插入一个文档： `db.<colname>.insertOne(doc,{writeConcern:<value>})`

参数说明：

`doc`: 要写入的文档

`writeConcern`: 写入策略，默认为1，即要求确认写操作，0是不要求。

返回结果：

`acknowledged`: 如果writeConcern值为1，则返回true；否则返回false

`insertedId`: 文档的_id

```bash
> db.col.insertOne(
{title:"MongoDB教程",description:"MongoDB是一个NoSQL数据库",by:"菜鸟教程",url:"http://www.runoob.com",tags:["mongodb","database","NoSQL"],likes:100}
)
```

- 插入多个文档

插入多个文档：`db.<colname>.insertMany([<doc1>,<doc2>,...]{writeConcern:<value>,ordered:<bool>})`

参数说明：

`doc`: 要写入的文档

`writeConcern`: 写入策略，默认为1，即要求确认写操作，0是不要求。

`ordered`: 指定是否按顺序写入，默认true，按顺序写入。

返回结果：

`acknowledged`: 如果writeConcern值为1，则返回true；否则返回false

`insertedIds`: 多个文档的_ids

```bash
> db.col.insertMany([
{item:"journal", qty: 25, tags: ["black", "red"], size: { h:14, w: 21, uom: "cm"}},
{item:"mat", qty: 85, tags: ["gray"], size: { h:27.9, w: 35.5, uom: "cm"}}
])
```

- 查询文档

```bash
> db.col.find({})
```

- 更新单个文档

语法格式：

 `db.<colname>.updateOne(<filter>, <update>, <options>)`

或者：

`db.<colname>replaceOne(<filter>, <update>, <options>)`

```bash
> db.col.updateOne({item:"mat"},{$set:{"size.w":36.5,status:"P"},$currentDate:{lastModified:true}})
```

- 更新多个文档

语法格式： `db.<colname>.updateMany(<filter>, <update>, {upsert:<boolean>,writeConcern:<value>,collation:<doc>,arrayFilters:[<filterdocument1>,...],hint:<doc|string>})`



# 九、Robo 3T连接

## 1、下载

下载地址：https://robomongo.org/download

## 2、启动并连接



