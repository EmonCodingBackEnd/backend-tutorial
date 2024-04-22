# RabbitMQ实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、Docker版本安装

## 1、下载

下载地址获取页面： http://www.rabbitmq.com/download.html

docker镜像页面： https://hub.docker.com/_/rabbitmq/

## 2、安装

- 安装镜像

```bash
# 如果找不到镜像，下载并启动
[emon@emon ~]$ docker run -itd --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.8.3-management
```

- 验证

http://IP:15672



# 二、普通版本安装

## 1、安装Erlang

1. 下载安装包

下载地址获取页面： http://www.erlang.org/downloads

选择 OTP 21.3 Source File

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ http://erlang.org/download/otp_src_21.3.tar.gz
```

2. 依赖检查与安装

```bash
[emon@emon ~]$ yum list make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel unixODBC-devel
[emon@emon ~]$ sudo yum -y install make gcc gcc-c++ kernel-devel m4 ncurses-devel openssl-devel unixODBC-devel
```

3. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Erlang
```

4. 解压

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/otp_src_21.3.tar.gz -C /usr/local/Erlang/
```

5. 执行配置脚本，并编译安装

- 切换目录并执行配置脚本生成Makefile

```bash
[emon@emon ~]$ cd /usr/local/Erlang/otp_src_21.3/
[emon@emon otp_src_21.3]$ ./configure --prefix=/usr/local/Erlang/erlang21.3 --disable-javac
```

注意：看到如下提示，不会影响编译。

```bash
*********************************************************************
**********************  APPLICATIONS INFORMATION  *******************
*********************************************************************

wx             : wxWidgets not found, wx will NOT be usable

*********************************************************************
*********************************************************************
**********************  DOCUMENTATION INFORMATION  ******************
*********************************************************************

documentation  : 
                 fop is missing.
                 Using fakefop to generate placeholder PDF files.

*********************************************************************
```

- 编译

```bash
[emon@emon otp_src_21.3]$ make
```

- 安装

```bash
[emon@emon otp_src_21.3]$ make install
[emon@emon otp_src_21.3]$ cd
[emon@emon ~]$ ls /usr/local/Erlang/erlang21.3/
bin  lib
```

6. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Erlang/erlang21.3/ /usr/local/erl
```

7. 配置环境变量

在`/etc/profile.d`目录创建`erl.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/erl.sh
export ERLANG_HOME=/usr/local/erl
export PATH=$ERLANG_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

8. 校验

```bash
[emon@emon ~]$ erl
Erlang/OTP 21 [erts-10.3] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:1] [hipe]

Eshell V10.3  (abort with ^G)
1> halt().
```

## 2、安装RabbitMQ

1. 下载

下载地址获取页面：https://www.rabbitmq.com/download.html

下载地址列表：https://www.rabbitmq.com/releases/rabbitmq-server/

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.14/rabbitmq-server-generic-unix-3.7.14.tar.xz
```

2. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/RabbitMQ
```

3. 解压安装

```bash
# 其中，tar -Jxvf 可以分为两步执行， xz -d *.tar.xz 然后 tar -xvf *.tar
[emon@emon ~]$ tar -Jxvf /usr/local/src/rabbitmq-server-generic-unix-3.7.14.tar.xz -C /usr/local/RabbitMQ/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/RabbitMQ/rabbitmq_server-3.7.14 /usr/local/rabbitmq
```

如果创建软连接时，`rabbitmq_server-3.7.14`后面带有TAB键补全的`/`，会导致错误：

```bash
[emon@emon ~]$ rabbitmqctl status
escript: exception error: undefined function rabbitmqctl_escript:main/1
  in function  escript:run/2 (escript.erl, line 758)
  in call from escript:start/1 (escript.erl, line 277)
  in call from init:start_em/1 
  in call from init:do_boot/3 
```

5. 配置环境变量

在`/etc/profile.d`目录创建`rabbit.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/rabbitmq.sh
export RABBITMQ_HOME=/usr/local/rabbitmq
export PATH=$RABBITMQ_HOME/sbin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

6. 校验

- 启动服务

```bash
# 启动 rabbitmq, -detached 代表后台守护进程方式启动。
[emon@emon ~]$ rabbitmq-server -detached

# 后台启动的另一种方式【推荐】
[emon@emon ~]$ rabbitmq-server start &
```

- 查看启动状态

```bash
[emon@emon ~]$ rabbitmqctl status
```

- 关闭服务

```bash
[emon@emon ~]$ rabbitmqctl stop
```

- 列出角色

```bash
[emon@emon ~]$ rabbitmqctl list_users
Listing users ...
user	tags
guest	[administrator]
```

