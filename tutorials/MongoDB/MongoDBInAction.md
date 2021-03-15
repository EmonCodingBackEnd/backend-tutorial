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

5. 数据目录规划

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
# 日志控制，0-关闭，不收集任何数据；1-收集慢查询数据，默认是100毫秒；2-收集所有数据
profile=2
slowms=100
# 复制集名称
# replSet=emon
# 是否认证
auth=true
```

7. 启动与停止

- mongod命令查询

```bash
[emon@emon ~]$ mongod --help
```

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

```bash
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/mongo-27017.ini 
```

```ini
[program:mongo-27017]
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
stdout_logfile=/etc/supervisor/supervisor.d/mongo-27017.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
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

- mongo命令查询

```bash
[emon@emon ~]$ mongo --help
MongoDB shell version v4.4.1
usage: mongo [options] [db address] [file names (ending in .js)]
db address can be:
  foo                   foo database on local machine
  192.168.0.5/foo       foo database on 192.168.0.5 machine
  192.168.0.5:9999/foo  foo database on 192.168.0.5 machine on port 9999
  mongodb://192.168.0.5:9999/foo  connection string URI can also be used
Options:
  --host arg                           server to connect to
  --port arg                           port to connect to
Authentication Options:
  -u [ --username ] arg                username for authentication
  -p [ --password ] arg                password for authentication
```

- 无密码打开命令行

```bash
# 方式一
[emon@emon ~]$ mongo
# 方式二【单机推荐】
[emon@emon ~]$ mongo admin
# 方式三
[emon@emon ~]$ mongo localhost/admin
# 方式四
[emon@emon ~]$ mongo localhost:27017/admin
# 方式五【复制集推荐】
[emon@emon ~]$ mongo mongodb://localhost:27017/admin
# 方式六
[emon@emon ~]$ mongo --host localhost --port 27017 admin
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
# 方式三【单机推荐】
[emon@emon ~]$ mongo -u root -p root123 admin
# 方式四【复制集推荐】
[emon@emon ~]$ mongo mongodb://root:root123@localhost:27017/admin
# 方式五
[emon@emon ~]$ mongo --host localhost --port 27017 -uroot -proot123 admin
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



## 1.3、单点复制集安装

本安装基于`standalone`安装：

1. 调整节点配置，打开复制集名称，关闭认证

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
replSet=emon
# 是否认证
auth=false
```

2. 启动并配置单点复制集

- 通过supervisor重启
- 命令配置单点复制集

```bash
[root@emon ~]# mongo 127.0.0.1:27017/admin
```

```js
> config={
    _id:"emon",
    members: [
        {_id:0,host:"repo.emon.vip:27017"}
    ]
}
> rs.initiate(config)
```

> **说明**：上面的 `config.members.host` 如果是 `"0.0.0.0:27017"`，复制集初始化或者重配置时，会报错：
>
> 	emon:PRIMARY> rs.reconfig(config)
> 	{
> 		"operationTime" : Timestamp(1615793576, 1),
> 		"ok" : 0,
> 		"errmsg" : "No host described in new configuration with {version: 3, term: 3} for replica set emon maps to this node",
> 		"code" : 74,
> 		"codeName" : "NodeNotFound",
> 		"$clusterTime" : {
> 			"clusterTime" : Timestamp(1615793576, 1),
> 			"signature" : {
> 				"hash" : BinData(0,"lN8xHWICFER0gK33zL86lfAAltA="),
> 				"keyId" : NumberLong("6939150936686198788")
> 			}
> 		}
> 	}
> 可以替换`config.members.host`为具体IP地址，或者`/etc/hosts`下配置的本地DNS域名，比如：
>
> [emon@emon ~]$ cat /etc/hosts|grep repo
> 127.0.0.1   repo.emon.vip



## 1.3、复制集安装

本安装基于`standalone`安装：

1. 数据目录规划

```bash
[emon@emon ~]$ mkdir -pv /usr/local/mongodb/{conf,data/27017,data/27018,data/27019,log}
```

2. 调整第一个节点的配置，打开复制集名称，关闭认证

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
replSet=emon
# 是否认证
auth=false
```

3. 增加第二个数据节点

- mongo配置

```bash
[emon@emon ~]$ cp /usr/local/mongodb/conf/27017.conf /usr/local/mongodb/conf/27018.conf 
[emon@emon ~]$ vim /usr/local/mongodb/conf/27018.conf 
```

```ini
# 端口，默认27018，MongoDB的默认服务TCP端口
port=27018
# 远程连接要指定ip，不然无法连接；0.0.0.0表示不限制ip访问，并开启对应端口
bind_ip=0.0.0.0
# 日志文件
logpath=/usr/local/mongodb/log/27018.log
# 数据文件存放目录，默认： /data/db/
dbpath=/usr/local/mongodb/data/27018/
# 日志追加
logappend=true
# 启动的进程ID
pidfilepath=/usr/local/mongodb/data/27018/27018.pid
# 如果为true，以守护程序的方式启动，即在后台运行
fork=false
# oplog窗口大小
oplogSize=5120
# 复制集名称
replSet=emon
# 是否认证
auth=false
```

- supervisor配置

```bash
[emon@emon ~]$ sudo cp /etc/supervisor/supervisor.d/mongo-27017.ini /etc/supervisor/supervisor.d/mongo-27018.ini 
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/mongo-27018.ini 
```

```ini
[program:mongo-27018]
command=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/27018.conf
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
stdout_logfile=/etc/supervisor/supervisor.d/mongo-27018.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

- 加载

```bash
[emon@emon ~]$ sudo supervisorctl update
```

4. 增加第三个节点，arbiter节点

- mongo配置

```bash
[emon@emon ~]$ cp /usr/local/mongodb/conf/27017.conf /usr/local/mongodb/conf/27019.conf
[emon@emon ~]$ vim /usr/local/mongodb/conf/27019.conf 
```

```bash
# 端口，默认27019，MongoDB的默认服务TCP端口
port=27019
# 远程连接要指定ip，不然无法连接；0.0.0.0表示不限制ip访问，并开启对应端口
bind_ip=0.0.0.0
# 日志文件
logpath=/usr/local/mongodb/log/27019.log
# 数据文件存放目录，默认： /data/db/
dbpath=/usr/local/mongodb/data/27019/
# 日志追加
logappend=true
# 启动的进程ID
pidfilepath=/usr/local/mongodb/data/27019/27019.pid
# 如果为true，以守护程序的方式启动，即在后台运行
fork=false
# oplog窗口大小
oplogSize=5120
# 复制集名称
replSet=emon
# 是否认证
auth=false
```

- supervisor配置

```bash
[emon@emon ~]$ sudo cp /etc/supervisor/supervisor.d/mongo-27017.ini /etc/supervisor/supervisor.d/mongo-27019.ini
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/mongo-27019.ini
```

```ini
[program:mongo-27019]
command=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/27019.conf
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
stdout_logfile=/etc/supervisor/supervisor.d/mongo-27019.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

- 加载

```bash
[emon@emon ~]$ sudo supervisorctl update
```

5. 启动并配置复制集

- 通过supervisor重启第一个节点，启动第二和第三个节点。
- 命令配置复制集

```bash
[root@emon ~]# mongo 127.0.0.1:27017/admin
```

```js
// 备注： 0.0.0.0 需要更改为具体ip地址，比如 192.168.5.116
> config={
    _id:"emon",
    members: [
        {_id:0,host:"repo.emon.vip:27017",priority:1000},
        {_id:1,host:"repo.emon.vip:27018"},
        {_id:2,host:"repo.emon.vip:27019",arbiterOnly:true}
    ]
}
> rs.initiate(config)
```

- 其他一些命令：

```js
# 如果碰到副节点执行命令报错：uncaught exception: Error: not master and slaveOk=false
rs.secondaryOk()
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

## 3.1、数据库操作

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

语法格式： 

```js
db.<collection>.drop({writeConcern: <document>})
```

如果成功删除则返回true；否则返回false

```bash
# 删除col集合
> db.col.drop()
```



# 四、数据操纵语言之创建文档（DML）

## 4.1、插入单个文档

语法格式：

