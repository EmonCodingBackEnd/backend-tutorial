# Docker实践

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# Vagrant的安装与使用

## 1、Vagrant是什么

Vagrant是构建在虚拟化技术之上的虚拟机运行环境管理工具。

- 建立和删除虚拟机
- 配置虚拟机运行参数
- 管理虚拟机运行状态
- 自动化配置和安装开发环境
- 打包和分发虚拟机运行环境

- Vagrant的运行，需要依赖某项具体的虚拟化技术
  - VirtualBox
  - VMWare



### 1.1、个人角度优势

- 跨平台
- 可移动
- 自动化部署无需人工参与
- 面试加分项

### 1.2公司角度

- 减少人力培训成本
- 统一开发环境

VAGRANT+Virtualbox/VMWare+ubuntu/CentOS=目标环境

## 2、Vagrant适用范围

- 开发环境
- 项目配置比较复杂



## 3、Window安装Vagrant

1. 下载

下载地址：https://www.vagrantup.com/downloads

2. 安装

双击安装，安装后提示重启计算机，重启即可！

3. 查看版本

```bash
$ vagrant --version
Vagrant 2.2.19
$ vagrant -v
Vagrant 2.2.19
```

4. 修改Vagrant box保存路径

add box的时候默认保存在用户文件夹下的`.vagrant.d`目录，通过设置VAGRANT_HOME环境变量可以改变默认位置。

VAGRANT_HOME = `D:\SharedWorkspace\.vagrant.d`

## 4、Vagrant的使用

### 4.1、使用VirtualBox创建虚拟机

#### 第一步：启动virtualbox

virtualbox安装后启动！

#### 第二步：下载box

如何查询各种boxes：https://app.vagrantup.com/boxes/search

下载地址：https://app.vagrantup.com/centos/boxes/7

根据使用的Vagrant是VirtualBox还是VMWare，选择`virtualbox`或者`vmware_desktop ` 类型的 provider下载！

下载后本地安装：

```bash
# 如果不是为了`vagrant add box boxesname boxespath`可以不下载。
vagrant box add CentOS/7 CentOS-7-x86_64-Vagrant-2004_01.VMwareFusion.box
```

#### 第三步：Vagrantfile

- 规划一个目录，作为Vagrant虚拟机目录，比如：Vagrant/centos7

如果尚未看到Vagrantfile，初始化配置Vagrantfile

```bash
vagrant init
# 或者指定boxes【推荐】
vagrant init centos/7
```

- 编辑Vagrantfile

```bash
$ vim Vagrantfile
```

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

#### 第四步：初始化机器

```bash
$ vagrant up
# 指定virtualbox这个provider【推荐】；特别说明：默认也是 virtualbox
$ vagrant up --provider virtualbox
```



### 4.2、使用VMWare创建虚拟机

#### 第一步：安装VMWare provider插件vmware-desktop

1. 下载VMWare-utility

https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility

下载后，双击安装！

2. 下载VMWare-desktop查看

```bash
$ vagrant plugin install vagrant-vmware-desktop
# 命令行输出结果
Installing the 'vagrant-vmware-desktop' plugin. This can take a few minutes...
Installed the plugin 'vagrant-vmware-desktop (3.0.1)'!
```

3. 安装VMWare并启动

双击VMWare安装后，启动！

#### 第二步：下载box

如何查询各种boxes：https://app.vagrantup.com/boxes/search

下载地址：https://app.vagrantup.com/centos/boxes/7

根据使用的Vagrant是VirtualBox还是VMWare，选择`virtualbox`或者`vmware_desktop ` 类型的 provider下载！

下载后本地安装：

```bash
# 如果不是为了`vagrant add box boxesname boxespath`可以不下载。
vagrant box add CentOS/7 CentOS-7-x86_64-Vagrant-2004_01.VMwareFusion.box
```

#### 第三步：Vagrantfile

- 规划一个目录，作为Vagrant虚拟机目录，比如：Vagrant/centos7

如果尚未看到Vagrantfile，初始化配置Vagrantfile

```bash
vagrant init
# 或者指定boxes【推荐】
vagrant init centos/7
```

- 编辑Vagrant

```bash
$ vim Vagrantfile
```

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

#### 第四步：初始化机器

```bash
# 指定vmware_desktop这个provider【推荐】
vagrant up --provider vmware_desktop
```



### 4.3、Vagrant虚拟机访问