- 查看插件列表

```bash
[emon@emon ~]$ rabbitmq-plugins list
```

- 启动网页插件(15672端口)

```bash
[emon@emon ~]$ rabbitmq-plugins enable rabbitmq_management
```

7. 开放防火墙端口

```bash
# 配置Linux端口15672网页管理，5672 AMQP端口
[emon@emon ~]$ sudo firewall-cmd --permanent --zone=public --add-port=5672/tcp
[emon@emon ~]$ sudo firewall-cmd --permanent --zone=public --add-port=15672/tcp
[emon@emon ~]$ sudo firewall-cmd --reload
[emon@emon ~]$ sudo firewall-cmd --permanent --zone=public --list-ports
```

8. 访问网页

http://192.168.1.116:15672

错误提示：User can only log in via localhost 

因为RabbitMQ从3.3.0开始禁止使用guest/guest权限通过除localhost外的访问。

如果想使用guest/guest通过远程机器访问，需要调整如下：

```bash
[emon@emon ~]$ vim /usr/local/rabbitmq/ebin/rabbit.app 
```

找到`loopback_users`并调整内容：

`{loopback_users, [<<"guest">>]},` -> `{loopback_users, []},`

然后重启即可。



# 三、入门

## 1、RabbitMQ的命令行与管控台

### 1.1、基础操作

- 添加用户

```bash
rabbitmqctl add_user username password
```

- 赋予其administrator角色

```bash
rabbitmqctl set_user_tags username administrator
```

- 列出用户

```bash
rabbitmqctl list_users
```

- 删除用户

```bash
rabbitmqctl delete_user username
```

- 清除用户权限

```bash
rabbitmqctl clear_permissions -p vhostpath username
```

- 列出用户权限

```bash
rabbitmqctl list_user_permissions username
```

- 修改密码

```bash
rabbitmqctl change_password username newpassword
```

- 设置用户权限

```bash
rabbitmqctl set_permissions -p vhostpath username '.*' '.*' '.*'
```

- 创建虚拟主机

```bash
rabbitmqctl add_vhost vhostpath
```

- 列出所有虚拟主机

```bash
rabbitmqctl list_vhosts
```

- 列出虚拟主机上所有权限

```bash
rabbitmqctl list_permissions -p vhostpath
```

- 删除虚拟主机

```bash
rabbitmqctl delete_vhost vhostpath
```

- 查看所有队列信息

```bash
rabbitmqctl list_queues
```

- 清除队列里的消息

```bash
rabbitmqctl - p vhostpath purge_queue blue
```

### 1.3、高级操作

- 移除所有数据，要在rabbitmqctl stop之后使用

```bash
rabbitmqctl reset
```

- 组成集群命令

```bash
rabbitmqctl join_cluster <clusternode> [--ram]
```

- 查看集群状态

```bash
rabbitmqctl cluster_status
```

- 修改集群节点的存储形式

```bash
rabbitmqctl change_cluster_node_type disc|ram
```

- 忘记节点（摘除节点）

```bash
rabbitmqctl forget_cluster_node [--offline]
```

- 修改节点名称

```bash
rabbitmqctl rename_cluster_node oldnode1 newnode1 [oldnode2] [newnode2] ...
```

# 四、MQ概述

1. 大多应用中，可通过消息服务中间件来提升系统异步通信、扩展解耦能力。

2. 消息服务中两个重要概念：

   <span style="color:red;font-weight:bold;">消息代理（message broker）</span>和<span style="color:red;font-weight:bold;">目的地（destination）</span>

当消息发送者发送消息以后，将由消息代理接管，消息代理保证消息传递到指定目的地。

3. 消息队列主要有两种形式的目的地

   1. <span style="color:red;font-weight:bold;">队列（queue）</span>：点对点消息通信（point-to-point）

   2. <span style="color:red;font-weight:bold;">主题（topic）</span>：发布（publish）/订阅（subscribe）消息通信
4. 点对点式：
   1. 消息发送者发送消息，消息代理将其放入一个队列中，消息接收者从队列中获取消息内容，消息读取后被移出队列。
   2. 消息只有唯一的发送者和接收者，但并不是说只能有一个接收者。哪一个接收者收取了，其他接收者就不能得到了。

5. 发布订阅式：
   1. 发送者（发布者）发送消息到主题，多个接收者（订阅者）监听（订阅）这个主题，那么就会在消息到达时同时收到消息。

6. JMS（Java Message Service）Java消息服务：
   1. 基于JVM消息代理的规范。ActiveMQ、HornetMQ是JMS实现。

7. AMQP（Advanced Message Queuing Protocol）
   1. 高级消息队列协议，也是一个消息代理的规范，兼容JMS
   2. RabbitMQ是AMQP的实现


