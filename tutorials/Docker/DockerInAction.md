# Dockerʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# ��һ��Vagrant�İ�װ��ʹ��

## 1��Vagrant��ʲô

Vagrant�ǹ��������⻯����֮�ϵ���������л��������ߡ�

- ������ɾ�������
- ������������в���
- �������������״̬
- �Զ������úͰ�װ��������
- ����ͷַ���������л���

- Vagrant�����У���Ҫ����ĳ���������⻯����
  - VirtualBox
  - VMWare



### 1.1�����˽Ƕ�����

- ��ƽ̨
- ���ƶ�
- �Զ������������˹�����
- ���Լӷ���

### 1.2��˾�Ƕ�

- ����������ѵ�ɱ�
- ͳһ��������

VAGRANT+Virtualbox/VMWare+ubuntu/CentOS=Ŀ�껷��

## 2��Vagrant���÷�Χ

- ��������
- ��Ŀ���ñȽϸ���



## 3��Window��װVagrant

1. ����

���ص�ַ��https://www.vagrantup.com/downloads

2. ��װ

˫����װ����װ����ʾ������������������ɣ�

3. �鿴�汾

```bash
$ vagrant --version
Vagrant 2.2.19
$ vagrant -v
Vagrant 2.2.19
```

4. �޸�Vagrant box����·��

add box��ʱ��Ĭ�ϱ������û��ļ����µ�`.vagrant.d`Ŀ¼��ͨ������VAGRANT_HOME�����������Ըı�Ĭ��λ�á�

VAGRANT_HOME = `D:\SharedWorkspace\.vagrant.d`

## 4��Vagrant��ʹ��

### 4.1��ʹ��VirtualBox���������

#### ��һ��������virtualbox

virtualbox��װ��������

#### �ڶ���������box

��β�ѯ����boxes��https://app.vagrantup.com/boxes/search

���ص�ַ��https://app.vagrantup.com/centos/boxes/7

����ʹ�õ�Vagrant��VirtualBox����VMWare��ѡ��`virtualbox`����`vmware_desktop ` ���͵� provider���أ�

���غ󱾵ذ�װ��

```bash
# �������Ϊ��`vagrant add box boxesname boxespath`���Բ����ء�
vagrant box add CentOS/7 CentOS-7-x86_64-Vagrant-2004_01.VMwareFusion.box
```

#### ��������Vagrantfile

- �滮һ��Ŀ¼����ΪVagrant�����Ŀ¼�����磺Vagrant/centos7

�����δ����Vagrantfile����ʼ������Vagrantfile

```bash
vagrant init
# ����ָ��boxes���Ƽ���
vagrant init centos/7
```

- �༭Vagrantfile

```bash
$ vim Vagrantfile
```

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

#### ���Ĳ�����ʼ������

```bash
$ vagrant up
# ָ��virtualbox���provider���Ƽ������ر�˵����Ĭ��Ҳ�� virtualbox
$ vagrant up --provider virtualbox
```



### 4.2��ʹ��VMWare���������

#### ��һ������װVMWare provider���vmware-desktop

1. ����VMWare-utility

https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility

���غ�˫����װ��

2. ����VMWare-desktop�鿴

```bash
$ vagrant plugin install vagrant-vmware-desktop
# ������������
Installing the 'vagrant-vmware-desktop' plugin. This can take a few minutes...
Installed the plugin 'vagrant-vmware-desktop (3.0.1)'!
```

3. ��װVMWare������

˫��VMWare��װ��������

#### �ڶ���������box

��β�ѯ����boxes��https://app.vagrantup.com/boxes/search

���ص�ַ��https://app.vagrantup.com/centos/boxes/7

����ʹ�õ�Vagrant��VirtualBox����VMWare��ѡ��`virtualbox`����`vmware_desktop ` ���͵� provider���أ�

���غ󱾵ذ�װ��

```bash
# �������Ϊ��`vagrant add box boxesname boxespath`���Բ����ء�
vagrant box add CentOS/7 CentOS-7-x86_64-Vagrant-2004_01.VMwareFusion.box
```

#### ��������Vagrantfile

- �滮һ��Ŀ¼����ΪVagrant�����Ŀ¼�����磺Vagrant/centos7

�����δ����Vagrantfile����ʼ������Vagrantfile

```bash
vagrant init
# ����ָ��boxes���Ƽ���
vagrant init centos/7
```

- �༭Vagrant

```bash
$ vim Vagrantfile
```

```bash
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

#### ���Ĳ�����ʼ������

```bash
# ָ��vmware_desktop���provider���Ƽ���
vagrant up --provider vmware_desktop
```



### 4.3��Vagrant���������

### 4.3.1��ͨ��vagrant ssh����

```bash
$ vagrant ssh
[vagrant@localhost ~]$ pwd
/home/vagrant
```



### 4.3.2��ͨ��XShell����

#### 1.�鿴vagrant��ssh����

```bash
$ vagrant ssh-config
# ������������
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

���Կ�����

- HostName 127.0.0.1
- Port 2222
- IdentityFile D:/SharedWorkspace/Vagrant/centos7/.vagrant/machines/default/virtualbox/private_key

#### 2.XShell����

![image-20220311142612246](images/image-20220311142612246.png)



![image-20220311155658798](images/image-20220311155658798.png)

���ȷ�����½���״ε�½������ʾ�������룻��ʱ���������룺 vagrant ���ɣ�

#### 3.�л���root

```bash
# ������ vagrant
[vagrant@localhost ~]$ su - root
Password: 
Last login: Fri Mar 11 07:45:14 UTC 2022 on pts/0
[root@localhost ~]# 
```



## 5��Vagrant�ĳ�������

| ����                         | ����ִ�н��״̬ | ����                                |
| ---------------------------- | ---------------- | ----------------------------------- |
| vagrant --version/vagrant -v |                  | �鿴��ǰ�汾                        |
| vagrant box list             |                  | �鿴Ŀǰ���е�box                   |
| vagrant box add              |                  | ������һ��box                       |
| vagrant box remove < name >  |                  | ɾ��ָ��box                         |
| vagrant init < boxes >       |                  | ��ʼ������vagrantfile               |
| vagrant up                   | running          | ���������                          |
| vagrant ssh                  |                  | ssh��¼�����                       |
| vagrant suspend              | saved            | ���������                          |
| vagrant resume               | running          | ���������                          |
| vagrant halt                 | poweroff         | �ر������                          |
| vagrant reload               | running          | ���������                          |
| vagratn status               | running          | �鿴�����״̬                      |
| vagrant destroy [name\|id]   |                  | ɾ��������������default����ʡ��id |

����˵����vagrant up��һ������������Զ�saved/poweroff״̬����������ѡ�

## 6��Vagrant Plugin����

| ����                                  | ����           |
| ------------------------------------- | -------------- |
| vagrant plugin install < pluginName > | ��װ���       |
| vagrant plugin list                   | �鿴��װ�Ĳ�� |
| vagrant plugin uninstall              | ж�ز��       |
| vagrant plugin help                   | �鿴�����÷�   |



# �����Docker Desktop�İ�װ��ʹ�á����Ƽ���

1. ����

���ص�ַ��https://docs.docker.com/desktop/windows/install/

2. ��װ

��Windows��˫����װ����װ�������ʾ�������ԡ�

3. ���WSL 2 installation is incomplete����

��Docker Desktopʱ��ʾ��

![image-20220311180310750](images/image-20220311180310750.png)



���ȣ�ȷ�����¹����ѹ�ѡ��

![image-20220311180528462](images/image-20220311180528462.png)

����Թ�ѡ������WSLȷʵ�����أ���ô���Ը���WSL��

1���Թ���Ա������� powershell

2��ִ��

```bash
wsl --update
```

3������wsl�������󣬻ᵼ��VMWare����ʧ�ܣ�VMware Workstation �� Device/Credential Guard �����ݡ���

```bash
net stop LxssManager
net start LxssManager
```

��װDocker Desktop��Ҳ��Ĭ�����á����û�ر�Windows���ܡ�=>�����⻯ƽ̨����Ҳ�ᵼ������VMWare����ʧ�����⡣

ͬʱ��������=>��HV��������Ҳ����رգ�

# һ��Docker�İ�װ������

## 1����װ

