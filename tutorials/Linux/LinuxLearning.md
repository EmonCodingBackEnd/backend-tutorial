# Linux学习

[[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 第4章 Linux基础篇-目录结构

## 1.1 Linux目录结构

### 1.1.1 基本介绍

​	linux的文件系统是采用级层式的树状目录结构，在此结构中的最上层是根目录“/”，然后在此目录下再创建其他目录。

​	记住一句经典的话：<span style="color:red;font-weight:bold;">在Linux世界里，一切皆文件</span>

### 1.1.2 具体的目录结构

- /bin

  [<span style="color:red;font-weight:bold;">常用</span>]  (/usr/bin、/usr/local/bin)，是Binary的缩写，这个目录存放着最经常使用的命令。

- /sbin

   (/usr/sbin、/usr/local/sbin)，s就是Super User的意思，这里存放的是系统管理员使用的系统程序。

- /home

  [<span style="color:red;font-weight:bold;">常用</span>]存放普通用户的主目录，在Linux中每个用户都有一个自己的目录，一般该目录名是以用户的账号命名。

- /root

  [<span style="color:red;font-weight:bold;">常用</span>]该目录为系统管理员，也称作超级权限者的用户主目录

- /lib

  系统开机所需要最基本的动态连接共享库，其作用类似于Windows里的DLL文件。几乎所有的应用程序都需要用到这些共享库。

- /lost+found

  这个目录一般情况下是空的，当系统非法关机后，这里就存放了一些文件。

- /etc

  [<span style="color:red;font-weight:bold;">常用</span>]所有的系统管理所需要的配置文件和子目录，比如：安装mysql数据库 my.conf

- /usr

  [<span style="color:red;font-weight:bold;">常用</span>]这是一个非常重要的目录，用户的很多应用程序和文件都放在这个目录下，类似于windows下的program files目录

- /boot

  [<span style="color:red;font-weight:bold;">常用</span>]存放的是启动Linux时使用的一些核心文件，包括一些连接文件以及镜像文件。

- /proc 

  [<span style="color:red;font-weight:bold;">不能动</span>]这个目录是一个虚拟的目录，它是系统内存的映射，访问这个目录来获取系统信息。

- /srv

  [<span style="color:red;font-weight:bold;">不能动</span>]service缩写，该目录存放一些服务启动之后需要提取的数据。

- sys

  [<span style="color:red;font-weight:bold;">不能动</span>]这是linux2.6内核的一个很大的变化。该目录下安装了2.6内核中新出现的一个文件系统sysfs。

- /tmp

  这个目录是用来存放一些临时文件的。

- /dev

  类似于windows的设备管理器，把所有的硬件用文件的形式存储。

- /media

  [<span style="color:red;font-weight:bold;">常用</span>]linux系统会自动识别一些设备，例如U盘、光驱等等，当识别后，linux会把识别的设备挂载到这个目录下。

- /mnt

  [<span style="color:red;font-weight:bold;">常用</span>]系统提供该目录是为了让用户临时挂载别的文件系统的，我们可以将外部的存储挂载在/mnt/上，然后进入该目录就可以查看里面的内容了。

- /opt

  这是给<span style="color:#32CD32;font-weight:bold;">主机额外安装软件所存放的目录（安装包资源）</span>。如安装ORACLE数据库就可以放到该目录下。默认为空。

- /usr/local

  [<span style="color:red;font-weight:bold;">常用</span>]这是另一个给<span style="color:#32CD32;font-weight:bold;">主机额外安装软件所安装的目录（安装目录）</span>。一般是通过编译源码方式安装的程序。

- /var

  [<span style="color:red;font-weight:bold;">常用</span>]这个目录中存放着在不断扩充着的东西，习惯将经常被修改的目录放在这个目录下。包括各种日志文件。

- /selinux [security-enhanced linux]

  SELinux是一种安全子系统，它能控制程序只能访问特定文件，有三种工作模式，可以自行设置。

# 第7章 Linux实操篇-开机、重启和用户注销

## 7.1 关机&重启命令

- 基本介绍

| 命令            | 作用                    |
| --------------- | ----------------------- |
| shutdown -h now | 立即关机                |
| shutdown -h 1   | “Hello,1分钟后会关机了” |
| shutdown -r now | 现在重启计算机          |
| halt            | 关机，作用和上面一样    |
| reboot          | 现在重新启动计算机      |
| sync            | 把内存的数据同步到磁盘  |

- 使用细节

1. 不管是重启系统还是关闭系统，首先要运行sync命令，把内存中的数据写到磁盘中。
2. 目前的 shutdown/reboot/halt 等命令均已经在关机前进行了sync。

 ## 7.2 用户登录和注销

- 基本介绍

1. 登录时尽量少用root账号登录，因为它是系统管理员，最大的权限，避免操作失误。可以利用普通用户登录，登录后再用“su - 用户名”命令来切换成系统管理员身份。
2. 在提示符下输入 logout 即可注销用户

- 使用细节

1. logout 注销指令在图形运行级别无效，在运行级别 3 下有效。
2. 运行级别这个概念，后面再说。

# 九十九、常用总结

## 1.1、扩展root分区

1. 查看根分区大小

```bash
df -h
```

2. 在虚拟中添加一块物理的磁盘，重启虚拟机
3. 查看磁盘编号

```bash
[root@localhost ~]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb
# /dev/sdb 是新的虚拟磁盘
```

4. 创建pv

```bash
[root@localhost ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```

5. 把pv加入vg中，相当于扩充vg的大小

- 先使用vgs查看vg组

```bash
[root@localhost ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  centos   1   6   0 wz--n- <49.00g    0 
```

- 扩展vg，使用vgextend命令

```bash
[root@localhost ~]# vgextend centos /dev/sdb
  Volume group "centos" successfully extended
```

- 我们成功把vg卷扩展了，再用vgs查看一下

```bash
vgs
```

6. 扩充lv的大小

- 查看lv

```bash
[root@localhost ~]# lvs
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home centos -wi-ao---- <5.00g                                                    
  root centos -wi-ao---- <5.00g                                                    
  swap centos -wi-ao----  5.00g                                                    
  tmp  centos -wi-ao----  2.00g                                                    
  usr  centos -wi-ao---- 30.00g                                                    
  var  centos -wi-ao----  2.00g 
```

- 扩展lv，使用lvextend命令

```bash
[root@localhost ~]# lvextend -L +20G /dev/mapper/centos-root
  Insufficient free space: 5120 extents needed, but only 5119 available
# 发现错误，修改为+19G
[root@localhost ~]# lvextend -L +19G /dev/mapper/centos-root
  Size of logical volume centos/root changed from <5.00 GiB (1279 extents) to <24.00 GiB (6143 extents).
  Logical volume centos/root successfully resized.
```

7. 命令使系统重新读取大小

```bash
[root@localhost ~]# xfs_growfs /dev/mapper/centos-root 
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=327424 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=1309696, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 1309696 to 6290432
```

8. 最后查看根分区大小

```bash
df -h
```



## 1.2、centos7配置用户打开文件数和进程数

- 查看用户最大文件打开数和最大可用进程数

```bash
# 注意，查看具体用户的信息，需要以相应用户执行命令；root用户查看的，只是root用户的。
[root@emon ~]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 160002
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 800000
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 655360
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

- 查看用户最大文件打开数

```bash
[root@emon ~]# ulimit -n
800000
# 查看软限制
[root@emon ~]# ulimit -Sn
800000
# 查看硬限制
[root@emon ~]# ulimit -Hn
800000
```

- 查看用户最大可用进程数

```bash
[root@emon ~]# ulimit -u
655360
# 查看软限制
[root@emon ~]# ulimit -Su
655360
# 查看硬限制
[root@emon ~]# ulimit -Hu
655360
```

- 配置位置之`/etc/security/limits.conf`和`/etc/security/limits.d/`目录下的配置
  - 如果`/etc/security/limits.d/`存在，则`/etc/security/limits.conf`无效
  - 在`/etc/security/limits.d/`目录下，可用配置：
    - `/etc/security/limits.d/20-nproc.conf`
    - `/etc/security/limits.d/20-nofile.conf`
- 系统级别最大用户可用进程

```bash
cat /proc/sys/kernel/threads-max
```

- 查看全局的pid_max方法

```bash
cat /proc/sys/kernel/pid_max
```

- 系统级别最大用户可打开文件数

```bash
cat /proc/sys/fs/file-max
```

- 查询某个进程最大可打开文件数和进程数

```bash
cat /proc/45602/limits
```

- 查看某个进程当前打开的文件数

```bash
lsof -p 45602|wc -l
```



## 

