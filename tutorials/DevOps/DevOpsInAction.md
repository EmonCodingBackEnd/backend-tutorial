# DevOpsʵ��

[�����б�](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# ��һ��DevOps

DevOps��Development��Operations����ϴ�

CI/CD����������/�������������������

![image-20220318161154990](images/image-20220318161154990.png)



## 1����������˾��ν��г�������

![image-20220318160527598](images/image-20220318160527598.png)

## 2����������˾��ν��г�������

### 2.1�������Զ������𷽷�

![image-20220318162034127](images/image-20220318162034127.png)

### 2.2����β��Բ����Ч��

- ���̷���

![image-20220318162528421](images/image-20220318162528421.png)

- ��˿ȸ����

![image-20220318162429520](images/image-20220318162429520.png)

- ���ܿ���



## 3��������Ŀ����ܹ�

����Jira��https://www.atlassian.com/software/jira

- Release����������λΪ��
  - Sprint����̣���λΪ��
    - Issue������
      - Epic��ʷʫ�����磬������˫ʮһҪ��һ���������
      - Story���û����£���Ʒ����
      - Task�����񣺿���
      - Bug�����ϣ�����



ÿ��վ�᣺

- Scrum Master����
- ����ÿ�����Ͼ���
- ÿ�˻ش�3������
  - ��������ʲô
  - ����Ҫ��ʲô
  - ��ʲô���⣬��Ҫʲô����

## 4���ڿ��������Ｏ��Jira���

- IDEA�����Jira Integration



## 5��Gitflow VS ���ɿ�����֧ģ��

### 5.1��ʲô��Gitflow�Լ�����

Gitflow��һ�ַ�֧����ģ�ͣ���Դ��Vincent Driessen�����£���A successful Git branching model"

- Master
- Develop
- Release
- Feature
- Hotfix

Gitflow���ó���

- ���������ȶ���Ҫ���
- �Ŷ����������з������������м��з�
- ��Դ��Ŀ

### 5.2��ʲô�����ɿ���ģʽ�Լ�����

���ܿ������������ɿ�����

```java
if (FeatureManager.isFeatureEnabled("NewLoginForm")) {
    openNewLoginForm();
} else {
    openOldLoginForm();
}
```

���ɿ�����֧ģ�����ó�����

- �����������Ͽ�
- �Ŷ��м��������з��϶࣬�����з�����
- ��������Ʒ



# һ������һ��Spring BootӦ��

![image-20220318172126929](images/image-20220318172126929.png)

## 1����Ŀ����ܹ�ͼ

![image-20220318172329781](images/image-20220318172329781.png)



## 2��������·׷��

![image-20220319083449424](images/image-20220319083449424.png)

- Docker��ʽ����Zipkin����

```bash
[emon@emon ~]$ docker run --name zipkin -d -p 9411:9411 openzipkin/zipkin
```

http://emon:9411/



# �������

## 1���Maven˽��

![image-20220319153242376](images/image-20220319153242376.png)

### 1.1��Maven˽������

- ����
  - ����Maven����ֿ⣬����Maven��������
  - ��Ϊ���ػ���������й�˾������
- ������Դ����
  - JFrog Artifactory��Դ��
  - Nexus



### 1.2���JFrog Artifactory OSS��Դ��

- ʹ��Docker

```docker
[emon@emon ~]$ docker run --name artifactory-oss-6.18.1 -d -p 8083:8081 docker.bintray.io/jfrog/artifactory-oss:6.18.1
```

http://emon:8083/

�û������룺admin/password ==> ��¼��ǿ���޸ģ��޸Ľ����admin/admin123

- ʹ�ð�װ��

https://jfrog.com/open-source/



![image-20220319160615339](images/image-20220319160615339.png)

- ���ʹ��JFrog��

��һ�������� http://emon:8083

�ڶ�����������Artifacts==>�Ҳ�ҳ����Set Me Up==>����ҳ���Generate Maven Settings==>Generate Settings

��������Download Snippet

```bash
# �����ɵ�Settings������ȥ
[emon@emon ~]$ vim .m2/settings.xml
```

### 1.3����˽������jar

```bash
# admin�������API Key��ȡ��ʽ����¼JFrog==>���Ͻ�Welcome,admin����==>Edit Profile==>���������Unlock==>�����������ͼ�갴ť���ɣ��������ɹ�ֱ�Ӹ��ƣ�
[emon@emon ~]$ curl -u admin:AKCp8krAbJnpHRmCxRwQyh2t58cC6Hn6zURWKFwMaHGKvG7LP7FHRzLVuMBsEYdGaGBFLpYVW http://emon:8083/artifactory/libs-release-local/com/coding/devops/notebook-service/1.0/notebook-service-1.0.jar --output notebook-service-1.0.jar
```



# ������������

![image-20220319175723995](images/image-20220319175723995.png)

## 1���Jenkins

### 1.1��Jenkins����

- Jenkins

  - Project��Ŀ
  - Build����
  - Workspace�����ռ�
    - ���������ʵ�ʹ���Ŀ¼
      - �洢����
      - �м���ʱ�ļ�

  - Credentialsƾ��
    - ���ڹ����û���������Ϣ
      - �û���������
      - SSH Key
      - ֤��



### 1.2���Jenkins

- ʹ��Docker

ע�⣬��hub.docker.com������jenkinsʱ������ٷ��汾�󿴵���ʾ��

DEPRECATED; use "jenkins/jenkins:lts" instead

```bash
# �������������ص�
[emon@emon ~]$ mkdir /usr/local/dockerv/jenkins_home
# -v /usr/local/dockerv/jenkins_home:/var/jenkins_home ָ��������Ŀ¼ΪJenkins����Ŀ¼
# -v /etc/localtime:/etc/localtime ������ʹ�úͷ�����ͬ����ʱ������
# -v /usr/local/maven:/usr/local/maven ӳ����������maven
# -v /usr/local/java:/usr/local/java ӳ����������java
# Ҳ����ʹ�� jenkins/jenkins:lts-centos7-jdk8 ����
[emon@emon ~]$ docker run --name jenkins -d -p 8080:8080 -p 50000:50000 -v /usr/local/dockerv/jenkins_home:/var/jenkins_home -v /etc/localtime:/etc/localtime -v /usr/local/maven:/usr/local/maven -v /usr/local/java:/usr/local/java jenkins/jenkins:lts
```

- �鿴����

```bash
[emon@emon ~]$ docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# ������������
a3ada16670124943be3412fa7400c7f2
```

���ʣ�http://emon:8080

��װ�Ƽ��Ĳ��==>�����û���jenkins/jenkins123

- ����Jenkins

http://emon:8080/restart



### 1.3�����ò����װ�뻷������

#### 1.3.1�����ò����װ

- Git

- Artifactory������ⰲװ
- Pipeline
- Jira������ⰲװ
- Ansible������ⰲװ
- Kubernetes������ⰲװ

- [ SonarQube Scanner](https://plugins.jenkins.io/sonar)

��װ��ɺ󣬵������װ��ɺ�����Jenkins������������������

#### 1.3.2����������

##### Global Tool Configuration��ȫ�ֹ������ã�

- ����JDK

����·����Manage Jenkins==>Global Tool Configuration==>JDK==>�����Զ���װ==>

JDK����=java

JAVA_HOME=/usr/local/java

- ����Maven

����·����Manage Jenkins==>Global Tool Configuration==>Maven==>�����Զ���װ==>

JDK����=maven

MAVEN_HOME=/usr/local/maven

##### Configure System��ϵͳ���ã�

- ȫ������==>��������

����·����Manage Jenkins==>Configure System==>��ѡ��������==>��Ӽ�ֵ���б�==>

JAVA_HOME=/usr/local/java

MAVEN_HOME=/usr/local/maven

PATH+EXTRA=$MAVEN_HOME/bin:$JAVA_HOME/bin

- ����JFrog

����·����Manage Jenkins==>Configure System==>JFrog==>Add JFrog Platform Instance==>

Instance Id=artifactory-oss

JFrog Platform URL=http://172.17.0.1:8083/artifactory

Default Deployer Credentials���ã�

Username=admin

Password=admin123



### 1.4��Jenkins����������ˮ�߽���

#### 1.4.1��Jenkins��Ŀ����

- Jenkins��Ŀ����
  - Freestyle��Ŀ
  - Maven��Ŀ
  - Pipeline��Ŀ����ˮ�ߣ�
  - �ⲿ�������



#### 1.4.2��Jenkins����������ˮ���ŵ�

- Pipeline as Code����ˮ�߼����룬����ɴ洢��git�ֿ⣩
- ����������ˮ����������л���������Jenkins Slave�ڵ㣩
- �͵��������ɸ������ף��ӿڵ��ã�



#### 1.4.3��Jenkins����������ˮ���﷨

- Scripted�ű�ʽ
  - ��ʹ������Groovy�ű�ʵ�ֹ��ܣ��ǳ����
  - ѧϰ�ɱ��ͣ������ƹ�
- Declarative����ʽ
  - ͨ��Ԥ�Ƶı�ǩ���нṹ���ı�д
  - �������ޣ������ӱ�׼��



### 1.5���ű�ʽ��ˮ��

```groovy
node { // �����ڵ�
    def mvnHome
    stage('Pull source code') {// ���岽��
        git 'https://github.com/EmonCodingBackEnd/backend-devops-learning.git'
        mvnHome = tool 'maven'
    }
    dir('notebook-service') { // �л�����Ŀ¼
        stage('Maven build') {
            sh '''
            mvn deploy // ִ��Maven����
            '''
        }
    }
}
```



### 1.6������ʽ��ˮ��

```groovy
pipeline { // ���
    agent { docker 'maven:3-alpine'} // ָ��Agent
    stages {
        stage('Example Build') { // ִ�н׶�
            steps {
                sh 'mvn -B clean verify' // ִ��Maven����
            }
        }
    }
}
```



## 2��Jenkins����Artifactory

![image-20220320105817043](images/image-20220320105817043.png)

### 2.1��JFrog Artifactory����

- Artifactory��֪������Ʒ������ߣ�����ͳһ��������԰�����������Ʒ���ṩMaven˽������Ʒ��Ĺ��ܡ�
- ����Nexus��Ҫ��������������ȱ������Ʒ�Ĺ�������Ȩ�ޣ�MD5��飬������Ϣ�ȵȣ��������������ҵ��ʹ��Artifactory���Nexus������ͳһ������������Ʒ�����

### 2.2��Jenkins���ɲ���

- ��װJenkins Artifactory���
- ����Artifactory���
- ����Artifactory credentials
- ����ˮ����ʹ��Artifactory�����������أ���Ʒ�ϴ�

### 2.3������ƾ��

����·����Manage Jenkins==>ManageCredentials==>���Ͻ�ƾ������ѡ��System��ϵͳ��==>����ѡ��ȫ��ƾ�ݣ�unrestricted��==>���ƾ��==>

![image-20220320103558461](images/image-20220320103558461.png)



### 2.4��Pipeline��ˮ��������Artifactory��Stage

```groovy
        //Maven ��������Ʒ�ϴ��� Artifactory
        stage('Maven build'){
            def server = Artifactory.newServer url: "http://172.17.0.1:8083/artifactory", credentialsId: 'artifactory-oss-apikey'
            def rtMaven = Artifactory.newMavenBuild()

            rtMaven.tool = 'maven' // Tool name from Jenkins configuration
            rtMaven.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot-local', server: server

            //�ռ�������Ϣ
            def buildInfo = Artifactory.newBuildInfo()
            // server.publishBuildInfo buildInfo
            rtMaven.run pom: 'pom.xml', goals: 'deploy -Dmaven.test.skip=true', buildInfo: buildInfo

            server.publishBuildInfo buildInfo
        }
```



## 3��Jenkins����Jira���Թ���

![image-20220320105739321](images/image-20220320105739321.png)

### 3.1��Jira����

- Jira��ҵ��֪�������������
- Jira�������ڹ���������Ŀ������׷�٣����������Ŀ���ȣ�����ȹ��ܣ��ʺ����ݿ����Ŷӽ���ʹ�á�

### 3.2��Jenkins���ɲ���

- ��װJenkins Jira���
- ����Jira credentials
- ����Jira���
- �ύ����ʱ������Jira����ID
- �ڹ�������в鿴����ID

## 4��Jenkins����Sonarqube

![image-20220320112656769](images/image-20220320112656769.png)



### 4.1��Sonarqube����

- Sonarqube��֪���Ŀ�ԴԴ����ɨ�蹤�ߡ�

- ���������Ŀ��Դ����ɨ�裬ʶ������������©�����ظ��ʵ����⣬���������������
- ԭ��
  - ͨ���������ص�ɨ�������Դ�������ɨ�裬������й����򴴽�һ��issue�����������߽����޸���

### 4.2���Sonarqube

- ʹ��Docker

```bash
[emon@emon ~]$ docker run --name sonarqube -d -p 9000:9000 library/sonarqube:lts
```

���ʣ�http://emon:9000

�û������룺admin/admin ==> ��¼����ʾ�޸����룺admin/admin123



## 5��Jenkins����YAPI

### 5.1��YAPI����

- YAPI��ȥ�Ķ���Դ�Ľӿ��Զ������Թ��ߣ� https://github.com/YMFE/yapi
- YAPI�Ǹ�Ч�����á�����ǿ���API����ƽ̨��ּ��Ϊ��������Ʒ��������Ա�ṩ�����ŵĽӿڹ�����񡣿�Դ�������������ɴ�����������ά��API��

## 6��Jenkins����Selenium

![image-20220320120728443](images/image-20220320120728443.png)



### 6.1��Selenium����

- Selenium�ǳ����UI�Զ����Թ�����Ŀ�� https://www.selenium.dev
- Selenium��Ŀ
  - WebDriver - �������������ģ�����
  - IDE - ͨ��ҳ�������в��Խű���¼��
  - Grid - ֧�ֿ�ƽ̨�������������в���



# �ġ���������

![image-20220320120916693](images/image-20220320120916693.png)



## 1��Ansible���

### 1.1��Ansible����

Ansible���³��ֵ��Զ�����ά���ߣ�����Python�������������ڶ���ά���ߣ�puppet��chef��func��fabric�����ŵ㣬ʵ����ƥ��ϵͳ���á�����������������������ȹ��ܡ�

Ansible�ǻ���paramiko�����ģ����һ���ģ�黯����������û������������������������������������Ansible�����е�ģ�飬Ansibleֻ���ṩһ�ֿ�ܡ�Ansible����Ҫ��Զ�������ϰ�װClient/Agents����Ϊ�����ǻ���ssh����Զ������ͨѶ�ġ�

AnsibleĿǰ�Ѿ�����ñ�ٷ��չ������Զ�����ά�����д���Ͽɶ���ߵģ������������ף�ѧϰ�򵥡���ÿλ��ά����ʦ�������յļ���֮һ��

### 1.2��Ansible���ŵ�

- ����򵥣�ֻ��Ҫ�����ض˲���Ansible���������ض��������κβ�����
- Ĭ��ʹ��SSHЭ����豸���й���
- �д���������ά����ģ�飬����ʵ���ճ����󲿷ֲ�����
- ���ü򵥡�����ǿ����չ��ǿ��
- ֧��API���Զ���ģ�飬��ͨ��Python������չ��
- ͨ��Playbooks���籾��������ǿ������á�״̬����
- �������������ڿͻ��˰�װAgent������ʱ��ֻ��Ҫ�ڲ������Ͻ���һ�θ��¼��ɣ�
- �ṩһ������ǿ�󡢲�����ǿ��Web��������REST API�ӿڡ���AWXƽ̨��

- ͨ��Ansible Galaxy�ɻ�ȡ��Դ���������Playbook�������ظ��쳵�֡�

### 1.3��Ansible�ܹ�ͼ

![img](images/1204916-20171205163000628-69838828.png)

��ͼ�����ǿ�������Ҫģ�����£�

- Ansible��Ansible���ĳ���
- HostInventory����¼��Ansible�����������Ϣ�������˿ڡ����롢IP�ȡ�
- Playbooks�����籾��YAML��ʽ�ļ��������������һ���ļ��У�����������Ҫ������Щģ������ɵĹ��ܡ�
- CoreModules������ģ�飬��Ҫ������ͨ�����ú���ģ������ɹ�������
- CustomModules���Զ���ģ�飬��ɺ���ģ���޷���ɵĹ��ܣ�֧�ֶ������ԡ�
- ConnectionPlugins�����Ӳ����Ansible��Hostͨ��ʹ�á�



### 1.4��Ansible�ĺ��ĸ���

- Control node�����ƽڵ�
  - Ansible��װ�Ļ�������������������playbook��
  - �κΰ�װ��Python�Ļ������ܰ�װAnsible��-laptops��shared desktops��and servers��
  - ��������Windows machine��Ϊ���ƽڵ㡣
- Managed nodes���ܹܿؽڵ�
  - ʹ��Ansible�ܿص��豸������
  - �ܹܿؽڵ�Ҳ����֮Ϊ`hosts`
  - Ansible����װ���ܹܿؽڵ�
- Inventory������
  - �ܹܿؽڵ���б�
  - �����ļ�Ҳ����`hostfile`����Ŀ���ļ�����ָ���ܹܿػ�����IP��
  - ����Ҳ���Թ���ڵ㣬�������飬������������
- Modules��ģ��
  - Ansibleͨ��ģ����ִ���ض����
  - ÿ��ģ�����ض����ô���
  - �������һ�������е���ĳ��ģ�飬Ҳ������playbook�е��ö��ģ�顣
- Tasks������
  - Ansible�е�����Ԫ��������������ִ��һ��ad-hoc���
- Playbooks���籾
  - ����ı��Žű������ڶ��ڵ���������һϵ�е�����Playbooks���԰���������һ���ı������ݡ�
  - ��YAML��д�����ڱ�д������



## 2��Ansible����ִ��

### 2.1��Ansible����ִ��ģʽ

Ansibleϵͳ�ɿ��������Ա��ܽڵ�Ĳ�����ʽ�ɷ�Ϊ���ࣺ`adhoc`��`playbook`��

- ad-hocģʽ����Ե�ģʽ��

ʹ�õ���ģ�飬֧������ִ�е������ad-hoc������һ�ֿ��Կ��������������Ҳ���Ҫ����������������൱��bash�е�һ�仰shell��

- playbookģʽ���籾ģʽ��

��ģʽ��Ansible��Ҫ����ʽ��Ҳ��Ansible����ǿ��Ĺؼ����ڡ�playbookͨ�����task�������һ�๦�ܣ���Web����İ�װ�������ݿ���������������ݵȡ����Լ򵥵ذ�palybook���Ϊͨ����϶���ad-hoc�����������ļ���

### 2.2��Ansibleִ������

![img](images/1204916-20171205162615738-1292598736.png)

��������Ansible������ʱ�����ȶ�ȡ`ansible.cfg`�е����ã����ݹ����ȡ`Inventory`�еĹ��������б����е�����Щ������ִ�����õ��������ȴ�ִ�з��صĽ����



### 2.3��Ansible����ִ�й���

1. �����Լ��������ļ���Ĭ��`/etc/ansible/ansible.cfg`��
2. ���Ҷ�Ӧ�����������ļ����ҵ�Ҫִ�е����������飻
3. �����Լ���Ӧ��ģ���ļ�����command��
4. ͨ��ansible��ģ����������ɶ�Ӧ����ʱpy�ļ���python�ű������������ļ�������Զ�̷�������
5. ��Ӧִ���û��ļ�Ŀ¼��`.ansible/tmp/XXX/XXX.PY`�ļ���
6. ���ļ�+xִ��Ȩ�ޣ�
7. ִ�в����ؽ����
8. ɾ����ʱpy�ļ���`sleep 0`�˳���

## 3��Ansible�������

### 3.1��Ansible��װ��ʽ

Ansible��װ�������ַ�ʽ��`yum��װ`��`pip����װ`��

#### 3.1.1��ʹ��pip��python�İ�����ģ�飩��װ

���ȣ�������Ҫ��װһ��Python3.8���ϰ汾�İ�����װ����Ժ���ֱ��ʹ��`pip`���װansible���ɣ�

```bash
[emon@emon ~]$ pip3 install ansible
```

#### 3.1.2��ʹ��yum��װ���Ƽ���

yum��װ�����Ǻ���Ϥ�İ�װ��ʽ�ˡ�������Ҫ�Ȱ�װһ��epel-release�����ٰ�װ���ǵ�ansible���ɡ�

```bash
[emon@emon ~]$ sudo yum install -y epel-release
[emon@emon ~]$ sudo yum install -y ansible
```

### 3.2��Ansible����ṹ

��װĿ¼���£�yum��װ����

| Ŀ¼                                      | ˵��          |
| ----------------------------------------- | ------------- |
| /etc/ansible/                             | �����ļ�Ŀ¼  |
| /usr/bin/                                 | ִ���ļ�Ŀ¼  |
| /usr/lib/pythonX.X/site-packages/ansible/ | Lib������Ŀ¼ |
| /usr/share/doc/ansible-X.X.X/             | Help�ĵ�Ŀ¼  |
| /usr/share/man/man1/                      | Man�ĵ�Ŀ¼   |

### 3.3��Ansible�����ļ�����˳��

Ansible�����������ķ�������һ�����кܴ�ͬ������������ļ������ǴӶ���ط��ҵģ�˳�����£�

1. ��黷�ڱ���`ANSIBLE_CONFIG`ָ���·���ļ���export ANSIBLE_CONFIG=/etc/ansible/ansible.cfg����
2. `~/.ansible.cfg`����鵱ǰĿ¼�µ�ansible.cfg�����ļ���
3. `/etc/ansible/ansible.cfg`���etcĿ¼�������ļ�

### 3.4��Ansible�����ļ�

Ansible�������ļ�Ϊ`/etc/ansible/ansible.cfg`��ansible�������������������г�һЩ�����Ĳ�����

```ini
inventory = /etc/ansible/hosts	#���������ʾ��Դ�嵥inventory�ļ���λ��
library = /usr/share/ansible	#ָ����Ansibleģ���Ŀ¼��֧�ֶ��Ŀ¼��ʽ��ֻҪ��ð�ţ����������Ϳ���
forks = 5						#������������Ĭ��Ϊ5
sudo_user = root				#����Ĭ��ִ��������û�
remote_port = 22				#ָ�����ӱ��ܽڵ�Ĺ���˿ڣ�Ĭ��Ϊ22�˿ڣ������޸ģ��ܹ����Ӱ�ȫ
host_key_checking = False		#�����Ƿ���SSH��������Կ��ֵΪTrue/False���رպ��һ�����Ӳ�����ʾ����ʵ��
timeout = 60					#����SSH���ӵĳ�ʱʱ�䣬��λΪ��
log_path = /var/log/ansible.log	#ָ��һ���洢ansible��־���ļ���Ĭ�ϲ���¼��־��
```

### 3.5��Ansible�����嵥

�������ļ��У������ᵽ����Դ�嵥������嵥�������ǵ������嵥�����汣�����һЩansible��Ҫ���ӹ���������б����ǿ������������Ķ��巽ʽ��

```bash
1�� ֱ��ָ��������ַ����������
	## green.example.com#
	# blue.example.com#
	# 192.168.100.1
	# 192.168.100.10
2�� ����һ��������[����]�ѵ�ַ���������ӽ�ȥ
	[mysql_test]
	192.168.253.159
	192.168.253.160
	192.168.253.153
```

��Ҫע����ǣ���������Ա����ʹ��ͨ�����ƥ�䣬��������һЩ��׼���Ĺ�����˵�ͺ����ɷ����ˡ�

���ǿ��Ը���ʵ��������������ǵ������б�����������£�

```bash
[emon@emon ~]$ sudo mkdir /etc/ansible
[emon@emon ~]$ sudo vim /etc/ansible/hosts
```

```ini
[web]
emon2
emon3
```

������Hosts�����о����õ��ı������֣�

| ����                         | ����                                                         |
| ---------------------------- | ------------------------------------------------------------ |
| ansible_ssh_host             | ����ָ�����������������ʵIP                                 |
| ansible_ssh_port             | ����ָ�����ӵ�������������ssh�˿ںţ�Ĭ����22                |
| ansible_ssh_user             | ssh����ʱĬ��ʹ�õ��û���                                    |
| ansible_ssh_pass             | ssh����ʱ������                                              |
| ansible_sudo_pass            | ʹ��sudo�����û�ʱ������                                     |
| ansible_sudo_exec            | ���sudo�����Ĭ��·������Ҫָ��sudo����·��               |
| ansible_ssh_private_key_file | ��Կ�ļ�·������Կ�ļ��������ʹ��ssh-agent����ʱ����ʹ�ô�ѡ�� |
| ansible_shell_type           | Ŀ��ϵͳ��shell�����ͣ�Ĭ��sh                                |
| ansible_connection           | SSH ���ӵ����ͣ�local , ssh , paramiko����ansible1.2֮ǰĬ����paramiko ����������ѡ������ʹ�û���ControlPersist ��ssh |
| ansible_python_interpreter   | ����ָ��python��������·����Ĭ��Ϊ/usr/bin/python ͬ������ָ��ruby ��perl��·�� |
| `ansible_*_interpreter`      | ����������·�����÷���ansible_python_interpreter���ƣ�����"*"������ruby��perl���������� |

## 4��Ansible��������

### 4.1��ansible���

```bash
# -1����-l
[emon@emon ~]$ ls -1 /usr/local/python3/bin/ansible*
# ������������������ AD-hoc����ʾ��ʱ����ģʽ
/usr/local/python3/bin/ansible # Ansible AD-Hoc��ʱ����ִ�й��ߣ���������ʱ�����ִ��
/usr/local/python3/bin/ansible-config 
/usr/local/python3/bin/ansible-connection
/usr/local/python3/bin/ansible-console # Ansible����Linux Console��������û�����������ִ�й���
/usr/local/python3/bin/ansible-doc # Ansibleģ�鹦�ܲ鿴����
/usr/local/python3/bin/ansible-galaxy # ����/�ϴ���������Rolesģ��Ĺ���ƽ̨�����������
/usr/local/python3/bin/ansible-inventory
/usr/local/python3/bin/ansible-playbook # Ansible�����Զ��������񼯱��Ź���
/usr/local/python3/bin/ansible-pull # AnsibleԶ��ִ������Ĺ��ߣ���ȡ���ö����������ã�ʹ�ý��٣���������ʱʹ�ã�����ά�ļܹ�����Ҫ��ϸߣ�
/usr/local/python3/bin/ansible-test
/usr/local/python3/bin/ansible-vault # Ansible�ļ����ܹ���
```

���У����ǱȽϳ��õ���`ansible`��`ansible-playbook`���

### 4.2��ansible-doc����

ansible-doc������ڻ�ȡģ����Ϣ����ʹ�ð�����һ���÷����£�

```bash
ansible-doc -l # ��ȡȫ��ģ�����Ϣ
ansible-doc -s MOD_NAME # ��ȡָ��ģ���ʹ�ð���
ansible-doc -h # ��ȡansible-doc�����ȫ���÷�
```

- ���磬��mysql_userģ��Ϊ��

```bash
[emon@emon ~]$ ansible-doc -s mysql_user
```

### 4.3��ansible�������

- ����ľ����ʽ���£�

```bash
ansible <host-pattern> [-f forks] [-m module_name] [-a args]
```

Ҳ����ͨ��`ansible -h`���鿴�����������г�һЩ����ѡ����ͺ��壺

```bash
-a MODULE_ARGS # ģ��Ĳ��������ִ��Ĭ��COMMAND��ģ�飬��������������磺date��pwd�ȵ�
-k, --ask-pass # ask for SSH password����¼���룬��ʾ����SSH��������Ǽ��������Կ����֤��Сд��k
-b, --become # ��Ȩ������ִ��������-K��������ʱ���������
-K, --ask-become-pass # ����Ȩ������ʱ�������룬��д��K

-f FORKS # ������������Ĭ��Ϊ5
-i INVENTORY # ָ�������嵥��·����Ĭ��Ϊ `/etc/ansible/hosts`
--list-hosts # �鿴����Щ������

-m MODULE_NAME # ִ��ģ������֣�Ĭ��ʹ��commandģ�飬���������ִֻ�е�һ������Բ���-m����
-o # ѹ����������Խ����н����һ�������һ������ռ�����ʹ��
-v # �鿴��ϸ��Ϣ��ͬʱ֧��-vvv��-vvvv�ɲ鿴����ϸ��Ϣ

-T TIMEOUT # ����ʱָ��sshĬ�ϳ�ʱʱ�䣬Ĭ��Ϊ10s��Ҳ�����������ļ����޸�
-u REMOTE_USER # ����ʱ���õ�Զ���û���Ĭ��Ϊ��ǰ�û�
```

### 4.4��Ansible���ù�˽Կ

���������Ѿ��ᵽ��Ansible�ǻ���SSHЭ��ʵ�ֵģ����������ù�˽Կ�ķ�ʽ��SSHЭ��ķ�ʽ��ͬ����������������£�

1. ����˽Կ

```bash
[emon@emon ~]# ssh-keygen
```

2. �������ַ���Կ

```bash
[emon@emon ~]# ssh-copy-id -i root@emon2
[emon@emon ~]# ssh-copy-id -i root@emon3
```

�����Ļ����Ϳ���ʵ���������¼��

�����ʾû��ssh-copy-id������԰�װ��

```bash
yum -y install openssh-clientsansible
```

## 5��Ansible����ģ��

### 5.1��������ͨ�Բ���

ʹ��`ansible web -m ping`����������������ͨ�Բ��ԣ�Ч�����£�

```bash
[emon@emon ~]#  ansible web -m ping
emon3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
emon2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```

### 5.2��commandģ��

���ģ�����ֱ����Զ��������ִ���������������ر�������

- �������£�

```bash
# -b -K ��ʾ����Ȩ��ִ�У�K�Ǵ�д��ĸ
[emon@emon ~]$ ansible web -m command -a 'ss -ntl' -b -K
emon3 | CHANGED | rc=0 >>
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN     0      100    127.0.0.1:25                       *:*                  
LISTEN     0      128          *:22                       *:*                  
LISTEN     0      100      [::1]:25                    [::]:*                  
LISTEN     0      128       [::]:22                    [::]:*                  
emon2 | CHANGED | rc=0 >>
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN     0      100    127.0.0.1:25                       *:*                  
LISTEN     0      128          *:22                       *:*                  
LISTEN     0      100      [::1]:25                    [::]:*                  
LISTEN     0      128       [::]:22                    [::]:* 
```

����ģ������������ƣ������ǿո�ָ����б���������������������ѡ���Ľڵ���ִ�С�������ͨ��shell���д�������$HOME�Ͳ�����"<",">","|",";","&"��������Ҫʹ�ã�shell��ģ��ʵ����Щ���ܣ���ע�⣬�����֧��`|`�ܵ����

��������һ����ģ���³��õļ������

> chdir # ��ִ������֮ǰ�����л�����Ŀ¼
>
> executable # �л�shell��ִ�������Ҫʹ������ľ���·��
>
> free_form # Ҫִ�е�Linuxָ�һ��ʹ��Ansible��-a��������
>
> creates # һ���ļ�����������ļ����ڣ���������һ�£������������ж�
>
> removes # һ���ļ���������ļ������ڣ�������ִ��

����������������Щ�����ִ��Ч����

```bash
# ��emon2�ϴ���Ŀ¼
[root@emon2 ~]# mkdir /data/abc

# ���л���/data/Ŀ¼����ִ�С�ls������
[emon@emon ~]$ ansible web -m command -a 'chdir=/data/ ls'
# ���ָ��Ŀ¼���ڣ���ִ������
[emon@emon ~]$ ansible web -m command -a 'creates=/data/ ls'
emon2 | SUCCESS | rc=0 >>
skipped, since /data/ existsDid not run command since '/data/' exists
emon3 | CHANGED | rc=0 >>
bin
# ���ָ��Ŀ¼�����ڣ���ִ������
[emon@emon ~]$ ansible web -m command -a 'removes=/data/ ls'
emon2 | CHANGED | rc=0 >>
bin
emon3 | SUCCESS | rc=0 >>
skipped, since /data/ does not existDid not run command since '/data/' does not exist
```

### 5.3��shellģ��

shellģ�������Զ�������ϵ���shell�������������֧��shell�ĸ��ֹ��ܣ�����ܵ��ȡ�

```bash
[emon@emon ~]$ ansible web -m shell -a 'cat /etc/passwd|grep "emon"'
emon3 | CHANGED | rc=0 >>
daemon:x:2:2:daemon:/sbin:/sbin/nologin
emon:x:1000:1000:Web Site User:/home/emon:/bin/bash
emon2 | CHANGED | rc=0 >>
daemon:x:2:2:daemon:/sbin:/sbin/nologin
emon:x:1000:1000:Web Site User:/home/emon:/bin/bash

[emon@emon ~]$ ansible web -m shell -a 'ss -ntl' -b -K
```

ֻҪ�����ǵ�shell���������ͨ�����ģ����Զ�����������С�

### 5.4��copyģ��

���ģ�����ڽ��ļ����Ƶ�Զ��������ͬʱ֧�ָ������������ļ����޸�Ȩ�޵ȡ�

�����ѡ�����£�

> src #�����Ƶ�Զ�������ı����ļ��������Ǿ���·����Ҳ���������·�������·����һ��Ŀ¼�����ݹ鸴�ƣ��÷�������"rsync"
>
> content #�����滻"src"������ֱ��ָ���ļ���ֵ
>
> dest # ��ѡ���Դ�ļ����Ƶ�Զ�������ľ���·��
>
> backup # ���ļ����ݷ����ı���ڸ���֮ǰ��Դ�ļ����ݣ������ļ�����ʱ����Ϣ
>
> directory_mode # �ݹ��趨Ŀ¼��Ȩ�ޣ�Ĭ��ΪϵͳĬ��Ȩ��
>
> force # ��Ŀ�������������ļ��������ݲ�ͬʱ������Ϊ"yes"����ʾǿ�Ƹ��ǣ�����Ϊ"no"����ʾĿ��������Ŀ��λ�ò����ڸ��ļ��Ÿ��ơ�Ĭ��Ϊ"yes"
>
> others # ���е�fileģ���е�ѡ�����������ʹ��

�÷��������£�

- �����ļ�

```bash
[emon@emon ~]$ ansible web -m copy -a 'src=~/notebook-service-1.0.jar dest=~/'
```

- �������������ļ�����ָ��Ȩ��

```bash
[emon@emon ~]$ ansible web -m copy -a 'content="hello world!\n" dest=~/test.txt mode=666'
```

- ���ڸ���

���ǰ��ļ��������޸�һ�£�Ȼ��ѡ�񸲸Ǳ��ݣ�

```bash
[emon@emon ~]$ ansible web -m copy -a 'content="hello world!\ngood!" backup=yes dest=~/test.txt mode=666'
# �鿴һ��
[emon@emon ~]$ ansible web -m shell -a 'ls -l ~/|grep test'
emon3 | CHANGED | rc=0 >>
-rw-rw-rw-. 1 emon emon       18 3��  20 23:49 test.txt
-rw-rw-rw-. 1 emon emon       13 3��  20 23:45 test.txt.71549.2022-03-20@23:49:21~
emon2 | CHANGED | rc=0 >>
-rw-rw-rw-. 1 emon emon       18 3��  20 23:49 test.txt
-rw-rw-rw-. 1 emon emon       13 3��  20 23:45 test.txt.121900.2022-03-20@23:49:35~
```

### 5.5��fileģ��

��ģ����Ҫ���������ļ������ԣ����紴���ļ������������ļ���ɾ���ļ��ȡ�

������һЩ�������

> force # ��Ҫ�����������ǿ�ƴ��������ӣ�һ����Դ�ļ������ڣ���֮��Ὠ��������£���һ����Ŀ���������Ѵ��ڣ���Ҫ��ȡ��֮ǰ�������ӣ�Ȼ�󴴽��µ������ӣ�������ѡ�yes|no
>
> group # �����ļ�/Ŀ¼�����顣������Լ���`mode`�������ļ�/Ŀ¼��Ȩ��
>
> owner # �����ļ�/Ŀ¼������������������`path`�������ļ�/Ŀ¼��·��
>
> recurse # �ݹ������ļ������ԣ�ֻ��Ŀ¼��Ч���������`src`�������ӵ�Դ�ļ�·����ֻӦ����`state=link`�����
>
> dest # �����ӵ���·����ֻӦ����`state=link`�����
>
> state # ״̬��������ѡ�
>
> > directory�����Ŀ¼�����ڣ��ʹ���Ŀ¼
> >
> > file����ʹ�ļ������ڣ�Ҳ���ᱻ����
> >
> > link������������
> >
> > hard������Ӳ����
> >
> > touch������ļ������ڣ���ᴴ��һ���µ��ļ�������ļ���Ŀ¼�Ѵ��ڣ������������޸�ʱ��
> >
> > absent��ɾ��Ŀ¼���ļ�����ȡ�������ļ�

- ����Ŀ¼

```bash
[emon@emon ~]$ ansible web -m file -a 'path=~/data/app state=directory'
```

- ���������ļ�

```bash
# Ч����bbb.jpg -> aaa.jpg 
[emon@emon ~]$ ansible web -m file -a 'path=~/data/bbb.jpg force=yes src=aaa.jpg state=link'
```

- ɾ���ļ�

```bash
[emon@emon ~]$ ansible web -m file -a 'path=~/data/a state=absent'
```

### 5.6��fetchģ��

��ģ�����ڴ�Զ��ĳ������ȡ�����ƣ��ļ������ء�

������ѡ�

> dest����������ļ���Ŀ¼
>
> src����Զ����ȡ���ļ������ұ�����һ��file��������Ŀ¼

- ����Զ���ļ�������

```bash
[emon@emon ~]$ ansible web -m fetch -a 'src=~/test.txt dest=~/data'
# �鿴���
[emon@emon ~]$ tree data
data
������ emon2
��?? ������ home
��??     ������ emon
��??         ������ test.txt
������ emon3
    ������ home
        ������ emon
            ������ test.txt
```

### 5.7��cronģ��

��ģ�������ڹ���`cron`�ƻ�����ġ�

��ʹ�õ��﷨�����ǵ�`crontab`�ļ��е��﷨һ�£�ͬʱ������ָ������ѡ�

> day�� ��Ӧ�����еĹ�����`1-31,*,*/2`��
>
> hour��Сʱ��`0-23,*,*/2`��
>
> minute����֧��`0-59,*,*/2`��
>
> mouth���£�`1-12,*,*/2`��
>
> weekday���ܣ�`0-6 for Sunday-Saturday`��
>
> job��ָ�����е�������ʲô
>
> name����ʱ��������
>
> reboot������������ʱ���У�������ʹ�ã�����ʹ��special_time
>
> special_time�������ʱ�䷶Χ��������reboot������ʱ����annually��ÿ�꣩��monthly��ÿ�£���weekly��ÿ�ܣ���daily��ÿ�죩��hourly��ÿСʱ��
>
> state��ָ��״̬��present��ʾ��Ӷ�ʱ����Ҳ��Ĭ�����ã�absent��ʾɾ����ʱ����
>
> user�����ĸ��û������ִ��

- ��Ӽƻ�����

```bash
[emon@emon ~]$ ansible web -m cron -a 'name="ntp update every 5 min" minute=*/5 job="/usr/sbin/ntpdate 172.17.0.1 &> /dev/null"'
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'crontab -l'
emon2 | CHANGED | rc=0 >>
#Ansible: ntp update every 5 min
*/5 * * * * /usr/sbin/ntpdate 172.17.0.1 &> /dev/null
emon3 | CHANGED | rc=0 >>
#Ansible: ntp update every 5 min
*/5 * * * * /usr/sbin/ntpdate 172.17.0.1 &> /dev/null
```

- ɾ���ƻ�����

������ǵļƻ�������Ӵ�����Ҫɾ���Ļ�����ִ�����²�����

```bash
# ע�⣬��ͬ�������state=absent����ɾ����ʱ������
[emon@emon ~]$ ansible web -m cron -a 'name="ntp update every 5 min" minute=*/5 job="/usr/sbin/ntpdate 172.17.0.1 &> /dev/null" state=absent'
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'crontab -l'
emon2 | CHANGED | rc=0 >>

emon3 | CHANGED | rc=0 >>
```

### 5.8��yumģ��

����˼�壬��ģ����Ҫ��������İ�װ��

��ѡ�����£�

> name������װ�İ�������
>
> state��present-��װ��latest-��װ���µģ�absent-ж�������
>
> update_cache��ǿ�Ƹ���yum�Ļ���
>
> conf_file��ָ��Զ��yum��װʱ�������������ļ�����װ�������еİ�����
>
> disable_pgp_check���Ƿ��ֹGPG checking��ֻ����present or latest
>
> disablerepo����ʱ��ֹʹ�õ�yum�⡣ֻ���ڰ�װ�����ʱ��
>
> enablerepo����ʱʹ�õ�yum�⡣ֻ���ڰ�װ�����ʱ��

- ��װһ��������

```bash
# �鿴Ŀ������Ƿ��иð�
[emon@emon ~]$ ansible web -m shell -a 'yum list epel-release'
# ��װ
[emon@emon ~]$ ansible web -m yum -a 'name=epel-release state=present' -b -K
```

- ��װhtop����ж��

```bash
# ��װ
[emon@emon ~]$ ansible web -m yum -a 'name=htop state=present' -b -K
# ж��
[emon@emon ~]$ ansible web -m yum -a 'name=htop state=absent' -b -K
```

### 5.9��serviceģ��

��ģ�����ڷ������Ĺ���

����Ҫѡ�����£�

> arguments���������ṩ����Ĳ���
>
> enabled�����ÿ�������
>
> name����������
>
> runlevel�����������ļ���һ�㲻��ָ����
>
> sleep������������Ĺ����У��Ƿ�ȴ������ڷ���ر��Ժ��ٵȴ�2�����������������ھ籾�С���
>
> state��������״̬���ֱ�Ϊ��started-��������stopped-ֹͣ����restarted-��������reloaded-��������

- ������������������

```bash
[emon@emon ~]$ ansible web -m service -a 'name=docker state=started enabled=true' -b -K
```

- �رշ���ȡ��������

```bash
[emon@emon ~]$ ansible web -m service -a 'name=docker state=stopped enabled=false' -b -K
```

### 5.10��userģ��

��ģ����Ҫ�����������û��˺š�

����Ҫѡ�����£�

> comment���û���������Ϣ
>
> createhome���Ƿ񴴽���Ŀ¼
>
> force����ʹ��state=absentʱ����Ϊ��userdel -forceһ��
>
> group��ָ��������
>
> groups��ָ�������飬���ָ��Ϊ��groups=����ʾɾ��������
>
> home��ָ���û���Ŀ¼
>
> move_home���������Ϊhome=ʱ����ͼ���û���Ŀ¼�ƶ���ָ����Ŀ¼
>
> name��ָ���û���
>
> non_unique����ѡ������ı��Ψһ���û�IDֵ
>
> password��ָ���û�����
>
> remove����ʹ��state=absentʱ����Ϊ����userdel -removeһ��
>
> shell��ָ��Ĭ��shell
>
> state�������˺�״̬����ָ��Ϊ������ָ��ֵΪabsent��ʾɾ����
>
> system��������һ���û�����������û���ϵͳ�û���������ò��ܸ��������û�
>
> uid��ָ���û���uid

- ���һ���û���ָ����uid

```bash
[emon@emon ~]$ ansible web -m user -a 'name=keer uid=11111' -b -K
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'cat /etc/passwd|grep keer'
emon2 | CHANGED | rc=0 >>
keer:x:11111:11111::/home/keer:/bin/bash
emon3 | CHANGED | rc=0 >>
keer:x:11111:11111::/home/keer:/bin/bash
```

- ɾ���û�

```bash
[emon@emon ~]$ ansible web -m user -a 'name=keer state=absent' -b -K
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'cat /etc/passwd|grep keer'
emon2 | FAILED | rc=1 >>
non-zero return code
emon3 | FAILED | rc=1 >>
non-zero return code
```

### 5.11��groupģ��

��ģ����Ҫ������ӻ�ɾ���顣

���õ�ѡ�����£�

> gid���������GID��
>
> name��ָ���������
>
> state��ָ�����״̬��Ĭ��Ϊ����������ΪabsentΪɾ��
>
> system������ֵΪyes����ʾ����Ϊϵͳ�顣

- ������

```bash
[emon@emon ~]$ ansible web -m group -a 'name=songuo gid=12222' -b -K
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'cat /etc/group|grep 12222'
emon2 | CHANGED | rc=0 >>
songuo:x:12222:
emon3 | CHANGED | rc=0 >>
songuo:x:12222:
```

- ɾ����

```bash
[emon@emon ~]$ ansible web -m group -a 'name=songuo state=absent' -b -K
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'cat /etc/group|grep 12222'
emon3 | FAILED | rc=1 >>
non-zero return code
emon2 | FAILED | rc=1 >>
non-zero return code
```

### 5.12��scriptģ��

��ģ�����ڽ������Ľű��ڱ�����˵Ļ��������С�

��ģ��ֱ��ָ���ű���·�����ɣ�����ͨ����������һ���������ʹ�õģ�

���ȣ�����дһ���ű������������ִ��Ȩ�ޣ�

```bash
[emon@emon ~]$ vim /tmp/df.sh
```

```bash
#!/bin/bash

date >> /tmp/disk_total.log
df -lh >> /tmp/disk_total.log
```

```bash
[emon@emon ~]$ chmod +x /tmp/df.sh
```

Ȼ������ֱ������������ʵ���ڱ������ִ�иýű���

```bash
[emon@emon ~]$ ansible web -m script -a '/tmp/df.sh'
# �鿴���
[emon@emon ~]$ ansible web -m shell -a 'cat /tmp/disk_total.log'
emon3 | CHANGED | rc=0 >>
2022�� 03�� 21�� ����һ 13:19:04 CST
�ļ�ϵͳ                 ����  ����  ���� ����% ���ص�
devtmpfs                 898M     0  898M    0% /dev
tmpfs                    910M     0  910M    0% /dev/shm
tmpfs                    910M   26M  885M    3% /run
tmpfs                    910M     0  910M    0% /sys/fs/cgroup
/dev/mapper/centos-root   30G   71M   30G    1% /
/dev/mapper/centos-usr    89G  7.0G   83G    8% /usr
/dev/loop0               4.4G  4.4G     0  100% /media/cdrom
/dev/mapper/centos-home   10G   97M  9.9G    1% /home
/dev/mapper/centos-tmp   5.0G   33M  5.0G    1% /tmp
/dev/sda1               1014M  150M  865M   15% /boot
/dev/mapper/centos-var    10G  1.8G  8.3G   18% /var
tmpfs                    182M     0  182M    0% /run/user/0
tmpfs                    182M     0  182M    0% /run/user/1000
emon2 | CHANGED | rc=0 >>
2022�� 03�� 21�� ����һ 13:19:04 CST
�ļ�ϵͳ                 ����  ����  ���� ����% ���ص�
devtmpfs                 898M     0  898M    0% /dev
tmpfs                    910M     0  910M    0% /dev/shm
tmpfs                    910M   18M  893M    2% /run
tmpfs                    910M     0  910M    0% /sys/fs/cgroup
/dev/mapper/centos-root   30G   71M   30G    1% /
/dev/mapper/centos-usr    89G  9.0G   80G   11% /usr
/dev/loop0               4.4G  4.4G     0  100% /media/cdrom
/dev/sda1               1014M  150M  865M   15% /boot
/dev/mapper/centos-home   10G   97M  9.9G    1% /home
/dev/mapper/centos-var    10G  2.0G  8.0G   20% /var
/dev/mapper/centos-tmp   5.0G   96M  4.9G    2% /tmp
tmpfs                    182M     0  182M    0% /run/user/0
tmpfs                    182M     0  182M    0% /run/user/1000
```

���Կ��֣��Ѿ�ִ�гɹ���

### 5.13��setupģ��

��ģ����Ҫ�����ռ���Ϣ����ͨ������facts�����ʵ�ֵġ�

facts�����Ansible���ڲɼ����ܻ����豸��Ϣ��һ�����ܣ����ǿ���ʹ��setupģ��鿴����������facts��Ϣ������ʹ��filter���鿴ָ����Ϣ������facts��Ϣ����װ��һ��JSON��ʽ�����ݽṹ�У�ansible_facts�����ϲ��ֵ��

facts���Ǳ������ڽ�������ÿ�������ĸ�����Ϣ��cpu�������ڴ��С�ȡ������facts�е�ĳ�������С����ú󷵻غܶ��Ӧ��������Ϣ���ں���Ĳ����п��Ը��ݲ�ͬ����Ϣ������ͬ�Ĳ�������redhatϵ����yum��װ����debianϵ����apt��װ�����

- �鿴��Ϣ

���ǿ���ֱ���������ȡ��������ֵ�������������������ӣ�

```bash
# �鿴�ڴ�
[emon@emon ~]$ ansible web -m setup -a 'filter="*mem*"'
emon2 | SUCCESS => {
    "ansible_facts": {
        "ansible_memfree_mb": 524,
        "ansible_memory_mb": {
            "nocache": {
                "free": 1462,
                "used": 357
            },
            "real": {
                "free": 524,
                "total": 1819,
                "used": 1295
            },
            "swap": {
                "cached": 0,
                "free": 5116,
                "total": 5119,
                "used": 3
            }
        },
        "ansible_memtotal_mb": 1819,
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
emon3 | SUCCESS => {
    "ansible_facts": {
        "ansible_memfree_mb": 386,
        "ansible_memory_mb": {
            "nocache": {
                "free": 1431,
                "used": 388
            },
            "real": {
                "free": 386,
                "total": 1819,
                "used": 1433
            },
            "swap": {
                "cached": 0,
                "free": 5117,
                "total": 5119,
                "used": 2
            }
        },
        "ansible_memtotal_mb": 1819,
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false
}
# ʹ��free -m��ʽ��ѯ�Ա���
[emon@emon ~]$ ansible web -m shell -a 'free -m'
emon2 | CHANGED | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           1819         259         522          15        1037        1369
Swap:          5119           3        5116
emon3 | CHANGED | rc=0 >>
              total        used        free      shared  buff/cache   available
Mem:           1819         268         384          23        1166        1344
Swap:          5119           2        5117
```

- ������Ϣ

���ǵ�setupģ�黹��һ���ܺ��õĹ��ܾ��ǿ��Ա���������ɸѡ����Ϣ�����ǵ������ϣ�ͬʱ���ļ���Ϊ���Ǳ����Ƶ�������IP��������������֪������̨�����������⡣

```bash
[emon@emon ~]$ ansible web -m setup -a 'filter="*mem*"' --tree /tmp/facts
[emon@emon ~]$ ls /tmp/facts/|cat
emon2
emon3
[emon@emon ~]$ cat /tmp/facts/emon2|jq .
{
  "ansible_facts": {
    "ansible_memfree_mb": 520,
    "ansible_memory_mb": {
      "nocache": {
        "free": 1461,
        "used": 358
      },
      "real": {
        "free": 520,
        "total": 1819,
        "used": 1299
      },
      "swap": {
        "cached": 0,
        "free": 5116,
        "total": 5119,
        "used": 3
      }
    },
    "ansible_memtotal_mb": 1819,
    "discovered_interpreter_python": "/usr/bin/python"
  },
  "changed": false
}
```

## 6��Ansible Playbook

### 6.1��Ansible Playbook����

Playbooks��adhoc��ȣ���һ����ȫ��ͬ������ansible�ķ�ʽ��������saltstack��state״̬�ļ���ad-hoc�޷��־�ʹ�ã�playbook���Գ־�ʹ�á�

Playbook����һ������play��ɵ��б�play����Ҫ�������ڽ����ȹ鲢Ϊһ�������װ�������ͨ��ansible�е�task����õĽ�ɫ���Ӹ�������������ν��task�޷��ǵ���ansible��һ��module�������play��֯��һ��playbook�У��������������������������ȱ��ŵĻ������ĳһ������

### 6.2��Playbook����Ԫ��

- Hosts��ִ�е�Զ�������б�
- Tasks������
- Variables�����ñ������Զ��������playbook�е���
- Templates��ģ�壬��ʹ��ģ���﷨���ļ������������ļ���
- Handlers��notity���ʹ�ã����ض����������Ĳ�����������������ִ�У�����ִ��
- Taggs����ǩ��ָ��ĳ������ִ�У�����ѡ������playbook�еĲ��ִ���



### 6.3��Playbook�﷨

playbookʹ��yaml�﷨��ʽ����׺������yaml��Ҳ������yml��

- �ڵ�һһ��playbook�ļ��У����������������Ӻţ�`---`�����ֶ��play������ѡ���Ե�����������ţ�`...`��������ʾplay�Ľ�β��Ҳ����ʡ�ԡ�

- ���п�ʼ����дplaybook�����ݣ�һ�㶼��д��������playbook�Ĺ��ܡ�

- ʹ��#��ע�ʹ��롣
- ��������ͳһ�����ܿո��tab���á�
- �����ļ���Ҳ������һ�µģ�ͬ������������ͬ���ļ��𣬳����б����õļ�����ͨ��������ϻ���ʵ�ֵġ�
- YAML�ļ����ݺ�Linuxϵͳ��Сд�жϷ�ʽ����һ�£������ִ�Сд�ģ�`k/v`��ֵ�����Сд���С�
- `k/v`��ֵ��ͬ��дҲ���Ի���д��ͬ��ʹ��`:`�ָ���
- `v`������һ���ַ�����Ҳ������һ���б�
- һ�������Ĵ���鹦����Ҫ����Ԫ�ذ�����`name:task`



### 6.4��һ���򵥵�ʾ��

```yaml
---								# �̶���ʽ
- hosts: 192.168.1.31			# ������Ҫִ�е�����
  remote_user: root				# Զ���û�
  vars:							# �������
    http_port: 8088				# ����

  tasks:						# ����һ������Ŀ�ʼ
    - name: create new file		# �������������
      file: name=/tmp/playtest.txt state=touch	# ����ģ�飬����Ҫ��������
    - name: create new user
      user: name=test02 system=yes shell=/sbin/nologin
    - name: install package
      yum: name=httpd
    - name: config httpd
      template: src=./httpd.conf dest=/etc/httpd/conf/httpd.conf
      notify:								# ����ִ��һ��������action����handlers������ִ�У���handlers���ʹ��
        - restart apache					# notifyҪִ�еĶ��������������handlers�е�name��������һ��
    - name: copy index.html
      copy: src=/var/www/html/index.html dest/var/www/html/index.html
    - name: start https
      service: name=httpd state=started
  handlers:									# ����������Ӧtasks��notify�����action����ִ����Ӧ�Ĵ�����
    - name: restart apache					# Ҫ��notify�����������ͬ
      service: name=httpd state=restarted	# ����Ҫִ�еĶ���
```

### 6.5��Playbook�����з�ʽ

ͨ��`ansible-playbook`��������

��ʽ��`ansible-playbook <filename.yml> ... [options]`

> -C, --check # ֻ�����ܻᷢ���ĸı䣬��������ִ�иò���
>
>  --list-hosts # �г��������������
>
>  --list-tags  # �г�playbook�ļ��ж�������е�tags
>
>  --list-tasks # �г�playbook�ļ��ж�������е�tasks
>
>  --skip-tags SKIP_TAGS # ����ָ����tags
>
> -f # ָ����������Ĭ��Ϊ5��
>
> -t # ָ��playbook�ж����tags���У�����ĳ�����߶��tags��
>
> -v # ��ʾ���� -vv����-vvv����ϸ

### 6.6����������

#### 6.6.1��ping����

```bash
[emon@emon ~]$ vim ansibledata/ping-playbook.yml
```

```yaml
- hosts: web
  remote_user: emon
  vars:
    http_port: 80
    max_clients: 200
  tasks:
    - name: ping
      ping:
```

```bash
[emon@emon ~]$ ansible-playbook ansibledata/ping-playbook.yml
# ������������
PLAY [web] ****************************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [emon2]
ok: [emon3]

TASK [ping] ***************************************************************************************************
ok: [emon2]
ok: [emon3]

PLAY RECAP ****************************************************************************************************
emon2                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
emon3                      : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

#### 6.6.2��playbook������

- ��дplaybook

```bash
[emon@emon ~]$ vim ansibledata/loop-playbook.yml
```

```yaml
- hosts: web
  remote_user: emon
  tasks:
    - debug:
        msg: "{{ item }}"
      loop: "{{ groups['all'] }}"
```

```bash
[emon@emon ~]$ vim ansibledata/import-playbook.yml
```

```yaml
- name: Include a play after another play
  import_playbook: loop-playbook.yml

- hosts: web
  remote_user: emon
  tasks:
    - debug:
        msg: "Main entrance of import"
      loop: "{{ groups['all'] }}"
```

- ִ��

```bash
[emon@emon ~]$ ansible-playbook ansibledata/import-playbook.yml 
```

#### 6.6.3�����ʹ�ñ���



# �塢��



# ����������

![image-20220321225749039](images/image-20220321225749039.png)

# ��ʮ���������������������

## 1��MySQL

### 1.1������

```bash
# /usr/local/dockerv/mysql_home Ŀ¼���Զ�����
$ docker run --name=mysql \
-e MYSQL_ROOT_HOST=%.%.%.% -e MYSQL_ROOT_PASSWORD=root123 \
-v /usr/local/dockerv/mysql/log:/var/log/mysql \
-v /usr/local/dockerv/mysql/dada:/var/lib/mysql \
-v /usr/local/dockerv/mysql/conf:/etc/mysql \
-p 3306:3306 -d mysql/mysql-server:5.7
```

### 1.2������

#### 1.2.1����

1������

```bash
# /usr/local/dockerv/mysql_home Ŀ¼���Զ�����
$ docker run --name=mysql-master \
-e MYSQL_ROOT_HOST=%.%.%.% -e MYSQL_ROOT_PASSWORD=root123 \
-v /usr/local/dockerv/mysql-master/log:/var/log/mysql \
-v /usr/local/dockerv/mysql-master/data:/var/lib/mysql \
-v /usr/local/dockerv/mysql-master/conf:/etc/mysql \
-p 3307:3306 -d mysql/mysql-server:5.7
```

2������

```bash
$ vim /usr/local/dockerv/mysql-master/conf/my.cnf
```

```bash
[mysqld]
#========���Ӹ�������========
#������������־����
log-bin=mysql-bin
#����ʹ�õĶ�������־��ʽ��mixed,statement,row��
binlog_format=row
# ����binlog_format = ROWģʽʱ�����ټ�¼��־�����ݣ�ֻ��¼��Ӱ�����
binlog_row_image = minimal
#����server_id��ͬһ����������ҪΨһ
server_id=1

#��������־��������ʱ�䡣Ĭ��ֵΪ0����ʾ���Զ�����
expire_logs_days=7
# ÿ����־�ļ���С
max_binlog_size = 100m
# binlog�����С
binlog_cache_size = 4m
# ���binlog�����С
max_binlog_cache_size = 512m

# ����������������д�����ݣ�������ͨ�û���Ч��������root��ʹ��super_read_only
read_only=0
#ָ������Ҫͬ�������ݿ�����
binlog_ignore_db = information_schema
binlog_ignore_db = mysql
binlog_ignore_db = performance_schema
binlog_ignore_db = sys
```

33������

```bash
$ docker restart mysql-master
```

4������mysql-master����

```bash
$ docker exec -it mysql-master /bin/bash
```

��mysql-master�����ڴ�������ͬ���û���

```bash
bash-4.2# mysql -uroot -proot123
mysql> create user 'repl'@'%' identified by 'repl123';
mysql> grant replication slave on *.* to 'repl'@'%';
show master status;
+------------------+----------+--------------+-------------------------------------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB                                | Executed_Gtid_Set |
+------------------+----------+--------------+-------------------------------------------------+-------------------+
| mysql-bin.000001 |      595 |              | information_schema,mysql,performance_schema,sys |                   |
+------------------+----------+--------------+-------------------------------------------------+-------------------+
1 row in set (0.00 sec)
```

#### 1.2.2����

1������

```bash
# /usr/local/dockerv/mysql_home Ŀ¼���Զ�����
$ docker run --name=mysql-slave \
-e MYSQL_ROOT_HOST=%.%.%.% -e MYSQL_ROOT_PASSWORD=root123 \
-v /usr/local/dockerv/mysql-slave/log:/var/log/mysql \
-v /usr/local/dockerv/mysql-slave/data:/var/lib/mysql \
-v /usr/local/dockerv/mysql-slave/conf:/etc/mysql \
-p 3308:3306 -d mysql/mysql-server:5.7
```

2������

```bash
$ vim /usr/local/dockerv/mysql-slave/conf/my.cnf
```

```bash
[mysqld]
#========���Ӹ�������========
#������������־����
log-bin=mysql-bin
#����ʹ�õĶ�������־��ʽ��mixed,statement,row��
binlog_format=row
# ����binlog_format = ROWģʽʱ�����ټ�¼��־�����ݣ�ֻ��¼��Ӱ�����
binlog_row_image = minimal
#����server_id��ͬһ����������ҪΨһ
server_id=2

#��������־��������ʱ�䡣Ĭ��ֵΪ0����ʾ���Զ�����
expire_logs_days=7
# ÿ����־�ļ���С
max_binlog_size = 100m
# binlog�����С
binlog_cache_size = 4m
# ���binlog�����С
max_binlog_cache_size = 512m

# �ڴӷ������Ͻ�ֹ�κ��û�д���κ����ݣ�������ͨ�û���Ч��������root��ʹ��super_read_only
read_only = 1

#ָ������Ҫͬ�������ݿ�����
replicate_ignore_db = information_schema
replicate_ignore_db = mysql
replicate_ignore_db = performance_schema
replicate_ignore_db = sys
relay_log = mysql-relay-bin
# ��Ϊ�ӿ�ʱ��Ч������м������ƣ�����Ҫ�˲���
log_slave_updates = on
#�����������Ὣmaster.info��relay.info�����ڱ��У�Ĭ����Myisam����
master_info_repository = TABLE
relay_log_info_repository = TABLE
```

3������

```bash
$ docker restart mysql-slave
```

4������mysql-slave����

```bash
$ docker exec -it mysql-slave /bin/bash
bash-4.2# mysql -uroot -proot123
```

5����mysql-slave���������Ӹ���

```bash
# ע�⣺MASTER_LOG_FILE��MASTER_LOG_POS��������ͨ�� show master status �õ���
mysql> change master to \
master_host='192.168.200.116', \
master_port=3307, \
master_user='repl', \
master_password='repl123', \
MASTER_LOG_FILE='mysql-bin.000001', \
MASTER_LOG_POS=595; \
mysql> start slave;
mysql> show slave status \G
```

#### 1.2.3����֤

- ��¼������

```bash
$ docker exec -it mysql-master /bin/bash
bash-4.2# mysql -uroot -proot123
mysql> create database db0;
mysql> use db0;
mysql> create table user(id int,name varchar(20),age tinyint);
mysql> insert into user values(1,'emon',28);
mysql> select * from user;
+------+------+------+
| id   | name | age  |
+------+------+------+
|    1 | emon |   28 |
+------+------+------+
1 row in set (0.00 sec)
```

- ��¼�ӿ�

```bash
$ docker exec -it mysql-slave /bin/bash
bash-4.2# mysql -uroot -proot123
mysql> select * from db0.user;
+------+------+------+
| id   | name | age  |
+------+------+------+
|    1 | emon |   28 |
+------+------+------+
1 row in set (0.00 sec)
```



## 2��Redis

- redis�����ļ����ص�ַ��https://redis.io/docs/manual/config/

```bash
# ����redis.conf
$ wget -cP /usr/local/dockerv/redis_home/ https://raw.githubusercontent.com/redis/redis/5.0/redis.conf
# ����redis.conf
$ cp /usr/local/dockerv/redis_home/redis.conf /usr/local/dockerv/redis_home/redis.conf.bak
```

- ���������ļ�

```bash
$ vim /usr/local/dockerv/redis_home/redis.conf
```

```bash
# [�޸�]
bind 127.0.0.1
==>
bind 0.0.0.0
# [�޸�] Ĭ��yes����������ģʽ������Ϊ���ط���
protected-mode yes
==>
protected-mode no
# [�޸�] Ĭ��Ū����Ϊyes��Ϊ����aof�־û�
appendonly no
==>
appendonly yes
# [����] ������������
requirepass redis123
```

- ����

```bash
$ docker run --name=redis \
-v /usr/local/dockerv/redis_home/data:/data \
-v /usr/local/dockerv/redis_home/redis.conf:/etc/redis/redis.conf \
-p 6379:6379 -d redis:5.0 \
redis-server /etc/redis/redis.conf
```

- docker�����з���

```bash
$ docker exec -it redis redis-cli
```

## 3��Zookeeper

- ����

```bash
$ docker run --name zoo --restart always -p 2181:2181 -d zookeeper:3.6.3
```

- ����

```bash
$ docker exec -it zoo zkCli.sh
# �˳�
[zk: localhost:2181(CONNECTED) 1] quit
```

## zkui

- ������������

```bash
# ����zkui����
$ mkdir /usr/local/zkui
$ cd /usr/local/zkui/
$ git clone https://github.com/DeemOpen/zkui.git
$ cd zkui
# ȷ�����ص�¼��docker hub
# �޸� vim Makefile �� publish һ��
# ==================================
publish:
    docker tag $(NAME):$(VERSION) $(NAME):$(VERSION)
    docker tag $(NAME):$(VERSION) $(NAME):latest
    docker tag $(NAME):$(VERSION) $(NAME):latest
    docker push $(NAME)
==>
HUB_NAME = rushing/zkui
publish:
    docker tag $(NAME):$(VERSION) $(HUB_NAME):$(VERSION)
    docker tag $(NAME):$(VERSION) $(HUB_NAME):latest
    docker push $(HUB_NAME):$(VERSION)
    docker push $(HUB_NAME)
# ==================================
$ make build
$ make publish


# admin/manager ��д�˺ţ�appconfig/appconfig ��ͨ�û�
$ docker run -d --name zkui -p 9090:9090 -e ZK_SERVER=192.168.200.116:2181 rushing/zkui
# �ɲ鿴ʵ������
$ docker exec -it zkui /bin/bash
```

- ��¼����

http://repo.emon.vip:9090

## 4��xxl-job-admin

�ĵ���ַ��https://www.xuxueli.com/xxl-job/

- �����������ݿ�

�ű���ַ��https://github.com/xuxueli/xxl-job/blob/master/doc/db/tables_xxl_job.sql

ָ���汾�ű���ַ��https://github.com/xuxueli/xxl-job/blob/2.3.0/doc/db/tables_xxl_job.sql

- ����

```bash
# ��ȷ����ִ�����ݿ�ű���������xxl_job��ͱ�
# �����Զ��� mysql �����ã���ͨ�� "-e PARAMS" ָ����������ʽ PARAMS="--key=value  --key2=value2" ��
# ������ο��ļ���https://github.com/xuxueli/xxl-job/blob/master/xxl-job-admin/src/main/resources/application.properties
# �����Զ��� JVM�ڴ���� �����ã���ͨ�� "-e JAVA_OPTS" ָ����������ʽ JAVA_OPTS="-Xmx512m" ��
$ docker run --name xxl-job-admin \
-e PARAMS="--spring.datasource.url=jdbc:mysql://192.168.200.116:3306/xxl_job?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true&serverTimezone=Asia/Shanghai --spring.datasource.username=root --spring.datasource.password=root123" \
-v /usr/local/dockerv/xxl-job-admin:/data/applogs \
-p 8790:8080 -d xuxueli/xxl-job-admin:2.3.0
```

- ��¼����

http://repo.emon.vip:8790/xxl-job-admin

�˺����룺

admin/123456

## 5��sentinel-dashboard

- ����

```bash
$ mkdir /usr/local/sentinel-dashboard && cd /usr/local/sentinel-dashboard/
$ wget https://github.com/alibaba/Sentinel/releases/download/1.8.4/sentinel-dashboard-1.8.4.jar
# ��ע������ʹ�õĲ��ǹٷ��棬��Ϊ�ٷ�Ĭ�ϲ�֧����������־û�������
$ vim Dockerfile
```

```dockerfile
FROM openjdk:8-jre
MAINTAINER ���� liming2011071@163.com

COPY sentinel-dashboard-1.8.0-zookeeper.jar sentinel-dashboard.jar

ENTRYPOINT ["java", "-jar", "/sentinel-dashboard.jar"]
```

- ��������

```bash
$ docker build -t rushing/sentinel-dashboard:ds-1.8.0 .
$ docker push rushing/sentinel-dashboard:ds-1.8.0
```

- ����

```bash
$ docker run --name sentinel \
-e JAVA_TOOL_OPTIONS="-Dserver.port=8791 -Dcsp.sentinel.dashboard.server=localhost:8791 -Dproject.name=sentinel-dashboard -Ddatasource.provider=zookeeper -Ddatasource.provider.zookeeper.server-addr=192.168.200.116:2181" \
-p 8791:8791 -d rushing/sentinel-dashboard:ds-1.8.0
```

- ��¼����

http://repo.emon.vip:8791

�˺����룺

sentinel/sentinel



## 6��Elasticsearch

- �������磨ͬһ�����services�������ӣ�

```bash
$ docker network create esnet
```

- ����

```bash
$ docker run --name es --net esnet -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -d elasticsearch:7.17.5
```



## 7��MongoDB

### 7.1����ͨ����

```bash
# /usr/local/dockerv/mongo Ŀ¼���Զ�����
$ docker run --name mongo \
-e MONGO_INITDB_ROOT_USERNAME=root \
-e MONGO_INITDB_ROOT_PASSWORD=root123 \
-v /usr/local/dockerv/mongo/data/:/data/db \
-p 27017:27017 \
-d mongo:5.0.11
```

### 7.2�������ļ�����

- ����keyFile

```bash
$ mkdir -pv /usr/local/dockerv/mongo/conf
$ openssl rand -base64 128 > /usr/local/dockerv/mongo/conf/keyFile
# ���Ƽ���keyFile��Ҫ���ǣ�
# 1-��base64���뼯�е��ַ����б�д�����ַ���ֻ�ܰ���a-z,A-Z,+,/��=
# 2-���Ȳ��ܹ�����1000�ֽ�
# 3-Ȩ����ൽ600
$ chmod 600 /usr/local/dockerv/mongo/conf/keyFile
```

- ���������ļ�

```bash
$ vim /usr/local/dockerv/mongo/conf/27017.conf
```

```bash
# �˿ڣ�Ĭ��27017��MongoDB��Ĭ�Ϸ���TCP�˿�
port=27017
# Զ������Ҫָ��ip����Ȼ�޷����ӣ�0.0.0.0��ʾ������ip���ʣ���������Ӧ�˿�
bind_ip=0.0.0.0
# ��־�ļ�
logpath=/usr/local/dockerv/mongo/log/27017.log
# �����ļ����Ŀ¼��Ĭ�ϣ� /data/db/
dbpath=/usr/local/dockerv/mongo/data/27017/
# ��־׷��
logappend=true
# �����Ľ���ID
pidfilepath=/usr/local/dockerv/mongo/data/27017/27017.pid
# ���Ϊtrue�����ػ�����ķ�ʽ���������ں�̨����
fork=false
# oplog���ڴ�С
oplogSize=5120
# ���Ƽ�����
replSet=emon
# ���Ƽ���֤�ļ�
keyFile=/usr/local/dockerv/mongo/conf/keyFile
```

- ����

```bash
# /usr/local/dockerv/mongo Ŀ¼���Զ�����
$ docker run --name mongo \
-e MONGO_INITDB_ROOT_USERNAME=root
-e MONGO_INITDB_ROOT_PASSWORD=root123
-v /usr/local/dockerv/mongo/conf/:/etc/mongo
-d mongo:5.0.11
--config /etc/mongo/27017.conf
```

## 8��JFrog Artifactory

### 8.1��6�汾

- ����volume

```bash
$ docker volume create artifactory
```

- ����

```bash
$ docker run --name artifactory \
-v artifactory:/var/opt/jfrog/artifactory \
-p 8082:8081 \
-d releases-docker.jfrog.io/jfrog/artifactory-oss:6.23.42
```

- ��¼

http://emon:8082/

�û������룺admin/password ==> ��¼��ǿ���޸ģ��޸Ľ����admin/admin123



### 8.2��7�汾

- ����Ŀ¼����Ȩ

```bash
$ mkdir -pv /usr/local/dockerv/jfrog/artifactory/var/etc
$ touch /usr/local/dockerv/jfrog/artifactory/var/etc/system.yaml
$ chown -R 1030:1030 /usr/local/dockerv/jfrog/artifactory/var
```

- ����

```bash
$ docker run --name artifactory \
-v /usr/local/dockerv/jfrog/artifactory/var:/var/opt/jfrog/artifactory \
-p 8081:8081 -p 8082:8082 \
-d releases-docker.jfrog.io/jfrog/artifactory-oss:7.41.12
```

- ��¼

http://emon:8082/

�û������룺admin/password ==> ��¼��ǿ���޸ģ��޸Ľ����admin/Admin5%123

Base URL��http://repo.emon.vip
