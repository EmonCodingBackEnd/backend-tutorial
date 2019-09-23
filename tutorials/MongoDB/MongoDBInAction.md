# MongoDB实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装

## 1、下载

下载地址： <https://www.mongodb.com/download-center/community>

![1568993780255](images/1568993780255.png)

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.0.tgz
```

## 2、创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/MongoDB
```

## 3、解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/mongodb-linux-x86_64-rhel70-4.2.0.tgz -C /usr/local/MongoDB/
```

## 4、创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/MongoDB/mongodb-linux-x86_64-rhel70-4.2.0/ /usr/local/mongodb
```

## 5、配置环境变量

在`/etc/profile.d`目录创建`mongodb.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/mongodb.sh
export PATH=/usr/local/mongodb/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

## 6、数据库目录规划

```bash
[emon@emon ~]$ mkdir -p /usr/local/mongodb/{db,log,conf}
```

## 7、配置文件

```bash
[emon@emon ~]$ vim /usr/local/mongodb/conf/mongodb.conf
```

```bash
# 数据文件存放目录，默认： /data/db/
dbpath=/usr/local/mongodb/db
# 日志文件
logpath=/usr/local/mongodb/log/mongodb.log
# 端口，默认27017，MongoDB的默认服务TCP端口
port=27017
# 以守护程序的方式启动，即在后台运行
fork=true
# 日志追加
logappend=true
# 是否认证
auth=false
# 远程连接要指定ip，不然无法连接；0.0.0.0表示不限制ip访问，并开启对应端口
bind_ip=0.0.0.0
```

## 8、启动与停止

- 启动

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/mongodb.conf 
或
[emon@emon ~]$ mongod -f /usr/local/mongodb/conf/mongodb.conf 
```

- 停止

```bash
[emon@emon ~]$ mongod --config /usr/local/mongodb/conf/mongodb.conf --shutdown
```

## 9、设置启动项

```bash
[emon@emon ~]$ sudo vim /usr/lib/systemd/system/mongod.service
```

```bash
[Unit]
    Description=mongodb
    After=network.target remote-fs.target nss-lookup.target
[Service]
    Type=forking
    ExecStart=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf
    ExecReload=/bin/kill -s HUP $MAINPID
    ExecStop=/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf --shutdown
    PrivateTmp=true
[Install]
    WantedBy=multi-user.target
```

- 加载启动项

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
```

- 启动mongodb

```bash
[emon@emon ~]$ sudo systemctl start mongod
```

- 停止mongodb

```bash
[emon@emon ~]$ sudo systemctl stop mongod
```



# 二、Robo 3T连接

## 1、下载

下载地址：https://robomongo.org/download

## 2、启动并连接