### 4.3.1、通过vagrant ssh命令

```bash
$ vagrant ssh
[vagrant@localhost ~]$ pwd
/home/vagrant
```



### 4.3.2、通过XShell工具

#### 1.查看vagrant的ssh配置

```bash
$ vagrant ssh-config
# 命令行输出结果
Host default
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile D:/SharedWorkspace/Vagrant/centos7/.vagrant/machines/default/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

可以看到：

- HostName 127.0.0.1
- Port 2222
- IdentityFile D:/SharedWorkspace/Vagrant/centos7/.vagrant/machines/default/virtualbox/private_key

#### 2.XShell连接

![image-20220311142612246](images/image-20220311142612246.png)



![image-20220311155658798](images/image-20220311155658798.png)

点击确定后登陆，首次登陆，会提示输入密码；这时，输入密码： vagrant 即可！

#### 3.切换到root

```bash
# 密码是 vagrant
[vagrant@localhost ~]$ su - root
Password: 
Last login: Fri Mar 11 07:45:14 UTC 2022 on pts/0
[root@localhost ~]# 
```



## 5、Vagrant的常用命令

| 命令                         | 解释                                |
| ---------------------------- | ----------------------------------- |
| vagrant --version/vagrant -v | 查看当前版本                        |
| vagrant box list             | 查看目前已有的box                   |
| vagrant box add              | 新增加一个box                       |
| vagrant box remove < name >  | 删除指定box                         |
| vagrant init < boxes >       | 初始化配置vagrantfile               |
| vagrant up                   | 启动虚拟机                          |
| vagrant ssh                  | ssh登录虚拟机                       |
| vagrant suspend              | 挂起虚拟机                          |
| vagrant resume               | 唤醒虚拟机                          |
| vagrant halt                 | 关闭虚拟机                          |
| vagrant reload               | 重启虚拟机                          |
| vagratn status               | 查看虚拟机状态                      |
| vagrant destroy [name\|id]   | 删除虚拟机，如果是default可以省略id |





## 6、Vagrant Plugin命令

| 命令                                  | 解释           |
| ------------------------------------- | -------------- |
| vagrant plugin install < pluginName > | 安装插件       |
| vagrant plugin list                   | 查看安装的插件 |
| vagrant plugin uninstall              | 卸载插件       |
| vagrant plugin help                   | 查看命令用法   |



# Docker Desktop的安装与使用

1. 下载

下载地址：https://docs.docker.com/desktop/windows/install/

2. 安装

在Windows上双击安装，安装后根据提示重启电脑。

3. 解决WSL 2 installation is incomplete问题

打开Docker Desktop时提示：

![image-20220311180310750](images/image-20220311180310750.png)



首先，确保如下功能已勾选：

![image-20220311180528462](images/image-20220311180528462.png)

如果以勾选，并且WSL确实有下载，那么尝试更新WSL：

1：以管理员身份启动 powershell

2：执行

```bash
wsl --update
```



# 一、Docker的安装与配置

## 1、安装

[查看官方CentOS安装Docker教程](https://docs.docker.com/engine/install/centos/)

## 1.0、删除旧版Docker

```bash
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

如果yum报告说以上安装包未安装，未匹配，未删除任何安装包，活码环境干净，没有历史遗留旧版安装。

### 1.1、安装要求

	安装Docker的基本要求如下：

- Dockr只支持64位的CPU架构的计算机，目前不支持32位CPU
- 建议系统的Linux内核版本为3.10及以上
- Linux内核需要开启cgroups和namespace功能
- 对于非Linux内核的平台，如Microsoft Windows和OS X，需要安装使用Boot2Docker工具

### 1.2、CentOS环境下安装Docker

	Docker目前只能运行在64位平台上，并且要求内核版本不低于3.10，实际上内核版本越新越好，过低的内核版本容易造成功能不稳定。
	
	用户可以通过如下命令检查自己的内核版本详细信息：

```shell
[emon@emon ~]$ uname -a
Linux emon 3.10.0-862.el7.x86_64 #1 SMP Fri Apr 20 16:44:24 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
[emon@emon ~]$ cat /proc/version
Linux version 3.10.0-862.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC) ) #1 SMP Fri Apr 20 16:44:24 UTC 2018
```

1. 安装需要的软件包，yum-util提供yum-config-manager功能，另外两个是devicemapper驱动依赖的

```shell
[emon@emon ~]$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

2. 设置yum源

```shell
[emon@emon ~]$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

