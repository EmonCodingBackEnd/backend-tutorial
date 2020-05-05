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

2. 创建安装目录

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

- 第三处：相对路径修改为绝对路径

```yaml
receiver-trace:
  default:
    bufferPath: ${SW_RECEIVER_BUFFER_PATH:../trace-buffer/}
=>
receiver-trace:
  default:
    bufferPath: ${SW_RECEIVER_BUFFER_PATH:/usr/local/sw/trace-buffer/}
    
service-mesh:
  default:
    bufferPath: ${SW_SERVICE_MESH_BUFFER_PATH:../mesh-buffer/}
=>
service-mesh:
  default:
    bufferPath: ${SW_SERVICE_MESH_BUFFER_PATH:/usr/local/sw/mesh-buffer/}
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

# 二、分布式日志链路追踪trace-id

1. 配置agent

在项目的`VM options:`中配置如下内容：

```
-Xmx512m -Xms512m -Xmn256m -Xss228k -javaagent:C:\Job\JobSoftware\apache-skywalking-apm-es7-7.0.0\agent\skywalking-agent.jar -DSW_AGENT_NAME=huiba-site-provider -DSW_AGENT_COLLECTOR_BACKEND_SERVICES=192.168.5.116:11800
```

**说明：**

- javaagent
  - 代理的jar包

- SW_AGENT_NAME
  - 项目在SkyWalking中的服务名称。
- DSW_AGENT_COLLECTOR_BACKEND_SERVICES
  - 项目agent对应的`Backend service`地址



2. 配置logback

对SpringBoot项目，在`resources`目录下创建文件`logback-spring-defaults.xml`，内容如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--
Default logback configuration provided for import, equivalent to the programmatic
initialization performed by Boot
-->

<included>
    <conversionRule conversionWord="clr" converterClass="org.springframework.boot.logging.logback.ColorConverter" />
    <conversionRule conversionWord="wex" converterClass="org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter" />
    <conversionRule conversionWord="wEx" converterClass="org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter" />
    <property name="CONSOLE_LOG_PATTERN_CUSTOMER" value="${CONSOLE_LOG_PATTERN_CUSTOMER:-%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} [%tid] %clr(${LOG_LEVEL_PATTERN:-%5p}) %clr(${PID:- }){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}"/>
    <property name="FILE_LOG_PATTERN_CUSTOMER" value="${FILE_LOG_PATTERN_CUSTOMER:-%d{yyyy-MM-dd HH:mm:ss.SSS} [%tid] ${LOG_LEVEL_PATTERN:-%5p} ${PID:- } --- [%t] %-40.40logger{39} : %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}"/>
</included>
```

在其他logback日志配置文件中，引入该文件，比如`logback-spring-dev.xml`：

```xml
<include resource="logback-spring-defaults.xml"/>
```

配置`appender`如下：

```xml
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <!--<encoder>
            <pattern>${CONSOLE_LOG_PATTERN}</pattern>
            <charset>utf8</charset>
        </encoder>-->
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.TraceIdPatternLogbackLayout">
                <pattern>${CONSOLE_LOG_PATTERN_CUSTOMER}</pattern>
            </layout>
            <charset>utf8</charset>
        </encoder>
    </appender>

   <appender name="monitor_exception" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${logDir}/%d{yyyyMMdd}/monitor_exception.%i.log.gz</fileNamePattern>
            <maxHistory>50</maxHistory>
            <timeBasedFileNamingAndTriggeringPolicy
                    class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>WARN</level>
        </filter>
        <!--<encoder>
            <pattern>${FILE_LOG_PATTERN}</pattern>
        </encoder>-->
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.TraceIdPatternLogbackLayout">
                <pattern>${FILE_LOG_PATTERN_CUSTOMER}</pattern>
            </layout>
            <charset>utf8</charset>
        </encoder>
    </appender>

    <appender name="desc_normal" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${logDir}/%d{yyyyMMdd}/desc_normal.%i.log.gz</fileNamePattern>
            <maxHistory>50</maxHistory>
            <timeBasedFileNamingAndTriggeringPolicy
                    class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
        <!--<encoder>
            <pattern>${FILE_LOG_PATTERN}</pattern>
        </encoder>-->
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="org.apache.skywalking.apm.toolkit.log.logback.v1.x.TraceIdPatternLogbackLayout">
                <pattern>${FILE_LOG_PATTERN_CUSTOMER}</pattern>
            </layout>
            <charset>utf8</charset>
        </encoder>
    </appender>
```

如上配置后，对于用户请求日志如下：

```
2020-05-01 18:41:58.489 [TID:7.163.15883297184890001]  INFO 34808 --- [nio-8080-exec-3] c.i.plugin.CoreHeaderInterceptor         : rule: 1#offline
2020-05-01 18:41:58.493 [TID:7.163.15883297184890001]  INFO 34808 --- [nio-8080-exec-3] c.i.h.site.web.HealthCheckController     : view health api
```

对于普通日志如下：

```
2020-05-01 18:42:10.685 [TID:N/A]  INFO 34808 --- [nfoReplicator-0] jdbc.sqltiming                           : /* ping */ SELECT 1 
 {executed in 59 msec}
```

