# Linux学习

[[返回列表](https://github.com/EmonCodingBackEnd/backend-tutorial)](https://github.com/EmonCodingBackEnd/backend-tutorial)

[TOC]

# 一、常用总结

## 1.1、扩展root分区

1. 查看根分区大小

```bash
df -h
```

2. 在虚拟中添加一块物理的磁盘，重启虚拟机
3. 查看磁盘编号

```bash
[root@localhost ~]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb
# /dev/sdb 是新的虚拟磁盘
```

4. 创建pv

```bash
[root@localhost ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```

5. 把pv加入vg中，相当于扩充vg的大小

- 先使用vgs查看vg组

```bash
[root@localhost ~]# vgs
  VG     #PV #LV #SN Attr   VSize   VFree
  centos   1   6   0 wz--n- <49.00g    0 
```

- 扩展vg，使用vgextend命令

```bash
[root@localhost ~]# vgextend centos /dev/sdb
  Volume group "centos" successfully extended
```

- 我们成功把vg卷扩展了，再用vgs查看一下

```bash
vgs
```

6. 扩充lv的大小

- 查看lv

```bash
[root@localhost ~]# lvs
  LV   VG     Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home centos -wi-ao---- <5.00g                                                    
  root centos -wi-ao---- <5.00g                                                    
  swap centos -wi-ao----  5.00g                                                    
  tmp  centos -wi-ao----  2.00g                                                    
  usr  centos -wi-ao---- 30.00g                                                    
  var  centos -wi-ao----  2.00g 
```

- 扩展lv，使用lvextend命令

```bash
[root@localhost ~]# lvextend -L +20G /dev/mapper/centos-root
  Insufficient free space: 5120 extents needed, but only 5119 available
# 发现错误，修改为+19G
[root@localhost ~]# lvextend -L +19G /dev/mapper/centos-root
  Size of logical volume centos/root changed from <5.00 GiB (1279 extents) to <24.00 GiB (6143 extents).
  Logical volume centos/root successfully resized.
```

7. 命令使系统重新读取大小

```bash
[root@localhost ~]# xfs_growfs /dev/mapper/centos-root 
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=327424 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=1309696, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 1309696 to 6290432
```

8. 最后查看根分区大小

```bash
df -h
```



