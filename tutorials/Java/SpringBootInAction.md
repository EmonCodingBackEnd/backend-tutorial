# SpringBoot

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、小总结

## 1、监控 spring-boot-starter-actuator

- 如何引入？

使用时需要引入web和actuator，如下：

```xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```

- 如何开放`endpoint(s)`

```yml
management:
  endpoint:
    shutdown:
      enabled: true # 最特殊的监控端点
  endpoints:
    web:
      exposure:
        include: "*" # 打开所有的监控点
```



- 如何访问

http://ip:port/{context-path}/actuator

- 分类

    - 应用配置类常用监控
        - 自己配置的info信息：`/actuator/info`
        - 应用中bean的信息：`/actutor/beans`
        - 应用中URI路径信息：`/actuator/mappings`

    - 度量指标类常用监控

        - 检查应用的运行状态：`/actuator/health`
        - 当前线程活动快照：`/actuator/threaddump`

    - 操作控制类常用监控

        - 关闭应用（POST）：`/actuator/shutdown`

        ```bash
        curl -X POST "http://localhost:8080/actuator/shutdown"
        ```

- 自定义端点



## 2、feign打开日志

https://blog.csdn.net/youbl/article/details/109047987