3. 可以查看所有仓库中所有docker版本，并选择安装特定的版本

```shell
[emon@emon ~]$ yum list docker-ce --showduplicates |sort -r
```

4. 安装docker

```shell
# 安装最新
[emon@emon ~]$ sudo yum install -y docker-ce
# 安装指定版本
[emon@emon ~]$ sudo yum install -y docker-ce-18.06.3.ce
```

5. 启动

```shell
[emon@emon ~]$ sudo systemctl start docker
```

6. 验证安装

```shell
[emon@emon ~]$ sudo docker version
[emon@emon ~]$ sudo docker info
[emon@emon ~]$ sudo docker run hello-world
```

### 1.3、配置docker加速器

- 配置

  - DaoCloud

  采用 DaoCloud: https://www.daocloud.io/ 提供的Docker加速器。

  登录DaoCloud，找到小火箭图标，根据说明操作：

  ```bash
  [emon@emon ~]$ curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
  docker version >= 1.12
  {"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
  Success.
  You need to restart docker to take effect: sudo systemctl restart docker
  ```

  - 阿里云

  登录阿里开发者平台： https://promotion.aliyun.com/ntms/act/kubernetes.html#industry

  点击【镜像搜索】按钮，自动跳转到控制台的镜像搜索，根据提示注册并登录：

  在左侧【镜像中心】中选择【镜像加速器】，右边是生成的加速地址：比如我的：`https://pyk8pf3k.mirror.aliyuncs.com`，执行命令配置上即可：

  ```bash
  sudo tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"]
  }
  EOF
  ```

- 查看

```bash
[emon@emon ~]$ sudo cat /etc/docker/daemon.json 
{"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
```

- 重启

```bash
[emon@emon ~]$ sudo systemctl restart docker
```

## 2、配置Docker服务

### 2.1、推荐通过配置sudo的方式：

	不推荐docker服务启动后，修改/var/run/docker.sock文件所属组为dockerroot，然后为某个user添加附加组dockerroot方式，使得docker命令在user登录后可以执行。

```shell
[emon@emon ~]$ sudo visudo
```

	找到`## Allow root to run any commands anywhere`这样的标识，在下方配置：

```shell
# 备注：如果已经赋予了ALL的操作权限，就没必要配置如下了
emon    ALL=(ALL)       PASSWD:/usr/bin/docker
```



### 2.2、配置alias

	配置永久的alias：

```shell
[emon@emon ~]$ vim .bashrc
alias docker="sudo /usr/bin/docker"
alias dockerpsf="sudo /usr/bin/docker ps --format \"table{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.RunningFor}}\t{{.Ports}}\""
```

	使之生效：

```shell
[emon@emon ~]$ source .bashrc
```

	使用示例：

```shell
[emon@emon ~]$ docker images
[sudo] emon 的密码：
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```



# 二、基本信息查看

## 1、查看Docker的基本信息

```shell
[emon@emon ~]$ docker info
Containers: 0
 Running: 0
 Paused: 0
 Stopped: 0
Images: 0
Server Version: 18.06.3-ce
Storage Driver: overlay2
 Backing Filesystem: xfs
 Supports d_type: true
 Native Overlay Diff: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins:
 Volume: local
 Network: bridge host macvlan null overlay
 Log: awslogs fluentd gcplogs gelf journald json-file logentries splunk syslog
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 468a545b9edcd5932818eb9de8e72413e616e86e
runc version: a592beb5bc4c4092b1b1bac971afed27687340c5
init version: fec3683
Security Options:
 seccomp
  Profile: default
Kernel Version: 3.10.0-1062.el7.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
CPUs: 4
Total Memory: 4.743GiB
Name: emon
ID: GN4G:MRL4:3LOQ:IHZP:CXV6:TE33:WSIG:FAYD:4UBO:3VU6:VBAZ:5I5I
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Labels:
Experimental: false
Insecure Registries:
 127.0.0.0/8
Registry Mirrors:
 http://c018e274.m.daocloud.io/
Live Restore Enabled: false
```

## 2、查看Docker版本

```shell
[emon@emon ~]$ docker version
Client:
 Version:           18.06.3-ce
 API version:       1.38
 Go version:        go1.10.3
 Git commit:        d7080c1
 Built:             Wed Feb 20 02:26:51 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server:
 Engine:
  Version:          18.06.3-ce
  API version:      1.38 (minimum version 1.12)
  Go version:       go1.10.3
  Git commit:       d7080c1
  Built:            Wed Feb 20 02:28:17 2019
  OS/Arch:          linux/amd64
  Experimental:     false
```



