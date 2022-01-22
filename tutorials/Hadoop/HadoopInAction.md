# Hadoop实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、HDFS命令

# 二、HDFS详解

## 2.1、HDFS体系结构分析

![image-20220121144248315](images/image-20220121144248315.png)

HDFS支持主从结构，主节点称为 NameNode，是因为主节点上运行的有NameNode进程，NameNode支持多个。

从节点称为DataNode，是因为从节点上面运行的有DataNode进程，DataNode支持多个。

HDFS中还包含一个SecondaryNameNode进程，这个进程从字面意思上看像是第二个NameNode的意思，但并不是。

简单理解如下：

公司BOSS：NameNode

秘书：SecondaryNameNode

员工：DataNode

### 2.1.1、NameNode介绍

NameNode是整个文件系统的管理节点。

它主要维护着整个文件系统的文件目录树，`文件/目录的信息`和`每个文件对应的数据块列表`，并且还负责接收用户的操作请求。

- 文件/目录的信息：表示文件/目录的一些基本信息，所有者 属组 修改时间 文件大小等信息。
- 每个文件对应的数据块列表：如果一个文件太大，那么在集群中存储的时候会对文件进行切割，这个时候就类似于会给文件分成一块一块的，存储到不同机器上面。所以HDFS还要记录一下一个文件到底被分了多少块，每一块都在什么地方存储着。

### 2.1.2、NameNode包含的文件

NameNode主要包括以下文件：

- edits：操作日志文件【事务文件】，这里面会实时记录用户的所有操作。

- fsimage

  - >元数据镜像文件，存储某一时刻NameNode内存中的元数据信息，就类似是定时做了一个快照操作。
    >
    >【这里的元数据信息是指文件目录树、文件/目录的信息、每个文件对应的数据块列表】

- seed_txid

  - > 是存放transactionId的文件，format之后是0，它代表的是namenode里面的edits_*文件的尾数，namenode重启的时候会按照seen_txid的数字，顺序从头跑edits_0000001~到seen_txid的数字。如果根据对应的seen_txid无法加载到对应的文件，NameNode进行将不会完成启动以保护数据一致性。

- VERSION：保存了集群的版本信息

以上这些文件的存储路径是由hdfs-default.xml中的`dfs.namenode.name.dir`属性控制的，hdfs.default.xml在`${HADOOP_HOME}/share/hadoop/hdfs/hadoop-hdfs-3.3.1.jar`这个jar包中。该文件包含了HDFS相关的所有默认参数，这些默认参数可以被`hdfs-site.xml`配置文件覆盖同名参数。

最终，存储路径的值是：`${hadoop.tmp.dir}/dfs/name`

进入该目录：

```bash
[emon@emon ~]$ cd /usr/local/hadoop/tmp/dfs/name
[emon@emon name]$ ls
current  in_use.lock
[emon@emon name]$ cd current
```

`in_use.lock`在namenode启动后产生的，停止后会删除该文件。表示锁定！

```bash
[emon@emon name]$ ll current/
总用量 3140
-rw-rw-r--. 1 emon emon      42 1月  18 18:31 edits_0000000000000000001-0000000000000000002
-rw-rw-r--. 1 emon emon      42 1月  20 10:31 edits_0000000000000000003-0000000000000000004
-rw-rw-r--. 1 emon emon 1048576 1月  20 10:31 edits_0000000000000000005-0000000000000000005
-rw-rw-r--. 1 emon emon      42 1月  20 11:19 edits_0000000000000000006-0000000000000000007
-rw-rw-r--. 1 emon emon 1048576 1月  20 11:19 edits_0000000000000000008-0000000000000000008
-rw-rw-r--. 1 emon emon      42 1月  20 17:52 edits_0000000000000000009-0000000000000000010
-rw-rw-r--. 1 emon emon     530 1月  21 09:55 edits_0000000000000000011-0000000000000000018
-rw-rw-r--. 1 emon emon     695 1月  21 10:55 edits_0000000000000000019-0000000000000000028
-rw-rw-r--. 1 emon emon    3934 1月  21 11:55 edits_0000000000000000029-0000000000000000077
-rw-rw-r--. 1 emon emon      42 1月  21 12:55 edits_0000000000000000078-0000000000000000079
-rw-rw-r--. 1 emon emon    3048 1月  21 13:55 edits_0000000000000000080-0000000000000000117
-rw-rw-r--. 1 emon emon      88 1月  21 14:55 edits_0000000000000000118-0000000000000000120
-rw-rw-r--. 1 emon emon 1048576 1月  21 14:55 edits_inprogress_0000000000000000121
-rw-rw-r--. 1 emon emon     689 1月  21 13:55 fsimage_0000000000000000117
-rw-rw-r--. 1 emon emon      62 1月  21 13:55 fsimage_0000000000000000117.md5
-rw-rw-r--. 1 emon emon     689 1月  21 14:55 fsimage_0000000000000000120
-rw-rw-r--. 1 emon emon      62 1月  21 14:55 fsimage_0000000000000000120.md5
-rw-rw-r--. 1 emon emon       4 1月  21 14:55 seen_txid
-rw-rw-r--. 1 emon emon     214 1月  20 17:50 VERSION
```

