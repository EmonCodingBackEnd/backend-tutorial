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





### 1.2、配置【一从】

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

6. 命令使用详解

```bash
[saas@local-66 bin]$ ./logstash -h
Usage:
    bin/logstash [OPTIONS]

Options:
    -n, --node.name NAME          Specify the name of this logstash instance, if no value is given
                                  it will default to the current hostname.
                                   (default: "local-66")
    -f, --path.config CONFIG_PATH Load the logstash config from a specific file
                                  or directory.  If a directory is given, all
                                  files in that directory will be concatenated
                                  in lexicographical order and then parsed as a
                                  single config file. You can also specify
                                  wildcards (globs) and any matched files will
                                  be loaded in the order described above.
    -e, --config.string CONFIG_STRING Use the given string as the configuration
                                  data. Same syntax as the config file. If no
                                  input is specified, then the following is
                                  used as the default input:
                                  "input { stdin { type => stdin } }"
                                  and if no output is specified, then the
                                  following is used as the default output:
                                  "output { stdout { codec => rubydebug } }"
                                  If you wish to use both defaults, please use
                                  the empty string for the '-e' flag.
                                   (default: nil)
    --field-reference-parser MODE (DEPRECATED) This option is no longer
                                  configurable.
                                  
                                  Use the given MODE when parsing field
                                  references.
                                  
                                  The field reference parser is used to expand
                                  field references in your pipeline configs,
                                  and has become more strict to better handle
                                  ambiguous- and illegal-syntax inputs.
                                  
                                  The only available MODE is:
                                   - `STRICT`: parse in a strict manner; when
                                     given ambiguous- or illegal-syntax input,
                                     raises a runtime exception that should
                                     be handled by the calling plugin.
                                  
                                   (default: "STRICT")
    --modules MODULES             Load Logstash modules.
                                  Modules can be defined using multiple instances
                                  '--modules module1 --modules module2',
                                     or comma-separated syntax
                                  '--modules=module1,module2'
                                  Cannot be used in conjunction with '-e' or '-f'
                                  Use of '--modules' will override modules declared
                                  in the 'logstash.yml' file.
    -M, --modules.variable MODULES_VARIABLE Load variables for module template.
                                  Multiple instances of '-M' or
                                  '--modules.variable' are supported.
                                  Ignored if '--modules' flag is not used.
                                  Should be in the format of
                                  '-M "MODULE_NAME.var.PLUGIN_TYPE.PLUGIN_NAME.VARIABLE_NAME=VALUE"'
                                  as in
                                  '-M "example.var.filter.mutate.fieldname=fieldvalue"'
    --setup                       Load index template into Elasticsearch, and saved searches, 
                                  index-pattern, visualizations, and dashboards into Kibana when
                                  running modules.
                                   (default: false)
    --cloud.id CLOUD_ID           Sets the elasticsearch and kibana host settings for
                                  module connections in Elastic Cloud.
                                  Your Elastic Cloud User interface or the Cloud support
                                  team should provide this.
                                  Add an optional label prefix '<label>:' to help you
                                  identify multiple cloud.ids.
                                  e.g. 'staging:dXMtZWFzdC0xLmF3cy5mb3VuZC5pbyRub3RhcmVhbCRpZGVudGlmaWVy'
    --cloud.auth CLOUD_AUTH       Sets the elasticsearch and kibana username and password
                                  for module connections in Elastic Cloud
                                  e.g. 'username:<password>'
    --pipeline.id ID              Sets the ID of the pipeline.
                                   (default: "main")
    -w, --pipeline.workers COUNT  Sets the number of pipeline workers to run.
                                   (default: 24)
    --java-execution              Use Java execution engine.
                                   (default: true)
    --plugin-classloaders         (Beta) Load Java plugins in independent classloaders to isolate their dependencies.
                                   (default: false)
    -b, --pipeline.batch.size SIZE Size of batches the pipeline is to work in.
                                   (default: 125)
    -u, --pipeline.batch.delay DELAY_IN_MS When creating pipeline batches, how long to wait while polling
                                  for the next event.
                                   (default: 50)
    --pipeline.unsafe_shutdown    Force logstash to exit during shutdown even
                                  if there are still inflight events in memory.
                                  By default, logstash will refuse to quit until all
                                  received events have been pushed to the outputs.
                                   (default: false)
    --path.data PATH              This should point to a writable directory. Logstash
                                  will use this directory whenever it needs to store
                                  data. Plugins will also have access to this path.
                                   (default: "/usr/local/logstash/data")
    -p, --path.plugins PATH       A path of where to find plugins. This flag
                                  can be given multiple times to include
                                  multiple paths. Plugins are expected to be
                                  in a specific directory hierarchy:
                                  'PATH/logstash/TYPE/NAME.rb' where TYPE is
                                  'inputs' 'filters', 'outputs' or 'codecs'
                                  and NAME is the name of the plugin.
                                   (default: [])
    -l, --path.logs PATH          Write logstash internal logs to the given
                                  file. Without this flag, logstash will emit
                                  logs to standard output.
                                   (default: "/usr/local/logstash/logs")
    --log.level LEVEL             Set the log level for logstash. Possible values are:
                                    - fatal
                                    - error
                                    - warn
                                    - info
                                    - debug
                                    - trace
                                   (default: "info")
    --config.debug                Print the compiled config ruby code out as a debug log (you must also have --log.level=debug enabled).
                                  WARNING: This will include any 'password' options passed to plugin configs as plaintext, and may result
                                  in plaintext passwords appearing in your logs!
                                   (default: false)
    -i, --interactive SHELL       Drop to shell instead of running as normal.
                                  Valid shells are "irb" and "pry"
    -V, --version                 Emit the version of logstash and its friends,
                                  then exit.
    -t, --config.test_and_exit    Check configuration for valid syntax and then exit.
                                   (default: false)
    -r, --config.reload.automatic Monitor configuration changes and reload
                                  whenever it is changed.
                                  NOTE: use SIGHUP to manually reload the config
                                   (default: false)
    --config.reload.interval RELOAD_INTERVAL How frequently to poll the configuration location
                                  for changes, in seconds.
                                   (default: 3000000000)
    --http.host HTTP_HOST         Web API binding host (default: "127.0.0.1")
    --http.port HTTP_PORT         Web API http port (default: 9600..9700)
    --log.format FORMAT           Specify if Logstash should write its own logs in JSON form (one
                                  event per line) or in plain text (using Ruby's Object#inspect)
                                   (default: "plain")
    --path.settings SETTINGS_DIR  Directory containing logstash.yml file. This can also be
                                  set through the LS_SETTINGS_DIR environment variable.
                                   (default: "/usr/local/logstash/config")
    --verbose                     Set the log level to info.
                                  DEPRECATED: use --log.level=info instead.
    --debug                       Set the log level to debug.
                                  DEPRECATED: use --log.level=debug instead.
    --quiet                       Set the log level to info.
                                  DEPRECATED: use --log.level=info instead.
    -h, --help                    print help
```

