# Maven实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装`nexus maven`私服

1. 前提

安装了JDK

2. 下载

官网地址：https://www.sonatype.com/

下载地址：https://www.sonatype.com/download-oss-sonatype

专项下载地址：https://help.sonatype.com/repomanager3/download

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://sonatype-download.global.ssl.fastly.net/repository/repositoryManager/3/nexus-3.15.2-01-unix.tar.gz
```

3. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Nexus
```

4. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/nexus-3.15.2-01-unix.tar.gz -C /usr/local/Nexus/
```

5. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Nexus/nexus-3.15.2-01/ /usr/local/nexus
```

6. 修改默认服务端口

```bash
[emon@emon ~]$ vim /usr/local/nexus/etc/nexus-default.properties 
```

```bash
# 默认的8081端口，修改为8089
application-port=8089
```

7. 配置环境变量

在`/etc/profile.d`目录创建`nexus.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/nexus.sh
export NEXUS_HOME=/usr/local/nexus
export PATH=$NEXUS_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

8. 校验

```bash
[emon@emon ~]$ nexus status
nexus is stopped.
```

9. 启动、停止、重启

- 启动

```bash
[emon@emon ~]$ nexus start
```

- 停止

```bash
[emon@emon ~]$ nexus stop
```

- 重启

```bash
[emon@emon ~]$ nexus restart
```

