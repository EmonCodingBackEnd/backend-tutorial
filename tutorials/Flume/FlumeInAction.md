# Kafka实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装Flume](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#7%E5%AE%89%E8%A3%85flume)

# 二、Flume详解

## 2.1、什么是Flume

Flume是一个高可用，高可靠，分布式的海量日志采集、聚合和传输的系统，能够有效的收集、聚合、移动大量的日志数据。

通俗一点来说就是Flume是一个很靠谱、很方便、很强的日志采集工具。

## 2.2、Flume的三大核心组件

- Source：数据源

  - > 通过Source组件可以指定让Flume读取哪里的数据，然后将数据传递给后面的channel
    >
    > Flume内置支持读取很多种数据源，基于文件、基于目录、基于TCP\UDP端口、基于HTTP、Kafka等等，也支持自定义！

  - 挑选几个常用的说明下

    - > Exec Source：实现文件监控，可以实时监控文件中的新增内容，类似于Linux中的tail -f效果。需要注意`tail -F`和`tail -f`的区别：
      >
      > `tail -F`等同于-follow=name --retry，根据文件名进行追踪，并保持重试，即该文件被删除或改名后，如果再次创建相同的文件名，会继续追踪。
      >
      > `tail -f`等同于-follow=descriptor，根据文件描述符进行追踪，当文件改名或者被删除，追踪停止。

    - >  NetCat TCP/UDP Source：采集指定端口（tcp、udp）的数据。

    - > Spooling Directory Source：采集文件夹里新增的文件。

    - > Kafka Source：从Kafka消息队列中采集数据。

- Channel：临时存储数据的管道

  - > 接受Source发出的数据，临时存储
    >
    > Channel的类型有很多：内存、文件、内存+文件、JDBC等

  - 挑选几个常用的说明下

    - > Memory Channel：使用内存作为数据存储

    - > File Channel：使用文件来作为数据的存储

    - > Spillable Memory Channel：使用内存和文件作为数据存储，即先存储到内存中，如果内存中数据达到阈值再flush到文件中。

- Sink：目的地

  - > 从Channel中读取数据并存储到指定目的地
    >
    > Sink的表现形式：控制台、HDFS、Kafka等
    >
    > 注意：Channel中的数据直到进入目的地才会被删除，当Sink写入失败后，可以自动重写，不会造成数据丢失。

  - 常用的Sink组件

    - > Logger Sink：将数据作为日志处理

    - > HDFS Sink：将数据传输到HDFS中

    - > Kafka Sink：将数据发送到Kafka消息队列中



## 2.3、Flume的使用示例

### 2.3.1、示例1：netcat->memory->logger

- 配置

```bash
[emon@emon ~]$ vim /usr/local/flume/config/example.conf 
```

```properties
# example.conf: A single-node Flume configuration

# Name the components on this agent
a1.sources = r1
a1.sinks = k1
a1.channels = c1

# Describe/configure the source
a1.sources.r1.type = netcat
a1.sources.r1.bind = 0.0.0.0
a1.sources.r1.port = 44444

# Describe the sink
a1.sinks.k1.type = logger

# Use a channel which buffers events in memory
a1.channels.c1.type = memory
a1.channels.c1.capacity = 1000
a1.channels.c1.transactionCapacity = 100

# Bind the source and sink to the channel
a1.sources.r1.channels = c1
a1.sinks.k1.channel = c1
```

- 前台启动【测试用】

```bash
[emon@emon ~]$ flume-ng agent --conf /usr/local/flume/conf --conf-file /usr/local/flume/config/example.conf --name a1 -Dflume.root.logger=INFO,console
```

- 后台启动

```bash
[emon@emon ~]$ nohup flume-ng agent --conf /usr/local/flume/conf --conf-file /usr/local/flume/config/example.conf --name a1 -Dflume.root.logger=INFO,LOGFILE &
```

**说明**：`-Dflume.root.logger=INFO.LOGFILE`是`$FLUME_HOME/conf/log4j.properties`的默认值，可以省略！根据配置，日志`logs`文件会在命令执行时所在目录生成！

- 查看启动信息

```bash
[emon@emon ~]$ jps -m
```

- 验证

```bash
[emon@emon ~]$ telnet emon 44444
```

输入数据并回车，可以看到`flume-ng`终端可以看到对应输出！

- Supervisor管理服务运行【生产用】【推荐】

```bash
[emon@emon ~]$ vim supervisor.d/flume-netcat-memory-logger.ini
```

```ini
[program:flume-netcat-memory-logger]
command=/usr/local/flume/bin/flume-ng agent --conf /usr/local/flume/conf --conf-file /usr/local/flume/config/example.conf --name a1 -Dflume.root.logger=INFO,console
directory=/usr/local/flume/config
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
stdout_logfile=/usr/local/flume/config/example.log    ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动
创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```bash
# 加载最新配置文件
[emon@emon ~]$ sudo supervisorctl update
# 查看被管控的服务
[emon@emon ~]$ sudo supervisorctl status
# 启动
[emon@emon ~]$ sudo supervisorctl start flume-netcat-memory-logger
# 重启
[emon@emon ~]$ sudo supervisorctl restart flume-netcat-memory-logger
# 停止
[emon@emon ~]$ sudo supervisorctl stop flume-netcat-memory-logger
```
