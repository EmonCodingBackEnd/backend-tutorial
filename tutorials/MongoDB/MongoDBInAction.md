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

## 1.1、standalone安装

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
[emon@emon ~]$ mkdir -p /usr/local/mongodb/{conf,data/27017,log}
```

6. 配置文件

```bash
[emon@emon ~]$ vim /usr/local/mongodb/conf/27017.conf
```

```bash
# 端口，默认27017，MongoDB的默认服务TCP端口
port=27017
# 远程连接要指定ip，不然无法连接；0.0.0.0表示不限制ip访问，并开启对应端口
bind_ip=0.0.0.0
# 日志文件
logpath=/usr/local/mongodb/log/27017.log
# 数据文件存放目录，默认： /data/db/
dbpath=/usr/local/mongodb/data/27017/
# 日志追加
logappend=true
# 启动的进程ID
pidfilepath=/usr/local/mongodb/data/27017/27017.pid
# 如果为true，以守护程序的方式启动，即在后台运行
fork=false
# oplog窗口大小
oplogSize=5120
# 复制集名称
# replSet=emon
# 是否认证
auth=true
```

7. 启动与停止

- 启动

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/27017.conf
或
[emon@emon ~]$ mongod -f /usr/local/mongodb/conf/27017.conf
```

- 停止

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/27017.conf --shutdown
```

8. 设置启动项（**注意：如果通过该方式，配置文件中的 fork=true**）

```bash
[emon@emon ~]$ sudo vim /usr/lib/systemd/system/mongod.service
```

```bash
[Unit]
    Description=mongodb
    After=network.target remote-fs.target nss-lookup.target
[Service]
    Type=forking
    ExecStart=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/27017.conf
    ExecReload=/bin/kill -s HUP $MAINPID
    ExecStop=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/27017.conf --shutdown
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

9. 设置supervisor启动（**注意：如果通过该方式，配置文件中的 fork=false**）【推荐】

