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
localhost:6379> auth `[密码]`
```

- 切换数据库，总共默认16个

```bash
# index的值在[0, 15]之间
localhost:6379> select <index>
```

- 删除当前数据库中的数据

```bash
localhost:6379> flushdb [ASYNC]
```

- 删除所有db中的数据

```bash
localhost:6379> flushall
```



## 1.2、Redis的数据类型

### 1.2.1、string 字符串

string：最简单的字符串类型键值对缓存，也是最基本的。

- 查看所有的key（不建议在生产上使用，有性能影响）

```bash
localhost:6379> keys * 
```

- 查看key的类型

```bash
localhost:6379> type <key>
```

- 设置以及存档的key，会覆盖已有同名key的值

```bash
localhost:6379> set <key> <value>
OK
```

- 设置以及存档在key，不会覆盖

```bash
# 结果0表示未设置成功，1表示设置成功
localhost:6379> setnx <key> <value>
(integer) 0
```

- 设置带过期时间的数据

```bash
# 设置秒为单位过期的数据
localhost:6379> set <key> <value> ex time
# 设置毫秒为单位过期的数据
localhost:6379> set <key> <value> px time
```

- 设置过期时间

```bash
# 结果0表示设置失败，比如key已不存在，1表示设置成功
localhost:6379> expire <key> time
(integer) 0
```

- 查看剩余时间

```bash
# 结果-1表示永不过期，-2已过期
localhost:6379> ttl <key>
(integer) -2
```

- 合并字符串

```bash
localhost:6379> append <key> <value>
```

- 字符串长度

```bash
localhost:6379> strlen <key>
```

- 累加1

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加1后的值
localhost:6379> incr <key>
```

- 累减1

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加1后的值
localhost:6379> decr <key>
```

- 累加给定数值

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累加num后的值
localhost:6379> incrby <key> <num>
```

- 累减给定数值

```bash
# 仅能对integer类型的字符串数据操作，返回的结果表示累减num后的值
localhost:6379> decrby <key> <num>
```

- 截取数据，end=-1代表到最后

```bash
# 仅能对string类型的字符串数据操作
localhost:6379> getrange <key> <start> <end>
```

- 从start位置开始替换数据

```bash
# 仅能对string类型的字符串数据操作
localhost:6379> setrange <key> <start> <newdata>
```

- 连续设置

```bash
localhost:6379> mset <key> <value> [<key> <value> ...]
```

- 连续取值

```bash
localhost:6379> mget <key> [<key> ...]
```

- 连续设置，如果存在则不设置

```bash
# 特殊：如连续设置的key，有任何一个已经存在，则整体都会被忽略！0-表示全部被忽略，1-表示全部成功！
localhost:6379> msetnx <key> <value> [<key> <value> ...]
(integer) 1
```