```js
db.<collection>.insertOne(
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



## 4.2、插入多个文档

语法格式：

```js
db.<collection>.insertMany(
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

在执行`db.<collection>.insertMany`命令时，默认的`{ordered: true}` 在遇到错误时，操作便会退出，剩余的文档无论正确与否，都不会被写入；如果是 `{ordered: false}` 在遇到错误时，剩余正确的文档也会被写入。



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



## 4.3、插入或者更新文档

描述：当`db.<collection>.save()`命令处理一个新文档时，会调用`db.<collection>.save()`命令。

语法格式：

```js
db.<collection>.save(
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



# 五、数据查询语言（DQL）

语法格式：

`db.<collection>.find(query, projection)`

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

### 文档游标

`db.collection.find()`返回一个文档集合游标，在不迭代游标的情况下，只列出前20个文档。

```js
> var myCursor = db.accounts.find();
> myCursor[1]
{
	"_id" : ObjectId("602d00d3ebecf117915b0974"),
	"name" : "bob",
	"balance" : 50
}
```

游标被遍历完后，或者在10分钟后，游标便会自动关闭。可以使用`noCursorTimeout()`函数来保持游标不关闭。

```js
> var myCursor = db.accounts.find().noCursorTimeout();
> myCursor.close();
```

- 游标函数

| 函数名                         | 描述                                             |
| ------------------------------ | ------------------------------------------------ |
| cursor.hasNext()               | 是否还有元素                                     |
| cursor.next()                  | 下一个元素                                       |
| cursor.forEach(<function>)     | 遍历                                             |
| cursor.limit(<number>)         | 返回游标限制条数的数量，从第一条开始，0表示全部  |
| cursor.skip(<offset>)          | 跳过游标中几条文档，从第一条开始，0表示不跳过    |
| cursor.count(<applySkipLimit>) | applySkipLimit默认false，表示忽略limit和skip效果 |
| cursor.sort(<document>)        | 参数document定义了排序要求，1-正向；-1-逆向      |

- 遍历游标示例

```js
> var myCursor = db.accounts.find({name:"david"});
> while(myCursor.hasNext()) {
	printjson(myCursor.next());
}
```

- 遍历游标示例2

```js
> var myCursor = db.accounts.find({name:"david"});
> myCursor.forEach(printjson)
```

- 获取一条文档

```js
> db.accounts.find({name:"david"}).limit(1)
```

- 跳过一条文档

```js
> db.accounts.find({name:"david"}).skip(1)
```

- 统计数量

```js
> db.accounts.find({name:"david"}).count()
2
> db.accounts.find({name:"david"}).limit(1).count()
2
> db.accounts.find({name:"david"}).skip(1).count()
2
> db.accounts.find({name:"david"}).limit(1).count(true)
1
> db.accounts.find({name:"david"}).skip(1).count(true)
1
```

- 在不提供筛选条件时，`cursor.count()`会从集合的元数据Metadata中取得结果

```js
> db.accounts.find().count()
```

**注意：数据库结构较为复杂时，元数据中的文档数量可能不准确，应尽量避免不带筛选条件的统计，而使用聚合管道来计算文档数量**

- 游标排序

```js
> db.accounts.find().sort({balance:-1, name:1})
```

- 集合函数执行顺序

`cursor.sort()`->`cursor.skip()`->`cursor.limit()`

```js
> db.accounts.find().limit(5).skip(3).sort({balance:-1,name:1})
```

### 文档投影

不适用投影时，`db.collection.find()`返回符合条件的完整文档，而使用投影可以有选择的返回文档中的部分字段。

语法格式：

```js
// db.collection.find(<query>, <projection>)
{field: inclusion}
```

参数说明：

`inclusion`： 1-表示返回字段，0-表示不返回字段。**投影中除了主键之外，不能混用包含和不包含两种条件**

- 仅返回银行账户文档中的用户姓名

```js
> db.accounts.find({}, {name: 1})
```

- 默认都会返回`_id`字段，可以指定不返回

```js
> db.accounts.find({}, {name: 1, _id:0})
```

- 不返回银行账户文档中的用户姓名，也不返回主键

```js
> db.accounts.find({}, {name: 0, _id:0})
```

#### $slice

该操作符可以返回数组字段中的部分元素

- 仅返回数组第一个元素

```js
> db.accounts.find({}, {_id:0, name:1, contact:{$slice:1}})
```

- 仅返回数组的最后一个元素

```js
> db.accounts.find({}, {_id:0, name:1, contact:{$slice:-1}})
```

- 返回数组指定范围的元素

```js
> db.accounts.find({}, {_id:0, name:1, contact:{$slice:[1,2]}})
```

#### $elemMatch和$

该操作符可以返回数组字段中满足筛选条件的第一个元素

```js
> db.accounts.find({}, {
_id:0, name:1, contact:{$elemMatch:{$gt:"Alabama"}}
})

// $操作符，依赖于<query>
> db.accounts.find({contact:{$gt:"Alabama"}}, {_id:0, name:1, "contact.$":1})
```



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

- 也可以使用对应的BSON类型序号作为$type操作符的参数

```js
> db.accounts.find({_id:{$type: 2}})
```



## 5.5、数组操作符

数据准备：

```js
> db.accounts.insert([
    {
        name: "jack",
        balance: 2000,
        contact: ["11111111", "Alabama", "US"]
    },
    {
        name: "karen",
        balance: 2500,
        contact: [["22222222", "33333333"], "Beijing", "China"]
    }
])
```

### $all

语法格式：

```js
{ <field>: { $all: [ <value1> , <value2> ... ] } }
```

匹配数组字段中包含所有查询值的文档

- 查询联系地址位于中国北京的银行账户文档

```js
> db.accounts.find({contact: {$all: ["China", "Beijing"]}})
```

- 查询联系电话包含 222222 和 333333 的银行账户文档

```js
> db.accounts.find({contact: {$all: [["22222222","33333333"]]}})
```

### $elemMatch

语法格式：

```js
{ <field>: { $elemMatch: { <query1>, <query2>, ... } } }
```

匹配数组字段中至少存在一个值满足筛选条件的文档

- 查询联系电话范围在 10000000 至 20000000 之间的银行账户文档

```js
> db.accounts.find({contact:{$elemMatch:{$gt: "10000000", $lt: "20000000"}}})
```

- 混合使用`$all`与`$elemMatch`，查询包含一个在 10000000 至 20000000 之间，和一个在 20000000 至   30000000 之间的联系电话的银行账户文档

```js
> db.accounts.find({
    contact: {$all:[
        {$elemMatch: {$gt: "10000000", $lt: "20000000"}},
        {$elemMatch: {$gt: "20000000", $lt: "30000000"}}
    ]}
})
```

- 一个特殊用法记录

  - 数据准备

  ```js
  > db.crm_cust_track.insert([
      {
          cust_name: "小李",
          track_event_type: 2,
          todo_info: {
              track_channel: 1,
              remind_status: 1,
              todo_user_info: [
                  {
                      user_id: "jack",
                      todo_status: 0
                  },
                  {
                      user_id: "karen",
                      todo_status: 1
                  }
              ]
          }
      },
      {
          cust_name: "小张",
          track_event_type: 2,
          todo_info: {
              track_channel: 1,
              remind_status: 1,
              todo_user_info: [
                  {
                      user_id: "jack",
                      todo_status: 1
                  }
              ]
          }
      }
  ])
  ```

  - 查询待办事项跟踪人是jack且跟踪状态是0的

  ```js
  > db.crm_cust_track.find({
      "todo_info.todo_user_info": {
          $elemMatch: {
              "user_id": "jack",
              "todo_status": 0
          }
      }
  });
  ```

  - 更新某一个数组元素对象的某一个值，注意$[uf]定义了一个变量uf，然后在arrayFilters中使用了

  ```js
  > db.crm_cust_track.update(
  	{
          _id: ObjectId("6040f07c39ace0514f614b09"),
          "todo_info.todo_user_info": {
              $elemMatch: {
                  "user_id": "jack",
                  "todo_status": 0
              }
          }   
      },
      {
          $set: {
              "todo_info.todo_user_info.$[uf].todo_status": 0
          }
      },
      {
      	arrayFilters: [{"uf.user_id": "jack"}], multi:true
      }
  );
  ```

  

  

  

  

  

  

## 5.6、运算操作符（Evaluation Query Operators）

### $regex

语法格式：

```js
{ <field>: { $regex: /pattern/, $options: '<options>' } }
{ <field>: { $regex: 'pattern', $options: '<options>' } }
{ <field>: { $regex: /pattern/<options> } }
// 或者
{ <field>: /pattern/<options> }
```

参数说明：

v8.41`正则表达式库。

`options`：的可能值解释如下：

| Option | Description                   |
| ------ | ----------------------------- |
| i      | 忽略大小写                    |
| m      | 匹多行配                      |
| x      | 忽略空白符                    |
| s      | 允许`.`匹配所有字符，包含`\n` |

- 在和$in 操作符一起使用时，只能使用 `/pattern/<options>` 格式

```js
> db.accounts.find({name: {$in: [/^c/, /^j/]}})
```

- 查询用户姓名包含LIE（不区分大小写）的银行账户文档

```js
> db.accounts.find({name: {$regex: /LIE/, $options: "i"}})
```



# 六、数据操纵语言之更新文档（DML）

语法格式：

```js
db.<collection>.update(
   <query>,
   <update>,
   {
     upsert: <boolean>,
     multi: <boolean>,
     writeConcern: <document>,
     collation: <document>,
     arrayFilters: [ <filterdocument1>, ... ],
     hint:  <document|string>        // Available starting in MongoDB 4.2
   }
)
```

参数说明：

| 参数    | 类型                 | 描述                                    |
| ------- | -------------------- | --------------------------------------- |
| query   | document             | 可选，筛选条件，默认:{}                 |
| update  | document or pipeline | 1、更新操作符；2、更新文档；3、聚合管道 |
| options | document             | 可选，更新操作的控制项                  |

## 6.1、常规更新

- 更新整篇文档（在`<update>`文档不包含任何更新操作符的情况下，称为：`replacement-style update`）

  - `<update>`会替换原文档；如果字段在原文档已存在，则覆盖；如果不存在，则添加；如果原文档比指定文档多，则去掉。
  - 该方法默认仅更新第一个文档；如果指定了options选项{multi:true}会报错

  >multi update is not supported for replacement-style update

  - 文档主键_id是不可以更改的，如果指定的文档包含_id，值要和被更新文档主键值一样

```js
> db.accounts.update({_id:"account1"}, {name:"alice",balance:123})
```

- 更新特定字段（在`<update>`文档包含更新操作符）



## 6.2、文档更新操作符

### $set 更新或新增字段

语法格式：

```js
{ $set: { <field1>: <value1>, ... } }
```

- 更新jack的银行账户和开户信息

```js
> db.accounts.update(
	{name: "jack"},
    {
        $set: {
            balance: 3000,
            info: {
                dateOpened: new Date("2021-02-26T23:10:30Z"),
                branch: "branch1"
            }
        }
    }
)
```

- 更新或新增内嵌文档的字段，更新jack的银行账户的开户时间

```js
> db.accounts.update(
	{name: "jack"},
    {
        $set: {
            "info.dateOpened": new Date("2021-02-26T23:15:36Z")
        }
    }
)
```

- 更新或新增数组内的字段，更新jack的联系电话

```js
> db.accounts.update(
	{name: "jack"},
    {
        $set: {
            "contact.0": "66666666"
        }
    }
)
```

- 新增数组内的字段，添加jack的联系方式

```js
> db.accounts.update(
	{name: "jack"},
    {
        $set: {
            "contact.3": "new contact"
        }
    }
)
```

- 新增数组内的字段，**跳跃式**添加加jack的联系方式

**注意：如果向现有数组字段范围以外位置处添加新值，数组字段的长度会扩大，未被赋值的数组成员将被设置为null。**

```js
> db.accounts.find({name:"jack"}).pretty()
{
	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17a"),
	"name" : "jack",
	"balance" : 3000,
	"contact" : [
		"66666666",
		"Alabama",
		"US",
		"new contact"
	],
	"info" : {
		"dateOpened" : ISODate("2021-02-26T23:15:36Z"),
		"branch" : "branch1"
	}
}
> db.accounts.update(
	{name: "jack"},
    {
        $set: {
            "contact.5": "another new contact"
        }
    }
)
> db.accounts.find({name:"jack"}, {contact:1}).pretty()
{
	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17a"),
	"contact" : [
		"66666666",
		"Alabama",
		"US",
		"new contact",
		null,
		"another new contact"
	]
}
```



### $unset 删除字段

语法格式：

```js
{ $unset: { <field1>: "", ... }}
```

**说明**： `<field1>: ""`的值`""`对操作结果不影响，只是为了满足json格式。

- 删除jack的银行账户余额和开户地点

```js
> db.accounts.update(
	{name: "jack"},
    {
        $unset: {
            balance: "",
            "info.branch": ""
        }
    }
)
```

- 删除jack的银行开户时间

```js
> db.accounts.find({name:"jack"}).pretty()
{
	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17a"),
	"name" : "jack",
	"contact" : [
		"66666666",
		"Alabama",
		"US",
		"new contact",
		null,
		"new contact"
	],
	"info" : {
		"dateOpened" : ISODate("2021-02-26T23:15:36Z")
	}
}
> db.accounts.update(
	{name: "jack"},
    {
        $unset: {
            "info.dateOpened": "this can be any value"
        }
    }
)
> db.accounts.find({name:"jack"}).pretty()
{
	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17a"),
	"name" : "jack",
	"contact" : [
		"66666666",
		"Alabama",
		"US",
		"new contact",
		null,
		"new contact"
	],
	"info" : {
		
	}
}
> db.accounts.find({name:"jack"}).pretty()
{
	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17a"),
	"name" : "jack",
	"contact" : [
		"66666666",
		"Alabama",
		"US",
		"new contact",
		null,
		"new contact"
	],
	"info" : {
		
	}
}
```

**注意：删除了info字段的最后一个子字段，info字段还在。**

- 如果$unset命令中的字段根本不存在，那么文档内容将保持不变

```js
> db.accounts.update(
	{name: "jack"},
    {
        $unset: {
            notExist: ""
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

- 删除数组内的字段，删除jack的联系电话

```js
> db.accounts.update(
	{name: "jack"},
    {
        $unset: {
            "contact.0": ""
        }
    }
)
```

**注意：删除数组内的字段后，只是把该字段置为null，并不会改变数组长度。**



### $rename 重命名字段

语法格式：

```js
{ $rename: { <field1>: <newName1>, <field2>: <newName2>, ... } }
```

**注意：$rename无法对数组文档进行操作**

- 如果$rename命令要重命名的字段并不存在，那么文档内容不会被改变

```js
> db.accounts.update(
	{name: "jack"},
    {
        $rename: {
            "notExist": "name"
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

- 如果新的字段名已经存在，那么原有的这个字段会被覆盖

```js
> db.accounts.update(
	{name: "jack"},
    {
        $rename: {
            "name": "contact"
        }
    }
)
```

**说明**:当$rename命令中的新字段存在的时候，$rename命令会先$unset旧字段，然后再$set新字段。

- 重命名内嵌文档的字段，更新账户余额和开户地点字段在文档中的位置

  - 数据准备：更新karen的银行账户的开户时间和联系方式

  ```js
  > db.accounts.find({name:"karen"}).pretty()
  {
  	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17b"),
  	"name" : "karen",
  	"balance" : 2500,
  	"contact" : [
  		[
  			"22222222",
  			"33333333"
  		],
  		"Beijing",
  		"China"
  	]
  }
  > db.accounts.update(
  	{name: "karen"},
      {
          $set: {
              info: {
                  dateOpened: new Date("2021-02-27T08:51:55Z"),
                  branch: "branch1"
              },
              "contact.3": {
                  primaryEmail: "xxx@gmail.com",
                  secondaryEmail: "yyy@gmail.com"
              }
          }
      }
  )
  > db.accounts.find({name:"karen"}).pretty()
  {
  	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17b"),
  	"name" : "karen",
  	"balance" : 2500,
  	"contact" : [
  		[
  			"22222222",
  			"33333333"
  		],
  		"Beijing",
  		"China",
  		{
  			"primaryEmail" : "xxx@gmail.com",
  			"secondaryEmail" : "yyy@gmail.com"
  		}
  	],
  	"info" : {
  		"dateOpened" : ISODate("2021-02-27T08:51:55Z"),
  		"branch" : "branch1"
      }
  }
  ```

  - 更新账户余额和开户地点字段在文档中的位置

  ```js
  > db.accounts.update(
  	{name: "karen"},
      {
          $rename: {
              "info.branch": "branch",
              "balance": "info.balance"
          }
      }
  )
  > db.accounts.find({name:"karen"}).pretty()
  {
  	"_id" : ObjectId("602e3b5f4da3eca7f2dcc17b"),
  	"name" : "karen",
  	"contact" : [
  		[
  			"22222222",
  			"33333333"
  		],
  		"Beijing",
  		"China",
  		{
  			"primaryEmail" : "xxx@gmail.com",
  			"secondaryEmail" : "yyy@gmail.com"
  		}
  	],
  	"info" : {
  		"dateOpened" : ISODate("2021-02-27T08:51:55Z"),
  		"balance" : 2500
  	},
  	"branch" : "branch1"
  }
  ```

  

### $inc 加减字段值

语法格式：

```js
{ $inc: <field1>: <amount1>, ... } }
```

**注意：只能使用在数字字段上**

- 更新david的账户余额

```js
> db.accounts.update(
    {name: "david"},
    {
        $inc: {
            balance: -0.5
        }
    }
)
```

- 如果被更新的字段不存在

```js
> db.accounts.find({name:"david"}).pretty()
{
	"_id" : ObjectId("602d1d49ebecf117915b0979"),
	"name" : "david",
	"balance" : 99.75
}
> db.accounts.update(
    {name: "david"},
    {
        $inc: {
            notYetExist: 10
        }
    }
)
> db.accounts.find({name:"david"}).pretty()
{
	"_id" : ObjectId("602d1d49ebecf117915b0979"),
	"name" : "david",
	"balance" : 99.75,
	"notYetExist" : 10
}
```

**注意：如果更新的字段不存在，会添加新字段，且值是更新的值**



### $mul 相乘字段值

语法格式：

```js
{ $mul: <field1>: <number1>, ... } }
```

**注意：只能使用在数字字段上**

```js
> db.accounts.update(
    {name: "david"},
    {
        $mul: {
            balance: 0.5
        }
    }
)
```

- 如果被更新的字段不存在

```js
> db.accounts.find({name:"david"}).pretty()
{
	"_id" : ObjectId("602d1d49ebecf117915b0979"),
	"name" : "david",
	"balance" : 99.75,
	"notYetExist" : 10
}
> db.accounts.update(
    {name: "david"},
    {
        $mul: {
            notYetExistEither: 20
        }
    }
)
> db.accounts.find({name:"david"}).pretty()
{
	"_id" : ObjectId("602d1d49ebecf117915b0979"),
	"name" : "david",
	"balance" : 99.75,
	"notYetExist" : 10,
	"notYetExistEither" : 0
}
```

**注意：如果更新的字段不存在，会添加新字段，且值是0**



### $min 比较减小字段值

语法格式：

```js
{ $min: { <field1>: <value1>, ... } }
```

- 更新karen的账户余额，比较之后更新较小的那一个为新值

```js
> db.accounts.find({name: "karen"}, {name: 1, info: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"info" : {
		"dateOpened" : ISODate("2021-02-27T08:51:55Z"),
		"balance" : 2500
	}
}
> db.accounts.update(
	{name: "karen"},
    {
        $min: {
            "info.balance": 5000
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

- 更新karen的开户时间

```js
> db.accounts.update(
	{name: "karen"},
    {
        $min: {
            "info.dateOpened": ISODate("2021-02-27T11:00:00Z")
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

- 如果被更新的字段不存在

```js
> db.accounts.update(
	{name: "karen"},
    {
        $min: {
            notYetExist: 10
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```

**注意：如果更新的字段不存在，会添加新字段，且值是更新的值**

- 如果被更新的字段类型和更新值类型不一致，则按照BSON数据类型排序后更新，对$max效果一样

```js
> db.accounts.update(
	{name: "karen"},
    {
        $min: {
            "info.balance": null
        }
    }
)
```

**特殊说明**：

>$min和$max命令会按照BSON数据类型排序规则进行比较，
>
>最小： Null
>
>​			Numbers(ints, longs, doubles, decimals)
>
>​			Symbol, String
>
>​			Object
>
>​			Array
>
>​			BigData
>
>​			ObjectId
>
>​			Boolean
>
>​			Date
>
>​			Timestamp
>
>最大：Regular Expression



### $max 比较增大字段值

语法格式：

```js
{ $max: { <field1>: <value1>, ... } }
```

- 更新karen的账户余额，比较之后更新较大的那一个为新值

```js
> db.accounts.find({name: "karen"}, {name: 1, info: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"info" : {
		"dateOpened" : ISODate("2021-02-27T08:51:55Z"),
		"balance" : 2500
	}
}
> db.accounts.update(
	{name: "karen"},
    {
        $max: {
            "info.balance": 5000
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```

- 更新karen的开户时间

```js
> db.accounts.update(
	{name: "karen"},
    {
        $max: {
            "info.dateOpened": ISODate("2021-02-27T11:00:00Z")
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```

- 如果被更新的字段不存在

```js
> db.accounts.update(
	{name: "karen"},
    {
        $max: {
            notYetExistEither: 20
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```

**注意：如果更新的字段不存在，会添加新字段，且值是更新的值**



## 6.3、数组更新操作符

### $addToSet 向数组中添加元素

语法格式：

```js
{ $addToSet: { <field1>: <value1>, ... } }
```

- 向karen的账户文档中添加联系方式

```js
> db.accounts.update(
	{name: "karen"},
    {
        $addToSet: {
            contact: "China"
        }
    }
)
```

**注意：如果要插入的值已经存在数组字段中，则$addToSet不会再添加重复值**

- 向karen的账户文档中添加新的联系方式

```js
> db.accounts.find({name: "karen"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		}
	]
}
> db.accounts.update(
	{name: "karen"},
    {
        $addToSet: {
            contact: {
                "secondaryEmail": "yyy@gmail.com",
                "primaryEmail": "xxx@gmail.com"
            }
        }
    }
)
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
> db.accounts.find({name: "karen"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		{
			"secondaryEmail" : "yyy@gmail.com",
			"primaryEmail" : "xxx@gmail.com"
		}
	]
}
```

**注意：使用$addToSet插入数组和文档时，插入值中的字段顺序也和已有值重复的时候，才算作重复值忽略，否则插入成功**

- 向karen的账户文档中添加多个联系方式

```js
> db.accounts.update(
	{name: "karen"},
    {
        $addToSet: {
            contact: ["contact1", "contact2"]
        }
    }
)
```

**总结**：这种会将数组插入被更新的数组字段中，成为内嵌数组。

- 向karen的账户文档中，插入非内嵌的多个联系方式

```js
> db.accounts.update(
	{name: "karen"},
    {
        $addToSet: {
            contact: {
                $each: ["contact1", "contact2"]
            }
        }
    }
)
```



### $pop 从数组中删除第一个或最后一个元素

语法格式：

```js
{ $pop: { <field>: <-1 | 1>, ... } }
```

- 从karen的账户文档中删除最后一个联系方式

```js
> db.accounts.update(
	{name: "karen"},
    {
        $pop: {
            contact: 1
        }
    }
)
```

- 从karen的账户文档中删除第一个联系方式

```js
> db.accounts.update(
	{name: "karen"},
    {
        $pop: {
            contact: -1
        }
    }
)
```

- 从karen的账户文档中删除第六个联系方式的第一个元素

```js
> db.accounts.find({name: "karen"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		{
			"secondaryEmail" : "yyy@gmail.com",
			"primaryEmail" : "xxx@gmail.com"
		},
		[
			"contact1",
			"contact2"
		],
		"contact1"
	]
}
> db.accounts.update(
	{name: "karen"},
    {
        $pop: {
            "contact.5": -1
        }
    }
)
> db.accounts.update(
	{name: "karen"},
    {
        $pop: {
            "contact.5": -1
        }
    }
)
> db.accounts.find({name: "karen"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "karen",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		{
			"secondaryEmail" : "yyy@gmail.com",
			"primaryEmail" : "xxx@gmail.com"
		},
		[ ],
		"contact1"
	]
}
```

**总结：使用$pop删除数组元素，哪怕数组元素的最后一个元素都被删除了，也会保留数组结构。**



### $pull 从数组字段中删除特定元素

语法格式：

```js
{ $pull: { <field1>: <value|condition>, ... } }
```

数据准备：复制karen的账户文档，并修改用户姓名为lawrence

```js
> db.accounts.find({name:"karen"}, {_id: 0}).forEach(function(doc){
    var newDoc = doc;
    newDoc.name = "lawrence";
    db.accounts.insert(newDoc);
})
```

- 从karen的联系方式中删去包含'hi'字母的元素

```js
> db.accounts.update(
	{name: "karen"},
    {
        $pull: {
            contact: {
                $elemMatch: {$regex: /hi/}
            }
        }
    }
)
# 结果：没有更新到任何数据
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

**总结**： $pull操作符本身是只能作用在数组元素上的，我们不需要额外使用$elemMatch操作符。

```js
> db.accounts.update(
	{name: "karen"},
    {
        $pull: {
            contact: {
				$regex: /hi/
            }
        }
    }
)
```

- 如果数组元素本身就是一个内嵌数组，我们也可以使用$elemMatch来对这些内嵌数组进行筛选

```js
> db.accounts.update(
    {name: "karen"},
    {
        $pull: {
            contact: {
                $elemMatch: {
                    $eq: "22222222"
                }
            }
        }
    }
)
```



### $pullAll 和 $pull 对比

语法格式：

```js
{ $pullAll: { <field1>: [ <value1>, <value2> ...], ... } }
```

**注意：使用$pullAll时，如果要删除的数组元素本身也是一个数组，则该数组元素的值和排列顺序都必须和被删除的数组元素完全一样。**

**注意：使用$pullAll时，如果要删除的数组元素本身也是一个文档，则该数组元素的值和排列顺序都必须和被删除的数组元素完全一样。**

相当于：

```js
{ $pull: { <field1>: { $in: [ <value1>, <value2> ...], ... }}}
```

**注意：使用$pull时，如果要删除的数组元素本身也是一个数组，则该数组元素的值和排列顺序都必须和被删除的数组元素完全一样。**

**注意：使用$pull时，如果要删除的数组元素本身也是一个文档，则该数组元素的值不需要完全匹配，排列顺序也不需要完全匹配。**

- 删除本身也是数组的数组元素

```js
> db.accounts.find({name: "lawrence"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "lawrence",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		{
			"secondaryEmail" : "yyy@gmail.com",
			"primaryEmail" : "xxx@gmail.com"
		},
		[ ],
		"contact1"
	]
}
> db.accounts.update(
	{name: "lawrence"},
    {
        $pullAll: {
            contact: [
                ["33333333", "22222222"]
            ]
        }
    }
)
# 没有删除任何元素
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
> db.accounts.update(
	{name: "lawrence"},
    {
        $pull: {
            contact: [
                "33333333", "22222222"
            ]
        }
    }
)
# 没有删除任何元素
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
```

- 删除本身是文档的数组元素

```js
> db.accounts.find({name: "lawrence"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "lawrence",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		{
			"secondaryEmail" : "yyy@gmail.com",
			"primaryEmail" : "xxx@gmail.com"
		},
		[ ],
		"contact1"
	]
}
> db.accounts.update(
	{name: "lawrence"},
    {
        $pullAll: {
            contact: [
                {"primaryEmail": "xxx@gmail.com"}
            ]
        }
    }
)
# 没有删除任何元素
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 0 })
> db.accounts.update(
	{name: "lawrence"},
    {
        $pullAll: {
            contact: [
                {secondaryEmail : "yyy@gmail.com", "primaryEmail": "xxx@gmail.com"}
            ]
        }
    }
)
# 删除成功顺序满足的数组元素
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```

```js
> db.accounts.find({name: "lawrence"}, {name: 1, contact: 1, _id: 0}).pretty()
{
	"name" : "lawrence",
	"contact" : [
		[
			"22222222",
			"33333333"
		],
		"Beijing",
		"China",
		{
			"primaryEmail" : "xxx@gmail.com",
			"secondaryEmail" : "yyy@gmail.com"
		},
		[ ],
		"contact1"
	]
}
> db.accounts.update(
	{name: "lawrence"},
    {
        $pull: {
            contact: {secondaryEmail : "yyy@gmail.com"}
        }
    }
)
# 数组元素内容部分匹配，成功删除
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

# 恢复被删掉的数组元素
> db.accounts.update(
	{name: "lawrence"},
    {
        $addToSet: {
            contact: {
                primaryEmail: "xxx@gmail.com",
                secondaryEmail: "yyy@gmail.com"
            }
        }
    }
)

> db.accounts.update(
	{name: "lawrence"},
    {
        $pull: {
            contact: {secondaryEmail : "yyy@gmail.com", "primaryEmail": "xxx@gmail.com"}
        }
    }
)
# 数组元素排列顺序部分匹配，成功删除
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
```



### $push 向数组字段中添加元素

语法格式：

```js
{ $push: { <field1>: <value1>, ... } }
```

和$addToSet命令相似，但$push命令的功能更加强大。

- 和$addToSet相似的地方

```js
# 把整个文档作为数组元素
> db.accounts.update(
	{name: "lawrence"},
    {
        $push: {newArray: "new element"}
    }
)
# 把整个数组拉平后作为数组元素
> db.accounts.update(
	{name: "lawrence"},
    {
        $push: {
            newArray: { $each: [2,3,4]}
        }
    }
)
```

- 和$addToSet不同的地方，`$push`和`$each`操作符还可以和更多的操作符搭配使用，实现比$addToSet更复杂的操作
  - 使用`$position`操作符将元素插入到数组的指定位置

  ```js
  > db.accounts.find({name: "lawrence"}, {name: 1, newArray: 1, _id: 0}).pretty()
  { "name" : "lawrence", "newArray" : [ "new element", 2, 3, 4 ] }
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: ["pos1", "pos2"],
                  $position: 0
              }
          }
      }
  )
  # 插入成功
  WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })
  > db.accounts.find({name: "lawrence"}, {name: 1, newArray: 1, _id: 0}).pretty()
  {
  	"name" : "lawrence",
  	"newArray" : [
  		"pos1",
  		"pos2",
  		"new element",
  		2,
  		3,
  		4
  	]
  }
  # $position的值-1表示插入最后一个元素之前，-2表示最后2个元素之前，以此类推。
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: ["pos3", "pos4"],
                  $position: -1
              }
          }
      }
  )
  ```

  - 使用$sort对数组进行排序；1-正序；-1-倒序；

  ```js
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: ["sort1"],
                  $sort: 1
              }
          }
      }
  )
  # 插入内嵌文档并排序
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: [{key: "sort", value: 100}, {key:"sort", value: 200}],
                  $sort: {value: -1}
              }
          }
      }
  ]
  # 如果不想插入任何元素，只是想对文档中的数组字段进行排序
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: [],
                  $sort: -1
              }
          }
      }
  )
  ```

  - 使用$slice来截取部分数组

  ```js
  # $slice: -8 表示倒数8个元素作为保留
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: ["slice1"],
                  $slice: -8
              }
          }
      }
  )
  # 如果不想插入元素，只想截取文档中的数组字段
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: [],
                  $slice: 6
              }
          }
      }
  )
  ```

  - `$position`,`$sort`,`$slice`可以一起使用

  这三个操作符的执行顺序是：`$position` -> `$sort` -> `$slice`

  写在命令中的操作符顺序并不重要，并不会影响命令的执行顺序

  ```js
  > db.accounts.update(
  	{name: "lawrence"},
      {
          $push: {
              newArray: {
                  $each: ["push1", "push2"],
                  $position: 2,
                  $sort: -1,
                  $slice: 5
              }
          }
      }
  )
  ```

### 更新数组中特定元素

语法格式：

```js
db.collection.update(
    { <array>: <query selector> },
    { <update operator>: { "<array>.$": value } }
)
```

参数说明：

$是数组中第一个符合筛选条件的数组元素的占位符，搭配更新操作符使用，可以对满足筛选条件的数组元素进行更新。

```js
> db.accounts.update(
	{name: "lawrence", newArray: "pos2"},
    {
        $set: {
            "newArray.$": "updated"
        }
    }
)
```

### 更新数组中的所有元素

语法格式：

```js
{ <update operator>: { "<array>.$[]": value } }
```

参数说明：

$[]指代数组字段中的所有元素，搭配更新操作符使用，可以对数组中的所有元素进行更新。

```js
> db.accounts.update(
	{name: "lawrence"},
	{
        $set: {
            "contact.0.$[]": "88888888"
        }
    }
)
```

## 6.4、更新文档选项

### 6.4.1、更新多个文档选项

语法格式：

```js
{ multi: <boolean> }
```

参数说明：

是否更新多个文档，默认： false

```js
# 默认只更新一个文档
> db.accounts.update(
	{},
    {
        $set: {
            currency: "USD"
        }
    }
)
# 指定更新多个文档
> db.accounts.update(
	{},
    {
        $set: {
            currency: "USD"
        }
    },
    {
        multi: true
    }
)
```

**注意：MongoDB只能保证`单个`文档操作的原子性，不能保证`多个`文档操作的原子性**

更新多个文档的操作虽然在单一线程中执行，但是线程在执行过程中可能被挂起，以便其他线程也有机会对数据进行操作。

如果需要保证多个文档操作时的原子性，就需要使用MongoDB4.0版本引入的事务功能进行操作。

### 6.4.2、更新或者创建文档

在默认情况下，如果update命令中的筛选条件没有匹配任何文档，则不会进行任何操作。

将upsert的选项设置为true，如果update命令中的筛选条件没有匹配任何文档，则会创建新文档。

```js
# 对于匹配不到的文档，则新增；如果筛选条件比较确定，则条件也会作为字段插入文档
> db.accounts.update(
	{name: "maggie"},
    {
        $set: { balance: 700 }
    },
    { upsert: true }
)
> db.accounts.find({name: "maggie"})
{ "_id" : ObjectId("603a5ee25bf5ade50b06a390"), "name" : "maggie", "balance" : 700 }