```ini
[program:mongo]
command=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/27017.conf
autostart=false                 ; 在supervisord启动的时候也自动启动
startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3                  ; 启动失败自动重试次数，默认是3
user=emon                       ; 用哪个用户启动进程，默认是root
priority=70                     ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true            ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
environment=JAVA_HOME="/usr/local/java"
stdout_logfile=/etc/supervisor/supervisor.d/mongo.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

- 加载

```bash
[emon@emon ~]$ sudo supervisorctl update
```

- 启动mongodb

```bash
[emon@emon ~]$ sudo supervisorctl start mongo
```

- 停止mongodb

```bash
[emon@emon ~]$ sudo supervisorctl stop mongo
```

10. 打开命令行

- 无密码打开命令行

```bash
[emon@emon ~]$ mongo
```

- 密码打开命令行

```bash
# 方式一
[emon@emon ~]$ mongo
> use admin
> db.auth('root', 'root123')
# 方式二
# 如果密码包含特殊字符，比如！，需要在密码前后带上单引号 '包含特殊字符的密码'
[emon@emon ~]$ mongo admin -u root -p root123
```



## 1.2、docker安装

1. 下载MongoDB的官方docker镜像

```bash
[emon@emon ~]$ docker pull mongo:4
```

2. 查看下载的镜像

```bash
[emon@emon ~]$ docker images
```

3. 启动一个MongoDB服务器容器

```bash
[emon@emon ~]$ docker run  --name mymongo -v /data/MongoDB/data/:/data/db -d mongo:4
```

- `--name mymongo` --> 容器名称
- `-v /data/MongoDB/data/:/data/db` --> 挂在数据目录
- `-d` -- > 后台运行容器

4. 查看docker容器状态

```bash
[emon@emon ~]$ docker ps
```

5. 查看数据库服务器日志

```bash
[emon@emon ~]$ docker logs -f mymongo
```

6. 停止和再启动

- 停止MongoDB

```bash
[emon@emon ~]$ docker stop mymongo
```

- 再次启动MoongoDB

```bash
[emon@emon ~]$ docker start mymongo
```

# 二、Mongo数据库介绍

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

## 2.3、对象主键ObjectId

对象主键是一个可快速生成的12字节id，是文档的默认主键。

对象主键组成部分：

ObjectId使用12字节的存储空间，每一个字节是两位十六进制数字，是一个24位的字符串，该12字节按照如下方法生成：

| 字节数      | 含义                 |
| ----------- | -------------------- |
| 第1-4字节   | UNIX时间戳，精确到秒 |
| 第5-7字节   | 主机标识符           |
| 第8-9字节   | 进程PID              |
| 第10-12字节 | 计数器               |

- 生成主键ObjectId

```js
> ObjectId()
ObjectId("602d2112ebecf117915b097b")
```

- 提取ObjectId的创建时间

```js
> ObjectId("602d2112ebecf117915b097b").getTimestamp()
ISODate("2021-02-17T13:58:42Z")
```

- 复合主键

```js
> use test
> db.accounts.insert(
	{
        _id: {accountNo: "001", type: "savings"},
        name: "irene",
        balance: 80
    }
)
WriteResult({ "nInserted" : 1 })
```



# 三、数据定义语言（DDL）

## 3.1、 数据库操作

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

## 3.2、集合操作

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



# 四、数据操纵语言（DML）

## 4.1、创建文档

### 4.1.1、插入单个文档

语法格式：

```js
db.collection.insertOne(
   <document>,
   {
      writeConcern: <document>
   }
)
```

参数说明：

`collection`: 集合名称

`document`:  要写入的文档

`writeConcern`:  定义了本次文档创建操作的安全写级别，简单来说，安全写级别用来判断一次数据库写入操作是否成功。如果不提供writeConsern文档，MongoDB使用默认的安全写级别。

执行命令：

```js
> use test
> try {
    db.accounts.insertOne(
        {
            _id: "account1",
            name: "alice",
            balance: 100
        }
    )
} catch(e) {
    print(e)
}
```

执行结果：

```js
{ "acknowledged" : true, "insertedId" : "account1" }
```

`acknowledged`: 如果writeConcern值为1，则返回true；否则返回false

`insertedId`: 文档的_id

**总结**：

此时，执行`show collections`会发现多了一个集合`accounts`，db.collection.insertOne()命令会自动创建响应的集合；

命令中的collection代指集合名称，比如这里的 `accounts`。

**Example**:

省略创建文档中的_id字段：

```js
> db.accounts.insertOne(
	{
        name: "bob",
        balance: 50
    }
)
```



### 4.1.2、插入多个文档

语法格式：

```js
db.collection.insertMany(
   [ <document 1> , <document 2>, ... ],
   {
      writeConcern: <document>,
      ordered: <boolean>
   }
)
```

参数说明：

`collection`: 集合名称

`document`: 要写入的文档或文档数组

`writeConcern`: 定义了本次文档创建操作的安全写级别，简单来说，安全写级别用来判断一次数据库写入操作是否成功。如果不提供writeConsern文档，MongoDB使用默认的安全写级别。

`ordered`: 指定是否按顺序写入，默认true，按顺序写入；如果将ordered参赛设置为false，MongoDB可以打乱文档写入顺序，以便优化写入操作的性能。

执行命令：

```js
> use test
> db.accounts.insertMany(
    [
        {
            name: "charlie",
            balance: 500
        },
        {
            name: "david",
            balance: 200
        }
    ]
)
```

执行结果：

```js
{
	"acknowledged" : true,
	"insertedIds" : [
		ObjectId("602d136cebecf117915b0975"),
		ObjectId("602d136cebecf117915b0976")
	]
}
```

`acknowledged`: 如果writeConcern值为1，则返回true；否则返回false

`insertedIds`: 多个文档的_ids

**总结**：

在执行db.collection.insertMany命令时，默认的`{ordered: true}` 在遇到错误时，操作便会退出，剩余的文档无论正确与否，都不会被写入；如果是 `{ordered: false}` 在遇到错误时，剩余正确的文档也会被写入。



- 插入文档（单个或者多个）

语法格式：

```js
db.collection.insert(
   <document or array of documents>,
   {
     writeConcern: <document>,
     ordered: <boolean>
    }
)
```

参数说明：

`collection`: 集合名称

`document`: 要写入的文档或文档数组

`writeConcern`: 定义了本次文档创建操作的安全写级别，简单来说，安全写级别用来判断一次数据库写入操作是否成功。如果不提供writeConsern文档，MongoDB使用默认的安全写级别。

`ordered`: 指定是否按顺序写入，默认true，按顺序写入；如果将ordered参赛设置为false，MongoDB可以打乱文档写入顺序，以便优化写入操作的性能。

执行命令：

```js
> use test
> db.accounts.insert(
	{
        name: "george",
        balance: 1000
    }
)
> db.accounts.insert(
	[
        {
            name: "charlie",
            balance: 500
        },
        {
            name: "david",
            balance: 200
        }
    ]
)
```

执行结果:

```js
WriteResult({ "nInserted" : 1 })
```

`nInserted`: 写入的文档的数量

**三种创建文档命令的区别**：

>insertOne和insertMany命令不支持db.collection.explain()命令
>
>insert支持db.collection.explain()命令



### 4.1.3、插入或者更新文档

描述：当db.collection.save()命令处理一个新文档时，会调用db.collection.save()命令。

语法格式：

```js
db.collection.save(
   <document>,
   {
     writeConcern: <document>
   }
)
```

参数说明：

`collection`: 集合名称

`document`: 要写入的文档

`writeConcern`: 定义了本次文档创建操作的安全写级别，简单来说，安全写级别用来判断一次数据库写入操作是否成功。如果不提供writeConsern文档，MongoDB使用默认的安全写级别。

执行命令：

```js
> use test
> db.accounts.save(
	{
        name: "liming",
        balance: 1000
    }
)
```

执行结果：

```js
WriteResult({ "nInserted" : 1 })
```

`nInserted`: 写入的文档的数量



## 4.2、更新文档

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



## 4.3、删除文档





# 五、数据查询语言（DQL）

语法格式：

`db.collection.find(query, projection)`

参数说明：

| 参数       | 类型     | 描述                                 |
| ---------- | -------- | ------------------------------------ |
| query      | document | 可选，筛选条件，默认:{}              |
| projection | document | 可选，对查询结果的投射，指定返回字段 |

## 5.1、常规查询

- 查询全部文档

```js
> db.accounts.find()
```

- 查询全部文档，以良好格式输出

```js
> db.accounts.find().pretty()
```

- 匹配查询：查询alice的银行账户文档

```js
> db.accounts.find({name: "alice"})
```

- 匹配查询：查询alice的余额为100元的银行账户文档

```js
> db.accounts.find({name: "alice", balance: 100})
```

- 匹配查询：查询银行账户类型为储蓄账户的文档

```js
> db.accounts.find({"_id.type": "savings"})
```

**总结**：

在find语句里，如果是顶级字段，不加引号和加引号都行；如果是内嵌文档字段，那么整个字段都是要用引号括起来的。



## 5.2、比较操作符（Comparison Query Operators）

### $eq

语法格式：

```js
{ <field>: { $eq: <value> } }
```

匹配字段值相等的文档

- 查询alice的银行账户文档

```js
> db.accounts.find({name:{$eq:"alice"}})
```

### $ne

语法格式：

```js
{ <field>: { $ne: <value> } }
```

匹配字段值不等的文档

- 查询不属于alice的银行账户文档

```js
> db.accounts.find({name:{$ne:"alice"}})
```

- 查询银行账户类型不是储蓄账户的文档，**会检索出不包含指定字段的文档**

```js
> db.accounts.find({"_id.type":{$ne:"savings"}})
```

### $gt

语法格式：

```js
{ <field>: { $gt: <value> } }
```

匹配字段值大于查询值的文档

- 查询余额大于500的银行账户文档

```js
> db.accounts.find({balance:{$gt:500}})
```

### $gte

语法格式：

```js
{ <field>: { $gte: <value> } }
```

匹配字段值大于或等于查询值的文档

### $lt

语法格式：

```js
{ <field>: { $lt: <value> } }
```

匹配字段值小于查询值的文档

- 查询用户名字排在fred之前的银行账户文档

```js
> db.accounts.find({name:{$lt:"fred"}})
```

### $lte

语法格式：

```js
{ <field>: { $lte: <value> } }
```

匹配字段值小于或等于查询值的文档

### $in

语法格式：

```js
{ <field>: { $in: [<value1>, <value2> ... <valueN>] } }
```

匹配字段值与任一查询值相等的文档

- 查询alice和charlie的银行账户文档

```js
> db.accounts.find({name:{$in:["alice", "charlie"]}})
```

### $nin

语法格式：

```js
{ <field>: { $nin: [<value1>, <value2> ... <valueN>] } }
```

匹配字段值与任何查询值都不相等的文档

- 查询除了alice和charlie之外的其他用户的银行账户文档

```js
> db.accounts.find({name:{$nin:["alice", "charlie"]}})
```

- 查询账户类型不是储蓄账户的银行账户文档，**会检索出不包含指定字段的文档**

```js
> db.accounts.find({"_id.type":{$nin:["savings"]}})
```



## 5.3、逻辑操作符（Logical Query Operators）

### $not

语法格式：

```js
{ field: { $not: { <operator-expression> } } }
```

匹配筛选条件不成立的文档

- 读取余额不小于500的银行账户文档

```js
> db.accounts.find({balance:{$not:{$lt:500}}})
```

- 查询账户类型不是储蓄账户的银行账户文档，**会检索出不包含指定字段的文档**

```js
> db.accounts.find({"_id.type":{$not:{$eq:"savings"}}})
```

### $and

语法格式：

```js
{ $and: [ { <expression1> }, { <expression2> } , ... , { <expressionN> } ] }
```

匹配多个筛选条件全部成立的文档

- 查询余额大于100并且用户姓名排在fred之后的银行账户文档

```js
> db.accounts.find({
    $and: [
        {balance: {$gt:100}},
        {name:{$gt:"fred"}}
    ]
})
```

- 当筛选条件应用在不同字段上时，可以省略`$and`操作符

```js
> db.accounts.find({balance: {$gt:100},name:{$gt:"fred"}})
```

- 当筛选条件应用在同一个字段上时，也可以简化命令

```js
> db.accounts.find({balance:{$gt:100, $lt:500}})
```

### $or

语法格式：

```js
{ $or: [ { <expression1> }, { <expression2> }, ... , { <expressionN> } ] }
```

匹配至少一个条件成立的文档

- 查询属于alice或者charlie的银行账户文档

```js
> db.accounts.find({
    $or: [
        {name: {$eq:"alice"}},
        {name:{$eq:"charlie"}}
    ]
})
```

- 当所有筛选条件使用的都是`$eq`操作符时，`$or`和`$in`的效果是相同的

```js
> db.accounts.find({name: {$in: ["alice", "charlie"]}})
```

- 读取余额小于100或者大于5003 银行账户文档

```js
> db.accounts.find({
    $or: [
        {balance: {$lt: 100}},
        {balance: {$gt: 500}}
    ]
})
```

### $nor

语法格式：

```js
{ $nor: [ { <expression1> }, { <expression2> }, ... , { <expressionN> } ] }
```

匹配多个筛选条件全部不成立的文档

- 查询不属于alice和charlie且余额不小于100的银行账户文档

```js
> db.accounts.find({
    $nor: [
        {name: "alice"},
        {name: "charlie"},
        {balance: {$lt: 100}}
    ]
})
```

- 查询账户类型不是储蓄账户且余额大于500的银行账户文档，**会检索出不包含指定字段的文档**

```js
> db.accounts.find({
    $nor: [
        {"_id.type": "savings"},
        {balance: {$gt: 500}}
    ]
})
```



## 5.4、字段操作符（Element Query Operators）

### $exists

语法格式：

```js
{ field: { $exists: <boolean> } }
```

匹配包含查询字段的文档

- 查询包含账户类型字段的银行账户文档

```js
> db.accounts.find({"_id.type":{$exists:true}})
```

- 精确查找，优化**会检不包含指定字段的文档**的问题

```js
> db.accounts.find({"_id.type":{$ne:"checking", $exists:true}})
```

### $type

语法格式：

```js
{ field: { $type: <BSON type> } }
// 或者
{ field: { $type: [ <BSON type1> , <BSON type2>, ... ] } }
```

匹配字段类型符合查询值的文档

- 查询文档主键是字符串的银行账户文档

```js
> db.accounts.find({_id:{$type:"string"}})
```

- 查询文档主键是对象主键或者是复合主键的银行账户文档

```js
> db.accounts.find({_id:{$type:["objectId", "object"]}})
```

- 查询用户姓名是`null`的银行账户文档

```js
> db.accounts.find({name:{$type: "null"}})
```



# 八、数据控制语言（DCL）

## 8.1、MongoDB数据库默认角色

- 数据库用户角色
  - `read`: 允许用户查询指定数据库
  - `readWrite`:允许用户读写指定数据库
- 数据库管理角色
  - `dbAdmin`: 允许用户在指定数据库中执行管理函数，如索引创建、删除，查看统计或访问system.profile
  - `dbOwner`: 
  - `userAdmin`: 允许用户向system.users集合写入，可以找指定数据库里创建、删除和管理用户
- 集群管理角色
  - `clusterAdmin`: 只在admin数据库中可用，赋予用户所有分片和复制集相关函数的管理权限。
  - `clusterManager`: 
  - clusterMonitor
  - hostManager
- 备份恢复角色
  - backup
  - restore
- 所有数据库角色
  - `readAnyDatabase`: 只在admin数据库中可用，赋予用户所有数据库的读权限
  - `readWriteAnyDatabase`: 只在admin数据库中可用，赋予用户所有数据库的读写权限
  - `userAdminAnyDatabase`: 只在admin数据库中可用，赋予用户所有数据库的userAdmin权限
  - `dbAdminAnyDatabase`: 只在admin数据库中可用，赋予用户所有数据库的dbAdmin权限。
- 超级用户角色
  - `root`: 只在admin数据库中可用。超级账号，超级权限



## 8.2、设置用户名密码

1. 先添加用户

- 命令行下添加用户

```bash
> use admin
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