7. 几个实例

- 准备一个`logstash-simple.conf`配置文件

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

- 准备一个`mysql.conf`配置文件【一个接近实战的例子】

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

1. 下载

```bash
[saas@local-66 ~]$ wget -cP /usr/local/src/ https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.2-linux-x86_64.tar.gz
```

2. 解压安装

```bash
[saas@local-66 ~]$ tar -zxvf /usr/local/src/filebeat-7.6.2-linux-x86_64.tar.gz -C /usr/local/ElasticStack/Beats/
```

3. 创建软连接

```bash
[saas@local-66 ~]$ ln -s /usr/local/ElasticStack/Beats/filebeat-7.6.2-linux-x86_64/ /usr/local/filebeat
```

4. 配置文件

`/usr/local/filebeat/filebeat.reference.yml` 包含所有未过时的配置项

`/usr/local/filebeat/filebeat.yml` 配置文件

filebeat命令需要在根目录下执行，所以先切换到根目录下：

```bash
[saas@local-66 ~]$ cd /usr/local/filebeat/
```

- 如何使用`filebeat`命令

```bash
[saas@local-66 filebeat]$ ./filebeat -h
```

```bash
Usage:
  filebeat [flags]
  filebeat [command]

Available Commands:
  enroll      Enroll in Kibana for Central Management                  	
  export      Export current config or index template					# 导出
  generate    Generate Filebeat modules, filesets and fields.yml
  help        Help about any command
  keystore    Manage secrets keystore									# 秘钥存储
  modules     Manage configured modules									# 模块配置管理
  run         Run filebeat												# 执行（默认执行）
  setup       Setup index template, dashboards and ML jobs				# 设置初始环境
  test        Test config												# 测算配置
  version     Show current version info
```

