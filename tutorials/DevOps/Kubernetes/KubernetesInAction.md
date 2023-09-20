# Kubernetesʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# һ��Kubeadmin��װK8S V1.20

����汾��https://blog.csdn.net/Josh_scott/article/details/121961369?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_title~default-0.pc_relevant_default&spm=1001.2101.3001.4242.1&utm_relevant_index=3



�߿��ð汾��https://blog.csdn.net/qq_16538827/article/details/120175489



Kubeadm��һ��K8s���𹤾ߣ��ṩkubeadm init��kubeadm join�����ڿ��ٲ���Kubernetes��Ⱥ��

## 1����������׼��

### 1.1���������滮

| ������ | ϵͳ����  | IP��ַ          | �ڴ� | �������� |
| ------ | --------- | --------------- | ---- | -------- |
| emon   | CentOS7.7 | 192.168.200.116 | >=2G | master   |
| emon2  | CentOS7.7 | 192.168.200.117 | >=2G | worker   |
| emon3  | CentOS7.7 | 192.168.200.118 | >=2G | worker   |

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

## 2��������װ�����нڵ㣩

### 2.1����װDocker

[�鿴�ٷ�CentOS��װDocker�̳�](https://docs.docker.com/engine/install/centos/)

####  2.1.0��ɾ���ɰ�Docker

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
yum remove -y docker* container-selinux
```

���yum����˵���ϰ�װ��δ��װ��δƥ�䣬δɾ���κΰ�װ�������뻷���ɾ���û����ʷ�����ɰ氲װ��

#### 2.1.1��CentOS�����°�װDocker

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

#### 2.1.2������docker������

- ������

��¼���￪����ƽ̨�� https://promotion.aliyun.com/ntms/act/kubernetes.html#industry

�����������������ť���Զ���ת������̨�ľ���������������ʾע�Ტ��¼��

����ࡾ���񹤾ߡ���ѡ�񡾾�������������ұ������ɵļ��ٵ�ַ�������ҵģ�`https://pyk8pf3k.mirror.aliyuncs.com`��ִ�����������ϼ��ɣ�

```bash
# - registry-mirrors����������ַ
# - graph: ����docker����Ŀ¼��ѡ��Ƚϴ�ķ�������������Ǹ�Ŀ¼�Ͳ���Ҫ�����ˣ�Ĭ��Ϊ/var/lib/docker��
# - exec-opts: ����cgroup driver��Ĭ����cgroupfs�����Ƽ�����systemd��
# - insecure-registries������˽�����ŵ�ַ
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "graph": "/var/lib/docker",
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "insecure-registries": ["192.168.32.116:5080"]
}
EOF
```

- �鿴

```bash
$ cat /etc/docker/daemon.json 
```

- ����

```bash
$ systemctl enable docker && systemctl restart docker
```

### 2.2����װkubeadm/kubelet/kubectl

#### 2.2.1����װ

1. ����k8sԴ

```bash
$ cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes] 
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64 
enabled=1 
gpgcheck=0 
repo_gpgcheck=0 
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg 
EOF
$ yum update
```

2.  ��װkubeadm/kubelet/kubectl

```bash
$ yum install -y kubelet-1.20.15 kubeadm-1.20.15 kubectl-1.20.15
# �� kubeadm init �� join ���kubelet��������������ﲻ��Ҫ�ֹ�����������Ҫ���뿪������������
$ systemctl enable kubelet
```



## 3������Kubernetes Mater����master�ڵ㣩

### 3.1��kubeadm init

```bash
# ��Master��ִ�У�����Ĭ����ȡ�����ַ k8s.gcr.io �����޷����ʣ�����ָ�������ƾ���ֿ��ַ��
# ִ�иò���֮ǰ��Ҳ����ִ�� kubeadm config images pull Ԥ���ؾ���
$ kubeadm init \
--apiserver-advertise-address=192.168.200.116 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.20.0 \
--service-cidr=10.233.0.0/16 \
--pod-network-cidr=10.200.0.0/16

# ʹ�� kubectl ���ߣ�Master&&Node�ڵ㣩
$ mkdir -p $HOME/.kube 
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ����ѡһ�������root�û�������ʹ�����������滻���棺���������ѡһ��
export KUBECONFIG=/etc/kubernetes/admin.conf

# ����ʱ������ִ�У�������¼�ο�
# Then you can join any number of worker nodes by running the following on each as root:
kubeadm join 192.168.200.116:6443 --token jqgqm7.ax7b938u5xheiu6d \
    --discovery-token-ca-cert-hash sha256:882f6812169b4103fcae6065975c3cb231184cd4950301b7fcc5f769ddd265cb
```

### 3.2����װ������-calico����master�ڵ㣩

#### 3.2.1���л�Ŀ¼

```bash
$ cd
$ mkdir -pv /root/k8s_soft/k8s_v1.20.15 && cd /root/k8s_soft/k8s_v1.20.15
```

�ⲿ�����ǲ���kubernetes�������� CNI��

�ĵ���ַ��https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises

#### 3.2.2�������ļ������õ���

�ĵ������������ã�50���½ڵ��50���Ͻڵ㣬���ǵ���Ҫ�������������typha��
���ڵ����Ƚ϶������£�Calico �� Felix�����ͨ�� Typha ֱ�Ӻ� Etcd �������ݽ�������ͨ�� kube-apiserver������kube-apiserver��ѹ������Ҹ����Լ���ʵ�����ѡ�����ء�
���غ���ļ���һ��all-in-one��yaml�ļ�������ֻ��Ҫ�ڴ˻������������޸ļ��ɡ�

```bash
# ����calico.yaml�ļ�
# $ curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O ��������°汾����K8S�汾V1.20.15�����ʺϡ�
$ curl https://docs.projectcalico.org/v3.20/manifests/calico.yaml -O
```

�޸�IP�Զ�����

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

�޸�CIDR

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

#### 3.2.3��ִ�а�װ

```bash
# ��Ч֮ǰ�鿴
$ kubectl get nodes
NAME   STATUS     ROLES                  AGE     VERSION
emon   NotReady   control-plane,master   5m31s   v1.20.15
# ʹ֮��Ч
$ kubectl apply -f calico.yaml
# �鿴node
$ kubectl get nodes
NAME    STATUS     ROLES                  AGE    VERSION
emon    Ready      control-plane,master   7m2s   v1.20.15
# �鿴pod
$ kubectl get po -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-577f77cb5c-g78c7   1/1     Running   0          13h
calico-node-hxvx8                          1/1     Running   0          13h
coredns-7f89b7bc75-8ks6f                   1/1     Running   0          14h
coredns-7f89b7bc75-kfdbm                   1/1     Running   0          14h
etcd-emon                                  1/1     Running   0          14h
kube-apiserver-emon                        1/1     Running   0          14h
kube-controller-manager-emon               1/1     Running   0          14h
kube-proxy-f2r8l                           1/1     Running   0          14h
kube-scheduler-emon                        1/1     Running   0          14h

# ===== �ȴ�����һ��worker�ڵ����֮���ٲ鿴������Ϣ������ῴ��pending����Ϊ�Ҳ������ʵĽڵ㲿��pod =====
# �鿴pod��Ϣ
$ kubectl get po -n kube-system
NAME                                       READY   STATUS     RESTARTS   AGE
calico-kube-controllers-858c9597c8-ktgcf   0/1     Pending    0          7s
calico-node-4282z                          0/1     Init:0/3   0          7s
coredns-7f89b7bc75-5262d                   0/1     Pending    0          5m30s
coredns-7f89b7bc75-tf6tl                   0/1     Pending    0          5m30s
etcd-emon                                  1/1     Running    0          5m45s
kube-apiserver-emon                        1/1     Running    0          5m45s
kube-controller-manager-emon               1/1     Running    0          5m45s
kube-proxy-vwxmm                           1/1     Running    0          5m30s
kube-scheduler-emon                        1/1     Running    0          5m45s
# ===================================================================================================
# ���������ٴβ鿴
$ kubectl get po -n kube-system
NAME                                       READY   STATUS    RESTARTS   AGE
calico-kube-controllers-858c9597c8-ktgcf   1/1     Running   0          6m9s
calico-node-4282z                          1/1     Running   0          6m9s
calico-node-xjwc4                          1/1     Running   0          5m4s
coredns-7f89b7bc75-5262d                   1/1     Running   0          11m
coredns-7f89b7bc75-tf6tl                   1/1     Running   0          11m
etcd-emon                                  1/1     Running   0          11m
kube-apiserver-emon                        1/1     Running   0          11m
kube-controller-manager-emon               1/1     Running   0          11m
kube-proxy-mcwts                           1/1     Running   0          5m4s
kube-proxy-vwxmm                           1/1     Running   0          11m
kube-scheduler-emon                        1/1     Running   0          11m
# �ٴβ鿴node
$ kubectl get nodes
NAME    STATUS   ROLES                  AGE     VERSION
emon    Ready    control-plane,master   12m     v1.20.15
emon2   Ready    <none>                 5m21s   v1.20.15
```

### 3.3������ڵ㵽��Ⱥ����worker�ڵ㣩

```bash
# ������kubeadm initִ�гɹ��󣬵õ�����־
......ʡ��......
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.200.116:6443 --token bizkzu.r7xeo57jugvd2ia3 \
    --discovery-token-ca-cert-hash sha256:2ab2809af3d7ea7b684e1dcdea1859b226ec8b9185a82a56344aade4d3000f99
```



## 4����װingress-nginx����master�ڵ㣩

### 4.1���л�Ŀ¼

```bash
$ cd
$ mkdir -pv /root/k8s_soft/k8s_v1.20.15 && cd /root/k8s_soft/k8s_v1.20.15
```

### 4.2�������ļ������õ�������δ���á�

```bash
# ����
curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml -O
```

�޸�kindģʽ Deployment ==> DaemonSet

```yaml
#kind: Deployment ����ingress-nginx-controller�ҵ��ô����޸�
kind: DaemonSet
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.3.0
  name: ingress-nginx-controller
```

�ڶ����޸ģ�����

```bash
# �ҵ�nginx-ingress-controller���containers������nodeSelector����
	spec:
      nodeSelector:
        app: ingress
      containers:
      - args:
        - /nginx-ingress-controller
```



### 4.3����װingress-nginx

- ��װ�����master�ڵ㣩

```bash
# ����mandatory.yaml����� nodeSelector����node������labelѡ�����������ӱ�ǩ������
# Warning  FailedScheduling  6m19s  default-scheduler  0/2 nodes are available: 2 node(s) didn't match Pod's node affinity.
$ kubectl label node emon2 app=ingress

# ===== ��������һֱ���ϴ������⣬�����ذ� beg =====����worker�ڵ����ؾ��񼴿ɡ�
# �鿴���辵��
$ grep image ingress-nginx.yaml
# �ֹ��������辵��ע���һ��������Ӧ���� k8s.gcr.io/defaultbackend-amd64:1.5
$ docker pull registry.cn-hangzhou.aliyuncs.com/liuyi01/defaultbackend-amd64:1.5
$ docker pull quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0
# �Ե�һ���������´��ǩ����ʹ��
# ���ز��ɷ��ʵľ���
$ docker tag registry.cn-hangzhou.aliyuncs.com/liuyi01/defaultbackend-amd64:1.5 k8s.gcr.io/defaultbackend-amd64:1.5
# ===== ��������һֱ���ϴ������⣬�����ذ� end =====

# ������Դ
$ kubectl apply -f ingress-nginx.yaml
# �鿴
$ kubectl get all -n ingress-nginx -o wide
```

### 4.4�����Է���

#### 4.4.1��ingress-demo.yaml����

```bash
$ vim ingress-demo.yaml
```

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
# Ӧ����Դ����������ʹ�ã��ɵ���Ϊ create -> apply  ����ʹ�úʹ�����ʹ�õ�Ч��
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
http://api.mooc.com # ���� default backend - 404

# ɾ����Դ
$ kubectl delete -f ingress-demo.yaml
```

#### 4.4.2��ingress-nginx.yaml

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
# ��һ�������� Deployment ==> DaemonSet
kind: DaemonSet
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
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
          # �ڶ��������� 0.19.0 ==> 0.23.0
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0
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

## 5����Ⱥð�̲��ԣ������ڵ�emon������

### 5.0�����绷���л���k8s���粻ͨС����

```bash
# �������ð�̲��Բ�ͨ���ٳ���
$ systemctl restart NetworkManager
```

### 5.1������nginx ds

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

### 5.2��������ip��ͨ��

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

### 5.3�����dns������

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

### 5..4����־����

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

### 5.5��Exec����

����kubectl��exec����

```bash
# ��ѯָ����ǩ��pod
$ kubectl get pods -l app=nginx-ds
$ kubectl exec -it <nginx-pod-name> -- nginx -v
```

### 5.6��ɾ�����õĲ�����Դ

```bash
$ kubectl delete -f pod-nginx.yaml
$ kubectl delete -f nginx-ds.yml
# �鿴�Ƿ��������
$ kubectl get pods
# ������������
No resources found in default namespace.
```

## 6��Harbor����˽������emon����root�û���װ��

### 6.1����װdocker-compose

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

### 6.2����װHarbor����˽��

Harbor����˽������emon����root�û���װ��

0. �л�Ŀ¼

```bash
$ cd
$ mkdir -pv /root/k8s_soft/k8s_v1.20.15 && cd /root/k8s_soft/k8s_v1.20.15
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
$ mkdir -p /usr/local/dockerv/harbor_home
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
hostname: 192.168.200.116
# �޸�
  # port: 80
  port: 5080
# �޸�
https:
  # https port for harbor, default is 443
  port: 5443
  # The path of cert and key files for nginx
  # certificate: /your/certificate/path
  # private_key: /your/private/key/path
  # �޸ģ�ע�⣬���ﲻ��ʹ��������Ŀ¼ /usr/loca/harbor�滻/usr/local/Harbor/harbor-2.2.4
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

��¼�󴴽��������ռ䣺devops-learning ����emon�û����ڸ������ռ�

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
  "insecure-registries": ["192.168.200.116:5080"]
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
$ systemctl daemon-reload
$ systemctl restart docker
```

10. ���;���

��¼harbor���ȴ���devops-learning��Ŀ��������emon�û���

```bash
# ����
$ docker pull openjdk:8-jre
# ���ǩ
$ docker tag openjdk:8-jre 192.168.200.116:5080/devops-learning/openjdk:8-jre
# ��¼
$ docker login -u emon -p Emon@123 192.168.200.116:5080
# �ϴ�����
$ docker push 192.168.200.116:5080/devops-learning/openjdk:8-jre
# �˳���¼
$ docker logout 192.168.200.116:5080

�������˻���
token��  
XsttKM4zpuFWcchUmEhJErmiRRRfBu0A
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
# ��װ�������
$ yum install -y epel-release python36 python36-pip git
# ����kubesprayԴ��
$ wget https://github.com/kubernetes-sigs/kubespray/archive/v2.15.0.tar.gz
# ��ѹ��
$ tar -xvf v2.15.0.tar.gz && cd kubespray-2.15.0
# ��װrequirements
$ cat requirements.txt
$ pip3.6 install -r requirements.txt

## ���install������������ȳ�������pip
$ pip3.6 install --upgrade pip
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
vim inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml
# 5. �޸�etcd��������Ϊhost��Ĭ����docker��
vim inventory/mycluster/group_vars/etcd.yml
# 6. ���������ingress��dashboard�ȣ�
vim inventory/mycluster/group_vars/k8s-cluster/addons.yml
```

- `vim inventory/mycluster/group_vars/all/all.yml`

```bash
# [����]
http_proxy: "http://192.168.200.116:8118"
# [����]
https_proxy: "http://192.168.200.116:8118"
```

- `vim inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml`

```yaml
# [�޸�]
kube_service_addresses: 10.200.0.0/16
# [�޸�]
kube_pods_subnet: 10.233.0.0/16
# [����]
container_manager: docker
```

- `vim inventory/mycluster/group_vars/k8s-cluster/addons.yml`

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
$ ansible-playbook -i inventory/mycluster/hosts.yaml  -b cluster.yml -vvvv
```

### 3.6�������������

����������ã�����ʱ������Ҫ����ɾ���������ü��ɣ�

##### ɾ��docker��http������ÿ���ڵ�ִ�У�

```bash
$ rm -f /etc/systemd/system/containerd.service.d/http-proxy.conf
$ systemctl daemon-reload
$ systemctl restart containerd
```

##### ɾ��yum����

```bash
# ��grep�����Ĵ��������ֶ�ɾ������
$ grep 8118 -r /etc/yum*
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

#### 6.1.5�����þ��������������֤��

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
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."192.168.200.116:5080"]
          endpoint = ["https://192.168.200.116:5443"]
      [plugins."io.containerd.grpc.v1.cri".registry.configs]
        [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.200.116:5443".tls]
          insecure_skip_verify = true
        [plugins."io.containerd.grpc.v1.cri".registry.configs."192.168.200.116:5443".auth]
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
# ��ѯָ����ǩ��pod
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
$ systemctl enable docker && systemctl restart docker
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
$ mkdir -p /usr/local/dockerv/harbor_home
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
hostname: 192.168.200.116
# �޸�
  # port: 80
  port: 5080
# �޸�
https:
  # https port for harbor, default is 443
  port: 5443
  # The path of cert and key files for nginx
  # certificate: /your/certificate/path
  # private_key: /your/private/key/path
  # �޸ģ�ע�⣬���ﲻ��ʹ��������Ŀ¼ /usr/loca/harbor�滻/usr/local/Harbor/harbor-2.2.4
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
$ docker tag openjdk:8-jre 192.168.200.116:5080/devops-learning/openjdk:8-jre
# ��¼
$ docker login -u emon -p Emon@123 192.168.200.116:5080
# �ϴ�����
$ docker push 192.168.200.116:5080/devops-learning/openjdk:8-jre
# �˳���¼
$ docker logout 192.168.200.116:5080

�������˻���
token��  
XsttKM4zpuFWcchUmEhJErmiRRRfBu0A
```

# ����Kubernetes�ķ�����

![image-20220403131408465](images/image-20220403131408465.png)



![image-20220407103050136](images/image-20220407103050136.png)



## 0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv k8s_soft/k8s_v1.20.2 && cd k8s_soft/k8s_v1.20.2
```

## 1����װingress-nginx

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

## 2�����Է���

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
# Ӧ����Դ����������ʹ�ã��ɵ���Ϊ create -> apply  ����ʹ�úʹ�����ʹ�õ�Ч��
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
http://api.mooc.com # ���� default backend - 404

# ɾ����Դ
$  kubectl delete -f ingress-demo.yaml
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

# �ߡ�Namespace

## 0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/1-namespace
$ cd /root/dockerdata/deep-in-kubernetes/1-namespace/
```

## 1�����������ռ�

- ����yaml

```bash
vim namespace-dev.yaml
```

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

- Ӧ��yaml

```bash
$ kubectl create -f namespace-dev.yaml
# �鿴�����ռ�
$ kubectl get namespaces
```

## 2��������������ռ�

- ����yaml

```bash
$ vim web-dev.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/springboot-web-demo:latest
        ports:
        - containerPort: 8080
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: sbt-web-demo
  type: ClusterIP

---
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
  - host: sbt-dev.emon.vip
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: sbt-web-demo
            port:
              number: 80
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl create -f web-dev.yaml
# �鿴dev�����ռ�������
$ kubectl get all -n dev
# �鿴deploy����
$ kubectl get deploy sbt-web-demo -o yaml -n dev
```

## 3�������ռ�����

### 3.1�������ռ���ͨ���������ķ��ʹ���

- ͬһ�������ռ��µ�podͨ�����������Ի������
- ��ͬ�����ռ��µ�podͨ�������������Ի������

```bash
$ kubectl get pods -o wide
NAME                                      READY   STATUS    RESTARTS   AGE   IP               NODE    NOMINATED NODE   READINESS GATES
k8s-springboot-web-demo-7689b896d-pz9mh   1/1     Running   0          71m   10.200.108.119   emon2   <none>           <none>
tomcat-demo-54cbbcffdb-z9jl5              1/1     Running   0          22m   10.200.161.18    emon3   <none>           <none>

$ kubectl get pods -n dev
NAME                            READY   STATUS    RESTARTS   AGE
sbt-web-demo-756b64bb8b-qqp5x   1/1     Running   0          26m

# �鿴����������ע�� search default.svc.cluster.local �� search dev.svc.cluster.local ������
$ kubectl exec -it k8s-springboot-web-demo-7689b896d-pz9mh -- cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.25.10
options ndots:5
$ kubectl exec -it sbt-web-demo-756b64bb8b-qqp5x -n dev -- cat /etc/resolv.conf
search dev.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.25.10
options ndots:5
```

### 3.2�������ռ���ͨ��IP�ķ��ʹ���

- ��ͬ�����ռ��µ�service��podͨ��IP�ǿ��Ի������

```bash
$ kubectl get svc
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
k8s-springboot-web-demo   ClusterIP   10.233.31.78    <none>        80/TCP    11h
kubernetes                ClusterIP   10.233.0.1      <none>        443/TCP   3d22h
tomcat-demo               ClusterIP   10.233.60.100   <none>        80/TCP    14m
$ kubectl get svc -n dev
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
sbt-web-demo   ClusterIP   10.233.175.91   <none>        80/TCP    29m

# dev�����ռ���pod���Է���default�����ռ��µ�tomcat-demo����IP��ͨ��
$ kubectl exec -it sbt-web-demo-756b64bb8b-qqp5x bash -n dev
# dev�����ռ���pod����default�����ռ��µ�tomcat-demo��pods��IPҲͨ
root@sbt-web-demo-756b64bb8b-qqp5x:/# wget 10.233.60.100
root@sbt-web-demo-756b64bb8b-qqp5x:/# wget 10.200.161.18:8080
```

## 4�������û���Ĭ�������ռ�

- ����`.kube/config`

```bash
$ cp .kube/config .kube/config.bak
```

- ����admin�û���Ĭ�������ռ�

```bash
# ���������Ĳ�����д�벢�����ļ�
$ kubectl config set-context ctx-dev \
  --cluster=kubernetes \
  --user=admin \
  --namespace=dev \
  --kubeconfig=/root/.kube/config
# ����Ĭ��������
$ kubectl config use-context ctx-dev --kubeconfig=/root/.kube/config

# ��ԭ
$ cp .kube/config.bak .kube/config
$ kubectl config use-context default --kubeconfig=/root/.kube/config


# �鿴��ǰĬ�������ռ�
$ kubectl config get-contexts
CURRENT   NAME      CLUSTER      AUTHINFO   NAMESPACE
*         default   kubernetes   admin 
```

## 5�������ռ仮�ַ�ʽ

- ���������֣�dev��test��prod
- ���Ŷӻ���
- �Զ���༶����
  - ��һ��������
  - �ڶ������Ŷ�

# �ˡ�Resources

## 0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/2-resource
$ cd /root/dockerdata/deep-in-kubernetes/2-resource
```

## 1����ʶ

- CPU
- GPU
- �ڴ�
- �־û��洢

![image-20220409111711111](images/image-20220409111711111.png)



## 2���������

- Requests���������Դ
- Limits�����Ƶ���Դ

## 3���������

- ����һ������

```bash
$ vim web-dev.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: 100Mi
            # 1���ĵ�CPU=1000m
            cpu: 100m
          limits:
            memory: 100Mi
            cpu: 200m
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: sbt-web-demo
  type: ClusterIP

---
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
  - host: sbt-dev.emon.vip
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: sbt-web-demo
            port:
              number: 80
```

- ����

```bash
$ kubectl apply -f web-dev.yaml
# �鿴dev�����ռ�������
$ kubectl get all -n dev
# �鿴nodes
$ kubectl get nodes -n dev
# �鿴�ڵ��Ͽ�����Դ
$ kubectl describe node emon2 -n dev
```

## 4��Requests&Limits�������밲ȫ�ȼ�

- Requests==Limits����ȫ�ȼ����
- �����ã������飩
- Limits > Requests���ȽϿɿ�

### 4.0������test�����ռ�������ʾ

```bash
$ kubectl create ns test
```

### 4.1������LimitRange������Pod��Container���ڴ��CPU

- ����LimitRange

```bash
$ vim limits-test.yaml
```

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: test-limits
spec:
  limits:
    - max:
        cpu: 4000m
        memory: 2Gi
      min:
        cpu: 100m
        memory: 100Mi
      maxLimitRequestRatio:
        cpu: 3
        memory: 2
      type: Pod
    - default:
        cpu: 300m
        memory: 200Mi
      defaultRequest:
        cpu: 200m
        memory: 100Mi
      max:
        cpu: 2000m
        memory: 1Gi
      min:
        cpu: 100m
        memory: 100Mi
      maxLimitRequestRatio:
        cpu: 5
        memory: 4
      type: Container
```

- Ӧ��LimitRange

```bash
$ kubectl create -f limits-test.yaml -n test
# �鿴test�����ռ��µ�limits
$ kubectl describe limits -n test
Name:       test-limits
Namespace:  test
Type        Resource  Min    Max  Default Request  Default Limit  Max Limit/Request Ratio
----        --------  ---    ---  ---------------  -------------  -----------------------
Pod         memory    100Mi  2Gi  -                -              2
Pod         cpu       100m   4    -                -              3
Container   cpu       100m   2    200m             300m           5
Container   memory    100Mi  1Gi  100Mi            200Mi          4
```

### 4.2������LimitRange

- ����һ������

```bash
$ vim web-test.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: test
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
        ports:
        - containerPort: 8080
```

- ����

```bash
$ kubectl apply -f web-test.yaml
# �鿴dev�����ռ�������
$ kubectl get all -n test
# �鿴����
$ kubectl get deploy -n test
# �鿴��������
$ kubectl get deploy -n test sbt-web-demo -o yaml
# �鿴pods����
$ kubectl get pods -n test sbt-web-demo-756b64bb8b-pmvmd -o yaml
```

- ����������Դ

```bash
$ vim web-test.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: test
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
        ports:
        - containerPort: 8080
        # LimitRange�����޶�
        resources:
          requests:
            memory: 100Mi
            # 1���ĵ�CPU=1000m
            cpu: 100m
          limits:
            memory: 1000Mi
            cpu: 2000m
```

- ˢ�²���

```bash
$ kubectl apply -f web-test.yaml
# �鿴dev�����ռ�������
$ kubectl get all -n test
# �鿴����
$ kubectl get deploy -n test
# �鿴����״̬
$ kubectl describe deploy -n test sbt-web-demo
# �鿴�������飺���Կ��� message: 'pods "sbt-web-demo-dcc47d586-7wwbz" is forbidden: 
$ kubectl get deploy -n test sbt-web-demo -o yaml
# �鿴pods����
$ kubectl get pods -n test sbt-web-demo-756b64bb8b-pmvmd -o yaml
```



### 4.3������ResourceQuota������������Դ����

#### 4.3.1������pod�Լ�CPU���ڴ������

- ����pod�Լ�CPU���ڴ������

```bash
$ vim compute-resource.yaml
```

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota
spec:
  hard:
    pods: 4
    requests.cpu: 2000m
    requests.memory: 4Gi
    limits.cpu: 4000m
    limits.memory: 8Gi
```

#### 4.3.2������������Դ�����

- ����������Դ�����

```bash
$ vim object-count.yaml
```

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-counts
spec:
  hard:
    configmaps: 10
    persistentvolumeclaims: 4
    replicationcontrollers: 20
    secrets: 10
    services: 10
```

#### 4.3.3��Ӧ����鿴���

```bash
$ kubectl apply -f compute-resource.yaml -n test
$ kubectl apply -f object-count.yaml -n test

$ kubectl get quota -n test
NAME             AGE   REQUEST                                                                                                      LIMIT
object-counts    77s   configmaps: 1/10, persistentvolumeclaims: 0/4, replicationcontrollers: 0/20, secrets: 1/10, services: 0/10   
resource-quota   83s   pods: 1/4, requests.cpu: 1/2, requests.memory: 500Mi/4Gi                                                     limits.cpu: 2/4, limits.memory: 1000Mi/8Gi
```

### 4.4������ResourceQuota

- ����һ������

```bash
$ vim web-test.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: test
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 5
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: 100Mi
            # 1���ĵ�CPU=1000m
            cpu: 100m
          limits:
            memory: 100Mi
            cpu: 200m
```

- ����

```bash
$ kubectl apply -f web-test.yaml
# �鿴����
$ kubectl get deploy -n test
# �鿴��������
$ kubectl get deploy -n test sbt-web-demo -o yaml
# �鿴quota
$ kubectl describe quota resource-quota -n test
Name:            resource-quota
Namespace:       test
Resource         Used    Hard
--------         ----    ----
limits.cpu       2600m   4
limits.memory    1300Mi  8Gi
pods             4       4
requests.cpu     1300m   2
requests.memory  800Mi   4Gi
```

## 4.5��Pod���� - Eviction

### 4.5.1�����������������

```bash
# ����ڴ�С��1.5Gi�ҳ���1m30s����
--eviction-soft=memory.availabel<1.5Gi
--eviction-soft-grace-period=memory.availabel=1m30s
# ����ڴ�С��100Mi���ߴ���С��1Gi����inodes����5%����������
--eviction-hard=memory.availabel<100Mi,nodefs.availabel<1Gi,nodefs.inodesFree<5%
```

- ���̽�ȱʱ�����߼�

  - ɾ��������pod������

  - ɾ��û�õľ���
  - �����ȼ�����Դռ���������pod

- �ڴ��ȱ

  - ���𲻿ɿ���pod
  - ��������ɿ���pod
  - ����ɿ���pod

# �š�Label

![image-20220409152210334](images/image-20220409152210334.png)



## 9.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/3-label
$ cd /root/dockerdata/deep-in-kubernetes/3-label
```



## 9.1����ʾ��ǩ������

- ����һ������

```bash
$ vim web-dev.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      # �� deployֻ������б�ǩ app=sbt-web-demo ��ǩ��pod
      app: sbt-web-demo
    matchExpressions:
      - {key: group, operator: In, values: [dev, test]}
  replicas: 1
  # �� deploy �����������ô���pod
  template:
    metadata:
      labels:
        group: dev
        app: sbt-web-demo
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
        ports:
        - containerPort: 8080
      # ѡ��ָ�� node ����� pod
      nodeSelector:
        disktype: ssd
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  ports:
  # service�˿ڣ���k8s�з���֮��ķ��ʶ˿�
  - port: 80
    protocol: TCP
    # pod ��Ҳ�����������˿�
    targetPort: 8080
  selector:
    # ���� app=sbt-web-demo ��ǩ��pod
    app: sbt-web-demo
  type: ClusterIP

---
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
  - host: sbt-dev.emon.vip
    http:
      paths:
      - path: /
        # ƥ�����ͣ�Prefix-ǰ׺ƥ�䣬����Exact-��ȷƥ��
        pathType: Prefix
        backend:
          service: 
            name: sbt-web-demo
            port:
              number: 80
```

- ����

```bash
$ kubectl apply -f web-dev.yaml
# ���ݱ�ǩ����pod
$ kubectl get pods -l group=dev -n dev
```

# ʮ��������顪���߿��õ��ػ���

## 10.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/4-health-check
$ cd /root/dockerdata/deep-in-kubernetes/4-health-check
```

## 10.1��CMD��ʽ��SpringBoot�����á�

- ���������ļ�

```bash
$ vim web-dev-cmd.yaml
```

```bash
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
        - name: sbt-web-demo
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
          # ���״̬���
          livenessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - ps -ef|grep java|grep -v grep
            # pod ����10s��������һ��̽��
            initialDelaySeconds: 10
            # ÿ��10s����һ��̽��
            periodSeconds: 10
            # ��ʱʱ��3s
            timeoutSeconds: 3
            # �ɹ�1�μ���ʾ��������
            successThreshold: 1
            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
            failureThreshold: 5
```



## 10.2��HTTP��ʽ

- ���������ļ�

```bash
$ vim web-dev-http.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
        - name: sbt-web-demo
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
          # ���״̬���
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
              scheme: HTTP
            # pod ����10s��������һ��̽��
            initialDelaySeconds: 10
            # ÿ��10s����һ��̽��
            periodSeconds: 10
            # ��ʱʱ��3s
            timeoutSeconds: 3
            # �ɹ�1�μ���ʾ��������
            successThreshold: 1
            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
            failureThreshold: 5
          # ����״̬���
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8080
			  scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 3
```

- ����

```bash
$ kubectl apply -f web-dev-cmd.yaml
# �鿴pods�б�
$ kubectl get pods -o wide -n dev
# �鿴pods���飺����Liveness �� Readiness
$ kubectl describe pods sbt-web-demo-7cfcdddcc5-7ht6x -n dev
```

## 10.3��TCP��ʽ��SpringBoot�����á�

- ���������ļ�

```bash
$ vim web-dev-tcp.yaml
```

```bash
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
        - name: sbt-web-demo
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
          # ���״̬���
          livenessProbe:
            tcpSocket:
              port: 8080
            # pod ����10s��������һ��̽��
            initialDelaySeconds: 10
            # ÿ��10s����һ��̽��
            periodSeconds: 10
            # ��ʱʱ��3s
            timeoutSeconds: 3
            # �ɹ�1�μ���ʾ��������
            successThreshold: 1
            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
            failureThreshold: 5
```

# ʮһ��Scheduler

![image-20220410073524383](images/image-20220410073524383.png)

## 11.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/5-scheduler
$ cd /root/dockerdata/deep-in-kubernetes/5-scheduler
```

## 11.1���ڵ����

- ���������ļ�

```bash
$ vim web-dev-node.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo-node
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo-node
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo-node
    spec:
      containers:
        - name: sbt-web-demo-node
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
      # �׺���
      affinity:
        # �ڵ��׺���
        nodeAffinity:
          # ��������
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: beta.kubernetes.io/arch
                    operator: In
                    values:
                      - amd64
          # �������
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 1
              preference:
                matchExpressions:
                  - key: disktype
                    operator: NotIn
                    values:
                      - ssd
```

- ����

```bash
# �鿴�ڵ��ǩ���飺����emon2���� disktype=ssd ��ǩ
$ kubectl get node --show-labels
NAME    STATUS   ROLES    AGE     VERSION   LABELS
emon2   Ready    <none>   4d19h   v1.20.2   app=ingress,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/arch=amd64,kubernetes.io/hostname=emon2,kubernetes.io/os=linux
emon3   Ready    <none>   4d19h   v1.20.2   app=ingress,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=emon3,kubernetes.io/os=linux

$ kubectl apply -f web-dev-node.yaml
# �鿴pod���𵽵Ľڵ㣺����pod������emon3�ڵ�
$ kubectl get pods -o wide -n dev
# ������������
NAME                                 READY   STATUS    RESTARTS   AGE     IP              NODE    NOMINATED NODE   READINESS GATES
sbt-web-demo-node-74bdc75d4f-mhrfw   1/1     Running   0          1s      10.200.161.23   emon3   <none>           <none>
```

## 11.2��pod����

- ���������ļ�

```bash
$ vim web-dev-pod.yaml
```

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo-pod
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo-pod
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo-pod
    spec:
      containers:
        - name: sbt-web-demo-pod
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
      # �׺���
      affinity:
        # pod�׺��ԣ�podAntiAffinity-���׺���
        podAffinity:
          # �������㣺���pod��app=sbt-web-demo��pod������ͬһ���ڵ���
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - sbt-web-demo
              topologyKey: kubernetes.io/hostname
          # �������
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - sbt-web-demo-node
                topologyKey: kubernetes.io/hostname
```

- ����

```bash
$ kubectl apply -f web-dev-pod.yaml
# �鿴pod���𵽵Ľڵ㣺����pod������emon2�ڵ㣬��Ϊsbt-web-demo���podҲ��emon2�ڵ�
$ kubectl get pods -o wide -n dev
# ������������
NAME                                 READY   STATUS    RESTARTS   AGE   IP              NODE    NOMINATED NODE   READINESS GATES
sbt-web-demo-7cfcdddcc5-ll89j        1/1     Running   0          8h    10.200.108.73   emon2   <none>           <none>
sbt-web-demo-node-74bdc75d4f-srf9f   1/1     Running   0          6m    10.200.161.24   emon3   <none>           <none>
sbt-web-demo-pod-cd78fb5cf-sglbj     1/1     Running   0          3s    10.200.108.75   emon2   <none>           <none>
```

## 11.3��taint���ȣ��۵㣩

- ���������ļ�

```bash
$ vim web-dev-taint.yaml
```

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo-taint
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo-taint
  replicas: 2
  template:
    metadata:
      labels:
        app: sbt-web-demo-taint
    spec:
      containers:
        - name: sbt-web-demo-taint
          image: 192.168.200.116:5080/devops-learning/k8s-springboot-web-demo:latest
          ports:
            - containerPort: 8080
      tolerations:
        - key: "gpu"
          operator: "Equal"
          value: "true"
          effect: "NoSchedule"
```

- ����

```bash
# ��ӽڵ���۵㣺NoSchedule-��Ҫ���ȣ�PreferNoSchedule-��ò�Ҫ���ȣ�NoExecute-��Ҫ���ȣ�������ýڵ��ϵ�pod
$ kubectl taint nodes emon3 gpu=true:NoSchedule

$ kubectl apply -f web-dev-taint.yaml
# �鿴pod���𵽵Ľڵ㣺��Ȼemon3���۵㣬������2��pod����������emon3�ˣ�����ѡ��������
$ kubectl get pods -o wide -n dev
$  kubectl get pods -o wide -n dev
NAME                                  READY   STATUS    RESTARTS   AGE     IP              NODE    NOMINATED NODE   READINESS GATES
sbt-web-demo-taint-7d69cf4fff-pq8pf   1/1     Running   0          5s      10.200.108.83   emon2   <none>           <none>
sbt-web-demo-taint-7d69cf4fff-t95cx   1/1     Running   0          5s      10.200.161.33   emon3   <none>           <none>
```

# ʮ�����������ʵ��

## 12.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/6-deployment
$ cd /root/dockerdata/deep-in-kubernetes/6-deployment
```

## 12.1����������RollingUpdate���������¡�Ĭ�Ϸ�ʽ��

- ���������ļ�

```bash
$ vim web-rollingupdate.yaml
```

```bash
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-rollingupdate
  namespace: dev
spec:
  strategy: # Ĭ�ϲ�����RollingUpdate������������ maxSurge:25%�� maxUnavailable:25%
    rollingUpdate:
      # ��󳬳�����ʵ�����İٷֱȣ������4������25%��ʾ���ֻ�ܳ���1��ʾ����Ҳ����������Ϊ���֣�����1��ʾ���1������
      maxSurge: 25%
      # ��󲻿��÷���ʵ�����İٷֱȣ������4������������3���ǿ��õ�
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: sbt-web-rollingupdate
  replicas: 2
  template:
    metadata:
      labels:
        app: sbt-web-rollingupdate
    spec:
      containers:
        - name: sbt-web-rollingupdate
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:latest
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: 1024Mi
              cpu: 500m
            limits:
              memory: 2048Mi
              cpu: 2000m
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 5
          readinessProbe:
            httpGet:
              path: /hello?name=test
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 1
            successThreshold: 1
            timeoutSeconds: 5
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-rollingupdate
  namespace: dev
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: sbt-web-rollingupdate
  type: ClusterIP

---
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-rollingupdate
  namespace: dev
spec:
  rules:
    - host: sbt-web-rollingupdate.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-rollingupdate
                port:
                  number: 80
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-web-rollingupdate.emon.vip/hello?name=emon
```bash
$ kubectl apply -f web-rollingupdate.yaml
# �鿴pods
$ kubectl get pods -o wide -n dev
# ��ͣ����
$ kubectl rollout pause deploy sbt-web-rollingupdate -n dev
# �ָ�����
$ kubectl rollout resume deploy sbt-web-rollingupdate -n dev
# �ع�����
$ kubectl rollout undo deploy sbt-web-rollingupdate -n dev
```

## 12.2���ؽ�����Recreate��ʹ�ó������ࡿ

- ���������ļ�

```bash
$ vim web-recreate.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-recreate
  namespace: dev
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: sbt-web-recreate
  replicas: 2
  template:
    metadata:
      labels:
        app: sbt-web-recreate
    spec:
      containers:
        - name: sbt-web-recreate
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:latest
          ports:
            - containerPort: 8080
          # ���״̬���
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 8080
              scheme: HTTP
            # pod ����10s��������һ��̽��
            initialDelaySeconds: 10
            # ÿ��10s����һ��̽��
            periodSeconds: 10
            # ��ʱʱ��3s
            timeoutSeconds: 3
            # �ɹ�1�μ���ʾ��������
            successThreshold: 1
            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
            failureThreshold: 5
          # ����״̬���
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 8080
			  scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 3
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-recreate
  namespace: dev
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: sbt-web-recreate
  type: ClusterIP

---
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-recreate
  namespace: dev
spec:
  rules:
    - host: sbt-web-recreate.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-recreate
                port:
                  number: 80
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-web-recreate.emon.vip/hello?name=emon

```bash
$ kubectl apply -f web-recreate.yaml
# �鿴pods
$ kubectl get pods -o wide -n dev
```

## 12.3�����̲���

### 12.3.1������V1�汾

- ���������ļ�

```bash
$ vim web-bluegreen.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-bluegreen-v1.0
  namespace: dev
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: sbt-web-bluegreen
  replicas: 2
  template:
    metadata:
      labels:
        app: sbt-web-bluegreen
        version: v1.0
    spec:
      containers:
        - name: sbt-web-bluegreen
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v1.0
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: 1024Mi
              cpu: 500m
            limits:
              memory: 2048Mi
              cpu: 2000m
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 5
          readinessProbe:
            httpGet:
              path: /hello?name=test
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 1
            successThreshold: 1
            timeoutSeconds: 5
```

- ����service�ļ�

```bash
$ vim bluegreen-service.yaml
```

```yaml
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-bluegreen
  namespace: dev
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: sbt-web-bluegreen
    version: v1.0
  type: ClusterIP

---
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-bluegreen
  namespace: dev
spec:
  rules:
    - host: sbt-web-bluegreen.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-bluegreen
                port:
                  number: 80
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-web-bluegreen.emon.vip/hello?name=emon
```bash
$ kubectl apply -f web-bluegreen.yaml
$ kubectl apply -f bluegreen-service.yaml
```

### 12.3.2������V2�汾

- ���������ļ�

```bash
# �޸�V1�汾�����ط�
$ vim web-bluegreen.yaml
```

```bash
# ��һ����Deployment����
name: sbt-web-bluegreen-v1.0 
==> 
name: sbt-web-bluegreen-v2.0
# �ڶ��Σ�Pod��ǩ
version: v2.0
# �����Σ�����汾
image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v1.0
==>
image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v2.0
```

- ����service�ļ�

```bash
# �޸�V1�汾�����ط�
$ vim bluegreen-service.yaml
```

```bash
# ��һ����ƥ���pod�汾
version: v1.0
==>
version: v2.0
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-web-bluegreen.emon.vip/hello?name=emon

```bash
$ kubectl apply -f web-bluegreen.yaml
$ kubectl apply -f bluegreen-service.yaml
```

## 12.4����˿ȸ

�����̲�������ϣ�����service�ļ���ȥ��version: v2.0��ǩ�����·���service���õ��Ľ�����ǽ�˿ȸ����������

# ʮ��������Pod��δ�������

## 13.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/7-pod
$ cd /root/dockerdata/deep-in-kubernetes/7-pod
```

## 13.1�����˼��

- Pod����С���ȵ�λ
- ���ʻ��������ĸ���
- Pause����

# 13.2��network

- ���������ļ�

```bash
$ vim pod-network.yaml
```

```yaml
 apiVersion: v1
kind: Pod
metadata:
  name: pod-network
spec:
  containers:
    - name: sbt-v1
      image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v1.0
      ports:
        - containerPort: 8080
    - name: sbt-v2
      image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v2.0
      args: [ "--server.port=8081" ]
      ports:
        - containerPort: 8081
```

- ����

```bash
$ kubectl apply -f pod-network.yaml
$ kubectl get pods -o wide
```

# ʮ�ġ�����Ingress-Nginx

## 14.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/8-ingress
$ cd /root/dockerdata/deep-in-kubernetes/8-ingress
```

## 14.1�����°�װIngress-Nginx������Ingress-Nginx��

��װ��ʽ��DaemonSet

��װ�汾��0.23.0

- ��װ֮ǰɾ���ɵ�Ingress-Nginx

```bash
# ���ص㡿����ɾ��mandatory.yaml��Ӧ����Դ
$ kubectl delete -f mandatory.yaml
```

- ����mandatory.yaml

```bash
# Ȼ����ڵ����£�����2��
$ vim /root/dockerdata/deep-in-kubernetes/8-ingress/mandatory.yaml
```

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
# ��һ�������� Deployment ==> DaemonSet
kind: DaemonSet
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
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
          # �ڶ��������� 0.19.0 ==> 0.23.0
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0
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

- ����

```bash
$  kubectl apply -f mandatory.yaml

# �鿴deploy�Ĳ�����Ϣ
$ kubectl get ds -n ingress-nginx
# �鿴pods
$ kubectl get pods -n ingress-nginx -o wide
# ��ȡ ConfigMap �����б�
$ kubectl get cm -n ingress-nginx
# ������������
NAME                              DATA   AGE
ingress-controller-leader-nginx   0      3d21h
kube-root-ca.crt                  1      3d21h
nginx-configuration               0      3d21h
tcp-services                      1      3d21h
udp-services                      0      3d21h
# ��ȡ ConfigMap �����������
$ kubectl get cm -n ingress-nginx tcp-services
# ��ȡ ConfigMap �������������yaml��ʽ
$ kubectl get cm -n ingress-nginx tcp-services -o yaml
```

## 14.2���Ĳ����(��Ӧcm=tcp-services��

- ���������ļ�

```bash
$ vim tcp-config.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
# ����Ҫ��¶�Ĳ����ķ���  
data:
  "30000": dev/sbt-web-demo:80
```

- ����

�������ɹ����ɷ��ʣ�

http://sbt-web-bluegreen.emon.vip/hello?name=emon

http://sbt-web-bluegreen.emon.vip:30000/hello?name=emon

```bash
# =====��master�ڵ����ڷ�����=====
$ kubectl apply -f tcp-config.yaml
# �鿴�����yaml����
$ kubectl get svc -n dev sbt-web-demo -o yaml

# =====�� nginx-ingress-controller �ڵ����ڷ�����=====
# �鿴 nginx-ingress-controller ���ڷ������Ƿ���30000�˿ڱ�¶����
$ netstat -tnlp|grep 30000

# �鿴 nginx-ingress-controller ����ID
$ crictl ps|grep nginx-ingress-controller 
# ���� nginx-ingress-controller ����
$ crictl exec -it <containerId> /bin/bash
# �鿴��������nginxʵ�������ļ�λ��Ϊ /etc/nginx/nginx.conf
www-data@emon3:/etc/nginx$ more /etc/nginx/nginx.conf
```

## 14.3��Ingress-Nginx�����ļ�

### 14.3.1������ר��������ʾ

- ���������ļ�

data�Ŀ������²ο���https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/

```bash
$ vim nginx-config.yaml
```

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app: ingress-nginx
data:
  proxy-body-size: "64m"
  proxy-read-timeout: "180"
  proxy-send-timeout: "180"
```

- ����

```bash
# ���ú���� nginx-ingress-controller �����ж�Ӧ��nginx�����ļ��鿴��
$ kubectl apply -f nginx-config.yaml
```

### 14.3.2��ȫ������

- ���������ļ�

```bash
$ vim custom-header-global.yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
data:
  # ingress-nginx/custom-headers:��ʾ�� ingress-nginx ���������Ϊ custom-headers ����������������Ϊheader����
  proxy-set-headers: "ingress-nginx/custom-headers"
metadata:
  name: nginx-configuration
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
---
apiVersion: v1
kind: ConfigMap
data:
  X-Different-Name: "true"
  X-Request-Start: t=${msec}
  X-Using-Nginx-Controller: "true"
metadata:
  name: custom-headers
  namespace: ingress-nginx
```

- ����

```bash
$ kubectl apply -f custom-header-global.yaml
```

### 14.3.3��ר������

- ���������ļ�

```bash
$ vim custom-header-spec-ingress.yaml
```

```yaml
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "Request-Id: $req_id";
  name: sbt-web-demo
  namespace: dev
# �����ý��� sbt-dev.emon.vip ����Ч
spec:
  rules:
    - host: sbt-dev.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-demo
                port:
                  number: 80
```

- ����

```bash
$ kubectl apply -f custom-header-spec-ingress.yaml
```

### 14.3.4���Զ���Nginxģ�壨����Ingress-Nginx��

�ο���https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/custom-template/

- ����mandatory.yaml

```bash
# Ȼ����� 14.1 ������2��
$ vim /root/dockerdata/deep-in-kubernetes/8-ingress/mandatory.yaml
```

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
kind: DaemonSet
metadata:
  name: nginx-ingress-controller
  namespace: ingress-nginx
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
spec:
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
	  # ��һ�������� Deployment ==> DaemonSet
      volumes:
        - name: nginx-template-volume
          configMap:
            name: nginx-template
            items:
            - key: nginx.tmpl
              path: nginx.tmpl
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.23.0
          # �ڶ��������� volumeMounts
          volumeMounts:
            - mountPath: /etc/nginx/template
              name: nginx-template-volume
              readOnly: true
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

- ����֮ǰ�ȴ���ConfigMap

```bash
# �鿴 nginx-ingress-controller ��pods
$ kubectl get pods -n ingress-nginx|grep nginx-ingress-controller
# ������������
nginx-ingress-controller-68tms          1/1     Running   0          49m

# �������п��������������������ļ�
$ kubectl cp nginx-ingress-controller-68tms:/etc/nginx/template/nginx.tmpl -n ingress-nginx nginx.tmpl

# ����ConfigMap
$ kubectl create cm nginx-template --from-file nginx.tmpl -n ingress-nginx
# �鿴ConfigMap
$ kubectl get cm -n ingress-nginx nginx-template
# �鿴ConfigMap��yaml����
$ kubectl get cm -n ingress-nginx nginx-template -o yaml
```

- ����

```bash
# ʹ������Ч
$ kubectl apply -f mandatory.yaml
# �鿴deploy�Ĳ�����Ϣ
$ kubectl get ds -n ingress-nginx
# �鿴pods
$ kubectl get pods -n ingress-nginx -o wide

# �޸� ConfigMap ����
$ kubectl edit cm -n ingress-nginx nginx-template
# ���������� types_hash_max_size ��ֵΪ 4096

# ���� nginx-ingress-controller ���pods�������������
$ kubectl get pods -n ingress-nginx -o wide|grep nginx-ingress-controller
# ������������
nginx-ingress-controller-mswq2          1/1     Running   0          96s

# ���������鿴
$ kubectl exec -it nginx-ingress-controller-mswq2 -n ingress-nginx -- bash
# �������ڲ鿴 types_hash_max_size ��ֵ�Ƿ���ȷ����֤�õ�4096������������nginx.tmpl���䣬�мǣ����֣�
www-data@emon3:/etc/nginx$ more /etc/nginx/template/nginx.tmpl 
```

## 14.4��Https֤�飺����tls������Ingress-Nginx��

### 14.4.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/8-ingress/tls
$ cd /root/dockerdata/deep-in-kubernetes/8-ingress/tls
```

### 14.4.1������tls����֤

- ����֤��

```bash
$ openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout emon.key -out emon.crt \
-subj "/C=CN/ST=ZheJiang/L=HangZhou/O=HangZhou emon Technologies,Inc./OU=IT emon/CN=*.emon.vip"
```

- ����secret

```bash
$ kubectl create secret tls emon-tls --key emon.key --cert emon.crt -n dev
# �鿴secret
$ kubectl get secret emon-tls -n dev
$ kubectl get secret emon-tls -o yaml -n dev
```

- ����֤�飬����mandatory.yaml

```bash
# Ȼ����� 14.3.4 ������1��
$ vim /root/dockerdata/deep-in-kubernetes/8-ingress/mandatory.yaml
```

```yaml
# ��һ�����������ָ��֤��
            - --annotations-prefix=nginx.ingress.kubernetes.io
            - --default-ssl-certificate=dev/emon-tls
```

- ����Ingress

```bash
$ vim web-ingress.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
    - host: sbt-dev.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-demo
                port:
                  number: 80
  tls:
    - hosts:
        - sbt-dev.emon.vip
      secretName: emon-tls
```

- ����

�������ɹ����ɷ��ʣ�

https://sbt-dev.emon.vip/hello?name=emon

```bash
# ����Ingress
$ kubectl apply -f web-ingress.yaml
$ kubectl apply -f ../nginx-ingress-controller.yaml

# �鿴deploy�Ĳ�����Ϣ
$ kubectl get ds -n ingress-nginx
# �鿴pods
$ kubectl get pods -n ingress-nginx -o wide
```

## 14.5��Session����

### 14.5.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/8-ingress/session
$ cd /root/dockerdata/deep-in-kubernetes/8-ingress/session
```

### 14.5.1����汾����׼��

Ŀ�꣺һ���������ʵ�pods�ж��֣��õ��Ľ��Ҳ�ж��֣�����

- ����yaml

```bash
$ vim web-dev.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo-v1
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
        version: v1.0
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v1.0
        ports:
        - containerPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo-v2
  namespace: dev
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
        version: v1.0
    spec:
      containers:
      - name: sbt-web-demo
        image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v2.0
        ports:
        - containerPort: 8080
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: sbt-web-demo
  type: ClusterIP

---
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
  - host: sbt-dev.emon.vip
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: sbt-web-demo
            port:
              number: 80
  tls:
    - hosts:
        - sbt-dev.emon.vip
      secretName: emon-tls
```

- ����

�������ɹ����ɷ��ʣ�

https://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl apply -f web-dev.yaml
# �鿴dev�����ռ�������
$ kubectl get all -n dev
# �鿴deploy����
$ kubectl get deploy sbt-web-demo -o yaml -n dev
```

- ˵��

������̨����汾��һ�£�����ʱ�ᷴ�����ֲ�ͬ�����ݣ�
https://sbt-dev.emon.vip/hello?name=emon

### 14.5.2�������session���֣�

- ����Ingress�ļ�

```bash
$ vim ingress-session.yaml
```

```yaml
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # ���ûỰ����
    nginx.ingress.kubernetes.io/affinity: cookie
    nginx.ingress.kubernetes.io/session-cookie-hash: sha1
    nginx.ingress.kubernetes.io/session-cookie-name: route
  name: sbt-web-demo
  namespace: dev
spec:
  rules:
  - host: sbt-dev.emon.vip
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: sbt-web-demo
            port:
              number: 80
  tls:
    - hosts:
        - sbt-dev.emon.vip
      secretName: emon-tls
```

- ����

����ɹ����ٴη��ʷ��ֲ��ٷ����ˣ���Ϊ���������������Ϊroute��cookie������Session������

https://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl apply -f ingress-session.yaml
```

## 14.6����������

### 14.6.0���л�Ŀ¼

```bash
$ mkdir -pv /root/dockerdata/deep-in-kubernetes/8-ingress/canary
$ cd /root/dockerdata/deep-in-kubernetes/8-ingress/canary
```

### 14.6.1����������׼��

- ����canary�����ռ�

```bash
$ kubectl create ns canary
```

- ���������ļ�A

```bash
$ vim web-canary-a.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-canary-a
  namespace: canary
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: web-canary-a
  replicas: 1
  template:
    metadata:
      labels:
        app: web-canary-a
    spec:
      containers:
        - name: web-canary-a
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v1.0
          ports:
            - containerPort: 8080
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 5
          readinessProbe:
            httpGet:
              path: /hello?name=test
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 1
            successThreshold: 1
            timeoutSeconds: 5
---
#service
apiVersion: v1
kind: Service
metadata:
  name: web-canary-a
  namespace: canary
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: web-canary-a
  type: ClusterIP
```

- ����A

```bash
$ kubectl apply -f web-canary-a.yaml
```

- ���������ļ�B

```bash
$ vim web-canary-b.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-canary-b
  namespace: canary
spec:
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  selector:
    matchLabels:
      app: web-canary-b
  replicas: 1
  template:
    metadata:
      labels:
        app: web-canary-b
    spec:
      containers:
        - name: web-canary-b
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:v2.0
          ports:
            - containerPort: 8080
          livenessProbe:
            tcpSocket:
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 5
          readinessProbe:
            httpGet:
              path: /hello?name=test
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 20
            periodSeconds: 10
            failureThreshold: 1
            successThreshold: 1
            timeoutSeconds: 5
---
#service
apiVersion: v1
kind: Service
metadata:
  name: web-canary-b
  namespace: canary
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: web-canary-b
  type: ClusterIP
```

- ����B

```yaml
$ kubectl apply -f web-canary-b.yaml
```

### 14.6.2��ingress-common.yaml

- ���������ļ�

```bash
$ vim ingress-common.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary-a
  namespace: canary
spec:
  rules:
    - host: canary.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-canary-a
                port:
                  number: 80
```

- ����

����ɹ��󣬷��ʣ�ȫ����v1.0�汾��Ӧ��

https://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl apply -f ingress-common.yaml
```

### 14.6.3������Ingress��ingress-weight.yaml

- ���������ļ�

```bash
$ vim ingress-common.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary-b
  namespace: canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "90"
spec:
  rules:
    - host: canary.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-canary-b
                port:
                  number: 80
```

- ����

����ɹ��󣬷��ʣ������д������v2.0�汾��Ӧ��

https://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl apply -f ingress-common.yaml
```

### 14.6.4�������������ƣ�ingress-cookie.yaml

- ���������ļ�

```bash
$ vim ingress-cookie.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary-b
  namespace: canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-cookie: "web-canary"
spec:
  rules:
    - host: canary.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-canary-b
                port:
                  number: 80
```

- ����

����ɹ��󣬷��ʣ�δ����cookiesʱӦ��v1.0������cookie��Ϣweb-canary=always��Ӧ��v2.0

https://sbt-dev.emon.vip/hello?name=emon

```bash
$ kubectl apply -f ingress-cookie.yaml
```

### 14.6.5�������������ƣ�ingress-header.yaml

- ���������ļ�

```bash
$ vim ingress-header.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary-b
  namespace: canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "web-canary"
spec:
  rules:
    - host: canary.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-canary-b
                port:
                  number: 80

```

- ����

����ɹ��󣬷��ʣ�δ����cookiesʱӦ��v1.0������header��Ϣweb-canary=always��Ӧ��v2.0

`curl -H 'web-canary:always' http://canary.emon.vip/hello?name=emon`

```bash
$ kubectl apply -f ingress-header.yaml
```

### 14.6.6�������������ƣ�ingress-compose.yaml

- ���������ļ�

```bash
$ vim  ingress-compose.yaml
```

```yaml
#ingress
# apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-canary-b
  namespace: canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-by-header: "web-canary"
    nginx.ingress.kubernetes.io/canary-by-cookie: "web-canary"
    nginx.ingress.kubernetes.io/canary-weight: "90"
spec:
  rules:
    - host: canary.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-canary-b
                port:
                  number: 80
```

- ����

�������ȼ���header>cookie>Ȩ��

```bash
$ kubectl apply -f ingress-compose.yaml
```

# ʮ�塢����洢��δ�������

# ʮ����StatefulSet��δ�������

# ʮ�ߡ�K8S�е���־����

�ڲ�����ɺ� ��Ȼ�������������������ǵķ����� �� �������ǲ鿴��־ȴ��һ�����鷳������ �� ����ֻ��ȥ�������в鿴�Ѿ���ӡ�õ���־ ��������Էǳ��Ĳ��Ѻ� �� ���������е���־�϶�Ҫ��ʱɾ���� �� �����������պ�ȥ���Ҷ�Ӧ����־��

Ŀǰ����������elk�Ľ������ �� ���� l ȴ�кܶ಻ͬ ������ʹ�õ��� aliyun�� log-pilot

[log-pilot �ٷ��ĵ�](https://github.com/AliyunContainerService/log-pilot) �������к���ϸ�Ľ��� �Լ� log-pilot ���ŵ㡣

[log-pilot�����ư�������](https://help.aliyun.com/document_detail/208235.html?spm=5176.21213303.J_6704733920.7.312153c9dHMU2p&scm=20140722.S_help%40%40%E6%96%87%E6%A1%A3%40%40208235.S_0%2Bos.ID_208235-RL_logDASpilot-LOC_helpmain-OR_ser-V_2-P0_0)

## 17.0���л�Ŀ¼

```bash
$ mkdir -pv /root/k8s_soft/k8s_v1.20.15
$ cd/root/k8s_soft/k8s_v1.20.15
```

## 17.1�����������ռ�

```bash
# ���� drill �����ռ䣬��ʾѵ���Ŀռ�
$ kubectl create ns drill
```

## 17.2�������ⲿES���񡾺��ԡ�

����˵���������Ⱥ���絽ES��������ֱ��÷����ʡ�ԣ�����

```bash
$ vim external-es.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-es
  namespace: drill
spec:
  ports:
  - port: 80
---
apiVersion: v1
kind: Endpoints
metadata:
  # �� svc ��ͬ������
  name: external-es
  namespace: drill
subsets:
  - addresses:
    # es �˿�
    - ip: 192.168.1.66
    # ��Ҫָ���˿ں�
    ports:
    - port: 9200
```

```bash
$ kubectl apply -f external-es.yaml
# �鿴
$ kubectl get all -n drill
```

## 17.3������log-pilot

�ٷ���֧��ES7�汾��ʹ��������¹��쾵��ʹ�á�

https://gitee.com/Rushing0711/log-pilot

���ߣ�

https://github.com/40kuai/log-pilot/tree/filebeat7.x ���Ƽ���

��Ӧ����dockerhub��heleicool/log-pilot:7.x-filebeat

���˱��ݣ�dockerhub��rushing/log-pilot:7.x-filebeat

```bash
$ vim log-pilot.yaml
```

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-pilot
  labels:
    app: log-pilot
  # �������������namespace
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: log-pilot
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: log-pilot
      annotations:
        scheduler.alpha.kubernetes.io/critical-pod: ''
    spec:
      # �Ƿ�������Master�ڵ���
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: log-pilot
        # �汾��ο�https://github.com/AliyunContainerService/log-pilot/releases
        # image: registry.cn-hangzhou.aliyuncs.com/acs/log-pilot:0.9.7-filebeat
        # image: 192.168.200.116:5080/devops-learning/log-pilot:0.9.7-filebeat-7.6.1
        # image: heleicool/log-pilot:7.x-filebeat
        image: rushing/log-pilot:7.x-filebeat
        resources:
          limits:
            memory: 500Mi
          requests:
            cpu: 200m
            memory: 200Mi
        env:
          - name: "NODE_NAME"
            valueFrom:
              fieldRef:
                fieldPath: spec.nodeName
          - name: "LOGGING_OUTPUT"
            value: "elasticsearch"
          # ��ȷ����Ⱥ��ES����ɴ�
          - name: "ELASTICSEARCH_HOSTS"
            value: "192.168.1.66:9200"
          # ����ES����Ȩ��
          #- name: "ELASTICSEARCH_USER"
          #  value: "{es_username}"
          #- name: "ELASTICSEARCH_PASSWORD"
          #  value: "{es_password}"
        volumeMounts:
        - name: sock
          mountPath: /var/run/docker.sock
        - name: root
          mountPath: /host
          readOnly: true
        - name: varlib
          mountPath: /var/lib/filebeat
        - name: varlog
          mountPath: /var/log/filebeat
        - name: localtime
          mountPath: /etc/localtime
          readOnly: true
        livenessProbe:
          failureThreshold: 3
          exec:
            command:
            - /pilot/healthz
          initialDelaySeconds: 10
          periodSeconds: 10
          successThreshold: 1
          timeoutSeconds: 2
        securityContext:
          capabilities:
            add:
            - SYS_ADMIN
      terminationGracePeriodSeconds: 30
      volumes:
      - name: sock
        hostPath:
          path: /var/run/docker.sock
      - name: root
        hostPath:
          path: /
      - name: varlib
        hostPath:
          path: /var/lib/filebeat
          type: DirectoryOrCreate
      - name: varlog
        hostPath:
          path: /var/log/filebeat
          type: DirectoryOrCreate
      - name: localtime
        hostPath:
          path: /etc/localtime
```

```bash
$ kubectl apply -f log-pilot.yaml
# �鿴
$ kubectl get po -n kube-system

# �鿴��־ȷ���Ƿ��������Ч
$ kubectl logs -f log-pilot-27p5w -n kube-system
# ������������
......ʡ��......
time="2022-04-13T13:57:53+08:00" level=debug msg="9c4e8aa84be485d59706f4dc84951324ba0500bd16d253fea8f7cc2d749ffbf9 has not log config, skip" 
```

## 17.4���������鿴��־

```bash
$ vim web-drill.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sbt-web-demo
  namespace: drill
spec:
  selector:
    matchLabels:
      app: sbt-web-demo
  replicas: 1
  template:
    metadata:
      labels:
        app: sbt-web-demo
    spec:
      containers:
        - name: sbt-web-demo
          image: 192.168.200.116:5080/devops-learning/springboot-web-demo:vlog
          ports:
            - containerPort: 8080
          env:
            # 1��stdoutΪԼ���ؼ��֣���ʾ�ɼ���׼�����־
            # 2�����ñ�׼�����־�ɼ���ES��catalina������
            - name: aliyun_logs_catalina
              value: "stdout"
            # 1�����òɼ��������ļ���־��֧��ͨ���
            # 2�����ø���־�ɼ���ES��access������
            - name: aliyun_logs_access
              value: "/home/saas/devops/k8s-demo/logs/*.log"
          # �������ļ���־·����Ҫ����emptyDir
          volumeMounts:
            - name: log-volume
              mountPath: /home/saas/devops/k8s-demo/logs
      volumes:
        - name: log-volume
          emptyDir: {}
---
#service
apiVersion: v1
kind: Service
metadata:
  name: sbt-web-demo
  namespace: drill
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8080
  selector:
    app: sbt-web-demo
  type: ClusterIP

---
#ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sbt-web-demo
  namespace: drill
spec:
  rules:
    - host: sbt-drill.emon.vip
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sbt-web-demo
                port:
                  number: 80
```

```bash
$ kubectl apply -f web-drill.yaml
# �鿴
$ kubectl get po -n drill
```

## 17.5��Kibana

- ͨ��cerebro����鿴ES��������ַ��Ҫ�滻cerebro��ַ��ES��ַ

http://192.168.1.66:9000/#/overview?host=http:%2F%2F192.168.1.66:9200

- ��Kibana��������

��Management��==>��Kibana��==>��Index Patterns��==>access-*

��Management��==>��Kibana��==>��Index Patterns��==>catalina-*

- ��Kibana�鿴

��Discover��==>��ѡ��մ�����Index Patterns���鿴

# ʮ�ˡ�K8S�еļ��kubectl top

kubectl top �ǻ������������Ҫ�������׵�������ܻ�ȡ�����ֵ��

- 1.8���ϣ����� [metrics-server](https://github.com/kubernetes-sigs/metrics-server)

0���л�Ŀ¼

```bash
$ cd
$ mkdir -pv /root/k8s_soft/k8s_v1.20.15 && cd /root/k8s_soft/k8s_v1.20.15
```



1������

```bash
$ wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.6.1/components.yaml -O metrics-server-v0.6.1.yaml

$ vim metrics-server-v0.6.1.yaml
# ����metrics-server-v0.6.1.yaml������֤��
# �ҵ� - --metric-resolution=15s ��������
- --kubelet-insecure-tls
```

2����װ

```bash
# ===== �����containerd���� =====
$ crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server:v0.6.1
$ ctr -n k8s.io i tag  registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server:v0.6.1 k8s.gcr.io/metrics-server/metrics-server:v0.6.1

# ===== �����docker���� =====
$ docker pull registry.cn-hangzhou.aliyuncs.com/emon-k8s/metrics-server:v0.6.1
$ docker tag registry.cn-hangzhou.aliyuncs.com/emon-k8s/metrics-server:v0.6.1 k8s.gcr.io/metrics-server/metrics-server:v0.6.1

$ kubectl apply -f metrics-server-v0.6.1.yaml
```

3������

```bash
# �鿴�ڵ��ʹ�����
$ kubectl top node
# �鿴pod��ʹ�����
$ kubectl top pod
# �鿴����podʹ�������--containers������ʾpod�����е�container
$ kubectl top pod nginx --containers
```





# ��ʮ��Containerdȫ������ʵ��

## 90.1��ctr�����

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

## 90.2��crictl

k8s�ṩ�Ĺ���

```bash
# �鿴crictl�������
$ crictl -h
# �鿴����
$ crictl images
# �鿴pod
$ crictl pods
```

## 90.3��kubectl

```bash
# �鿴�ͻ��˺ͷ�������汾��Ϣ
$ kubectl version
# ��group/version�ĸ�ʽ��ʾ����������֧�ֵ�API�汾
$ kubectl api-versions
# ��ʾ��Դ�ĵ���Ϣ
$ kubectl explain < xxx >
$ kubectl explain svc
$ kubectl explain svc.spec
$ kubectl explain svc

# ȡ��ȷ�϶�����Ϣ�б�
$ kubectl get < xxx >
# ��ʾnode����Ϣ
$ kubectl get nodes -o wide

# �г�namespace��Ϣ
$ kubectl get namespaces
# ������������
NAME              STATUS   AGE
default           Active   45h
kube-node-lease   Active   45h
kube-public       Active   45h
kube-system       Active   45h

# �г�deployment��Ϣ
$ kubectl get deployment -n ingress-nginx


# ȡ��ȷ�϶������ϸ��Ϣ
$ kubectl describe < xxx > < xxx >
# ����node��ϸ��Ϣ
$ kubectl describe node emon2
# ��ȡnode��Ӧyaml����
$ kubectl get node emon2 -o yaml
# �г�ĳһ��pod��ϸ��Ϣ��-nָ�������ռ�
$ kubectl describe pod ingress-nginx-admission-patch-kpnds -n ingress-nginx
# �г�ĳһ��deployment��ϸ��Ϣ
$ kubectl describe deployment ingress-nginx-controller -n ingress-nginx

# ȡ��pod��������log��Ϣ
$ kubectl logs < xxx >
$ kubectl logs nginx-ds-tbtkz

# ��������ִ��һ������
$ kubectl exec < xxx >
# ����pods
$ kubectl exec -it nginx-ingress-controller-82mlt -n ingress-nginx -- bash
# ������ֱ��ִ������
$ kubectl exec -it nginx-ds-tbtkz -- nginx -v

# �������п��������������������ļ�
$ kubectl cp nginx-ingress-controller-82mlt:/etc/nginx/template/nginx.tmpl -n ingress-nginx nginx.tmpl
# Attach��һ�������е�������
$ kubectl attach

# �鿴ĳ�������ռ�������Ϣ
$ kubectl get all -n ingress-nginx
# �鿴ĳ�������ռ���ָ��������Ϣ
$ kubectl get po,svc -n kube-system -o wide
# ������Դ
$ kubectl apply -f < xxx.yaml >
# ɾ����Դ
$ kubectl delete -f < xxx.yaml >
# ���ڵ���ǩ
$ kubectl label nodes emon2 disktype=ssd
# �鿴�ڵ��ϵı�ǩ
$ kubectl get nodes emon2 --show-labels
# �鿴���нڵ��ϵı�ǩ�б�����ǩ����
$ kubectl get nodes --show-labels
# ɾ����ǩ��ע���ǩ��������� - ��ʾɾ��
$ kubectl label node emon2 disktype-

# �鿴Ĭ�������ռ���������Դ
$ kubectl get all
# �鿴ָ�������ռ���������Դ
$ kubectl get all -n kube-system
# �鿴��Ⱥ��Կ
$ kubectl get secret -n default
# ������Կ��ע��emon.key��emon.crtҪ����
$ kubectl create secret tls emon-tls --key emon.key --cert emon.crt -n default
# ɾ����Կ
$ kubectl delete secret emon-tls -n default
# �鿴deploy��Ӧyaml����
$ kubectl get deploy k8s-springboot-web-demo -o yaml
# �༭deploy
$ kubectl edit deploy sbt-web-demo -n dev
# �鿴quota�б�
$ kubectl get quota -n test
# �鿴quota
$ kubectl describe quota resource-quota -n test
# ���ݱ�ǩ����pod
$ kubectl get pods -l group=dev -n dev
$ kubectl get pods -l 'group in (dev,test)' -n dev
# ��ѯ���������ռ��е�pods
$ kubectl get pods -A
# ��ѯ���������ռ��е�svc
$ kubectl get svc -A
# ��ѯ���������ռ��е�deploy
$ kubectl get deploy -A
# �鿴��ǰĬ�������ռ�
$ kubectl config get-contexts

# ��ӽڵ���۵㣺NoSchedule-��Ҫ���ȣ�PreferNoSchedule-��ò�Ҫ���ȣ�NoExecute-��Ҫ���ȣ�������ýڵ��ϵ�pod
$ kubectl taint nodes emon3 gpu=true:NoSchedule
# �鿴�۵�
$ kubectl describe nodes emon3
# ɾ���۵�
$ kubectl taint nodes emon3 gpu=true:NoSchedule-

# ���²���
$ kubectl replace --force -f course-service.yaml

# �鿴 DaemonSet �����б�
$ kubectl get ds -n ingress-nginx
# ���� nginx-ingress-controller ��yaml�����ļ�
$ kubectl get ds -n ingress-nginx nginx-ingress-controller -o yaml > nginx-ingress-controller.yaml

# ��ȡ ConfigMap �����б�
$ kubectl get cm -n ingress-nginx
# ��ȡ ConfigMap �����������
$ kubectl get cm -n ingress-nginx tcp-services
# ��ȡ ConfigMap �������������yaml��ʽ
$ kubectl get cm -n ingress-nginx tcp-services -o yaml
# �޸� ConfigMap ����
$ kubectl edit cm -n ingress-nginx nginx-template

# �鿴���е�api-versions
$ kubectl api-versions

# �鿴��Ⱥ״̬
kubectl version --short=true �鿴�ͻ��˼�����˳���汾��Ϣ
kubectl cluster-info �鿴��Ⱥ��Ϣ

# ������Դ����
kubectl run name --image=(������) --replicas=(������) --port=(����Ҫ��¶�Ķ˿�) --labels=(�趨�Զ����ǩ)
kubectl create -f **.yaml  ����ʽ�������ù���ʽ
kubectl apply -f **.yaml  ����ʽ�������ù���ʽ��Ҳ�����ڸ��µȣ�

# �鿴��Դ����
kubectl delete [pods/services/deployments/...] name ɾ��ָ����Դ����
kubectl delete [pods/services/deployments/...] -l key=value -n kube-system  ɾ��kube-system��ָ����ǩ����Դ����
kubectl delete [pods/services/deployments/...] --all -n kube-system ɾ��kube-system��������Դ����
kubectl delete [pods/services/deployments/...] source_name --force --grace-period=0 -n kube-system ǿ��ɾ��Terminating����Դ����
kubectl delete -f xx.yaml
kubectl apply -f xx.yaml --prune -l <labels>(һ�㲻�����ַ�ʽɾ��)
kubectl delete rs rs_name --cascade=fale(Ĭ��ɾ����������ͬʱɾ����ܿص�����Pod���󣬼���cascade=false��ֻɾ��rs)

# �鿴ingress����
$ kubectl get ing -n lishi-recruitment

# kubctl��ΰ��ļ�����������
#�﷨�� kubectl cp <some-namespace>/<some-pod>:/path /local/path
# ���������ռ��� nbms������������ nbms-admin
$ kubectl cp nbms/nbms-admin-xxxxx:/home/app/logs -c nbms-admin .
```

- iptables

```bash
# ����ͨ�� iptables-save �����ӡ����ǰ�ڵ�� iptables ����
$ iptables-save
```

## 90.4��kubeadm��μ���ڵ�

```bash
# 1. ���������µ�token:
[root@host1 flannel]# kubeadm  token create
W0514 10:44:17.973722   26813 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
38lqh5.w6csafdt0cqkxz4e
[root@host1 flannel]# kubeadm  token list
TOKEN                     TTL         EXPIRES                     USAGES                   DESCRIPTION                                                EXTRA GROUPS
38lqh5.w6csafdt0cqkxz4e   23h         2021-05-15T10:44:17+08:00   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token

# 2. ��ȡca֤��sha256����hashֵ:
[root@host1 flannel]# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
84b0d7e02994966eb529731e85809f451f81efbb802a8d2f113ac8ce42770a5d


# 3. �ڵ���뼯Ⱥ:
  kubeadm join 10.0.0.17:6443 --token 38lqh5.w6csafdt0cqkxz4e --discovery-token-ca-cert-hash sha256:84b0d7e02994966eb529731e85809f451f81efbb802a8d2f113ac8ce42770a5d
# �����Ӻ���Ӧ��ע�⵽kubectl get nodes����������������ʱ����еĴ˽ڵ㡣


# ����ķ����ȽϷ�����һ����λ��
kubeadm token create --print-join-command

# �ڶ��ַ�����
token=$(kubeadm token generate)
kubeadm token create $token --print-join-command --ttl=0	#--ttl=0,��ʾ����ʧЧ
```

## 90.5��kubeadm���ɾ���ڵ�

```bash
kubeadm reset -f
modprobe -r ipip
lsmod
rm -rf ~/.kube/
rm -rf /etc/kubernetes/
rm -rf /etc/systemd/system/kubelet.service.d
rm -rf /etc/systemd/system/kubelet.service
rm -rf /usr/bin/kube*
rm -rf /etc/cni
rm -rf /opt/cni
rm -rf /var/lib/etcd
rm -rf /var/etcd
yum clean all
yum remove kube*
```

## 90.6���鿴kubeadm���Ⱥ��֤�����ʱ��

```bash
cd /etc/kubernetes/pki/ && for i in $(ls *.crt); do echo "===== $i ====="; openssl x509 -in $i -text -noout | grep -A 3 'Validity' ; done
```



# ��ʮһ����ѧ����

## 91.1���������˼�

https://dashboard.zrj222.xyz/#/register?code=WQuqlN4W

��¼���򣬲���ȡSSЭ�飺

��¼�����˼䡰��վ -> ���˵��������ʹ���ĵ��� -> ���������С�������ȡĳ���ڵ��SS/V2��Э�����ӡ� -> ���ơ�SSЭ�顱�µ����ӵ�ַ������������д򿪣�����ʾ�����еĵ�ַ����㸴��һ����

> �����ҵģ�
> ss://Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpiZmU5NmVlNS0xZWU5LTRhN2EtYmEyZS1kZWQwZmM3OTgxNDg@ngzyd-1.lovefromgelifen.xyz:30001#%F0%9F%87%AD%F0%9F%87%B0%20%E9%A6%99%E6%B8%AF-2%20%7C%20SS%20%7C%20%E5%B9%BF%E7%A7%BB
>
> ���У� ssЭ��ĸ�ʽ�ǣ�`ss://method:password@server:port`
>
> �� `method:password`���ֽ��н�����
>
> Y2hhY2hhMjAtaWV0Zi1wb2x5MTMwNTpiZmU5NmVlNS0xZWU5LTRhN2EtYmEyZS1kZWQwZmM3OTgxNDg
>
> base64����õ���
>
> chacha20-ietf-poly1305:bfe96ee5-1ee9-4a7a-ba2e-ded0fc798148
>
> ��Ϣ�����
>
> ���ϣ����Եõ��ҵ�ss������Ϣ��
>
> server: ngzyd-1.lovefromgelifen.xyz
> server_port: 30001
> password: bfe96ee5-1ee9-4a7a-ba2e-ded0fc798148 
> method: chacha20-ietf-poly1305

## 91.2���㶨shadowsocks�ͻ���

```bash
$ yum install -y libsodium  autoconf  python36
$ pip3.6 install https://github.com/shadowsocks/shadowsocks/archive/master.zip -U
$ vim /etc/shadowsocks.json
```

```bash
{
    "server": "ngzyd-1.lovefromgelifen.xyz",
    "server_port": 30001,
    "local_address": "127.0.0.1",
    "local_port": 8118,
    "password": "bfe96ee5-1ee9-4a7a-ba2e-ded0fc798148",
    "timeout": 300,
    "method": "chacha20-ietf-poly1305",
    "workers": 1
}
```

```bash
# �����ͻ���
$ nohup sslocal -c /etc/shadowsocks.json /dev/null 2>&1 &

# ��֤�ͻ���
$ curl --socks5 127.0.0.1:8118 http://httpbin.org/ip
# ���Գɹ���
{
  "origin": "203.175.12.131"
}
```

## 91.3���㶨����http����

��һ������socks5���񣬲�����ֱ��ʹ�ã���Ϊ������Ҫ����http��https�������Ի���Ҫ����һ���������һͷ����socks5����һ���ṩhttp��https����

```bash
# ������privoxy
# ����: https://pan.baidu.com/s/1OoM-uVpf1jyyb8dRjNDfvg?pwd=aqtf ��ȡ��: aqtf 

$ tar -zxvf privoxy-3.0.26-stable-src.tar.gz
$ cd privoxy-3.0.26-stable
# Privoxy ǿ�Ҳ�����ʹ�� root �û����У���������ʹ�� useradd privoxy �½�һ���û�.
$ useradd privoxy
$ autoheader && autoconf
$ ./configure
$ make && make install

# ����
$ vi /usr/local/etc/privoxy/config
listen-address 0.0.0.0:8118   # 8118 ��Ĭ�϶˿ڣ����øģ�������õ�
forward-socks5t / 127.0.0.1:8118 . # ����Ķ˿�д shadowsocks �ı��ض˿ڣ�ע������Ǹ� . ��Ҫ©��

# ����
$ privoxy --user privoxy /usr/local/etc/privoxy/config
```

## 91.4������������

���������ת�������Ǿ����Լ��ķ�����������һ�������ṩhttp/https����ķ���������������Ҫ���������ͷǳ����ˣ�ֱ�������������������ͺã�

```bash
$ export http_proxy=http://192.168.200.1:8118
$ export https_proxy=http://192.168.200.1:8118
# ����
$ curl www.google.com
```

# ��ʮ�����ȿ�ѧ��������ѧ������

https://www.kchuhai.com/report/view-6052.html

�ȸ��ƣ�https://console.cloud.google.com

- �������һ�� k8s ����

```bash
# ǰ����������ܿ�ѧ��������¼�ȸ��ƣ������� cloud shell��Ȼ����cloud shell�²���
$ docker pull k8s.gcr.io/metrics-server/metrics-server:v0.6.1
$ docker login --username=18767188240 --password aliyunk8s123 registry.cn-hangzhou.aliyuncs.com
$ docker tag k8s.gcr.io/metrics-server/metrics-server:v0.6.1 registry.cn-hangzhou.aliyuncs.com/emon-k8s/metrics-server:v0.6.1
$ docker push registry.cn-hangzhou.aliyuncs.com/emon-k8s/metrics-server:v0.6.1
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
$ wget -cP /usr/local/src/ https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.42.0.tar.gz
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
$ tar -zxvf /usr/local/src/git-2.42.0.tar.gz -C /usr/local/Git/
```

6. ִ�����ýű��������밲װ

- �л�Ŀ¼��ִ�нű�

```bash
$ cd /usr/local/Git/git-2.42.0/
$ ./configure --prefix=/usr/local/Git/git2.42.0
```

- ����

```bash
$ make
```

- ��װ

```bash
$ make install
$ cd
$ ls /usr/local/Git/git2.42.0/
bin  libexec  share
```

7. ����������

```bash
$ ln -snf /usr/local/Git/git2.42.0/ /usr/local/git
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
git version 2.42.0
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
$ wget -cP /usr/local/src/ https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
```

2. ������װĿ¼

```bash
$ mkdir /usr/local/Maven
```

3. ��ѹ��װ

```bash
$ tar -zxvf /usr/local/src/apache-maven-3.8.6-bin.tar.gz -C /usr/local/Maven/
```

4. ����������

```bash
$ ln -snf /usr/local/Maven/apache-maven-3.8.6/ /usr/local/maven
```

5. ���û�������

��`/etc/profile.d`Ŀ¼����`mvn.sh`�ļ���

```bash
$ vim /etc/profile.d/mvn.sh
```

```bash
export M2_HOME=/usr/local/maven
export PATH=$M2_HOME/bin:$PATH
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

## 4��Zookeeper���ڵ㣨Apache�棩

1. ����

������ַ�� https://zookeeper.apache.org/index.html

���ص�ַ�� https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/

```bash
$ wget -cP /usr/local/src/ https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.5.9/apache-zookeeper-3.5.9-bin.tar.gz --no-check-certificate
```

2. ������װĿ¼

```bash
$ mkdir /usr/local/ZooKeeper
```

3. ��ѹ��װ

```bash
$ tar -zxvf /usr/local/src/apache-zookeeper-3.5.9-bin.tar.gz -C /usr/local/ZooKeeper/
```

4. ����������

```bash
$ ln -snf /usr/local/ZooKeeper/apache-zookeeper-3.5.9-bin/ /usr/local/zoo
```

5. ���û�������

��`/etc/profile.d`Ŀ¼����`zoo.sh`�ļ���

```bash
$ sudo vim /etc/profile.d/zoo.sh
```

```bash
export ZK_HOME=/usr/local/zoo
export PATH=$ZK_HOME/bin:$PATH
```

ʹ֮��Ч��

```bash
$ source /etc/profile
```

6. �����ļ�

- ����`zoo_sample.cfg`��`zoo.cfg`

```bash
$ cp /usr/local/zoo/conf/zoo_sample.cfg /usr/local/zoo/conf/zoo.cfg
```

- �༭`zoo.cfg`�ļ�

```bash
$ vim /usr/local/zoo/conf/zoo.cfg
```

```bash
# [�޸�]
dataDir=/tmp/zookeeper => dataDir=/usr/local/zoo/data
```

7. ������ֹͣ

- �������˿ں�2181��

```bash
$ zkServer.sh start
```

- У��

```bash
$ jps
44611 QuorumPeerMain
```

- ֹͣ

```bash
$ zkServer.sh stop
```

- ״̬

```bash
$ zkServer.sh status
```

8. ����

- Զ������

```bash
$ zkCli.sh -server emon:2181
```

- ��������

```bash
$ zkCli.sh
```

- �˳������ӳɹ���ʹ������quit�˳���

```bash
[zk: localhost:2181(CONNECTED) 0] quit
```

- �鿴���ڵ�������

```bash
[zk: localhost:2181(CONNECTED) 1] ls /
```

- �����ڵ�test���洢����hello

```bash
[zk: localhost:2181(CONNECTED) 2] create /test hello
```

- �鿴�ڵ�test����

```bash
[zk: localhost:2181(CONNECTED) 6] get /test
# ������������
hello
```

- ɾ���ڵ�

```bash
# �ݹ�ɾ��
[zk: localhost:2181(CONNECTED) 7] deleteall /test
# ��ͨɾ��
[zk: localhost:2181(CONNECTED) 7] delete /test
```

## 5��Maven�ֿ�Ԥ��λ��



## 6���Jenkins

### 6.1����װ

#### 6.1.1��ʹ��Docker

ע�⣬��hub.docker.com������jenkinsʱ������ٷ��汾�󿴵���ʾ��

DEPRECATED; use "jenkins/jenkins:lts" instead

```bash
# �������������ص�
$ mkdir /usr/local/dockerv/jenkins_home
# ����jenkins_homeĿ¼���������������⣺
# touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
# Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?
# $ chown -R 1000:1000 /usr/local/dockerv/jenkins_home/
# -v /usr/local/dockerv/jenkins_home:/var/jenkins_home ָ��������Ŀ¼ΪJenkins����Ŀ¼
# -v /etc/localtime:/etc/localtime ������ʹ�úͷ�����ͬ����ʱ������
# -v /usr/local/maven:/usr/local/maven ӳ����������maven
# -v /usr/local/java:/usr/local/java ӳ����������java
# Ҳ����ʹ�� jenkins/jenkins:lts-centos7-jdk8 ����
$ docker run --name jenkins --user=root \
-d -p 8080:8080 -p 50000:50000 \
-v /usr/local/dockerv/jenkins_home:/var/jenkins_home \
-v /etc/localtime:/etc/localtime \
-v /usr/local/maven:/usr/local/maven \
-v /usr/local/java:/usr/local/java \
-v /root/jenkins:/root/jenkins \
-v /usr/bin/docker:/bin/docker -v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/local/bin/kubectl:/usr/local/bin/kubectl \
jenkins/jenkins:lts
```

#### 6.1.2��ʹ��docker-compose

```bash
# �������������ص�
$ mkdir /usr/local/dockerv/jenkins_home
# ����docker-composeĿ¼
$ mkdir /usr/local/Jenkins
$ vim /usr/local/Jenkins/docker-compose.yml
```

```yaml
version: '3'
services:
  jenkins:
    image: 'jenkins/jenkins:lts'
    container_name: jenkins
    restart: always
    user: root
    ports:
      - 80:8080
      - 50000:50000
    environment:
      TZ: Asia/Shanghai
    volumes:
      - '/usr/local/dockerv/jenkins_home:/var/jenkins_home'
      - '/etc/localtime:/etc/localtime'
      - '/usr/local/maven:/usr/local/maven'
      - '/usr/local/java:/usr/local/java'
      - '/root/jenkins:/root/jenkins'
      - '/usr/bin/docker:/bin/docker'
      - '/var/run/docker.sock:/var/run/docker.sock'
```

```bash
# ��̨����
$ docker-compose -f /usr/local/Jenkins/docker-compose.yml up -d
# ֹͣ
$ docker-compose -f /usr/local/Jenkins/docker-compose.yml down -v
# ������������down -v��up -d��������restart
$ docker-compose -f /usr/local/Jenkins/docker-compose.yml restart
```

- �鿴����

```bash
$ docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# ������������
b273ae2aadaf491e834d1fce52b90e65
```

- ���jenkins��������������docker����

> ����docker: error while loading shared libraries: libltdl.so.7: cannot open shared object file: No such file or directory
>
> �����
>
> $ docker exec -it jenkins /bin/bash
>
> �ڴ򿪵��������У�ִ�����װ��
>
> root@eab33185950a:/# apt-get update && apt-get install -y libltdl7
>
> ˳��ִ����harbor��¼������ű��е�¼��
>
> root@eab33185950a:/# docker login -u emon -p Emon@123 192.168.200.116:5080



#### 6.1.3��war��װ���Ƽ���

������ַ��https://www.jenkins.io/

���ٰ�װ��

1. ����war

```bash
# ����jenkins��װĿ¼
$ mkdir /usr/local/Jenkins/
$ wget https://get.jenkins.io/war-stable/2.332.2/jenkins.war -O /usr/local/Jenkins/jenkins-2.332.2.war
```

2. ��д�����ű�

- jenkins.sh

```bash
$ vim /usr/local/Jenkins/jenkins.sh
```

```bash
#!/bin/bash
JAVA_HOME=/usr/local/java
JENKINS_WAR_NAME=jenkins-2.332.2.war
JENKINS_WAR=/usr/local/Jenkins/${JENKINS_WAR_NAME}
JENKINS_LOG=/usr/local/Jenkins/jenkins.log
pid=$(ps -ef | grep ${JENKINS_WAR_NAME} | grep -v 'grep' | awk '{print $2}' | wc -l)
if [ "$1" = "start" ]; then
  if [ $pid -gt 0 ]; then
    echo 'jenkins is running...'
  else
    echo 'jenkins is starting...'
    nohup $JAVA_HOME/bin/java -jar -Dorg.jenkinsci.plugins.gitclient.Git.timeOut=60 ${JENKINS_WAR} --enable-future-java --httpPort=8080 &>>${JENKINS_LOG} &
  fi
elif [ "$1" = "stop" ]; then
  pid=$(ps -ef | grep ${JENKINS_WAR_NAME} | grep -v grep | awk '{print $2}')
  if [ -z $pid ]; then
    echo 'jenkins has stoped'
  else
    exec echo $pid | xargs kill -9
    echo 'jenkins is stop...'
  fi
else
  echo "Please input like this:"./jenkins.sh start" or "./jenkins stop""
fi
```

```bash
$ chmod u+x /usr/local/Jenkins/jenkins.sh
```

- ����systemd��service�����ļ�

```bash
$ vim /usr/lib/systemd/system/jenkins.service
```

```bash
[Unit]
Description=Jenkins
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/Jenkins/jenkins.sh start
ExecReload=
ExecStop=/usr/local/Jenkins/jenkins.sh stop
PrivateTmp=false
User=root
Group=root

[Install]
WantedBy=multi-user.target
```

- ���ط������ÿ�������

```bash
$ systemctl daemon-reload && systemctl enable jenkins && systemctl start jenkins
```

- �鿴��ʼ����

```bash
$ cat /root/.jenkins/secrets/initialAdminPassword
dd56c6ccb54a48c285f3f40546726bfb
```

#### 6.1.4����װ�Ƽ����

���ʣ�http://emon:8080

�����ʼ���벢��װ�Ƽ������

![image-20220407163042485](images/image-20220407163042485.png)

- �����û�

���ʣ�http://emon:8080

��װ�Ƽ��Ĳ��==>�����û���jenkins/jenkins123

- ����Jenkins

http://emon:8080/restart



### 6.2����������

#### 6.2.1�����ò����װ

- Git Parameter

��װ��ɺ󣬵������װ��ɺ�����Jenkins������������������

#### 6.2.2����������

##### Global Tool Configuration��ȫ�ֹ������ã���war��װ�ɺ��ԡ�

- ����JDK

����·����Manage Jenkins==>Global Tool Configuration==>JDK==>�����Զ���װ==>

JDK����=java1.8

JAVA_HOME=/usr/local/java

- ����Maven

����·����Manage Jenkins==>Global Tool Configuration==>Maven==>�����Զ���װ==>

JDK����=maven3.6.3

MAVEN_HOME=/usr/local/maven

##### Configure System��ϵͳ���ã�

- ȫ������==>��������

����·����Manage Jenkins==>Configure System==>ȫ������==>��ѡ��������==>��Ӽ�ֵ���б�==>

JAVA_HOME=/usr/local/java

M2_HOME=/usr/local/maven

PATH+EXTRA=$M2_HOME/bin:$JAVA_HOME/bin

ע�⣺

1��M2_HOME �������������ǹ̶��ģ�������д�����ı�����; ��ʶMaven��ϵͳ�ڵļ�Ŀ¼��

2��PATH+EXTRA ��������Maven��Ŀ¼���������̶������ܸ��ġ�

3�������Ҫ��������������npm���������£�

PATH+EXTRA=$M2_HOME/bin:$JAVA_HOME/bin:/root/.nvm/versions/node/v12.22.12/bin

�������������á�



### 6.3��Pipeline������ʾ

- �����ű�Ŀ¼

```bash
$ mkdir -pv /root/jenkins/script
```

#### 6.3.1������env���ű�

- �����ű��ļ�

```bash
$ vim /root/jenkins/script/check-env.sh
```

```bash
#!/bin/bash

# У��������Pipeline���������Ƿ��Ѷ���
BUILD_TYPE_SCOPE=(
"mvn"
"npm"
)
if [ "${BUILD_TYPE}" == "" ];then
    echo "env 'BUILD_TYPE' is not set, the support value is mvn or npm"
    exit 1
elif [[ ! "${BUILD_TYPE_SCOPE[@]}" =~ "${BUILD_TYPE}" ]];then 
    echo "env 'BUILD_TYPE' must in mvn or npm"
    exit 1
fi
# ȷ����������Ĺ���Ŀ¼
if [ "${BUILD_BASE_DIR}" == "" ];then
    echo "env 'BUILD_BASE_DIR' is not set"
    exit 1
fi
# ����Ĭ�ϵ�${JOB_NAME}����ѡ��
if [ "${BUILD_JOB_NAME}" == "" ];then
    echo "env 'BUILD_JOB_NAME' is not set, use default value '${JOB_NAME}'"
fi
# �������ԴĿ¼����������ڣ���ʹ����Ŀ��Ŀ¼�µ�k8sĿ¼�������ѡ��
if [ "${K8S_DIR}" == "" ];then
    if [ "${MODULE}" == "" ];then
        K8S_DIR=${WORKSPACE}/k8s
    else
        K8S_DIR=${WORKSPACE}/${MODULE}/k8s
    fi 
    echo "env 'K8S_DIR' is not set, use default value '$K8S_DIR'"
fi

# �����mvn���ͣ�����ָ��MODULE
if [ "${BUILD_TYPE}" == "mvn" ];then
    # �������ʱʹ�õ�ģ��
    if [ "${MODULE}" == "" ];then
        echo "env 'MODULE' is not set"
        exit 1
    fi
fi
# ����ֿ��ַ
if [ "${IMAGE_REPO}" == "" ];then
    echo "env 'IMAGE_REPO' is not set"
    exit 1
fi


# ���񷢲��󣬱�¶����������
if [ "${HOST}" == "" ];then
    echo "env 'HOST' is not set, if you need it, please set!"
fi
echo "env.HOST=$HOST"
# ���񷢲�ʹ�õ������ռ� default/drill/dev/test/prod �ȵ�
if [ "${NS}" == "" ];then
    NS="default"
    echo "env 'NS' is not set, use default"
fi
echo "env.NS=$NS"
# �����ָ����Ĭ��ʹ�� web.yaml ����ʹ��ָ���������ļ�����k8s����
if [ "${DEPLOY_YAML}" == "" ];then
    DEPLOY_YAML="web.yaml"
    echo "env 'DEPLOY_YAML' is not set, use web.yaml"
fi
echo "env.DEPLOY_YAML=$DEPLOY_YAML"


# ��ʼ������
# ׼�����������ļ����������ԴĿ¼����������ڣ���ʹ����Ŀ��Ŀ¼�µ�k8sĿ¼��������Ҳ�����ڣ����˳���
if [ ! -d ${K8S_DIR} ];then
    echo "env 'K8S_DIR' is not exists, please ensure k8s dir in your project"
    exit 1
fi

DEPLOY_NAME=${JOB_NAME}
if [ -f "${K8S_DIR}/job_name_copy_to_build_dist" ];then
    echo "file job_name_copy_to_build_dist exists in ${K8S_DIR}, enable custom resource copy"
    if [ "${BUILD_JOB_NAME}" == "" ];then
        BUILD_JOB_NAME=${K8S_DIR##*/}
        echo "env 'BUILD_JOB_NAME' is not set, but file job_name_build_dist is exists, set BUILD_JOB_NAME=$BUILD_JOB_NAME'"
    fi
    DEPLOY_NAME=${BUILD_JOB_NAME}
    if [ -z "${DEPLOY_NAME}" ];then
        DEPLOY_NAME=${K8S_DIR##*/}
    fi
fi

# ȷ����������Ĺ���Ŀ¼
DOCKER_DIR=${BUILD_BASE_DIR}/${JOB_NAME}
# ����Ĭ�ϵ�${JOB_NAME}
if [ -n "${BUILD_JOB_NAME}" ];then
    DOCKER_DIR=${BUILD_BASE_DIR}/${BUILD_JOB_NAME}
fi
if [ ! -d ${DOCKER_DIR} ];then
    mkdir -p ${DOCKER_DIR}
fi
echo "docker workspace: ${DOCKER_DIR}"

# �����Ŀ��������Ŀ¼��Ĭ���ڹ����������ڵ�Ŀ¼
WEB_ROOT=$DOCKER_DIR
if [ -n "${BUILD_DIST}" ];then
    WEB_ROOT=$DOCKER_DIR/$BUILD_DIST
fi
echo "web root in the image will be:"$WEB_ROOT

# ȷ��Jenkins��ģ���λ��
JENKINS_DIR=${WORKSPACE}/${MODULE}
echo "jenkins workspace: ${JENKINS_DIR}"
```

#### 6.3.2��������Դ�ռ��ű�

- �����ű��ļ�

```bash
$ vim /root/jenkins/script/collect-resource.sh
```

```bash
#!/bin/bash

ENTRY_PATH=$(pwd)
ENTRY_BASE_PATH=$(dirname "$WORKSPACE")
SCRIPT_BASE_PATH=$(dirname "$0")
echo "==========��ʼִ��collect-resource.sh�ű���ENTRY_PATH=$ENTRY_PATH, WORKSPACE=$WORKSPACE, ENTRY_BASE_PATH=$ENTRY_BASE_PATH, SCRIPT_BASE_PATH=$SCRIPT_BASE_PATH=========="
source $SCRIPT_BASE_PATH/check-env.sh

# У����Դ�Ƿ����
if [ "${BUILD_TYPE}" == "mvn" ];then
    # �ж�Ŀ��jar�Ƿ����
    if [ ! -f ${JENKINS_DIR}/target/*.jar ];then
        echo "target jar file not found ${JENKINS_DIR}/target/*.jar"
        exit 1
    fi
elif [ "${BUILD_TYPE}" == "npm" ];then    
    # �ж�Ŀ��distĿ¼�Ƿ��������
    if [ ! "$(ls -A ${JENKINS_DIR}dist)" ];then
        echo "content is empty in dir ${JENKINS_DIR}dist"
        exit 1
    fi
fi


# ������������Ĺ���Ŀ¼
echo "==========�л�Ŀ¼����${DOCKER_DIR}=========="
cd ${DOCKER_DIR}

echo "copy k8s resource from $K8S_DIR to $DOCKER_DIR"
cp -rv ${K8S_DIR}/* .

if [ "${BUILD_TYPE}" == "mvn" ];then
    mkdir -p $WEB_ROOT
    cp ${JENKINS_DIR}/target/*.jar $WEB_ROOT
elif [ "${BUILD_TYPE}" == "npm" ];then
    if [ -f job_name_copy_to_build_dist ];then
        for line in `cat job_name_copy_to_build_dist`
        do
            array=(`echo $line | tr '' ' '`)
            JOB_NAME=${array[0]}
            BUILD_DIST=${array[1]}
            JENKINS_DIR=${ENTRY_BASE_PATH}/$JOB_NAME
            WEB_ROOT=$DOCKER_DIR/$BUILD_DIST
            echo "JOB_NAME=$JOB_NAME, BUILD_DIST=$BUILD_DIST, JENKINS_DIR=$JENKINS_DIR, WEB_ROOT=$WEB_ROOT"

            if [ -d "${JENKINS_DIR}/dist" ];then
                echo "cp -rv $JENKINS_DIR/dist/* $WEB_ROOT"
                mkdir -p $WEB_ROOT
                cp -rv $JENKINS_DIR/dist/* $WEB_ROOT
            else
                echo "dir $JENKINS_DIR/dist does not exists, ignore copy!!!"
            fi
        done
    else
        mkdir -p $WEB_ROOT
        cp -rv ${JENKINS_DIR}dist/* $WEB_ROOT
    fi
fi

# ���汾��ִ�н���
echo "collect-resource" > ${DOCKER_DIR}/PROGRESS
```

#### 6.3.3������������ű�

- �����ű��ļ�

```bash
$ vim /root/jenkins/script/build-image.sh
```

```bash
#!/bin/bash

ENTRY_PATH=$(pwd)
ENTRY_BASE_PATH=$(dirname "$WORKSPACE")
SCRIPT_BASE_PATH=$(dirname "$0")
echo "==========��ʼִ��build-image.sh�ű���ENTRY_PATH=$ENTRY_PATH, WORKSPACE=$WORKSPACE, ENTRY_BASE_PATH=$ENTRY_BASE_PATH, SCRIPT_BASE_PATH=$SCRIPT_BASE_PATH=========="
source $SCRIPT_BASE_PATH/check-env.sh

echo "==========�л�Ŀ¼����${DOCKER_DIR}=========="
cd ${DOCKER_DIR}

# ��ʼ�������ϴ������ļ�
VERSION=`date +%Y%m%d%H%M%S`
#IMAGE_NAME=192.168.200.116:5080/devops-learning/${JOB_NAME}:${VERSION}
IMAGE_NAME=${IMAGE_REPO}/${JOB_NAME}:${VERSION}

echo "building image: ${IMAGE_NAME}"
#docker login -u emon -p Emon@123 192.168.200.116:5080
docker build -t ${IMAGE_NAME} .

docker push ${IMAGE_NAME}

# �ϴ���ɾ�����ؾ���
docker rmi ${IMAGE_NAME}

# ���汾�ξ�������
echo "${IMAGE_NAME}" > ${DOCKER_DIR}/IMAGE

# ���汾��ִ�н���
echo "build-image" > ${DOCKER_DIR}/PROGRESS
```

#### 6.3.4������k8sģ��ű�

- ��ģ��

```bash
$ mkdir -pv /root/jenkins/script/template
$ vim /root/jenkins/script/template/web.yaml
```

```yaml
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  selector:
    matchLabels:
      app: {{name}}
  replicas: 1
  template:
    metadata:
      labels:
        app: {{name}}
    spec:
      containers:
      - name: {{name}}
        image: {{image}}
        ports:
        - containerPort: 8080
---
#service
apiVersion: v1
kind: Service
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    app: {{name}}
  type: ClusterIP

---
#ingress
#apiVersion: extensions/v1beta1
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  rules:
  - host: {{host}}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {{name}}
            port:
              number: 80
```

- SpringBootģ�塾��ģ��ŵ���Ŀ�и�Ŀ¼��k8sĿ¼��ʹ�ã���������Ǳ���һ�¡�

```yaml
# web-custom.yaml ���� k8s-deploy-drill.yaml ����������
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  selector:
    matchLabels:
      app: {{name}}
  replicas: 1
  template:
    metadata:
      labels:
        app: {{name}}
    spec:
      containers:
        - name: {{name}}
          image: {{image}}
          ports:
            - containerPort: 38751
          resources:
            requests:
              memory: 768Mi
              # 1���ĵ�CPU=1000m
              cpu: 700m
            limits:
              memory: 1024Mi
              cpu: 1000m
          # ���״̬���
          livenessProbe:
            httpGet:
              path: /actuator/health/liveness
              port: 38751
              scheme: HTTP
            # pod ����10s��������һ��̽��
            initialDelaySeconds: 50
            # ÿ��10s����һ��̽��
            periodSeconds: 10
            # ��ʱʱ��3s
            timeoutSeconds: 3
            # �ɹ�1�μ���ʾ��������
            successThreshold: 1
            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
            failureThreshold: 5
          # ����״̬���
          readinessProbe:
            httpGet:
              path: /actuator/health/readiness
              port: 38751
              scheme: HTTP
            initialDelaySeconds: 50
            periodSeconds: 10
            timeoutSeconds: 3
          env:
            - name: JAVA_TOOL_OPTIONS
              value: "-Xmx768m -Xms768m -Xmn256m -Xss228k -XX:MetaspaceSize=256m -Djasypt.encryptor.password=EbfYkLpulv58S2mFmXzmyJMXoaxZTDK7 -Dspring.profiles.active=uat"
            # 1��stdoutΪԼ���ؼ��֣���ʾ�ɼ���׼�����־
            # 2�����ñ�׼�����־�ɼ���ES��catalina������
            - name: aliyun_logs_catalina
              value: "stdout"
            # 1�����òɼ��������ļ���־��֧��ͨ���
            # 2�����ø���־�ɼ���ES��access������
            - name: aliyun_logs_access
              value: "/home/saas/huiba/gaia/huiba-gaia-admin/logs/*.log"
          # �������ļ���־·����Ҫ����emptyDir
          volumeMounts:
            - name: log-volume
              mountPath: /home/saas/huiba/gaia/huiba-gaia-admin/logs
      volumes:
        - name: log-volume
          emptyDir: { }
---
#service
apiVersion: v1
kind: Service
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 38751
  selector:
    app: {{name}}
  type: ClusterIP

---
#ingress
#apiVersion: extensions/v1beta1
#kind: Ingress
#metadata:
#  name: {{name}}
#  namespace: {{ns}}
#spec:
#  rules:
#    - host: {{host}}
#      http:
#        paths:
#          - path: /
#            pathType: Prefix
#            backend:
#              serviceName: {{name}}
#              servicePort: 80
```



#### 6.3.5������k8s����ű�

```bash
$ vim /root/jenkins/script/deploy.sh
```

```bash
#!/bin/bash

ENTRY_PATH=$(pwd)
ENTRY_BASE_PATH=$(dirname "$WORKSPACE")
SCRIPT_BASE_PATH=$(dirname "$0")
echo "==========��ʼִ��deploy.sh�ű���ENTRY_PATH=$ENTRY_PATH, WORKSPACE=$WORKSPACE, ENTRY_BASE_PATH=$ENTRY_BASE_PATH, SCRIPT_BASE_PATH=$SCRIPT_BASE_PATH=========="
source $SCRIPT_BASE_PATH/check-env.sh

# ��ӡ��BASH_DIR·��
BASH_DIR=$(dirname "${BASH_SOURCE[0]}")
echo "BASH_DIR=${BASH_DIR}"

# Ϊģ��ű�׼������
name=${DEPLOY_NAME}
image=$(cat ${DOCKER_DIR}/IMAGE)
host=${HOST}
ns=${NS}

echo "deploying ... name: ${name}, image: ${image}, host: ${host}, ns: ${ns}, deploy_yaml: ${DEPLOY_YAML}"

# �����Ĭ��ģ�壬��ģ��⿽����������Ϊ����Ŀ�ṩ�ˣ�����Ŀ��k8sĿ¼�£��Ѵ���
if [ "${DEPLOY_YAML}" == "web.yaml" ];then
    rm -f ${DOCKER_DIR}/${DEPLOY_YAML}
    cp ${BASH_DIR}/template/web.yaml ${DOCKER_DIR}
fi

sed -i "s,{{name}},${name},g" ${DOCKER_DIR}/${DEPLOY_YAML}
sed -i "s,{{image}},${image},g" ${DOCKER_DIR}/${DEPLOY_YAML}
sed -i "s,{{host}},${host},g" ${DOCKER_DIR}/${DEPLOY_YAML}
sed -i "s,{{ns}},${ns},g" ${DOCKER_DIR}/${DEPLOY_YAML}

echo "kubectl apply -f ${DOCKER_DIR}/${DEPLOY_YAML}"
kubectl apply -f ${DOCKER_DIR}/${DEPLOY_YAML}

# ��ӡ���β����web.yaml����
echo "web.yaml content as follows:"
cat ${DOCKER_DIR}/${DEPLOY_YAML}

# �������
echo "begin health check..."
success=0
count=60
IFS=","
sleep 5
while [ ${count} -gt 0 ]
do
    replicas=$(kubectl -n ${ns} get deploy ${name} -o go-template='{{.status.replicas}},{{.status.updatedReplicas}},{{.status.readyReplicas}},{{.status.availableReplicas}}')
    echo "replicas: ${replicas}"
    arr=(${replicas})
    if [ "${arr[0]}" == "${arr[1]}" -a "${arr[1]}" == "${arr[2]}" -a "${arr[2]}" == "${arr[3]}" ];then
        echo "health check success!"
        success=1
        break
    fi
    ((count--))
    sleep 2
done

if [ ${success} -ne 1 ];then
    echo "health check failed!"
    exit 1
fi

# ���汾��ִ�н���
echo "deploy" > ${DOCKER_DIR}/PROGRESS
```



#### 6.3.3������Pipeline script����

Jenkins��¼==>�½�����==>�������� k8s-springboot-web-demo Ȼ��ѡ����ˮ�ߡ�����==>���ȷ�������ɹ���

- Git��֧���ã��������ʹ�õ�${params.BRANCH}��������Ҫ���ã�������Ҫ���Ǳ��롿

![image-20220408230030796](images/image-20220408230030796.png)

- Pipeline script��SpringBoot��Ŀʾ����

```bash
node {
    env.BUILD_TYPE="mvn"
    // ȷ����������Ĺ���Ŀ¼
    env.BUILD_BASE_DIR = "/root/jenkins/build_workspace"
    
    // �������ʱʹ�õ�ģ��
    env.MODULE = "huiba-gaia-admin/huiba-gaia-admin-server"
    // ����ֿ��ַ
    env.IMAGE_REPO = "gaia-e2-01-registry.cn-shanghai.cr.aliyuncs.com/lishi"
    
	// ���񷢲��󣬱�¶����������
    env.HOST = "gyls.gaiaworks.cn"
    // ���񷢲�ʹ�õ������ռ� default/drill/dev/test/prod �ȵ�
    env.NS = "lishi-recruitment"
    // �����ָ����Ĭ��ʹ�� web.yaml ����ʹ��ָ���������ļ�����k8s����
    env.DEPLOY_YAML = "k8s-deploy-uat.yaml"
    
    stage('Preparation') {
        sh 'printenv'
        // git 'git@github.com:EmonCodingBackEnd/backend-devops-learning.git'
        // git branch: "${params.BRANCH}", url: 'git@github.com:EmonCodingBackEnd/backend-devops-learning.git'
        git branch: "develop", url: 'http://git.ishanshan.com/huiba-backend/huiba-gaia.git'
    }
    
    stage('Maven Build') {
        sh "mvn -pl ${MODULE} -am clean package -Dmaven.test.skip=true"
    }
    
    stage('Collect Resource'){
        sh "/root/jenkins/script/collect-resource.sh"
    }
    
    stage('Build Image') {
        sh "/root/jenkins/script/build-image.sh"
    }
    
    stage('Deploy') {
        sh "/root/jenkins/script/deploy.sh"
    }
}
```

- Pipeline script��Vue��Ŀʾ����

```bash
// ���浥��Ŀ����ѡ�������д�������Ҫ�����Ŀ�ı���������ͬһ�����񣬿�ѡ������ÿ���������һ�㣻ʾ�����뼴�����ָ��������
node {
    env.BUILD_TYPE="npm"
    // ȷ����������Ĺ���Ŀ¼
    env.BUILD_BASE_DIR = "/root/jenkins/build_workspace"
    // �������ԴĿ¼����������ڣ���ʹ����Ŀ��Ŀ¼�µ�k8sĿ¼�������ѡ��
    env.K8S_DIR = "/root/jenkins/k8s/gaia-web"
    
    // �������ʱʹ�õ�ģ��
    env.MODULE = ""
    // ����ֿ��ַ
    env.IMAGE_REPO = "gaia-e2-01-registry.cn-shanghai.cr.aliyuncs.com/lishi"
    
	// ���񷢲��󣬱�¶����������
    env.HOST = "gyls.gaiaworks.cn"
    // ���񷢲�ʹ�õ������ռ� default/drill/dev/test/prod �ȵ�
    env.NS = "lishi-recruitment"
    // �����ָ����Ĭ��ʹ�� web.yaml ����ʹ��ָ���������ļ�����k8s����
    env.DEPLOY_YAML = "k8s-deploy-uat.yaml"
    
    stage('Preparation') {
        sh 'printenv'
        // git 'git@github.com:EmonCodingBackEnd/backend-devops-learning.git'
        // git branch: "${params.BRANCH}", url: 'git@github.com:EmonCodingBackEnd/backend-devops-learning.git'
        git branch: "develop", url: 'http://git.ishanshan.com/huiba-frontend/huiba-gaia-web.git'
    }
    
    stage('Npm Install') {
        sh "npm install"
    }
    
    stage('Npm Build') {
        sh "npm run build:prod"
    }
    
    stage('Collect Resource'){
        sh "/root/jenkins/script/collect-resource.sh"
    }
    
    stage('Build Image') {
        sh "/root/jenkins/script/build-image.sh"
    }
    
    stage('Deploy') {
        sh "/root/jenkins/script/deploy.sh"
    }
}
```



#### 6.3.4������Pipeline script from SCM����



### 6.3.5������Ŀ�����������

�ڲ���K8S����ʱ��ǰ����Ŀ�ж�����������ǹ���̨�˺��ֻ��ˣ���������Ҫ����ͬһ�������£�������Ҫ�����ͬһ�������¡�

����̨��Ŀ��huiba-scrm-web

�ֻ�����Ŀ��huiba-scrm-h5

- ����������Ŀ���õ��ļ���

```bash
$ mkdir -pv /root/jenkins/k8s
```

- ����huiba-scrm-web��huiba-scrm-h5���ļ���

```bash
$ mkdir -pv /root/jenkins/k8s/gaia-web
```

- ����Dockerfile

```bash
$ vim /root/jenkins/k8s/gaia-web/Dockerfile
```

```dockerfile
# FROM 192.168.200.116:5080/devops-learning/nginx:1.21
FROM nginx:1.21
MAINTAINER ���� liming2011071@163.com

COPY mgr/ /usr/share/nginx/html/mgr
COPY h5/ /usr/share/nginx/html/h5
COPY dockerfiles/default.conf /etc/nginx/conf.d/default.conf
```

- ����k8s-deploy-uat.yaml

```bash
$ vim /root/jenkins/k8s/gaia-web/k8s-deploy-uat.yaml
```

```yaml
# web-custom.yaml ���� k8s-deploy-drill.yaml ����������
#deploy
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  selector:
    matchLabels:
      app: {{name}}
  replicas: 1
  template:
    metadata:
      labels:
        app: {{name}}
    spec:
      containers:
        - name: {{name}}
          image: {{image}}
          ports:
            - containerPort: 8808
          resources:
            requests:
              memory: 100Mi
              # 1���ĵ�CPU=1000m
              cpu: 100m
            limits:
              memory: 300Mi
              cpu: 300m
#          # ���״̬���
#          livenessProbe:
#            httpGet:
#              path: /actuator/health/liveness
#              port: 8808
#              scheme: HTTP
#            # pod ����10s��������һ��̽��
#            initialDelaySeconds: 35
#            # ÿ��10s����һ��̽��
#            periodSeconds: 10
#            # ��ʱʱ��3s
#            timeoutSeconds: 3
#            # �ɹ�1�μ���ʾ��������
#            successThreshold: 1
#            # ����5��ʧ�ܣ����ж�������������Ĭ��3��
#            failureThreshold: 5
#          # ����״̬���
#          readinessProbe:
#            httpGet:
#              path: /actuator/health/readiness
#              port: 8808
#              scheme: HTTP
#            initialDelaySeconds: 30
#            periodSeconds: 10
#            timeoutSeconds: 3
#          env:
#            - name: JAVA_TOOL_OPTIONS
#              value: "-Xmx512m -Xms512m -Xmn256m -Xss228k -XX:MetaspaceSize=256m -Djasypt.encryptor.password=EbfYkLpulv58S2mFmXzmyJMXoaxZTDK7 -Dspring.profiles.active=uat"
#            # 1��stdoutΪԼ���ؼ��֣���ʾ�ɼ���׼�����־
#            # 2�����ñ�׼�����־�ɼ���ES��catalina������
#            - name: aliyun_logs_catalina
#              value: "stdout"
#            # 1�����òɼ��������ļ���־��֧��ͨ���
#            # 2�����ø���־�ɼ���ES��access������
#            - name: aliyun_logs_access
#              value: "/home/saas/huiba/gaia/huiba-gaia-admin/logs/*.log"
#          # �������ļ���־·����Ҫ����emptyDir
#          volumeMounts:
#            - name: log-volume
#              mountPath: /home/saas/huiba/gaia/huiba-gaia-admin/logs
#      volumes:
#        - name: log-volume
#          emptyDir: { }

---
#service
apiVersion: v1
kind: Service
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 8808
  selector:
    app: {{name}}
  type: ClusterIP

---
#ingress
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{name}}
  namespace: {{ns}}
spec:
  rules:
    - host: {{host}}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              serviceName: {{name}}
              servicePort: 80
```

- ����job_name_copy_to_build_dist

**Ĭ�ϵ��зָ�����`\001`����linux������Ctrl+V��Ctrl+A��Ч��`\001`���÷ָ�����ʾΪ^A**

���ļ����ڶ����Ŀ���һ������ʱ���ռ���Դ���Զ������á��������ݱ�ʾ��

huiba-gaia-web��Ŀ�����������ռ���gaia-web/mgrĿ¼��

huiba-gaia-h5��Ŀ�����������ռ���gaia-web/h5Ŀ¼��

**mgr��h5Ŀ¼�������**

```bash
$ vim /root/jenkins/k8s/gaia-web/job_name_copy_to_build_dist
```

```bash
huiba-gaia-web^Amgr
huiba-gaia-h5^Ah5
```

- ����dockerfiles�ļ���������

```bash
$ mkdir -pv /root/jenkins/k8s/gaia-web/dockerfiles
$ vim /root/jenkins/k8s/gaia-web/dockerfiles/default.conf
```

```nginx
proxy_cache_path /tmp/nginx levels=1:2 keys_zone=my_zone:200m inactive=3d;

server {
    listen 8808;
    server_name localhost gyls.gaiaworks.cn;
    proxy_cache_key "$scheme$proxy_host$request_uri";
    access_log  /var/log/nginx/scrm.access.log  main;
    error_log  /var/log/nginx/scrm.error.log  error;

    location ~ .*\.txt$ {
          root /home/saas/huiba/scrm/huiba-scrm-web/webroot/;
    }

    location ^~ /mg/ {
            rewrite ^/(.*)$  /wx.html last;
    }
    location /wx.html {
        #root html/dist;
        root /usr/share/nginx/html/h5/;
        index wx.html wx.htm;
    }
    location ^~ /h5/ {
            rewrite ^/(.*)$  /index.html last;
    }
    location /index.html {
        #root html/dist;
        root /usr/share/nginx/html/h5/;
        index index.html index.htm;
    }
    location /hs/ {
        #rewrite ^/(.*)$  /index.html last;
        alias /usr/share/nginx/html/h5/;
        index index.html index.htm;
        try_files $uri $uri/ /hs/index.html;
    }

    location ^~ /static {
        #root html/h5create;
        root /usr/share/nginx/html/mgr/;
        index index.html index.htm;
    }

    location ^~ /m {
        if ($request_uri ~* /static/(js|css|fonts|img)) {
            rewrite /m/(.*?)/static/(.*) /static/$2 last;
        }
        #root   html/h5create;
        root /usr/share/nginx/html/mgr/;
        default_type text/html;
        # access_by_lua_file lua/h5auth_access.lua;
        # header_filter_by_lua_file lua/h5auth_header.lua;
        #content_by_lua_block {
            #local r = require('read_static')
            #r.readStaticRoot("/h5.html")
        #}
    }

    location ^~ /api/hbscrm/ {
      # add_header Access-Control-Allow-Origin *;
      # add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
      #add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
    
      #if ($request_method = 'OPTIONS') {
      #    return 204;
      #}
    
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto  $scheme;
      #proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
          proxy_pass http://huiba-gaia-gateway;
          proxy_http_version 1.1;
      proxy_read_timeout 7200s;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    }

    location ^~ /jsapi/pay/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        #proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://huiba-gaia-gateway/api/hbscrm/huiba-scrm-game-provider/jsapi/pay/;
    }

    location ^~ /jsapi/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        #proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://huiba-gaia-gateway/api/hbscrm/huiba-scrm-game-provider/;
    }

    location / {
        rewrite ^/(.*)$  /mgr/scrm.html last;
    }
    location ^~ /mgr/ {
        #rewrite ^/(.*)$  /index.html last;
        root /usr/share/nginx/html/;
        index index.html index.htm;
        add_header Access-Control-Allow-Origin *;
    }
    location ^~ /yd/ {
        #rewrite ^/(.*)$  /index.html last;
        root /home/saas/huiba/scrm/huiba-scrm-mall-web/webroot/;
        index index.html index.htm;
        add_header Access-Control-Allow-Origin *;
    }
    location ^~ /wecom/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://huiba-wecom-helper-inner/;
    }
    location ^~ /eurekaweb/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://huiba-gaia-eureka/;
    }
    location ^~ /eureka/ {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto  $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_pass http://huiba-gaia-eureka;
    }

   location ^~ /gimg {
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://huiba-gimg;
   }
   location ^~ /gimg/img/ {
      proxy_cache my_zone;
      add_header X-Proxy-Cache $upstream_cache_status;
      add_header 'Access-Control-Allow-Headers' 'X-Requested-With';
      add_header 'Access-Control-Allow-Origin' '*';
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://huiba-gimg;
   }

   location ^~ /gimg/upload {
      add_header 'Access-Control-Allow-Headers' 'X-Requested-With';
      add_header 'Access-Control-Allow-Origin' '*';
      add_header Access-Control-Allow-Methods POST;
      if ($request_method = 'OPTIONS') {
        return 204;
      }
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://huiba-gimg;
   }

   location ^~ /gimg/user/upload {
      add_header 'Access-Control-Allow-Headers' 'X-Requested-With';
      add_header 'Access-Control-Allow-Origin' '*';
      add_header Access-Control-Allow-Methods POST;
      if ($request_method = 'OPTIONS') {
        return 204;
      }
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://huiba-gimg;
   }
}
```





