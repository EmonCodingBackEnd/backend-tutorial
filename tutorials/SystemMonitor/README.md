# 系统监控

[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)

[toc]

# 一、安装

## 1、Prometheus

官网： https://prometheus.io/

下载地址页： https://prometheus.io/download/

1、下载

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://github.com/prometheus/prometheus/releases/download/v2.30.0-rc.0/prometheus-2.30.0-rc.0.linux-amd64.tar.gz
```

2、创建安装目录

```bash
[emon@emon ~]$ mkdir /usr/local/Promethues
```

3、解压安装

```bash
[emon@emon ~]$ tar -zxvf /usr/local/src/prometheus-2.30.0-rc.0.linux-amd64.tar.gz -C /usr/local/Promethues
```

4、创建软连接

```bash
[emon@emon local]$ ln -s /usr/local/Promethues/prometheus-2.30.0-rc.0.linux-amd64/ /usr/local/prome
```

5、创建数据目录

```bash
[emon@emon ~]$ mkdir /usr/local/prome/data
```

6、启动

- 启动方式1

```bash
[emon@emon local]$ /usr/local/prome/prometheus --config.file=/usr/local/prome/prometheus.yml 
```

- 启动方式2：支持从Web端点动态更新配置

```bash
[emon@emon local]$ /usr/local/prome/prometheus --config.file=/usr/local/prome/prometheus.yml --web.enable-lifecycle
```

- 方式2启动后，可以如下加载最新配置

```bash
curl -X POST http://localhost:9090/-/reload
```

7、访问

访问： http://repo.emon.vip:9090

查看监控的数据：	http://repo.emon.vip:9090/metrics



8、配置化启动【推荐】

```bash
[emon@emon ~]$ sudo vim /usr/lib/systemd/system/promed.service
```

```bash
# vim /usr/lib/systemd/system/prometheus.service
[Unit]
Description=The Prometheus Process Manager
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
User=emon
ExecStart=/usr/local/prome/prometheus \
--config.file=/usr/local/prome/prometheus.yml \
--web.enable-lifecycle --storage.tsdb.path=/usr/local/prome/data
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

- 加载

```bash
[emon@emon ~]$ sudo systemctl daemon-reload
```

- 启动

```bash
[emon@emon ~]$ sudo systemctl start promed.service
```

- 查看

```bash
[emon@emon ~]$ sudo systemctl status promed.service
```

- 停止

```bash
[emon@emon ~]$ sudo systemctl stop promed.service 
```



## 2、Grafana

官网：

下载地址页：

1、下载

```bash
[emon@emon ~]$ wget -cP /usr/local/src/ https://dl.grafana.com/enterprise/release/grafana-enterprise-8.1.3-1.x86_64.rpm
```

2、安装

```bash
[emon@emon ~]$ sudo yum install /usr/local/src/grafana-enterprise-8.1.3-1.x86_64.rpm 
```

3、启动停止和查看状态

- 启动

```bash
[emon@emon ~]$ sudo systemctl start grafana-server
```

- 停止

```bash
[emon@emon ~]$ sudo systemctl stop grafana-server
```

- 查看状态

```bash
[emon@emon ~]$ sudo systemctl status grafana-server
```

4、访问

http://repo.emon.vip:3000

默认账号密码： admin/admin

首次登陆提示修改密码，修改后账号密码： admin/admin123

5、使用

- 创建数据源
- 创建dashboard
- 创建Panel
  - 多个Panel形成可视化大盘
