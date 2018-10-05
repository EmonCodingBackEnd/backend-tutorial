# MySQL实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、数据库设计规范

## 1、数据库命名规范

- 所有数据库对象名称必须使用小写字母并使用下划线分隔
- 所有数据库对象名称禁止使用MySQL保留关键字
- 数据库对象的命名要能做到见名知意，并且最好不要超过32个字符
- 临时库表必须以tmp为前缀并以日期为后缀
- 备份库，备份表必须以bak为前缀并以日期为后缀
- 所有存储相同数据的列名和列类型必须一致

## 2、数据库基本设计规范

- 所有表必须使用Innodb存储引擎
  - MySQL5.6之后，InnoDB已经成为了默认存储引擎
  - 支持事务，行级锁，更好的恢复性，高并发下性能更好
- 数据库和表的字符集统一使用UTF8（也可以统一到UTF8MB4）
  - 统一字符集可以避免由于字符集转换产生的乱码
  - MySQL中UTF8字符集汉字占3个字节，ASCII码占用1个字节
- 所有表和字段都需要添加注释
  - 从一开始就进行数据字典的维护
- 尽量的控制单表数据量的大小，建议控制在500万以内
  - 500万不是MySQL数据库的限制
  - 可以用历史数据归档，分库分表等手段来控制数据量大小
- 谨慎使用MySQL分区表
  - 分区表在物理上表现为多个文件，在逻辑上表现为一个表
  - 谨慎选择分区键，跨分区查询效率可能更低
  - 建议采用物理分表的方式管理大数据
- 尽量做到冷热数据分离，减小表的宽度
  - MySQL限制最多存储4096列
  - 每行数据的大小不能超过65535个字节
  - 减少磁盘IO，保证热数据的内存缓存命中率
  - 更有效的利用缓存，避免读入无用的冷数据
  - 经常一起使用的列放到一个表中
- 禁止在表中建立预留字段
  - 预留的字段命名很难做到见名知意
  - 预留字段无法确认存储的数据类型，所以无法选择合适的数据类型
  - 对预留字段类型的修改，会对表进行行级锁定
- 禁止在数据库中存储图片，文件等二进制数据
- 禁止在线上数据库压力测试
- 禁止从开发环境，测试环境直接连接生产环境数据库

## 3、数据库索引设计规范

**索引对数据库的查询性能来说是非常重要的**

- 不要滥用索引，限制每张表上的索引数量，建议单张表索引不超过5个

  - 索引并不是越多越好！索引可以提高效率同样可以降低效率
  - 禁止给表中的每一列都建立单独的索引
  - Innodb是按照哪一个索引的顺序来组织表的？
    - 答案是：主键

- 每个Innodb表必须有一个主键

  - 不使用更新频繁的列作为主键，不使用多列主键/联合主键
  - 不使用UUID，MD5，HASH，字符串列作为主键
  - 如果不能自己生成唯一、增长的主键，那么主键建议选择使用自增ID值

- 常见索引列建议

  - 在哪些列上建立索引呢？
    - SELECT、UPDATE、DELETE语句的WHERE从句中的列
    - 包含在ORDER BY、GROUP BY、DISTINCT中的字段
    - 多表JOIN的关联列
  - 如何选择索引列的顺序
    - 区分度最高的列放在联合索引的最左侧
    - 尽量把字段长度小的列放到联合索引的最左侧
    - 使用最频繁的列放到联合索引的最左侧

- 避免建立冗余索引和重复的索引

  - 重复索引示例：

  ```
  primary key(id)、index(id)、unique index(id)
  ```

  - 冗余索引示例：

  ```
  index(a,b,c)、index(a,b)、index(a)
  ```

- 对于频繁的查询优先考虑使用覆盖索引
  - 覆盖索引：就是包含了所有查询字段的索引
  - 覆盖索引的好处
    - 避免Innodb表进行索引的二次查找
    - 可以把随机IO变为顺序IO加快查询效率
- 尽量避免使用外键
  - 不建议使用外键约束，但一定在表与表之间的关联键上建立索引
  - 外键可用于保证数据的参照完整性，但建议在业务端实现
  - 外键会影响父表和子表的写操作从而降低性能

## 4、数据库字段设计规范

