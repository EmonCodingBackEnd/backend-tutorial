# Kubernetes实践

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、Kubernetes基础概念



![image-20220328213313664](images/image-20220328213313664.png)



![image-20220328213551170](images/image-20220328213551170.png)



![image-20220328213835819](images/image-20220328213835819.png)

![image-20220328214019324](images/image-20220328214019324.png)

![image-20220328214430562](images/image-20220328214430562.png)



![image-20220328220806300](images/image-20220328220806300.png)

![image-20220328220425586](images/image-20220328220425586.png)

# 二、搭建K8S集群

## 0、安装步骤总览

【安装准备】==>【安装容器引擎】==>【下载安装工具、node组件】==>【核心组件镜像下载】==>【初始化master】==>【安装集群网络】==>【加入work节点】==>【配置命令行环境】==>【安装Dashboard】

# 一、实践准备环境

## 1、服务器规划

| 机器名 | 系统类型 | IP1-家庭      | IP2-公司   | 内存 | 部署内容 |
| ------ | -------- | ------------- | ---------- | ---- | -------- |
| emon   | CentOS7  | 192.168.1.116 | 10.0.0.116 | >=2G | master   |
| emon2  | CentOS7  | 192.168.1.117 | 10.0.0.117 | >=2G | worker   |
| emon3  | CentOS7  | 192.168.1.118 | 10.0.0.118 | >=2G | worker   |

## 2、系统设置（所有节点）

说明：以下命令在root权限下执行；如果不在root用户，可以提升权限：```sudo -i```

### 2.1、主机名

主机名必须每个节点都不一样。

```bash
# 查看主机名
hostname
# 设置主机名：注意修改为具体的主机名
hostnamectl set-hostname emon
```

### 2.2、本地DNS

配置host，使得所有节点之间可以通过hostname互相访问。

```bash
vim /etc/hosts
```

```bash
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```

### 2.3、SSH免密登录

注意：这里是root用户！

