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

    - >  Kafka Sink：将数据发送到Kafka消息队列中

