# Kubernetesʵ��

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

### 2.3������ʾ��

![image-20220318172126929](images/image-20220318172126929.png)



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

## 1����Ŀ����ܹ�ͼ

![image-20220318172329781](images/image-20220318172329781.png)













