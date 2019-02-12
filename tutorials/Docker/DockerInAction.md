# Dockerʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# һ��Docker�İ�װ������

## 1����װ

### 1.1����װҪ��

	��װDocker�Ļ���Ҫ�����£�

- Dockrֻ֧��64λ��CPU�ܹ��ļ������Ŀǰ��֧��32λCPU
- ����ϵͳ��Linux�ں˰汾Ϊ3.10������
- Linux�ں���Ҫ����cgroups��namespace����
- ���ڷ�Linux�ں˵�ƽ̨����Microsoft Windows��OS X����Ҫ��װʹ��Boot2Docker����

### 1.2��CentOS�����°�װDocker

	DockerĿǰֻ��������64λƽ̨�ϣ�����Ҫ���ں˰汾������3.10��ʵ�����ں˰汾Խ��Խ�ã����͵��ں˰汾������ɹ��ܲ��ȶ���
	
	�û�����ͨ�������������Լ����ں˰汾��ϸ��Ϣ��

```shell
[emon@emon ~]$ uname -a
Linux emon 3.10.0-862.el7.x86_64 #1 SMP Fri Apr 20 16:44:24 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
[emon@emon ~]$ cat /proc/version
Linux version 3.10.0-862.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC) ) #1 SMP Fri Apr 20 16:44:24 UTC 2018
```

1. ��װ��Ҫ���������yum-util�ṩyum-config-manager���ܣ�����������devicemapper����������

```shell
[emon@emon ~]$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```

2. ����yumԴ

```shell
[emon@emon ~]$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

3. ���Բ鿴���вֿ�������docker�汾����ѡ��װ�ض��İ汾

```shell
[emon@emon ~]$ yum list docker-ce --showduplicates |sort -r
```

4. ��װdocker

```shell
[emon@emon ~]$ sudo yum install -y docker-ce-17.12.0.ce
```

5. ����

```shell
[emon@emon ~]$ sudo systemctl start docker
```

6. ��֤��װ

```shell
[emon@emon ~]$ docker version
[emon@emon ~]$ docker info
```

## 1.3������docker������

���� DaoCloud: https://www.daocloud.io/ �ṩ��Docker��������

��¼DaoCloud���ҵ�С���ͼ�꣬����˵��������

- ����

```bash
[root@emon docker]# curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://c018e274.m.daocloud.io
docker version >= 1.12
{"registry-mirrors": ["http://c018e274.m.daocloud.io"]}
Success.
You need to restart docker to take effect: sudo systemctl restart docker 
```

- �鿴

```bash
[root@emon docker]# cat /etc/docker/daemon.json 
{"registry-mirrors": ["http://c018e274.m.daocloud.io"]}
```

- ����

```bash
[root@emon docker]# systemctl restart docker
```

## 2������Docker����

### 2.1���Ƽ�ͨ������sudo�ķ�ʽ��

	���Ƽ�docker�����������޸�/var/run/docker.sock�ļ�������Ϊdockerroot��Ȼ��Ϊĳ��user��Ӹ�����dockerroot��ʽ��ʹ��docker������user��¼�����ִ�С�

```shell
[emon@emon ~]$ sudo visudo
```

	�ҵ�`## Allow root to run any commands anywhere`�����ı�ʶ�����·����ã�

```shell
# ��ע������Ѿ�������ALL�Ĳ���Ȩ�ޣ���û��Ҫ����������
emon    ALL=(ALL)       PASSWD:/usr/bin/docker
```



### 2.2������alias

	�������õ�alias��

```shell
[emon@emon ~]$ vim .bashrc
alias docker="sudo /usr/bin/docker"
```

	ʹ֮��Ч��

```shell
[emon@emon ~]$ source .bashrc
```

	ʹ��ʾ����

```shell
[emon@emon ~]$ docker images
[sudo] emon �����룺
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```



# ����������Ϣ�鿴

## 1���鿴Docker�Ļ�����Ϣ

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

## 2���鿴Docker�汾

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



# ��������

## 1����ȡ����

- ��ȡDocker Hub����
  - ����������������ǰ�ᣬ�ٷ���Docker Hub��վ�Ѿ��ṩ����ʮ������񹩿������ء�
  - �����ʽ�� `docker pull NAME[:TAG]` ���У�NAME�Ǿ���ֿ�����ƣ��������־��񣩣�TAG�Ǿ���ı�ǩ������������ʾ�汾��Ϣ����ͨ������£�����һ��������Ҫ����`����+��ǩ`��Ϣ��
  - �����ָ��TAG��Ĭ��ѡ��latest��ǩ��������زֿ������°汾�ľ���

```shell
# ��Ч�� docker pull registry.hub.docker.com/ubuntu:14.04
[emon@emon ~]$ docker pull ubuntu:14.04
# ��ϲ����centos
[emon@emon ~]$ docker pull centos:7.5.1804
```

- ��ȡ��������������

```shell
[emon@emon ~]$ docker pull hub.c.163.com/public/ubuntu:14.04
```

## 2���鿴����

- ʹ��`docker images`�����г�����

```shel
[emon@emon ~]$ docker images
```

- ����������

| ����       | ����                                                         |
| ---------- | ------------------------------------------------------------ |
| REPOSITORY | �������ĸ��ֿ⣬����ubuntu�ֿ���������ubuntuϵ�л�������     |
| TAG        | ����ı�ǩ��Ϣ������14.04��latest������ע��ͬ�İ汾��Ϣ����ǩֻ�Ǳ�ǣ�����ʶ�������� |
| IMAGE ID   | �����ID��Ψһ��ʶ���񣩣�����ubuntu:14.04��Ψһ��־�� 971bb384a50a |
| CREATED    | ����ʱ�䣬˵���������ĸ���ʱ��                             |
| SIZE       | �����С������ľ�����������Ƚ�С                           |

- ����֧�ֵ�ѡ��

| ��������                | ��������                                                     |
| ----------------------- | ------------------------------------------------------------ |
| -a, --all=true\|false   | �г����еľ����ļ���������ʱ�ļ�����Ĭ��Ϊ��                 |
| --digests=true\|false   | �г����������ժҪֵ��Ĭ��Ϊ��                               |
| -f, --filter=[]         | �����г��ľ�����dangling=trueֻ��ʾû�б�ʹ�õľ���Ҳ����ָ�������ض���ע�ľ���� |
| --format="TEMPLATE"     | ���������ʽ������`.ID`����ID��Ϣ��`.Repository`����ֿ���Ϣ�� |
| --no-trunc=true\|false  | ����������̫���Ĳ����Ƿ���нضϣ��羵���ID��Ϣ��Ĭ��Ϊ�� |
| -q, --quiet=true\|false | �����ID��Ϣ��Ĭ��Ϊ��                                       |

	���У������������п��Ƶ�ѡ����-f, --filter=[]��--no-trunc=true|false��-q, --quiet=true|false�ȣ��Դ󲿷������֧�֡�

## 3��Ϊ������ӱ�ǩTag

	Ϊ�˷����ں���������ʹ���ض����񣬻�����ʹ��`docker tag`������Ϊ���ؾ�����������µı�ǩ��

```shell
[emon@emon ~]$ docker tag hub.c.163.com/public/ubuntu:14.04 163_ubuntu:14.04
```

	֮���û��Ϳ���ֱ��ʹ�� 163_ubuntu:14.04 ����ʾ��������ˡ� 

## 4��ʹ��`inspect`����鿴��ϸ��Ϣ

```shell
[emon@emon ~]$ docker inspect ubuntu:14.04
```

## 5����Ѱ����

	ʹ��docker search�����������Զ�˲ֿ��й���ľ���Ĭ�������ٷ��ֿ��еľ���֧�ֵĲ�����Ҫ������

| ��������                          | ��������                                                     |
| --------------------------------- | ------------------------------------------------------------ |
| --filter=is-automated=true\|false | ����ʾ�Զ������ľ���Ĭ��Ϊ��                               |
| --no-trunc=true\|false            | �����Ϣ���ض���ʾ��Ĭ��Ϊ��                                 |
| --filter=stars=3                  | ָ������ʾ����Ϊָ���Ǽ����ϵľ���Ĭ��Ϊ0����������о��� |

ʾ����

```shell
[emon@emon ~]$ docker search --filter=is-automated=true --filter=stars=3 nginx
```

## 6��ɾ������

- ʹ�ñ�ǩɾ�����������ʽ�� `docker rmi IMAGE [IMAGE...]`������IMAGE�����Ǳ�ǩ����ID

```shell
[emon@emon ~]$ docker rmi ubuntu:14.04
```

- ʹ�þ���ID�����߲���ID��ǰ׺��ɾ������

```shell
[emon@emon ~]$ docker rmi 2fe5c4bba1f9
```

	����壺���ȳ���ɾ������ָ��þ���ı�ǩ��Ȼ��ɾ���þ����ļ�����

## 7����������

	��������ķ�����Ҫ�����֣��������о�����������������ڱ���ģ�嵼�롢����Dockerfile������

### 7.1���������о������������

�÷�����Ҫ��ʹ��docker commit���

�����ʽΪ`docker commit [OPTIONS] CONTAINTER [REPOSITORY[:TAG]]`����Ҫѡ�������

| ��������         | ��������                                                     |
| ---------------- | ------------------------------------------------------------ |
| -a, --author=""  | ������Ϣ                                                     |
| -c, --change=[]  | �ύ������ִ��Dockerfileָ�����CMD\|ENTRYPOINT\|ENV\|EXPOSE\|LABEL\|ONBUILD\|USER\|VOLUME\|WORKDIR�� |
| -m, --message="" | �ύ��Ϣ                                                     |
| -p, --pause=true | �ύʱ��ͣ��������                                           |

1. ���ȣ�����һ�����񣬲������н����޸Ĳ��������紴��һ��test�ļ���֮���Ƴ���

```shell
[emon@emon ~]$ docker run -it ubuntu:14.04 /bin/bash
root@fe1aa9bd8460:/# touch test
root@fe1aa9bd8460:/# exit
```

��ס������IDΪ fe1aa9bd8460��

��ʱ����������ԭubuntu:14.04������ȣ��Ѿ������˱仯������ʹ��`docker commit`�����ύδһ���µľ����ύʱ����ʹ��ID����������ָ��������

```shell
[emon@emon ~]$ docker commit -m "Added a new file" -a "Emon" fe1aa9bd8460 test:0.0.1
```

### 7.2�����ڱ���ģ�嵼��

�û�Ҳ����ֱ�Ӵ�һ������ϵͳģ���ļ�����һ��������Ҫʹ��`docker import`���

�����ʽΪ`docker import [OPTIONS] file|URL| - [REPOSITORY[:TAG]]`

## 8����������뾵��

�û�����ʹ��`docker save`��`docker load`��������������뾵��

### 8.1���������

```shell
[emon@emon ~]$ docker save -o test_0.0.1.tar test:0.0.1
```

˵����������ͨ��sudoʹ�õ�docker������ﵽ���ľ�������root�û����þ�����Էַ��������˵��롣

### 8.2�����뾵��

```shell
[emon@emon ~]$ docker load --input test_0.0.1.tar 
```

���ߣ�ʹ��root�û�ִ�У�

```shell
[root@emon ~]# docker load < /home/emon/test_0.0.1.tar 
```

���ߣ�ʹ�÷�root����ִ�У�

```shell
[emon@emon ~]$ sudo bash -c "chown emon.emon test_0.0.1.tar;docker load < test_0.0.1.tar"
```

˵����ֱ��ʹ��docker load�����root�û���Ȩ�����ƣ�

```shell
[emon@emon ~]$ docker load < test_0.0.1.tar 
-bash: test_0.0.1.tar: Ȩ�޲���
```

## 9���ϴ�����

��ʹ��docker push�����ϴ����񵽲ֿ⣬Ĭ���ϴ���Docker Hub�ٷ��ֿ⣨��Ҫ��¼���������ʽΪ��

`docker push NAME[:TAG] | [REGISTRY_HOST[:REGISTRY_PORT]/]NAME[:TAG]`

�û���Docker Hub��վע�������ϴ����Ƶľ��������û�user�ϴ����ص�test:latest���񣬿���������µı�ǩuser/test:latest��Ȼ����docker push�����ϴ�����

**��ȷ���Լ��� [Docker Hub](https://hub.docker.com/) ����ע����û�������user�滻Ϊ�ֽڵ��û���**

1. ���ǩ

```shell
[emon@emon ~]$ docker tag test:0.0.1 rushing/test:0.0.1
```

2. ��¼ Docker Hub

```shell
[emon@emon ~]$ docker login
```

3. �ϴ�

```shell
[emon@emon ~]$ docker push rushing/test:0.0.1
```

![�ϴ����](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Docker/images/2018080801.png)



# �ġ�����

	����˵�������Ǿ����һ������ʵ��������ͬ���ǣ������Ǿ�̬��ֻ���ļ�����������������ʱ��Ҫ��
��д�㡣�����Ϊ�������ģ�����е�һ���ײ���ϵͳ�������ںˡ�Ӧ������̬����������ϵͳ�����������������Ӧ�ã���ôDocker�������Ƕ������е�һ������һ�飩Ӧ�ã��Լ����Ǳ�������л�����

## 1���鿴����

### 1.1�������÷�

- �����ʽ�� `docker ps [OPTIIONS]`

| ѡ����      | Ĭ��ֵ | ����                                                         |
| ----------- | ------ | ------------------------------------------------------------ |
| --all,-a    | false  | �Ƿ���ʾ����������Ĭ�Ͻ���ʾ�����е�������                   |
| --filter,-f |        | ���ݹ��˵���������������                                   |
| --format    |        | ʹ��ģ�������ʽ���õĽ��                                   |
| --last,-n   | -1     | ��ʾ��󴴽���n����������������״̬��������                  |
| --latest,-l | false  | ��ʾ��󴴽�����������������״̬��������                     |
| --no-trunc  | false  | ���ض����                                                   |
| --quiet,-q  | false  | ������ʾID��                                                 |
| --size,-s   | false  | ��ʾ�ļ���С������������С�����������С��������ʵ��С+�����ľ����С���� |

- ��ʾ�������е�����

```shell
[emon@emon ~]$ docker ps
```

- ��ʾ����״̬��������7��״̬��created|restarting|runnning|removing|paused|exited|dead)

```shell
[emon@emon ~]$ docker ps -a
```

- ��ʾ��󱻴�����n������������״̬��

```shell
[emon@emon ~]$ docker ps -n 1
```

- ��ʾ��󱻴���������������״̬��

```shell
[emon@emon ~]$ docker ps -l
```

- ��ʾ�����������������״̬�ģ�

```shell
[emon@emon ~]$ docker ps --no-trunc
```

- ֻ��ʾ����ID����������״̬�ģ�

```shell
[emon@emon ~]$ docker ps -q
```

- ��ʾ�����ļ���С����������״̬�ģ���������ʾ������ʵ��С�������������С=(������ʵ��С+���������С)��

```shell
[emon@emon ~]$ docker ps -s
```

### 1.2���߼��÷�

��������������࣬�������ų���������������ͨ��--filter����-fѡ�������Ҫ��ʾ��������

| �������� | ����                                                         |
| -------- | ------------------------------------------------------------ |
| id       | ����ID                                                       |
| label    | label=<key>����label=<key>=<value>                           |
| status   | ֧�ֵ�״ֵ̬�У�created/restarting/running/removing/paused/exited/dead |
| health   | starting/healthy/unhealthy/none ���ڽ������״̬��������     |
|          |                                                              |
|          |                                                              |
|          |                                                              |
|          |                                                              |

�����ܶ࣬����䲻�����ڣ�ֻ��Ҫ��ס����3��׼��

1. ѡ�����Ķ��Ǽ�ֵ��key=value(�ɲ�������)������ж�������������Ͷ��ʹ��filterѡ����磺

```shell
docker ps --filter id=a1b2c3 --filter name=festive_pasteur
```

2. ��ͬ����֮��Ĺ�ϵ�ǻ򣬲�ͬ����֮��Ĺ�ϵ���롣���磺

```shell
docker ps --filter name=festive --filter name=pasteur --filter status=running
```

���Ϲ����������ҳ�name����festive����pasteur����statusΪrunning��������

3. id��name��֧��������ʽ��ʹ�������ǳ������磺

```shell
docker ps --filter name=^/festive_pasteur$
```

��ȷƥ��nameΪfestive_pasteur��������ע�⣬����ʵ�����ƣ���ͷ����һ����б��/������docker inspectһ����֪��

```shell
docker ps --filter name=.*festive_pasteur.*
```

ƥ��name����festive_pasteur����������--filter name=festive_pasteurЧ��һ��

����о�һ�����ӵ�����ӣ������������ư���festive_pasteur����״̬Ϊexited��dead�����������£�

```shell
docker rm $(docker ps -q --filter name=.*festive_pasteur.* --filter status=exited --filter status=dead 2>/dev/null)
```

����Ƿ�root�û���Ҫʹ���������

```shell
docker rm $(sudo bash -c "docker ps -q --filter name=.*festive_pasteur.* --filter status=exited --filter status=dead 2>/dev/null")
```

### 1.3��Format��ʽ����ʾ

�����Ҫ�Զ�����ʾ�����ֶΣ������ø�ʽ��ѡ�� -format��

| ռλ��      | ����                                                         |
| ----------- | ------------------------------------------------------------ |
| .ID         | ����ID                                                       |
| .Image      | ImageID                                                      |
| .Command    | ��������������                                               |
| .CreatedAt  | ����������ʱ��                                               |
| .RunningFor | �Դ��������������ŵ�ʱ��                                     |
| .Ports      | ��¶�Ķ˿�                                                   |
| .Status     | ����ռ�õĴ��̴�С                                           |
| .Names      | ����������                                                   |
| .Labels     | �������б�����ı�ǩ                                         |
| .Label      | ����ĳ��ָ����ǩ��ֵ�����磺'{{.Label "com.docker.swarm.cpu"}}' |
| .Mounts     | �������صľ������                                           |
| .Networks   | attached������ʱ����������                                   |

1. ��ʹ����--formatѡ���ôps����ֻ�����template��ָ�������ݣ�

```shell
[emon@emon ~]$ docker ps --format "{{.ID}}:{{.Command}}"
```

2. �������ϱ����ͷ����Ҫ��telplate�м���table��

```shell
[emon@emon ~]$ docker ps --format "table{{.ID}}:{{.Command}}"
```

[�����÷�](https://www.cnblogs.com/fuyuteng/p/8847331.html)



## 2����������

- �½�����

```shell
[emon@emon ~]$ docker create -it centos:7.5.1804
61d0bd1c9c24ef46e88ba73bdf71e539d30f35ba23827b4c64f5d2c9f9876c76
```

ʹ��docker create���������������ֹͣ״̬������ʹ��docker start������������

- ��������

```shell
[emon@emon ~]$ docker start 61d0bd1c9c24
```

- �½�����������

```shell
[emon@emon ~]$ docker run -it centos:7.5.1804 /bin/bash
```

�û����԰�Ctrl+d��������exit�������˳�������

TIPS���˳�ʱ��ʹ��[Ctrl+D]�����������docker��ǰ�̣߳���������������ʹ��[Ctrl+P]��[Ctrl+Q]�˳���������ֹ������

```shell
[root@3ac494840e14 /]# exit
```

- �ػ�̬����

�����ʱ����Ҫ��Docker�����ں�̨���ػ�̬��Daemonized����ʽ���С���ʱ������ͨ�����-d������ʵ�֡�

```shell
[emon@emon ~]$ docker run -d centos:7.5.1804 /bin/bash -c "while true;do echo hello world;sleep 1;done"
```

˵�������û�����е����ݣ����Զ�ͣ����

## 3����ֹ����

����ʹ��docker stop����ֹһ�������е�������������ĸ�ʽΪdocker stop [-t|--time[=10]][CONTAINER...]��

��������������SIGTERM�źţ��ȴ�һ�γ�ʱʱ�䣨Ĭ��Ϊ10�룩���ٷ���SIGKILL�ź�����ֹ������

```shell
[emon@emon ~]$ docker stop 2534df637e7e
```

[docker kill �����ֱ�ӷ���SIGKILL�ź���ǿ����ֹ������]

���⣬��Docker������ָ����Ӧ���ս�ʱ������Ҳ���Զ���ֹ��

���⣬docker restart����Ὣһ������̬����������ֹ��Ȼ����������������

```shell
[emon@emon ~]$ docker restart 2534df637e7e
```

## 4����������

��ʹ��-d����ʱ�����������������̨���û��޷����������е���Ϣ��Ҳ�޷����в�����

���ʱ�������Ҫ�����������в������ж��ַ���������ʹ�ùٷ���attach��exec����Լ���������nsenter���ߵȡ�

- attach������Ӻ�ִ��exit��ֹͣ����������ʱ��ʽ��

attach��Docker�Դ�����������ʽΪ��

docker attach [--detach-keys[=[]]][--no-stdin] [--sig-proxy[=true]] CONTAINER

| ѡ����             | Ĭ��ֵ | ����                                                |
| ------------------ | ------ | --------------------------------------------------- |
| --detach-keys[=[]] |        | ָ���˳�attachģʽ�Ŀ�ݼ����У�Ĭ����Ctrl-p Ctrl-q |
| --no-stdin         | false  | �Ƿ�رձ�׼����                                    |
| --sig-proxy        | true   | �Ƿ�����յ���ϵͳ�źŸ�Ӧ�ý���                    |

1. ������������̨����

```shell
[emon@emon ~]$ docker run -itd centos:7.5.1804
```

2. ��������

```shell
[emon@emon ~]$ docker attach 201cd2b1eee5
```

����ʹ��attach������ʱ�򲻷��㡣���������ͬʱ��attach�������ӵ�ͬһ��������ʱ�����д��ڶ���ͬ����ʾ����ĳ����������������ʱ����������Ҳ�޷�ִ�в����ˡ�

- exec������Ӻ�ִ��exit��������ֹͣ���������Ƽ���ʽ��

 Docker��1.3.0�汾���ṩ��һ�����ӷ����exec���������������ֱ��ִ���������������Ļ�����ʽΪ

docker exec [-d| --detach][--detach-keys[=[]]]	[-i| --interactive] [--privileged][-t| --tty] [-u| --user[=USER]] CONTAINER COMMAND [ARG...]

| ѡ����           | Ĭ��ֵ | ����                         |
| ---------------- | ------ | ---------------------------- |
| -i,--interactive | false  | �򿪱�׼��������û��������� |
| --priveleged     | false  | �Ƿ��ִ�������Ը�Ȩ��       |
| -t,--tty         | false  | ����α�նˣ�Ĭ��Ϊfalse      |
| -u,--user        |        | ִ��������û�������ID       |

1. ������������̨����

```shell
[emon@emon ~]$ docker run -itd centos:7.5.1804
```

2. ��������

```shell
[emon@emon ~]$ docker exec -it eac2c8d31678 /bin/bash
```

- ʹ��nsenter����

����

## 5��ɾ������

����ʹ��docker rm ������ɾ��������ֹ���˳�״̬�������������ʽΪ��

docker rm [-f|--force][-l|--link] [-v|--volumes] CONTAINER [CONTAINER...]��

| ѡ����       | Ĭ��ֵ | ����                               |
| ------------ | ------ | ---------------------------------- |
| -f,--force   | false  | �Ƿ�ǿ����ֹ��ɾ��һ�������е����� |
| -l,--link    | false  | ɾ�����������ӣ�����������         |
| -v,--volumes | false  | ɾ���������ص����ݾ�               |

- �鿴��ɾ��ֹͣ״̬������

1. �鿴ֹͣ״̬������

```shell
[emon@emon ~]$ docker ps -q -f status=exited
```

2. ɾ��ֹͣ״̬������

```shell
[emon@emon ~]$ docker rm 31f3f0a229e5
```

- ɾ������״̬������

1. �鿴����״̬������

```shell
[emon@emon ~]$ docker ps -q
����
[emon@emon ~]$ docker ps -q --filter status=running
```

2. ɾ������״̬������

```shell
[emon@emon ~]$ docker rm -f 3aa0487c2904
```

## 6������͵�������

ĳЩʱ����Ҫ��������һ��ϵͳǨ�Ƶ�����һ��ϵͳ����ʱ����ʹ��Docker�ĵ���͵������ܡ���Ҳ��Docker�����ṩ��һ����Ҫ���ԡ�

### 6.1����������

����������ָ����һ���Ѿ�������������һ���ļ������ܴ�ʱ��������Ƿ�������״̬������ʹ��docker export���������ĸ�ʽΪ��

docker export [-o|--output[=""]] CONTAINER��

���У�����ͨ��-oѡ����ָ��������tar�ļ�����Ҳ����ֱ��ͨ���ض�����ʵ�֡�

1. �鿴����

```shell
[emon@emon ~]$ docker ps -qa
```

2. ���������ļ�

```shell
[emon@emon ~]$ docker export -o test_for_centos.tar 7fcaad938106
```

֮�󣬿ɽ�������tar�ļ����䵽���������ϣ�Ȼ����ͨ����������뵽ϵͳ�У��Ӷ�ʵ��������Ǩ�ơ�

### 6.2����������

�������ļ��ֿ���ʹ��docker import������ɾ��񣬸������ʽΪ��

docker import [-c|--change[=[]]][-m|--message[=MESSAGE]] file|URL|-[REPOSITORY[:TAG]]

�û�����ͨ��-c, --change=[]ѡ���ڵ����ͬʱִ�ж����������޸ĵ�Dockerfileָ�

```shell
[emon@emon ~]$ docker import test_for_centos.tar centos:7-test
```

ע�⣺��������������Ϊ������Ҫ�����Ż���ֵ�docker ps -qa�б��С�



# �塢�ֿ�



# �������ݹ���



# �ߡ��˿�ӳ������������



