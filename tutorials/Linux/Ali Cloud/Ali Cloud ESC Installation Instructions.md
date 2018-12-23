[TOC]

# 一、安装前的准备工作

新购买的阿里云服务器ECS，只用root用户；如果没有指定主机名，那么给定一个默认的随机串作为主机名，比
如： iZ2zeccmg1u7pjn8jm0wg4Z 这样的字符串。

**注意：以下内容针对CentOS7版本操作系统**

## 1、修改主机名

```bash
[root@iZ2zeccmg1u7pjn8jm0wg4Z ~]# hostnamectl set-hostname emon
```

修改后需要**重新登录**root用户，才能在命令行看到新的主机名。

```bash
[root@emon ~]# cat /etc/hostname
emon
```

## 2、创建具有sudo权限的普通用户

1. 创建普通用户

```bash
[root@emon ~]# useradd -c "Web Site User" emon
```

2. 修改密码

```bash
[root@emon ~]# passwd emon
```

3. 赋权sudo

root用户以`visudo`命令打开文件，在99行添加：`emon ALL=(ALL) ALL`即可。

## 3、开启SELinux

阿里云默认关闭SELinux，请开启。

```bash
[root@emon ~]# vim /etc/selinux/config 
```

找到`SELINUX=disabled`修改为`SELINUX=enforcing`，这种修改需要重启系统才能生效。

## 4、开启firewalld防火墙

阿里云默认关闭firewalld服务，请开启。

```bash
[root@emon ~]# systemctl start firewalld
```

## 5、修改vim的缩进为4个空格

```bash
[root@emon ~]# vim /etc/vimrc 
```

打开文件后，在最后一行追加如下内容：

```bash
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
```

以上设置，是一个新的阿里云服务器ECS在安装软件之前，需要预先设置的内容；设置完成后，重启系统使
SELinux配置生效。
别忘记**创建快照**哦！

# 二、安装项目所需软件

---

由于下面采用emon进行安装，安装目录在`/usr/local/`，这里先修改目录的属主。

```bash
[emon@emon ~]$ sudo chown -R emon /usr/local/
[emon@emon ~]$ ll -d /usr/local
drwxr-xr-x. 13 emon root 4096 Feb 24  2017 /usr/local
```

下面安装时，如非必要，默认在emon用户的宿主目录执行命令。

## 1、安装JDK

1. 检查是否已安装

```bash
[emon@emon ~]$ rpm -qa|grep jdk
```

2. 下载

下面的下载地址，可以通过ORACLE官网下载页，登录后获取：

官网下载页地址： <http://www.oracle.com/technetwork/java/javase/downloads/index.html>

```bash
[emon@emon ~]$ wget -O /usr/local/src/jdk-8u191-linux-x64.tar.gz https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.tar.gz?AuthParam=1545562991_7d97cdebe79dbe0cde3dfcb898c1a70c
```

3. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Java
```

4. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/jdk-8u191-linux-x64.tar.gz -C /usr/local/Java/
```

5. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Java/jdk1.8.0_191/ /usr/local/java
```

6. 配置环境变量

在`/etc/profile.d`目录创建`jdk.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/jdk.sh
export JAVA_HOME=/usr/local/java
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
```







