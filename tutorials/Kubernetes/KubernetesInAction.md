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



# ����Ԥ��׼������

## 1��׼��������

| ������ | ϵͳ���� | IP1-��ͥ      | IP2-��˾   | �ڴ� | �������� |
| ------ | -------- | ------------- | ---------- | ---- | -------- |
| emon   | CentOS7  | 192.168.1.116 | 10.0.0.116 | >=2G | master   |
| emon2  | CentOS7  | 192.168.1.117 | 10.0.0.117 | >=2G | worker   |
| emon3  | CentOS7  | 192.168.1.118 | 10.0.0.118 | >=2G | worker   |

## 2����װdocker�����нڵ㣩

### 2.1����װ�ĵ�

[Docker��װ](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Docker/DockerInAction.md#%E4%B8%80docker%E7%9A%84%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE)

### 2.2��docker��������

- ��������ip�����ݰ�ת��

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# ��������ExecStart=XXX�������һ�У��������£���k8s��������Ҫ��
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
```

- ����˽��

```bash
[emon@emon ~]$ sudo vim /lib/systemd/system/docker.service 
```

```bash
# ����������б�Ҫ������ExecStart����׷��һ��˽����ַ�����á����û��httpЭ��ľ���˽�������������á�
EnvironmentFile=-/etc/docker/daemon.json
```

���ļ� `/etc/docker/daemon.json` ׷�� `insecure-registries`���ݣ�

```bash
[emon@emon ~]$ sudo vim /etc/docker/daemon.json
```

```bash
{
  "registry-mirrors": ["https://pyk8pf3k.mirror.aliyuncs.com"],
  "insecure-registries": ["emon:5080"]
}
```

### 2.3����������

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
[emon@emon ~]$ sudo systemctl restart docker
```

## 3��ϵͳ���ã����нڵ㣩

### 3.1���رա����÷���ǽ�������л���֮�䶼����ͨ������˿ڽ������ӣ�

```bash
[emon@emon ~]$ sudo systemctl stop firewalld
[emon@emon ~]$ sudo systemctl disable firewalld
[emon@emon ~]$ sudo setenforce 0
```

### 3.2������ϵͳ���� - ����·��ת��������bridge�����ݽ��д���

```bash
#д�������ļ�
$ cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
 
#��Ч�����ļ�
$ sysctl -p /etc/sysctl.d/k8s.conf
```



### 3.3������host�ļ�

�༭`/etc/hosts`�ļ����������Ƭ�Σ�ע��IP��ַ����Ϊ�Լ�ʵ�������

```bash
192.168.1.116 emon
192.168.1.117 emon2
192.168.1.118 emon3
```



## 4��׼���������ļ������нڵ㣩

kubernetes�İ�װ�м��ַ�ʽ��������kube-admin�����������׵Ĳ��𷽰����벻���⼸�ַ�ʽ��

- **ʹ���ֳɵĶ������ļ�**

> ֱ�Ӵӹٷ����������������أ�����kubernetes��������Ŀ�ִ���ļ��������Ϳ���ֱ�������ˡ�������centos��ubuntu����������linux���а汾��ֻҪgcc���뻷��û��̫�������Ϳ���ֱ�����еġ�ʹ�ý��µ�ϵͳһ�㲻����ʲô��ƽ̨�����⡣

- **ʹ��Դ����밲װ**

> ������Ҳ�Ǹ�������Ķ������ļ������������ֱ�����ص���Ҫ�Ķ������ļ�����û��ʲô����ı�Ҫ���ˡ�

- **ʹ�þ���ķ�ʽ����**

> ͬ��һ������ʹ�ö������ļ��ṩ�ķ���Ҳ����ѡ��ʹ�þ���ķ�ʽ������nginx����mysql�����ǿ���ʹ�ð�װ�棬��һ����ִ���ļ�����������Ҳ����ʹ�����ǵľ��������������ṩͬ���ķ���kubernetesҲ��һ���ĵ����������ļ��ṩ�ķ�����Ҳһ�������ṩ��

����������ַ�ʽ����ʵʹ�þ����ǱȽ����ŵķ����������ĺô���Ȼ���ö�˵�����ӳ�ѧ�ߵĽǶ���˵�����ķ������Ե���Щ���ӣ�����ô���⣬���кܶ������������ļ��Լ��������ƶ������ļ��ṩ�ķ���������������ṩ�����⣬������ƫ�� ������������ʹ�ö����Ƶķ�ʽ�����𡣶������ļ��Ѿ����ﱸ�ã���ҿ��Դ�����أ������غõ��ļ��ŵ�ÿ���ڵ��ϣ������ĸ�Ŀ¼����ϲ����**�źú��������һ�»�������$PATH**������������ֱ��ʹ�����(��ѧ������ͬѧҲ�����Լ�ȥ��������)

[���ص�ַ��kubernetes 1.9.0�汾��](https://pan.baidu.com/s/1bMnqWY)

�������ص�ַ��https://github.com/kubernetes/kubernetes/releases

������ʹ��1.9.0�汾������



# ����������Ⱥ���� - kubernetes-simple



# �ġ�������Ⱥ���� - kubernetes-with-ca



# �塢��kubernetes�ϲ������ǵ�΢����































































































































































