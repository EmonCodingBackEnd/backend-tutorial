# HBase实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

[安装HBase（外部ZK+外部HDFS+CDH）](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#8%E5%AE%89%E8%A3%85hbase%E5%A4%96%E9%83%A8zk%E5%A4%96%E9%83%A8hdfscdh)

# 二、常用命令

## 0、写在前面

- 启动

```bash
[emon@emon ~]$ start-hbase.sh 
```

- 停止

```bash
[emon@emon ~]$ stop-hbase.sh 
```

- 进入hbase命令行

```bash
[emon@emon ~]$ hbase shell
```

**以下命令，都是在`hbase shell`命令行下执行！**

## 1、命名空间

HBase命名空间namespace是与关系数据库系统中的数据库类似的表的逻辑分组。

### 1.1、HBase预定义的命名空间

- `hbase`：系统命名空间，用于包含HBase内部表
- `default`：没有显示指定命名空间的表将自动落入此命名空间

### 1.2、行、列、cell

- 行

HBase中的行是逻辑上的行，物理模型上行是按列族（column family）分别存取的。

- 列族

Apache HBase中的列被分组为列族。列族中的所有列成员具有相同的前缀。一个表不应该有太多列族，一般1-3个为宜。

- HBase Cell

由`{row key,column(=<family> + <label>),version}唯一确定的单元。cell中的数据是没有类型的，全部是字节码形式存储。

## 2、数据定义语言（DDL）

**DDL：Hive Data Definition Language**

### 2.1、命名空间操作(数据库)

- 查看命名空间列表

```bash
hbase> list_namespace
```

- 创建命名空间

```bash
hbase>  'my_ns'
```

- 查看命名空间下的表

```bash
hbase> list_namespace_tables 'my_ns'
```

- 查看某一个命名空间

```bash
hbase> describe_namespace 'my_ns'
```

- 删除命名空间（如果存在表，无法删除）

```bash
# 先禁用表=>删除表=>删除命名空间
hbase> disable 'my_ns:my_table'
hbase> drop 'my_ns:my_table'                          
hbase> drop_namespace 'my_ns'
```

### 2.2、数据表操作

HBase中表是在schema定义时被预先声明的。

```bash
create '<table name>','<column family1>','<column family2>'......,'<column familyn>'
```

- 创建表

```bash
# '[命名空间]:表名,'列簇1','列簇2','列簇3'
# 命名空间可以不写，默认是default；列簇最多5个
hbase> create 'test','f1','f2','f3'
```

- 查看表结构

```bash
# '[命名空间]:表名'
hbase> describe 'test'
或者
hbase> desc 'test'
```

- 禁用表

```bash
hbase> disable 'test'
```

- 启用表

```bash
hbase> enable 'test'
```

- 查看表结构是否允许修改（启用的表不允许修改）

```bash
hbase> is_enabled 'test'
```

- 增加一个列族

```bash
hbase> disable 'test'
hbase> alter 'test', NAME=>'f1',VERSIONS=>3
hbase> enable 'test'
或者
hbase> alter 'test','f3'
```

- 删除某个列族

```bash
hbase> disable 'test'
hbase> alter 'test', NAME=>'f1',METHOD=>'delete'
hbase> enable 'test'
或者
hbase> alter 'test','delete'=>'f3'
```

- 查看所有表

```bash
hbase> list_namespace_tables 'default'
或者
hbase> list
# 特别注意，list 'default'和list是不一样的
```

- 查看某一张表是否存在

```bash
hbase> exists 'test'
```

- 清空表

```bash
hbase> truncate 'test'
```

- 删除表

```bash
# ENABLED状态的表无法删除，要先禁用再删除
hbase> disable 'test'
hbase> drop 'test'
```

## 3、数据操作语言之创建（DML）

**Hive Data Manipulation Language**

- 向表中插入数据

```bash
# put '[命名空间]:表名','行键','列簇:列名','列值'
# 命名空间可以不写，默认是default；列簇的列可以不存在，修改数据也是put，只需要行键和列相同
hbase> put 'test','0001','f1:username','henry'
```

- 删除某行数据的列[值]

```bash
# 删除 test 行，行键为r1的name列中。
hbase> delete 'test','r1','f1:name'
```

- 删除某行数据

```bash
hbase> deleteall 'test','r1'
```

## 4、数据查询语言（DQL）

**Hive Data Query Language**

- 获取某个行键的所有列族的列值

```bash
hbase> get 'test','r1'
```

- 获取某个行键的某个列族的所有列值

```bash
hbase> get 'test','r1','f1'
```

- 获取某个行键的某两个列族的某个列值

```bash
# get '[命名空间]:表名','行键','列族1','列族2'
hbase> get 'test','r1','f1','f2'
# get '[命名空间]:表名','行键','列族1:列名','列族2'
hbase> get 'test','0001','f1:age','f2'
```

- 获取某个行键的某个列族的某个列值

```bash
hbase> get 'test','r1','f1:name'
```

- 获取某个表的所有行键值

```bash
hbase> scan 'test'
```

- 获取某个表的前3行

```bash
hbase> scan 'test',{LIMIT=>3}
```

- 获取某个表的从指定位置开始的行

```bash
hbase> scan 'test',{STARTROW=>'rowKey',LIMIT=>3}
```

- 获取某个表的指定列的所有行数据

```bash
hbase> scan 'test',{COLUMNS=>'f1:nickname'}
```

- 统计表的行数

```bash
hbase> count 'test'
```