[�鿴�ٷ�CentOS��װDocker�̳�](https://docs.docker.com/engine/install/centos/)

## 1.0��ɾ���ɰ�Docker

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

���yum����˵���ϰ�װ��δ��װ��δƥ�䣬δɾ���κΰ�װ�������뻷���ɾ���û����ʷ�����ɰ氲װ��

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
# ��װ����
[emon@emon ~]$ sudo yum install -y docker-ce
# ��װָ���汾
[emon@emon ~]$ sudo yum install -y docker-ce-18.06.3.ce
```

5. ����

```shell
[emon@emon ~]$ sudo systemctl start docker
```

6. ��֤��װ

```shell
[emon@emon ~]$ sudo docker version
[emon@emon ~]$ sudo docker info
[emon@emon ~]$ sudo docker run hello-world
```

> ˵�������docker info����ʾ��
> WARNING: bridge-nf-call-iptables is disabled
> WARNING: bridge-nf-call-ip6tables is disabled

����취��

```bash
[emon@emon2 ~]$ sudo vim /etc/sysctl.conf 
```

```bash
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

ʹ֮��Ч��

```bash
[emon@emon2 ~]$ sudo sysctl -p
```

������������ʱdocker info�Ϳ������˱����ˡ�

### 1.3������docker������

- ����

  - DaoCloud

  ���� DaoCloud: https://www.daocloud.io/ �ṩ��Docker��������

  ��¼DaoCloud���ҵ�С���ͼ�꣬����˵��������

  ```bash
  [emon@emon ~]$ curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
  docker version >= 1.12
  {"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
  Success.
  You need to restart docker to take effect: sudo systemctl restart docker
  ```

  - ������

  ��¼���￪����ƽ̨�� https://promotion.aliyun.com/ntms/act/kubernetes.html#industry

  �����������������ť���Զ���ת������̨�ľ���������������ʾע�Ტ��¼��

  ����ࡾ�������ġ���ѡ�񡾾�������������ұ������ɵļ��ٵ�ַ�������ҵģ�`https://pyk8pf3k.mirror.aliyuncs.com`��ִ�����������ϼ��ɣ�

  ```bash
  sudo tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"]
  }
  EOF
  ```

- �鿴

```bash
[emon@emon ~]$ sudo cat /etc/docker/daemon.json 
{"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
```

- ����

```bash
[emon@emon ~]$ sudo systemctl restart docker
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
alias dockerpsf="sudo /usr/bin/docker ps --format \"table{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.RunningFor}}\t{{.Ports}}\""
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

## 3��������Ϣ�鿴

### 3.1���鿴Docker�Ļ�����Ϣ

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

### 3.2���鿴Docker�汾

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



# ����Docker�ļܹ��͵ײ㼼��

## 1��Docker Platform

- Docker�ṩ��һ�����������������app��ƽ̨
- ��app�͵ײ�infrastructure���뿪��

|         Docker Platform          |
| :------------------------------: |
|           Application            |
|          Docker Engine           |
| Infrastructure(physical/virtual) |

### 1.1��Docker Engine

- ��̨���̣�dockerd��
- REST API Server
- CLI�ӿڣ�docker��

![image-20220312112414087](images/image-20220312112414087.png)

�鿴Docker��̨���̣�

```bash
[vagrant@localhost ~]$ ps -ef|grep docker
root      1952     1  0 02:02 ?        00:00:00 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```



## 2��Docker Architecture

![image-20220312113046549](images/image-20220312113046549.png)

## 3���ײ㼼��֧��

- Namespaces��������pid��net��ipc��mnt��uts
- Control groups������Դ����
- Union file systems��Container��image�ķֲ�





# ��������

## 1��ʲô��Image

- �ļ���meta data�ļ��ϣ�root filesystem��
- �ֲ�ģ�����ÿһ�㶼������Ӹı䣬ɾ���ļ�����Ϊһ���µ�image
- ��ͬ��image���Թ�����ͬ��layer
- Image������read-only��

![image-20220312135147138](images/image-20220312135147138.png)



## 2����ȡ����

- ��ȡDocker Hub����
  - ����������������ǰ�ᣬ�ٷ���Docker Hub��վ�Ѿ��ṩ����ʮ������񹩿������ء�
  - �����ʽ�� `docker pull NAME[:TAG]` ���У�NAME�Ǿ���ֿ�����ƣ��������־��񣩣�TAG�Ǿ���ı�ǩ������������ʾ�汾��Ϣ����ͨ������£�����һ��������Ҫ����`����+��ǩ`��Ϣ��
  - �����ָ��TAG��Ĭ��ѡ��latest��ǩ��������زֿ������°汾�ľ���

```shell
# ��Ч�� docker pull registry.hub.docker.com/ubuntu:14.04
[emon@emon ~]$ docker pull ubuntu:14.04
# ��ϲ����centos
[emon@emon ~]$ docker pull centos:7
```

- ��ȡ��������������

```shell
[emon@emon ~]$ docker pull hub.c.163.com/public/ubuntu:14.04
```

### 2.1��������DIYһ��Base Image

#### 2.1.1������hello-world����

```bash
[emon@emon ~]$ docker pull hello-world
[emon@emon ~]$ docker image ls
[emon@emon ~]$ docker run hello-world
```

#### 2.1.2��DIY hello-world����

1����װC���Ա��빤��

```bash
[emon@emon ~]$ sudo yum install -y gcc glibc-static
```

2������hello.c�ļ�������

```bash
[emon@emon ~]$ mkdir dockerdata/hello-world
[emon@emon ~]$ cd dockerdata/hello-world/
[emon@emon hello-world]$ vim hello.c
```

```c
#include<stdio.h>

int main()
{
    printf("hello docker\n");
}
```

```bash
[emon@emon hello-world]$ gcc -static hello.c -o hello
[emon@emon hello-world]$ ls
hello  hello.c
[emon@emon hello-world]$ ./hello 
hello docker
```

3����дDockerfile

```bash
[emon@emon hello-world]$ vim Dockerfile
```

```dockerfile
FROM scratch
ADD hello /
CMD ["/hello"]
```

```bash
# rushing-dockerhub�û����� .-��ǰĿ¼Ѱ��Dockerfile
[emon@emon hello-world]$ docker build -t rushing/hello-world .
# ������������
Sending build context to Docker daemon  865.3kB
Step 1/3 : FROM scratch
 ---> 
Step 2/3 : ADD hello /
 ---> 340544a0099c
Step 3/3 : CMD ["/hello"]
 ---> Running in 1ae3095100d9
Removing intermediate container 1ae3095100d9
 ---> 72b24c24801b
Successfully built 72b24c24801b
Successfully tagged rushing/hello-world:latest
```

4���鿴

- �鿴image

```bash
[emon@emon hello-world]$ docker image ls|grep rushing
rushing/hello-world   latest              72b24c24801b        25 seconds ago      861kB
```

- �鿴image�ķֲ�

```bash
[emon@emon hello-world]$ docker history 72b24c24801b
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
72b24c24801b        2 minutes ago       /bin/sh -c #(nop)  CMD ["/hello"]               0B                  
340544a0099c        2 minutes ago       /bin/sh -c #(nop) ADD file:e7f35cd45d6ae73c7��   861kB 
```

5������

```bash
[emon@emon hello-world]$ docker run rushing/hello-world
# ������������
hello docker
```



## 3���鿴����

- ʹ��`docker images`�����г�����

```shell
[emon@emon ~]$ docker images
# ����
[emon@emon ~]$ docker image ls
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

## 4��Ϊ������ӱ�ǩTag

	Ϊ�˷����ں���������ʹ���ض����񣬻�����ʹ��`docker tag`������Ϊ���ؾ�����������µı�ǩ��

```shell
[emon@emon ~]$ docker tag centos:7 centos:7.8
[emon@emon ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7                   b5b4d78bc90c        2 days ago          203MB
centos              7.8                 b5b4d78bc90c        2 days ago          203MB
```

## 5��ʹ��`inspect`����鿴������ϸ��Ϣ

```shell
[emon@emon ~]$ docker inspect centos:7
```

## 6����Ѱ����

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

## 7��ɾ������

- ʹ�ñ�ǩɾ�����������ʽ�� `docker rmi IMAGE [IMAGE...]`������IMAGE�����Ǳ�ǩ����ID

```shell
[emon@emon ~]$ docker rmi centos:7.8
[emon@emon ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7                   b5b4d78bc90c        2 days ago          203MB
```

- ʹ�þ���ID�����߲���ID��ǰ׺��ɾ������

```shell
[emon@emon ~]$ docker rmi -f b5b4d78bc90c
```

	����壺���ȳ���ɾ������ָ��þ���ı�ǩ��Ȼ��ɾ���þ����ļ��������»��ڸþ���������������Ҳ��ɾ�����񡣵���Ӱ��������

## 8����������

	��������ķ�����Ҫ�����֣��������о�����������������ڱ���ģ�嵼�롢����Dockerfile������

### 8.1���������о�����������������Ƽ���

�÷�����Ҫ��ʹ��docker commit�����Ч���docker container commit

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

### 8.2�����ڱ���ģ�嵼��

�û�Ҳ����ֱ�Ӵ�һ������ϵͳģ���ļ�����һ��������Ҫʹ��`docker import`���

�����ʽΪ`docker import [OPTIONS] file|URL| - [REPOSITORY[:TAG]]`

### 8.3������Dockerfile�������Ƽ���

docker build�����Ч���docker image build

1������Ŀ¼

```bash
[emon@emon ~]$ mkdir docker-centos-vim
[emon@emon ~]$ cd docker-centos-vim/
```

2������Dockerfile

```bash
[emon@emon docker-centos-vim]$ vim Dockerfile 
```

```dockerfile
FROM centos:7
RUN yum install -y vim
```

3����������

```bash
# -t ָ��repository����Ϊ rushing/centos-vim:latest ����rushing��dockerhub�û����� .-��ǰĿ¼Ѱ��Dockerfile
[emon@emon docker-centos-vim]$ docker build -t rushing/centos-vim .
```



## 9����������뾵��

�û�����ʹ��`docker save`��`docker load`��������������뾵��

### 9.1���������

```shell
[emon@emon ~]$ docker save -o test_0.0.1.tar test:0.0.1
```

˵����������ͨ��sudoʹ�õ�docker������ﵽ���ľ�������root�û����þ�����Էַ��������˵��롣

### 9.2�����뾵��

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

## 10���ϴ�����

��ʹ��docker push�����ϴ����񵽲ֿ⣬Ĭ���ϴ���Docker Hub�ٷ��ֿ⣨��Ҫ��¼���������ʽΪ��

`docker push NAME[:TAG] | [REGISTRY_HOST[:REGISTRY_PORT]/]NAME[:TAG]`

�û���Docker Hub��վע�������ϴ����Ƶľ��������û�user�ϴ����ص�test:latest���񣬿���������µı�ǩuser/test:latest��Ȼ����docker push�����ϴ�����

**��ȷ���Լ��� [Docker Hub](https://hub.docker.com/) ����ע����û�������user�滻Ϊ�Լ����û���**

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



![image-20220312161602917](images/2018080801.png)



## 11�������Լ���docker˽��

- ����docker˽��

���ʣ�https://hub.docker.com/

����registry˽���ĵ���https://docs.docker.com/registry/spec/api/#listing-repositories

������registry���ҵ��ٷ��ṩ��registry�������洢�ͷ���docker image��

```bash
[emon@emon ~]$ docker run -d -p 5000:5000 --restart always --name registry registry:2
```

- ˽����ȫ����

���ļ� `/etc/docker/daemon.json` ׷�� `insecure-registries`����

```bash
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "insecure-registries": ["emon:5000"]
}
```

���ļ� `/lib/systemd/system/docker.service` ׷��`EnvironmentFile`��

```bash
# ��EnvironmentFile����һ��׷��
EnvironmentFile=-/etc/docker/daemon.json
```

����Docker����

```bash
[emon@emon hello-world]$ sudo systemctl daemon-reload
[emon@emon hello-world]$ sudo systemctl restart docker
```

- ��DIY��hello-world�������±�����µľ���

```bash
# ע�⣺������ rushing ==> emon:5000
[emon@emon hello-world]$ docker build -t emon:5000/hello-world .
[emon@emon hello-world]$ docker images | grep hello
# ������������
emon:5000/hello-world      latest              da65ce820d2d        29 seconds ago      861kB
```

- �ϴ�������docker˽��

```bash
[emon@emon hello-world]$ docker push emon:5000/hello-world
# ������������
The push refers to repository [emon:5000/hello-world]
da4136101ba6: Pushed 
latest: digest: sha256:77042e6c954be4845eaf2181e4c7cb6d51441fb00cf2c45513b1040cb68f5d32 size: 527
```

- ��֤˽��

���ʣ�http://emon:5000/v2/_catalog

- ɾ������helle-world��image������˽��pull����

```bash
[emon@emon ~]$ docker rmi < imageId >
[emon@emon ~]$ docker pull emon:5000/hello-world
```



# �ġ�����

	����˵�������Ǿ����һ������ʵ��������ͬ���ǣ������Ǿ�̬��ֻ���ļ�����������������ʱ��Ҫ��
��д�㡣�����Ϊ�������ģ�����е�һ���ײ���ϵͳ�������ںˡ�Ӧ������̬����������ϵͳ�����������������Ӧ�ã���ôDocker�������Ƕ������е�һ������һ�飩Ӧ�ã��Լ����Ǳ�������л�����

## 1��ʲô��Container

- ͨ��Image������Copy��

- ��Image layer֮�Ͻ���һ��container layer���ɶ�д��
- �������������ʵ��
- Image����app�Ĵ洢�ͷַ���Container��������app

![image-20220312161602917](images/image-20220312161602917.png)



## 2���鿴����

### 2.1�������÷�

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
# ����
[emon@emon ~]$ docker container ls
```

- ��ʾ����״̬��������7��״̬��created|restarting|runnning|removing|paused|exited|dead)

```shell
[emon@emon ~]$ docker ps -a
# ����
[emon@emon ~]$ docker container ls -a
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

### 2.2���߼��÷�

��������������࣬�������ų���������������ͨ��--filter����-fѡ�������Ҫ��ʾ��������

| �������� | ����                                                         |
| -------- | ------------------------------------------------------------ |
| id       | ����ID                                                       |
| label    | label=<key>����label=<key>=<value>                           |
| status   | ֧�ֵ�״ֵ̬�У�created/restarting/running/removing/paused/exited/dead |
| health   | starting/healthy/unhealthy/none ���ڽ������״̬��������     |

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

### 2.3��Format��ʽ����ʾ

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

3. һ���ȽϺ��õĸ�ʽ

```bash
[emon@emon ~]$ docker ps --format "table{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.RunningFor}}\t{{.Ports}}"
```

[�����÷�](https://www.cnblogs.com/fuyuteng/p/8847331.html)



## 3����������

### 3.1����������

- �½�����

```shell
[emon@emon ~]$ docker create -it --name centos7.8 centos:7
```

ʹ��docker create���������������ֹͣ״̬������ʹ��docker start������������

- ��������

```shell
[emon@emon ~]$ docker start <container_id|container_name>
```

- �½��������������ػ�̬����(Daemonized)���Ƽ���������ʽ��

```bash
[emon@emon ~]$ docker run -itd --name centos7.8 centos:7 [/bin/bash]
```

- �½����������������ػ�̬����

```bash
[emon@emon ~]$ docker run -it --name centos7.8 centos:7 [/bin/bash]
```

�������з�ʽ���û����԰�Ctrl+d��������exit�������˳�������

TIPS���˳�ʱ��ʹ��[Ctrl+D]�����������docker��ǰ�̣߳���������������ʹ��[Ctrl+P+Q]�˳���������ֹ������

**�쳣�����**

�����������ʱ���������´���Ĵ���취��

`WARNING: IPv4 forwarding is disabled. Networking will not work.`

```bash
# ���
[emon@emon ~]$ sudo sysctl -a|grep net.ipv4.ip_forward
# ����
[emon@emon ~]$ sudo vim /etc/sysctl.conf
net.ipv4.ip_forward=1
# ʹ֮��Ч
[emon@emon ~]$ sudo sysctl -p
# ��������
[emon@emon ~]$ sudo systemctl restart network
```

### 3.2��������Դ����

- �޶��ڴ�

```bash
# ָ�������ڴ�200M������200M��Swap����400M��
[emon@emon ~]$ docker run --memory=200M rushing/ubuntu-stress --vm 1 --verbose
# ָ�������ڴ�200M������200M��Swap����400M����ָ��ʹ���ڴ�500M
[emon@emon ~]$ docker run --memory=200M rushing/ubuntu-stress --vm 1 --verbose --vm-bytes 500M
```

- �޶�CPU

```bash
# ����cpuʹ��Ȩ�أ�����test1ռ��10��test2ռ��5�����cpu��������£��ᰴ��2:1����
[emon@emon ~]$ docker run --cpu-shares=10 --name=test1 rushing/ubuntu-stress --cpu 2
[emon@emon ~]$ docker run --cpu-shares=5 --name=test2 rushing/ubuntu-stress --cpu 1
```



## 4����ֹ����

����ʹ��docker stop����ֹһ�������е�������������ĸ�ʽΪdocker stop [-t|--time[=10]][CONTAINER...]��

��������������SIGTERM�źţ��ȴ�һ�γ�ʱʱ�䣨Ĭ��Ϊ10�룩���ٷ���SIGKILL�ź�����ֹ������

```shell
[emon@emon ~]$ docker stop <container_id|container_name>
```

[docker kill �����ֱ�ӷ���SIGKILL�ź���ǿ����ֹ������]

���⣬��Docker������ָ����Ӧ���ս�ʱ������Ҳ���Զ���ֹ��

���⣬docker restart����Ὣһ������̬����������ֹ��Ȼ����������������

```shell
[emon@emon ~]$ docker restart <container_id|container_name>
```

## 5����������

��ʹ��-d����ʱ�����������������̨���û��޷����������е���Ϣ��Ҳ�޷����в�����

���ʱ�������Ҫ�����������в������ж��ַ���������ʹ�ùٷ���attach��exec����Լ���������nsenter���ߵȡ�

### 5.1��attach����

- attach������Ӻ�ִ��exit��ֹͣ����������ʱ��ʽ��

attach��Docker�Դ�����������ʽΪ��

docker attach [--detach-keys[=[]]][--no-stdin] [--sig-proxy[=true]] CONTAINER

| ѡ����             | Ĭ��ֵ | ����                                                |
| ------------------ | ------ | --------------------------------------------------- |
| --detach-keys[=[]] |        | ָ���˳�attachģʽ�Ŀ�ݼ����У�Ĭ����Ctrl-p Ctrl-q |
| --no-stdin         | false  | �Ƿ�رձ�׼����                                    |
| --sig-proxy        | true   | �Ƿ�����յ���ϵͳ�źŸ�Ӧ�ý���                    |

```shell
[emon@emon ~]$ docker attach <container_id|container_name>
```

����ʹ��attach������ʱ�򲻷��㡣���������ͬʱ��attach�������ӵ�ͬһ��������ʱ�����д��ڶ���ͬ����ʾ����ĳ����������������ʱ����������Ҳ�޷�ִ�в����ˡ�

### 5.2��exec����

- exec������Ӻ�ִ��exit��������ֹͣ���������Ƽ���ʽ��

 Docker��1.3.0�汾���ṩ��һ�����ӷ����exec���������������ֱ��ִ���������������Ļ�����ʽΪ

docker exec [-d| --detach][--detach-keys[=[]]]	[-i| --interactive] [--privileged][-t| --tty] [-u| --user[=USER]] CONTAINER COMMAND [ARG...]

| ѡ����           | Ĭ��ֵ | ����                         |
| ---------------- | ------ | ---------------------------- |
| -i,--interactive | false  | �򿪱�׼��������û��������� |
| --priveleged     | false  | �Ƿ��ִ�������Ը�Ȩ��       |
| -t,--tty         | false  | ����α�նˣ�Ĭ��Ϊfalse      |
| -u,--user        |        | ִ��������û�������ID       |

- ��������

```shell
[emon@emon ~]$ docker exec -it <container_id|container_name> /bin/bash
```

- ������ִ����������

```bash
[emon@emon ~]$ docker exec -it <container_id|container_name> ip addr
```



### 5.3��ʹ��nsenter����

����

## 6��ɾ������

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
[emon@emon ~]$ docker rm <container_id|container_name>
```

3. ɾ������ֹͣ״̬������

```bash
[emon@emon ~]$ docker rm $(docker ps -aq --filter status=exited)
# ����
[emon@emon ~]$ docker rm $(docker container ls -f "status=exited" -q)
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

## 7������͵�������

ĳЩʱ����Ҫ��������һ��ϵͳǨ�Ƶ�����һ��ϵͳ����ʱ����ʹ��Docker�ĵ���͵������ܡ���Ҳ��Docker�����ṩ��һ����Ҫ���ԡ�

### 7.1����������

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

### 7.2����������

�������ļ��ֿ���ʹ��docker import������ɾ��񣬸������ʽΪ��

docker import [-c|--change[=[]]][-m|--message[=MESSAGE]] file|URL|-[REPOSITORY[:TAG]]

�û�����ͨ��-c, --change=[]ѡ���ڵ����ͬʱִ�ж����������޸ĵ�Dockerfileָ�

```shell
[emon@emon ~]$ docker import test_for_centos.tar centos:7-test
```

ע�⣺��������������Ϊ������Ҫ�����Ż���ֵ�docker ps -qa�б��С�

## 8���鿴������־

- �����ʽ�� `docker logs [OPTIONS]` <container_id|container_name>

| ѡ����          | Ĭ��ֵ | ����                                                         |
| --------------- | ------ | ------------------------------------------------------------ |
| --details       |        | ��ʾ�������Ϣ                                               |
| -f,--follow     |        | ����ʵʱ��־                                                 |
| --since string  |        | ��ʾ��ĳ��timestamp֮�����־�������ʱ�䣬��42m����42���ӣ� |
| --tail string   |        | ����־ĩβ��ʾ��������־��Ĭ����all                          |
| -t,--timestamps |        | ��ʾʱ���                                                   |
| --until string  |        | ��ʾ��ĳ��timestamp֮ǰ����־���������ʱ�䣬��42m����42���ӣ� |

- �鿴ָ��ʱ������־��ֻ��ʾ���100��

```bash
docker logs -f -t --since="2021-02-17" --tail=100 <container_id|container_name>
```

- �鿴���30���ӵ���־

```bash
docker logs --since 30 <container_id|container_name>
```

- �鿴ĳ��ʱ��֮�����־

```bash
docker logs -t --since="2021-02-17T13:05:30" <container_id|container_name>
```

- ʵʱ�鿴

```bash
docker logs -f <container_id|container_name>
```

- ��ͨ�鿴

```bash
docker logs <container_id|container_name>
```



## 9��ʹ��inspect����鿴������ϸ��Ϣ

```bash
[emon@emon ~]$ docker inspect <container_id|container_name>
```

# �塢Dockerfile�﷨�������ʵ��

[Docker reference](https://docs.docker.com/engine/reference/builder/)

## 1���ؼ��ֽ���

### 1.1���ؼ��֣�FROM

```dockerfile
# ����base image
FROM scratch
```

```dockerfile
# ʹ��base image
FROM centos:7
```

```dockerfile
# ʹ��base image��latest
FROM ubuntu
```

### 1.2���ؼ��֣�LABEL

```dockerfile
LABEL maintainer="rushing@163.com"
LABEL version="1.0"
LABEL description="This is description"
```

˵����

- Metadata�����٣�

### 1.3���ؼ��֣�RUN

```dockerfile
# ��б�߻���
RUN yum update && yum install -y vim \
    python-dev
RUN /bin/bash -c 'source $HOME/.bashrc;echo $HOME'
```

˵����

ÿһ��RUN������������µ�һ�㣡

Ϊ�����ۣ����ӵ�RUN���÷�б�߻��У�

�������÷ֲ㣬�ϲ����������һ�У�

### 1.4���ؼ��֣�WORKDIR

```dockerfile
# ������Ŀ¼��test�ļ���
WORKDIR /root
```

```dockerfile
# ���û�л��Զ�����testĿ¼
WORKDIR /test
WORKDIR demo
# ������Ӧ���� /test/demo
RUN pwd
```

˵����

- ��WORKDIR����Ҫ��RUN cd��
- ����ʹ�þ���Ŀ¼��

### 1.5���ؼ��֣�ADD and COPY

```dockerfile
# ��hello�ļ���ӵ�/Ŀ¼
ADD hello /
```

```dockerfile
# ��ӵ���Ŀ¼����ѹ
ADD test.tar.gz /
```

```dockerfile
WORKDIR /root
# �ᴴ�������ڵ��ļ��У������/root/test/hello
ADD hello test/
```

```dockerfile
WORKDIR /root
# �ᴴ�������ڵ��ļ��У������/root/test/hello
COPY hello test/
```

˵����

- �󲿷������COPY����ADD��

- ADD����COPY���ж��⹦�ܣ���ѹ����
- ���Զ���ļ�/Ŀ¼��ʹ��curl����wget��

### 1.6���ؼ��֣�ENV

```doc
# ���ó���
ENV MYSQL_VERSION 5.6
# ���ó���
RUN apt-get install -y mysql-server="${MYSQL_VERSION}" \
	&& rm -rf /var/lib/apt/lists/*
```

˵����

- ����ʹ��ENV���ӿ�ά���ԣ�

### 1.7���ؼ��֣�VOLUME and EXPOSE

�洢�����硣

### 1.8��RUN vs CMD vs ENTRYPOINT

- RUN��ִ����������µ� IMAGE Layer

- CMD����������������Ĭ��ִ�е�����Ͳ���
  - ��������ʱĬ��ִ�е�����
  - ���docker runָ�����������CMD�������
  - ��������˶��CMD��ֻ�����һ����ִ��

- ENTRYPOINT��������������ʱ���е�����

  - ��������Ӧ�ó�����߷������ʽ����
  - ���ᱻ���ԣ�һ����ִ��
  - ���ʵ����дһ��shell�ű���Ϊentrypoint

  ```dockerfile
  COPY docker-entrypoint.sh /usr/local/bin/
  ENTRYPOINT [ "docker-entrypoint.sh" ]
  
  EXPOSE 27017
  CMD [ "mongod" ]
  ```



#### 1.8.1��ENTRYPOINT֮Shell��ʽ

```bash
[emon@emon ~]$ mkdir -pv ~/dockerdata/entrypoint_shell
[emon@emon ~]$ cd ~/dockerdata/entrypoint_shell/
[emon@emon entrypoint_shell]$ vim Dockerfile
```

```dockerfile
FROM centos:7
ENV name Docker
ENTRYPOINT echo "hello $name"
```

```bash
[emon@emon entrypoint_shell]$ docker build -t rushing/centos-entrypoint-shell .
[emon@emon entrypoint_shell]$ docker run rushing/centos-entrypoint-shell
hello Docker
```

#### 1.8.2��ENTRYPOINT֮Exec��ʽ

```bash
[emon@emon ~]$ mkdir -pv ~/dockerdata/entrypoint_exec
[emon@emon ~]$ cd ~/dockerdata/entrypoint_exec/
[emon@emon entrypoint_exec]$ vim Dockerfile
```

```dockerfile
FROM centos:7
ENV name Docker
ENTRYPOINT [ "bin/bash", "-c", "echo hello $name" ]
```

```bash
[emon@emon entrypoint_exec]$ docker build -t rushing/centos-entrypoint-exec .
[emon@emon entrypoint_exec]$ docker run rushing/centos-entrypoint-exec
hello Docker
```

#### 1.8.3��CMD֮Shell

```bash
[emon@emon ~]$ mkdir -pv ~/dockerdata/cmd_shell
[emon@emon ~]$ cd ~/dockerdata/cmd_shell/
[emon@emon cmd_shell]$ vim Dockerfile
```

```dockerfile
FROM centos:7
ENV name Docker
CMD echo "hello $name"
```

```bash
[emon@emon cmd_shell]$ docker build -t rushing/centos-cmd-shell .
[emon@emon cmd_shell]$ docker run rushing/centos-cmd-shell
hello Docker
# ���ָ�� /bin/bash ʱ���Ḳ��CMD���ִ��
[emon@emon cmd_shell]$ docker run rushing/centos-cmd-shell /bin/bash
```

#### 1.8.4��CMDֵExec

```bash
[emon@emon ~]$ mkdir -pv ~/dockerdata/cmd_exec
[emon@emon ~]$ cd ~/dockerdata/cmd_exec/
[emon@emon cmd_exec]$ vim Dockerfile
```

```dockerfile
FROM centos:7
ENV name Docker
CMD [ "bin/bash", "-c", "echo hello $name" ]
```

```bash
[emon@emon cmd_exec]$ docker build -t rushing/centos-cmd-exec .
[emon@emon cmd_exec]$ docker run rushing/centos-cmd-exec
hello Docker
```



### 1.9��Shell��Exec��ʽ

- Shell��ʽ

```dockerfile
RUN apt-get install -y vim
CMD echo "hello docker"
ENTRYPOINT echo "hello docker"
```

- Exec��ʽ

```dockerfile
RUN [ "apt-get", "install", "-y", "vim" ]
CMD [ "/bin/echo", "hello docker" ]
ENTRYPOINT [ "/bin/echo", "hello docker" ]
```



## 2������

�ο�ʾ����https://github.com/docker-library/mysql

### 2.1��������flask-demo������

1������Ŀ¼

```bash
[emon@emon ~]$ mkdir dockerdata/flask-demo
[emon@emon ~]$ cd dockerdata/flask-demo/
```

2����д����

- ����app.py

```bash
[emon@emon flask-demo]$ vim app.py
```

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "hello docker"

if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )
```

- ��װflask

```bash
[emon@emon flask-demo]$ pip3 install flask
```

- ����

```bash
[emon@emon flask-demo]$ python3 app.py
```

3������Dockerfile

```bash
[emon@emon flask-demo]$ vim Dockerfile
```

```dockerfile
FROM python:2.7
LABEL maintainer="emon<emon@163.com>"
RUN pip install flask
COPY app.py /app
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]
```

4����������

```bash
[emon@emon flask-demo]$ docker build -t rushing/flask-hello-world .
......ʡ��......
Step 4/7 : COPY app.py /app
 ---> 5584b327f25d
Step 5/7 : WORKDIR /app
Cannot mkdir: /app is not a directory
```

���Կ���Step 5/7 ʧ���ˣ���δ���

����Step 4/7�����ľ���㣺

```bash
[emon@emon flask-demo]$ docker run -it 5584b327f25d /bin/bash
root@7666f9b78e80:/# ls -l|grep app
-rw-rw-r--.   1 root root 212 Mar 13 09:52 app
```

����app����һ��Ŀ¼������һ���ļ���

����Dockerfile���ݣ�

```dockerfile
FROM python:2.7
LABEL maintainer="emon<emon@163.com>"
RUN pip install flask
COPY app.py /app/
WORKDIR /app
EXPOSE 5000
CMD ["python", "app.py"]
```

�ٴδ�������

```bash
[emon@emon flask-demo]$ docker build -t rushing/flask-hello-world .
```

5�����о���

```bash
[emon@emon flask-demo]$ docker run rushing/flask-hello-world
# ������������
 * Serving Flask app "app" (lazy loading)
 * Environment: production
   WARNING: This is a development server. Do not use it in a production deployment.
   Use a production WSGI server instead.
 * Debug mode: on
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 471-935-875
```

### 2.2��������ubuntu-stress���߾���

1������Ŀ¼

```bash
[emon@emon ~]$ mkdir dockerdata/ubuntu-stress
[emon@emon ~]$ cd dockerdata/ubuntu-stress/
```

2������Dockerfile

```bash
[emon@emon ubuntu-stress]$ vim Dockerfile
```

```dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y stress
ENTRYPOINT ["/usr/bin/stress"]
CMD []
```

3����������

```bash
[emon@emon ubuntu-stress]$ docker build -t rushing/ubuntu-stress .
```

4�����о���

```bash
[emon@emon ubuntu-stress]$ docker run -it rushing/ubuntu-stress --vm 1 --verbose
```



# ��������

## 6.1������Ļ���֪ʶ

### 6.1.1������ķ���

- ����
  - Bridge Network
  - Host Network
  - None Network
- ���
  - Overlay Network

### 6.1.2������ķֲ�

![image-20220314093103079](images/image-20220314093103079.png)

### 6.1.3������IP��˽��IP

- Public IP���������ϵ�Ψһ��ʶ�����Է���internet
- Private IP�������ڻ�������ʹ�ã����������ڲ�ʹ��

| ��� | ����                         | ʾ��           |
| ---- | ---------------------------- | -------------- |
| A��  | 10.0.0.0--10.255.255.255     | 10.0.0.0/8     |
| B��  | 172.16.0.0--172.31.255.255   | 172.16.0.0/12  |
| C��  | 192.168.0.0--192.168.255.255 | 192.168.0.0/16 |

### 6.1.4�������ַת��NAT

![image-20220314124559772](images/image-20220314124559772.png)

### 6.1.5��ping��telnet�Լ�wireshark

- ping(ICMP)����֤IP�Ŀɴ���
- telnet����֤����Ŀ�����
- wireshark��ץ������



## 6.2��Linux���������ռ�

### 6.2.1��docker�����������ռ�

����һ��������Ϊ��ʾ������

```bash
# ��������������
[emon@emon ~]$ docker run -d --name test1 busybox /bin/sh -c "while true; do sleep 3600; done"
# �鿴����
[emon@emon ~]$ docker ps 
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
c77a3a22a9b8        busybox             "/bin/sh -c 'while t��"   49 seconds ago      Up 48 seconds                           test1
# ��������
[emon@emon ~]$ docker exec -it c77a3a22a9b8 /bin/sh
# �������� ip a ����Чip addr��
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
96: eth0@if97: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

���ϣ�ip aչʾ�Ľ��������test1������������������ռ䡣



������һ��������

```bash
[emon@emon ~]$ docker run -d --name test2 busybox /bin/sh -c "while true; do sleep 3600; done"
# �鿴test2���������������ռ�
[emon@emon ~]$ docker exec -it b966b6ee1664 ip a
```

### 6.2.2��linux�����������ռ�

#### ���������������ռ䣿

- �鿴���������ռ��б�

```bash
[emon@emon ~]$ sudo ip netns list
```

- ������������ռ�

```bash
[emon@emon ~]$ sudo ip netns add test1
[emon@emon ~]$ sudo ip netns add test2
```

- �鿴ĳ�����������ռ�����

```bash
[emon@emon ~]$ sudo ip netns exec test1 ip a
# ������������
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
[emon@emon ~]$ sudo ip netns exec test1 ip link
# ������������
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

- ����lo

```bash
[emon@emon ~]$ sudo ip netns exec test1 ip link set dev lo up
[emon@emon ~]$ sudo ip netns exec test1 ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

#### ��δ�ͨ���������ռ䣿

- ���������veth pair

```bash
# ������������veth pair
[emon@emon ~]$ sudo ip link add veth-test1 type veth peer name veth-test2
# �鿴������ip link�����Կ���veth-test1��veth-test2
[emon@emon ~]$ sudo ip link

# ���veth-test1��test1�����ռ�
[emon@emon ~]$ sudo ip link set veth-test1 netns test1
# �鿴test1�����ռ��µ�ip link
[emon@emon ~]$ sudo ip netns exec test1 ip link

# ���veth-test2��test2�����ռ�
[emon@emon ~]$ sudo ip link set veth-test2 netns test2
# �鿴test2�����ռ��µ�ip link
[emon@emon ~]$ sudo ip netns exec test2 ip link

# �ٴβ鿴������ip link��������veth-test1��veth-test2
[emon@emon ~]$ sudo ip link
```

ͼ�⣺

![image-20220314155521836](images/image-20220314155521836.png)



- Ϊ�����ռ�test1��test2���IP��ַ

```bash
# Ϊtest1�����ռ��ϵ�veth-test1���IP��ַ
[emon@emon ~]$ sudo ip netns exec test1 ip addr add 192.168.1.1/24 dev veth-test1
# Ϊtest2�����ռ��ϵ�veth-test2���IP��ַ
[emon@emon ~]$ sudo ip netns exec test2 ip addr add 192.168.1.2/24 dev veth-test2

# ����test1�ϵ�veth-test1
[emon@emon ~]$ sudo ip netns exec test1 ip link set dev veth-test1 up
# ����test2�ϵ�veth-test2
[emon@emon ~]$ sudo ip netns exec test2 ip link set dev veth-test2 up

# ==================================================
# �鿴test1��test2��ip link
[emon@emon ~]$ sudo ip netns exec test1 ip link
# ������������
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
101: veth-test1@if100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether fa:6e:7e:58:57:03 brd ff:ff:ff:ff:ff:ff link-netnsid 1
[emon@emon ~]$ sudo ip netns exec test2 ip link
# ������������
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
100: veth-test2@if101: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether fe:ca:9f:29:72:0b brd ff:ff:ff:ff:ff:ff link-netnsid 0
    
# �鿴test1��test2��ip a
[emon@emon ~]$ sudo ip netns exec test1 ip a
# ������������
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
101: veth-test1@if100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fa:6e:7e:58:57:03 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet 192.168.1.1/24 scope global veth-test1
       valid_lft forever preferred_lft forever
    inet6 fe80::f86e:7eff:fe58:5703/64 scope link 
       valid_lft forever preferred_lft forever
[emon@emon ~]$ sudo ip netns exec test2 ip a
# ������������
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
100: veth-test2@if101: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether fe:ca:9f:29:72:0b brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.1.2/24 scope global veth-test2
       valid_lft forever preferred_lft forever
    inet6 fe80::fcca:9fff:fe29:720b/64 scope link 
       valid_lft forever preferred_lft forever
       
# ��test1��ͨtest2��֤
[emon@emon ~]$ sudo ip netns exec test1 ping 192.168.1.2
```

## 6.3��Docker����

### 6.3.1��Docker���������б�

- �鿴Docker�����б�

```bash
[emon@emon ~]$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4350d5c6e428        bridge              bridge              local
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
# �鿴bridge��ϸ��Ϣ�е� Containers ���԰�����������Ϣ
[emon@emon ~]$ sudo docker network inspect bridge
```

- ��װ���繤��

```bash
[emon@emon ~]$ sudo yum install -y bridge-utils
[emon@emon ~]$ brctl show
bridge name	bridge id		STP enabled	interfaces
docker0		8000.02426f6e5033	no		veth3950c82
										veth4b7c084
```

˵����������veth����Ӧ����������ͨ��docker0���bridge��������������ͼ���£�

### 6.3.2��Docker����֮bridge

#### �����以���������ͼ

![image-20220314164344245](images/image-20220314164344245.png)



#### ������η��ʵ�������

![image-20220314165401819](images/image-20220314165401819.png)





#### ������ͨ��Ĭ�ϵ�birdge��link

- ɾ�������´���test2����test2ͨ��link��ʽ���ӵ�test1����

```bash
[emon@emon ~]$ docker rm -f test2
[emon@emon ~]$ docker run -d --name test2 --link test1 busybox /bin/sh -c "while true; do sleep 3600; done"
# ����ͨ��test1��������ͨ
[emon@emon ~]$ docker exec -it test2 /bin/sh
/ # ping test1
PING test1 (172.17.0.2): 56 data bytes
64 bytes from 172.17.0.2: seq=0 ttl=64 time=0.056 ms
```

- ��ԭtest2

```bash
[emon@emon ~]$ docker rm -f test2
[emon@emon ~]$ docker run -d --name test2 busybox /bin/sh -c "while true; do sleep 3600; done"
```

#### ������ͨ���Զ����bridge��link

- �����µ�bridge

```bash
[emon@emon ~]$ docker network create -d bridge my-bridge
```

- ����������ָ�����½���bridge

```bash
[emon@emon ~]$ docker run -d --name test3 --network my-bridge busybox /bin/sh -c "while true; do sleep 3600; done"
# �鿴������bridge�󶨹�ϵ
[emon@emon ~]$ brctl show
bridge name	bridge id		STP enabled	interfaces
br-1c371c5eabde		8000.02426de4ab41	no		veth911f9ea
docker0		8000.02426f6e5033	no		veth3950c82
										veth4b7c084
# �鿴my-bridge��ϸ��Ϣ�е� Containers ���԰�����������Ϣ
[emon@emon ~]$ sudo docker network inspect my-bridge
```

- ������������test2���ӵ�my-bridge

```bash
[emon@emon ~]$ docker network connect my-bridge test2
# �鿴my-bridge��ϸ��Ϣ�е� Containers ���԰�����������Ϣ������test2�Ծɺ�bridge��������
[emon@emon ~]$ sudo docker network inspect bridge
# �鿴my-bridge��ϸ��Ϣ�е� Containers ���԰�����������Ϣ������test2Ҳ���ӵ�my-bridge��
[emon@emon ~]$ sudo docker network inspect my-bridge
```

- ��������������ӵ��Զ���bridge������ͨ��name��pingͨ�Է�

```bash
[emon@emon ~]$ docker exec -it test3 /bin/sh
/ # ping test2
PING test2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.058 ms

[emon@emon ~]$ docker exec -it test2 /bin/sh
/ # ping test3
PING test3 (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.053 ms
```



### 6.3.3�������Ķ˿�ӳ��

- ����һ��nginx������

```docker
[emon@emon ~]$ docker run --name web -d -p 80:80 nginx
```



### 6.3.4��Docker����֮none

��ʼ��������

```bash
# ��������
[emon@emon ~]$ docker rm -f $(docker ps -qa)
# �����Զ���bridge
[emon@emon ~]$ docker network rm my-bridge

[emon@emon ~]$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4350d5c6e428        bridge              bridge              local
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
[emon@emon ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

- ������������none

```bash
[emon@emon ~]$ docker run -d --name test1 --network none busybox /bin/sh -c "while true; do sleep 3600; done"
# �鿴����none������
[emon@emon ~]$ docker network inspect none
# �鿴test1�����������ռ�
[emon@emon ~]$ docker exec -it test1 /bin/sh
/ # ip a �鿴�õ�������������
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
```

### 6.3.5��Docker����֮host

��ʼ��������

```bash
# ��������
[emon@emon ~]$ docker rm -f $(docker ps -qa)

[emon@emon ~]$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4350d5c6e428        bridge              bridge              local
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
[emon@emon ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

- ������������host

```bash
[emon@emon ~]$ docker run -d --name test1 --network host busybox /bin/sh -c "while true; do sleep 3600; done"
# �鿴����host������
[emon@emon ~]$ docker network inspect host
# �鿴test1�����������ռ�
[emon@emon ~]$ docker exec -it test1 /bin/sh
/ # ip a ���Ե�֪�������������������������ռ�
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:0c:29:57:cc:44 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.116/24 brd 192.168.1.255 scope global noprefixroute ens33
       valid_lft forever preferred_lft forever
    inet6 2409:8a28:cbc:b580:1d13:cc6f:fd77:6e75/64 scope global dynamic noprefixroute 
       valid_lft 86393sec preferred_lft 14393sec
    inet6 fe80::4964:c0da:32bd:1d54/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue 
    link/ether 02:42:6f:6e:50:33 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:6fff:fe6e:5033/64 scope link 
       valid_lft forever preferred_lft forever
```

## 6.4������������������Ӧ�õĲ�����ʾ

��ʼ��������

```bash
# ��������
[emon@emon ~]$ docker rm -f $(docker ps -qa)

[emon@emon ~]$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4350d5c6e428        bridge              bridge              local
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
[emon@emon ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

1������Ŀ¼

```bash
[emon@emon ~]$ mkdir dockerdata/flask-redis
[emon@emon ~]$ cd dockerdata/flask-redis/
```

2����д����

- ����app.py

```bash
[emon@emon flask-redis]$ vim app.py
```

```python
from flask import Flask
from redis import Redis
import os
import socket

app = Flask(__name__)
redis = Redis(host=os.environ.get('REDIS_HOST', '127.0.0.1'), port=6379)


@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello Container World! I have been seen %s times and my hostname is %s.\n' % (redis.get('hits'),socket.gethostname())


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
```

3������Dockerfile

```bash
[emon@emon flask-redis]$ vim Dockerfile
```

```dockerfile
FROM python:2.7
LABEL maintainer="emon<emon@163.com>"
COPY . /app
WORKDIR /app
RUN pip install flask redis
EXPOSE 5000
CMD ["python", "app.py"]
```

4������redis����

```bash
[emon@emon flask-redis]$ docker run -d --name redis redis
```

5����������

```bash
[emon@emon flask-redis]$ docker build -t rushing/flask-redis .
```

6�����о���

```bash
[emon@emon flask-redis]$ docker run -d -p 5000:5000 --link redis --name flask-redis -e REDIS_HOST=redis rushing/flask-redis
# ��������
[emon@emon flask-redis]$ docker exec -it flask-redis /bin/bash
# �鿴env
root@f37f93de0bcb:/app# env|grep REDIS_HOST
REDIS_HOST=redis
# ���д���
root@f37f93de0bcb:/app# curl 127.0.0.1:5000
Hello Container World! I have been seen 1 times and my hostname is f37f93de0bcb.
root@f37f93de0bcb:/app# curl 127.0.0.1:5000
Hello Container World! I have been seen 2 times and my hostname is f37f93de0bcb.
root@f37f93de0bcb:/app# curl 127.0.0.1:5000

# ��������������
[emon@emon flask-redis]$ curl 127.0.0.1:5000
Hello Container World! I have been seen 4 times and my hostname is 28bc2a8ace9e.
```



## 6.5��Overlay��Underlay��ͨ�׽���

**����׼����emon��emon2��������̨������docker�ָ���û�����������е�״̬������װetcd��Ⱥ��**

### 6.5.1�������ͨ�ţ�Vxlan��

![image-20220315081508907](images/image-20220315081508907.png)

- underlay���������Ϊ������֮���ͨ�ţ�
- overlay���������Ϊ��ͬ��������docker����֮���ͨ�ţ�

### 6.5.2����װetcd��Ⱥ

| ������ | IP1-��ͥ      | IP2-��˾   | ��������     |
| ------ | ------------- | ---------- | ------------ |
| emon   | 192.168.1.116 | 10.0.0.116 | docker-node1 |
| emon2  | 192.168.1.117 | 10.0.0.117 | docker-node2 |

1����װetcd

```bash
# emon������װ
[emon@emon ~]$ sudo yum install -y etcd
# emon2������װ
[emon@emon2 ~]$ sudo yum install -y etcd
```

2���޸�����

- emon��������docker-node1

```bash
# ����ԭ�����ļ����༭
[emon@emon ~]$ sudo cp /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak
[emon@emon ~]$ sudo vim /etc/etcd/etcd.conf 
```

```properties
#[Member]
# ÿ��������д�Լ���������ȡ hostname -s ֵ����
ETCD_NAME="emon"
# �����������ݱ����·����Ĭ��Ϊ `$name}.etcd`
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_WAL_DIR="/var/lib/etcd/default.etcd/wal"
# ���ڼ������� etcd member ���ӣ��ر�ע�⣬ip��ַ����ʹ�����������
ETCD_LISTEN_PEER_URLS="http://10.0.0.116:2380"
# ���� etcdctl �������ӣ����� localhost ���ڱ�������
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.116:2379,http://localhost:2379"

#[Clustering]
# �������ڼ������������� member �ĵ�ַ
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.116:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.116:2379,http://localhost:2379"
# ������Ⱥʱ��ʹ�þ�̬���ӷ���������ÿ�� member ������ endpoint
ETCD_INITIAL_CLUSTER="emon=http://10.0.0.116:2380,emon2=http://10.0.0.117:2380"
# ���ڱ�Ǽ�ȺΨһ�Ե�token
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
# ��ʾ��ʼ����Ⱥ
ETCD_INITIAL_CLUSTER_STATE="new"
```

- emon2��������docker-node2

```bash
# ����ԭ�����ļ����༭
[emon@emon2 ~]$ sudo cp /etc/etcd/etcd.conf /etc/etcd/etcd.conf.bak
[emon@emon2 ~]$ sudo vim /etc/etcd/etcd.conf 
```

```properties
#[Member]
# ÿ��������д�Լ���������ȡ hostname -s ֵ����
ETCD_NAME="emon2"
# �����������ݱ����·����Ĭ��Ϊ `$name}.etcd`
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_WAL_DIR="/var/lib/etcd/default.etcd/wal"
# ���ڼ������� etcd member ���ӣ��ر�ע�⣬ip��ַ����ʹ�����������
ETCD_LISTEN_PEER_URLS="http://10.0.0.117:2380"
# ���� etcdctl �������ӣ����� localhost ���ڱ�������
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.117:2379,http://localhost:2379"

#[Clustering]
# �������ڼ������������� member �ĵ�ַ
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.117:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.117:2379,http://localhost:2379"
# ������Ⱥʱ��ʹ�þ�̬���ӷ���������ÿ�� member ������ endpoint
ETCD_INITIAL_CLUSTER="emon=http://10.0.0.116:2380,emon2=http://10.0.0.117:2380"
# ���ڱ�Ǽ�ȺΨһ�Ե�token
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
# ��ʾ��ʼ����Ⱥ
ETCD_INITIAL_CLUSTER_STATE="new"
```

3��������Ⱥ

```bash
# ����etcd����
[emon@emon ~]$ sudo systemctl start etcd
[emon@emon2 ~]$ sudo systemctl start etcd

# ���ÿ�������
[emon@emon ~]$ sudo systemctl enable etcd
[emon@emon2 ~]$ sudo systemctl enable etcd
```

ע�� , ��һ̨������etcd(master�ڵ�)(isLeader=true)��ȴ��ڶ�̨����֮�� ,�Ż������ɹ����ڴ�֮ǰ�Ῠ����

- �鿴�汾

```bash
[emon@emon ~]$ etcd --version
# ������������
etcd Version: 3.3.11
Git SHA: 2cf9e51
Go Version: go1.10.3
Go OS/Arch: linux/amd64
```

- ����״̬���

```bash
[emon@emon ~]$ sudo systemctl status etcd
```

- �鿴��Ⱥ�������

```bash
[emon@emon ~]$ etcdctl cluster-health
# ������������
member 122b032f3d6b6b6 is healthy: got healthy result from http://10.0.0.117:2379
member 85cea699a6c68067 is healthy: got healthy result from http://10.0.0.116:2379
```

- �鿴��Ⱥ���нڵ�

```bash
[emon@emon ~]$ etcdctl member list
# ������������
122b032f3d6b6b6: name=emon2 peerURLs=http://10.0.0.117:2380 clientURLs=http://10.0.0.117:2379,http://localhost:2379 isLeader=false
85cea699a6c68067: name=emon peerURLs=http://10.0.0.116:2380 clientURLs=http://10.0.0.116:2379,http://localhost:2379 isLeader=true
```

- ��һ̨�豸�Ƴ�����Ⱥ�������Ǽ�Ⱥ�ڵ�ţ�ʹ��list���Բ鿴��

```bash
# �Ƴ�֮�󣬸ýڵ��etcd�����Զ��ر�
etcdctl member remove 122b032f3d6b6b6
```

- ����һ���ڵ�

```bash
etcdctl member update 122b032f3d6b6b6
```

- ����key=hello,value=world

```bash
etcdctl set hello world
```

- �鿴key��ֵ

```bash
etcdctl get hello
```

- �鿴key�б�

```bash
etcdctl ls /
```

- �رռ�Ⱥ

```bash
# ����Ҫ��etcd��Ⱥ�������ã���򵥵ķ�ʽ�ǹرռ�Ⱥ��ɾ������ etcd member �е� ETCD_DATA_DIR �����ж����������Ŀ¼��
[emon@emon ~]$ sudo systemctl stop etcd
```



4���л�IP����

- companys�л���houses

```bash
[emon@emon ~]$ sudo sed -n 's/10.0.0/192.168.1/gp' /etc/etcd/etcd.conf
[emon@emon ~]$ sudo sed -i 's/10.0.0/192.168.1/g' /etc/etcd/etcd.conf
```

- houses�л���companys

```bash
[emon@emon ~]$ sudo sed -n 's/192.168.1/10.0.0/gp' /etc/etcd/etcd.conf
[emon@emon ~]$ sudo sed -i 's/192.168.1/10.0.0/g' /etc/etcd/etcd.conf
```

5����Ⱥ��������ڵ㣨��ʱ�ڵ㣩

����1�������Ա

```bash
etcdctl member add name=emon3 --peer-urls="http://10.0.0.118:2380"
```

����2��ɾ���½ڵ��dataĿ¼

```bash
# ע�⣬���½ڵ����������
rm -rf /var/lib/etcd/default.etcd
```

����3���½ڵ���������etcd.conf

ע�⣬����� `ETCD_INITIAL_CLUSTER_STATE="existing"`�����Ѵ��ڽڵ㡣

����4�������½ڵ��etcd����

```bash
systemctl start etcd
```

PS : ���費�ܴ� , ��������п��� , ���¼ӽڵ�֮�� , ��Ⱥ����һ�� , �Ƚϲ����״�



### 6.5.3������overlay network

#### ����docker����

```bash
# emon����������
[emon@emon ~]$ sudo systemctl stop docker
# ˵���������һ��ִ��ʱ����������� [1] 31966 ʱ��û����Ϣ�ˣ�Ҫ����һ��
[emon@emon ~]$ sudo dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.0.0.116:2379 --cluster-advertise=10.0.0.116:2375&

# emon2����������
[emon@emon2 ~]$ sudo systemctl stop docker
# ������������
Warning: Stopping docker.service, but it can still be activated by:
  docker.socket
# ֹͣdocker.socket����
[emon@emon2 ~]$ sudo systemctl stop docker.socket
# ˵���������һ��ִ��ʱ����������� [1] 31966 ʱ��û����Ϣ�ˣ�Ҫ����һ��
[emon@emon2 ~]$ sudo dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --cluster-store=etcd://10.0.0.117:2379 --cluster-advertise=10.0.0.117:2375&
```

#### ����overlay network

��emon�������ϴ���һ��demo��overlay network

```bash
[emon@emon ~]$ sudo docker network ls 
NETWORK ID          NAME                DRIVER              SCOPE
b685c764ea40        bridge              bridge              local
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
[emon@emon ~]$ sudo docker network create -d overlay demo
a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454
[emon@emon ~]$ sudo docker network ls 
NETWORK ID          NAME                DRIVER              SCOPE
b685c764ea40        bridge              bridge              local
a99463bedc7d        demo                overlay             global
4913d65f0331        host                host                local
5dddd8fbaae8        none                null                local
[emon@emon ~]$ docker network inspect demo
[
    {
        "Name": "demo",
        "Id": "a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454",
        "Created": "2022-03-15T11:33:36.272826446+08:00",
        "Scope": "global",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.0.0.0/24",
                    "Gateway": "10.0.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

���ǻῴ����emon2�ϣ����demo��overlay network�ᱻͬ��������

```bash
[emon@emon2 ~]$ sudo docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
986acb0bb4f2   bridge    bridge    local
a99463bedc7d   demo      overlay   global
82cc9a054945   host      host      local
490e5622c907   none      null      local
[emon@emon2 ~]$ docker network inspect demo
[
    {
        "Name": "demo",
        "Id": "a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454",
        "Created": "2022-03-15T11:33:36.272826446+08:00",
        "Scope": "global",
        "Driver": "overlay",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "10.0.0.0/24",
                    "Gateway": "10.0.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {},
        "Labels": {}
    }
]
```

ͨ���鿴etcd��key-value�����ǻ�ȡ�������demo��network��ͨ��etcd��emonͬ����emon2�ġ�

```bash
[emon@emon2 ~]$ etcdctl ls /docker
/docker/network
/docker/nodes
[emon@emon2 ~]$ etcdctl ls /docker/nodes
/docker/nodes/10.0.0.116:2375
/docker/nodes/10.0.0.117:2375
[emon@emon2 ~]$ etcdctl ls /docker/network
/docker/network/v1.0
[emon@emon2 ~]$ etcdctl ls /docker/network/v1.0
/docker/network/v1.0/ipam
/docker/network/v1.0/idm
/docker/network/v1.0/overlay
/docker/network/v1.0/network
/docker/network/v1.0/endpoint_count
/docker/network/v1.0/endpoint
[emon@emon2 ~]$ etcdctl ls /docker/network/v1.0/network
/docker/network/v1.0/network/a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454
# ����jq����Ѻ�json��ʽ����װjq��sudo yum install -y jq
[emon@emon2 ~]$ etcdctl get /docker/network/v1.0/network/a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454|jq .
{
  "addrSpace": "GlobalDefault",
  "attachable": false,
  "configFrom": "",
  "configOnly": false,
  "created": "2022-03-15T11:33:36.272826446+08:00",
  "enableIPv6": false,
  "generic": {
    "com.docker.network.enable_ipv6": false,
    "com.docker.network.generic": {}
  },
  "id": "a99463bedc7d7972ed5866607212d91b88e080e6ef56b87b2c21973146db7454",
  "inDelete": false,
  "ingress": false,
  "internal": false,
  "ipamOptions": {},
  "ipamType": "default",
  "ipamV4Config": "[{\"PreferredPool\":\"\",\"SubPool\":\"\",\"Gateway\":\"\",\"AuxAddresses\":null}]",
  "ipamV4Info": "[{\"IPAMData\":\"{\\\"AddressSpace\\\":\\\"GlobalDefault\\\",\\\"Gateway\\\":\\\"10.0.0.1/24\\\",\\\"Pool\\\":\\\"10.0.0.0/24\\\"}\",\"PoolID\":\"GlobalDefault/10.0.0.0/24\"}]",
  "labels": {},
  "loadBalancerIP": "",
  "name": "demo",
  "networkType": "overlay",
  "persist": true,
  "postIPv6": false,
  "scope": "global"
}
```

### 6.5.4������overlay����docker����

```bash
[emon@emon ~]$ docker run -d --name test1 --network demo busybox /bin/sh -c "while true; do sleep 3600; done"
```

# �ߡ��ֿ�



# �ˡ����ݹ���



# �š��˿�ӳ������������





