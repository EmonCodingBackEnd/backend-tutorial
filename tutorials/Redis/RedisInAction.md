# Redis实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[toc]

# 一、Redis

## 1.1、Redis的命令行客户端

- 关闭redis

```bash
redis-cli -a password shutdown
```

- 进入到redis客户端

```bash
# 默认登录本机服务
[emon@emon ~]$ redis-cli
# 指定ip和端口
[emon@emon ~]$ redis-cli -h localhost -p 6379
```

- 输入密码

```bash
localhost:6379 auth `[密码]`
```

- 切换数据库，总共默认16个

```bash
# index的值在[0, 15]之间
localhost:6379 select index
```

- 删除当前数据库中的数据

```bash
localhost:6379 flushdb [ASYNC]
```

- 删除所有db中的数据

```bash
localhost:6379 flushall
```

- 清屏

```bash
localhost:6379 clear
```

## 1.2、Redis的数据类型

### 1.2.1、string 字符串

string：最简单的字符串类型键值对缓存，也是最基本的。

- 查看所有的key（不建议在生产上使用，有性能影响）

```bash
localhost:6379 keys * 
```

- 查看key的类型

```bash
localhost:6379 type key
```

- 设置以及存档的key，会覆盖已有同名key的值

```bash
localhost:6379 set key value
OK
```

- 设置以及存档在key，不会覆盖

```bash
# 结果0表示未设置成功，1表示设置成功
localhost:6379 setnx key value
(integer) 0
```

- 设置带过期时间的数据

```bash
# 设置秒为单位过期的数据
localhost:6379 set key value ex time
# 设置毫秒为单位过期的数据
localhost:6379 set key value px time
```

- 设置过期时间

```bash
# 结果0表示设置失败，比如key已不存在，1表示设置成功
localhost:6379 expire key time
(integer) 0
```

- 查看剩余时间

```bash
# 结果-1表示永不过期，-2已过期
localhost:6379 ttl key
(integer) -2
```

- 合并字符串

```bash
localhost:6379 append key value
```

- 字符串长度

```bash
localhost:6379 strlen key
```

- 累加1

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加1后的值
localhost:6379 incr key
```

- 累减1

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加1后的值
localhost:6379 decr key
```

- 累加给定数值

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加num后的值
localhost:6379 incrby key num
```

- 累减给定数值

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累减num后的值
localhost:6379 decrby key num
```

- 截取数据，end=-1代表到最后

```bash
# 仅能对string类型的字符串数据操作
localhost:6379 getrange key start end
```

- 从start位置开始替换数据

```bash
# 仅能对string类型的字符串数据操作
localhost:6379 setrange key start newdata
```

- 连续设置

```bash
localhost:6379 mset key value [key value ...]
```

- 连续取值

```bash
localhost:6379 mget key [key ...]
```

- 连续设置，如果存在则不设置

```bash
# 特殊：如连续设置的key，有任何一个已经存在，则整体都会被忽略！0-表示全部被忽略，1-表示全部成功！
localhost:6379 msetnx key value [key value ...]
(integer) 1
```



### 1.2.2、hash

hash：类似map，存储结构化数据结构，比如存储一个对象（不能有嵌套对象）。

- 设置hash

```bash
localhost:6379 hset key field value
```

- 获取hash

```bash
localhost:6379 hget key field
```

- 获取hash某个对象的全部属性

```bash
localhost:6379 hkeys key
```

- 获取hash某个对象的全部值

```bash
localhost:6379 hvals key
```

- 累加给定数值

```bash
# 注意，increment 可正可负可小数
localhost:6379 hincrby key field increment
```

- 判断hash对象的属性是否存在

```bash
localhost:6379 hexists key field
```

- 删除hash对象的属性

```bash
localhost:6379 hdel key field [field ...]
```

- 获取hash对象

```bash
localhost:6379 hgetall key 
```

- 连续设置hash

```bash
localhost:6379 hmset key field value [field value ...]
```

- 连续获取

```bash
localhost:6379 hmget key field [field ...]
```

### 1.2.3、list

list:列表，[a,b,c,d...]

- 构建一个list，从左边开始存入数据

```bash
# 返回列表最新数据量
localhost:6379 lpush key value [value ...]
```

- 查看list数据，-1表示到结尾

```bash
# 返回列表最新数据量
localhost:6379 lrange key start stop
```

- 从右边存入数据

```bash
localhost:6379 rpush key value [value ...]
```

- 从左侧开始拿出一个数据

```bash
# 返回被拿到的值，并从列表中剔除
localhost:6379 lpop key
```

- 从右侧开始拿出一个数据

```bash
# 返回被拿到的值，并从列表中剔除
localhost:6379 rpop key
```

- 查看list长度

```bash
localhost:6379 llen key
```

- 获取list下标的值

```bash
localhost:6379 lindex key index
```

- 把某个下标的值替换

```bash
# 成功返回OK
localhost:6379 lset key index value
```

- 插入一个新的值

```bash
# pivot指代某个列表元素值，返回插入新值后元素的个数
localhost:6379 linsert key before/after pivot value
```

- 删除几个相同数据

```bash
# 返回实际产出的数量
localhost:6379 lrem key num value
```

- 截取值，替换原来的list，-1表示到结尾

```bash
# 截取后，原list被改变
localhost:6379 ltrim key start end
```

### 1.2.4、set

- 添加数据

```bash
# 返回去重后的元素数量
localhost:6379 sadd key member [member ...]
```

- 查看set元素，返回列表

```bash
localhost:6379 smembers key
```

- 查看set元素数量

```bash
localhost:6379 scard key
```

- 查看元素是否set成员

```bash
# 如果返回1表示存在，0表示不存在
localhost:6379 sismember key member
```

- 删除set元素

```bash
# 如果删除成功返回1，否则返回0
localhost:6379 srem key member [member ...]
```

- 随机从set移除一定量元素，默认1个，会改变set

```bash
localhost:6379 spop key [count]
```

- 随机从set获取一定量元素，默认1个，不会改变set

```bash
localhost:6379 srandmemberkey [count]
```

- 从一个set移除指定元素，并放入另外一个set中，会修改两个set的元素

```bash
localhost:6379 smove source destination member
```

- set的差集

```bash
# 返回存在于第一个key，但不存在于第二个key的元素
localhost:6379 sdiff key [key ...]
```

- set的交集

```bash
# 返回存在于第一个key，且存在于第二个key的元素
localhost:6379 sinter key [key ...]
```

- set的并集

```bash
# 返回存在于第一个key，或者存在于第二个key的元素
localhost:6379 sunion key [key ...]
```

### 1.2.5、zset

zet也称为sorted set：

sorted set：排序的set，可以去重可以排序，比如可以根据用户积分做排名，积分作为set的一个数值，根据数值可以做排序。set中的每一个member都带有一个分数。

- 添加zset元素

```bash
localhost:6379 zadd key [NX|XX] [CH] [INCR] score member [score member ...]
```

- 查看zset元素

```bash
localhost:6379 zrange key start stop [WITHSCORES]
```

- 获取zset指定元素的下标

```bash
localhost:6379> zrank key member
```

- 获取zset指定元素的分数

```bash
localhost:6379> zscore key member
```

- 查看zset元素数量

```bash
localhost:6379> zcard key
```

- 统计分数区间内的元素数量

```bash
localhost:6379> zcount key min max
```

- 统计分数区间内的元素，以列表显示元素

```bash
# 获取min<=x<=max的元素，如果不想要等于，可以使用 (min 和 (max，比如 zrangebyscore key (20 (40 表示大于20且小于40
localhost:6379> zrangebyscore key min max [WITHSCORES] [LIMIT offset count]
```

- 删除zset元素，返回删除的元素数量

```bash
localhost:6379> zrem key member [member ...]
```

## 1.3、Redis的发布（pub）与订阅（sub）

- 订阅

```bash
localhost:6379> subscribe channel [channel ...]
```

- 发布

```bash
localhost:6379> publish channel message
```

- 批量订阅

```bash
localhost:6379> psubscribe pattern [pattern ...]
```