# 三、镜像

## 1、获取镜像

- 获取Docker Hub镜像
  - 镜像是运行容器的前提，官方的Docker Hub网站已经提供了数十万个镜像供开放下载。
  - 命令格式： `docker pull NAME[:TAG]` 其中，NAME是镜像仓库的名称（用来区分镜像），TAG是镜像的标签（往往用来表示版本信息）。通常情况下，描述一个镜像需要包括`名称+标签`信息。
  - 如果不指定TAG，默认选择latest标签，这会下载仓库中最新版本的镜像。

```shell
# 等效于 docker pull registry.hub.docker.com/ubuntu:14.04
[emon@emon ~]$ docker pull ubuntu:14.04
# 我喜欢的centos
[emon@emon ~]$ docker pull centos:7
```

- 获取其他服务器镜像

```shell
[emon@emon ~]$ docker pull hub.c.163.com/public/ubuntu:14.04
```

## 2、查看镜像

- 使用`docker images`命令列出镜像

```shel
[emon@emon ~]$ docker images
```

- 列名解析：

| 列名       | 释义                                                         |
| ---------- | ------------------------------------------------------------ |
| REPOSITORY | 来自于哪个仓库，比如ubuntu仓库用来保存ubuntu系列基础镜像     |
| TAG        | 镜像的标签信息，比如14.04、latest用来标注不同的版本信息。标签只是标记，不标识镜像内容 |
| IMAGE ID   | 镜像的ID（唯一标识镜像），比如ubuntu:14.04的唯一标志是 971bb384a50a |
| CREATED    | 创建时间，说明镜像最后的更新时间                             |
| SIZE       | 镜像大小，优秀的镜像往往体积比较小                           |

- 命令支持的选项

| 参数名称                | 参数作用                                                     |
| ----------------------- | ------------------------------------------------------------ |
| -a, --all=true\|false   | 列出所有的镜像文件（包括临时文件），默认为否                 |
| --digests=true\|false   | 列出镜像的数字摘要值，默认为否                               |
| -f, --filter=[]         | 过滤列出的镜像，如dangling=true只显示没有被使用的镜像；也可以指定带有特定标注的镜像等 |
| --format="TEMPLATE"     | 控制输出格式，例如`.ID`代表ID信息，`.Repository`代表仓库信息等 |
| --no-trunc=true\|false  | 对输出结果中太长的部分是否进行截断，如镜像的ID信息，默认为是 |
| -q, --quiet=true\|false | 仅输出ID信息，默认为否                                       |

	其中，对输出结果进行控制的选项如-f, --filter=[]、--no-trunc=true|false、-q, --quiet=true|false等，对大部分子命令都支持。

## 3、为镜像添加标签Tag

	为了方便在后续工作中使用特定镜像，还可以使用`docker tag`命令来为本地镜像任意添加新的标签。

```shell
[emon@emon ~]$ docker tag centos:7 centos:7.8
[emon@emon ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7                   b5b4d78bc90c        2 days ago          203MB
centos              7.8                 b5b4d78bc90c        2 days ago          203MB
```

## 4、使用`inspect`命令查看详细信息

```shell
[emon@emon ~]$ docker inspect centos:7
```

## 5、搜寻镜像

	使用docker search命令可以搜索远端仓库中共享的镜像，默认搜索官方仓库中的镜像。支持的参数主要包括：

| 参数名称                          | 参数作用                                                     |
| --------------------------------- | ------------------------------------------------------------ |
| --filter=is-automated=true\|false | 仅显示自动创建的镜像，默认为否                               |
| --no-trunc=true\|false            | 输出信息不截断显示，默认为否                                 |
| --filter=stars=3                  | 指定仅显示评价为指定星级以上的镜像，默认为0，即输出所有镜像。 |

示例：

```shell
[emon@emon ~]$ docker search --filter=is-automated=true --filter=stars=3 nginx
```

## 6、删除镜像

- 使用标签删除镜像，命令格式： `docker rmi IMAGE [IMAGE...]`，其中IMAGE可以是标签或者ID

```shell
[emon@emon ~]$ docker rmi centos:7.8
[emon@emon ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7                   b5b4d78bc90c        2 days ago          203MB
```

- 使用镜像ID（或者部分ID串前缀）删除镜像

```shell
[emon@emon ~]$ docker rmi -f b5b4d78bc90c
```

	命令含义：会先尝试删除所有指向该镜像的标签，然后删除该镜像文件本身。哪怕基于该镜像启动了容器，也会删除镜像。但不影响容器。

## 7、创建镜像

	创建镜像的方法主要有三种：基于已有镜像的容器创建、基于本地模板导入、基于Dockerfile创建。

### 7.1、基于已有镜像的容器创建

该方法主要是使用docker commit命令。

命令格式为`docker commit [OPTIONS] CONTAINTER [REPOSITORY[:TAG]]`，主要选项包括：

| 参数名称         | 参数作用                                                     |
| ---------------- | ------------------------------------------------------------ |
| -a, --author=""  | 作者信息                                                     |
| -c, --change=[]  | 提交的试试执行Dockerfile指令，包括CMD\|ENTRYPOINT\|ENV\|EXPOSE\|LABEL\|ONBUILD\|USER\|VOLUME\|WORKDIR等 |
| -m, --message="" | 提交信息                                                     |
| -p, --pause=true | 提交时暂停容器运行                                           |

1. 首先，启动一个镜像，并在其中进行修改操作，例如创建一个test文件，之后推出：

```shell
[emon@emon ~]$ docker run -it ubuntu:14.04 /bin/bash
root@fe1aa9bd8460:/# touch test
root@fe1aa9bd8460:/# exit
```

记住容器的ID为 fe1aa9bd8460。

此时，该容器跟原ubuntu:14.04镜像相比，已经发生了变化，可以使用`docker commit`命令提交未一个新的镜像。提交时可以使用ID或者名称来指定容器：

```shell
[emon@emon ~]$ docker commit -m "Added a new file" -a "Emon" fe1aa9bd8460 test:0.0.1
```

### 7.2、基于本地模板导入

用户也可以直接从一个操作系统模板文件导入一个镜像，主要使用`docker import`命令。

命令格式为`docker import [OPTIONS] file|URL| - [REPOSITORY[:TAG]]`

## 8、存出和载入镜像

用户可以使用`docker save`和`docker load`命令来存出和载入镜像。

### 8.1、存出镜像

```shell
[emon@emon ~]$ docker save -o test_0.0.1.tar test:0.0.1
```

说明：由于是通过sudo使用的docker命令，这里到处的镜像属于root用户；该镜像可以分发给其他人导入。

### 8.2、载入镜像

```shell
[emon@emon ~]$ docker load --input test_0.0.1.tar 
```

或者，使用root用户执行：

```shell
[root@emon ~]# docker load < /home/emon/test_0.0.1.tar 
```

或者，使用非root如下执行：

```shell
[emon@emon ~]$ sudo bash -c "chown emon.emon test_0.0.1.tar;docker load < test_0.0.1.tar"
```

说明：直接使用docker load命令，非root用户有权限限制：

```shell
[emon@emon ~]$ docker load < test_0.0.1.tar 
-bash: test_0.0.1.tar: 权限不够
```

## 9、上传镜像

以使用docker push命令上传镜像到仓库，默认上传到Docker Hub官方仓库（需要登录）。命令格式为：

`docker push NAME[:TAG] | [REGISTRY_HOST[:REGISTRY_PORT]/]NAME[:TAG]`

用户在Docker Hub网站注册后可以上传自制的镜像。例如用户user上传本地的test:latest镜像，可以先添加新的标签user/test:latest，然后用docker push命令上传镜像；

