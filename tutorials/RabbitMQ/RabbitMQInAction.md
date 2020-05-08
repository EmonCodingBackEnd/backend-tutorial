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
rabbitmqctl set_permissions -p vhostpath username 
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











# 九十九、用户信息

| 用户名 | 密码  |
| ------ | ----- |
| guest  | guest |
|        |       |
|        |       |

