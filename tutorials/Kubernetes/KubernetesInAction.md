# Kubernetesʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# һ����������ʱ

## 1����װContainerd

1. ����

���ص�ַ��https://github.com/containerd/containerd/releases

```bash
[root@emon ~]# wget -cP /usr/local/src/ https://github.com/containerd/containerd/releases/download/v1.6.2/cri-containerd-cni-1.6.2-linux-arm64.tar.gz
```



# ����ʹ��Kubespray����Kubernetes������Ⱥ

## 1���������滮

| ������ | ϵͳ����  | IP��ַ          | �ڴ� | �������� |
| ------ | --------- | --------------- | ---- | -------- |
| emon   | CentOS7.7 | 192.168.200.116 | >=2G | master   |
| emon2  | CentOS7.7 | 192.168.200.117 | >=2G | worker   |
| emon3  | CentOS7.7 | 192.168.200.118 | >=2G | worker   |

## 2��ϵͳ���ã����нڵ㣩

> ע�⣺����������rootȨ����ִ�У��л���root�û���������Ȩ�ޣ�```sudo -i```

### 2.1��������

����������ÿ���ڵ㶼��һ�������������淶������+��ĸ+�л�����ϣ���Ҫ�������������ַ�����

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
192.168.200.116 emon
192.168.200.117 emon2
192.168.200.118 emon3
```

### 2.3����װ������

```bash
# ����yum
yum update
# ��װ������
yum install -y conntrack ipvsadm ipset jq sysstat curl iptables libseccomp
```

### 2.4���رշ���ǽ������iptables���ر�swap���ر�selinux��dnsmasq

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

### 2.5��ϵͳ��������

```bash
# ���������ļ�
cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_nonlocal_bind=1
net.ipv4.ip_forward=1
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
EOF
# ��Ч�ļ�
sysctl -p /etc/sysctl.d/kubernetes.conf
```

> ���ִ��sysctl -p����
>
> > sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: û���Ǹ��ļ���Ŀ¼
> >
> > sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: û���Ǹ��ļ���Ŀ¼
>
> ��ʱ����������������
>
> > modprobe br_netfilter
>
> ���÷�������������Ч��
>
> > cat > /etc/rc.sysinit << EOF
> > #!/bin/bash
> > for file in /etc/sysconfig/modules/*.modules ; do
> > [ -x $file ] && $file
> > done
> > EOF
> > cat > /etc/sysconfig/modules/br_netfilter.modules << EOF
> > modprobe br_netfilter
> > EOF
> > chmod 755 /etc/sysconfig/modules/br_netfilter.modules
> > lsmod |grep br_netfilter

### 2.6���Ƴ�docker������������ѡ��

```bash
yum remove -y docker*
rm -f /etc/docker/daemon.json
rm -rf /var/lib/docker/
```

## 3��ʹ��kubespray����Ⱥ

�ⲿ��ֻ��Ҫ��һ�� **����** �ڵ�ִ�У������Ǽ�Ⱥ�е�һ���ڵ㣬Ҳ�����Ǽ�Ⱥ֮��Ľڵ㡣�������������Լ��ıʼǱ����ԡ���������ʹ�ø��ձ�ļ�Ⱥ�е�����һ��linux�ڵ㡣

### 3.1��SSH���ܵ�¼

ע�⣺������root�û���

```bash
# �����Ƿ��Ѿ�����rsa��Կ
$ cat ~/.ssh/id_rsa.pub

# ��������ھʹ���һ���µ�
$ ssh-keygen -t rsa

# ��id_rsa.pub�ļ�����copy��������������Ȩ�ļ���
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon2
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon3
```

### 3.2������������ء���װ

```bash
# ��װ�����������һ���μ�python���밲װ����װ���Դ�pip
# yum install -y epel-release python36 python36-pip git

# ����kubesprayԴ��
wget -cP /usr/local/src/ https://github.com/kubernetes-sigs/kubespray/archive/refs/tags/v2.18.1.tar.gz
mv /usr/local/src/v2.18.1.tar.gz /usr/local/src/kubespray-v2.18.1.tar.gz
# ��ѹ��
tar -zxvf /usr/local/src/kubespray-v2.18.1.tar.gz -C . && cd kubespray-2.18.1
# ��װrequirements
cat requirements.txt
pip3 install -r requirements.txt

## ���install������������ȳ�������pip
## $ pip3 install --upgrade pip
```

### 3.3����������

��Ŀ����һ��Ŀ¼�Ǽ�Ⱥ�Ļ������ã�ʾ��������Ŀ¼inventory/sample�У����Ǹ���һ�ݳ�����Ϊ�Լ���Ⱥ�����á�

```bash
# copyһ��demo���ã�׼���Զ���
cp -rpf inventory/sample inventory/mycluster
```

����kubespray������׼����py�ű�������ֱ�Ӹ��ݻ��������Զ����������ļ���������������ֻ��Ҫ�趨�û��������Ϳ�������

```bash
# ʹ����ʵ��hostname��������Զ������hostname�ĳ�node1/node2...����Ŷ��
export USE_REAL_HOSTNAME=true
# ָ�������ļ�λ��
export CONFIG_FILE=inventory/mycluster/hosts.yaml
# ����ip�б���ķ���������ip��ַ�б�3̨�����ϣ�ǰ��̨Ĭ��Ϊmaster�ڵ㣩
declare -a IPS=(192.168.200.116 192.168.200.117 192.168.200.118)
# ���������ļ�
python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

### 3.4�����Ի�����

�����ļ������ɺ��ˣ���Ȼ����ֱ���ã�����������ȫ�����ҵĸ��Ի����󣬱�����docker����containerd��docker�Ĺ���Ŀ¼�Ƿ���Ĭ�ϵ�/var/lib/docker���ȵȡ���ȻĬ�ϵ����kubespray���ᵽgoogle�Ĺٷ��ֿ����ؾ��񡢶������ļ����������Ҫ��ķ����������������������������Ҳ��Ҫ�޸�һЩ���á�

```bash
# ���ƻ������ļ�
# 1. �ڵ���֯���ã�������Ե���ÿ���ڵ�Ľ�ɫ��
vim inventory/mycluster/hosts.yaml
# 2. containerd���ã��̳�ʹ��containerd��Ϊ�������棩
vim inventory/mycluster/group_vars/all/containerd.yml
# 3. ȫ�����ã�������������http(s)����ʵ���������ʣ�
vim inventory/mycluster/group_vars/all/all.yml
# 4. k8s��Ⱥ���ã�����������������ʱ��svc���Ρ�pod���εȣ�
vim inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
# 5. �޸�etcd��������Ϊhost��Ĭ����docker��
vim inventory/mycluster/group_vars/etcd.yml
# 6. ���������ingress��dashboard�ȣ�
vim inventory/mycluster/group_vars/k8s_cluster/addons.yml
```

- `vim inventory/mycluster/group_vars/all/all.yml`

```bash
# [����]
http_proxy: "http://192.168.200.116:8118"
# [����]
https_proxy: "http://192.168.1200.116:8118"
```

- `vim inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml`

```yaml
# [�޸�]
kube_service_addresses: 10.200.0.0/16
# [�޸�]
kube_pods_subnet: 10.233.0.0/16
# [����]
container_manager: containerd
```

- `vim inventory/mycluster/group_vars/k8s_cluster/addons.yml`

```yaml
# [����]
dashboard_enabled: true
# [�޸�]
ingress_nginx_enabled: true
```

### 3.5��һ������

�����ļ����������˺󣬾Ϳ��Կ�ʼһ��������������������̲��������ǳ�����

- һ������

```bash
# -vvvv���ӡ����ϸ����־��Ϣ�����鿪��
ansible-playbook -i inventory/mycluster/hosts.yaml  -b cluster.yml -vvvv
```

# ����kubernetes-the-hard-way

> ע�⣺����������rootȨ����ִ�У��л���root�û���������Ȩ�ޣ�```sudo -i```

## ��Ҫ����

- ѧϰ: ����github֪����Ŀkubernetes-the-hard-way�����̣�ȫ���ֶ����������˽⼯Ⱥ�������
- �������߿���: ��kubernetes-the-hard-way�����������˸�������ĸ߿��÷���������������ȺҪ��
- 99������֤�飬����Ϊ֤����ڷ���
- ������ansible�ȵ���������
- �߿��ò�����haproxy��keepalived�����ñ��ش���ķ�ʽ��������

## �������

- �����������ѧϰkubernetes
- �����ϲ�������Ƶ���ά��ʽ
- ��������ڲ�������������kubernetes

## �����ĵ�

## 1����������׼��

### 1.1���������滮

| ������ | ϵͳ����  | IP��ַ          | �ڴ� | ��������       |
| ------ | --------- | --------------- | ---- | -------------- |
| emon   | CentOS7.7 | 192.168.200.116 | >=2G | master         |
| emon2  | CentOS7.7 | 192.168.200.117 | >=2G | master��worker |
| emon3  | CentOS7.7 | 192.168.200.118 | >=2G | worker         |

### 1.2��ϵͳ���ã����нڵ㣩

#### 1.2.1��������

����������ÿ���ڵ㶼��һ�������������淶������+��ĸ+�л�����ϣ���Ҫ�������������ַ�����

```bash
# �鿴������
$ hostname
# ������������ע���޸�Ϊ�����������
$ hostnamectl set-hostname emon
```

#### 1.2.2������DNS

����host��ʹ�����нڵ�֮�����ͨ��hostname������ʡ�

```bash
$ vim /etc/hosts
```

```bash
192.168.200.116 emon
192.168.200.117 emon2
192.168.200.118 emon3
```

#### 1.2.3����װ������

```bash
# ����yum
$ yum update -y
# ��װ������
$ yum install -y socat conntrack ipvsadm ipset jq sysstat curl iptables libseccomp yum-utils
```

#### 1.2.4���رշ���ǽ������iptables���ر�swap���ر�selinux��dnsmasq

```bash
# �رշ���ǽ
$ systemctl stop firewalld && systemctl disable firewalld

# ����iptables����
$ iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat && iptables -P FORWARD ACCEPT

# �ر�swap
$ swapoff -a
# ȥ��swap��������
$ sed -i '/swap/s/^\(.*\)$/#\1/g' /etc/fstab

# �ر�selinux
$ setenforce 0
# ��ֹ�����ָ�
$ sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# �ر�dnsmasq��������ܵ���docker�����޷����������������û�и�������Ԫ�����Ժ��ԣ�
$ systemctl stop dnsmasq && systemctl disable dnsmasq
```

#### 1.2.5��ϵͳ��������

```bash
# ���������ļ�
$ cat > /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
vm.swappiness = 0
vm.overcommit_memory = 1
EOF
# ��Ч�ļ�
$ sysctl -p /etc/sysctl.d/kubernetes.conf
```