**请确保自己在 [Docker Hub](https://hub.docker.com/) 上有注册的用户，并把user替换为自己的用户名**

1. 打标签

```shell
[emon@emon ~]$ docker tag test:0.0.1 rushing/test:0.0.1
```

2. 登录 Docker Hub

```shell
[emon@emon ~]$ docker login
```

3. 上传

```shell
[emon@emon ~]$ docker push rushing/test:0.0.1
```

![上传结果](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Docker/images/2018080801.png)



# 四、容器

	简单来说，容器是镜像的一个运行实例。所不同的是，镜像是静态的只读文件，而容器带有运行时需要的
可写层。如果认为虚拟机是模拟运行的一整套操作系统（包括内核、应用运行态环境和其他系统环境）和跑在上面的应用，那么Docker容器就是独立运行的一个（或一组）应用，以及它们必需的运行环境。

## 1、查看容器

### 1.1、基本用法

- 命令格式： `docker ps [OPTIIONS]`

| 选项名      | 默认值 | 描述                                                         |
| ----------- | ------ | ------------------------------------------------------------ |
| --all,-a    | false  | 是否显示所有容器（默认仅显示运行中的容器）                   |
| --filter,-f |        | 根据过滤的条件过滤输出结果                                   |
| --format    |        | 使用模板输出格式良好的结果                                   |
| --last,-n   | -1     | 显示最后创建的n个容器（包含所有状态的容器）                  |
| --latest,-l | false  | 显示最后创建的容器（包含所有状态的容器）                     |
| --no-trunc  | false  | 不截断输出                                                   |
| --quiet,-q  | false  | 仅仅显示ID列                                                 |
| --size,-s   | false  | 显示文件大小（容器增量大小和容器虚拟大小（容器真实大小+依赖的镜像大小）） |

- 显示正在运行的容器

```shell
[emon@emon ~]$ docker ps
```

- 显示所有状态的容器（7种状态：created|restarting|runnning|removing|paused|exited|dead)

```shell
[emon@emon ~]$ docker ps -a
```

- 显示最后被创建的n个容器（不限状态）

```shell
[emon@emon ~]$ docker ps -n 1
```

- 显示最后被创建的容器（不限状态）

```shell
[emon@emon ~]$ docker ps -l
```

- 显示完整输出（正在运行状态的）

```shell
[emon@emon ~]$ docker ps --no-trunc
```

- 只显示容器ID（正在运行状态的）

```shell
[emon@emon ~]$ docker ps -q
```

- 显示容器文件大小（正在运行状态的，该命令显示容器真实大小和容器的虚拟大小=(容器真实大小+容器镜像大小)）

```shell
[emon@emon ~]$ docker ps -s
```

### 1.2、高级用法

如果容器数量过多，或者想排除干扰容器，可以通过--filter或者-f选项，过滤需要显示的容器。

| 过滤条件 | 描述                                                         |
| -------- | ------------------------------------------------------------ |
| id       | 容器ID                                                       |
| label    | label=<key>或者label=<key>=<value>                           |
| status   | 支持的状态值有：created/restarting/running/removing/paused/exited/dead |
| health   | starting/healthy/unhealthy/none 基于健康检查状态过滤容器     |
|          |                                                              |
|          |                                                              |
|          |                                                              |
|          |                                                              |

条件很多，但万变不离其宗，只需要记住以下3条准则：

1. 选项后跟的都是键值对key=value(可不带引号)，如果有多个过滤条件，就多次使用filter选项。例如：

```shell
docker ps --filter id=a1b2c3 --filter name=festive_pasteur
```

2. 相同条件之间的关系是或，不同条件之间的关系是与。例如：

```shell
docker ps --filter name=festive --filter name=pasteur --filter status=running
```

以上过滤条件会找出name包含festive或者pasteur并且status为running的容器。

3. id和name，支持正则表达式，使用起来非常灵活。例如：

```shell
docker ps --filter name=^/festive_pasteur$
```

精确匹配name为festive_pasteur的容器。注意，容器实际名称，开头是由一个正斜线/，可用docker inspect一看便知。

```shell
docker ps --filter name=.*festive_pasteur.*
```

匹配name包含festive_pasteur的容器，和--filter name=festive_pasteur效果一致

最后，列举一个复杂点的例子，用于清理名称包含festive_pasteur，且状态为exited或dead的容器，如下：

```shell
docker rm $(docker ps -q --filter name=.*festive_pasteur.* --filter status=exited --filter status=dead 2>/dev/null)
```

如果是非root用户，要使用如下命令：

```shell
docker rm $(sudo bash -c "docker ps -q --filter name=.*festive_pasteur.* --filter status=exited --filter status=dead 2>/dev/null")
```

### 1.3、Format格式化显示

如果想要自定义显示容器字段，可以用格式化选项 -format。

| 占位符      | 描述                                                         |
| ----------- | ------------------------------------------------------------ |
| .ID         | 容器ID                                                       |
| .Image      | ImageID                                                      |
| .Command    | 启动容器的命令                                               |
| .CreatedAt  | 容器创建的时间                                               |
| .RunningFor | 自从容器创建后流逝的时间                                     |
| .Ports      | 暴露的端口                                                   |
| .Status     | 容器占用的磁盘大小                                           |
| .Names      | 容器的名称                                                   |
| .Labels     | 容器所有被分配的标签                                         |
| .Label      | 容器某个指定标签的值，比如：'{{.Label "com.docker.swarm.cpu"}}' |
| .Mounts     | 容器挂载的卷标名称                                           |
| .Networks   | attached到容器时的网络名称                                   |

