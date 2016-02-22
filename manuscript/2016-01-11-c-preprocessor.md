---
layout: post
title: GCC预处理
date: 2016-01-11
category: gcc preprocessor
---

### 预处理指令格式
井号和define,include之间可以插入任意数量的非换行空白符

~~~
huihoo@lw:~/wspace/c$ make
123
huihoo@lw:~/wspace/c$ cat hello.c 
#             include <stdio.h>
#      define HUIHOO 123


int main (void) { 
  printf("%d\n", HUIHOO);
  return 0;
} 
huihoo@lw:~/wspace/c$
~~~

### include和include_next
include:搜索后面指示的文件,然后把这个文件的内容加载到当前的文件中

include_next是GNU的扩展,用于解决两个相同文件名的头文件的特殊情况.
如果使用include,那么会在多个默认搜索路径,按顺序查询,找到第一个,就直接返回.
假如搜索路径是A,B,C,D,E,在B和D下都有相同名字的头文件,比如说limits.h,使用
include就总是包含B下的limits.h,要想包含D下的limits.h,就得用include_next.

