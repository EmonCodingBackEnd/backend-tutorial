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

## 1、命名空间

HBase命名空间namespace是与关系数据库系统中的数据库类似的表的逻辑分组。

### 1.1、HBase预定义的命名空间

- `hbase`：系统命名空间，用于包含HBase内部表
- `default`：没有显示指定命名空间的表将自动落入此命名空间

### 1.2、操作命令

- 查看命名空间列表

```bash
list_namespace
```

- 创建命名空间

```bash
create_namespace 'my_ns'
```

- 在命名空间下创建表

```bash
create 'my_ns:my_table', 'fam'
```

- 查看命名空间下的表

```bash
list_namespace_tables 'my_ns'
```

- 查看某一个命名空间

```bash
describe_namespace 'my_ns'
```

- 删除命名空间（如果存在表，无法删除）

```bash
disable 'my_ns:my_table'
drop 'my_ns:my_table'                          
drop_namespace 'my_ns'
```

## 2、表DML

HBase中表是在schema定义时被预先声明的。

```bash
create '<table name>','<column family1>','<column family2>'......,'<column familyn>'
```

- 创建表

```bash
create 't_demo_tbl','f1','f2','f3'
```

- 查看表结构

```bash
describe 't_demo_tbl'
```

- 禁用表

```bash
disable 't_demo_tbl'
```

- 启用表

```bash
enable 't_demo_tbl'
```

- 查看表结构是否允许修改（启用的表不允许修改）

```bash
is_enabled 't_demo_tbl'
```

- 增加一个列族

```bash
disable 't_demo_tbl
alter 't_demo_tbl', NAME=>'f1',VERSIONS=>3
enable 't_demo_tbl'
或者
alter 't_demo_tbl','f3'
```

- 删除某个列族

```bash
disable 't_demo_tbl
alter 't_demo_tbl', NAME=>'f1',METHOD=>'delete'
enable 't_demo_tbl'
或者
alter 't_demo_tbl','delete'=>'f3'
```

- 查看所有表

```bash
list
或
list_namespace_tables 'default'
```

- 查看某一张表是否存在

```bash
exists 't_demo_tbl'
```

- 清空表

```bash
truncate 't_demo_tbl'
```

- 删除表

```bash
disable 't_demo_tbl'
drop 't_demo_tbl'
```

## 3、行、列、cell

### 3.1、行

HBase中的行是逻辑上的行，物理模型上行是按列族（column family）分别存取的。

### 3.2、列族

Apache HBase中的列被分组为列族。列族中的所有列成员具有相同的前缀。

### 3.3、HBase Cell

由`{row key,column(=<family> + <label>),version}唯一确定的单元。cell中的数据是没有类型的，全部是字节码形式存储。

### 3.4、表DDL

- 向表中插入数据

```bash
# 列族的列可以不存在，修改数据页是put，只需要行键[rowkey]和列相同即可。
put 't_demo_tbl','r1','f1:name','jmy'
put 't_demo_tbl','r1','f1:nickname','yy'
put 't_demo_tbl','r1','f2:age','27'
put 't_demo_tbl','r1','f3:desc','is a beauty girl'
put 't_demo_tbl','r2','f1:nickname','ff'
```

- 删除某行数据的列[值]

```bash
# 删除 t_demo_tbl 行，行键为r1的name列中。
delete 't_demo_tbl','r1','f1:name'
```

- 删除某行数据

```bash
deleteall 't_demo_tbl','r1'
```

- 获取某个行键的所有列族的列值

```bash
get 't_demo_tbl','r1'
```

- 获取某个行键的某个列族的所有列值

```bash
get 't_demo_tbl','r1','f1'
```

- 获取某个行键的某两个列族的某个列值

```bash
get 't_demo_tbl','r1','f1','f2'
```

- 获取某个行键的某个列族的某个列值

```bash
get 't_demo_tbl','r1','f1:name'
```

- 获取某个表的所有行键值

```bash
scan 't_demo_tbl'
```

- 获取某个表的前3行

```bash
scan 't_demo_tbl',{LIMIT=>3}
```

- 获取某个表的从指定位置开始的行

```bash
scan 't_demo_tbl',{STARTROW=>'rowKey',LIMIT=>3}
```

- 获取某个表的指定列的所有行数据

```bash
scan 't_demo_tbl',{COLUMNS=>'f1:nickname'}
```

- 统计表的行数

```bash
count 't_demo_tbl'
```