> ���ִ��sysctl -p����
>
> > sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-ip6tables: û���Ǹ��ļ���Ŀ¼
> >
> > sysctl: cannot stat /proc/sys/net/bridge/bridge-nf-call-iptables: û���Ǹ��ļ���Ŀ¼
>
> ��ʱ����������������
>
> > modprobe br_netfilter
>
> ���÷�������������Ч��
>
> > cat > /etc/rc.sysinit << EOF
> > #!/bin/bash
> > for file in /etc/sysconfig/modules/*.modules ; do
> > [ -x $file ] && $file
> > done
> > EOF
> > cat > /etc/sysconfig/modules/br_netfilter.modules << EOF
> > modprobe br_netfilter
> > EOF
> > chmod 755 /etc/sysconfig/modules/br_netfilter.modules
> > lsmod |grep br_netfilter

#### 1.2.6������SSH���ܵ�¼������ת�ڵ㣩

Ϊ�˷����ļ���copy����ѡ��һ����ת�ڵ㣨���һ���ڵ㣬�����Ǽ�Ⱥ�е�Ҳ�����ǷǼ�Ⱥ�еģ������úø��������нڵ�����ܵ�¼������ѡ��emon�ڵ㣺

```bash
# �����Ƿ��Ѿ�����rsa��Կ
$ cat ~/.ssh/id_rsa.pub

# ��������ھʹ���һ���µ�
$ ssh-keygen -t rsa

# ��id_rsa.pub�ļ�����copy��������������Ȩ�ļ���
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon2
$ ssh-copy-id -i ~/.ssh/id_rsa.pub emon3
```

#### 1.2.7���Ƴ�docker������������ѡ��

```bash
$ yum remove -y docker*
$ rm -f /etc/docker/daemon.json
$ rm -rf /var/lib/docker/
```

### 1.3��׼��k8s���������master�ڵ�emon��

#### 1.3.0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

#### 1.3.1�����������

������һ���ڵ����غ�ѹ�����󣬸��Ƶ����нڵ㼴��

master�ڵ������kube-apiserver��kube-controller-manager��kube-scheduler��kubectl

worker�ڵ������kubelet��kube-proxy

```bash
# �趨�汾��
$ export VERSION=v1.20.2

# ����master�ڵ����
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kube-apiserver
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kube-controller-manager
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kube-scheduler
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubectl

# ����worker�ڵ����
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kube-proxy
$ wget https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/linux/amd64/kubelet

# =================================================================================================
# ����etcd���
$ export VERSION=v3.4.10
$ wget https://github.com/etcd-io/etcd/releases/download/${VERSION}/etcd-${VERSION}-linux-amd64.tar.gz
$ tar -zxvf etcd-${VERSION}-linux-amd64.tar.gz -C .
$ mv etcd-${VERSION}-linux-amd64/etcd* .
$ rm -rf etcd-${VERSION}-linux-amd64

# =================================================================================================
# ͳһ�޸��ļ�Ȩ��Ϊ��ִ��
$ chmod +x kube*

# ����
$ wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64
$ wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64

# �޸�Ϊ��ִ��Ȩ��
$ chmod +x cfssl_1.6.1_linux_amd64 cfssljson_1.6.1_linux_amd64

# =================================================================================================
# �趨containerd�İ汾��
$ VERSION=1.4.3
# ����ѹ����
$ wget https://github.com/containerd/containerd/releases/download/v${VERSION}/cri-containerd-cni-${VERSION}-linux-amd64.tar.gz
```

#### 1.3.2��������ַ�

������غ󣬷ַ��ļ�����ÿ���ڵ���Ҫ���ļ�scp��ȥ

```bash
# ��master�������ַ���master�ڵ�
$ MASTERS=(emon emon2)
for instance in ${MASTERS[@]}; do
  scp kube-apiserver kube-controller-manager kube-scheduler kubectl root@${instance}:/usr/local/bin/
done

# ��worker�ȹ�����ַ���worker�ڵ�
$ WORKERS=(emon2 emon3)
for instance in ${WORKERS[@]}; do
  scp kubelet kube-proxy root@${instance}:/usr/local/bin/
done

# ��etcd����ַ���etcd�ڵ�
$ ETCDS=(emon emon2 emon3)
for instance in ${ETCDS[@]}; do
  scp etcd etcdctl etcdutl root@${instance}:/usr/local/bin/
done
```



## 2������֤�飨����ת�ڵ㣩

���²���������`/root/k8s_soft/k8s_v1.20.2`Ŀ¼ִ�С�

### 2.0����װcfssl

- ��װcfssl

cfssl�Ƿǳ����õ�CA���ߣ���������������֤�����Կ�ļ� ��װ���̱Ƚϼ򵥣����£�

```bash
# �����ִ��Ŀ¼
$ cp cfssl_1.6.1_linux_amd64 /usr/local/bin/cfssl
$ cp cfssljson_1.6.1_linux_amd64 /usr/local/bin/cfssljson

# ��֤
$ cfssl version
# ������������
Version: 1.6.1
Runtime: go1.12.12
```

### 2.1����֤��

��֤���Ǽ�Ⱥ���нڵ㹲��ģ�ֻ��Ҫ����һ�� CA ֤�飬��������������֤�鶼����ǩ����
������ڵ㣨�������ܵ�¼�������ڵ㣩����һ��������֤��Ŀ¼���磺`mkdir pki && cd pki`

#### ��֤�������ļ�

```json
$ cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "876000h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "876000h"
      }
    }
  }
}
EOF

$ cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
EOF
```

#### ����֤���˽Կ

```bash
# ����֤���˽Կ
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
# ������ɺ���������ļ�������������Ҫ�ľ���ca-key.pem��ca.pem��һ����Կ��һ��֤�飩
$ ls ca*
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```

### 2.2��admin�ͻ���֤��

#### admin�ͻ���֤�������ļ�

```bash
$ cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "system:masters",
      "OU": "seven"
    }
  ]
}
EOF
```

#### ����admin�ͻ���֤���˽Կ

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin

# �鿴
$ ls admin*
admin.csr  admin-csr.json  admin-key.pem  admin.pem
```

### 2.3��kubelet�ͻ���֤��

Kubernetesʹ��һ�ֳ�ΪNode Authorizer��ר����Ȩģʽ����ȨKubelets������API���� Kubeletʹ�ý����ʶΪsystem:nodes���е�ƾ�ݣ����û���Ϊsystem��node:nodeName��������͸�ÿ�������ڵ�����֤�顣

#### ����kubelet�ͻ���֤���˽Կ

```bash
# �������worker�ڵ��б�
$ WORKERS=(emon2 emon3)
$ WORKER_IPS=(192.168.200.117 192.168.200.118)
# ��������worker�ڵ��֤������
$ for ((i=0;i<${#WORKERS[@]};i++)); do
cat > ${WORKERS[$i]}-csr.json <<EOF
{
  "CN": "system:node:${WORKERS[$i]}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "L": "Beijing",
      "O": "system:nodes",
      "OU": "seven",
      "ST": "Beijing"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${WORKERS[$i]},${WORKER_IPS[$i]} \
  -profile=kubernetes \
  ${WORKERS[$i]}-csr.json | cfssljson -bare ${WORKERS[$i]}
done

# �鿴
$ ls emon*
emon2.csr  emon2-csr.json  emon2-key.pem  emon2.pem  emon3.csr  emon3-csr.json  emon3-key.pem  emon3.pem
```

### 2.4��kube-controller-manager�ͻ���֤��

#### kube-controller-manager�ͻ���֤�������ļ�

```bash
$ cat > kube-controller-manager-csr.json <<EOF
{
    "CN": "system:kube-controller-manager",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "BeiJing",
        "L": "BeiJing",
        "O": "system:kube-controller-manager",
        "OU": "seven"
      }
    ]
}
EOF
```

#### ����kube-controller-manager�ͻ���֤��

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
  
# �鿴
$ ls -1 kube-controller-manager*
kube-controller-manager
kube-controller-manager.csr
kube-controller-manager-csr.json
kube-controller-manager-key.pem
kube-controller-manager.pem
```

### 2.5��kube-proxy�ͻ���֤��

#### kube-proxy�ͻ���֤�������ļ�

```bash
$ cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "seven"
    }
  ]
}
EOF
```

#### ����kube-proxy�ͻ���֤��

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
# �鿴  
$ ls -1 kube-proxy*
kube-proxy
kube-proxy.csr
kube-proxy-csr.json
kube-proxy-key.pem
kube-proxy.pem
```

### 2.6��kube-scheduler�ͻ���֤��

#### kube-scheduler�ͻ���֤�������ļ�

```bash
$ cat > kube-scheduler-csr.json <<EOF
{
    "CN": "system:kube-scheduler",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
      {
        "C": "CN",
        "ST": "BeiJing",
        "L": "BeiJing",
        "O": "system:kube-scheduler",
        "OU": "seven"
      }
    ]
}
EOF
```

#### ����kube-scheduler�ͻ���֤��

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
# �鿴
ls -1 kube-scheduler*
kube-scheduler
kube-scheduler.csr
kube-scheduler-csr.json
kube-scheduler-key.pem
kube-scheduler.pem
```

### 2.7��kube-apiserver�����֤��

#### kube-apiserver�����֤�������ļ�

```bash
$ cat > kubernetes-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "seven"
    }
  ]
}
EOF
```

#### ����kube-apiserver�����֤��

�����֤����ͻ������в�ͬ���ͻ�����Ҫͨ��һ�����ֻ���һ��ipȥ���ʷ���ˣ�����֤�����Ҫ�����ͻ��������ʵ����ֻ�ip�����Կͻ�����֤��

```bash
# apiserver��service ip��ַ��һ����svc���εĵ�һ��ip��
$ KUBERNETES_SVC_IP=10.233.0.1
# ���е�master����ip�����ŷָ����ƻ������Լ���master����ip�Ա�֧�ֹ���ip���ʣ�����Ȼ118����master����δ��������
$ MASTER_IPS=192.168.200.116,192.168.200.117,192.168.200.118
# ����֤��
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${KUBERNETES_SVC_IP},${MASTER_IPS},127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
# �鿴
$ ls -1 kubernetes*
kubernetes.csr
kubernetes-csr.json
kubernetes-key.pem
kubernetes.pem
```

### 2.8��Service Account֤��

#### �����ļ�

```bash
$ cat > service-account-csr.json <<EOF
{
  "CN": "service-accounts",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "seven"
    }
  ]
}
EOF
```

#### ����֤��

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
# �鿴
$ ls -1 service-account*
service-account.csr
service-account-csr.json
service-account-key.pem
service-account.pem
```

### 2.9��proxy-client֤��

#### �����ļ�

```bash
$ cat > proxy-client-csr.json <<EOF
{
  "CN": "aggregator",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "CN",
      "ST": "BeiJing",
      "L": "BeiJing",
      "O": "k8s",
      "OU": "seven"
    }
  ]
}
EOF
```

#### ����֤��

```bash
$ cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  proxy-client-csr.json | cfssljson -bare proxy-client
# �鿴
$ ls -1 proxy-client*
proxy-client.csr
proxy-client-csr.json
proxy-client-key.pem
proxy-client.pem
```

### 2.10���ַ��ͻ��ˡ������֤��

#### �ַ�worker�ڵ���Ҫ��֤���˽Կ

```bash
$ WORKERS=(emon2 emon3)
for instance in ${WORKERS[@]}; do
  scp ca.pem ${instance}-key.pem ${instance}.pem root@${instance}:~/
done
```

#### �ַ�master�ڵ���Ҫ��֤���˽Կ

> ע�⣺��������ַ���֤�鼴������etcd��֤��Ҳ������k8s���ڵ��֤�顣 ���� MASTER_IPS �б���������� `master` �ڵ��Լ� `etcd` �ڵ㡣���û�а�������etcd�ڵ��֤�飬��Ҫ���¶��壬���ŷָ�

```bash
$ MASTER_IPS=192.168.200.116,192.168.200.117,192.168.200.118
OIFS=$IFS
IFS=','
for instance in ${MASTER_IPS}; do
  scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem proxy-client.pem proxy-client-key.pem root@${instance}:~/
done
IFS=$OIFS
```

## 3��kubernetes���������֤���ã�����ת�ڵ㣩

>  ��ǰλ�ã�emon����

kubernetes����֤�����ļ���Ҳ��kubeconfigs��������kubernetes�Ŀͻ��˶�λkube-apiserver��ͨ��apiserver�İ�ȫ��֤��

����������һ�������ɸ��������kubeconfigs������controller-manager��kubelet��kube-proxy��scheduler���Լ�admin�û���

����������Ҫ����һ�ڡ�����֤�顱��ͬһ��Ŀ¼��ִ�С�

### 3.0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

### 3.1��kubelet

```bash
# ָ�����worker�б�hostname�����ո�ָ�
$ WORKERS="emon2 emon3"
$ for instance in ${WORKERS}; do
  kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done
# �鿴
$ ls -1tr|tail -n 2
emon2.kubeconfig
emon3.kubeconfig
```

### 3.2��kube-proxy

```bash
kubectl config set-cluster kubernetes \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials system:kube-proxy \
   --client-certificate=kube-proxy.pem \
   --client-key=kube-proxy-key.pem \
   --embed-certs=true \
   --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
   --cluster=kubernetes \
   --user=system:kube-proxy \
   --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
# �鿴
$ ls -1tr|tail -n 1
kube-proxy.kubeconfig
```

### 3.3��kube-controller-manager

```bash
kubectl config set-cluster kubernetes \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=kube-controller-manager.pem \
  --client-key=kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
# �鿴
$ ls -1tr|tail -n 1
kube-controller-manager.kubeconfig
```

### 3.4��kube-scheduler

```bash
kubectl config set-cluster kubernetes \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=kube-scheduler.pem \
  --client-key=kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=system:kube-scheduler \
  --kubeconfig=kube-scheduler.kubeconfig

kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
# �鿴
ls -1tr|tail -n 1
kube-scheduler.kubeconfig
```

### 3.5��admin�û�����

Ϊadmin�û�����kubeconfig����

```bash
kubectl config set-cluster kubernetes \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig
# �鿴
$ ls -1tr|tail -n 1
admin.kubeconfig
```

### 3.6���ַ������ļ�

#### 3.6.1����kubelet��kube-proxy��Ҫ��kubeconfig���÷ַ���ÿ��worker�ڵ�

```bash
$ WORKERS="emon2 emon3"
for instance in ${WORKERS}; do
    scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
```

#### 3.6.2����kube-controller-manager��kube-scheduler��Ҫ��kubeconfig���÷ַ���master�ڵ�

```bash
$ MASTERS="emon emon2"
for instance in ${MASTERS}; do
    scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
done
```

## 4������ETCD��Ⱥ�����нڵ㣩

Kubernetes�������״̬�ģ�����etcd�д洢��Ⱥ״̬�� �ڱ�С���У����ǽ����������ڵ��etcdȺ�������������������ʵ�ָ߿����ԺͰ�ȫ��Զ�̷��ʡ�

### 4.0���л�Ŀ¼

```bash
$ cd
```

### 4.1������etcd

- copy��Ҫ��֤���ļ�

```bash
$ mkdir -p /etc/etcd /var/lib/etcd
$ chmod 700 /var/lib/etcd
$ cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
```

- ����etcd.service�ļ�

```bash
$ ETCD_NAME=$(hostname -s)
$ ETCD_IP=192.168.200.116 # IP��ַ�滻Ϊ����ڵ�IP��ַ
# etcd���нڵ��ip��ַ
$ ETCD_NAMES=(emon emon2 emon3)
$ ETCD_IPS=(192.168.200.116 192.168.200.117 192.168.200.118)
$ cat <<EOF > /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${ETCD_IP}:2380 \\
  --listen-peer-urls https://${ETCD_IP}:2380 \\
  --listen-client-urls https://${ETCD_IP}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${ETCD_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${ETCD_NAMES[0]}=https://${ETCD_IPS[0]}:2380,${ETCD_NAMES[1]}=https://${ETCD_IPS[1]}:2380,${ETCD_NAMES[2]}=https://${ETCD_IPS[2]}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 4.2������etcd��Ⱥ

����etcd�ڵ㶼���ú�etcd.service������etcd��Ⱥ

```bash
# ע�⣺����������Ҫ�£����нڵ㶼ִ����������󣬾���ͨ�ˣ�����Ϊ�˵ȴ������ڵ����
$ systemctl daemon-reload && systemctl enable etcd && systemctl restart etcd
```

### 4.3����֤etcd��Ⱥ

```bash
$ ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
# ������������
3bae6ef756268744, started, emon2, https://192.168.200.117:2380, https://192.168.200.117:2379, false
48fd167b46c04497, started, emon3, https://192.168.200.118:2380, https://192.168.200.118:2379, false
7d04ddf76c096e96, started, emon, https://192.168.200.116:2380, https://192.168.200.116:2379, false
```



## 5������kubernetes����ƽ�棨����master�ڵ㣩

�ⲿ�����ǲ���kubernetes�Ŀ���ƽ�棬ÿ������ж���㱣֤�߿��á�ʵ���������������ڵ��ϲ��� API Server��Scheduler �� Controller Manager����Ȼ��Ҳ���԰��ս̳̲��������ڵ�ĸ߿��ã���������һ�µġ�

> ��������������������ÿ��master�ڵ�ģ����ǵ�ʵ������ emon �� emon2

�ԺͰ�ȫ��Զ�̷��ʡ�

### 5.0���л�Ŀ¼

```bash
$ cd
```

### 5.1������API Server

```bash
# ����kubernetes��ҪĿ¼
$ mkdir -p /etc/kubernetes/ssl
# ׼��֤���ļ�
$ cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    proxy-client.pem proxy-client-key.pem \
    /etc/kubernetes/ssl/

# ����kube-apiserver.service
# ��������ip
$ IP=192.168.200.116 # IP��ַ�滻Ϊ����ڵ�IP��ַ
# apiserverʵ����
$ APISERVER_COUNT=2
# etcd�ڵ�
$ ETCD_ENDPOINTS=(192.168.200.116 192.168.200.117 192.168.200.118)
# ���� apiserver service
$ cat <<EOF > /etc/systemd/system/kube-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${IP} \\
  --allow-privileged=true \\
  --apiserver-count=${APISERVER_COUNT} \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
  --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \\
  --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --etcd-servers=https://${ETCD_ENDPOINTS[0]}:2379,https://${ETCD_ENDPOINTS[1]}:2379,https://${ETCD_ENDPOINTS[2]}:2379 \\
  --event-ttl=1h \\
  --kubelet-certificate-authority=/etc/kubernetes/ssl/ca.pem \\
  --kubelet-client-certificate=/etc/kubernetes/ssl/kubernetes.pem \\
  --kubelet-client-key=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --service-account-issuer=api \\
  --service-account-key-file=/etc/kubernetes/ssl/service-account.pem \\
  --service-account-signing-key-file=/etc/kubernetes/ssl/service-account-key.pem \\
  --api-audiences=api,vault,factors \\
  --service-cluster-ip-range=10.233.0.0/16 \\
  --service-node-port-range=30000-32767 \\
  --proxy-client-cert-file=/etc/kubernetes/ssl/proxy-client.pem \\
  --proxy-client-key-file=/etc/kubernetes/ssl/proxy-client-key.pem \\
  --runtime-config=api/all=true \\
  --requestheader-client-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --requestheader-allowed-names=aggregator \\
  --requestheader-extra-headers-prefix=X-Remote-Extra- \\
  --requestheader-group-headers=X-Remote-Group \\
  --requestheader-username-headers=X-Remote-User \\
  --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem \\
  --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```



### 5.2������kube-controller-manager

```bash
# ׼��kubeconfig�����ļ�
$ cp kube-controller-manager.kubeconfig /etc/kubernetes/

# ���� kube-controller-manager.service
$ cat <<EOF > /etc/systemd/system/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem \\
  --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem \\
  --cluster-signing-duration=876000h0m0s \\
  --kubeconfig=/etc/kubernetes/kube-controller-manager.kubeconfig \\
  --leader-elect=true \\
  --root-ca-file=/etc/kubernetes/ssl/ca.pem \\
  --service-account-private-key-file=/etc/kubernetes/ssl/service-account-key.pem \\
  --service-cluster-ip-range=10.233.0.0/16 \\
  --use-service-account-credentials=true \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 5.3������kube-scheduler

```bash
# ׼��kubeconfig�����ļ�
$ cp kube-scheduler.kubeconfig /etc/kubernetes/

# ���� scheduler service �ļ�
$ cat <<EOF > /etc/systemd/system/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --authentication-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --authorization-kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --kubeconfig=/etc/kubernetes/kube-scheduler.kubeconfig \\
  --leader-elect=true \\
  --bind-address=0.0.0.0 \\
  --port=0 \\
  --v=1
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 5.4����������

```bash
$ systemctl daemon-reload && systemctl enable kube-apiserver kube-controller-manager kube-scheduler
$ systemctl restart kube-apiserver kube-controller-manager kube-scheduler
```

### 5.5��������֤

�˿���֤

```bash
# ��������ļ����˿�
$ netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      17094/master        
tcp        0      0 192.168.200.116:2379    0.0.0.0:*               LISTEN      61298/etcd          
tcp        0      0 127.0.0.1:2379          0.0.0.0:*               LISTEN      61298/etcd          
tcp        0      0 192.168.200.116:2380    0.0.0.0:*               LISTEN      61298/etcd          
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      9808/sshd           
tcp6       0      0 ::1:25                  :::*                    LISTEN      17094/master        
tcp6       0      0 :::6443                 :::*                    LISTEN      61426/kube-apiserve 
tcp6       0      0 :::10252                :::*                    LISTEN      61444/kube-controll 
tcp6       0      0 :::10257                :::*                    LISTEN      61444/kube-controll 
tcp6       0      0 :::10259                :::*                    LISTEN      61457/kube-schedule 
tcp6       0      0 :::22                   :::*                    LISTEN      9808/sshd 
```



ϵͳ��־��֤

```bash
# �鿴ϵͳ��־�Ƿ�������Ĵ�����־
$ journalctl -f
```

### 5.6������kubectl��emon���master�ڵ㼴�ɣ�

kubectl����������kubernetes��Ⱥ�Ŀͻ��˹��ߣ�ǰ�������Ѿ����ص������е�master�ڵ㡣��������������������ߣ���������ʹ�á�

```bash
# ����kubectl������Ŀ¼
$ mkdir ~/.kube/
# �ѹ���Ա�������ļ��ƶ���kubectl��Ĭ��Ŀ¼
$ cp ~/admin.kubeconfig ~/.kube/config
# ����
$ kubectl get nodes
# ��������������Ŀǰ��������
No resources found
```

��ִ�� kubectl exec��run��logs ������ʱ��apiserver ��ת���� kubelet�����ﶨ�� RBAC ������Ȩ apiserver ���� kubelet API��

```bash
$ kubectl create clusterrolebinding kube-apiserver:kubelet-apis --clusterrole=system:kubelet-api-admin --user kubernetes
```



## 6������kubernetes�����ڵ㣨����worker�ڵ㣩

�ⲿ�����ǲ���kubernetes�Ĺ����ڵ㡣ʵ�������������������ڵ㣬һ���Ƕ����Ĺ����ڵ㣬һ���Ǹ�master��һ��Ľڵ㡣
��ÿ���ڵ������ǻᲿ��kubelet��kube-proxy��container runtime��cni��nginx-proxy

### 6.0���л�Ŀ¼������ת�ڵ㣩

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

### 6.1��Container Runtime - Containerd

#### 6.1.1����������أ�����ת�ڵ㣩

```bash
# �趨containerd�İ汾�ţ��ַ�������work�ڵ�
$ VERSION=1.4.3
WORKERS="emon2 emon3"
for instance in ${WORKERS}; do
    scp cri-containerd-cni-${VERSION}-linux-amd64.tar.gz ${instance}:~/
done
```

#### 6.1.2������ѹ���ļ�

���غ���ļ���һ��tar.gz����һ��allinone�İ���������runc��circtl��ctr��containerd����������ʱ�Լ�cni��ص��ļ�����ѹ����һ��������Ŀ¼��

```bash
$ VERSION=1.4.3
# ������ѹĿ¼
$ mkdir containerd
# ��ѹ��
$ tar -zxvf cri-containerd-cni-${VERSION}-linux-amd64.tar.gz -C containerd
# ������Ҫ���ļ�
$ cp containerd/etc/crictl.yaml /etc/
$ cp containerd/etc/systemd/system/containerd.service /etc/systemd/system/
$ cp -r containerd/usr /
```

#### 6.1.3��containerd�����ļ�

```bash
$ mkdir -p /etc/containerd
# Ĭ���������������ļ�
$ containerd config default > /etc/containerd/config.toml

# ���ƻ����ã���ѡ��
# ��������Ŀ¼
$ mkdir /usr/local/lib/containerd
$ vi /etc/containerd/config.toml
```

�޸�Ĭ�Ͼ���Ŀ¼���Ǳ��룩�����ԡ�

```bash
# ����config.toml����
root = "/var/lib/containerd" ==> root = "/usr/local/lib/containerd"
```

#### 6.1.4������containerd

```bash
$ systemctl enable containerd && systemctl restart containerd
# ���״̬
$ systemctl status containerd
```

#### 6.1.5�����þ������������δ��֤��

https://help.aliyun.com/document_detail/60750.html

```bash
# ����Դ�ļ� 
$ cp /etc/containerd/config.toml /etc/containerd/config.toml.bak
# �޸������ļ������� registry����������
$ vim /etc/containerd/config.toml
```

```toml
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          #endpoint = ["https://registry-1.docker.io"]
          endpoint = ["https://pyk8pf3k.mirror.aliyuncs.com"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.66.4"]
          endpoint = ["https://192.168.66.4:443"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
   		[plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".tls]
          insecure_skip_verify = true
       	[plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.66.4".auth]
          username = "admin"
          password = "Harbor12345"
```

- ����k8sʹ������Ч

```bash
systemctl restart containerd
```



### 6.2������kubelet

#### ׼��kubelet����

```bash
$ mkdir -p /etc/kubernetes/ssl/
$ cp ${HOSTNAME}-key.pem ${HOSTNAME}.pem ca.pem ca-key.pem /etc/kubernetes/ssl/
$ cp ${HOSTNAME}.kubeconfig /etc/kubernetes/kubeconfig
$ IP=192.168.200.117 # IP��ַ�滻Ϊ����ڵ�IP��ַ
# д��kubelet�����ļ�
$ cat <<EOF > /etc/kubernetes/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/etc/kubernetes/ssl/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "169.254.25.10"
podCIDR: "10.200.0.0/16"
address: ${IP}
readOnlyPort: 0
staticPodPath: /etc/kubernetes/manifests
healthzPort: 10248
healthzBindAddress: 127.0.0.1
kubeletCgroups: /systemd/system.slice
resolvConf: "/etc/resolv.conf"
runtimeRequestTimeout: "15m"
kubeReserved:
  cpu: 200m
  memory: 512M
tlsCertFile: "/etc/kubernetes/ssl/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/etc/kubernetes/ssl/${HOSTNAME}-key.pem"
EOF
```

#### ����kubelet����

```bash
$ cat <<EOF > /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/etc/kubernetes/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/etc/kubernetes/kubeconfig \\
  --network-plugin=cni \\
  --node-ip=${IP} \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```



### 6.3������nginx-proxy������û��apiserver�Ľڵ㲿������emon3��

nginx-proxy��һ������worker�ڵ����apiserver��һ��������apiserverһ�����ŵĸ߿��÷�������ʹ��kubelet��staticpod��ʽ��������ÿ���ڵ㶼���Ծ���ķ��ʵ�ÿ��apiserver�������ŵ������ͨ������ip����apiserver�ķ�ʽ��

> Tips: nginx-proxy ֻ��Ҫ��û�� apiserver �Ľڵ㲿��Ŷ~

#### 6.3.1��nginx�����ļ�

```bash
$ mkdir -p /etc/nginx
# master ip�б�
$ MASTER_IPS=(192.168.200.116 192.168.200.117)
# ִ��ǰ����copyһ�ݣ����޸ĺ�upstream�� 'server' ��������
$ cat <<EOF > /etc/nginx/nginx.conf
error_log stderr notice;

worker_processes 2;
worker_rlimit_nofile 130048;
worker_shutdown_timeout 10s;

events {
  multi_accept on;
  use epoll;
  worker_connections 16384;
}

stream {
  upstream kube_apiserver {
    least_conn;
    # ����ж��master���������ü���
    server ${MASTER_IPS[0]}:6443;
    server ${MASTER_IPS[1]}:6443;
  }

  server {
    listen        127.0.0.1:6443;
    proxy_pass    kube_apiserver;
    proxy_timeout 10m;
    proxy_connect_timeout 1s;
  }
}

http {
  aio threads;
  aio_write on;
  tcp_nopush on;
  tcp_nodelay on;

  keepalive_timeout 5m;
  keepalive_requests 100;
  reset_timedout_connection on;
  server_tokens off;
  autoindex off;

  server {
    listen 8081;
    location /healthz {
      access_log off;
      return 200;
    }
    location /stub_status {
      stub_status on;
      access_log off;
    }
  }
}
EOF
```

#### 6.3.2��nginx manifest

```bash
# �����⡿�����ļ�����emon2Ҳ��Ҫ������nginx-proxy.yaml����Ҫ
$ mkdir -p /etc/kubernetes/manifests/
$ cat <<EOF > /etc/kubernetes/manifests/nginx-proxy.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-proxy
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
    k8s-app: kube-nginx
spec:
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
  nodeSelector:
    kubernetes.io/os: linux
  priorityClassName: system-node-critical
  containers:
  - name: nginx-proxy
    image: docker.io/library/nginx:1.19
    imagePullPolicy: IfNotPresent
    resources:
      requests:
        cpu: 25m
        memory: 32M
    securityContext:
      privileged: true
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8081
    readinessProbe:
      httpGet:
        path: /healthz
        port: 8081
    volumeMounts:
    - mountPath: /etc/nginx
      name: etc-nginx
      readOnly: true
  volumes:
  - name: etc-nginx
    hostPath:
      path: /etc/nginx
EOF
```



### 6.4������kube-proxy

#### 6.4.1�������ļ�

```bash
$ mv kube-proxy.kubeconfig /etc/kubernetes/
# ���� kube-proxy-config.yaml
$ cat <<EOF > /etc/kubernetes/kube-proxy-config.yaml
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
bindAddress: 0.0.0.0
clientConnection:
  kubeconfig: "/etc/kubernetes/kube-proxy.kubeconfig"
clusterCIDR: "10.200.0.0/16"
mode: ipvs
EOF
```

#### 6.4.2��kube-proxy�����ļ�

```bash
$ cat <<EOF > /etc/systemd/system/kube-proxy.service
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-proxy \\
  --config=/etc/kubernetes/kube-proxy-config.yaml
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```

### 6.5����������

```bash
# �����⡿��emon2����Ҫ������emon3�ڵ�ǳ��Ƽ���pull��nginx����crictl pull docker.io/library/nginx:1.19  ������
$ crictl pull docker.io/library/nginx:1.19

# ��emon2��emon3�ڵ㣬�ǳ��Ƽ���pull��pause������������pause����pull�����μ����棡����
$ crictl pull registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2
$ ctr -n k8s.io i tag  registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2 k8s.gcr.io/pause:3.2

$ systemctl daemon-reload && systemctl enable kubelet kube-proxy
$ systemctl restart kubelet kube-proxy
$ journalctl -f -u kubelet
$ journalctl -f -u kube-proxy

# ��ֹĿǰ�����crictl ps emon3����nginx������emon2��������������
```

> ����˵���������Ǹ��˼�¼�����⣬�����Ż��˾�����ȡ��ǰ��������5��֮�ھ������ˣ�����������2�����⣡�����мǣ�����
>
> 
>
> journalctl -f -u kubelet
>
> ����һ��
>
> emon2�ڵ㱨�� Unable to read config path "/etc/kubernetes/manifests"
>
> ����Ŀ¼���ɣ�mkdir -p /etc/kubernetes/manifests/
>
> ����2��
>
> emon3�ڵ㱨��kubelet.go:2243] node "emon3" not found
>
> ����crictl images ���֣����ھ��� pause:3.2 ��δ�����������ȴ����ɣ�
>
> ����̸֮������
>
> �ֹ����أ�
>
> crictl pull docker.io/library/nginx:1.19
>
> ��ʱ��emon3�ڵ㣬�����Ļ��Ǳ�����Ϣ�����ż����������û���⣬�ȴ��ӽ�10���ӣ��ᷢ�����£�
>
> ```tex
> 4�� 01 17:27:56 emon3 kubelet[60611]: E0401 17:27:56.859842   60611 kubelet.go:2243] node "emon3" not found
> 4�� 01 17:27:56 emon3 kubelet[60611]: E0401 17:27:56.959939   60611 kubelet.go:2243] node "emon3" not found
> 4�� 01 17:27:57 emon3 kubelet[60611]: E0401 17:27:57.060894   60611 kubelet.go:2243] node "emon3" not found
> 4�� 01 17:27:59 emon3 kubelet[60611]: I0401 17:27:59.174140   60611 setters.go:86] Using node IP: "192.168.200.118"
> 4�� 01 17:28:00 emon3 kubelet[60611]: E0401 17:28:00.488025   60611 kubelet.go:2163] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
> 4�� 01 17:28:05 emon3 kubelet[60611]: I0401 17:28:05.318879   60611 kubelet_getters.go:176] "Pod status updated" pod="kube-system/nginx-proxy-emon3" status=Running
> 4�� 01 17:28:05 emon3 kubelet[60611]: E0401 17:28:05.489211   60611 kubelet.go:2163] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
> 4�� 01 17:28:09 emon3 kubelet[60611]: I0401 17:28:09.178972   60611 setters.go:86] Using node IP: "192.168.200.118"
> 4�� 01 17:28:10 emon3 kubelet[60611]: E0401 17:28:10.490192   60611 kubelet.go:2163] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
> 4�� 01 17:28:15 emon3 kubelet[60611]: E0401 17:28:15.491678   60611 kubelet.go:2163] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
> 4�� 01 17:28:19 emon3 kubelet[60611]: I0401 17:28:19.182519   60611 setters.go:86] Using node IP: "192.168.200.118"
> 4�� 01 17:28:20 emon3 kubelet[60611]: E0401 17:28:20.493213   60611 kubelet.go:2163] Container runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:Network plugin returns error: cni plugin not initialized
> ```
>
> OK�ˣ���ͷ������3�飬�������������ˣ������η�����ִ�������`modprobe -r br_netfilter`���������ϵͳ�ˣ���ģ�鶼�������¼��أ����£�
> sysctl -p /etc/sysctl.d/kubernetes.conf ʧ�ܡ�
>
> �ڵ�����ʱ������˸����⡣������һ��ʱ������ʾ node "emon3" not found��˲�����������
>
> �������ˣ��ȼ������¿���Ƶ������ѧϰ���뷨ʱ������ԼĪ10���ӣ�����OK�ˣ�Ȼ��`crictl ps`����������һ��������6443�ӿڱ������ˣ�����
>
> �����ǣ�����
>
> ѧϰ����Ҫϸ�ģ�Ҳ��Ҫ���ģ�����2022��04��01�գ����˽ڿ��֣�����ǰ��3�죬�����ɸ㶨�����⣬��¼�£�����

### 6.6���ֶ����ؾ��񣨷������޷��������������������װ�̳��Ѿ���ǰ���ؾ���

��ÿ�������ڵ�����pause����Ϊ��������������

```bash
$ crictl pull registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2
$ ctr -n k8s.io i tag  registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2 k8s.gcr.io/pause:3.2
```



## 7��������-Calico�������ڵ�emon��

### 7.0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

�ⲿ�����ǲ���kubernetes�������� CNI��

�ĵ���ַ��https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises

### 7.1�������ļ�˵��

�ĵ������������ã�50���½ڵ��50���Ͻڵ㣬���ǵ���Ҫ�������������typha��
���ڵ����Ƚ϶������£�Calico �� Felix�����ͨ�� Typha ֱ�Ӻ� Etcd �������ݽ�������ͨ�� kube-apiserver������kube-apiserver��ѹ������Ҹ����Լ���ʵ�����ѡ�����ء�
���غ���ļ���һ��all-in-one��yaml�ļ�������ֻ��Ҫ�ڴ˻������������޸ļ��ɡ�

```bash
# ����calico.yaml�ļ�
$ curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
```

### 7.2���޸�IP�Զ�����

> ��kubelet�����������д���--node-ip��ʱ����host-networkģʽ������pod��status.hostIP�ֶξͻ��Զ�����kubelet��ָ����ip��ַ��

�޸�ǰ��

```bash
- name: IP
  value: "autodetect"
```

�޸ĺ�

```bash
- name: IP
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
```

### 7.3���޸�CIDR

�޸�ǰ��

```bash
# - name: CALICO_IPV4POOL_CIDR
#   value: "192.168.0.0/16"
```

�޸ĺ��޸ĳ����Լ���value����������10.200.0.0/16��

```bash
- name: CALICO_IPV4POOL_CIDR
  value: "10.200.0.0/16"
```

### 7.4��ʹ֮��Ч

```bash
# ��Ч֮ǰ�鿴
$ kubectl get nodes
NAME    STATUS     ROLES    AGE     VERSION
emon2   NotReady   <none>   5m39s   v1.20.2
emon3   NotReady   <none>   5m35s   v1.20.2
# ʹ֮��Ч
$ kubectl apply -f calico.yaml
# �鿴node
$ kubectl get nodes
NAME    STATUS     ROLES    AGE     VERSION
emon2   NotReady   <none>   4h52m   v1.20.2
emon3   NotReady   <none>   4h44m   v1.20.2
# �鿴pod��Ϣ
$ kubectl get po -n kube-system
NAME                                       READY   STATUS     RESTARTS   AGE
calico-kube-controllers-858c9597c8-lm45b   0/1     Pending    0          42s
calico-node-cnt7b                          0/1     Init:0/3   0          42s
calico-node-l7xgf                          0/1     Init:0/3   0          42s
nginx-proxy-emon3                          1/1     Running    0          4h44m
# ===================================================================================================
# ���������ٴβ鿴
$ kubectl get po -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-858c9597c8-lm45b   1/1     Running   0          3m32s
calico-node-cnt7b                          1/1     Running   0          3m32s
calico-node-l7xgf                          1/1     Running   0          3m32s
nginx-proxy-emon3                          1/1     Running   0          4h47m
# �ٴβ鿴node
$ kubectl get nodes
NAME    STATUS   ROLES    AGE     VERSION
emon2   Ready    <none>   4h56m   v1.20.2
emon3   Ready    <none>   4h48m   v1.20.2
```



## 8��DNS���-CoreDNS�������ڵ�emon��

�ⲿ�����ǲ���kubernetes��DNS��� - CoreDNS��

�����ڵİ汾��dns�����pod��ʽ�������У�Ϊ��Ⱥ�ṩdns�������е�pod��������ͬһ��dns����
��kubernetes 1.18�汾��ʼNodeLocal DnsCache���ܽ���stable״̬��
NodeLocal DNSCacheͨ��daemon-set����ʽ������ÿ�������ڵ㣬��Ϊ�ڵ���pod��dns��������Ӷ�������iptables��DNAT�����connection tracking������������dns�����ܡ�

### 8.0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

### 8.1������CoreDNS

```bash
# ���� coredns �� cluster-ip
$ COREDNS_CLUSTER_IP=10.233.0.10
# ����coredns����all-in-one��addons/coredns.yaml�����ο������ coredns.yaml�ļ�
$ vim coredns.yaml
# �滻cluster-ip
$ sed -i "s/\${COREDNS_CLUSTER_IP}/${COREDNS_CLUSTER_IP}/g" coredns.yaml
# ���� coredns
$ kubectl apply -f coredns.yaml
# �鿴pod
$ kubectl get po -n kube-system
```



### 8.2������NodeLocal DNSCache

```bash
# ���� coredns �� cluster-ip
$ COREDNS_CLUSTER_IP=10.233.0.10
# ����nodelocaldns����all-in-one(addons/nodelocaldns.yaml)���ο������ nodelocaldns.yaml�ļ�
$ vim nodelocaldns.yaml
# �滻cluster-ip
$ sed -i "s/\${COREDNS_CLUSTER_IP}/${COREDNS_CLUSTER_IP}/g" nodelocaldns.yaml
# ���� nodelocaldns
$ kubectl apply -f nodelocaldns.yaml
# �鿴pod
$ kubectl get po -n kube-system
```



### 8.3����֤

```bash
# �鿴pod��Ϣ
$ kubectl get po -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-858c9597c8-vdc7n   1/1     Running   0          6m57s
calico-node-4qz8m                          1/1     Running   0          6m57s
calico-node-q5x6w                          1/1     Running   0          6m57s
coredns-84646c885d-ghjsk                   1/1     Running   0          116s
coredns-84646c885d-plqbz                   1/1     Running   0          116s
nginx-proxy-emon3                          1/1     Running   0          12m
nodelocaldns-72nns                         1/1     Running   0          62s
nodelocaldns-n6fqj                         1/1     Running   0          62s

# ��ʱ��emon2�������������£�
$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID
c48922e60a868       90f9d984ec9a3       4 minutes ago       Running             node-cache          0                   5ed3cb8b8d249
54c7c7c3ad922       67da37a9a360e       5 minutes ago       Running             coredns             0                   33d271c6a6f5b
95f0d92df2c56       7a71aca7b60fc       9 minutes ago       Running             calico-node         0                   75a971d7d731d
# ��ʱ��emon3�������������£�
$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID
af46c12946807       90f9d984ec9a3       4 minutes ago       Running             node-cache                0                   a9de1d50e76d1
4a58b042b9887       67da37a9a360e       5 minutes ago       Running             coredns                   0                   0202b404f9e97
cd668919ab62b       c0c6672a66a59       9 minutes ago       Running             calico-kube-controllers   0                   f1a7cbc5c54c5
28ae265580655       7a71aca7b60fc       9 minutes ago       Running             calico-node               0                   1f0c2fc445512
acb35f522c6d6       f0b8a9a541369       17 minutes ago      Running             nginx-proxy               0                   0c96cb3f33875
```

- ������֤

```bash
# �鿴pod�ֲ�����
$ kubectl get po -n kube-system -o wide
NAME                                       READY   STATUS    RESTARTS   AGE   IP                NODE    NOMINATED NODE   READINESS GATES
calico-kube-controllers-858c9597c8-vdc7n   1/1     Running   0          16m   10.200.161.1      emon3   <none>           <none>
calico-node-4qz8m                          1/1     Running   0          16m   192.168.200.117   emon2   <none>           <none>
calico-node-q5x6w                          1/1     Running   0          16m   192.168.200.118   emon3   <none>           <none>
coredns-84646c885d-ghjsk                   1/1     Running   0          11m   10.200.161.2      emon3   <none>           <none>
coredns-84646c885d-plqbz                   1/1     Running   0          11m   10.200.108.65     emon2   <none>           <none>
nginx-proxy-emon3                          1/1     Running   0          21m   192.168.200.118   emon3   <none>           <none>
nodelocaldns-72nns                         1/1     Running   0          10m   192.168.200.117   emon2   <none>           <none>
nodelocaldns-n6fqj                         1/1     Running   0          10m   192.168.200.118   emon3   <none>           <none>
```





**�ٷ��ĵ���ַ**

**coredns�ٷ��ĵ�**��https://coredns.io/plugins/kubernetes/
**NodeLocal DNSCache**��https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/



**coredns.yaml**

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
      addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        prometheus :9153
        forward . /etc/resolv.conf {
          prefer_udp
        }
        cache 30
        loop
        reload
        loadbalance
    }
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: Reconcile
  name: system:coredns
rules:
  - apiGroups:
      - ""
    resources:
      - endpoints
      - services
      - pods
      - namespaces
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
    addonmanager.kubernetes.io/mode: EnsureExists
  name: system:coredns
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:coredns
subjects:
  - kind: ServiceAccount
    name: coredns
    namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  name: coredns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/name: "coredns"
    addonmanager.kubernetes.io/mode: Reconcile
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: ${COREDNS_CLUSTER_IP}
  ports:
    - name: dns
      port: 53
      protocol: UDP
    - name: dns-tcp
      port: 53
      protocol: TCP
    - name: metrics
      port: 9153
      protocol: TCP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "coredns"
  namespace: kube-system
  labels:
    k8s-app: "kube-dns"
    addonmanager.kubernetes.io/mode: Reconcile
    kubernetes.io/name: "coredns"
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 10%
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    metadata:
      labels:
        k8s-app: kube-dns
      annotations:
        seccomp.security.alpha.kubernetes.io/pod: 'runtime/default'
    spec:
      priorityClassName: system-cluster-critical
      nodeSelector:
        kubernetes.io/os: linux
      serviceAccountName: coredns
      tolerations:
        - key: node-role.kubernetes.io/master
          effect: NoSchedule
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - topologyKey: "kubernetes.io/hostname"
            labelSelector:
              matchLabels:
                k8s-app: kube-dns
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: node-role.kubernetes.io/master
                operator: In
                values:
                - ""
      containers:
      - name: coredns
        image: "docker.io/coredns/coredns:1.6.7"
        imagePullPolicy: IfNotPresent
        resources:
          # TODO: Set memory limits when we've profiled the container for large
          # clusters, then set request = limit to keep this container in
          # guaranteed class. Currently, this container falls into the
          # "burstable" category so the kubelet doesn't backoff from restarting it.
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-conf", "/etc/coredns/Corefile" ]
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9153
          name: metrics
          protocol: TCP
        securityContext:
          allowPrivilegeEscalation: false
          capabilities:
            add:
            - NET_BIND_SERVICE
            drop:
            - all
          readOnlyRootFilesystem: true
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8181
            scheme: HTTP
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 10
      dnsPolicy: Default
      volumes:
        - name: config-volume
          configMap:
            name: coredns
            items:
            - key: Corefile
              path: Corefile
```



**nodelocaldns.yaml**

```bash
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nodelocaldns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists

data:
  Corefile: |
    cluster.local:53 {
        errors
        cache {
            success 9984 30
            denial 9984 5
        }
        reload
        loop
        bind 169.254.25.10
        forward . ${COREDNS_CLUSTER_IP} {
            force_tcp
        }
        prometheus :9253
        health 169.254.25.10:9254
    }
    in-addr.arpa:53 {
        errors
        cache 30
        reload
        loop
        bind 169.254.25.10
        forward . ${COREDNS_CLUSTER_IP} {
            force_tcp
        }
        prometheus :9253
    }
    ip6.arpa:53 {
        errors
        cache 30
        reload
        loop
        bind 169.254.25.10
        forward . ${COREDNS_CLUSTER_IP} {
            force_tcp
        }
        prometheus :9253
    }
    .:53 {
        errors
        cache 30
        reload
        loop
        bind 169.254.25.10
        forward . /etc/resolv.conf
        prometheus :9253
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nodelocaldns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    addonmanager.kubernetes.io/mode: Reconcile
spec:
  selector:
    matchLabels:
      k8s-app: nodelocaldns
  template:
    metadata:
      labels:
        k8s-app: nodelocaldns
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '9253'
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: nodelocaldns
      hostNetwork: true
      dnsPolicy: Default  # Don't use cluster DNS.
      tolerations:
      - effect: NoSchedule
        operator: "Exists"
      - effect: NoExecute
        operator: "Exists"
      containers:
      - name: node-cache
        image: "registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/dns_k8s-dns-node-cache:1.16.0"
        resources:
          limits:
            memory: 170Mi
          requests:
            cpu: 100m
            memory: 70Mi
        args: [ "-localip", "169.254.25.10", "-conf", "/etc/coredns/Corefile", "-upstreamsvc", "coredns" ]
        securityContext:
          privileged: true
        ports:
        - containerPort: 53
          name: dns
          protocol: UDP
        - containerPort: 53
          name: dns-tcp
          protocol: TCP
        - containerPort: 9253
          name: metrics
          protocol: TCP
        livenessProbe:
          httpGet:
            host: 169.254.25.10
            path: /health
            port: 9254
            scheme: HTTP
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 10
        readinessProbe:
          httpGet:
            host: 169.254.25.10
            path: /health
            port: 9254
            scheme: HTTP
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 10
        volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        - name: xtables-lock
          mountPath: /run/xtables.lock
      volumes:
        - name: config-volume
          configMap:
            name: nodelocaldns
            items:
            - key: Corefile
              path: Corefile
        - name: xtables-lock
          hostPath:
            path: /run/xtables.lock
            type: FileOrCreate
      # Minimize downtime during a rolling upgrade or deletion; tell Kubernetes to do a "force
      # deletion": https://kubernetes.io/docs/concepts/workloads/pods/pod/#termination-of-pods.
      terminationGracePeriodSeconds: 0
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 20%
    type: RollingUpdate
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nodelocaldns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: Reconcile
```



## 9����Ⱥð�̲��ԣ������ڵ�emon������

### 9.0�����绷���л���k8s���粻ͨС����

```bash
# �������ð�̲��Բ�ͨ���ٳ���
$ systemctl restart NetworkManager
```

### 9.1������nginx ds

```bash
 # д������
$ cat > nginx-ds.yml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ds
  labels:
    app: nginx-ds
spec:
  type: NodePort
  selector:
    app: nginx-ds
  ports:
  - name: http
    port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-ds
spec:
  selector:
    matchLabels:
      app: nginx-ds
  template:
    metadata:
      labels:
        app: nginx-ds
    spec:
      containers:
      - name: my-nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
EOF

# ����ds
$ kubectl apply -f nginx-ds.yml
```

### 9.2��������ip��ͨ��

```bash
# ���� Node �ϵ� Pod IP ��ͨ��
$ kubectl get pods -o wide

# ��ÿ��worker�ڵ���ping pod ip
$ ping <pod-ip>

# ���service�ɴ���
$ kubectl get svc

# ��ÿ��worker�ڵ��Ϸ��ʷ���
$ curl <service-ip>:<port>

# ��ÿ���ڵ���node-port������
$ curl <node-ip>:<port>
```

### 9.3�����dns������

```bash
# ����һ��nginx pod
$ cat > pod-nginx.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: docker.io/library/nginx:1.19
    ports:
    - containerPort: 80
EOF

# ����pod
$ kubectl apply -f pod-nginx.yaml

# ����pod���鿴dns
$ kubectl exec nginx -it -- /bin/bash

# �鿴dns����
root@nginx:/# cat /etc/resolv.conf

# �鿴�����Ƿ������ȷ����
root@nginx:/# curl nginx-ds

# �˳�����
root@nginx:/# exit
```

### 9.4����־����

����ʹ��kubectl�鿴pod��������־

```bash
$ kubectl get pods
# ������������
NAME             READY   STATUS    RESTARTS   AGE
nginx            1/1     Running   0          54s
nginx-ds-dkfjm   1/1     Running   0          2m54s
nginx-ds-rx6mj   1/1     Running   0          2m54s

# �鿴��־
$ kubectl logs <pod-name>
```

### 9.5��Exec����

����kubectl��exec����

```bash
$ kubectl get pods -l app=nginx-ds
$ kubectl exec -it <nginx-pod-name> -- nginx -v
```

### 9.6��ɾ�����õĲ�����Դ

```bash
$ kubectl delete -f pod-nginx.yaml
$ kubectl delete -f nginx-ds.yml
# �鿴�Ƿ��������
$ kubectl get pods
# ������������
No resources found in default namespace.
```



# �ġ�Docker�İ�װ�����ã���emon����root�û���װ��

## 1����װDocker

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
# ��Ҫʱ������yum��װ���°汾docker
yum remote -y docker* container-selinux
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
$ uname -a
Linux emon 3.10.0-862.el7.x86_64 #1 SMP Fri Apr 20 16:44:24 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
$ cat /proc/version
Linux version 3.10.0-862.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-28) (GCC) ) #1 SMP Fri Apr 20 16:44:24 UTC 2018
```

1. ��װ��Ҫ���������yum-util�ṩyum-config-manager���ܣ�����������devicemapper����������

```shell
$ yum install -y yum-utils device-mapper-persistent-data lvm2
```

2. ����yumԴ

```shell
$ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

3. ���Բ鿴���вֿ�������docker�汾����ѡ��װ�ض��İ汾

```shell
$ yum list docker-ce --showduplicates |sort -r
```

4. ��װdocker

```shell
# ��װ����
# $ sudo yum install -y docker-ce
# ��װָ���汾
$ yum install -y docker-ce-18.06.3.ce
```

5. ����

```shell
$ systemctl start docker
```

6. ��֤��װ

```shell
$ docker version
$ docker info
$ docker run hello-world
```

> ˵�������docker info����ʾ��
> WARNING: bridge-nf-call-iptables is disabled
> WARNING: bridge-nf-call-ip6tables is disabled

����취��

```bash
$ vim /etc/sysctl.conf 
```

```bash
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
```

ʹ֮��Ч��

```bash
$ sysctl -p
```

������������ʱdocker info�Ϳ������˱����ˡ�

### 1.3������docker������

- ����

  - DaoCloud

  ���� DaoCloud: https://www.daocloud.io/ �ṩ��Docker��������

  ��¼DaoCloud���ҵ�С���ͼ�꣬����˵��������

  ```bash
  $ curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://f1361db2.m.daocloud.io
  docker version >= 1.12
  {"registry-mirrors": ["http://f1361db2.m.daocloud.io"]}
  Success.
  You need to restart docker to take effect: sudo systemctl restart docker
  ```

  - ������

  ��¼���￪����ƽ̨�� https://promotion.aliyun.com/ntms/act/kubernetes.html#industry

  �����������������ť���Զ���ת������̨�ľ���������������ʾע�Ტ��¼��

  ����ࡾ���񹤾ߡ���ѡ�񡾾�������������ұ������ɵļ��ٵ�ַ�������ҵģ�`https://pyk8pf3k.mirror.aliyuncs.com`��ִ�����������ϼ��ɣ�

  ```bash
  # - registry-mirrors����������ַ
  # - graph: ����docker����Ŀ¼��ѡ��Ƚϴ�ķ������������Ǹ�Ŀ¼�Ͳ���Ҫ�����ˣ�Ĭ��Ϊ/var/lib/docker��
  # - exec-opts: ����cgroup driver��Ĭ����cgroupfs�����Ƽ�����systemd��
  # - insecure-registries������˽�����ŵ�ַ
  tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
    "graph": "/usr/local/lib/docker",
    "exec-opts": ["native.cgroupdriver=cgroupfs"],
    "insecure-registries": ["192.168.200.116:5080"]
  }
  EOF
  ```

- �鿴

```bash
$ cat /etc/docker/daemon.json 
```

- ����

```bash
$ systemctl restart docker
# ɾ���ɵĴ洢λ��
$ rm -rf /var/lib/docker/
```



## 2����װdocker-compose

1������

```bash
$ curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

2����ӿ�ִ��Ȩ��

```bash
$ chmod +x /usr/local/bin/docker-compose
# �������������ⰲװHarborʱ����? Need to install docker-compose(1.18.0+) by yourself first and run this script again.
$ ln -snf /usr/local/bin/docker-compose /usr/bin/docker-compose
```

33������

```bash
$ docker-compose --version
# ������������
docker-compose version 1.29.2, build 5becea4c
```

# �塢Harbor����˽������emon����root�û���װ��

0. �л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

1. ���ص�ַ

https://github.com/goharbor/harbor/releases

```bash
$ wget https://github.com/goharbor/harbor/releases/download/v2.2.4/harbor-offline-installer-v2.2.4.tgz
```

2. ������ѹĿ¼

```bash
# ����Harbor��ѹĿ¼
$ mkdir /usr/local/Harbor
# ����Harbor��volumeĿ¼
$ mkdir -p /usr/local/DockerV/harbor_home
```

3. ��ѹ

```bash
# �Ƽ�v2.2.4�汾�����߰汾����2.3��2.4��docker-compose down -v ==> down-compose up -dʱpostgresql�����������˵�bug�����ݿ�����ʧ�ܣ�
$ tar -zxvf harbor-offline-installer-v2.2.4.tgz -C /usr/local/Harbor/
$ ls /usr/local/Harbor/harbor
common.sh  harbor.v2.2.4.tar.gz  harbor.yml.tmpl  install.sh  LICENSE  prepare
```

4. ������ǩ��֤�顾�ο�ʵ�֣�����������������CA֤�顿��ȱ��֤���޷��������¼��

- ����֤����Ŀ¼

```bash
# �л�Ŀ¼
$ mkdir /usr/local/Harbor/cert && cd /usr/local/Harbor/cert
```

- ����CA��֤��

```bash
# ����C��Country��ST��State��L��local��O��Origanization��OU��Organization Unit��CN��common name(eg, your name or your server's hostname)
$ openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt \
-subj "/C=CN/ST=ZheJiang/L=HangZhou/O=HangZhou emon Technologies,Inc./OU=IT emon/CN=emon"
# �鿴���
$ ls
ca.crt  ca.key
```

- ����һ��֤��ǩ�������÷�������Ϊ emon

```bash
$ openssl req -newkey rsa:4096 -nodes -sha256 -keyout emon.key -out emon.csr \
-subj "/C=CN/ST=ZheJiang/L=HangZhou/O=HangZhou emon Technologies,Inc./OU=IT emon/CN=emon"
# �鿴���
$ ls
ca.crt  ca.key  emon.csr  emon.key
```

- ����������֤��

```bash
$ openssl x509 -req -days 3650 -in emon.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out emon.crt
# �鿴���
$ ls
ca.crt  ca.key  ca.srl  emon.crt  emon.csr  emon.key
```

5. �༭����

```bash
$ cp /usr/local/Harbor/harbor/harbor.yml.tmpl /usr/local/Harbor/harbor/harbor.yml
$ vim /usr/local/Harbor/harbor/harbor.yml
```

```yaml
# �޸�
# hostname: reg.mydomain.com
hostname: emon
# �޸�
  # port: 80
  port: 5080
# �޸�
# https:
  # https port for harbor, default is 443
  # port: 443
  # The path of cert and key files for nginx
  # certificate: /your/certificate/path
  # private_key: /your/private/key/path
  # �޸ģ�ע�⣬���ﲻ��ʹ��������Ŀ¼ /usr/loca/harbor�滻/usr/local/Harbor/harbor-2.4.2
  # ����ᷢ��֤���Ҳ�������FileNotFoundError: [Errno 2] No such file or directory: 
  certificate: /usr/local/Harbor/cert/emon.crt
  private_key: /usr/local/Harbor/cert/emon.key
# �޸�
# data_volume: /data
data_volume: /usr/local/dockerv/harbor_home
```

6. ��װ

```bash
# ��װʱ��ȷ�� /usr/bin/docker-compose ���ڣ�����ᱨ��? Need to install docker-compose(1.18.0+) by yourself first and run this script again.
$ /usr/local/Harbor/harbor/install.sh --with-chartmuseum --with-trivy
# �л�Ŀ¼
$  cd /usr/local/Harbor/harbor/
# �鿴����״̬
$ docker-compose ps
# ������������
      Name                     Command                  State                           Ports                     
------------------------------------------------------------------------------------------------------------------
chartmuseum         ./docker-entrypoint.sh           Up (healthy)                                                 
harbor-core         /harbor/entrypoint.sh            Up (healthy)                                                 
harbor-db           /docker-entrypoint.sh 96 13      Up (healthy)                                                 
harbor-jobservice   /harbor/entrypoint.sh            Up (healthy)                                                 
harbor-log          /bin/sh -c /usr/local/bin/ ...   Up (healthy)   127.0.0.1:1514->10514/tcp                     
harbor-portal       nginx -g daemon off;             Up (healthy)                                                 
nginx               nginx -g daemon off;             Up (healthy)   0.0.0.0:5080->8080/tcp, 0.0.0.0:5443->8443/tcp
redis               redis-server /etc/redis.conf     Up (healthy)                                                 
registry            /home/harbor/entrypoint.sh       Up (healthy)                                                 
registryctl         /home/harbor/start.sh            Up (healthy)                                                 
trivy-adapter       /home/scanner/entrypoint.sh      Up (healthy)
```

8. ��¼

���ʣ�http://192.168.200.116:5080 ���ᱻ��ת��http://192.168.200.116:5443��

�û������룺 admin/Harbor12345

harbor���ݿ����룺 root123

��¼�󴴽����û���emon/Emon@123

9. �޸���������

```bash
$ cd /usr/local/Harbor/harbor/
$ docker-compose down -v
# ������� postgresql ������UP״̬�����µ�¼��ʾ�����ķ��񲻿��á� ��ִ�������������data_volume���õ���·����������Ǹð汾��bug��Ŀǰ��v2.2.4�汾������ȷ����������ɾ��pg13
# [emon@emon harbor]$ sudo rm -rf /usr/local/dockerv/harbor_home/database/pg13
$ docker-compose up -d
```

10. ˽����ȫ����

- ���ļ� `/etc/docker/daemon.json` ׷�� `insecure-registries`���ݣ�

```bash
$ vim /etc/docker/daemon.json
```

```bash
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "graph": "/usr/local/lib/docker",
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "insecure-registries": ["emon:5080"]
}
```

- ���ļ� `/lib/systemd/system/docker.service` ׷��`EnvironmentFile`������ʡ�ԡ�

```bash
$ vim /lib/systemd/system/docker.service 
```

```bash
# ��ExecStart����һ��׷�ӣ�����֤daemon.json������insecure-registries���ɣ���������������
EnvironmentFile=-/etc/docker/daemon.json
```

����Docker����

```bash
$ sudo systemctl daemon-reload
$ sudo systemctl restart docker
```

10. ���;���

��¼harbor���ȴ���devops-learning��Ŀ��������emon�û���

```bash
# ����
$ docker pull openjdk:8-jre
# ���ǩ
$ docker tag openjdk:8-jre emon:5080/devops-learning/openjdk:8-jre
# ��¼
$ docker login -u emon -p Emon@123 emon:5080
# �ϴ�����
$ docker push emon:5080/devops-learning/openjdk:8-jre
# �˳���¼
$ docker logout emon:5080
```

# ����Kubernetes�ķ�����

![image-20220403131408465](images/image-20220403131408465.png)

## 0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

## 1��ingress-nginx

- ��װ�����master�ڵ㣩

```bash
# ����mandatory.yaml����� nodeSelector����node������labelѡ�����������ӱ�ǩ������
# Warning  FailedScheduling  6m19s  default-scheduler  0/2 nodes are available: 2 node(s) didn't match Pod's node affinity.
$ kubectl label node emon3 app=ingress

# ������Դ
$ kubectl apply -f mandatory.yaml
# �鿴
$ kubectl get all -n ingress-nginx
```

- ���ھ��񣺽��������أ���ִ����������worker�ڵ㣩

```bash
# ��������һֱ���ϴ������⣬�����ذ�
# �鿴���辵��
$ grep image mandatory.yaml
# �ֹ��������辵��ע���һ��������Ӧ���� k8s.gcr.io/defaultbackend-amd64:1.5
$ crictl pull registry.cn-hangzhou.aliyuncs.com/liuyi01/defaultbackend-amd64:1.5
$ crictl pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.19.0
# �Ե�һ���������´��ǩ����ʹ��
$ ctr -n k8s.io i tag registry.cn-hangzhou.aliyuncs.com/liuyi01/defaultbackend-amd64:1.5 k8s.gcr.io/defaultbackend-amd64:1.5
```

## 2������hostNetwork

### 2.1��ingress-demo.yaml����

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-demo
spec:
  selector:
    matchLabels:
      app: tomcat-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: tomcat-demo
    spec:
      containers:
      - name: tomcat-demo
        image: registry.cn-hangzhou.aliyuncs.com/liuyi01/tomcat:8.0.51-alpine
        ports:
        - containerPort: 8080
---
#service
apiVersion: v1
kind: Service
metadata:
  name: tomcat-demo
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: tomcat-demo

---
#ingress
#old version: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tomcat-demo
spec:
  rules:
  - host: tomcat.mooc.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tomcat-demo
            port:
              number: 80
```

������Դ��Ч��

```bash
# Ӧ����Դ 
$ kubectl create -f ingress-demo.yaml
# �鿴����ingress������emon3��
$ kubectl get po -n ingress-nginx -o wide
# �鿴ingress-demo��pod״̬
$ kubectl get pod -o wide

# ���ñ���DNS������emon3��DNS
$ vim /etc/hosts
192.168.200.118 tomcat.mooc.com
192.168.200.118 api.mooc.com

# ����
http://tomcat.mooc.com # ��������tomcat����
http://apiu.mooc.com # ���� default backend - 404

# ɾ����Դ
$  kubectl delete -f ingress-demo.yaml
kubectl apply -f k8s-demo/cronjob-demo/cronjob.yaml
```





## 99�����ø���

### 99.1��mandatory.yaml

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ingress-nginx

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-http-backend
  labels:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx
  namespace: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: default-http-backend
      app.kubernetes.io/part-of: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: default-http-backend
        app.kubernetes.io/part-of: ingress-nginx
    spec:
      terminationGracePeriodSeconds: 60
      containers:
        - name: default-http-backend
          # Any image is permissible as long as:
          # 1. It serves a 404 page at /
          # 2. It serves 200 on a /healthz endpoint
          image: k8s.gcr.io/defaultbackend-amd64:1.5
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 30
            timeoutSeconds: 5
          ports:
            - containerPort: 8080
          resources:
            limits:
              cpu: 10m
              memory: 20Mi
            requests:
              cpu: 10m
              memory: 20Mi

---
apiVersion: v1
kind: Service
metadata:
  name: default-http-backend
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx
spec:
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app.kubernetes.io/name: default-http-backend
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: tcp-services
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

kind: ConfigMap
apiVersion: v1
metadata:
  name: udp-services
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---

apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: nginx-ingress-clusterrole
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - services
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - ""
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - "extensions"
    resources:
      - ingresses/status
    verbs:
      - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: nginx-ingress-role
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
rules:
  - apiGroups:
      - ""
    resources:
      - configmaps
      - pods
      - secrets
      - namespaces
    verbs:
      - get
  - apiGroups:
      - ""
    resources:
      - configmaps
    resourceNames:
      # Defaults to "<election-id>-<ingress-class>"
      # Here: "<ingress-controller-leader>-<nginx>"
      # This has to be adapted if you change either parameter
      # when launching the nginx-ingress-controller.
      - "ingress-controller-leader-nginx"
    verbs:
      - get
      - update
  - apiGroups:
      - ""
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - ""
    resources:
      - endpoints
    verbs:
      - get

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: nginx-ingress-role-nisa-binding
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: nginx-ingress-role
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: nginx-ingress-clusterrole-nisa-binding
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: nginx-ingress-clusterrole
subjects:
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-nginx

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/part-of: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/part-of: ingress-nginx
      annotations:
        prometheus.io/port: "10254"
        prometheus.io/scrape: "true"
    spec:
      serviceAccountName: nginx-ingress-serviceaccount
      hostNetwork: true
      nodeSelector:
        app: ingress
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.19.0
          args:
            - /nginx-ingress-controller
            - --default-backend-service=$(POD_NAMESPACE)/default-http-backend
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
            - --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services
            - --udp-services-configmap=$(POD_NAMESPACE)/udp-services
            - --publish-service=$(POD_NAMESPACE)/ingress-nginx
            - --annotations-prefix=nginx.ingress.kubernetes.io
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            # www-data -> 33
            runAsUser: 33
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - name: http
              containerPort: 80
            - name: https
              containerPort: 443
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 1

---
```





# ��ʮ��Containerdȫ������ʵ��

- ctr�����

containerd�ṩ�Ĺ���

```bash
# �鿴ctr�������
$ ctr -h
# �鿴�����������
$ ctr i -h
# �鿴�����б�
$ ctr i ls
# �鿴ָ������ռ��¾����б�
$ ctr -n default i ls
# ���ؾ���
$ ctr i pull docker.io/library/redis:alpine
# �鿴�����ռ����
$ ctr ns -h
# �鿴�����ռ�
$ ctr ns ls
# ����������ָ������ID
$ ctr run -t -d docker.io/library/redis:alpine redis
# �鿴�����б�
$ ctr c ls
# �鿴���������б�
$ ctr t ls
# ͣ����������
$ ctr t kill redis
# ɾ���������񣨲���������
$ ctr t rm redis
# ɾ������
$ ctr c rm redis
```

- crictl

k8s�ṩ�Ĺ���

```bash
# �鿴crictl�������
$ crictl -h
# �鿴����
$ crictl images
# �鿴pod
$ crictl pods
```

- kubectl

```bash
# �鿴�ͻ��˺ͷ�������汾��Ϣ
$ kubectl version
# ��group/version�ĸ�ʽ��ʾ����������֧�ֵ�API�汾
$ kubectl api-versions
# ��ʾ��Դ�ĵ���Ϣ
$ kubectl explain

# ȡ��ȷ�϶�����Ϣ�б�
$ kubectl get < xxx >
# ��ʾnode����Ϣ
$ kubectl get nodes -o wide
# �г�namespace��Ϣ
$ kubectl get namespaces
# �г�deployment��Ϣ
$ kubectl get deployment -n ingress-nginx


# ȡ��ȷ�϶������ϸ��Ϣ
$ kubectl describe < xxx > < xxx >
# �г�node��ϸ��Ϣ
$ kubectl describe node emon2
# �г�ĳһ��pod��ϸ��Ϣ��-nָ�������ռ�
$ kubectl describe pod ingress-nginx-admission-patch-kpnds -n ingress-nginx
# �г�ĳһ��deployment��ϸ��Ϣ
$ kubectl describe deployment ingress-nginx-controller -n ingress-nginx

# ȡ��pod��������log��Ϣ
$ kubectl logs < xxx >
$ kubectl logs nginx-ds-tbtkz

# ��������ִ��һ������
$ kubectl exec < xxx >
$ kubectl exec -it nginx-ds-tbtkz -- nginx -v

# �������п��������������������ļ�
$ kubectl cp
# Attach��һ�������е�������
$ kubectl attach

# �鿴ĳ�������ռ�������Ϣ
$ kubectl get all -n ingress-nginx
# ������Դ
$ kubectl apply -f < xxx.yaml >
# ɾ����Դ
$ kubectl delete -f < xxx.yaml >
# ���ڵ���ǩ
$ kubectl label node emon2 disktype=ssd
# �鿴�ڵ��ϵı�ǩ
$ kubectl get node emon2 --show-labels
# �鿴���нڵ��ϵı�ǩ�б�����ǩ����
$ kubectl get node --show-labels
# ɾ����ǩ��ע���ǩ��������� - ��ʾɾ��
$ kubectl label node emon2 disktype-
```



# ��ʮ�塢��װ������������

## 1����װGit

1. ��鰲װ���

```bash
$ yum list git|tail -n 2
�ɰ�װ�������
git.x86_64                       1.8.3.1-13.el7                        CentOS7.5
```

2. ����

���ص�ַ��  https://www.kernel.org/pub/software/scm/git/

```bash
$ wget -cP /usr/local/src/ https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.26.2.tar.gz
```

3. ��������밲װ

```bash
$ yum list gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc gcc-c+ curl-devel expat-devel perl-ExtUtils-MakeMaker perl-ExtUtils-CBuilder cpio
$ yum install -y gettext-devel openssl-devel perl-CPAN perl-devel zlib-devel gcc gcc-c+ curl-devel expat-devel perl-ExtUtils-MakeMaker perl-ExtUtils-CBuilder cpio
```

4. ������ѹĿ¼

```bash
$ mkdir /usr/local/Git
```

5. ��ѹ

```bash
$ tar -zxvf /usr/local/src/git-2.26.2.tar.gz -C /usr/local/Git/
```

6. ִ�����ýű��������밲װ

- �л�Ŀ¼��ִ�нű�

```bash
$ cd /usr/local/Git/git-2.26.2/
$ ./configure --prefix=/usr/local/Git/git2.26.2
```

- ����

```bash
$ make
```

- ��װ

```bash
$ make install
$ cd
$ ls /usr/local/Git/git2.26.2/
bin  libexec  share
```

7. ����������

```bash
$ ln -snf /usr/local/Git/git2.26.2/ /usr/local/git
```

8. ���û�������

```bash
$ vim /etc/profile.d/git.sh
```

```bash
export GIT_HOME=/usr/local/git
export GIT_EDITOR=vim
export PATH=$GIT_HOME/bin:$PATH
```

ʹ֮��Ч��

```bash
$ source /etc/profile
```

9. �����˻���Ϣ

```bash
$ git config --global user.name "emon"
$ git config --global user.email "[����]"
```

10. ����SSH��Ϣ

- ���SSH keys�Ƿ���ڣ�

```bas
$ ls -a ~/.ssh/
.  ..  known_hosts
```

- ��������ڣ�����SSH keys��

```bash
$ ssh-keygen -t rsa -b 4096 -C "[����]"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/emon/.ssh/id_rsa): `[Ĭ��]`
Enter passphrase (empty for no passphrase): `[�����������û��л���emon����ʾ����]`
Enter same passphrase again: `[ȷ�Ͽ���]`
Your identification has been saved in /home/emon/.ssh/id_rsa.
Your public key has been saved in /home/emon/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:+hdO9yUj/Cm0IAaJcUqkPgXNY50lXZFIkdKZH7LhKIs liming20110711@163.com
The key's randomart image is:
+---[RSA 4096]----+
|  .+...*+Boo     |
|   oB =.X o      |
|  .o.* = = .     |
| . .+ + o .      |
|  o. o .S  .     |
|  E..  .o + = o .|
|      .. + = = = |
|       .  o o +  |
|        ..   .   |
+----[SHA256]-----+
```

- ������Կ��GitHub�ϡ���Ҫ��GitHub�˻��ſ������á�

```bash
$ cat ~/.ssh/id_rsa.pub
```

�����˹�Կ����GitHub����SSH keys��ҳ�棺 https://github.com/settings/keys ��Settings->SSH and GPG keys->New SSH key->д��Title��ճ��Key��

| Title           | Key                |
| --------------- | ------------------ |
| centos-emon-rsa | ���ղſ����Ĺ�Կ�� |

���Add SSH key��ȷ����ӡ�

- ��֤SSH����

```bash
$ ssh -T git@github.com
The authenticity of host 'github.com (13.250.177.223)' can't be established.
RSA key fingerprint is SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8.
RSA key fingerprint is MD5:16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,13.250.177.223' (RSA) to the list of known hosts.
Enter passphrase for key '/home/emon/.ssh/id_rsa': `[����SSH keysʱ���õĿ���]`
Hi Rushing0711! You've successfully authenticated, but GitHub does not provide shell access.
$ ls -a ~/.ssh/
.  ..  id_rsa  id_rsa.pub  known_hosts
```

11. У��

```bash
$ git --version
git version 2.26.2
```

## 2����װJDK

1. ����Ƿ��Ѱ�װ

```bash
$ rpm -qa|grep jdk
```

2. ����

��������ص�ַ������ͨ��ORACLE��������ҳ����¼���ȡ��

��������ҳ��ַ�� http://www.oracle.com/technetwork/java/javase/downloads/index.html

```bash
$ wget -cP /usr/local/src/ http://111.1.50.18/files/3104000006BC77D6/download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u251-linux-x64.tar.gz
```

3. ������װĿ¼

```bash
$ mkdir /usr/local/Java
```

4. ��ѹ��װ

```bash
$ tar -zxvf /usr/local/src/jdk-8u251-linux-x64.tar.gz -C /usr/local/Java/
```

5. ����������

```bash
$ ln -snf /usr/local/Java/jdk1.8.0_251/ /usr/local/java
```

6. ���û�������

��`/etc/profile.d`Ŀ¼����`jdk.sh`�ļ���

```bash
$ vim /etc/profile.d/jdk.sh
```

```bash
export JAVA_HOME=/usr/local/java
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
```

ʹ֮��Ч��

```bash
$ source /etc/profile
```

7. У��

```bash
$ java -version
java version "1.8.0_171"
Java(TM) SE Runtime Environment (build 1.8.0_171-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.171-b11, mixed mode)
```

## 3����װMaven

1. ����

���ص�ַ��ȡҳ�棺 https://maven.apache.org/download.cgi

```bash
$ wget -cP /usr/local/src/ http://mirrors.hust.edu.cn/apache/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz
```

2. ������װĿ¼

```bash
$ mkdir /usr/local/Maven
```

3. ��ѹ��װ

```bash
$ tar -zxvf /usr/local/src/apache-maven-3.6.3-bin.tar.gz -C /usr/local/Maven/
```

4. ����������

```bash
$ ln -snf /usr/local/Maven/apache-maven-3.6.3/ /usr/local/maven
```

5. ���û�������

��`/etc/profile.d`Ŀ¼����`mvn.sh`�ļ���

```bash
$ vim /etc/profile.d/mvn.sh
```

```bash
export MAVEN_HOME=/usr/local/maven
export PATH=$MAVEN_HOME/bin:$PATH
```

ʹ֮��Ч��

```bash
$ source /etc/profile
```

6. У��

```bash
$ mvn -v
```

7. ����

- ����repo���Ŀ¼

```bash
$ mkdir /usr/local/maven/repository
```

- ���ô��repo

  ```bash
  $ vim /usr/local/maven/conf/settings.xml 
  ```

  - ����`localRepository`�����û����ʲ��������á�

  ```xml
    <!-- localRepository
     | The path to the local repository maven will use to store artifacts.
     |
     | Default: ${user.home}/.m2/repository
    <localRepository>/path/to/local/repo</localRepository>
    -->
    <localRepository>/usr/local/maven/repository</localRepository>
  ```

  **˵����**��Ҫ�޸�`/usr/local/maven/repository`Ϊ`jenkins`�û�Ȩ�ޡ�

  > $ sudo chown jenkins.jenkins /usr/local/maven/repository
  
  - ����`mirror`
  
  ```xml
    <mirrors>
      <!-- mirror
       | Specifies a repository mirror site to use instead of a given repository. The repository that
       | this mirror serves has an ID that matches the mirrorOf element of this mirror. IDs are used
       | for inheritance and direct lookup purposes, and must be unique across the set of mirrors.
       |
      <mirror>
        <id>mirrorId</id>
        <mirrorOf>repositoryId</mirrorOf>
        <name>Human Readable Name for this Mirror.</name>
        <url>http://my.repository.com/repo/path</url>
      </mirror>
       -->
      <mirror>
          <id>nexus</id>
          <mirrorOf>*,!cloudera</mirrorOf>
          <name>nexus maven</name>
          <url>http://maven.aliyun.com/nexus/content/groups/public</url>
          <!--<url>http://localhost:8081/repository/maven-public/</url>-->
      </mirror>
    </mirrors>
  ```