1. 当使用了--format选项，那么ps命令只会输出template中指定的内容：

```shell
[emon@emon ~]$ docker ps --format "{{.ID}}:{{.Command}}"
```

2. 如果想带上表格列头，需要在telplate中加上table：

```shell
[emon@emon ~]$ docker ps --format "table{{.ID}}:{{.Command}}"
```

3. 一个比较好用的格式

```bash
[emon@emon ~]$ docker ps --format "table{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.RunningFor}}\t{{.Ports}}"
```

[更多用法](https://www.cnblogs.com/fuyuteng/p/8847331.html)



## 2、创建容器

- 新建容器

```shell
[emon@emon ~]$ docker create -it --name centos7.8 centos:7
```

使用docker create命令创建的容器处于停止状态，可以使用docker start命令来启动。

- 启动容器

```shell
[emon@emon ~]$ docker start <container_id|container_name>
```

- 新建并启动容器：守护态运行(Daemonized)【推荐的启动方式】

```bash
[emon@emon ~]$ docker run -itd --name centos7.8 centos:7 [/bin/bash]
```

- 新建并启动容器：非守护态运行

```bash
[emon@emon ~]$ docker run -it --name centos7.8 centos:7 [/bin/bash]
```

这种运行方式，用户可以按Ctrl+d或者输入exit命令来退出容器：

TIPS：退出时，使用[Ctrl+D]，这样会结束docker当前线程，容器结束，可以使用[Ctrl+P+Q]退出而不是终止容器。

**异常情况：**

如果创建容器时，发现如下错误的处理办法：

`WARNING: IPv4 forwarding is disabled. Networking will not work.`

```bash
# 检查
[emon@emon ~]$ sudo sysctl -a|grep net.ipv4.ip_forward
# 配置
[emon@emon ~]$ sudo vim /etc/sysctl.conf
net.ipv4.ip_forward=1
# 使之生效
[emon@emon ~]$ sudo sysctl -p
# 重启网络
[emon@emon ~]$ sudo systemctl restart network
```



## 3、终止容器

可以使用docker stop来终止一个运行中的容器。该命令的格式为docker stop [-t|--time[=10]][CONTAINER...]。

首先向容器发送SIGTERM信号，等待一段超时时间（默认为10秒）后，再发送SIGKILL信号来终止容器：

```shell
[emon@emon ~]$ docker stop <container_id|container_name>
```

[docker kill 命令会直接发送SIGKILL信号来强制终止容器。]

此外，当Docker容器中指定的应用终结时，容器也会自动终止。

此外，docker restart命令会将一个运行态的容器先终止，然后再重新启动它：

```shell
[emon@emon ~]$ docker restart <container_id|container_name>
```

## 4、进入容器

在使用-d参数时，容器启动后会进入后台，用户无法看到容器中的信息，也无法进行操作。

这个时候如果需要进入容器进行操作，有多种方法，包括使用官方的attach或exec命令，以及第三方的nsenter工具等。

- attach命令（连接后执行exit会停止容器）【过时方式】

attach是Docker自带的命令，命令格式为：

docker attach [--detach-keys[=[]]][--no-stdin] [--sig-proxy[=true]] CONTAINER

| 选项名             | 默认值 | 描述                                                |
| ------------------ | ------ | --------------------------------------------------- |
| --detach-keys[=[]] |        | 指定退出attach模式的快捷键序列，默认是Ctrl-p Ctrl-q |
| --no-stdin         | false  | 是否关闭标准输入                                    |
| --sig-proxy        | true   | 是否代理收到的系统信号给应用进程                    |

```shell
[emon@emon ~]$ docker attach <container_id|container_name>
```

但是使用attach命令有时候不方便。当多个窗口同时用attach命令连接到同一个容器的时候，所有窗口都会同步显示。当某个窗口因命令阻塞时，其他窗口也无法执行操作了。

- exec命令（连接后执行exit，并不会停止容器）【推荐方式】

 Docker从1.3.0版本起提供了一个更加方便的exec命令，可以在容器内直接执行任意命令。该命令的基本格式为

docker exec [-d| --detach][--detach-keys[=[]]]	[-i| --interactive] [--privileged][-t| --tty] [-u| --user[=USER]] CONTAINER COMMAND [ARG...]

| 选项名           | 默认值 | 描述                         |
| ---------------- | ------ | ---------------------------- |
| -i,--interactive | false  | 打开标准输入接受用户输入命令 |
| --priveleged     | false  | 是否给执行命令以高权限       |
| -t,--tty         | false  | 分配伪终端，默认为false      |
| -u,--user        |        | 执行命令的用户名或者ID       |

2. 进入容器

```shell
[emon@emon ~]$ docker exec -it <container_id|container_name> /bin/bash
```

- 使用nsenter工具

暂略

## 5、删除容器

可以使用docker rm 命令来删除处于终止或退出状态的容器，命令格式为：

docker rm [-f|--force][-l|--link] [-v|--volumes] CONTAINER [CONTAINER...]。

| 选项名       | 默认值 | 描述                               |
| ------------ | ------ | ---------------------------------- |
| -f,--force   | false  | 是否强行终止并删除一个运行中的容器 |
| -l,--link    | false  | 删除容器的连接，但保留容器         |
| -v,--volumes | false  | 删除容器挂载的数据卷               |

- 查看并删除停止状态的容器

1. 查看停止状态的容器

```shell
[emon@emon ~]$ docker ps -q -f status=exited
```

2. 删除停止状态的容器

```shell
[emon@emon ~]$ docker rm <container_id|container_name>
```

- 删除运行状态的容器

1. 查看运行状态的容器

```shell
[emon@emon ~]$ docker ps -q
或者
[emon@emon ~]$ docker ps -q --filter status=running
```

2. 删除运行状态的容器

```shell
[emon@emon ~]$ docker rm -f 3aa0487c2904
```

## 6、导入和导出容器

某些时候，需要将容器从一个系统迁移到另外一个系统，此时可以使用Docker的导入和导出功能。这也是Docker自身提供的一个重要特性。

### 6.1、导出容器

导出容器是指导出一个已经创建的容器到一个文件，不管此时这个容器是否处于运行状态，可以使用docker export命令，该命令的格式为：

docker export [-o|--output[=""]] CONTAINER。

其中，可以通过-o选项来指定导出的tar文件名，也可以直接通过重定向来实现。

1. 查看容器

```shell
[emon@emon ~]$ docker ps -qa
```

2. 导出容器文件

```shell
[emon@emon ~]$ docker export -o test_for_centos.tar 7fcaad938106
```

之后，可将导出的tar文件传输到其他机器上，然后再通过导入命令导入到系统中，从而实现容器的迁移。

### 6.2、导入容器

导出的文件又可以使用docker import命令导入变成镜像，该命令格式为：

docker import [-c|--change[=[]]][-m|--message[=MESSAGE]] file|URL|-[REPOSITORY[:TAG]]

用户可以通过-c, --change=[]选项在导入的同时执行对容器进行修改的Dockerfile指令。

```shell
[emon@emon ~]$ docker import test_for_centos.tar centos:7-test
```

注意：导入容器后，体现为镜像，需要启动才会出现到docker ps -qa列表中。

## 7、查看容器日志

- 命令格式： `docker logs [OPTIONS]` <container_id|container_name>

| 选项名          | 默认值 | 描述                                                         |
| --------------- | ------ | ------------------------------------------------------------ |
| --details       |        | 显示更多的信息                                               |
| -f,--follow     |        | 跟踪实时日志                                                 |
| --since string  |        | 显示自某个timestamp之后的日志，或相对时间，如42m（即42分钟） |
| --tail string   |        | 从日志末尾显示多少行日志，默认是all                          |
| -t,--timestamps |        | 显示时间戳                                                   |
| --until string  |        | 显示自某个timestamp之前的日志，或者相对时间，如42m（即42分钟） |

- 查看指定时间后的日志，只显示最后100行

```bash
docker logs -f -t --since="2021-02-17" --tail=100 <container_id|container_name>
```

- 查看最近30分钟的日志

```bash
docker logs --since 30 <container_id|container_name>
```

- 查看某个时间之后的日志

```bash
docker logs -t --since="2021-02-17T13:05:30" <container_id|container_name>
```

- 实时查看

```bash
docker logs -f <container_id|container_name>
```

# 五、仓库



# 六、数据管理



# 七、端口映射与容器互联