- 优先选择符合存储需要的最小的数据类型
  - 将字符串转化为数字类型存储
    - INET_ATON('255.255.255.255')=4294967295
    - INET_NTOA(4294967295)='255.255.255.255'
  - 对于非负型的数据来说，要优先使用无符号整型来存储
    - 无符号相对于有符号可以多出一倍的存储空间
  - varchar(n)中的n代表的是字符数，而不是字节数
  - 使用UTF8存储汉子varchar(255)=765个字节
  - 过大的长度会消耗更多的内存
  - 避免使用TEXT、BLOB数据类型
  - 建议把BLOB或是TEXT列分离到单独的扩展表中
  - TEXT或BLOB类型只能使用前缀索引，且不支持默认值
- 避免使用ENUM数据类型
  - 修改ENUM值需要使用ALTER语句
  - ENUM类型的ORDER BY操作效率低，需要额外的操作
  - 禁止使用数值作为ENUM的枚举值
- 尽可能把所有列定义为NOT NULL
  - 索引NULL列需要额外的空间来保存，所以要占用更多的空间
  - 进行和比较计算时要对NULL值做特别的处理
- 字符串存储日期型的数据（不正确的做法）
  - 缺点1：无法使用日期函数进行计算和比较
  - 缺点2：用字符串存储日期要占用更多的空间
- 使用TIMESTAMP或DATETIME类型存储时间
  - TIMESTAMP的存储空间比DATETIME小，占用4个字节，而DATETIME占用8个字节
  - TIMESTAMP的存储范围是 [1970-01-01 00:00:01 ~ 2038-01-19 03:14:07]
  - 超出TIMESTAMP取值范围的使用DATETIME类型
- 同财务相关的金额类数据，必须使用decimal类型
  - 非精准浮点：float，double
  - 精准浮点：decimal
    - Decimal类型为精度浮点数，在计算时不会丢失精度
    - 占用空间由定义的宽度决定
    - 可用于存储比bigint更大的整数数据

## 5、数据库SQL开发规范

- 建议使用预编译语句进行数据库操作

  - 减少与数据库的IO流量
  - 减少SQL编译的时间
  - 防止SQL注入

- 避免数据类型的隐式转换

  - 隐式转换会导致索引失效

  ```
  select name,phone from customer where id = '111' # 发生了隐式转换
  ```

- 充分利用表上已经存在的索引

  - 避免使用双%号的查询条件。如a like '%123%'
  - 避免使用前置%，如果只有后置%是可以利用到索引的
  - 一个SQL只能利用到复合索引中的一列进行范围查询，其他列的索引会被忽略使用，建议范围查询的列作为复合索引的右侧列
  - 使用left join或not exists来优化not in操作

- 数据库设计时，应该要对后续的扩展进行考虑

- 程序连接不同的数据库使用不同的账号，禁止跨库查询

  - 为数据库迁移和分库分表留出余地
  - 降低业务耦合度
  - 避免权限过大而产生的安全风险

- 禁止使用SELECT * 必须使用 SELECT <字段列表> 查询

  - 消耗更多的CPU和IO以及网络带宽资源
  - 无法使用覆盖索引
  - 可减少表结构变更带来的影响

- 禁止使用不含字段列表的INSERT语句

  - 可减少表结构变更带来的影响

- 避免使用子查询，可以把子查询优化为join操作

  - 子查询的结果集无法使用索引
  - 子查询会产生临时表操作，如果子查询数据量大则严重影响效率
  - 消耗过多的CPU及IO资源

- 避免使用JOIN关联太多的表

  - 每Join一个表会多占用一部分内存（join_buffer_size）
  - 会产生临时表操作，影响查询效率
  - MySQL最多允许关联61个表，建议不超过5个

- 减少同数据库的交互次数

  - 数据库更适合处理批量操作
  - 合并多个相同的操作到一起，可以提高处理效率

- 使用`in`代替`or`

  - in的值不要超过500个
  - in操作可以有效的利用索引

- 禁止使用order by rand()进行随机排序

  - 会把表中所有符合条件的数据装载到内存中进行排序
  - 会消耗大量的CPU和IO及内存资源
  - 推荐在程序中获取一个随机值，然后从数据库中获取数据

- WHERE从句中禁止对列进行函数转换和计算

  - 对列进行函数转换或计算会导致无法使用索引

  ```
  where date(createtime)='20160901'
  调整为=>
  where createtime>='20160901' and createtime<'20160902'
  ```

- 在明显不会有重复值时使用UNION ALL，而不是UNION

- 拆分复杂的大SQL为多个小SQL

  - MySQL一个SQL只能使用一个CPU进行计算
  - SQL拆分后可以通过并行执行来提高处理效率

## 6、数据库操作行为规范

- 超过100万行的批量写操作，要分批多次进行操作
  - 大批量的操作可能会造成严重的主从延迟
  - binlog日志为row格式时会产生大量的日志
  - 避免产生大事务操作
- 对大表数据结构的修改一定要谨慎，会造成严重的锁表操作。尤其是生产环境，是不能忍受的
  - 对于大表使用pt-online-schema-change修改表结构
  - 避免大表修改产生的主从延迟
  - 避免在对表字段进行修改时进行锁表
- 禁止为程序使用的账号赋予super权限
  - 当达到最大连接数限制时，还允许1个有super权限的用户连接
  - super权限只能留给DBA处理问题的账号使用
- 对于程序连接数据库账号，遵循权限最小原则
  - 程序使用数据库账号只能在一个DB下使用，不准跨库。
  - 程序使用的账号原则上不准有drop权限



# 二、MySQL5.7配置文件

## 1、`my.cnf`常规配置项

```
[client]
port = 3306
socket = /usr/local/mysql/run/mysql.sock

[mysqld]
# MySQL服务的唯一编号 每个MySQL服务ID需唯一
server-id = 1
# 服务端口号 默认3306
port = 3306
# MySQL安装根目录
basedir = /usr/local/mysql
# MySQL数据文件所在位置
datadir = /usr/local/mysql/data
# 临时目录 比如load data infile会用到
tmpdir = /tmp
# 设置socket文件所在目录
socket = /usr/local/mysql/run/mysql.sock
# 主要用于MyISAM存储引擎，如果多台服务器连接一个数据库则建议注释下面内容
skip-external-locking
# 只能用IP地址查看客户端的登录，不用主机名
skip_name_resolve = 1
# 事务隔离级别，默认为可重复读，MySQL默认可重复读级别
transaction_isolation = READ-COMMITTED

# 数据库默认字符集，主流字符集支持一些特殊表情符号（特殊表情符号占用4个字节）
character-set-server = utf8mb4
# 数据库字符集对应一些排序等规则，注意要和character-set-server对应
collation-server = utf8mb4_unicode_ci
# 设置client链接MySQL时的字符集，防止乱码
init_connect='SET NAMES utf8mb4'

# 是否对sql语句大小写敏感，1表示不敏感
lower_case_table_names=1

# SQL数据包发送的大小，如果有BLOB对象建议修改成1G
max_allowed_packet = 512M
# 最大连接数
max_connections = 2048
# 最大错误连接数
max_connect_errors = 100
# 增加每个进程的可打开文件数量
open_files_limit = 65535

# TIMESTAMP如果没有显示声明NOT NULL，是否允许NULL值
explicit_defaults_for_timestamp = OFF

# MySQL连接闲置超过一定时间后（单位：秒）将会被强制关闭
# MySQL默认的wait_timeout值为8个小时，interactive_timeout参数需要同时配置才能生效
interactive_timeout = 28800
wait_timeout = 1800

# 内部内存临时表的最大值，比如大数据量的group by,order by时可能用到临时表，超过了这个值将写入磁盘，系统IO压力增大
tmp_table_size = 32M
max_heap_table_size = 32M

# 禁用MySQL的缓存查询结果集功能，后期根据业务情况测试决定是否开启，大部分情况下关闭下面两项
query_cache_type = 0
query_cache_size = 0
#========日志设置========
# 数据库错误日志文件
log-error = /usr/local/mysql/log/mysql_error.log

# 慢查询sql日志设置
slow_query_log = 1
slow_query_log_file = /usr/local/mysql/log/mysql_slow_query.log
# 慢查询执行的秒数，必须达到此值可悲记录
long_query_time = 5
# 检索的行数北徐达到此值才可被记为慢查询
min_examined_row_limit = 100

# 检查未使用到索引的sql
log_queries_not_using_indexes = 1
# 针对log_queries_not_using_indexes开启后，记录慢sql的频次、每分钟记录的条数
log_throttle_queries_not_using_indexes = 5

# 作为从库时生效，从库复制中如果有慢sql也将被记录
log_slow_slave_statements = 1

#========主从复制设置========
# 开启MySQL binlog功能
log-bin = /usr/local/mysql/binlogs/mysql-bin
# binlog记录内容的方式，记录被操作的每一行
binlog_format = ROW
# 对于binlog_format = ROW模式时，减少记录日志的内容，只记录受影响的列
binlog_row_image = minimal

# 作为从库时生效，想进行级联复制，则需要此参数
log_slave_updates
# 作为从库时生效，中继日志relay-log可以自我修复
relay_log_recovery = 1
# 作为从库时生效，主从复制时忽略的错误
slave_skip_errors = ddl_exist_errors
# 值为null，表示限制mysqld不允许导入导出；值为/tmp/，限制mysqld的导入导出只能发生在/tmp/目录下；值为'',不对mysqld的导入导出限制；且注意该参数无法通过set global命令修改。
secure_file_priv = ''
```

## 2、设置变量

### 2.1、设置全局变量

- 修改配置文件并重启MySQL【不推荐】

```shell
[emon@emon ~]$ vim /data/mysql/etc/my.cnf 
[emon@emon ~]$ sudo systemctl restart mysqld
```

- 在命令行里通过SET来设置，然后再修改参数文件

1. 命令行里设置

```mysql
mysql> set global long_query_time = 5;
或者
mysql> set @@global.long_query_time = 5;
```

2. 查看是否生效

```mysql
mysql> show global variables like 'long_query_time';
```

**如果查询时使用的是show variables的话, 会发现设置并没有生效, 除非重新登录再查看. 这是因为使用show variables的话就等同于使用show session variables, 查询的是会话变量, 只有使用show global variables查询的才是全局变量. 如果仅仅想修改会话变量的话, 可以使用类似set long_query_time=5;或者set session long_query_time=5;这样的语法. **

3. 修改配置文件

当前只是修改正在运行的MySQL实例配置，下次重启MySQL又会回到默认值，所以记得修改配置文件

```shell
[emon@emon ~]$ vim /data/mysql/etc/my.cnf 
```

### 2.2、设置会话变量

如果要修改会话变量值，可以指定`session`或者`@@session`或者`@@`或者`local`或者`@@local`，或者什么都不使用。

1. 设置

```mysql
mysql> set long_query_time = 1;
```

2. 查看

```mysql
mysql> show variables like 'long_query_time';
```

# 三、MySQL执行计划(explain)分析

## 1、慢查询日志

- 如何配置

```
# 启用MySQL慢查询日志
slow_query_log = 1
slow_query_log_file = /usr/local/mysql/log/mysql_slow_query.log
# 慢查询执行的秒数，必须达到此值可悲记录
long_query_time = 5
# 检查未使用到索引的sql
log_queries_not_using_indexes = 1
```

- 如何分析

```shell
[emon@emon ~]$ sudo /usr/local/mysql/bin/mysqldumpslow /data/mysql/log/mysql_slow_query.log
```



# 四、MySQL数据库备份和恢复

对于任何数据库来说，备份都是非常重要的

数据库的主从复制不能取代备份的作用

- 逻辑备份和物理备份
  - 逻辑备份的结果为SQL语句，适合于所有存储引擎
  - 物理备份是对数据库目录的拷贝，对于内存表只备份结构
- 全量备份和增量备份
  - 全量备份是对整个数据库的一个完整备份
  - 增量备份是在上次全量或增量备份基础上，对于更改数据进行的备份
  - mysqldump不支持增量备份

## 1、使用`mysqldump`进行备份

- 常用语法

```shell
# 备份表
mysqldump [OPTIONS] database [tables]
# 备份多个数据库
mysqldump [OPTIONS] --databases [OPTIONS] DB1 [DB2 DB3...]
# 备份示例下的所有数据库
mysqldump [OPTIONS] --all-databases [OPTIONS]
```

- 常用参数

```shell
# 查询帮助
[emon@emon ~]$ mysqldump --help
```

```shell
-u, --user=name
-p, --password[=name]
# 对于事务型存储引擎Innodb，可以使用如下保证数据库在备份时是一致的
--single-transaction
# 对于非事务型，可以使用如下锁定一个数据库的表
-l, --lock-tables
# 锁定实例下所有表
-x, --lock-all-tables

--master-data=[1/2]
# 存储过程
-R, --routines
# 触发器
--triggers
# 事件
-E, --events
# 对数据库中大文本存储为十六进制
--hex-blob
# 生成两个文件，一个存储表结构，一个存储表数据
--tab=path
# 指定过滤条件(仅用于单表导出)
-w, --where='过滤条件'
```

执行mysqldump命令的用户需要有如下权限：

