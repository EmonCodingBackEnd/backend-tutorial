# Kubernetesʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# һ��Kubernetes��������



![image-20220328213313664](images/image-20220328213313664.png)



![image-20220328213551170](images/image-20220328213551170.png)



![image-20220328213835819](images/image-20220328213835819.png)

![image-20220328214019324](images/image-20220328214019324.png)

![image-20220328214430562](images/image-20220328214430562.png)



![image-20220328220806300](images/image-20220328220806300.png)

![image-20220328220425586](images/image-20220328220425586.png)

# �����K8S��Ⱥ

## 0����װ��������

����װ׼����==>����װ�������桿==>�����ذ�װ���ߡ�node�����==>����������������ء�==>����ʼ��master��==>����װ��Ⱥ���硿==>������work�ڵ㡿==>�����������л�����==>����װDashboard��

# һ��ʵ��׼������

## 1���������滮

| ������ | ϵͳ���� | IP1-��ͥ      | IP2-��˾   | �ڴ� | �������� |
| ------ | -------- | ------------- | ---------- | ---- | -------- |
| emon   | CentOS7  | 192.168.1.116 | 10.0.0.116 | >=2G | master   |
| emon2  | CentOS7  | 192.168.1.117 | 10.0.0.117 | >=2G | worker   |
| emon3  | CentOS7  | 192.168.1.118 | 10.0.0.118 | >=2G | worker   |

## 2��ϵͳ���ã����нڵ㣩

˵��������������rootȨ����ִ�У��������root�û�����������Ȩ�ޣ�```sudo -i```

### 2.1��������

����������ÿ���ڵ㶼��һ����

```bash
# �鿴������
hostname
# ������������ע���޸�Ϊ�����������
hostnamectl set-hostname emon
```

### 2.2������DNS

����host��ʹ�����нڵ�֮�����ͨ��hostname������ʡ�

```bash
vim /etc/hosts
```

```bash
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```

### 2.3��SSH���ܵ�¼

ע�⣺������root�û���

[SSH���ܵ�¼](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/BigData/BigDataInAction.md#522%E5%89%8D%E7%BD%AE%E5%AE%89%E8%A3%85)

### 2.4����װ������

```bash
# ����yum
yum update
# ��װ������
yum install -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp
```

### 2.5���رշ���ǽ������iptables���ر�swap���ر�selinux��dnsmasq

```bash
# �رշ���ǽ
systemctl stop firewalld && sudo systemctl disable firewalld
# ����iptables
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT
# �ر�swap
swapoff -a
# ȥ��swap��������
sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab
# �ر�selinux
setenforce 0
# ��ֹ�����ָ�
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config
# �ر�dnsmasq��������ܵ���docker�����޷����������������û�и�������Ԫ�����Ժ��ԣ�
systemctl stop dnsmasq && systemctl disable dnsmasq
```

### 2.6��ϵͳ��������

```bash
# ���������ļ�
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF
# ��Ч�ļ�
sysctl -p /etc/sysctl.d/kubernetes.conf
```

> ���ִ��sysctl -p����sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: û���Ǹ��ļ���Ŀ¼
>
> ����취��
>
> ����ģ�飺
>
> modprobe br_netfilter
>
> ��Ч�ļ���
>
> sysctl -p /etc/sysctl.d/kubernetes.conf
>
> �Ƴ�ģ�飺
>
> modprobe -r br_netfilter

## 3����װ��������docker�����нڵ㣩

- Docker��װ

[Docker��װ](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Docker/DockerInAction.md#%E4%B8%80docker%E7%9A%84%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE)

- ��������ip�����ݰ�ת��

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# ��������ExecStart=XXX�������һ�У��������£���k8s��������Ҫ��
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
```

- ����˽�����洢λ�á�������

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# ����������б�Ҫ������ExecStart����׷��һ��˽����ַ�����á����û��httpЭ��ľ���˽�������������á�
EnvironmentFile=-/etc/docker/daemon.json
```

���ļ� `/etc/docker/daemon.json` ׷�� `insecure-registries`���ݣ�

```bash
# ����docker�洢·�����Ǳ���
mkdir /usr/local/lib/docker
# ����docker����
vim /etc/docker/daemon.json
```

```bash
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "graph": "/usr/local/lib/docker",
  "insecure-registries": ["emon:5080"]
}
```

- ��������

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
[emon@emon ~]$ sudo systemctl restart docker
```



## 4����װ��Ҫ���ߣ����нڵ㣩

### 4.1������˵��

- kubeadm������Ⱥ�õ�����
- kubelet���ڼ�Ⱥ��ÿ̨�����϶�Ҫ���е�������������pod����������������
- kubectl����Ⱥ������

### 4.2����װ��������ѧ������

```bash
# ����yumԴ
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
# ��װ����
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
# ����kubelet
systemctl enable kubelet && systemctl start kubelet
```

### 4.2����װ��������ͨ������

���ܿ�ѧ������Ҫ��yumԴ�ĳɰ����Ƶľ���

```bash
# ����yumԴ
cat <<EOF > /etc/yum.repos.d/kubernets.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# ��װ����
yum install -y kubele t kubeadm kubectl --disableexcludes=kubernetes
# ����kubelet
systemctl enable kubelet && systemctl start kubelet
```



## 5��׼�������ļ�������ڵ㣩

### 5.1�����������ļ�



## 6��Ԥ�����ؾ��񣨿�ѧ������ͬѧ��������

kubeadm��ʽ�����ķ�����ͨ�������ķ�ʽ���еģ������񶼻��google�Ĳֿ�����ȡ���ǿ�ѧ������ͬѧ���о������ص����⡣





# �����߿��ü�Ⱥ����



# �ġ���Ⱥ�����Բ���



# �塢����dashboard



# ������kubernetes�ϲ������ǵ�΢����































































































































































