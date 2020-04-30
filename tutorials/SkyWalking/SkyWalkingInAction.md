# SkyWalking实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

1. 下载

官网： http://skywalking.apache.org/

下载地址： http://skywalking.apache.org/downloads/

由于要搭配Elasticsearch使用，这里下载`Binary Distribution for ElasticSearch 7`

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://mirror.bit.edu.cn/apache/skywalking/7.0.0/apache-skywalking-apm-es7-7.0.0.tar.gz
```

2. 创建按照目录

```bash
[emon@emon ~]$ mkdir /usr/local/SkyWalking
```

3. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/apache-skywalking-apm-es7-7.0.0.tar.gz -C /usr/local/SkyWalking/
```

4. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/SkyWalking/apache-skywalking-apm-bin-es7/ /usr/local/sw
```

5. 修改配置文件

配置文件`/usr/local/sw/config/application.yml`：

```bash
[emon@emon ~]$ vim /usr/local/sw/config/application.yml
```

- 第一处：存储方式

```yaml
storage:
  selector: ${SW_STORAGE:h2}
=>
storage:
  selector: ${SW_STORAGE:elasticsearch7} #selector: ${SW_STORAGE:h2}
```

- 第二处：es的集群名称

```yaml
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:""}
=>
  elasticsearch7:
    nameSpace: ${SW_NAMESPACE:"emon"} #nameSpace: ${SW_NAMESPACE:""}
```

配置文件`vim /usr/local/sw/webapp/webapp.yml`：

```bash
[emon@emon ~]$ vim /usr/local/sw/webapp/webapp.yml 
```

```bash
server:
    port: 8080
=>
server:
    port: 8780 #port: 8080
```

6. 常规启动

```bash
[emon@emon ~]$ /usr/local/sw/bin/startup.sh 
SkyWalking OAP started successfully!
SkyWalking Web Application started successfully!
```

**注意1：** 看到`successfully`不能表示成功了，需要看日志:`/usr/local/sw/logs/skywalking-oap-server.log`和`/usr/local/sw/logs/webapp.log`的详细结果。

- skywalking-oap-server.log

```
2020-04-30 17:51:10,801 - org.eclipse.jetty.server.Server - 444 [main] INFO  [] - Started @4288ms
2020-04-30 17:51:10,802 - org.apache.skywalking.oap.server.core.storage.PersistenceTimer - 59 [main] INFO  [] - persistence timer start
2020-04-30 17:51:10,804 - org.apache.skywalking.oap.server.core.cache.CacheUpdateTimer - 50 [main] INFO  [] - Cache updateServiceInventory timer start
```

- webapp.log

```
2020-04-30 17:42:11.941  INFO 53783 --- [main] o.s.c.support.DefaultLifecycleProcessor  : Starting beans in phase 02020-04-30 17:42:11.966  INFO 53783 --- [main] o.s.c.support.DefaultLifecycleProcessor  : Starting beans in phase 2147483647
2020-04-30 17:42:11.969  INFO 53783 --- [main] ration$HystrixMetricsPollerConfiguration : Starting poller2020-04-30 17:42:12.017  INFO 53783 --- [main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8080 (http)
2020-04-30 17:42:12.020  INFO 53783 --- [main] o.a.s.apm.webapp.ApplicationStartUp      : Started ApplicationStartUp in 6.956 seconds (JVM running for 7.606)
```

**注意2：** 注意`SkyWalking`会使用(8080, 10800, 11800, 12800)端口，因此先排除端口占用情况。