- 如何使用`file beat [command]子命令

```bash
# 查看使用方法： filebeat [command] -h，比如：
[saas@local-66 filebeat]$ ./filebeat modules -h
```

- 如何测算配置文件是否正确：

```bash
[saas@local-66 filebeat]$ ./filebeat test config
```

- 如何测算配置文件是否可以连通到output

```bash
[saas@local-66 filebeat]$ ./filebeat test output
```

- 配置`filebeat.yml`文件，log输入类型为例

```bash
# 备份
[saas@local-66 ~]$ cp /usr/local/filebeat/filebeat.yml /usr/local/filebeat/filebeat.yml.bak
# 编辑
[saas@local-66 ~]$ vim /usr/local/filebeat/filebeat.yml 
```

5. 几个实例

- 实例一：logstash作为输出
  - 配置logstash

  ```bash
  # 创建目录
  [saas@local-66 ~]$ mkdir -pv /usr/local/logstash/config/custom_config/filebeats_config/
  # 编辑文件
  [saas@local-66 ~]$ vim /usr/local/logstash/config/custom_config/filebeats_config/filebeats.conf 
  ```

  ```bash
  input {
    beats {
      port => 5044
    }
  }
  filter {
    grok {
      patterns_dir => ["/usr/local/logstash/config/custom_config/hbsite/patterns"]
      match => {
        "message" => "%{CDATE:date} \[%{CTID:tid}]  %{CLEVEL:level} %{CPID:pid} --- \[%{CTHREAD:thread}"
      }
    }
}
  output {
    elasticsearch {
      hosts => ["http://192.168.1.66:9200"]
      index => "hbsite-log-%{+YYYY.MM.dd}"
  }
  }
  ```
  
```bash
  # 执行配置文件
  [saas@local-66 ~]$ /usr/local/logstash/bin/logstash -f /usr/local/logstash/config/custom_config/filebeats_config/filebeats.conf
  ```
  
  ```bash
  # 配置supervisor启动
  ```
  
  ```bash
  [program:huiba-site-logstash]
  command=/usr/local/logstash/bin/logstash -f /usr/local/logstash/config/custom_config/hbsite/hbsite_log.conf
  autostart=false                 ; 在supervisord启动的时候也自动启动
  startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
  autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
  startretries=3                  ; 启动失败自动重试次数，默认是3
  user=saas                       ; 用哪个用户启动进程，默认是root
  priority=70                     ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true            ; 把stderr重定向到stdout，默认false
  stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
  environment=JAVA_HOME="/usr/local/java"
  stdout_logfile=/etc/program/huiba-site-logstash.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
  stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
  killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
```
  
  - 配置filebeat
  
  ```bash
  # 编辑配置文件
  [saas@local-66 ~]$ vim /usr/local/filebeat/filebeat.yml
  ```
  
  ```yml
  filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /home/saas/huiba/site/huiba-site-server/logs/huiba-site-provider.log
    # 表示过滤掉包含 TID:N/A 的行
    exclude_lines: ['TID:N/A']
    fields:
      appName: huiba-site-provider
    fields_under_root: true
    # multiline开头的3个配置表示：匹配 yyyy-MM-dd HH:mm:ss 开头的日志，作为独立成行的标志；该标志后面的行要和该行合并处理
    multiline.pattern: ^((([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29))\s+([0-1]?[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])
    multiline.negate: true
    multiline.match: after
    close_inactive: 2m
  filebeat.config.modules:
    path: ${path.config}/modules.d/*.yml
  reload.enabled: false
  setup.template.settings:
    index.number_of_shards: 1
  setup.kibana:
  output.logstash:
  hosts: ["localhost:5044"]
  processors:
    - add_host_metadata: ~
    - add_cloud_metadata: ~
    - add_docker_metadata: ~
    - add_kubernetes_metadata: ~
  ```
  
  ```bash
  # 执行配置文件，注意--path.config和-c参数的不同之处
  [saas@local-66 ~]$ /usr/local/filebeat/filebea --path.config /usr/local/filebeat -e
  ```
  
  ```bash
  [program:huiba-site-filebeat]
  command=/usr/local/filebeat/filebeat -c /usr/local/filebeat/filebeat.yml -e
  autostart=false                 ; 在supervisord启动的时候也自动启动
startsecs=10                    ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
  autorestart=true                ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
  startretries=3                  ; 启动失败自动重试次数，默认是3
  user=saas                       ; 用哪个用户启动进程，默认是root
  priority=70                     ; 进程启动优先级，默认999，值小的优先启动
  redirect_stderr=true            ; 把stderr重定向到stdout，默认false
  stdout_logfile_maxbytes=20MB    ; stdout 日志文件大小，默认50MB
  stdout_logfile_backups = 20     ; stdout 日志文件备份数，默认是10
  stdout_logfile=/etc/program/huiba-site-filebeat.log ; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动>创建目录（supervisord 会自动创建日志文件）
  stopasgroup=true                ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
  killasgroup=true                ;默认为false，向进程组发送kill信号，包括子进程
  ```
  
  