[SSH免密登录](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#522%E5%89%8D%E7%BD%AE%E5%AE%89%E8%A3%85)

### 2.4、安装依赖包

```bash
# 更新yum
yum update
# 安装依赖包
yum install -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp
```

### 2.5、关闭防火墙、重置iptables、关闭swap、关闭selinux和dnsmasq

```bash
# 关闭防火墙
systemctl stop firewalld && sudo systemctl disable firewalld
# 重置iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT
# 关闭swap
swapoff -a
# 去掉swap开机启动
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
# 关闭selinux
setenforce 0
# 防止重启恢复
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# 关闭dnsmasq（否则可能导致docker容器无法解析域名）：如果没有该启动单元，可以忽略！
systemctl stop dnsmasq && systemctl disable dnsmasq
```

### 2.6、系统参数设置

```bash
# 制作配置文件
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF
# 生效文件
sysctl -p /etc/sysctl.d/kubernetes.conf
```

> 如果执行sysctl -p报错：sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: 没有那个文件或目录
>
> 解决办法：
>
> 加载模块：
>
> modprobe br_netfilter
>
> 生效文件：
>
> sysctl -p /etc/sysctl.d/kubernetes.conf
>
> 移除模块：
>
> modprobe -r br_netfilter

## 3、安装容器引擎docker（所有节点）

- Docker安装

[Docker安装](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Docker/DockerInAction.md#%E4%B8%80docker%E7%9A%84%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE)

- 接受所有ip的数据包转发

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# 新增：在ExecStart=XXX上面添加一行，内容如下：（k8s的网络需要）
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
```

- 镜像私服、存储位置、加速器

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# 新增：如果有必要，可在ExecStart后面追加一行私服地址的配置【如果没有http协议的镜像私服，可无需配置】
EnvironmentFile=-/etc/docker/daemon.json
```

对文件 `/etc/docker/daemon.json` 追加 `insecure-registries`内容：

```bash
# 创建docker存储路径：非必须
mkdir /usr/local/lib/docker
# 调整docker配置（可选）
# - graph: 设置docker数据目录：选择比较大的分区（我这里是根目录就不需要配置了，默认为/var/lib/docker）
# - exec-opts: 设置cgroup driver（默认是cgroupfs，不推荐设置systemd）
vim /etc/docker/daemon.json
```

```bash
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "graph": "/usr/local/lib/docker",
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "insecure-registries": ["emon:5080"]
}
```

- 启动服务

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
[emon@emon ~]$ sudo systemctl restart docker
```



## 4、安装必要工具（所有节点）

### 4.1、工具说明

- kubeadm：部署集群用的命令
- kubelet：在集群中每台机器上都要运行的组件，负责管理pod、容器的生命周期
- kubectl：集群管理工具

### 4.2、安装方法（科学上网）

```bash
# 配置yum源
cat <<EOF > /etc/yum.repos.d/kubernets.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-pacl
exclude=kube*
EOF
# 安装工具
yum install -y kubelet-1.23.5 kubeadm-1.23.5 kubectl-1.23.5 --disableexcludes=kubernetes
# 启动kubelet
systemctl enable kubelet && systemctl start kubelet
```

### 4.2、安装方法（普通上网）

不能科学上网需要把yum源改成阿里云的镜像。

```bash
# 配置yum源
cat <<EOF > /etc/yum.repos.d/kubernets.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# 安装工具
yum install -y kubele t kubeadm kubectl --disableexcludes=kubernetes
# 启动kubelet
systemctl enable kubelet && systemctl start kubelet
```

## 5、预先下载镜像（科学上网的同学请跳过）

kubeadm方式构建的服务都是通过容器的方式运行的，而镜像都会从google的仓库中拉取，非科学上网的同学会有镜像下载的问题。

所以，先从国内已经存在的仓库中下载，然后再tag成kubeadm中显示的镜像。

### 5.1、下载国内镜像（仅k8s-master节点）

- 编写下载镜像的脚本

```bash
vim download-k8s-image.sh
```

```bash
#!/bin/bash
images=(
    kube-apiserver-amd64:v1.23.5          
    kube-controller-manager-amd64:v1.23.5 
    kube-scheduler-amd64:v1.23.5          
    kube-proxy-amd64:v1.23.5              
    pause-amd64:3.3                       
    etcd-amd64:3.4.9                      
    coredns:1.9.1         
    kubernetes-dashboard-amd64:v1.8.3
)
echo "=====开始下载镜像====="
for imageName in ${image[@]}; do
	docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
docker pull registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-node:v3.1.3
docker pull registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-cni:v3.1.3
docker pull registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-typha:v0.7.4

echo "=====开始打标签====="
for imageName in ${image[@]}; do
	docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
done
docker tag registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-node:v3.1.3 quay.io/calico/node:v3.1.3
docker tag registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-cni:v3.1.3 quay.io/calico/cni:v3.1.3
docker tag registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-typha:v0.7.4 quay.io/calico/typha:v0.7.4

echo "=====移除非k8s标签====="
for imageName in ${image[@]}; do
	docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
done
docker rmi registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-node:v3.1.3
docker rmi registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-cni:v3.1.3
docker rmi registry.cn-hangzhou.aliyuncs.com/liuyi01/calico-typha:v0.7.4
```

- 给脚本添加可执行权限

```bash
chmod u+x download-k8s-image.sh
```

- 执行脚本

```bash
./download-k8s-image.sh
```

- 删除脚本

```bash
rm download-k8s-image.sh
```

# 三、高可用集群部署

## 1、部署keepalived - 保证apiserver高可用（任选两个master几点）

由于目前是3节点集群，只有1个master节点，并不是高可用的，忽略！

## 2、部署第一个主节点

- 准备配置文件

```bash
# 导出配置文件
# kubeadm config print init-defaults --kubeconfig ClusterConfiguration > kubeadm.yml
vim kubeadm-config.yaml
```

```yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: v1.23.5
controlPlaneEndpoint: "192.168.200.116:6443"
networking:
    # This CIDR is a Calico default. Substitute or remove for your CNI provider.
    podSubnet: "172.22.0.0/16"
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers
```

- 执行

```bash
# ssh到第一个主节点，执行kubeadm初始化系统（注意保存最后打印的加入集群的命令）
kubeadm init --config=kubeadm-config.yaml --experimental-upload-certs
```





# 四、集群可用性测试



# 五、部署dashboard



# 六、在kubernetes上部署我们的微服务































































































































































