---
layout: post
title: 运维之centos系统自动部署1-深入剖析centos
date: 2016-01-07
category: deploy
---

##centos剖析思路
1. 逐步集成centos启动流程中涉及到的软件组件，最后定制出完整的可引导光盘镜像

2. 在已正常运转的centos上,利用系统工具找出各个文件所属的软件包及其作用，整理出
   软件之间的依赖关系，最终也可利用工具形成可引导光盘镜像

##实验环境
1. win8下的vmware workstation pro 12.0.0 build-2985596

2. CentOS-7-x86_64-Minimal-1511.iso

3. vmware里的centos 7(用2中的ISO安装的)

##测试步骤
1. 先把2中的ISO挂载到centos 7下的/mnt目录下,我们可以看到整个镜像的目录结构

~~~~~~
[root@localhost ~]# mount -o loop /dev/cdrom /mnt
[root@localhost ~]# ls -la /mnt
total 100
dr-xr-xr-x.  8 root root  2048 Dec  9 18:03 .
dr-xr-xr-x. 18 root root  4096 Dec 27 07:56 ..
-r--r--r--.  1 root root    14 Dec  9 17:35 CentOS_BuildTag
-r--r--r--.  1 root root    32 Dec  9 17:25 .discinfo
dr-xr-xr-x.  3 root root  2048 Dec  9 17:33 EFI
-r--r--r--.  1 root root   215 Dec  9 17:35 EULA
-r--r--r--.  1 root root 18009 Dec  9 17:35 GPL
dr-xr-xr-x.  3 root root  2048 Dec  9 17:33 images
dr-xr-xr-x.  2 root root  2048 Dec  9 17:33 isolinux
dr-xr-xr-x.  2 root root  2048 Dec  9 17:33 LiveOS
dr-xr-xr-x.  2 root root 55296 Dec  9 18:03 Packages
dr-xr-xr-x.  2 root root  4096 Dec  9 18:03 repodata
-r--r--r--.  1 root root  1690 Dec  9 17:35 RPM-GPG-KEY-CentOS-7
-r--r--r--.  1 root root  1690 Dec  9 17:35 RPM-GPG-KEY-CentOS-Testing-7
-r--r--r--.  1 root root  2883 Dec  9 18:03 TRANS.TBL
-r--r--r--.  1 root root  1109 Dec  9 17:35 .treeinfo
~~~~~~

2. 目录结构解析

- CentOS_BuildTag文件: 该iso的build时间戳，精确到分钟

~~~
[root@localhost mnt]# cat CentOS_BuildTag 
20151209-2215
~~~

- .discinfo文件:   该iso的创建unix时间戳,普通时间戳和面向的体系结构（这里是X86_64）

~~~
[root@localhost mnt]# cat .discinfo 
1449699925.561114
151209
x86_64
~~~

- EFI目录: 

~~~
[root@localhost mnt]# tree EFI/
EFI/
├── BOOT
│   ├── BOOTX64.EFI
│   ├── fonts
│   │   ├── TRANS.TBL
│   │   └── unicode.pf2
│   ├── grub.cfg
│   ├── grubx64.efi
│   ├── MokManager.efi
│   └── TRANS.TBL
└── TRANS.TBL
~~~

    
    