|              | JMS（Java Message Service）                                  | AMQP（Advanced Message Queuing Protocol）                    |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 定义         | Java api                                                     | 网络线级协议                                                 |
| 跨语言       | 否                                                           | 是                                                           |
| 跨平台       | 否                                                           | 是                                                           |
| Model        | 提供两种消息模型：<br />（1）、Peer-2-Peer<br />（2）、Pub/sub | 提供了五种消息模型：<br />（1）、direct exchange<br />（2）、fanout exchange<br />（3）、topic change<br />（4）、headers exchange<br />（5）、system exchange<br />本质来讲，后四种和JMS的pub/sub模型没有太大差别，仅是在路由机制上做了更详细的划分； |
| 支持消息类型 | 多种消息类型：<br />TextMessage<br />MapMessage<br />BytesMessage<br />StreamMessage<br />ObjectMessage<br />Message（只有消息头和属性） | byte[] 当实际应用时，有复杂的消息，可以将消息序列化后发送。  |
| 综合评价     | JMS定义了Java API层面的标准；在java体系中，多个client均可以通过JMS进行交互，不需要应用修改代码，但是其对跨平台的支持较差； | AMQP定义了wire-level层的协议标准；天然具有跨平台、跨语言特性。 |

8. Spring支持
   1. spring-jms提供了对JMS的支持
   2. spring-rabbit提供了对AMQP的支持
   3. 需要ConnectionFactory的实现来连接消息代理
   4. 提供JmsTemplate、RabbitTemplate来发送消息
   5. @JmsListener（JSM）、@RabbitListener（AMQP）注解在方法上监听消息代理发布的消息
   6. @EnableJms、@EnableRabbit开启支持
9. SpringBoot自动配置
   1. JmsAutoConfiguration
   2. RabbitAutoConfiguration
10. 市面上的MQ产品
    1. ActiveMQ
    2. RabbitMQ
    3. RocketMQ
    4. Kafka

# 五、RabbitMQ概念

## 1、RabbitMQ简介：

RabbitMQ是一个由erlang开发的AMQP（Advanved Message Queue Protocol）的开源实现。

## 2、核心概念

Message

消息，消息是不具名的，它由消息头和消息体组成。消息体时不透明的，而消息头则由一系列的可选属性组成，这些属性包括routing-key（路由键）、priority（相对于其他消息的优先权）、delivery-mode（指出该消息可能需要持久性存储）等等。

## 3、Publisher

消息的生产者，也是一个向交换器发布消息的客户端应用程序。

## 4、Exchange

交换器，用来接收生产者发送的消息并将这些消息路由给服务器中的队列。

Exchange有4种类型：direct（默认）、fanout、topic以及headers，不同类型的Exchange转发消息的策略有所不同。

## 5、Queue

消息队列，用来保存消息直到发送给消费者。它是消息的容器，也是消息的终点。一个消息可投入一个或多个队列。消息一直在队列里面，等待消费者连接到这个队列将其取走。

## 6、Binding

绑定，用于消息队列和交换器之间的关联。一个绑定就是基于路由键将交换器和消息队列连接起来的路由规则，所以可以将交换器理解成一个由绑定构成的路由表。

Exchange和Queue的绑定可以是多对多的关系。

## 7、Connection

网络连接，比如一个TCP连接。

## 8、Channel

信道，多路复用连接中的一条独立的双向数据流通道。信道是建立在真实的TCP连接内的虚拟连接，AMQP命令都是通过信道发出去的，不管是发布消息、订阅队列还是接收消息，这些动作都是通过信道完成。因为对于操作系统来说建立和销毁TCP都是非常昂贵的开销，所以引入了信道的概念，以复用一条TCP连接。

## 9、Consumer

消息的消费者，表示一个从消息队列中取得消息的客户端应用程序。

## 10、Virtual Host

虚拟主机，表示一批交换器、消息队列和相关对象。虚拟主机是共享相同的身份认证和加密环境的独立服务器域。每个vhost本质上就是一个mini版本的RabbitMQ服务器，拥有自己的队列、交换器、绑定和权限机制。vhost是AMQP概念的基础，必须在连接时指定，RabbitMQ默认的vhost是`/`。

## 11、Broker

表示消息队列服务器实体。

![image-20240422133228347](images/image-20240422133228347.png)



# 六、MQ应用场景

## 1、异步任务

## 2、应用解耦

## 3、流量控制、流量削峰









# 九十九、用户信息

| 用户名 | 密码      |
| ------ | --------- |
| guest  | guest     |
| rabbit | rabbit123 |
|        |           |