`SELECT`,`RELOAD`,`LOCK TABLES`,`REPLICATION CLIENT`,`SHOW VIEW`,`event`,`PROCESS`

- 建立备份账号

```shell
[emon@emon ~]$ mysql -uroot -proot123
mysql> create user 'backup'@'%' identified by 'Backup@123';
mysql> grant select,reload,lock tables,replication client,show view,event,process on *.* to 'backup'@'%' with grant option;
```

备注：如果要导出单张表数据，需要系统的file权限，还需要授权`file`。

- 备份整个数据库

```shell
mysqldump -ubackup -pBackup@123 --master-data=2 --single-transaction --routines --triggers --events selldb > selldb.sql
```

- 备份一个数据库的表结构，不含数据

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --routines --triggers --events -d selldb > selldb_schema.sql
```

- 备份一张表

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --routines --triggers --events selldb order_detail > order_detail.sql
```

- 备份一张表的表结构，不含数据

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --routines --triggers --events -d selldb order_detail > order_detail_schema.sql
```

- 备份实例下的所有数据库

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --routines --triggers --events --all-databases > springboot.sql
```

- 表结构与表数据分开文件的备份

注意，先调整目录`/tmp/selldb`具有如下权限：可见目录所属用户不是关键，写权限才是关键

```shell
[emon@emon ~]$ ll -d /tmp/selldb/
drwxrwxrwx. 2 emon emon 252 10月  5 08:18 /tmp/selldb/
```

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --routines --triggers --events --tab="/tmp/selldb" selldb
```

- 使用where备份

```shell
mysqldump -uspringboot -pSpringBoot@123 --master-data=2 --single-transaction --where "order_status=1" selldb order_master > order_master_status_1.sql
```

## 2、使用`mysql`命令导入

- 非`mysql`命令行下

```shell
mysql -uspringboot -pSpringBoot@123 <dbname> < <backup.sql>
```

- `mysql`命令行下

```mysql
mysql> use selldb;
mysql> source path_name(比如： /home/emon/backup/mysql/selldb_20180704_01.sql)
```

- 针对`--tab`的备份导入

  - 导入表结构

  ```mysql
  source XXX.sql
  ```

  - 导入表数据

  ```mysql
  load data infile 'XXX.txt'
  ```

## 3、备份脚本

1. 编写脚本

```
[emon@emon ~]$ vim ~/bin/backup.sh 
```

```shell
#!/bin/bash
########Basic parameters########
DAY=`date +%Y%m%d`
Environment=$(/sbin/ifconfig|grep "inet "|grep -v "127.0.0.1"|grep -v "172.17.0.1"|awk '{print $2}')
USER="backup"
PASSWD="Backup@123"
HostPort="3306"
MYSQLBASE="/usr/local/mysql"
DATADIR="$HOME/backup/db_backup/${DAY}"
MYSQL=`/usr/bin/which mysql`
MYSQLDUMP=`/usr/bin/which mysqldump`
mkdir -p ${DATADIR}

Dump() {
    ${MYSQLDUMP} --master-data=2 --single-transaction --routines --triggers --events -u${USER} -p${PASSWD} -P${HostPort} ${database} > ${DATADIR}/${Environment}-${database}.sql
    cd ${DATADIR}
gzip ${Environment}-${database}.sql
}

for db in `echo "select schema_name from information_schema.schemata where schema_name not in ('information_schema', 'sys', 'performance_schema')" | ${MYSQL} -u${USER} -p${PASSWD} --skip-column-names`
do
    database=${db}
    Dump
done
```

2. 赋予可执行的权限

```shell
[emon@emon ~]$ chmod u+x ~/bin/backup.sh 
```

3. 执行备份

```shell
[emon@emon ~]$ ~/bin/backup.sh 
```

## 4、如何进行指定时间点的恢复

- 先决条件
  - 具有指定时间点前的一个全备
  - 具有自上次全备后到指定时间点的所有二进制日志

## 5、实时二进制备份

创建具有特殊权限的用户：

```shell
[emon@emon ~]$ mysql -uroot -proot123
mysql> create user 'repl'@'%' identified by 'Repl@123';
mysql> grant replication slave on *.* to 'repl'@'%' with grant option;
```

```shell
mysqlbinlog --raw --read-from-remote-server --stop-never --host localhost --port 3306 -urepl -pRepl@123 二进制日志名
```



# 五、高性能高可用MySQL架构变迁

