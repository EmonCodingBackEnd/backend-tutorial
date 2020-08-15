# ElasticStack实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装之前

## 1、目录规划

| 模块          | 安装目录                              | 软连接              |
| ------------- | ------------------------------------- | ------------------- |
| Elasticsearch | /usr/local/ElasticStack/Elasticsearch | /usr/local/es       |
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
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-linux-x86_64.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/elasticsearch-7.6.2-linux-x86_64.tar.gz -C /usr/local/ElasticStack/Elasticsearch/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Elasticsearch/elasticsearch-7.6.2/ /usr/local/es
```

4. 配置

- 配置`elasticsearch.yml`文件

```shell
# 打开文件并追加
[emon@emon ~]$ vim /usr/local/es/config/elasticsearch.yml 
```

```yaml
cluster.name: es-cluster
node.name: master
# 表示该节点具有成为master的权利，但不一定就是master
node.master: true
# 表示该节点不存储数据
node.data: false
path.data: /usr/local/es/data
path.logs: /usr/local/es/logs
network.host: 0.0.0.0
# 指定所有想加入集群的地址
discovery.seed_hosts: ["127.0.0.1:9300", "127.0.0.1:9301"]
# 指定可以成为master的所有节点的name或者ip
cluster.initial_master_nodes: ["master"]


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

  - 修改前查看

  ```shell
  [emon@emon ~]$ ulimit -Sn
  1024
  [emon@emon ~]$ ulimit -Hn
  4096
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

  - 修改后查看

  ```
  [emon@emon ~]$ ulimit -Sn
  1024
  [emon@emon ~]$ ulimit -Hn
  65536
  ```

- 问题二

  - 问题描述

  ```
  [2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
  ```

  - 解决办法

  ```shell
  # 查看
  [emon@emon ~]$ sudo sysctl -a|grep vm.max_map_count
  vm.max_map_count = 65530
  # 打开文件并追加
  [emon@emon ~]$ sudo vim /etc/sysctl.conf 
  ```
```
  vm.max_map_count=655360
```
```bash
# 使配置生效
[emon@emon ~]$ sudo sysctl -p
vm.max_map_count = 655360
```

6. 配置启动

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisor.d/es.ini
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
stdout_logfile=/etc/supervisor/supervisor.d/es.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```

```shell
[emon@emon ~]$ sudo supervisorctl update
[emon@emon ~]$ sudo supervisorctl start es
```

- **supervisor启动时的问题**

在shell中执行命令可以启动了，但supervisor还是无法启动，报错：

```
020-04-30T15:53:15,294][ERROR][o.e.b.Bootstrap          ] [master] node validation exception
[1] bootstrap checks failed
[1]: max file descriptors [4096] for elasticsearch process is too low, increase to at least [65535]
```

因为supervisor中默认的打开的文件句柄的数量太少，看错误应该是能打开4096，但是一些资料上说是1024。

打开supervisor配置文件：

```shell
[emon@emon ~]$ sudo vim /etc/supervisor/supervisord.conf 
```

找到`[supervisord]`下面的`minfds=1024`修改。

```bash
minfds=1024                  ; min. avail startup file descriptors; default 1024
```

=>

```bash
;minfds=1024                  ; min. avail startup file descriptors; default 1024
minfds=65535                  ; min. avail startup file descriptors; default 1024
```

重启`supervisord`服务：

```
[emon@emon ~]$ sudo systemctl restart supervisord.service
```

再次启动`supervisor es`服务：

```bash
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

8. 相关命令

- 查看当前进程的最大可打开文件数和进程数等

```bash
cat /proc/<进程ID>/limits
比如：
[emon@emon ~]$ cat /proc/55756/limits
```

- 查看当前进程实时打开的文件数

```bash
lsof -p <PID> | wc -l
比如：
[emon@emon ~]$ lsof -p 55756 | wc -l
478
```

- 查看系统总限制打开文件的最大数量

```bash
[emon@emon ~]$ cat /proc/sys/fs/file-max
488387
```





### 1.2、配置【二从之一】

1. 复制主节点

```shell
[emon@emon ~]$ cp -ra /usr/local/es/ /usr/local/ElasticStack/Elasticsearch/elasticsearch-7.4.2-slave1/
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Elasticsearch/elasticsearch-7.6.2-slave1/ /usr/local/es-slave1
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
cluster.name: es-cluster
node.name: slave
# 表示该节点具有成为master的权利，但不一定就是master
node.master: false
# 表示该节点不存储数据
node.data: true
path.data: /usr/local/es-slave/data
path.logs: /usr/local/es-slave/logs
network.host: 0.0.0.0
# es服务端口
http.port: 9201
# 内部节点之间沟通端口
transport.tcp.port: 9301
# 指定所有想加入集群的地址
discovery.seed_hosts: ["127.0.0.1:9301", "127.0.0.1:9300"]
# 指定可以成为master的所有节点的name或者ip
cluster.initial_master_nodes: ["master"]


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

http://192.168.3.116:9201

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

[elasticsearch-head](https://github.com/mobz/elasticsearch-head)

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
[emon@emon ThirdPlugins]$ git clone git://github.com/mobz/elasticsearch-head.git
[emon@emon ThirdPlugins]$ cd elasticsearch-head/
[emon@emon elasticsearch-head]$ npm install
[emon@emon elasticsearch-head]$ npm start
[emon@emon elasticsearch-head]$ pwd
/usr/local/ElasticStack/ThirdPlugins/elasticsearch-head
```

3. 访问测试

http://192.168.3.116:9100

4. 更好的启动

使用`npm start`会阻塞运行，如果想要长期运行，需要如下方式：

- 安装`grunt`

```bash
# 在目录 /usr/local/ElasticStack/ThirdPlugins/elasticsearch-head 下
[emon@emon elasticsearch-head]$ npm install -g grunt-cli
[emon@emon elasticsearch-head]$ npm ls -g --depth=0|grep grunt
├── grunt-cli@1.3.2
```

- 编写脚本

```bash
[emon@emon elasticsearch-head]$ vim startup.sh
nohup grunt server &
[emon@emon elasticsearch-head]$ chmod u+x startup.sh
```

- 启动

```bash
[emon@emon elasticsearch-head]$ ./startup.sh
```



#### 1.5.2、cerebro插件

[插件cerebro](https://github.com/lmenezes/cerebro/tags)

1. 下载安装与运行

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://github.com/lmenezes/cerebro/releases/download/v0.9.2/cerebro-0.9.2.tgz
[emon@emon ~]$ tar -zxvf /usr/local/src/cerebro-0.9.2.tgz -C /usr/local/ElasticStack/ThirdPlugins/
[emon@emon ~]$ ln -s /usr/local/ElasticStack/ThirdPlugins/cerebro-0.9.2/ /usr/local/cerebro
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

### 1.6、ES插件安装

查看安装了哪些es插件：

```bash
[emon@emon bin]$ /usr/local/es/bin/elasticsearch-plugin list --verbose
```

#### 1.6.1、ik分词插件

1. 插件地址： [ik分词插件github地址](https://github.com/medcl/elasticsearch-analysis-ik)
2. 安装

```bash
[emon@emon ~]$ sudo /usr/local/es/bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.6.2/elasticsearch-analysis-ik-7.6.2.zip
```

**说明：**如果您正在使用 Elasticsearch 的DEB / RPM分发，请以超级用户权限运行安装；否则可能会碰到错误：

```bash
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@     WARNING: plugin requires additional permissions     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
```

导致安装失败，加上sudo适用root安装即可。另外，安装后需要**重启**。

### 1.7、X-Pack

X-Pack是`Elastic Stack`的一个扩展，提供了安全性、警报、监视、报告、机器学习和许多其他功能。默认情况下，当你安装Elasticsearch后，X-Pack也安装了。

## 2、Logstash

### 1.1 安装与配置

1. 下载

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/logstash/logstash-7.6.2.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/logstash-7.6.2.tar.gz -C /usr/local/ElasticStack/Logstash/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Logstash/logstash-7.6.2/ /usr/local/logstash
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

5. 测试安装是否成功

```bash
[emon@emon ~]$ /usr/local/logstash/bin/logstash -e 'input { stdin { } } output { stdout {} }'
```

**说明：** `-e`参数启用命令行模式。

看到如下输出表示成功：

```
[2020-08-07T14:40:35,609][INFO ][logstash.javapipeline    ][main] Starting pipeline {:pipeline_id=>"main", "pipeline.workers"=>8, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>50, "pipeline.max_inflight"=>1000, "pipeline.sources"=>["config string"], :thread=>"#<Thread:0x2d2eec91 run>"}
[2020-08-07T14:40:36,706][INFO ][logstash.javapipeline    ][main] Pipeline started {"pipeline.id"=>"main"}
The stdin plugin is now waiting for input:
[2020-08-07T14:40:36,760][INFO ][logstash.agent           ] Pipelines running {:count=>1, :running_pipelines=>[:main], :non_running_pipelines=>[]}
[2020-08-07T14:40:37,076][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
```

在打开的命令行下随便输入内容，比如：

```bash
hello world
```

会输出如下：

```bash
{
      "@version" => "1",
          "host" => "localhost.localdomain",
    "@timestamp" => 2020-08-07T06:53:47.828Z,
       "message" => "hello world"
}
```



5. 准备一个`logstash-simple.conf`配置文件

```
[emon@emon ~]$ vim /usr/local/logstash/config/logstash-simple.conf
```

```
input { stdin { } }
output {
  elasticsearch { hosts => ["localhost:9200"] }
  stdout { codec => rubydebug }
}
```

执行命令测试：

```bash
[emon@emon ~]$ /usr/local/logstash/bin/logstash -f /usr/local/logstash/config/logstash-simple.conf 
```

可以在控制台命令行输入消息，会被传递到es服务器。

6. 准备一个`mysql.conf`配置文件【一个接近实战的例子】

```bash
# 上传mysql驱动jar到该目录下，比如mysql-connector-java-5.1.41.jar
[emon@emon ~]$ mkdir -pv /usr/local/logstash/config/custom_config/mysql_config
```

```bash
# 编辑goods.config
[emon@emon ~]$ vim /usr/local/logstash/config/custom_config/mysql_config/goods.conf 
```

```bash
input {
    stdin {}
    jdbc {
        # 驱动jar包位置
        jdbc_driver_library => "/usr/local/logstash/config/custom_config/mysql_config/mysql-connector-java-5.1.41.jar"
        # 驱动类
        jdbc_driver_class => "com.mysql.jdbc.Driver"
        jdbc_paging_enabled => "true"
        jdbc_page_size => "50000"
        # 数据库
        jdbc_connection_string => "jdbc:mysql://192.168.1.52:3306/hbsitedb-test?useSSL=false"
        # 用户名密码
        jdbc_user => "jpss"
        jdbc_password => "Jpss541018!"
        # 是否开启记录追踪
        record_last_run => "true"
        plugin_timezone => "local"
        # 是否需要追踪字段，如果为true，则需要制定tracking_column，默认是timestamp
        use_column_value => "true"
        # 指定追踪的字段
        tracking_column => "modify_time"
        # 追踪字段的类型，目前只有数字和时间类型，默认是数字类型
        tracking_column_type => "timestamp"
        # 执行
        last_run_metadata_path => "/usr/local/logstash/config/custom_config/mysql_config/last_run_metadata_path"
        schedule => "* * * * *"
        statement_filepath => "/usr/local/logstash/config/custom_config/mysql_config/goods.sql"
    }
}
filter {
    json {
        source => "message"
        remove_field => ["message"]
    }
}
output {
    elasticsearch {
        hosts => "192.168.1.56:9200"
        index => "logstash-es-goods-%{+YYYY.MM.dd}"
        # 需要关联的数据库中有一个id字段，对应索引的id号
        document_id => "%{id}"
    }
    stdout {
        codec => json_lines
    }
}
```

```bash
# 编辑goods.sql文件
[emon@emon ~]$ vim /usr/local/logstash/config/custom_config/mysql_config/goods.sql
```

```sql
select sku.id, spu.id spu_id, spu.tenant_id , spu.shop_id , spu.cover , spu.imgs , spu.spu_name , sku.price , sku.spread_price , spu.sale_start_time ,spu.sale_end_time, spu.modify_time
from goods_sku sku
left join goods_spu spu
on spu.id=sku.spu_id
where spu.modify_time > :sql_last_value
```



执行配置文件：

```bash
[emon@emon ~]$ /usr/local/logstash/bin/logstash -f /usr/local/logstash/config/custom_config/mysql_config/goods.conf
```



### 1.2 安装插件

查看安装了哪些logstash插件：

```bash
[emon@emon ~]$ /usr/local/logstash/bin/logstash-plugin list --verbose
```

### 1.2.1、查看是否安装了`logstash-integration-jdbc`插件

```bash
[saas@localhost ~]$ /usr/local/logstash/bin/logstash-plugin list --verbose|grep jdbc
logstash-integration-jdbc (5.0.1)
 ├── logstash-input-jdbc
 ├── logstash-filter-jdbc_streaming
 └── logstash-filter-jdbc_static
```

发现已经安装了`logstash-integration-jdbc`插件。



#### 1.2.x logstash-integration-jdbc【已废弃】

- logstash插件地址：https://github.com/logstash-plugins
- logstash-integration-jdbc插件地址：https://github.com/logstash-plugins/logstash-integration-jdbc

1. 安装`gem`

由于插件是基于ruby语言开发，需要安装Ruby包管理器`RubyGems`。

```bash
[saas@localhost ~]$ sudo yum install gem
```

`gem`命令用于构建、上传、下载以及安装Gem包。`gem`的用法在功能上与`apt-get`、`yum`和`npm`非常相似。

| 命令                       | 说明                     |
| -------------------------- | ------------------------ |
| gem install mygem          | 安装                     |
| gem uninstal mygem         | 卸载                     |
| gem list --local           | 列出已安装的gem          |
| gem list --remote          | 列出可用的gem            |
| gem rdoc --all             | 为所有的gems创建RDoc文档 |
| gem fetch mygem            | 下载gem，但不安装        |
| gem search STRING --remote | 从可用的gem中搜索        |
| gem sources -l             | 查看当前源               |

2. 配置`gem`镜像

由于国内网络，导致`rubygems.org`存放在Amazon S3上面的资源文件间歇性的链接失败。所以你会遇到`gem install rack`或者`bundle install`的时候半天没有响应，具体可用`gem install rails -V`来查看执行过程。

- 查看`gem`源

```bash
[emon@emon ~]$ gem sources -l
*** CURRENT SOURCES ***

https://rubygems.org/
```

- 移除`https://rubygems.org/`并添加国内下载源`https://gems.ruby-china.com/`

```bash
[emon@emon ~]$ gem sources --remove https://rubygems.org/
https://rubygems.org/ removed from sources
[emon@emon ~]$ gem sources -a https://gems.ruby-china.com/
https://gems.ruby-china.com/ added to sources
```

如果你使用`Gemfile`和`Bundle`（例如：Rails项目）

你可以使用`bundle`的`gem`源代码镜像命令。

```bash
bundle config mirror.https://rubygems.org https://gems.ruby-china.com/
```



## 3、Kibana

1. 下载

```shell
[emon@emon ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/kibana/kibana-7.6.2-linux-x86_64.tar.gz
```

2. 解压安装

```shell
[emon@emon ~]$ tar -zxvf /usr/local/src/kibana-7.6.2-linux-x86_64.tar.gz -C /usr/local/ElasticStack/Kibana/
```

3. 创建软连接

```shell
[emon@emon ~]$ ln -s /usr/local/ElasticStack/Kibana/kibana-7.6.2-linux-x86_64/ /usr/local/kibana
```

4. 配置`kibana.yml`文件

```shell
[emon@emon ~]$ vim /usr/local/kibana/config/kibana.yml 
```

```yaml
server.host: 0.0.0.0
```

5. 解决启动问题

- 问题一

  - 问题描述

  ```bash
  [warning][config][encryptedSavedObjects][plugins] Generating a random key for xpack.encryptedSavedObjects.encryptionKey
  ```

  - 解决办法

  ```bash
  # 打开文件并追加，注意值不小于32位长度
  # vim /usr/local/kibana/config/kibana.yml
  xpack.encryptedSavedObjects.encryptionKey: encryptedSavedObjects12345678909876543210
  ```

- 问题二

  - 问题描述

  ```bash
  [warning][config][plugins][security] Generating a random key for xpack.security.encryptionKey
  ```

  - 解决办法

  ```bash
  # 打开文件并追加，注意值不小于32位长度
  # vim /usr/local/kibana/config/kibana.yml
  xpack.security.encryptionKey: encryptionKeysecurity12345678909876543210
  ```

- 问题三

  - 问题描述

  ```bash
  [warning][reporting] Generating a random key for xpack.reporting.encryptionKey. To prevent pending reports from failing on restart, please set xpack.reporting.encryptionKey in kibana.yml
  ```

  - 解决办法

  ```bash
  # 打开文件并追加，注意值不小于32位长度
  # vim /usr/local/kibana/config/kibana.yml
  xpack.reporting.encryptionKey: encryptionKeyreporting12345678909876543210
  ```

- 问题四

  - 问题描述

  ```bash
  [warning][savedobjects-service] Unable to connect to Elasticsearch. Error: [validation_exception] Validation Failed: 1: this action would add [2] total shards, but this cluster currently has [999]/[1000] maximum shards open;
  ```

  - 解决办法1

  ```bash
  # 打开es的配置文件
  # vim /usr/local/es/config/elasticsearch.yml
  cluster.max_shards_per_node: 1500
  ```

  - 解决办法2

  ```bash
  # 执行shell命令
  curl -X PUT "192.168.1.107:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
  {
      "persistent" : {
          "cluster.max_shards_per_node" : "10000"
      }
  }
  '
  ```

  - 解决办法3

  ```bash
  PUT /_cluster/settings
  {
    "persistent": {
      "cluster": {
        "max_shards_per_node":10000
      }
    }
  }
  ```

  **说明**：persistent:永久生效，transient：临时生效

- 优化实践

```
如果现在你的场景是分片数不合适了，但是又不知道如何调整，那么有一个好的解决方法就是按照时间创建索引，然后进行通配查询。如果每天的数据量很大，则可以按天创建索引，如果是一个月积累起来导致数据量很大，则可以一个月创建一个索引。如果要对现有索引进行重新分片，则需要重建索引。

对于分片数的大小，业界一致认为分片数的多少与内存挂钩，认为 1GB 堆内存对应 20-25 个分片。因此，具有30GB堆的节点最多应有600个分片，但是越低于此限制，您可以使其越好。而一个分片的大小不要超过50G，通常，这将有助于群集保持良好的运行状况。
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

**说明：**如果碰到启动失败，一直解决不了，可以使用root用户启动，并在command后追加`--allow-root`即可。

6. 访问

http://192.168.3.116:5601



## 4、Beats

































