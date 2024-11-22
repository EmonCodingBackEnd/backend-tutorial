# backend-tutorial
后端教程



# 命名规范

| 定义             | 说明     | 示例                  |
| ---------------- | -------- | --------------------- |
| XXXCommonCMD.md  | 常用命令 | LinuxCommonCMD.md     |
| XXXInAction.md   | 实战     | LinuxInAction.md      |
| XXXLearning.md   | 学习     | LinuxLearning         |
| UnderstantingXXX | 深入理解 | UnderstandingLinux.md |

# Demo与Example和Sample的区别

## Demo

是一种演示：给客户观看的，注重演示效果，而淡化代码实现

## Example

是一种示例：在培训时，用于传授经验、技巧等的佐证，可参考学习使用

## Sample

是一种样品：在实现度上高于Demo和Example，可以理解为试用品

# 目录

- [Insight感悟](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Insight)
- [Java](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Java)
- [Linux](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Linux)
    - [阿里云服务器ECS安装记录](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Linux/Ali%20Cloud)
- [Nginx](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Nginx)
- [RabbitMQ](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/RabbitMQ)
- [ElasticStack](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/ElasticStack)
  - [Elasticsearch](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/ElasticStack/Elasticsearch)
  - [Kibana](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/ElasticStack/Kibana)
  - [Beats](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/ElasticStack/Beats)
  - [Logstash](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/ElasticStack/Logstash)
- [Git](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Git)
- [MySQL](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/MySQL)
- [Oracle](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Oracle)
- [Maven](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Maven/MavenInAction.md)
- [Redis](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Redis)
- [MongoDB](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/MongoDB)
- [SkyWalking](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/SkyWalking)
- [Python](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Python)
- [BigData](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/BigData)
    - [ZooKeeper](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/ZooKeeper)
    - [Kafka](https://github.com/EmonCodingBackEnd/backend-tutorial/blob/master/tutorials/Kafka)
    - [Scala](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Scala)
    - [Hadoop](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Hadoop)
    - [Flume](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Flume)
    - [Hive](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Hive)
    - [Spark](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Spark)
    - [HBase](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/HBase)
    - [Flink](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/Flink)
- [DevOps](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/DevOps)
    - [Docker](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/DevOps/Docker)
    - [Kubernetes](https://github.com/EmonCodingBackEnd/backend-tutorial/tree/master/tutorials/DevOps/Kubernetes)




# util与component和experience的区别

## util

对Apache Commons和Spring工具类的补充，更偏向领域的业务。

## component

可以直接当作组件引入的二次封装。

## experience

仅用于参考实现，不太适合于拿来直接使用的封装。



搜狗输入法自定义短语：

【属性设置】=>【高级】=>【自定义短语】（比如：中文输入法下输入ssc，会提示匹配到的短语供选择）

ss,1=#$year$month$day_dd $fullhour:$minute:$second
ssc,1=猩红<span style="color:red;">猩红</span>
ssc,2=酸橙绿<span style="color:#32CD32;">酸橙绿</span>
ssc,3=洋红<span style="color:#FF00FF;">洋红</span>
ssc,4=深粉色<span style="color:#FF1493;">深粉色</span>
ssc,5=橙红色<span style="color:#FF4500;">橙红色</span>
ssc,6=深紫罗兰色<span style="color:#9400D3;">深紫罗兰色</span>
ssc,7=纯蓝<span style="color:blue;">纯蓝</span>
ssc,8=道奇蓝<span style="color:#1E90FF;">道奇蓝</span>
ssc,9=绿宝石<span style="color:#40E0D0;">绿宝石</span>
ssc,10=卡其布<span style="color:#F0E68C;">卡其布</span>
ssc,11=金<span style="color:#FFD700;">金</span>
ssc,12=橙色<span style="color:#FFA500;">橙色</span>
ssc,13=巧克力<span style="color:#D2691E;">巧克力</span>
ssc,14=深灰色<span style="color:#A9A9A9;">深灰色</span>
ssc,15=浅灰色<span style="color:#D3D3D3;">浅灰色</span>
sscb,1=猩红<span style="color:red;font-weight:bold;">猩红</span>
sscb,2=酸橙绿<span style="color:#32CD32;font-weight:bold;">酸橙绿</span>
sscb,3=洋红<span style="color:#FF00FF;font-weight:bold;">洋红</span>
sscb,4=深粉色<span style="color:#FF1493;font-weight:bold;">深粉色</span>
sscb,5=橙红色<span style="color:#FF4500;font-weight:bold;">橙红色</span>
sscb,6=深紫罗兰色<span style="color:#9400D3;font-weight:bold;">深紫罗兰色</span>
sscb,7=纯蓝<span style="color:blue;font-weight:bold;">纯蓝</span>
sscb,8=道奇蓝<span style="color:#1E90FF;font-weight:bold;">道奇蓝</span>
sscb,9=绿宝石<span style="color:#40E0D0;font-weight:bold;">绿宝石</span>
sscb,10=卡其布<span style="color:#F0E68C;font-weight:bold;">卡其布</span>
sscb,11=金<span style="color:#FFD700;font-weight:bold;">金</span>
sscb,12=橙色<span style="color:#FFA500;font-weight:bold;">橙色</span>
sscb,13=巧克力<span style="color:#D2691E;font-weight:bold;">巧克力</span>
sscb,14=深灰色<span style="color:#A9A9A9;font-weight:bold;">深灰色</span>
sscb,15=浅灰色<span style="color:#D3D3D3;font-weight:bold;">浅灰色</span>
ssbt,1=<div style="text-align:center;font-weight:bold;">标题</div>