# 如果无法从筛选条件中推断出确定的字段值，则新创建的文档不包含筛选条件涉及的字段
> db.accounts.update(
	{balance: {$gt: 20000}},
    {
        $set: {name: "nick"}
    },
    {upsert: true}
)
> db.accounts.find({name: "nick"})
{ "_id" : ObjectId("603a60065bf5ade50b06a3dc"), "name" : "nick" }
```



## 6.5、另一个更新文档的命令

语法格式：

```js
db.<collection>.save(<document>)
```

- 更新已存在文档或者创建新文档

```js
> db.accounts.find({_id: "account1"})
{ "_id" : "account1", "name" : "alice", "balance" : 123, "currency" : "USD" }

>  db.accounts.save({_id: "account1", name: "alice", balance: 100})
WriteResult({ "nMatched" : 1, "nUpserted" : 0, "nModified" : 1 })

> db.accounts.find({_id: "account1"})
{ "_id" : "account1", "name" : "alice", "balance" : 100 }
```



# 七、数据操纵语言之删除文档（DML）

语法格式：

```js
db.collection.remove(
   <query>,
   <justOne>
)
# 和
db.collection.remove(
   <query>,
   {
     justOne: <boolean>,
     writeConcern: <document>,
     collation: <document>
   }
)
```

| 参数    | 类型     | 描述                                |
| ------- | -------- | ----------------------------------- |
| query   | document | 可选，筛选条件，默认:{}             |
| justOne | boolean  | 可选，默认false；是否仅删除一个文档 |
| options | document | 可选，删除操作的控制项              |

- 删除文档

```js
# 查看银行账户文档
> db.accounts.find({}, {
    name: 1, balance: 1, _id:0
}).sort({balance: 1})
# 删除余额为50的银行账户文档
> db.accounts.remove({balance: 50})
```

- 删除余额为50的银行账户文档

```js
> db.accounts.remove({balance: 50})
```

**注意：在默认情况下，remove命令会删除所有符合筛选条件的文档。如果只想删除满足筛选条件的第一篇文档，可以通过 justOne 选项**

- 删除第一篇余额小于100的银行账户文档

```js
> db.accounts.remove(
    { balance: {$lt: 100} },
    { justOne: true }
)
```

- 删除集合中所有文档

```js
> db.accounts.remove({})
```

- 删除整个集合

```js
> db.accounts.drop()
```

**总结**：如果集合中的文档数量很多，使用remove命令删除所有文档的效率不高；这种情况下，更加有效率的方法，是使用drop命令删除集合，然后再创建空集合并创建索引。



# 八、聚合操作

语法格式：

```js
db.<collection>.aggregate(<pipeline>, <options>)
```

| 参数    | 类型     | 描述                                       |
| ------- | -------- | ------------------------------------------ |
| pipline | array    | 定义了操作中使用的聚合管道阶段和聚合操作符 |
| options | document | 声明了一些聚合操作的控制项                 |

## 8.1、聚合表达式

### 字段路径表达式

| 表达式                 | 含义                           |
| ---------------------- | ------------------------------ |
| `$<field>`             | 使用$指定字段路径              |
| `$<field>.<sub-field>` | 使用$和.来指定内嵌文档字段路径 |

- 示例

```js
$name
$info.dateOpened
```

### 系统变量表达式

| 表达式       | 含义                 |
| ------------ | -------------------- |
| $$<variable> | 使用$$来指示系统变量 |

- 示例

```js
$$CURRENT - 指示管道中当前操作的文档
$$CURRENT.<field>和$<field>是等效的
```

### 常量表达式

| 表达式            | 含义            |
| ----------------- | --------------- |
| $literal: <value> | 指示常量<value> |

- 示例

```js
$literal: "$name" - 指示常量字符串"$name"，这里的$被当做常量处理，而不是字段路径表达式
```



## 8.2、聚合管道阶段

语法格式：

```js
{ <operator>: [<argument1>, <argument2> ... ] }
{ <operator>: <argument> }
```

| 聚合管道阶段 | 作用                     |
| ------------ | ------------------------ |
| $project     | 对输入文档进行再次投影   |
| $match       | 对输入文档进行筛选       |
| $limit       | 筛选出管道内前N篇文档    |
| $skip        | 跳过管道内前N篇文档      |
| $unwind      | 展开输入文档中的数组字段 |
| $sort        | 对输入文档进行排序       |
| $lookup      | 对输入文档进行查询操作   |
| $group       | 对输入文档进行分组       |
| $out         | 将管道中的文档输出       |

### $project

数据准备：

```js
> db.accounts.insertMany([
    {
        name: {firstName: "alice", lastName: "wong"},
        balance: 50
    },
    {
        name: {firstName: "bob", lastName: "yang"},
        balance: 20
    }
])
```

- 对账户文档进行重新投影

```js
> db.accounts.aggregate([
    {
        $project: {
            _id: 0,
            balance: 1,
            clientName: "$name.firstName",
            nameArray: ["$name.firstName", "$name.middleName", "$name.lastName"]
        }
    }
])
```

### $match

- 对银行账户文档进行筛选

```js
> db.accounts.aggregate([
    {
        $match: {
            "name.firstName": "alice"
        }
    }
])
```

- 稍微复杂点的筛选

```js
> db.accounts.aggregate([
    {
        $match: {
            $or: [
                {balance: {$gt: 40, $lt: 80}},
                {"name.lastName": "yang"}
            ]
        }
    }
])
```

- 将筛选和投影结合

```js
> db.accounts.aggregate([
    {
        $match: {
            $or: [
                {balance: {$gt: 40, $lt: 80}},
                {"name.lastName": "yaang"}
            ]
        }
    },
    {
        $project: {
            _id: 0
        }
    }
])
```

**总结**：应该尽量在聚合管道的开始阶段使用$match，减少后续阶段处理的文档数量，优化聚合操作的性能。

### $limit和$skip

- 筛选第一篇银行账户文档

```js
> db.accounts.aggregate([
    {
        $limit: 1
    }
])
```

- 跳过第一篇银行账户文档

```js
> db.accounts.aggregate([
    {
        $skip: 1
    }
])
```

### $unwind

数据准备：向现有的银行账户文档中加入数组字段

```js
> db.accounts.update(
	{"name.firstName": "alice"},
    {
        $set: {
            currency: ["CNY", "USD"]
        }
    }
)
> db.accounts.update(
	{"name.firstName": "bob"},
    {
        $set: {
            currency: "GBP"
        }
    }
)
```

- 将文档中的货币种类数组展开

```js
> db.accounts.aggregate([
    {
        $unwind: {
            path: "$currency"
        }
    }
])
```

- 展开数组时添加元素位置

```js
> db.accounts.aggregate([
    {
        $unwind: {
            path: "$currency",
            includeArrayIndex: "ccyIndex"
        }
    }
])
```

- 再添加几篇文档

```js
> db.accounts.insertMany([
    {
        name: {firstName: "charlie", lastName: "gordon"},
        balance: 100
    },
    {
        name: {firstName: "david", lastName: "wu"},
        balance: 200,
        currency: []
    },
    {
        name: {firstName: "eddie", lastName: "kim"},
        balance: 100,
        currency: null
    }
])
```

- 添加几篇文档后，将文档中的货币种类数组展开

```js
> db.accounts.aggregate([
    {
        $unwind: {
            path: "$currency",
            preserveNullAndEmptyArrays: true
        }
    }
])
```

**注意：preserveNullAndEmptyArrays默认false，设置true才可以保留空数组的文档数据**

### $sort

- 对银行账户文档进行排序

```js
> db.accounts.aggregate([
    {
        $sort: {
            balance: 1,
            "name.lastName": -1
        }
    }
])
```

### $lookup

语法格式：

```js
# 简单条件
$lookup: {
    from: <collection to join>,
    localField: <field from the input documents>,
    foreignField: <field from the documents of the "from" collection>,
    as: <output array field>
}
# 复杂条件
$lookup: {
    from: <collection to join>,
    let: { <var_1>: <expression>, ..., <var_n>: <expression> },
	pipline: [ <pipeline to execute on the collection to join> ],
    as: <output array field>
}
```

参数说明：

`from`: 同一个数据库中的另一个查询集合

`localField`: 管道文档中用来进行查询的字段

`foreignField`: 查询集合中的查询字段

`as`: 写入管道文档中的查询结果数组字段

`let`:  对查询集合中的文档使用聚合阶段进行处理时，如果需要参考管道文档中的字段，则必须使用let参数对字段进行声明。

`pipeline`: 对查询集合中的文档使用聚合阶段进行处理。

数据准备：增加一个集合用来存储外汇数据

```js
> db.forex.insertMany([
    {ccy: "USD", rate: 6.91, date: new Date("2018-12-21")},
    {ccy: "GBP", rate: 8.72, date: new Date("2018-08-21")},
    {ccy: "CNY", rate: 1.0, date: new Date("2018-12-21")}
])
```

- 将查询到的外汇汇率写入银行账户文档

```js
> db.accounts.aggregate([
    {
		$lookup: {
            from: "forex", 
            localField: "currency", 
            foreignField: "ccy",
            as: "forexData"
        }
    }
])
```

- 如果localField是一个数组字段，需要按数组元素分开多个结果

```js
> db.accounts.aggregate([
    {
        $unwind: {
            path: "$currency"
        }
    },
    {
        $lookup: {
            from: "forex",
            localField: "currency",
            foreignField: "ccy",
            as: "forexData"
        }
    }
])
```

- 将特定日期外汇汇率写入银行账户文档

```js
> db.accounts.aggregate([
    {
        $lookup: {
            from: "forex",
            pipeline: [
                {
                    $match: {
                        date: new Date("2018-12-21")
                    }
                }
            ],
            as: "forexData"
        }
    }
])
```

- 将特定日期外汇汇率写入余额大于100的银行账户文档

```js
> db.accounts.aggregate([
    {
        $lookup: {
            from: "forex",
            let: { bal: "$balance"},
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $and: [
                                { $eq: ["$date", new Date("2018-12-21")]},
                                { $gt: ["$$bal", 100]}
                            ]
                        }
                    }
                }
            ],
            as: "forexData"
        }
    }
])
```

### $group

语法格式：

```js
$group: {
    _id: <expression>,
    <field1>: { <accumulator1>: <expression1> },
    ...
}
```

`_id`: 定义分组规则

`<field1>`:  可以使用聚合操作符来定义新字段

数据准备：增加一个集合用来存储股票交易记录

```js
> db.transactions.insertMany([
    {
        symbol: "600519",
        qty: 100,
        price: 567.4,
        currency: "CNY"
    },
    {
        symbol: "AMZN",
        qty: 1,
        price: 1377.5,
        currency: "USD"
    },
    {
        symbol: "AAPL",
        qty: 2,
        price: 150.7,
        currency: "USD"
    }
])
```

- 按照交易货币来分组交易记录

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$currency"
        }
    }
])
```

