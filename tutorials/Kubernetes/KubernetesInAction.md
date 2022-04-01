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

### 1.3��׼��k8s�����

#### 1.3.0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft && cd k8s_soft
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

# ����etcd���
$ wget -cP /usr/local/src https://github.com/etcd-io/etcd/releases/download/v3.4.10/etcd-v3.4.10-linux-amd64.tar.gz
$ tar -zxvf /usr/local/src/etcd-v3.4.10-linux-amd64.tar.gz -C .
$ mv etcd-v3.4.10-linux-amd64/etcd* .
$ rm -rf etcd-v3.4.10-linux-amd64

# ͳһ�޸��ļ�Ȩ��Ϊ��ִ��
$ chmod +x kube*
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
  scp etcd etcdctl root@${instance}:/usr/local/bin/
done
```



## 2������֤�飨����ת�ڵ㣩

���²���������`/root/k8s_soft`Ŀ¼ִ�С�

### 2.0����װcfssl

- ��װcfssl

cfssl�Ƿǳ����õ�CA���ߣ���������������֤�����Կ�ļ� ��װ���̱Ƚϼ򵥣����£�

```bash
# ����
$ wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssl_1.6.1_linux_amd64 -O /usr/local/bin/cfssl
$ wget https://github.com/cloudflare/cfssl/releases/download/v1.6.1/cfssljson_1.6.1_linux_amd64 -O /usr/local/bin/cfssljson

# �޸�Ϊ��ִ��Ȩ��
$ chmod +x /usr/local/bin/cfssl /usr/local/bin/cfssljson

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
# ����Ŀ¼
$ cd
$ mkdir -pv k8s_soft && cd k8s_soft
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

### 2.5��admin�û�����

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

### 2.6���ַ������ļ�

#### 2.6.1����kubelet��kube-proxy��Ҫ��kubeconfig���÷ַ���ÿ��worker�ڵ�

```bash
$ WORKERS="emon2 emon3"
for instance in ${WORKERS}; do
    scp ${instance}.kubeconfig kube-proxy.kubeconfig ${instance}:~/
done
```

#### 2.6.2����kube-controller-manager��kube-scheduler��Ҫ��kubeconfig���÷ַ���master�ڵ�

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
$ mv ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    proxy-client.pem proxy-client-key.pem \
    /etc/kubernetes/ssl

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
$ mv kube-controller-manager.kubeconfig /etc/kubernetes/

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
$ mv kube-scheduler.kubeconfig /etc/kubernetes

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
$ systemctl daemon-reload
$ systemctl enable kube-apiserver
$ systemctl enable kube-controller-manager
$ systemctl enable kube-scheduler
$ systemctl restart kube-apiserver
$ systemctl restart kube-controller-manager
$ systemctl restart kube-scheduler
```

### 5.5��������֤

�˿���֤

```bash
# ��������ļ����˿�
[root@emon ~]# netstat -tnlp
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
$ mv ~/admin.kubeconfig ~/.kube/config
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
# ����Ŀ¼
$ cd
$ mkdir -pv k8s_soft && cd k8s_soft
```

### 6.1��Container Runtime - Containerd

#### 6.1.1����������أ�����ת�ڵ㣩

```bash
# �趨containerd�İ汾��
$ VERSION=1.4.3
# ����ѹ����
$ wget https://github.com/containerd/containerd/releases/download/v${VERSION}/cri-containerd-cni-${VERSION}-linux-amd64.tar.gz

# �ַ�������work�ڵ�
$ WORKERS="emon2 emon3"
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
$ vi /etc/containerd/config.toml
```

�޸�Ĭ�Ͼ���Ŀ¼���Ǳ��룩�����ԡ�

```bash
# ��������Ŀ¼
mkdir /usr/local/lib/containerd
# ����config.toml����
root = "/var/lib/containerd" ==> root = "/usr/local/lib/containerd"
```

#### 6.1.4������containerd

```bash
$ systemctl enable containerd
$ systemctl restart containerd
# ���״̬
$ systemctl status containerd
```



### 6.2������kubelet

#### ׼��kubelet����

```bash
$ mkdir -p /etc/kubernetes/ssl/
$ mv ${HOSTNAME}-key.pem ${HOSTNAME}.pem ca.pem ca-key.pem /etc/kubernetes/ssl/
$ mv ${HOSTNAME}.kubeconfig /etc/kubernetes/kubeconfig
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
# ���⣺���ļ�����emon2Ҳ��Ҫ����
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
$ systemctl daemon-reload
$ systemctl enable kubelet kube-proxy
$ systemctl restart kubelet kube-proxy
$ journalctl -f -u kubelet
$ journalctl -f -u kube-proxy
```

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

### 6.6���ֶ����ؾ��񣨷������޷��������������

��ÿ�������ڵ�����pause����Ϊ��������������

```bash
$ crictl pull registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2
$ ctr -n k8s.io i tag  registry.cn-hangzhou.aliyuncs.com/kubernetes-kubespray/pause:3.2 k8s.gcr.io/pause:3.2
```



## 7��������-Calico

�ⲿ�����ǲ���kubernetes�������� CNI��

�ĵ���ַ��https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises

### 7.1�������ļ�˵��

�ĵ������������ã�50���½ڵ��50���Ͻڵ㣬���ǵ���Ҫ�������������typha��
���ڵ����Ƚ϶������£�Calico �� Felix�����ͨ�� Typha ֱ�Ӻ� Etcd �������ݽ�������ͨ�� kube-apiserver������kube-apiserver��ѹ������Ҹ����Լ���ʵ�����ѡ�����ء�
���غ���ļ���һ��all-in-one��yaml�ļ�������ֻ��Ҫ�ڴ˻������������޸ļ��ɡ�



