# ZooKeeper实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

官网地址： https://zookeeper.apache.org/index.html

下载地址：https://archive.apache.org/dist/zookeeper/

下载地址： https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/



[安装Zookeeper](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#1%E5%AE%89%E8%A3%85zookeeper)

# 二、常用命令

## 2.1、基本命令

- 远程连接

```bash
[emon@emon ~]$ zkCli.sh -server emon:2181
```

- 本地连接

```bash
[emon@emon ~]$ zkCli.sh
```

- 退出（连接成功后，使用命令quit退出）

```bash
quit
```

- 查看命令帮助

```bash
help
```

- 查看根节点下内容

```bash
ls /
```

- 查看根节点下内容及状态明细

```bash
ls -s /
# 或者【已过时的命令】
ls2 /
```

> ```bash
> cZxid = 0x0								节点创建时的事务id
> ctime = Thu Jan 01 08:00:00 CST 1970	节点创建的时间是1970年
> mZxid = 0x0								最近一次修改的事务id
> mtime = Thu Jan 01 08:00:00 CST 1970	修改的时间
> pZxid = 0x304							子节点删除或添加的znode的事务id，如果没有子节点，就是本身节点的czxid
> cversion = 71							对子节点的创建、删除次数
> dataVersion = 0							当前节点的数据版本号
> aclVersion = 0							权限修改次数
> ephemeralOwner = 0x0					临时节点所属实例的sessionId，如果有的话说明是临时节点
> dataLength = 0							数据字段的长度
> numChildren = 11						第一层子节点个数
> ```

- 创建节点并存储数据hello

```bash
# 创建非序列的持久节点
create /test hello
# 创建临时节点
create -e /test/tmp hello-tmp
# 创建序列节点
create -s /test/seq hello-tmp
# 创建序列的临时节点
create -s -e /test/seq-tmp hello-seq-tmp
```

- 查看节点内容

```bash
get /test
# 命令行输出结果
hello
```

- 查看节点内容和状态明细

```bash
get -s /test
```

- 设置节点内容

```bash
# 注意，这是后dataVersion会自动加1
set /test hello1
# 设置并返显明细
set -s /test hello1
# 设置并指定版本号，如果当前版本dataVersion=1时命令才会正确执行，否则提示：version No is not valid : /test
set -s -v 1 /test hello1
```

- 删除节点

```bash
# 递归删除
deleteall /test
# 普通删除
delete /test
# 删除指定版本号的数据节点，如果dataVersion=1的时候，并且/test没有子节点时才会正确执行
delete -v 1 /test
```

## 2.2、watcher

### 2.2.1、watcher操作概述

- 如何设置watcher？
  - `get -w path`
  - `ls -w path`
  - `stat -w path`
- 如何触发watcher？
  - 父节点增删改操作触发watcher
  - 子节点增删改操作触发watcher

### 2.2.2、父节点触发watcher

- 删除父节点触发：NodeDeleted

```bash
stat -w /test
deleteall /test
# 命令行输出
WATCHER::

WatchedEvent state:SyncConnected type:NodeDeleted path:/test
```

- 创建父节点触发：NodeCreated

```bash
stat -w /test
create /test 123
# 命令行输出
WATCHER::

WatchedEvent state:SyncConnected type:NodeCreated path:/test
```

- 修改父节点触发：NodeDataChanged

```bash
get -w /test
set /test 789
# 命令行输出
WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/test
```

### 2.2.2、子节点触发watcher

- 创建子节点触发：NodeChildrenChanged

```bash
ls -w /test
create /test/abc 888
# 命令行输出
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/test
Created /test/abc
```

- 修改子节点不会触发事件

```bash
ls -w /test
set -s /test/abc 9090
```

- 删除子节点触发：NodeChildrenChanged

```bash
ls -w /test
delete /test/abc
# 命令行输出
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/test
```

## 2.3、acl

- 查看权限

```bash
# 创建节点
create /test/abc 9090
# 查看权限
getAcl /test/abc
# 命令行输出
'world,'anyone
: cdrwa
```

- 设置world权限

```bash
# 设置权限
setAcl /test/abc world:anyone:crwa
# 查看权限
getAcl /test/abc
# 命令行输出
'world,'anyone
: crwa
# 创建节点
create /test/abc/xyz 123
# 删除节点
delete /test/abc/xyz
# 命令行输出
Authentication is not valid : /test/abc/xyz
```

- 设置auth权限

```bash
# 添加/登录一个认证用户
addauth digest emon0:123456
# 设置权限
setAcl /test/abc auth:emon0:123456:cdrwa
# 查看权限
getAcl /test/abc
'digest,'emon0:VfLYllQszSu5jTPKo9hR8++hZvo=
: cdrwa
```

- 设置digest权限

```bash
# 设置权限，密码是<base64encoded(SHA1(password))>
setAcl /test/abc digest:emon0:VfLYllQszSu5jTPKo9hR8++hZvo=:cdrwa
```

- 设置ip权限

```bash
# 设置权限
setAcl /test/abc ip:192.168.200.1:cdrwa
```

- 设置super超级管理员权限

第一步：修改zkServer.sh，增加super管理员

```bash
# 找到nohup，增加-Dzookeeper.DigestAuthenticationProvider.superDigest属性，emon:emon123
nohup "$JAVA" $ZOO_DATADIR_AUTOCREATE "-Dzookeeper.log.dir=${ZOO_LOG_DIR}" \
"-Dzookeeper.log.file=${ZOO_LOG_FILE}" "-Dzookeeper.root.logger=${ZOO_LOG4J_PROP}" \
-XX:+HeapDumpOnOutOfMemoryError -XX:OnOutOfMemoryError='kill -9 %p' \
"-Dzookeeper.DigestAuthenticationProvider.superDigest=emon:6/mDgySlNwggKl0eNhUYm7rPFYs=" \
-cp "$CLASSPATH" $JVMFLAGS $ZOOMAIN "$ZOOCFG" > "$_ZOO_DAEMON_OUT" 2>&1 < /dev/null &
```

第二步：重启zkServer.sh

```bash
$ zkServer.sh restart
```

```bash
# 查看权限
getAcl /test/abc 
```



# 三、初识ZooKeeper

## 3.1、ZooKeeper简介

- 中间件，提供协调服务
- 作用于分布式系统，发挥其优势，可以为大数据服务
- 支持Java，提供Java和C语言的客户端API

## 3.2、什么是分布式系统

- 很多台计算机组成一个整体，一个整体一致对外并且处理同一个请求
- 内部的每台计算机都可以互相通信（rest/rpc）
- 客户端到服务端的一次请求到响应结束会经历多台计算机

## 3.3、ZooKeeper的特性

- 一致性：数据一致性，数据按照顺序分批入库
- 原子性：事务要么成功要么失败，不会局部化
- 单一视图：客户端连接集群中的任一ZK节点，数据都是一致的

- 可靠性：每次对ZK的操作状态都会保存在服务端
- 实时性：客户端可以读取到ZK服务端的最新数据

## 3.4、ZooKeeper主要目录结构

```bash
# ZooKeeper 3.5.9
$ tree -L 1
```

> .
> ├── bin：主要的一些运行命令
> ├── conf：存放配置文件，其中我们需要修改zoo_sample.cfg（复制为zoo.cfg并修改配置内容）
> ├── data
> ├── docs：文档
> ├── lib：需要依赖的jar包
> ├── LICENSE.txt
> ├── logs
> ├── NOTICE.txt
> ├── README.md
> └── README_packaging.txt

## 3.5、zoo.cfg配置

- tickTime ：用于计算的时间单元。比如session超时：N*tickTime。默认值：2000，单位毫秒
- initLimit ： 用于集群，允许 从节点连接 并同步到 master节点 的初始化连接时间，以tickTime的倍数来表示。默认值：10
- syncLimit ： 用于集群，master主节点与从节点之间发送消息，请求和应答时间长度。（心跳机制）默认值：5
- dataDir ： 必须配置，默认值：/tmp/zookeeper
- dataLogDir ： 日志目录，如果不配置会和dataDir公用
- clientPort ： 连接服务器的端口，默认值：2181



# 四、ZooKeeper基础与进阶

## 4.1、ZooKeeper基本数据模型介绍

- 是一个树形结构，类似于前端开发中的tree.js组件
- 每一个节点都称之为znode，它可以有子节点，也可以有数据
- 每个节点分为临时节点和永久节点，临时节点在客户端断开后消失
- 每个zk节点都有各自的版本号，可以通过命令行来显示节点信息
- 每当节点数据发生变化，那么该节点的版本号会累加（乐观锁）
- 删除/修改过时节点，版本号不匹配则会报错
- 每个zk节点存储的数据不宜过大，几K即可

- 节点可以设置权限acl，可以通过权限来限制用户的访问



## 4.2、zk的作用体现

- master节点选举，主节点挂了以后，从节点就会接手工作，并且保证这个节点是唯一的，这也是所谓首脑模式，从而保证我们的集群是高可用的。
- 统一配置文件管理，即只需要部署一台服务器，则可以把相同的配置文件同步更新到其他所有服务器，此操作在云计算中用的特别多（假设修改了redis统一配置）。
- 发布与订阅，类似消息队列MQ（amq，rmq...），dubbo发布者把数据存储在znode上，订阅者会读取这个数据
- 提供分布式锁，分布式环境中不同进程之间争夺资源，类似于多线程中的锁。
- 集群管理，集群中保证数据的强一致性。



## 4.3、zk特性 - session的基本原理

- 客户端与服务端之间的连接存在会话
- 每个会话都可以设置一个超时时间
- 心跳结束，session则过期
- session过期，则临时节点znode会被抛弃
- 心跳机制：客户端向服务端的ping包请求



## 4.4、zk特性 - watcher机制

- 针对每个节点的操作，都会有一个监督者=>watcher
- 当监控的某个对象（znode）发生了变化，则触发watcher事件
- zk中的watcher是一次性的，触发后立即小慧
- 父节点，子节点 增删改都能够触发其watcher
- 针对不同类型的操作，触发的watcher事件也不同：
  - （子）节点创建事件
  - （子）节点删除事件
  - （子）节点数据变化事件

## 4.5、ACL(access control lists)权限控制

- 针对节点可以设置相关读写等权限，目的是为了保障数据安全性。

- 权限permissions可以指定不同的权限范围以及角色。

- ACL命令行

  - getAcl：获取某个节点的acl权限信息
  - setAcl：设置某个节点的acl权限信息

  - addauth：输入认证授权信息，注册时输入明文密码（登录），但是在zk的系统里，密码是以加密的形式存在的。

- ACL的构成

  - zk的acl通过`[schemaid:id:permissions]`来构成权限列表

    - schema：代表采用的某种权限机制
    
      - world：world下只有一个id，即只有一个用户，也就是anyone，那么组合的写法就是`world:anyone:[permissions]`
      - auth：代表认证登录，需要注册用户有权限就可以，形式为`auth:user:password:[permissions]`
      - digest：需要对密码加密才能访问，组合形式为`digest:username:BASE64(SHA1(password)):[permissions]`
    
      > 简而言之，auth与digest的区别就是，前者明文，后者密文。
      >
      > setAcl /path auth:lee:lee:cdrwa
      >
      > 与
      >
      > setAcl /path digest:lee:BASE64(SHA1(password)):cdrwa
      >
      > 是等价的，在通过 addauth digest lee:lee 后都能操作指定节点的权限
    
      - ip：当设置为ip指定的ip地址，此时限制ip进行访问，比如 `ip:192.168.1.1:[permissions]`
      - super：代表超级管理员，拥有所有的权限
    
    - id：代表允许访问的用户
    
    - permissions：权限组合字符串
    
      - 权限字符串缩写`crdwa`
        - CREATE：创建子节点
        - DELETE：删除子节点
        - READ：获取节点/子节点
        - WRITE：设置节点数据
        - ADMIN：设置权限
  

## 4.6、ACL的常用使用场景

- 开发/测试环境分离，开发者无权操作测试库的节点，只能看。
- 生产环境上控制指定ip的服务可以访问相关节点，防止混乱。



## 4.7、zk四字命令Four Letter Words

- zk可以通过它自身提供的简写命令来和服务器进行交互。
- 需要使用到nc命令，安装：`yum install nc`
- `echo [command] | nc [ip] [port]` ==> `echo stat|nc emon 2181`

### 4.7.1、解决白名单问题

问题：stat is not executed because it is not in the whitelist.

- 解决方法1：

vim /usr/local/zoo/bin/zkServer.sh

添加`ZOOMAIN="-Dzookeeper.4lw.commands.whitelist=* ${ZOOMAIN}"`一行并重启

```bash
    echo "ZooKeeper remote JMX Port set to $JMXPORT" >&2
    echo "ZooKeeper remote JMX authenticate set to $JMXAUTH" >&2
    echo "ZooKeeper remote JMX ssl set to $JMXSSL" >&2
    echo "ZooKeeper remote JMX log4j set to $JMXLOG4J" >&2
    ZOOMAIN="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=$JMXPORT -Dcom.sun.management.jmxremote.authenticate=$JMXAUTH -Dcom.sun.management.jmxremote.ssl=$JMXSSL -Dzookeeper.jmx.log4j.disable=$JMXLOG4J org.apache.zookeeper.server.quorum.QuorumPeerMain"
  fi
else
    echo "JMX disabled by user request" >&2
    ZOOMAIN="org.apache.zookeeper.server.quorum.QuorumPeerMain"
fi
ZOOMAIN="-Dzookeeper.4lw.commands.whitelist=* ${ZOOMAIN}"
```

- 解决方法2：

```bash
vim /usr/local/zoo/conf/zoo.cfg
```

```bash
# [新增]
4lw.commands.whitelist=*
```

### 4.7.2、命令示例

- 安装nc

```bash
$ yum install -y nc
```

- 查询状态

```bash
$ echo stat|nc emon 2181
```

- 查看当前zkserver是否启动，返回imok

```bash
$ echo ruok|nc emon 2181
```

- 列出未经处理的会话和临时节点

```bash
$ echo dump|nc emon 2181
```

- 查看服务器配置

```bash
$ echo conf|nc emon 2181
```

- `展示连接到服务器的客户端信息

```bash
$ echo cons|nc emon 2181
```

- 环境变量

```bash
$ echo envi|nc emon 2181
```

- 监控zk健康信息

```bash
$ echo mntr|nc emon 2181
```

- 展示watch的信息

```bash
$ echo wchs|nc emon 2181
```

- [wchc]与[wchp]session与watch及path与watch信息

```bash
$ echo wchc|nc emon 2181
```

## 4.8、ZooKeeper集群

### 4.8.1、ZooKeeper集群、主从节点、心跳机制（选举模式）



# 十、ZooKeeper客户端API

## 10.1、常用的ZooKeeper Java客户端

- ZooKeeper原生API

  - 配置

  ```xml
  <dependency>
      <groupId>org.apache.zookeeper</groupId>
      <artifactId>zookeeper</artifactId>
  </dependency>
  ```

  - 不足：Zookeeper的官方客户端提供了基本的操作，比如，创建会话、创建节点、读取节点、更新数据、删除节点和检查节点是否存在等。但对于开发人员来说，Zookeeper提供的基本操纵还是有一些不足之处。典型的缺点为：
    - Zookeeper的Watcher是一次性的，每次触发之后都需要重新进行注册； 
    - Session超时之后没有实现重连机制；需要手动才可以。
    - 异常处理繁琐，Zookeeper提供了很多异常，对于开发人员来说可能根本不知道该如何处理这些异常信息； 
    - 只提供了简单的byte[]数组的接口，没有提供针对对象级别的序列化； 
    - 不支持递归创建节点；
    - 创建节点时如果节点存在抛出异常，需要自行检查节点是否存在；
    - 删除节点无法实现级联删除； 

- ZkClient

  - 由Datameer的工程师开发，对Zookeeper的原生API进行了包装，实现了超时重连、Watcher反复注册等功能。像dubbo（2.3.0之前）等框架对其也进行了集成使用。从 2.3.0 版本开始支持可选 curator 实现。在2.7.x的版本中已经移除了zkclient的实现。
  - 不足：
    - 几乎没有参考文档；
    - 异常处理简化（抛出RuntimeException）；
    - 重试机制比较难用；
    - 没有提供各种使用场景的实现；

- Apache Curator

  - Apache Curator与ZooKeeper版本对应关系

  | Apache Curator                                               | ZooKeeper            |
  | ------------------------------------------------------------ | -------------------- |
  | Curator2.X、Curator4.2.X（需要排除ZooKeeper）                | ZooKeeper3.4.X       |
  | Curator3.0.0、Curator3.1.0、Curator3.2.0、Curator3.2.1、Curator3.3.0 | ZooKeeper3.5.1-alpha |
  | Curator4.0.0、Curator4.0.1                                   | ZooKeeper3.5.3-beta  |
  | Curator4.1.0、Curator4.2.0                                   | ZooKeeper3.5.4-beta  |
  | Curator4.3.0                                                 | ZooKeeper3.5.7       |
  | Curator5.0.0、Curator5.1.0                                   | ZooKeeper3.6.0       |
  | Curator5.2.0、Curator5.2.1、Curator5.3.0                     | ZooKeeper3.6.3       |
  | Curator5.4.0                                                 | ZooKeeper3.7.0       |
  
  
  
  - Curator组件与ZooKeeper版本对应关系
  
  | 组件名称  | 用途                                                         |
  | --------- | ------------------------------------------------------------ |
  | Client    | ZooKeeper客户端的封装，用于取代原生的ZooKeeper客户端，提供了一些底层处理和相关的工具方法。 |
  | Framework | 简化ZooKeeper高级功能的使用，并增加了一些新的功能，比如ZooKeeper集群连接、重试等。 |
  | Recipes   | ZooKeeper所有的典型应用场景的实现（除了两阶段提交外），该主机依赖Client和Framework。包括监听、各种分布式锁（可重入锁、排他锁、共享锁、信号锁等）、缓存、队列、选举、分布式atomic（分布式计数器）、分布式Barrier等等。 |
  | Utilities | 为ZooKeeper提供的各种工具类。                                |
  | Errors    | Curator异常处理、连接、恢复等。                              |
  
  - Maven依赖
  
  | GroupID/Org        | ArtifactID/Name           | 描述                                                         |
  | ------------------ | ------------------------- | ------------------------------------------------------------ |
  | org.apache.curator | curator-recipes           | 所有典型应用场景。需要依赖client和framework，需设置自动获取依赖。 |
  | org.apache.curator | curator-framework         | 同组件中framework介绍                                        |
  | org.apache.curator | curator-client            | 同组件中client介绍                                           |
  | org.apache.curator | curator-test              | 包含TestingServer、TestingCluster和一些测试工具。            |
  | org.apache.curator | curator-examples          | 各种使用Curator特性的案例                                    |
  | org.apache.curator | curator-x-discovery       | 在framework上构建的服务发现实现。                            |
  | org.apache.curator | curator-x-discoveryserver | 可以和Curator Discovery一起使用的RESTful服务器。             |
  | org.apache.curator | curator-x-rpc             | Curator Framework和Recipes非Java环境的桥接。                 |
  
  
  
  - Apache的开源项目
  - 解决Watcher的注册一次就失效问题
  - API更加简单易用
  - 提供更多解决方案并且实现简单，比如：分布式锁
  - 提供常用的ZooKeeper工具类
  - 编程风格更爽
  

# 九十、ZooKeeper Interview Guide

### 90.1、ZooKeeper奇偶数节点问题的简单理解

​	ZooKeeper的集群搭建需要符合过半存活即可用原则。假设我们节点数是2n，那么需要保证至少n+1的节点能正常工作，即容错数是n-1；当节点数为2n-1时，至少需要n个节点能正常工作，容错数也是n-1。为了节省服务器资源，我们选择设置奇数节点数量的方案。











