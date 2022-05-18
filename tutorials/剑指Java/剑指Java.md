# 剑指Java

[TOC]

# 面试知识点

## JVM

1、请你谈谈对JVM的理解？Java8虚拟机和之前的变化更新？

2、什么是OOM，什么是栈溢出StackOverFlowError？怎么分析？

3、JVM的常用调优参数有哪些？

4、内存快照如何抓取，怎么分析Dump文件？知道吗？

5、谈谈JVM中，类加载器你的认识？



1：JVM的位置

硬件体系（Intel等）==>操作系统（Win、Linux、Mac）==>JRE-JVM==>App

2：JVM的体系结构

![image-20220511235409430](images/image-20220511235409430.png)

3：类加载器

作用：加载Class文件

虚拟机自带的加载器

启动类（根）加载器：Bootstrap ClassLoader：主要负责加载核心的类库（java.lang.*等），构造ExtClassLoader和AppClassLoader。

扩展类加载器：ExtClassLoader：主要负责加载jre/lib/ext目录下的一些扩展的jar。

应用程序加载器：AppClassLoader：主要负责加载应用程序的主函数类



4：双亲委派机制

作用：保证安全

![image-20220512094510290](images/image-20220512094510290.png)

为什么要设计这种机制：

这种设计有个好处是，如果有人想替换系统级别的类：String.java。篡改它的实现，在这种机制下这些系统的类已经被Bootstrap classLoader加载过了（为什么？因为当一个类需要加载的时候，最先去尝试加载的就是BootstrapClassLoader），所以其他类加载器并没有机会再去加载，从一定程度上防止了危险代码的植入。



5：沙箱安全机制

6：Native

Native Method Stack

它的具体做法是Native Method Stack中等级native方法，在（Execution Engine）执行引擎执行时加载Native Libraries。【本地库】



7：PC寄存器

程序计数器：Program Counter Register

每个线程都有一个程序计数器，是线程私有的，就是一个指针，指向方法区中的方法字节码（用来存储指向一条指令的地址，也即将要指向的指令代码），在执行引擎读取下一条指令，是一个非常小的内存空间，几乎可以忽略不计！



8：方法区（Java8的元数据区）

Method Area方法区

方法区是被所有线程共享，所有字段和方法字节码，以及一些特殊方法，如构造函数，接口代码也在此定义，简单说所有定义的方法的信息都保存在该区域，此区域属于共享空间！

<font color='red'>静态变量、常量、类信息（构造方法、接口定义、普通方法）、运行时的常量池存在方法区中，但是实例变量存储在堆内存中，和方法区无关。</font>

static/final/class/常量池



9：栈（数据结构）

程序=数据结构+算法（不是框架+业务逻辑）

栈：先进后出、后进先出

队列：先进先出（FIFO：First Input First Output）

==喝多了吐就是栈，吃多了拉就是队列==

栈：8大基本类型+对象引用+实例方法

栈是运行时的单位：即程序如何执行，或者说如何处理数据。

栈是线程私有，不存在垃圾的回收。虚拟机栈的生命周期同线程一致。

栈帧：Java中的方法被扔进虚拟机的栈空间后就成为“栈帧”，比如main方法，程序入口；被压栈之后就成为栈帧。



10：三种JVM

- HotSpot（Oracle）
- BEA `JRockit`
- IBM `J9VM`



11：堆

堆：先进新出、后进后出

堆是存储的单位：堆解决的是数据存储问题，即数据如何存放，放哪里！

Heap，一个JVM只有一个堆内存；堆内存的大小是可以调节的。

新生区：

- 类 诞生 和 成长的地方，甚至是消亡
- 伊甸园 所有的对象都是在 eden 区 new 出来的
- 幸存区

真理：经过研究，99%的对象都是临时对象！

老年区：

永久区：

这个区域常驻内存，用来存放JDK自身携带的Class对象。Interface元数据，存储的是Java运行时的一些环境或类信息~，这个区域不存在垃圾回收！关闭VM虚拟机就会释放这个区域的内存~

​	元空间的OOM：逻辑上存在，物理上不存在；又说元数据不占用JVM堆，但占用物理内存

​	一个启动类，加载了大量第三方jar包。Tomcat部署了太多的应用。大量动态生成的反射类，不断被加载。直到内存慢了，就会OOM。

- JDK1.6之前：永久代，常量池是在方法区
- JDK1.7：永久代，但是慢慢退化了，`去永久代`，常量池在堆中
- JDK1.8之后：无永久代，常量池在元空间



![image-20220518092022891](images/image-20220518092022891.png)





12：新生代和老年代

13、永久代

14、堆内存调优

15、GC

## Java并发编程

## Java数据结构与算法

## Java网络编程

## HTTP协议

## 分布式

### 分布式ID

### 分布式缓存

### 分布式事务

### 分库分表

## BIO/AIO/NIO

## Netty

## Java设计模式

## Spring

## SpringBoot

## SpringCloud

## MySQL

## Redis

## MongoDB

## RabbitMQ/Kafka

## Zookeeper

## ES

## Java异常调优

## K8S







# 面试题

