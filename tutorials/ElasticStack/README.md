# ElasticStack实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装之前

## 1、目录规划

| 模块          | 安装目录                              | 软连接              |
| ------------- | ------------------------------------- | ------------------- |
| Elasticsearch | /usr/local/ElasticStack/Elasticsearch | /usr/local/es*      |
| Logstash      | /usr/local/ElasticStack/Logstash      | /usr/local/logstash |
| kibana        | /usr/local/ElasticStack/kibana        | /usr/local/kibana   |
| Beats         | /usr/local/ElasticStack/Beats         | /usr/local/beats    |
| 插件          | /usr/local/ElasticStack/ThirdPlugins  | /usr/local/*        |

创建所有目录：

```
[emon@emon ~]$ mkdir -pv /usr/local/ElasticStack/{Elasticsearch,Logstash,Kibana,Beats,ThirdPlugins}
```

## 2、依赖准备

请确保安装了JDK1.8，安装方式参考： [JDK1.8安装参考](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Linux/LinuxInAction.md)

打开后搜索 **安装JDK** 即可。

## 3、ElasticStack官网

官网： https://www.elastic.co/

下载地址页： https://www.elastic.co/downloads

# 二、安装

## 1、Elasticsearch

一主二从的安装方式

### 1.1、配置【一主】

1. 下载

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.1.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/elasticsearch-6.4.1.tar.gz -C /usr/local/ElasticStack/Elasticsearch/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Elasticsearch/elasticsearch-6.4.1/ /usr/local/es
```

4. 配置

- 配置`elasticsearch.yml`文件

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es/config/elasticsearch.yml 
```

```yaml
cluster.name: emon
node.name: master
# 表示该节点具有成为master的权利，但不一定就是master
node.master: true
network.host: 0.0.0.0
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es/config/jvm.options 
```

```
#-Xms1g
#-Xmx1g
-Xms256m
-Xmx256m
```

5. 解决启动问题

- 问题一

  - 问题描述

  ```
  [1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]
  ```

  - 解决办法

  ```shell
  # 打开文件并追加
  [emon@emon ~]$ sudo vim /etc/security/limits.conf
  ```

  ```
  # 配置内容，其中emon是启动elasticsearch的用户，如果不确定是什么用户，也可以替换为*表示所有
  emon             soft    nofile          1024
  emon             hard    nofile          65536
  ```

  **需要重新登录emon用户，才能生效**

- 问题二

  - 问题描述

  ```
  [2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
  ```

  - 解决办法

  ```shell
  # 查看
  [emon@emon ~]$ sudo sysctl -a|grep vm.max_map_count
  # 打开文件并追加
  [emon@emon ~]$ sudo vim /etc/sysctl.conf 
  ```

  ```
  vm.max_map_count=655360
  ```

  ```shell
  # 使配置生效
  [emon@emon ~]$ sudo sysctl -p
  ```

6. 配置启动

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/elasticsearch.ini
```

```ini
[program:es]
command=/usr/local/es/bin/elasticsearch
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
stdout_logfile=/etc/supervisor/supervisor.d/elasticsearch.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start es
```

7. 访问

http://192.168.3.116:9200

```json
{
    name: "master",
    cluster_name: "emon",
    cluster_uuid: "ZhvgqVsVRHCGSyzlg-HoXA",
    version: {
    number: "6.4.1",
    build_flavor: "default",
    build_type: "tar",
    build_hash: "e36acdb",
    build_date: "2018-09-13T22:18:07.696808Z",
    build_snapshot: false,
    lucene_version: "7.4.0",
    minimum_wire_compatibility_version: "5.6.0",
    minimum_index_compatibility_version: "5.0.0"
    },
    tagline: "You Know, for Search"
}
```

### 1.2、配置【二从之一】

1. 复制主节点

```shell
[emon@emon ~]$ cp -ra /usr/local/es/ /usr/local/ElasticStack/Elasticsearch/elasticsearch-6.4.1-slave1/
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Elasticsearch/elasticsearch-6.4.1-slave1/ /usr/local/es-slave1
# 清除主节点中运行产生的数据
[emon@emon ~]$ rm -rf /usr/local/es-slave1/data/
```

2. 配置

- 配置`elasticsearch.yml`文件

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es-slave1/config/elasticsearch.yml
```

```yaml
cluster.name: emon
node.name: slave1
network.host: 0.0.0.0
http.port: 9201
discovery.zen.ping.unicast.hosts: ["0.0.0.0"]
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es-slave1/config/jvm.options 
```

```
#-Xms1g
#-Xmx1g
-Xms256m
-Xmx256m
```

3. 配置启动

```
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/elasticsearch-slave1.ini 
```

```ini
[program:es-slave1]
command=/usr/local/es-slave1/bin/elasticsearch
autostart=false                 ; 在supervisord启动的时候也自动启动
startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3                  ; 启动失败自动重试次数，默认是3
user=emon                       ; 用哪个用户启动进程，默认是root
priority=71                     ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true            ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
environment=JAVA_HOME="/usr/local/java"
stdout_logfile=/etc/supervisor/supervisor.d/elasticsearch-slave1.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start es-slave1
```

4. 访问

http://192.168.3.116:8200

### 1.3、配置【二从之二】

1. 复制主节点

```shell
[emon@emon ~]$ cp -ra /usr/local/es/ /usr/local/ElasticStack/Elasticsearch/elasticsearch-6.4.1-slave2/
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Elasticsearch/elasticsearch-6.4.1-slave2/ /usr/local/es-slave2
# 清除主节点中运行产生的数据
[emon@emon ~]$ rm -rf /usr/local/es-slave2/data/
```

2. 配置

- 配置`elasticsearch.yml`文件

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es-slave2/config/elasticsearch.yml
```

```yaml
cluster.name: emon
node.name: slave2
network.host: 0.0.0.0
http.port: 9202
discovery.zen.ping.unicast.hosts: ["0.0.0.0"]
http.cors.enabled: true
http.cors.allow-origin: "*"
```

- 配置`jvm.options`

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es-slave2/config/jvm.options 
```

```
#-Xms1g
#-Xmx1g
-Xms256m
-Xmx256m
```

3. 配置启动

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/elasticsearch-slave2.ini 
```

```ini
[program:es-slave2]
command=/usr/local/es-slave2/bin/elasticsearch
autostart=false                 ; 在supervisord启动的时候也自动启动
startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3                  ; 启动失败自动重试次数，默认是3
user=emon                       ; 用哪个用户启动进程，默认是root
priority=72                     ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true            ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
environment=JAVA_HOME="/usr/local/java"
stdout_logfile=/etc/supervisor/supervisor.d/elasticsearch-slave2.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shel
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start es-slave2
```

4. 访问

http://192.168.3.116:7200

### 1.4、配置es启动组

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/es-group.ini
```

```ini
[group:es-group]
programs=es,es-slave1,es-slave2
priority=999
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl restart es-group:
```

### 1.5、es配套插件

#### 1.5.1、elasticsearch-head

1. 依赖安装

安装bzip2的解压工具：

```shell
[emon@emon ~]$ sudo yum install -y bzip2
```

该插件连接es，需要配置es的`elasticsearch.yml`追加如下：

```
# 追加
http.cors.enabled: true
http.cors.allow-origin: "*"
```

2. 下载安装与运行

```shell
[emon@emon ~]$ cd /usr/local/ElasticStack/ThirdPlugins/
[emon@emon ThirdPlugins]$ git clone git@github.com:mobz/elasticsearch-head.git
[emon@emon ThirdPlugins]$ cd elasticsearch-head/
[emon@emon elasticsearch-head]$ npm install
[emon@emon elasticsearch-head]$ npm start
```

3. 访问测试

http://192.168.3.116:9100

#### 1.5.2、cerebro插件

1. 下载安装与运行

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://github.com/lmenezes/cerebro/releases/download/v0.8.1/cerebro-0.8.1.tgz
[emon@emon ~]$ tar -zxvf /usr/local/src/cerebro-0.8.1.tgz -C /usr/local/ElasticStack/ThirdPlugins/
[emon@emon ~]$ ln -s /usr/local/ElasticStack/ThirdPlugins/cerebro-0.8.1/ /usr/local/cerebro
[emon@emon ~]$ /usr/local/cerebro/bin/cerebro
```

2. 访问测试

http://192.168.3.116:9000

3. 配置启动

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/cerebro.ini
```

```ini
[program:cerebro]
command=/usr/local/cerebro/bin/cerebro
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
stdout_logfile=/etc/supervisor/supervisor.d/cerebro.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start cerebro
```

## 2、Logstash

1. 下载

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/logstash/logstash-6.4.1.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/logstash-6.4.1.tar.gz -C /usr/local/ElasticStack/Logstash/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Logstash/logstash-6.4.1/ /usr/local/logstash
```

4. 配置

- 配置`logstash.yml`文件

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/logstash/config/logstash.yml 
```

```shell
http.host: "0.0.0.0"
```

- 配置`jvm.options`

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/logstash/config/jvm.options 
```

```
#-Xms1g
#-Xmx1g
-Xms256m
-Xmx256m
```

5. 准备一个`logstash.conf`配置文件

```
等待补充
```



## 3、Kibana

1. 下载

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/kibana/kibana-6.4.1-linux-x86_64.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/kibana-6.4.1-linux-x86_64.tar.gz -C /usr/local/ElasticStack/Kibana/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Kibana/kibana-6.4.1-linux-x86_64/ /usr/local/kibana
```

4. 配置`kibana.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/kibana/config/kibana.yml 
```

```yaml
server.host: 0.0.0.0
```

5. 配置启动

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/kibana.ini
```

```ini
[program:kibana]
command=/usr/local/kibana/bin/kibana
autostart=false                 ; 在supervisord启动的时候也自动启动
startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3                  ; 启动失败自动重试次数，默认是3
user=emon                       ; 用哪个用户启动进程，默认是root
priority=70                     ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true            ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
stdout_logfile=/etc/supervisor/supervisor.d/kibana.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目>录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start kibana
```

## 4、Beats

