**总结：**在不适用聚合操作符的情况下，$group可以返回管道文档中某个字段的所有不重复的值。

- 适用聚合操作符计算分组聚合值

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$currency",
            totalQty: {$sum: "$qty"},
            totalNational: {$sum: {$multiply:["$price", "$qty"]}},
            avgPrice: {$avg: "$price"},
            count: {$sum: 1},
            maxNational: {$max: {$multiply: ["$price", "$qty"]}},
            minNational: {$min: {$multiply: ["$price", "$qty"]}}
        }
    }
])
```

- 适用聚合操作符针对所有文档统计，并不分组

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: null,
            totalQty: {$sum: "$qty"},
            totalNational: {$sum: {$multiply:["$price", "$qty"]}},
            avgPrice: {$avg: "$price"},
            count: {$sum: 1},
            maxNational: {$max: {$multiply: ["$price", "$qty"]}},
            minNational: {$min: {$multiply: ["$price", "$qty"]}}
        }
    }
])
```

- 使用聚合操作符创建数组字段

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$currency",
            symbols: {$push: "$symbol"}
        }
    }
])
```

### $out 

- 将聚合管道中的文档写入一个新集合

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$currency",
            symbols: {$push: "$symbol"}
        }
    },
    {
		$out: "output"
    }
])
```

