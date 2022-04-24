# Concurrency实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、并发测试工具安装

## 1、ApacheBench

- 首先安装ab运行需要的软件包apr-util

```bash
$ yum install -y apr-util
```

- 然后安装一个yum的工具包，为了可以单独弄出来ab

```bash
$ yum install -y yum-utils
```

- 上面安装完成后，我们开始单独安装ab，其实就是下载到apache的rpm包，然后解压后，cp出来ab工具

```bash
$ mkdir /usr/local/httpd
$ cd /usr/local/httpd/
# 下载
$ yumdownloader httpd-tools*
# 解包
$ rpm2cpio httpd-tools-2.4.6-97.el7.centos.5.x86_64.rpm |cpio -idmv
# 回到根目录
$ cd
# 复制ab到系统bin下
$ cp /usr/local/httpd/usr/bin/ab /usr/bin/
```

- 测试

```bash
$ ab -V
```