2. 修改配置，启用认证

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

3. 使用密码登录后配置其他库密码

- 配置一个仅能访问test数据库的用户

```bash
> use test
> db.createUser({
	user: "test",
	pwd: "test123",
	roles: [{role:"readWrite", db:"test"}]
})
```

- 查看当前库下的用户

```bash
> show users
```

- 修改用户密码

```bash
> db.updateUser('root', {pwd:'root@123'})
```

- 删除用户

```bash
> db.dropUser('root')
```





# 九、MongDB的操作工具

## 9.1、Robo 3T连接

1. 下载

下载地址：https://robomongo.org/download

2. 启动并连接

## 9.2、Mongo Express

Mongo Express是一个基于网络的MongoDB数据库管理界面

### 9.2.1、安装MongoExpress（Docker版）

1. 下载mongo-express镜像

```bash
[emon@emon ~]$ docker pull mongo-express
```

2. 运行mongo-express

```bash
[emon@emon ~]docker run --name myMgExp --link mymongo:mongo -p 18081:8081 -d mongo-express
```

- `--link <container_id|container_name>:alias` --> 表示链接2个容器，`:`之前是容器的name或者id，`:`之后的alias是源容器在link下的别名。
- 错误处理：

>/usr/bin/docker: Error response from daemon: driver failed programming external connectivity on endpoint hungry_chandrasekhar (e0b186c6848e9e6b7d01b8d2b99fc152358b80f2b528697c5f415009721686b5):  (iptables failed: iptables --wait -t nat -A DOCKER -p tcp -d 0/0 --dport 8081 -j DNAT --to-destination 172.17.0.4:8081 ! -i docker0: iptables: No chain/target/match by that name.
> (exit status 1)).
>ERRO[0000] error waiting for container: context canceled 

重启docker后再次试试：

```bash
[emon@emon ~]$ sudo systemctl restart docker
```

## 9.3、 Mongo Shell（Docker版）

Mongo Shell是用来操作MongoDB的javascript客户端界面

- 运行mongo shell

```bash
[emon@emon ~]$ docker exec -it mymongo mongo
```

- 退出mongo shell

```bash
> exit
```



# 九十九、用户信息

## 1、mongodb用户

| 用户名 | 密码      |
| ------ | --------- |
| root   | root123   |
| test   | test123   |
| flyin  | flyin!123 |





