#  Linux学习

[[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

Linux教程视频地址

https://www.bilibili.com/video/BV1Sv411r7vd?spm_id_from=333.788.player.switch&vd_source=b850b3a29a70c8eb888ce7dff776a5d1&p=60



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



# 第5章 Linux实操篇-远程登录

# 第6章 Linux实操篇-Vim

<div style="text-align:center;font-weight:bold;">Vim键盘图</div>

![img](images/vi-vim-cheat-sheet-sch1.gif)



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
2. 目前的 shutdown/reboot/halt 等命令均已经在关机前进行了sync。<span style="color:red;font-weight:bold;">小心驶得万年船，还是建议关机重启前执行sync</span>

 ## 7.2 用户登录和注销

- 基本介绍

1. 登录时尽量少用root账号登录，因为它是系统管理员，最大的权限，避免操作失误。可以利用普通用户登录，登录后再用“su - 用户名”命令来切换成系统管理员身份。用完后通过exit/logout退出回到之前用户。
2. 在提示符下输入 logout 即可注销用户

- 使用细节

1. logout 注销指令在图形运行级别无效，在运行级别 3 下有效。
2. 运行级别这个概念，参考8.10章节。

# 第8章 Linux实操篇-实用指令

## 8.1 基本介绍

​	Linux系统是一个多用户多任务的操作系统，任何一个要使用系统资源的用户，都必须首先向系统管理员申请一个账号，然后以这个账号的身份进入系统。

## 8.2 添加用户

- 基本语法

```bash
% useradd 用户名
```

- 细节说明

1. 当创建用户成功后，会自动的创建和用户同名的家目录
2. 也可以通过 `useradd -d 指定目录 新的用户名`，给新创建的用户指定家目录

## 8.3  修改用户密码

- 基本语法

```bash
% passwd 用户名
```

## 8.4 删除用户

- 基本语法

```bash
# 默认保留家目录 
% userdel 用户名
# 删除用户及其家目录
% userdel -r 用户名
```

## 8.5 查询用户信息指令

- 基本语法

```bash
% id 用户名
```

- 细节说明

​	当用户不存在时，返回无此用户。

## 8.6 切换用户

- 介绍

​	在操作Linux中，如果当前用户的权限不够，可以通过 `su - 指令`，切换到高权限用户，比如：root。

- 基本语法

```bash
% su - 切换用户名
```

- 细节说明

1. 从权限高的用户切换到权低的用户，不需要输入密码，反之需要。
2. 当需要返回到原来用户时，使用 exit/logout 指令

## 8.7 查看当前用户/登录用户

- 基本语法

```bash
# 查询当前是什么用户身份
% whoami 
# 查询是什么用户身份登录的，以及登录时间
% who am i
```

## 8.8 用户组

- 介绍

​	类似于角色，系统可以对有共性的多个用户进行统一的管理。

- 新增组

```bash
% groupadd 组名
```

- 删除组

```bash
% groupdel 组名
```

- 增加用户时直接加上组

```bash
% useradd -g 用户组 用户名
```

- 修改用户的组

```bash
% usermod -g 用户组 用户名 
```

## 8.9 用户和组相关文件

- /etc/passwd 文件

用户（user）的配置文件，记录用户的各种信息。

每行的含义：<span style="color:#1E90FF;">用户名:口令:用户标识号:组标识号:注释性描述:主目录:登录Shell</span>

- /etc/shadow 文件

口令的配置文件

每行的含义：<span style="color:#1E90FF;">登录名:加密口令:最后一次修改时间:最小时间间隔:最大时间间隔:警告时间:不活动时间:失效时间:标志
</span>

- /etc/group 文件

组（group）的配置文件，记录Linux包含的组的信息

每行含义：<span style="color:#1E90FF;">组名:口令:组标识号:组内用户列表
</span>

# 第9章 Linux实操篇-实用指令

## 9.1 指定运行级别

- 基本介绍

运行级别说明：

0 ：关机

1 ：单用户（<span style="color:red;font-weight:bold;">找回丢失密码</span>）

2 ：多用户状态没有网络服务

3 ：多用户状态有网络服务

4 ：系统未使用保留给用户

5 ：图形界面

6 ：系统重启

常用运行级别是3和5，也可以指定默认运行级别，后面演示。

```bash
% init 3
```

- 应用实例

命令 ：init[0123456]

应用案例 ：通过init来切换不同的运行级别。比如，从5到3，然后关机。

```bash
# 图形界面，打开终端，执行切换
% init 3
# 多用户状态有网络服务模式下，执行切换
% init 5
```

- CentOS7之前如何指定运行级别？

在CentOS7之前，在 /etc/inittab 文件中。

- CentOS7及之后如何指定运行级别？

  - 默认级别说明
    - <span style="color:blue;">multi-user.target</span> : analogous to runlevel 3
    - <span style="color:blue;">graphical.target</span> : analogous to runlevel 5

  

  - 查看默认级别

  ```bash
  % systemctl get-default
  ```

  - 设置默认级别为 3

  ```bash
  % systemctl set-default multi-user.target
  ```

## 9.2 如何找回root密码

1. 首先，启动系统，进入开机界面，在界面中按“e”进入编辑界面。（可以先上下箭头选择内核，阻止倒计时，然后从容输入 e 进入编辑界面）。

![image-20241226090713041](images/image-20241226090713041.png)

2. 进入编辑界面，使用键盘上的上下键把光标往下移动，找到如下图所示的行，在行的最后面输入： `init=/bin/sh`

![image-20241226091417906](images/image-20241226091417906.png)

3. 接着，输入完成后，直接按快捷键：Ctrl+x进入单用户模式。
4. 接着，在光标闪烁的位置中输入：`mount -o remount,rw /`（注意：各个单词之间有空格），完成后按键盘的回车键（Enter）。如下图。

![image-20241226091851641](images/image-20241226091851641.png)

5. 在新的一行最后面输入：passwd，完成后按键盘的回车键（Enter）。输入密码，然后再次确认密码即可），密码修改成功后，会显示 passwd 的字样，说明密码修改成功。

![image-20241226092116858](images/image-20241226092116858.png)

6. 接着，在鼠标闪烁的位置中（最后一行中）输入：`touch /.autorelabel`（注意：touch与 、 之间有一个空格），完成后按键盘的回车键（Enter）。

![image-20241226092549058](images/image-20241226092549058.png)

![image-20241226093542808](images/image-20241226093542808.png)

7. 继续在光标闪烁的位置中，输入：`exec /sbin/init`（注意：exec 与 / 之间有一个空格），完成后按键盘的回车键（Enter），等待系统自动修改密码（<span style="color:red;font-weight:bold;">这个过程时间可能有点长，耐心等待，不要以为死机了。</span>），完成后，系统会自动重启，新的密码生效了。

![image-20241226093626504](images/image-20241226093626504.png)

## 9.3 帮助指令

### 9.3.1 man 获得帮助信息

基本语法：man [命令或配置文件] (功能描述：获得帮助信息)

案例：查看 ls 命令的帮助信息

```bash
% man ls
```

### 9.3.2 Help 指令

基本语法：help 命令 （功能描述：获得shell内置命令的帮助信息）

```bash
% help cd
```

## 9.4 文件目录类

### 9.4.1 pwd 指令

基本语法：pwd （功能描述：显示当前工作目录的绝对路径）

### 9.4.2 ls 指令

基本语法：ls [选项] [目录或文件]

常用选项：

-l ：以列表的方式显示信息。

-a ：显示当前目录所有的文件和目录，包括隐藏的。

-h ：以人类宜读的方式显示大小尺寸。

-R ：递归处理。

### 9.4.3 cd 指令

基本语法：cd [参赛] (功能描述：切换到指定目录)

理解：绝对路径和相对路径。

```bash
# 回到自己的家目录
% cd ~ 或 cd
# 回到当前目录的上级目录
% cd ..
```

### 9.4.4 mkdir 指令

基本语法：mkdir [选项] 要创建的目录

常用选项：-p 创建多级目录。

```bash
% mkdir /home/dog
% mkdir -p /home/animal/tiger
% mkdir /home/animal/{lion,leopard}
```

### 9.4.5 rmdir 指令

基本语法：rmdir [选项] 要删除的空目录。

使用细节：rmdir 删除的是空目录，如果目录下有内容时无法删除。若要删除非空目录，需要 rm -rf 要删除的目录。

```bash
% rmdir /home/dog
% rm -rf /home/animal
```

### 9.4.6 touch 指令

基本语法：touch 文件名称

```bash
% touch /home/ hello.txt
```

### 9.4.7 cp 指令

基本语法：cp [选项] source dest

常用选项：-r 递归复制整个文件夹

```bash
% cp /home/hello.txt /home/bbb
# 递归复制
% cp -r /home/bbb /opt
# 递归复制，遇到同名直接覆盖不用提示
% \cp -r /home/bbb /opt
```

### 9.4.8 rm指令

说明：rm指令移除文件或目录。

- 基本语法：

rm [选项] 要删除的文件或目录

- 常用选项：

-r ：递归删除整个文件夹

-f ：强制删除不提示

```bash
% rm /home/hello.txt 
% rm -rf /opt/bbb/
```

### 9.4.9 mv 指令

说明：mv指令移动文件与目录或重命名

- 基本语法

```bash
# 重命名
% mv oldNameFile newNameFile
# 移动文件
% mv /temp/movefile /targetFolder
```

### 9.4.10 cat 指令

cat 查看文件内容。

- 基本语法

cat [选项] 要查看的文件

- 常用选项

-n ：显示行号

- 使用细节

cat 只能浏览文件，而不能修改文件，为了浏览方便，一般会带上管道命令 | more

```bash
% cat -n /etc/profile | more
```

### 9.4.11 more 指令

more 指令是一个基于VI编辑器的文本过滤器，它以全屏幕的方式按页显示文本文件的内容。more指令中内置了若干快捷键，详见操作说明：

- 基本语法

more 要查看的文件

- 操作说明

| 操作          | 功能说明                             |
| ------------- | ------------------------------------ |
| 空白键(space) | 代表向下翻一页                       |
| Enter         | 代表向下翻【一行】                   |
| q             | 代表立刻离开more，不再显示该文件内容 |
| Ctrl+F        | 向下滚动一屏                         |
| Ctrl+B        | 返回上一屏                           |
| =             | 输出当前行的行号                     |
| :f            | 输出文件名和当前行的行号             |

- 应用案例

案例：采用 more 查看文件 /etc/profile

### 9.4.12 less 指令

less 指令用来分屏查看文件内容，它的功能与more命令类似，但是比more指令更加强大，支持各种显示终端。less指令在显式文件内容时，并不是一次将整个文件加载之后才显示，而是根据显示需要加载内容，对于显示大型文件具有较高的效率。

- 基本语法

```bash
% less 要查看的文件
```

- 操作说明

| 操作       | 功能说明                                          |
| ---------- | ------------------------------------------------- |
| 空白键     | 向下翻动一页                                      |
| [pagedown] | 向下翻动一页                                      |
| [pageup]   | 向上翻动一页                                      |
| /子串      | 向下搜寻【字典】的功能；n：向下查看；N：向上查找  |
| ?子串      | 向上搜寻【字典】的功能；n : 向上查找；N：向下查找 |
| q          | 离开less这个程序                                  |

### 9.4.13 echo 指令

echo输出内容到控制台。

- 基本语法

echo [选项] [输出内容]

```bash
% echo $PATH
% echo hello,world!
% echo "hello,world\!"
```

### 9.4.14 head 指令

head用于显示文件的开头部分内容，默认情况下head指令显示文件的前10行内容。

- 基本语法

  - `head 文件` （功能描述：查看文件头10行内容）

  - `head -n 5 文件` （功能描述：查看文件头5行内容，5可以是任意行数）

```bash
% head -n 5 /etc/profile
```

### 9.4.15 tail 指令

tail用于输出文件中尾部的内容，默认情况下tail指令显示文件的前10行内容。

- 基本语法

  - `tail 文件` （功能描述：查看文件尾10行内容）

  - `tail -n 5 文件` （功能描述：查看文件尾5行内容，5可以是任意行数）

  - `tail -f 文件` （功能描述：实时追踪该文件的所有更新）

```bash
% tail -n 5 /etc/profile
```

### 9.4.16 > 指令 和 >> 指令

`>` 输出重定向

`>>` 追加

- 基本语法

  - `ls -l > 文件` （功能描述：列表的内容写入文件a.txt中（覆盖写））

  - `ls -la >> 文件` （功能描述：列表的内容追加到文件aa.txt的末尾）

  - `cat 文件1 > 文件2` （功能描述：将文件1的内容覆盖到文件2）

  - `echo "内容" >> 文件` （功能描述：将“内容”追加到文件）

### 9.4.17 ln 指令

软连接也称为符号链接，类似于windows里的快捷方式，主要存放了链接其他文件的路径。

- 基本语法

`ln -s [原文件或目录] [软连接名] `（功能描述：给原文件创建一个软连接）

```bash
% ln -s /root/ myroot
```

### 9.4.18 history 指令

history 查看已经执行过的历史命令，也可以执行历史命令

- 基本语法

history （功能描述：查看已经执行过的历史命令）

```bash
% history
# 显示最近使用过的10个指令
% history 10
# 执行历史编号为5的指令
% !5
```

## 9.5 时间日期类

### 9.5.1 date指令

- 基本语法

1. `date` （功能描述：显示当前日期）
2. `date +%Y` （功能描述：显示当前年份）
3. `date +%m` （功能描述：显示当前月份）
4. `date +%d`（功能描述：显示当前是哪一天）
5. `date "+%Y-%m-%d %H:%M:%S"` （功能描述：显示年月日时分秒）

6. `date -s 字符串时间` （功能描述：设置系统当前时间，比如：2024-12-27 12:42:50）

### 9.5.2 cal 指令

查看日历指令。

- 基本语法

cal [选项] （功能描述：不加选项，显示本月日历）

 ```bash
 % cal
 % cal 2020
 ```

## 9.6 查找类

### 9.6.1 find 指令

find指令将从指定目录向下递归地遍历其各个子目录，将满足条件的文件或者目录显示在终端。

- 基本语法

find [搜索范围] [选项]

- 选项说明

| 选项             | 功能                                            |
| ---------------- | ----------------------------------------------- |
| -name <查询方式> | 按照指定的文件名查找模式查找文件                |
| -user <用户名>   | 查找属于指定用户名所有文件                      |
| -size <文件大小> | 按照指定的文件大小查找文件，+n大于 -n小于 n等于 |

- 应用实例

```bash
% find /home -name hello.txt 
% find /opt -user nobody
% find / -size +200M
```

### 9.6.2 locate 指令

​	locate指令可以快速定位文件路径。locate指令利用事先建立的系统中所有文件名称及路径的locate数据库实现快速定位给定的文件。locate指令无需遍历整个文件系统，查询速度较快。为了保证查询结果的准确度，管理员必须定期更新locate时刻。

**基本语法**

 locate 搜索文件

**特别说明**

由于locate指令基于数据库进行查询，所以第一次运行前，必须使用 updatedb 指令创建 locate 数据库。

**应用实例**

- 案例1：请使用locate指令快速定位 hello.txt 文件所在目录。

```bash
% locate hello.txt
```

### 9.6.3 which 指令

which 查看指令所在的位置。 

```bash
% which ls
```

### 9.6.4 whereis 指令

### 9.6.5 grep 指令和管道符号 |

grep 过滤查找，管道符 `|` 表示将前一个命令的处理结果输出传递给后面的命令处理。

**基本语法**

grep [选项] 查找内容 源文件

**常用选项**

| 选项 | 功能               |
| ---- | ------------------ |
| -n   | 显示匹配行及行号。 |
| -i   | 忽略字母大小写。   |

**应用实例**

- 案例1：请在hello.txt文件中，查找 ”yes“ 所在行，并显示行号。

```bash
% grep -n yes hello.txt
```

## 9.7 压缩和解压类

### 9.7.1 gzip/gunzip 指令

​	gzip 用于压缩文件， gunzip 用于解压文件。

**基本语法**

gzip 文件 （功能描述：压缩文件，只能将文件压缩为*.gz文件）

gunzip 文件.gz （功能描述：解压缩文件）

**应用实例**

- 案例1：gzip压缩，将/home下的hello.txt文件进行压缩。

```bash
% gzip hello.txt
```

- 案例2：gunzip解压缩，将 /hom下的hello.txt.gz 文件进行解压缩。

```bash
% gunzip hello.txt.gz 
```

### 9.7.2 zip/unzip指令

zip用于压缩文件，unzip用于解压缩，这个在项目打包发布中很有用。

**基本语法**

`zip [选项] xxx.zip 将要压缩的内容` （功能描述：压缩文件和目录的命令）

`unzip [选项] xxx.zip` （功能描述：解压缩文件）

**zip常用选项**

-r ：递归压缩，即压缩目录。

**unzip常用选项**

-d <目录> ：指定解压后文件的存放目录。

**应用实例**

- 案例1：将 /home 下的所有文件进行压缩成 myhome.zip

```bash
# 压缩/home目录及其下的内容
% zip -r myhome.zip /home/
```

- 案例2：将 myhome.zip 解压到 /opt/tmp 目录下

```bash
% unzip -d /opt/tmp myhome.zip
```

### 9.7.3 tar指令

tar指令是打包指令，最后打包后的文件是.tar.gz的文件

**基本语法**

`tar [选项] xxx.tar.gz 打包的内容` （功能描述：打包目录，压缩后的文件格式.tar.gz）

**选项说明**

| 选项 | 功能               |
| ---- | ------------------ |
| -c   | 产生.tar打包文件   |
| -v   | 显示详细信息       |
| -f   | 指定压缩后的文件名 |
| -z   | 打包同时压缩       |
| -x   | 解包.tar文件       |
| -C   | 指定解压目录       |

**应用实例**

- 案例1：压缩多个文件，将 /home/pig.txt 和 /home/cat.txt 压缩成 pc.tar.gz

```bash
% tar -zcvf pc.tar.gz /home/pig.txt /home/cat.txt
```

- 案例2：将 /home 的文件夹压缩成 myhome.tar.gz

```bash
% tar -zcvf myhome.tar.gz /home
```

- 案例3：将 pc.tar.gz 解压到当前目录

```bash
% tar -zxvf pc.tar.gz
```

- 案例4：将 myhome.tar.gz 解压到 /opt/tmp2 目录下

```bash
% tar -zxvf myhome.tar.gz -C /opt/tmp2
```

# 第10章 Linux实操篇-组管理和权限管理

 ## 10.1 Linxu组基本介绍

在linux中的每个用户必须属于一个组，不能独立于组外。在linux中每个文件有所有者、所在组、其它组的概念。
## 10.2 文件/目录 所有者

一般为文件的创建者，谁创建了该文件，就自然的成为该文件的所有者。

- 查看文件的所有者

```bash
% ls -lah
```

![image-20241229133538841](images/image-20241229133538841.png)

- 修改文件所有者

`chown 用户名 文件名`

```bash
% chown tom apple.txt 
```

## 10.3 文件/目录 所在组

当某个用户创建了一个文件后，这个文件的所在组就是该用户所在的组。

- 查看文件/目录所在组

```bash
% ls -lah
```

 ![image-20241229140018581](images/image-20241229140018581.png)

- 修改文件所在的组

`chgrp 组名 文件名`

```bash
% chgrp tom apple.txt
```

## 10.3 文件/目录 其他组

除文件的所有者和所在组的用户外，系统的其它用户都是文件的其它组。

**如何改变用户所在组？**

在添加用户时，可以指定该用户添加到哪一个组，同样的用root的管理权限可以改变某个用户所在的组。

- 改变用户所在组  

1. usermod -g 组名 用户名

- 应用实例

将zwj这个用户从原来所在组，修改到wudang组。

```bash
% usermod -g wudang zwj
```

## 10.4 权限的基本介绍

ls -l 中显示的内容如下：

```bash
-rw-------. 1 root root 1606 12月 22 19:46 anaconda-ks.cfg
```

0-9位说明：

- 第0位确定文件类型（d,-,l,c,b）
  - l是链接，相当于windows的快捷方式。
  - d是目录，相当于windows的文件夹。
  - c是字符设备文件，鼠标，键盘。
  - b是块设备，比如硬盘。
- 第1-3位确定所有者（该文件的所有者）拥有该文件的权限。--user
- 第4-6位确定所属组（同用户组的）拥有该文件的权限。--group
- 第7-9位确定其他用户拥有该文件的权限。--other

 ## 10.5 rwx权限详解

- rwx作用到文件
  1. r 代表可读：可以读取、查看
  2. w 代表可写：可以修改，但是不代表可以删除该文件，删除一个文件的前提条件是对该文件所在的目录有写权限，才能删除该文件。
  3. x 代表可执行：可以被执行。
- rwx作用到目录
  1. r 代表可读：可以读取，ls查看目录内容。
  2. w 代表可写：可以修改，对目录内创建+删除+重命名目录。
  3. x 代表可执行：可以进入该目录。

## 10.6 文件及目录权限实际案例

- ls -l中显示的内容如下

```bash
-rwxrw-r--. 1 root root   80 12月 28 01:28 abc
```

1. 10个字符确定不同用户能对文件干什么。

第一个字符代表文件类型：- l d c b

其余字符每3个一组（rwx）读（r）写（w）执行（x）

第一组rwx：文件拥有者的权限是读、写和执行。

第二组rw-：与文件拥有者同一组的用户的权限是读、写但不能执行。

第三组r--：不与文件拥有者同组的其它用户的权限是读，不能写和执行。

2. 可用数字表示为：r=4,w=2,x=1 因此rwx=4+2+1=7
3. 其他说明

1				文件：硬链接数 或目录：子目录数

root		  	用户

root		  	组

80		     	文件大小（字节），如果是文件夹，显示4096字节

12月 28 01:28	最后修改日期

abc			  文件名

## 10.7 修改权限-chmod

- 基本说明：

通过chmod指令，可以修改文件或者目录的权限。

**第一种方式：+、-、=变更权限**

u:所有者 g:所有组 o:其他人 a:所有人（u、g、o的总和）

1）chmod u=rwx,g=rx,o=x 文件/目录名

2）chmod o+w 文件/目录名

3）chmod a-x 文件/目录名

- 案例演示

1. 给abc文件的所有者读写执行的权限，给所在组读执行权限，给其他组读执行权限。

```bash
% chmod u=rwx,g=rx,o=rx abc
```

2. 给abc文件的所有者除去执行的权限，增加组写的权限。

```bash
% chmod u-x,g+w abc
```

3. 给abc文件的所有用户添加读的权限

```bash
% chmod a+r abc
```

**第二种方式：通过数字变更权限**

r=4,w=2,x=1 因此rwx=4+2+1=7

chmod u=rwx,g=rx,o=x 文件目录名

相当于 chmod 751 文件目录名

- 案例演示

1. 要求：将 /home/abc.txt 文件的权限修改成 rwxr-xr-x，使用数字方式实现。

```bash
% chmod 755 /home/abc.txt 
```

## 10.8 修改文件所有者-chown

- 基本介绍

`chown newowner 文件/目录 改变所有者`

`chown newowner:newgroup 文件/目录 改变所有者和所在组`

-R 如果是目录，则使其下所有子文件或目录递归生效。

- 案例演示

1. 请将 /home/abc.txt 文件的所有者修改成 tom

```bash
% chown tom /home/abc.txt
```

2. 请将 /home/kkk 目录下所有的文件和目录的所有者都修改成tom

```bash
% chown -R tom /home/kkk
```

## 10.9 修改文件/目录所在组-chgrp

- 基本介绍

`chgrp newgroup 文件/目录` 改变所在组

- 案例演示

1. 请将 /home/abc.txt 文件的所在组修改成 shaolin（少林）

```bash
% chgrp shaolin /home/abc.txt
```

2. 请将 /home/kkk 目录下所有的文件和目录的所在组都修改成 shaolin（少林）

```bash
% chgrp -R shaolin /home/kkk
```

## 10.10 最佳实践-警察和土匪游戏

police, bandit

jack,jerry:警察

xh,xq:土匪

1. 创建组

```bash
% groupadd police
% groupadd bandit
```

2. 创建用户

```bash
% useradd -g police jack
% useradd -g police jerry
% useradd -g bandit xh
% useradd -g bandit xq
```

3. jack创建一个文件，自己可以读写，本组人可以读，其它组没任何权限。

```bash
% jack登录
% vim jack.txt 
% chmod 640 jack.txt
```

4. jack修改该文件，让其它组人可以读，本小组人可以读写。

```bash
% chmod g+rw,o+r jack.txt
```

5. xh投靠警察，看看是否可以读写。

```bash
% usermod -g police xh
```

# 第11章 Linux实操篇-定时任务调度

## 11.1 crond 任务调度

crontab 进行定时任务的设置

- 概述

任务调度：是指系统在某个时间执行的特定的命令或程序。

任务调度分类：1.系统工作；有些重要的工作必须周而复始地执行。如病毒扫描等。

个别用户工作：个别用户可能希望执行某些程序，比如对mysql数据库的备份。

- 基本语法

`crontab [选项]`

- 常用选项

| 选项 | 功能                          |
| ---- | ----------------------------- |
| -e   | 编辑crontab定时任务           |
| -l   | 查询crontab任务               |
| -r   | 删除当前用户所有的crontab任务 |

- 快速入门

设置任务调度文件：/etc/crontab

设置个人任务调度。执行`crontab -e`命令。

接着输入任务到调度文件，如：

```bash
*/1 * * * * ls -l /etc/ > /tmp/to.txt
*/1 * * * * /home/time.sh
```

- 参数细节说明

5个占位符的说明。

| 项目       | 含义                 | 范围                    |
| ---------- | -------------------- | ----------------------- |
| 第一个 "*" | 一小时当中的第几分钟 | 0-59                    |
| 第二个 "*" | 一天当中的第几小时   | 0-23                    |
| 第三个 "*" | 一个月当中的第几天   | 1-31                    |
| 第四个 "*" | 一年当中的第几月     | 1-12                    |
| 第五个 "*" | 一周当中的星期几     | 0-7（0和7都代表星期日） |

- 特殊符号的说明

| 特殊符号 | 含义                                                         |
| -------- | ------------------------------------------------------------ |
| *        | 代表任何时间。比如第一个 "*" 就代表一小时中每分钟都执行一次的意思。 |
| ,        | 代表不连续的时间。比如 "0 8,12,16 * * * 命令"，就代表在每天的8点0分、12点0分、16点0分都执行一次命令 |
| -        | 代表连续的时间范围，比如"0 5 * * 1-6 命令"，代表在周一到周六的凌晨5点0分执行命令。 |
| */n      | 代表每隔多久执行一次。比如 "*/10 * * * * 命令",代表每隔10分钟就执行一遍命令。 |

- 重启任务调度

```bash
% service crond restart
```

## 11.2 at定时任务

- 基本介绍

1. at命令是一次性定时计划任务，at的守护进程atd会以后台模式运行，检查作业队列来运行。
2. 默认情况下，atd守护进程每60秒检查作业队列，有作业时，会检查作业运行时间，如果时间与当前时间匹配，则运行此作业。
3. at命令是一次性定时计划任务，执行完一个任务后不再执行此任务了。

4. 在使用at命令的时候，一定要保证atd进程的启动，可以使用相关指令来查看。

```bash
% ps -ef|grep atd
root      1548     1  0 12月28 ?      00:00:00 /usr/sbin/atd -f
root     14306 11352  0 22:55 pts/1    00:00:00 grep --color=auto atd
```

- at命令格式

`at [选项] [时间]`

执行2次 `Ctrl + D` 结束at命令的输入。

- at命令选项

| 选项          | 含义                                                       |
| ------------- | ---------------------------------------------------------- |
| -m            | 当指定的任务被完成后，将给用户发送邮件，即使没有标准输出。 |
| -l            | 小写字母L，atq的别名。                                     |
| -d            | atrm的别名。                                               |
| -v            | 显示任务将被执行的时间。                                   |
| -c            | 打印任务的内容到标准输出。                                 |
| -V            | 显示版本信息。                                             |
| -q <队列>     | 使用指定的队列.                                            |
| -f <文件>     | 从指定文件读入任务而不是从标准输入读入。                   |
| -t <时间参赛> | 以时间参赛的形式提交要运行的任务。                         |

- at时间定义

at指定时间的方法：

1. 接受在当天的hh:mm （小时:分钟) 式的时间指定。假如该时间已经过去，那么就放在第二天执行。例如：04:00
2. 使用midnight（深夜），noon（中午），teatime（饮茶时间，一般是下午4点）等比较模糊的词语来指定时间。
3. 采用12小时计时制，即在时间后面加上AM（上午）或PM（下午）来说明是上午还是下午。例如：12pm
4. 指定命令执行的具体日期，指定格式为month day（月日）或mm/dd/yy（月/日/年）或dd.mm.yy（日.月.年），指定的日期必须跟在指定时间的后面。例如：04:00 2021-03-1

5. 使用相对计时法。指定格式为：now + count time-units，now就是当前时间，time-units是时间单位，这里能够是minutes（分钟）、hours（小时）、days（天）、weeks（星期）。count是时间的数量，几天，几小时。例如：now + 5 minutes
6. 直接使用today（今天）、tomorrow（明天）来指定完成命令的时间。

- 应用实例

1. 案例1：2天后的下午5点执行 /bin/ls /home

```bash
# 编写完成后，输入2次Ctrl+D（在/home后面，输入2次Ctrl+D后得到<EOT>）
% at 5pm + 2 days
at> /bin/ls /home<EOT>
job 1 at Tue Dec 31 17:00:00 2024 
```

2. 案例2：`atq`命令来检查系统中没有执行的工作任务

```bash
% atq
1       Tue Dec 31 17:00:00 2024 a root
% at -l
1       Tue Dec 31 17:00:00 2024 a root
```

3. 案例3：明天17点钟，输出时间到指定文件内，比如 /root/date100.log

![image-20241229233300936](images/image-20241229233300936.png)

4. 案例4:2分钟后，输出时间到指定文件内，比如 /root/date200.log

```bash
% at now + 2 minutes
at> date > /root/date200.log<EOT>
job 3 at Sun Dec 29 23:36:00 2024
```

5. 案例5：删除已经设置的任务，`atrm 编号`

```bash
% atrm 2
% at -d 1
```

# 第12章 Linux实操篇-Linux磁盘分区、挂载

## 12.1 Linux分区

- 原理介绍

1. Linux来说无论有几个分区，分给哪一个目录使用，它归根结底就只有一个目录，一个独立且唯一的文件结构，Linux中每个分区都是用来组成整个文件系统的一部分。
2. Linux采用了一种叫做”载入“的处理方法，它的整个文件系统中包含了一整套的文件和目录，且将一个分区和一个目录联系起来。这时要载入的一个分区将使它的存储空间在一个目录下获得。

- 查看所有设备挂载情况

命令：`lsblk`或`lsblk -f`

<img src="images/image-20241229235008254.png" alt="image-20241229235008254" style="zoom:50%;" />

- 硬盘说明

1. Linux硬盘分IDE硬盘和SCSI硬盘，目前基本上是SCSI硬盘。
2. 对于IDE硬盘，驱动器标识符为”hdx~“，其中”hd“表明分区所在设备的类型，这里是指IDE硬盘了。”x“为盘号（a为基本盘，b为基本从属盘，c为辅助主盘，d为辅助从属盘），”~“代表分区，前四个分区用数字1到4表示，它们是主分区或扩展分区，从5开始就是逻辑分区。例，hda3表示为第一个IDE硬盘上的第三个主分区或扩展分区，hdb2表示为第二个IDE硬盘上的第二个主分区或扩展分区。
3. 对于SCSI硬盘则标识为”sdx~“，SCSI硬盘是用”sd“来表示分区所在设备的类型的，其余则和IDE硬盘的表示方法一样。
4. NVMe 硬盘，nvme0n1 这个磁盘名是 NVMe Disk 0 Namespace 1 的缩写，意思是第一个 NVMe 硬盘的第一个命名空间1。每个 NVMe 硬盘上的分区通过在磁盘名后面加上一个 p 和一个十进制数字表示，例如 nvme0n1p1 和 nvme0n1p2 表示系统中第一个 NVMe 硬盘的第一个命名空间的第一个和第二个分区。

## 12.2 挂载的经典案例

- 说明

下面我们以增加一块硬盘为例来熟悉下磁盘的相关指令和深入理解磁盘分区、挂载、卸载的概念。

**如何增加一块硬盘**

1. 虚拟机添加硬盘

   1. 关闭虚拟机
   2. 在【虚拟机】菜单中，选择【设置】，然后设备列表里添加硬盘，然后一路【下一步】，中间只有选择硬盘大小的地方需要修改，直到完成。然后<span style="color:red;font-weight:bold;">重启系统</span>（才能识别）！

   <img src="images/image-20241230125028507.png" alt="image-20241230125028507" style="zoom:50%;" />

   <img src="images/image-20241230125101169.png" alt="image-20241230125101169" style="zoom:50%;" />

   <img src="images/image-20241230125248536.png" alt="image-20241230125248536" style="zoom:50%;" />

   ![image-20241230125810471](images/image-20241230125810471.png)

2. 分区

   1. 查看挂载的硬盘

   <img src="images/image-20241230130306500.png" alt="image-20241230130306500" style="zoom:50%;" />

   2. 分区命令

   ```bash
   % fdisk /dev/nvme0n2
   ```

   <img src="images/image-20241230132015075.png" alt="image-20241230132015075" style="zoom:50%;" />

   3. 查看挂载信息

   <img src="images/image-20241230132400388.png" alt="image-20241230132400388" style="zoom:50%;" />

3. 格式化

格式化磁盘

```bash
# xfs是分区类型
% mkfs -t xfs /dev/nvme0n2p1
meta-data=/dev/nvme0n2p1         isize=512    agcount=4, agsize=65472 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=261888, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=855, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

4. 挂载

挂载：将一个分区和一个目录联系起来。

```bash
[root@emon ~]# mkdir /newdisk
[root@emon ~]# mount /dev/nvme0n2p1 /newdisk/
[root@emon ~]# lsblk
NAME               MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
nvme0n1            259:0    0   64G  0 disk 
├─nvme0n1p3        259:3    0 62.5G  0 part 
│ ├─cl_fedora-swap 253:1    0    8G  0 lvm  [SWAP]
│ └─cl_fedora-root 253:0    0 54.5G  0 lvm  /
├─nvme0n1p1        259:1    0  500M  0 part /boot/efi
└─nvme0n1p2        259:2    0    1G  0 part /boot
sr0                 11:0    1  7.6G  0 rom  
nvme0n2            259:4    0    1G  0 disk 
└─nvme0n2p1        259:5    0 1023M  0 part /newdisk
```

 说明：如何卸载？

```bash
# 卸载方式一
% umount /dev/nvme0n2p1
# 卸载方式二
% unmount /newdisk
```

<span style="color:red;font-weight:bold;">注意：用命令行挂载重启后会失效！</span>

5. 设置虚拟机启动后自动挂载

通过修改 /etc/fstab 实现自动挂载。添加完成后，执行 mount -a 即刻生效。

```bash
% vim /etc/fstab
# 个人配置
/dev/nvme0n2p1          /newdisk                xfs     defaults        0 0
```

## 12.3 磁盘情况查询

- 查询系统整体磁盘使用情况

```bash
% df -Th
```

- 查询指定目录磁盘占用情况

```bash
% du -sh
```

查询指定目录的磁盘占用情况，默认为当前目录。

| 选项          | 含义                       |
| ------------- | -------------------------- |
| -s            | 指定目录占用大小汇总       |
| -h            | 带计量单位                 |
| -a            | 含文件                     |
| --max-depth=1 | 子目录深度（与-s互斥）     |
| -c            | 列出明细的同时，增加汇总值 |

- 应用实例

```bash
% du -h --max-depth=1 /home
```

## 12.4 磁盘情况-工作实用指令

**统计/opt文件夹下文件的个数**

```bash
% ls -l /root/ | grep "^-" | wc -l
```

**统计/opt文件夹下目录的个数**

```bash
% ls -l /root/ | grep "^d" | wc -l
```

**统计/opt文件夹下文件的个数，包括子文件夹里的**

```bash
% ls -lR /root/ | grep "^-" | wc -l
```

**统计/opt文件夹下目录的个数，包括子文件夹里的**

```bash
% ls -lR /root/ | grep "^d" | wc -l
```

**以树状显示目录结构**

```bash
# 若没有tree命令，则 yum install -y --nogpgcheck tree 安装即可
% tree /root
% tree -L 1 /root
```

# 第13章 Linux实操篇-网络配置

## 13.1 Linux网络环境配置

- 修改网卡配置文件

![image-20241231145414358](images/image-20241231145414358.png)

- 修改内容如下

![image-20241231152042388](images/image-20241231152042388.png)

- 重启网络

```bash
% systemctl restart network
# 或者
% service network restart
# 或者
% reboot
```





























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

