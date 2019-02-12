# Docker实践

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、Docker的安装与配置

## 1、安装

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
[emon@emon ~]$ sudo yum install -y docker-ce-17.12.0.ce
```

5. 启动

```shell
[emon@emon ~]$ sudo systemctl start docker
```

6. 验证安装

```shell
[emon@emon ~]$ docker version
[emon@emon ~]$ docker info
```

## 1.3、配置docker加速器

采用 DaoCloud: https://www.daocloud.io/ 提供的Docker加速器。

登录DaoCloud，找到小火箭图标，根据说明操作：

- 配置

```bash
[root@emon docker]# curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://c018e274.m.daocloud.io
docker version >= 1.12
{"registry-mirrors": ["http://c018e274.m.daocloud.io"]}
Success.
You need to restart docker to take effect: sudo systemctl restart docker 
```

- 查看

```bash
[root@emon docker]# cat /etc/docker/daemon.json 
{"registry-mirrors": ["http://c018e274.m.daocloud.io"]}
```

- 重启

```bash
[root@emon docker]# systemctl restart docker
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
Server Version: 17.05.0-ce
Storage Driver: overlay
 Backing Filesystem: xfs
 Supports d_type: true
Logging Driver: json-file
Cgroup Driver: cgroupfs
Plugins: 
 Volume: local
 Network: bridge host macvlan null overlay
Swarm: inactive
Runtimes: runc
Default Runtime: runc
Init Binary: docker-init
containerd version: 9048e5e50717ea4497b757314bad98ea3763c145
runc version: 9c2d8d184e5da67c95d601382adf14862e4f2228
init version: 949e6fa
Security Options:
 seccomp
  Profile: default
Kernel Version: 3.10.0-862.el7.x86_64
Operating System: CentOS Linux 7 (Core)
OSType: linux
Architecture: x86_64
CPUs: 1
Total Memory: 1.779GiB
Name: emon
ID: QKZW:Q2LO:75KW:UETN:UKN7:7N6Y:H74J:R2RV:VQIB:7YNB:RVEV:UMN4
Docker Root Dir: /var/lib/docker
Debug Mode (client): false
Debug Mode (server): false
Registry: https://index.docker.io/v1/
Experimental: false
Insecure Registries:
 127.0.0.0/8
Live Restore Enabled: false
```

## 2、查看Docker版本

```shell
[emon@emon ~]$ docker version
Client:
 Version:      17.05.0-ce
 API version:  1.29
 Go version:   go1.7.5
 Git commit:   89658be
 Built:        Thu May  4 22:06:25 2017
 OS/Arch:      linux/amd64

Server:
 Version:      17.05.0-ce
 API version:  1.29 (minimum version 1.12)
 Go version:   go1.7.5
 Git commit:   89658be
 Built:        Thu May  4 22:06:25 2017
 OS/Arch:      linux/amd64
 Experimental: false
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
[emon@emon ~]$ docker pull centos:7.5.1804
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
[emon@emon ~]$ docker tag hub.c.163.com/public/ubuntu:14.04 163_ubuntu:14.04
```

	之后，用户就可以直接使用 163_ubuntu:14.04 来表示这个镜像了。 

## 4、使用`inspect`命令查看详细信息

```shell
[emon@emon ~]$ docker inspect ubuntu:14.04
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
[emon@emon ~]$ docker rmi ubuntu:14.04
```

- 使用镜像ID（或者部分ID串前缀）删除镜像

```shell
[emon@emon ~]$ docker rmi 2fe5c4bba1f9
```

	命令含义：会先尝试删除所有指向该镜像的标签，然后删除该镜像文件本身。

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

**请确保自己在 [Docker Hub](https://hub.docker.com/) 上有注册的用户，并把user替换为字节的用户名**

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

[更多用法](https://www.cnblogs.com/fuyuteng/p/8847331.html)



## 2、创建容器

- 新建容器

```shell
[emon@emon ~]$ docker create -it centos:7.5.1804
61d0bd1c9c24ef46e88ba73bdf71e539d30f35ba23827b4c64f5d2c9f9876c76
```

使用docker create命令创建的容器处于停止状态，可以使用docker start命令来启动。

- 启动容器

```shell
[emon@emon ~]$ docker start 61d0bd1c9c24
```

- 新建并启动容器

```shell
[emon@emon ~]$ docker run -it centos:7.5.1804 /bin/bash
```

用户可以按Ctrl+d或者输入exit命令来退出容器：

TIPS：退出时，使用[Ctrl+D]，这样会结束docker当前线程，容器结束，可以使用[Ctrl+P]或[Ctrl+Q]退出而不是终止容器。

```shell
[root@3ac494840e14 /]# exit
```

- 守护态运行

更多的时候，需要让Docker容器在后台以守护态（Daemonized）形式运行。此时，可以通过添加-d参数来实现。

```shell
[emon@emon ~]$ docker run -d centos:7.5.1804 /bin/bash -c "while true;do echo hello world;sleep 1;done"
```

说明：如果没有运行的内容，会自动停掉。

## 3、终止容器

可以使用docker stop来终止一个运行中的容器。该命令的格式为docker stop [-t|--time[=10]][CONTAINER...]。

首先向容器发送SIGTERM信号，等待一段超时时间（默认为10秒）后，再发送SIGKILL信号来终止容器：

```shell
[emon@emon ~]$ docker stop 2534df637e7e
```

[docker kill 命令会直接发送SIGKILL信号来强制终止容器。]

此外，当Docker容器中指定的应用终结时，容器也会自动终止。

此外，docker restart命令会将一个运行态的容器先终止，然后再重新启动它：

```shell
[emon@emon ~]$ docker restart 2534df637e7e
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

1. 创建容器并后台启动

```shell
[emon@emon ~]$ docker run -itd centos:7.5.1804
```

2. 进入容器

```shell
[emon@emon ~]$ docker attach 201cd2b1eee5
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

1. 创建容器并后台启动

```shell
[emon@emon ~]$ docker run -itd centos:7.5.1804
```

2. 进入容器

```shell
[emon@emon ~]$ docker exec -it eac2c8d31678 /bin/bash
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
[emon@emon ~]$ docker rm 31f3f0a229e5
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



# 五、仓库



# 六、数据管理



# 七、端口映射与容器互联