- 将聚合管道中的文档写入一个已经存在的集合

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$symbol",
            totalNotional: {$sum: {$multiply: ["$price", "$qty"]}}
        }
    },
    {
        $out: "output"
    }
])
```

**总结**：会覆盖更新。

## 8.3、聚合选项

### allowDiskUse:` <boolean>`

每一个聚合管道阶段使用的内存不能超过100MB，如果数据量较大，为了防止聚合管道阶段超出内存上限并抛出错误，可以启用allowDistKsu选项来使用硬盘。

allowDiskUse启用后，聚合阶段可以在内存容量不足时，将操作数据写入临时文件中；临时文件会被写入dbPath下的_tmp文件夹，dbPath默认值是`/data/db`。

- 使用示例

```js
> db.transactions.aggregate([
    {
        $group: {
            _id: "$currency"
        }
    }
], {allowDiskUse:true})
```



## 8.4、聚合操作符

语法格式：

```js
{ <operator>: [<argument1>, <argument2> ... ] }
{ <operator>: <argument> }
```



## 8.5、聚合操作的优化



# 九、索引

数据准备：

```js
> db.accountsWithIndex.insertMany([
    {
        name: "alice", balance: 50, currnecy: ["GBP", "USD"]
    },
    {
        name: "bob", balance: 20, currency: ["AUD", "USD"]
    },
    {
        name: "bob", balance: 300, currency: ["CNY"]
	}    
])
```

## 9.1、索引分类：

| 索引分类名称 | 索引含义                             |
| ------------ | ------------------------------------ |
| 单键索引     | 一个字段的索引                       |
| 复合键索引   | 多个字段的索引，仅支持前缀匹配       |
| 多键索引     | 针对数组字段的索引                   |
| 复合多键索引 | 针对数组的元素对象的多个字段创建索引 |

## 9.2、索引的创建

- 创建一个单建索引

```js
> db.accountsWithIndex.createIndex({name: 1})
```

- 列出集合中已经存在的索引

```js
> db.accountsWithIndex.getIndexes();
```

- 创建一个复合键索引

```js
> db.accountsWithIndex.createIndex({name: 1, balance: -1})
```

- 创建一个多键索引

```js
> db.accountsWithIndex.createIndex({currency: 1})
```

**说明**：数组字段中的每一个元素，都会在多键索引中创建一个键。

## 9.3、索引的效果

语法格式：

```js
db.<collection>.explain().<method(...)>
```

**说明**：可以使用explain()进行分析的命令包括`aggregate()`,`count()`,`distinct()`,`find()`,`group()`,`remove()`,`update()`

| winningPlan.stage          | 含义       |
| -------------------------- | ---------- |
| COLLSCAN                   | 全集合扫描 |
| IXSCAN->FETCH              | 索引扫描   |
| IXSCAN->PROJECTION_COVERED | 投影覆盖   |
| SORT                       | 全集合扫描 |



- 使用没有创建索引的字段进行搜索

```js
> db.accountsWithIndex.explain().find({balance: 100})
{
	"queryPlanner" : {
		"plannerVersion" : 1,
		"namespace" : "test.accountsWithIndex",
		"indexFilterSet" : false,
		"parsedQuery" : {
			"balance" : {
				"$eq" : 100
			}
		},
		"queryHash" : "88DDD986",
		"planCacheKey" : "9238DC63",
		"winningPlan" : {
			"stage" : "COLLSCAN",
			"filter" : {
				"balance" : {
					"$eq" : 100
				}
			},
			"direction" : "forward"
		},
		"rejectedPlans" : [ ]
	},
	"serverInfo" : {
		"host" : "debc519d5126",
		"port" : 27017,
		"version" : "4.4.3",
		"gitVersion" : "913d6b62acfbb344dde1b116f4161360acd8fd13"
	},
	"ok" : 1
}
```

**注意**：重点是`winningPlan`字段，表示MongoDB挑选中的优胜执行计划是什么。上面结果是`COLLSCAN`是全集合扫描，效率很低的，应该尽量避免。

- 使用一级创建索引的字段进行搜索

```js
> db.accountsWithIndex.explain().find({name: "alice"})
{
	"queryPlanner" : {
		"plannerVersion" : 1,
		"namespace" : "test.accountsWithIndex",
		"indexFilterSet" : false,
		"parsedQuery" : {
			"name" : {
				"$eq" : "alice"
			}
		},
		"queryHash" : "01AEE5EC",
		"planCacheKey" : "0BE5F32C",
		"winningPlan" : {
			"stage" : "FETCH",
			"inputStage" : {
				"stage" : "IXSCAN",
				"keyPattern" : {
					"name" : 1
				},
				"indexName" : "name_1",
				"isMultiKey" : false,
				"multiKeyPaths" : {
					"name" : [ ]
				},
				"isUnique" : false,
				"isSparse" : false,
				"isPartial" : false,
				"indexVersion" : 2,
				"direction" : "forward",
				"indexBounds" : {
					"name" : [
						"[\"alice\", \"alice\"]"
					]
				}
			}
		},
		"rejectedPlans" : [
			{
				"stage" : "FETCH",
				"inputStage" : {
					"stage" : "IXSCAN",
					"keyPattern" : {
						"name" : 1,
						"balance" : -1
					},
					"indexName" : "name_1_balance_-1",
					"isMultiKey" : false,
					"multiKeyPaths" : {
						"name" : [ ],
						"balance" : [ ]
					},
					"isUnique" : false,
					"isSparse" : false,
					"isPartial" : false,
					"indexVersion" : 2,
					"direction" : "forward",
					"indexBounds" : {
						"name" : [
							"[\"alice\", \"alice\"]"
						],
						"balance" : [
							"[MaxKey, MinKey]"
						]
					}
				}
			}
		]
	},
	"serverInfo" : {
		"host" : "debc519d5126",
		"port" : 27017,
		"version" : "4.4.3",
		"gitVersion" : "913d6b62acfbb344dde1b116f4161360acd8fd13"
	},
	"ok" : 1
}
```

- 仅返回创建了索引的字段

```js
> db.accountsWithIndex.explain().find({name: "alice"}, {_id: 0, name: 1})
{
	"queryPlanner" : {
		"plannerVersion" : 1,
		"namespace" : "test.accountsWithIndex",
		"indexFilterSet" : false,
		"parsedQuery" : {
			"name" : {
				"$eq" : "alice"
			}
		},
		"queryHash" : "3066FB64",
		"planCacheKey" : "A8F8C110",
		"winningPlan" : {
			"stage" : "PROJECTION_COVERED",
			"transformBy" : {
				"_id" : 0,
				"name" : 1
			},
			"inputStage" : {
				"stage" : "IXSCAN",
				"keyPattern" : {
					"name" : 1
				},
				"indexName" : "name_1",
				"isMultiKey" : false,
				"multiKeyPaths" : {
					"name" : [ ]
				},
				"isUnique" : false,
				"isSparse" : false,
				"isPartial" : false,
				"indexVersion" : 2,
				"direction" : "forward",
				"indexBounds" : {
					"name" : [
						"[\"alice\", \"alice\"]"
					]
				}
			}
		},
		"rejectedPlans" : [
			{
				"stage" : "PROJECTION_COVERED",
				"transformBy" : {
					"_id" : 0,
					"name" : 1
				},
				"inputStage" : {
					"stage" : "IXSCAN",
					"keyPattern" : {
						"name" : 1,
						"balance" : -1
					},
					"indexName" : "name_1_balance_-1",
					"isMultiKey" : false,
					"multiKeyPaths" : {
						"name" : [ ],
						"balance" : [ ]
					},
					"isUnique" : false,
					"isSparse" : false,
					"isPartial" : false,
					"indexVersion" : 2,
					"direction" : "forward",
					"indexBounds" : {
						"name" : [
							"[\"alice\", \"alice\"]"
						],
						"balance" : [
							"[MaxKey, MinKey]"
						]
					}
				}
			}
		]
	},
	"serverInfo" : {
		"host" : "debc519d5126",
		"port" : 27017,
		"version" : "4.4.3",
		"gitVersion" : "913d6b62acfbb344dde1b116f4161360acd8fd13"
	},
	"ok" : 1
}
```

- 使用已经创建索引的字段进行排序

```js
> db.accountsWithIndex.explain().find().sort({name: 1, balance: -1})
{
	"queryPlanner" : {
		"plannerVersion" : 1,
		"namespace" : "test.accountsWithIndex",
		"indexFilterSet" : false,
		"parsedQuery" : {
			
		},
		"queryHash" : "DC9EFEDE",
		"planCacheKey" : "DC9EFEDE",
		"winningPlan" : {
			"stage" : "FETCH",
			"inputStage" : {
				"stage" : "IXSCAN",
				"keyPattern" : {
					"name" : 1,
					"balance" : -1
				},
				"indexName" : "name_1_balance_-1",
				"isMultiKey" : false,
				"multiKeyPaths" : {
					"name" : [ ],
					"balance" : [ ]
				},
				"isUnique" : false,
				"isSparse" : false,
				"isPartial" : false,
				"indexVersion" : 2,
				"direction" : "forward",
				"indexBounds" : {
					"name" : [
						"[MinKey, MaxKey]"
					],
					"balance" : [
						"[MaxKey, MinKey]"
					]
				}
			}
		},
		"rejectedPlans" : [ ]
	},
	"serverInfo" : {
		"host" : "debc519d5126",
		"port" : 27017,
		"version" : "4.4.3",
		"gitVersion" : "913d6b62acfbb344dde1b116f4161360acd8fd13"
	},
	"ok" : 1
}
```

- 使用未创建索引的字段进行排序

```js
> db.accountsWithIndex.explain().find().sort({name: 1, balance: 1})
{
	"queryPlanner" : {
		"plannerVersion" : 1,
		"namespace" : "test.accountsWithIndex",
		"indexFilterSet" : false,
		"parsedQuery" : {
			
		},
		"queryHash" : "797A24CD",
		"planCacheKey" : "797A24CD",
		"winningPlan" : {
			"stage" : "SORT",
			"sortPattern" : {
				"name" : 1,
				"balance" : 1
			},
			"memLimit" : 104857600,
			"type" : "simple",
			"inputStage" : {
				"stage" : "COLLSCAN",
				"direction" : "forward"
			}
		},
		"rejectedPlans" : [ ]
	},
	"serverInfo" : {
		"host" : "debc519d5126",
		"port" : 27017,
		"version" : "4.4.3",
		"gitVersion" : "913d6b62acfbb344dde1b116f4161360acd8fd13"
	},
	"ok" : 1
}
```

## 9.4、索引的删除



# 10、MongoDB管理工具

## 10.1、安装Database Tools

安装文件下载地址：[Linux版Database Tools](https://docs.mongodb.com/database-tools/installation/installation/)

下载版本选择页面：https://www.mongodb.com/try/download/database-tools?tck=docs_databasetools

使用文档：https://docs.mongodb.com/database-tools/

- 下载

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.3.0.tgz
```

