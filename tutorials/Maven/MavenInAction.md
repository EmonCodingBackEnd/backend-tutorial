# Maven实战

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、安装`nexus maven`私服

1. 前提

安装了JDK

2. 下载

官网地址：https://www.sonatype.com/

下载地址：https://www.sonatype.com/download-oss-sonatype

专项下载地址：https://help.sonatype.com/repomanager3/download

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/3/nexus-3.23.0-03-unix.tar.gz
```

3. 创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Nexus
# 每一个版本解压到一个目录
[emon@emon ~]$ mkdir /usr/local/Nexus/nexus3.23.0-03-bundle/
```

4. 解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/nexus-3.23.0-03-unix.tar.gz -C /usr/local/Nexus/nexus3.23.0-03-bundle
```

5. 创建软连接

```bash
[emon@emon ~]$ ln -s /usr/local/Nexus/nexus3.23.0-03-bundle/nexus-3.23.0-03 /usr/local/nexus
[emon@emon ~]$ ln -s /usr/local/Nexus/nexus3.23.0-03-bundle/sonatype-work/nexus3/ /usr/local/nexus-work
```

6. 修改配置

- 修改默认服务端口

```bash
# 如果需要修改，可以在该文件修改 application-port；默认使用8081，不修改
[emon@emon ~]$ vim /usr/local/nexus/etc/nexus-default.properties 
```

- 修改默认启动内存

```bash
[emon@emon ~]$ vim /usr/local/nexus/bin/nexus.vmoptions 
```

```bash
#-Xms1200M
#-Xmx1200M
#-XX:MaxDirectMemorySize=2G
-Xms512M
-Xmx512M
-XX:MaxDirectMemorySize=1G
```

7. 配置环境变量

在`/etc/profile.d`目录创建`nexus.sh`文件：

```bash
[emon@emon ~]$ sudo vim /etc/profile.d/nexus.sh
export NEXUS_HOME=/usr/local/nexus
export NEXUS_WORK_HOME=/usr/local/nexus-work
export PATH=$NEXUS_HOME/bin:$PATH
```

使之生效：

```bash
[emon@emon ~]$ source /etc/profile
```

8. 校验

```bash
[emon@emon ~]$ nexus status
nexus is stopped.
```

9. 启动、停止、重启

- 启动

```bash
[emon@emon ~]$ nexus start
```

- 停止

```bash
[emon@emon ~]$ nexus stop
```

- 重启

```bash
[emon@emon ~]$ nexus restart
```

查看日志：`/usr/local/nexus-work/log/nexus.log`

10. 设置启动项【推荐】

参考：https://help.sonatype.com/repomanager3/system-requirements#SystemRequirements-Linux

```bash
[emon@emon ~]$ sudo vim /usr/lib/systemd/system/nexus.service
```

```bash
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/usr/local/nexus/bin/nexus start
ExecReload=/usr/local/nexus/bin/nexus restart
ExecStop=/usr/local/nexus/bin/nexus stop
User=emon
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

加载启动项：

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
```

设置开机启动：

```bash
[emon@emon ~]$ sudo systemctl enable nexus.service
```

- 启动

```bash
[emon@emon ~]$ sudo systemctl start nexus.service
```

- 停止

```bash
[emon@emon ~]$ sudo systemctl stop nexus.service
```

- 重启

```bash
[emon@emon ~]$ sudo systemctl restart nexus.service
```

11. 访问

http://192.168.1.116:8081

默认用户名密码： admin/admin123

查看admin密码：

```bash
[emon@emon ~]$ cat /usr/local/Nexus/nexus3.23.0-03-bundle/sonatype-work/nexus3/admin.password
# 然后按照步骤修改为admin123，并禁止匿名用户访问。
```

12. 添加阿里云代理资源库

第一步：创建Blob Stores

登录后，点击齿轮，

左侧：Repositories->Blob Stores

右侧：Create blob store

在`type`、`Name`和`Path`中的`Name`输入`alimaven`，点击`Create blob store`按钮，确定。

第二步：创建 Repository

左侧：Repositories

右侧：Create repository

选择maven2(proxy)，主要录入以下几项：

`Name`: alimaven

`Proxy`->`Remote storage`:录入阿里云镜像地址

```bash
http://maven.aliyun.com/nexus/content/groups/public
```

`Storage`->`Blob store`:选择第一步创建的Blob Stores `alimaven`，点击`Create repository`按钮，确定。

第三步：把alimaven加入maven-public

左侧：Repositories

右侧：`maven-public`中，把`alimaven`加入右侧，顺序调整为：

- `maven-releases`
- `maven-snapshots`
- `alimaven`
- `maven-central`

13. 配置maven的`settings.xml`文件

```xml
        <server>
            <id>nexus-releases</id>
            <username>admin</username>
            <password>admin123</password>
        </server>
        <server>
            <id>nexus-snapshots</id>
            <username>admin</username>
            <password>admin123</password>
        </server>
```



```xml
        <mirror>
            <id>nexus</id>
            <mirrorOf>*</mirrorOf>
            <name>nexus maven</name>
            <!--<url>http://maven.aliyun.com/nexus/content/groups/public</url>-->
            <url>http://localhost:8081/repository/maven-public/</url>
        </mirror>
```

14. 配置nginx

```bash
[emon@emon ~]$ vim /usr/local/nginx/conf/vhost/repo.emon.vip.conf 
```

```bash
server {
    listen 80;
    autoindex on;
    server_name repo.emon.vip;
    access_log /usr/local/nginx/logs/access.log combined;
    index index.html index.htm index.jsp index.php;
    #error_page 404 /404.html;
    if ( $query_string ~* ".*[\;'\<\>].*" ){
        return 404;
    }

    location / {
        proxy_pass http://127.0.0.1:8081;
    }
}
```



---

更新nexus索引【暂时不用】

在 http://repo.maven.apache.org/maven2/.index/ 下载

nexus-maven-repository-index.gz

nexus-maven-repository-index.properties

以及点击下载：[indexer-cli-6.0.0.jar](http://central.maven.org/maven2/org/apache/maven/indexer/indexer-cli/6.0.0/indexer-cli-6.0.0.jar)

```bash
http://repo.maven.apache.org/maven2/.index/nexus-maven-repository-index.gz
http://repo.maven.apache.org/maven2/.index/nexus-maven-repository-index.properties
http://central.maven.org/maven2/org/apache/maven/indexer/indexer-cli/6.0.0/indexer-cli-6.0.0.jar
```

上传上面的三个文件到服务器同一个目录，然后执行：

```bash
java -jar indexer-cli-6.0.0.jar -u nexus-maven-repository-index.gz -d indexer
```

等程序运行完成之后，可以发现indexer文件夹出现了很多的文件，将这些文件拷贝到`$NEXUS_WORK_HOME/blobs/default`

---

# 九、用户信息

## 1、nexus用户

| 用户名 | 密码     |
| ------ | -------- |
| admin  | admin123 |
| nexus  | nexus123 |
|        |          |