如何查看fsimage文件？

```bash
# 转换到xml文件查看
[emon@emon current]$ hdfs oiv -p XML -i fsimage_0000000000000000117 -o fsimage117.xml
```

如何查看edits文件？

```bash
# 转换到xml文件查看
[emon@emon current]$ hdfs oev -i edits_0000000000000000001-0000000000000000002 -o edits.xml
```

### 2.1.3、SecondaryNameNode

- SecondaryNameNode主要负责定期的把edits文件中的内容合并到fsimage中。
- 这个合并操作成为checkpoint，在合并的时候会对edits中的内容进行转换，生成新的内容保存到fsimage文件中。

注意：NameNode的HA架构中没有SecondaryNameNode进程，文件合并操作会由standby NameNode负责实现，所以在Hadoop集群中，SecondaryNameNode进行并不是必须的。

所以，在2.X版本SecondaryNameNode是必须的，但3.X的版本不是必须的了。

### 2.1.4、DataNode介绍

- 提供真实文件数据的存储服务。
- HDFS会按照固定的大小，顺序对文件进行划分并编号，划分好的每一个块称一个Block，HDFS默认Block大小是128MB。
- Block块是HDFS读写数据的基本单位，不管你的文件是文本文件，还是视频或者音频文件，对HDFS而言都是字节。

### 2.1.5、DataNode包含的文件

DataNode需要关注的文件有如下：

- blk

  - > 位置：/usr/local/hadoop/tmp/dfs/data/current/BP-823583849-10.0.0.116-1642501231529/current/finalized/subdir0/subdir0

- VERSION

和NameNode一样，DataNode的存储目录也可以在`hdfs-site.xml`配置文件覆盖`hdfs.default.xml`中的同名参数。

最终路径是：`${hadoop.tmp.dir}/dfs/data`

```bash
[emon@emon ~]$ cd /usr/local/hadoop/tmp/dfs/data/
[emon@emon data]$ ls
current  in_use.lock
[emon@emon data]$ cd current/
[emon@emon current]$ ls
BP-823583849-10.0.0.116-1642501231529  VERSION
[emon@emon current]$ cd BP-823583849-10.0.0.116-1642501231529/current/finalized/subdir0/subdir0/
[emon@emon subdir0]$ pwd
# 命令行输出信息
/usr/local/hadoop/tmp/dfs/data/current/BP-823583849-10.0.0.116-1642501231529/current/finalized/subdir0/subdir0
```

`in_use.lock`在datanode启动后产生的，停止后会删除该文件。表示锁定！

```bash
[emon@emon subdir0]$ ll
总用量 16
-rw-rw-r--. 1 emon emon 175 1月  20 18:04 blk_1073741825
-rw-rw-r--. 1 emon emon  11 1月  20 18:04 blk_1073741825_1001.meta
-rw-rw-r--. 1 emon emon  22 1月  21 22:17 blk_1073741843
-rw-rw-r--. 1 emon emon  11 1月  21 22:17 blk_1073741843_1019.meta
```

这里面有很多block块，具体块对应的文件信息，可以查看：http://emon:9870 ==> Utilities ==> Browse the file system ==> 点击具体文件查看块的信息！

![image-20220121222710554](images/image-20220121222710554.png)

> 注意：这里的.meta文件也是做校验用的。

在块目录下，blk文件可直接查看内容：

```bash
[emon@emon subdir0]$ cat blk_1073741825
For the latest information about Hadoop, please visit our website at:

   http://hadoop.apache.org/

and our wiki, at:

   https://cwiki.apache.org/confluence/display/HADOOP/
```

> 注意：这个block中的文件内容可能只是一个文件的一部分，如果你的文件较大，就会分为多个block存储，默认一个hadoop3中一个block的大小为128M。根据字节进行截取，截取到的128M就是一个block。如果文件大小没默认的block块大那最终就只有一个block。

HDFS中，如果一个文件小于一个数据块的大小，那么并不会占用整个数据块的存储空间。

![image-20220121223458199](images/image-20220121223458199.png)

Size是实际大小，Block Size是文件的最大块的大小。

另外，在DataNode的数据目录下面的current目录中有一个VERSION文件。这个文件和NameNode里面的VERSION文件相似，对比如下：
**NameNode下的VERSION文件**：

```bash
[emon@emon ~]$ cat /usr/local/hadoop/tmp/dfs/name/current/VERSION 
#Sat Jan 22 09:27:01 CST 2022
namespaceID=1685831230
clusterID=CID-8368f407-a3a6-4d9e-86eb-ed62198078e6
cTime=1642501231529
storageType=NAME_NODE
blockpoolID=BP-823583849-10.0.0.116-1642501231529
layoutVersion=-66
```

**DataNode下的VERSION文件**：

```bash
[emon@emon ~]$ cat /usr/local/hadoop/tmp/dfs/data/current/VERSION 
#Sat Jan 22 09:27:04 CST 2022
storageID=DS-5ec2332c-eff2-4ead-8f36-0aaa5a01a31e
clusterID=CID-8368f407-a3a6-4d9e-86eb-ed62198078e6
cTime=0
datanodeUuid=dd05c2ac-6668-4317-8d72-15551cf97d98
storageType=DATA_NODE
layoutVersion=-57
```

所以，NameNode不要随便格式化，因为格式化了以后VERSION里面的clusterID会变化，但是datanode的VERSION中的clusterID并不会变化，就匹配不上了。

**重点**：如果要重新格式化，需要先清空集群中每一台服务器上的`${hadoop.tmp.dir}`目录。

### 2.1.6、NameNode总结

> 注意：block块存放在哪些datanode上，只有datanode自己知道，当集群启动的时候，datanode会扫描自己节点上所有的block块信息，然后把节点和这个节点上的所有block块信息告诉给namenode。这个关系是每次重启集群都会动态加载的【这个其实就是为什么集群数据越多，启动越慢的原因】

NameNode维护了两份关系：

第一份关系：file与block list的关系，对应的关系信息存储在fsimage和edits文件中，当NameNode启动的时候会把文件中的元数据信息加载到内存中。

第二份关系：datanode与block的关系，对应的关系主要在集群启动的时候保存在内存中，当DataNode启动时会把当前节点上的Block信息和节点信息上报给NameNode。

> 注意了，NameNode启动的时候会把文件中的元数据信息加载到内存中，然后每一个文件的元数据信息会占用150字节的内存空间，这个是恒定的，和文件大小没关系。这也是HDFS不适合存储小文件的原因。不管大文件还是小文件，一个文件的元数据信息在NameNode中都会占用150字节，NameNode节点的内存是有限的，所以它的存储能力也是有限的，如果我们存储了一堆都是几KB的小文件，最后发现NameNode内存占满了，确实存储了很多文件，但是文件的总体大小确很小，这样就失去了HDFS存在的价值。



## 2.2、HDFS高级

### 2.2.1、HDFS的回收站

HDFS会为每一个用户创建一个回收站目录：`/user/用户名/.Trash/`，每一个被用户在Shell命令行删除的文件/目录，会进入到对应的回收站目录中，在回收站中的数据都有一个生存周期，也就是当回收站中的文件/目录在一段时间之内没有被用户恢复的话，HDFS就会自动的把这个文件/目录彻底删除，之后，用户就永远也找不回这个文件/目录了。

默认情况下HDFS的回收站是没有开启的，需要通过一个配置来开启，在`core-site.xml`中添加如下配置，value的单位是分钟，1440分钟表示是一天的生存周期。

```xml
    <property>
        <name>fs.trash.interval</name>
        <value>1440</value>
    </property>
```

在修改配置信息之前先验证一下删除操作，显示的是直接删除掉了。

```bash
[emon@emon ~]$ hdfs dfs -rm /NOTICE.txt
Deleted /NOTICE.txt
```

停止集群 ==> 修改主节点 emon 上的回收站配置 ==> 同步到其他两个节点 ==> 启动集群：

```bash
[emon@emon ~]$ stop-all.sh 
[emon@emon ~]$ vim /usr/local/hadoop/etc/hadoop/core-site.xml 
```

```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://emon:8020</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/usr/local/hadoop/tmp</value>
    </property>
    <property>
        <name>fs.trash.interval</name>
        <value>1440</value>
    </property>
</configuration>
```

```bash
[emon@emon ~]$ scp -rq /usr/local/hadoop/etc/hadoop/core-site.xml emon@emon2:/usr/local/hadoop/etc/hadoop/
[emon@emon ~]$ scp -rq /usr/local/hadoop/etc/hadoop/core-site.xml emon@emon3:/usr/local/hadoop/etc/hadoop/
```

启动集群，再执行删除操作：

```bash
[emon@emon ~]$ hdfs dfs -rm /NOTICE.txt
2022-01-22 11:06:16,208 INFO fs.TrashPolicyDefault: Moved: 'hdfs://emon:8020/NOTICE.txt' to trash at: hdfs://emon:8020/user/emon/.Trash/Current/NOTICE.txt
```

此时看到提示信息说把删除的文件移到了指定目录中，其实就是移动到了当前用户的回收站目录。

> 注意：如果删除的文件过大，超过回收站大小的话会提示删除失败，需要指定参数 -skipTrash ，指定这个参数表示删除的文件不会进回收站。

```bash
[emon@emon ~]$ hdfs dfs -rm -skipTrash /LICENSE.txt
Deleted /LICENSE.txt
```

### 2.2.2、HDFS的安全模式

平时操作HDFS的时候，可能会遇到这个问题，特别是刚启动集群后去上传或者删除文件，会发现错误，提示NameNode处于`safe mode`。这个属于HDFS的安全模式，因为在集群每次重启的时候，HDFS都会检查集群中文件信息是否完整，例如副本是否缺少之类的信息，所以这个时间段内是不允许对集群有修改操作的，如果遇到了这种情况，可以稍等一会，等HDFS自检完毕，就会自动退出安全模式。

此时访问HDFS的web ui界面，可以看到下面的信息，on表示处于安全模式，off表示安全模式已退出。

**安全模式开启图示**：

![image-20220122112610207](images/image-20220122112610207.png)



**安全模式关闭图示**：

![image-20220122112005572](images/image-20220122112005572.png)

或者通过hdfs命令也可以查看当前的状态：

```bash
[emon@emon ~]$ hdfs dfsadmin -safemode get
Safe mode is OFF
```

如果想快速离开安全模式，可以通过命令强制离开，正常情况下建议等HDFS自检完毕，自动退出。

```bash
[emon@emon ~]$ hdfs dfsadmin -safemode leave
Safe mode is OFF
```

此时，再操作HDFS中的文件就可以了。



### 2.2.3、实战：定时上传数据至HDFS

> 需求分析：
>
> 在实际工作中会有定时上传数据到HDFS的需求，我们有一个web项目每天都会产生日志文件，日志文件的格式为access_2020-01-01+12:35.log这种格式的，每天产生一个，我们需要每天凌晨将昨天生成的日志文件上传至HDFS上，按天分目录存储，HDFS上的目录格式为20200101。
>
> 说明：根据 /usr/local/nginx/sbin/cut_my_log.sh 脚本对nginx日志进行按照每分钟切割，可以生成测试文件。

针对这个需求，我们需要开发一个shell脚本，方便定时调度执行：

第一步：我们需要获取到昨天日志文件的名称

第二步：在HDFS上面使用昨天的日期创建目录

第三步：将昨天的日志文件上传到刚创建的HDFS目录中

第四部：要考虑到脚本重跑，补数据的情况

第五步：配置crontab任务

开始开发shell脚本，脚本内容如下：

```bash
[emon@emon ~] vim /usr/local/hadoop/custom/shell/uploadLogData.sh
```

```bash
#!/bin/bash

# 获取昨天日期字符串
yesterday=$1
if [ "$yesterday" = "" ]
then
    yesterday=`date +%Y-%m-%d+%H --date="1 days ago"`
fi

# 拼接日志文件路径信息
logPath=/usr/local/nginx/logs/access.${yesterday}.log

# 将日期字符串中的 -+: 去掉，并且拼接成HDFS的路径
hdfsPath=/log/${yesterday//[-+:]/}

# 在HDFS上面创建目录
hdfs dfs -mkdir -p ${hdfsPath}

# 将数据上传到HDFS的指定目录中
hdfs dfs -put ${logPath} ${hdfsPath}
```

```bash
# -x 参数跟踪脚本执行情况
[emon@emon ~]$ sh -x /usr/local/hadoop/custom/shell/uploadLogData.sh 
# 命令行输出信息
+ yesterday=
+ '[' '' = '' ']'
++ date +%Y-%m-%d+%H '--date=1 days ago'
+ yesterday=2022-01-21+13
+ logPath=/usr/local/nginx/logs/access.2022-01-21+13.log
+ hdfsPath=/log/2022012113
+ hdfs dfs -mkdir -p /log/2022012113
+ hdfs dfs -put /usr/local/nginx/logs/access.2022-01-21+13.log /log/2022012113
put: `/log/2022012113/access.2022-01-21+13.log': File exists
[emon@emon shell]$ sh -x uploadLogData.sh 
+ yesterday=
+ '[' '' = '' ']'
++ date +%Y-%m-%d+%H '--date=1 days ago'
+ yesterday=2022-01-21+13
+ logPath=/usr/local/nginx/logs/access.2022-01-21+13.log
+ hdfsPath=/log/2022012113
+ hdfs dfs -mkdir -p /log/2022012113
+ hdfs dfs -put /usr/local/nginx/logs/access.2022-01-21+13.log /log/2022012113

[emon@emon ~]$ hdfs dfs -ls -R /log
drwxr-xr-x   - emon supergroup          0 2022-01-22 13:54 /log/2022012113
-rw-r--r--   2 emon supergroup        564 2022-01-22 13:54 /log/2022012113/access.2022-01-21+13.log
```

```bash
# 手工上传指定日志
[emon@emon ~]$ sh -x /usr/local/hadoop/custom/shell/uploadLogData.sh 2022-01-21+12
+ yesterday=2022-01-21+12
+ '[' 2022-01-21+12 = '' ']'
+ logPath=/usr/local/nginx/logs/access.2022-01-21+12.log
+ hdfsPath=/log/2022012112
+ hdfs dfs -mkdir -p /log/2022012112
+ hdfs dfs -put /usr/local/nginx/logs/access.2022-01-21+12.log /log/2022012112

[emon@emon ~]$ hdfs dfs -ls -R /log
drwxr-xr-x   - emon supergroup          0 2022-01-22 14:01 /log/2022012112
-rw-r--r--   2 emon supergroup        412 2022-01-22 14:01 /log/2022012112/access.2022-01-21+12.log
drwxr-xr-x   - emon supergroup          0 2022-01-22 13:54 /log/2022012113
-rw-r--r--   2 emon supergroup        564 2022-01-22 13:54 /log/2022012113/access.2022-01-21+13.log
```

### 2.2.4、HDFS的高可用和高扩展

NameNode节点负责接收用户的操作请求，所有的读写请求都会经过它，如果NameNode节点宕机了怎么办？

![image-20220122141409203](images/image-20220122141409203.png)

**HA部署暂略！**



# 三、MapReduce

## 3.1、多文件WordCount案例分析



![image-20220122152359162](images/image-20220122152359162.png)

![image-20220122152410838](images/image-20220122152410838.png)

