- 安装目录创建

说明：使用之前的安装目录。

- 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/mongodb-database-tools-rhel70-x86_64-100.3.0.tgz -C /usr/local/MongoDB/
```

- 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/MongoDB/mongodb-database-tools-rhel70-x86_64-100.3.0/ /usr/local/mongodbtools
```

- 配置环境变量

修改mongodb的环境变量文件，如下：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/mongodb.sh 
export PATH=/usr/local/mongodb/bin:/usr/local/mongodbtools/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```



**说明**：数据库管理工具提供的命令，需要在系统命令行下执行，而不是`mongo` shell下执行。



## 10.2、明文格式导入导出

### 10.2.1、`mongoexport`导出

语法格式：

```bash
mongoexport --collection=<coll> <options> <connection-string>
```

```bash
[emon@emon ~]$ mongoexport --db test --collection accounts --type=csv --fields name,balance --out /usr/local/mongodb/bak/accounts.csv -u backup -p test123
```





## 10.3、二进制格式导入导出





# 八十、数据控制语言（DCL）

## 80.1、角色管理

### 80.1.1、MongoDB数据库默认角色

- 数据库用户角色
  - `read`
  
  >读取当前数据库中所有非系统集合
  
  - `readAnyDatabase`
  
  > 读取任何数据库中所有非系统集合，仅在admin数据库有效
  
  - `readWrite`
  
  >读写当前数据库中所有非系统集合
  
  - `readWriteAnyDatabase`
  
  > 读写任何数据库可中所有非系统集合，仅在admin数据库有效
  
- 数据库管理角色
  - `dbAdmin`
  
  > 管理当前数据库
  
  - `dbAdminAnyDatabase`
  
  > 管理任何数据库，仅在admin数据库有效
  
  - `dbOwner`: 
  - `userAdmin`
  
  > 管理当前数据库中的用户和角色
  
  - `userAdminAnyDatabase`
  
  > 管理任何数据库中的用户和角色，仅在admin数据库有效
  
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



### 80.1.2、创建角色

语法格式：

```js
db.createRole(role, writeConcern)
```

| 参数         | 类型     | 描述   |
| ------------ | -------- | ------ |
| role         | document |        |
| writeConcern | document | 可选项 |

- 创建角色

```js
> use test;
> db.createRole(
	{
        role: "readAccounts",
        privileges: [
            {
                resource: {db: "test", collection: "accounts"}, 
                actions: ["find"]
            }
        ],
        roles: []
    }
)
> db.createUser(
	{
        user: "accountsReader",
        pwd: "passwd",
        roles: ["readAccounts"]
    }
)
```



### 80.1.3、查询角色

- 查询单个角色

```js
db.getRole("readAccounts")
```

- 查询所有角色（非内建)

```js
db.getRoles()
```

- 查询所有角色（内建）

```js
db.getRoles({showBuiltinRoles:true})
```

- 查询所有角色（非内建+内建）

```js
show roles
```



### 80.1.4、删除角色

- 删除单个角色

```js
db.dropRole("readAccounts")
```

- 删除所有非内建的角色

```js
db.dropAllRoles()
```



## 80.2、用户管理

### 80.2.1、创建用户

语法格式：

```js
db.createUser(user, writeConcern)
```

参数说明：

| 参数         | 类型     | 描述   |
| ------------ | -------- | ------ |
| user         | document |        |
| writeConcern | document | 可选项 |

- 创建一个只能读取test数据库的用户

```js
> use test;
> db.createUser(
	{
        user: "testReader",
        pwd: "passwd",
        roles: [{role: "read", db: "test"}]
    }
)
```




### 80.2.2、查询用户

语法格式：

```js
# 查询单个
db.getUser(username, args)
# 查询列表
db.getUsers(<options>)
```

| 参数     | 类型     | 描述   |
| -------- | -------- | ------ |
| username | string   | 用户名 |
| args     | document | 可选项 |

- 查看用户密码

```js
db.getUser("testReader")
```

- 查看用户列表

```js
db.getUsers()
```

- 显示用户

```js
> show users
```



### 80.2.3、修改密码

- 修改用户密码

```js
db.changeUserPassword("testReader", "password")
```

- 修改用户密码

```js
db.updateUser('root', {pwd:'root@123'})
```



### 80.2.4、授权角色到用户

- 为用户添加新角色，不会影响之前的角色

```js
db.grantRolesToUser("testReader", ["readWrite", {role:"read",db:"stock"}])
```



### 80.2.5、移除用户的某个角色

- 移除掉用的某个角色

```js
db.revokeRolesFromUser("testReader", ["readWrite",{db:"stock",role:"read"}])
```



### 80.2.4、删除用户
语法格式：

```bash
db.dropUser(username, writeConcern)
```

参数说明：

| 参数         | 类型     | 描述   |
| ------------ | -------- | ------ |
| username     | string   | 用户名 |
| writeConcern | document | 可选项 |

- 删除用户

```js
db.dropUser("testReader")
```




## 80.3、设置用户名密码

1. 先添加用户

- 命令行下添加用户

```js
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

- 配置一个仅能访问test数据库的备份用户

```js
> use test
> db.createUser({
	user: "backup",
	pwd: "backup123",
	roles: [{role:"read", db:"test"}]
})
```



# 九十、MongDB的操作工具

## 1、Robo 3T连接

1. 下载

下载地址：https://robomongo.org/download

2. 启动并连接

## 2、Mongo Express

Mongo Express是一个基于网络的MongoDB数据库管理界面

### 2.1、安装MongoExpress（Docker版）

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

## 3、 Mongo Shell（Docker版）

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





