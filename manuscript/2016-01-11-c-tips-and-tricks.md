---
layout: post
title: C语言的小知识点
date: 2016-01-11
category: c
---

### sizeof和strlen
sizeof: 在C语言中,sizeof是用于取得**数据类型**在内存中占用的字节数

strlen: 在C语言中,strlen是用于取得**NULL结尾的字符串**占用的字节数

~~~
huihoo@lw:~/wspace/c$ cat hello.c 
#include <stdio.h> /*123123123213*/
#include <stdlib.h>
#include <string.h>

int main (void) { 
  char string[5] = "12";
  printf("%lu\n", sizeof(string));
  printf("%lu\n", strlen(string));
  return 0;
} 

huihoo@lw:~/wspace/c$ make
5
2
huihoo@lw:~/wspace/c$
~~~

### include预处理指令
C文件中,把一些公共的类型声明和函数原型声明抽出来形成header文件.
要想在你的程序中使用这些类型或函数,就必须把这些头文件包含到你的源代码中,
这也因此有了预处理命令include.
include的作用就是在预处理过程中,把对应的文件的内容原原本本地包含进源代码中.
格式一般是: include "header_file_name" 或 include <header_file_name>

由于header_file_name仅仅是文件名而已,不足以定位到文件系统中的某个文件.
因此就有了默认的header search path.

`gcc -print-prog-name=cc1` -v 可以打印出默认的header search path

~~~
huihoo@lw:~/wspace/c$ `gcc -print-prog-name=cc1` -v
ignoring nonexistent directory "/usr/lib/gcc/x86_64-linux-gnu/4.7/../../../../x86_64-linux-gnu/include"
#include "..." search starts here:
#include <...> search starts here:
 /usr/lib/gcc/x86_64-linux-gnu/4.7/include
 /usr/local/include
 /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed
 /usr/include
End of search list.
~~~

从上面可以看出,
如果是include "filename",那么gcc会先从当前目录开始搜索,然后才是下面几个header search path
如果是include <filename>,那么gcc直接从header search path开始搜索,不在当前目录下搜索


~~~
huihoo@lw:~/wspace/c$ cat hello.c 
#include "huihoo.h"

int main (void) { 
  return 0;
  } 
huihoo@lw:~/wspace/c$ make
hello.c:1:20: fatal error: huihoo.h: No such file or directory
compilation terminated.
make: *** [all] Error 1
huihoo@lw:~/wspace/c$ ls
hello.c  makefile  run
huihoo@lw:~/wspace/c$
huihoo@lw:~/wspace/c$ touch huihoo.h
huihoo@lw:~/wspace/c$ make
huihoo@lw:~/wspace/c$
~~~

从上面实验可以证明,
include "filename"会在当前目录下搜索

~~~
huihoo@lw:~/wspace/c$ ls
hello.c  huihoo.h  makefile  run
huihoo@lw:~/wspace/c$ cat hello.c 
#include <huihoo.h>

int main (void) { 
  return 0;
} 
huihoo@lw:~/wspace/c$ make
hello.c:1:20: fatal error: huihoo.h: No such file or directory
compilation terminated.
make: *** [all] Error 1
huihoo@lw:~/wspace/c$
~~~

从上面实验可以证明,
include <filename>不会在当前目录下搜索

接下来,找出上面几个header search path的搜索顺序
首先,先在

* /usr/lib/gcc/x86_64-linux-gnu/4.7/include
* /usr/local/include
* /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed
* /usr/include

这几个目录下,创建huihoo.h,在各个huihoo.h中#define HUIHOO "huihoo.h的路径"

~~~
huihoo@lw:~/wspace/c$ cat /usr/lib/gcc/x86_64-linux-gnu/4.7/include/huihoo.h 
#define HUIHOO "/usr/lib/gcc/x86_64-linux-gnu/4.7/include"
huihoo@lw:~/wspace/c$ cat /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed/huihoo.h 
#define HUIHOO "/usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed"
huihoo@lw:~/wspace/c$ cat /usr/local/include/huihoo.h 
#define HUIHOO "/usr/local/include"
huihoo@lw:~/wspace/c$ cat /usr/include/huihoo.h 
#define HUIHOO "/usr/include"

huihoo@lw:~/wspace/c$ cat hello.c 
#include <huihoo.h>
#include <stdio.h>

int main (void) { 
  printf("%s\n", HUIHOO);
  return 0;
} 
huihoo@lw:~/wspace/c$ make
/usr/lib/gcc/x86_64-linux-gnu/4.7/include

root@lw:/home/huihoo# rm /usr/lib/gcc/x86_64-linux-gnu/4.7/include/huihoo.h

huihoo@lw:~/wspace/c$ make
/usr/local/include

root@lw:/home/huihoo# rm /usr/local/include/huihoo.h

huihoo@lw:~/wspace/c$ make
/usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed

root@lw:/home/huihoo# rm /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed/huihoo.h

huihoo@lw:~/wspace/c$ make
/usr/include

root@lw:/home/huihoo# rm /usr/include/huihoo.h

huihoo@lw:~/wspace/c$ make
hello.c:1:20: fatal error: huihoo.h: No such file or directory
compilation terminated.
make: *** [all] Error 1
huihoo@lw:~/wspace/c$
~~~

### 基本数据类型的最大和最小值
limit.h 头文件决定了各种基本数据类型的各种属性.

~~~
root@lw:~# grep ' *# *define' /usr/lib/gcc/x86_64-linux-gnu/4.7/include-fixed/limits.h
#define _GCC_LIMITS_H_
#define _LIMITS_H___
#define CHAR_BIT __CHAR_BIT__
#define MB_LEN_MAX 1
#define SCHAR_MIN (-SCHAR_MAX - 1)
#define SCHAR_MAX __SCHAR_MAX__
# define UCHAR_MAX (SCHAR_MAX * 2U + 1U)
# define UCHAR_MAX (SCHAR_MAX * 2 + 1)
#  define CHAR_MIN 0U
#  define CHAR_MIN 0
# define CHAR_MAX UCHAR_MAX
# define CHAR_MIN SCHAR_MIN
# define CHAR_MAX SCHAR_MAX
#define SHRT_MIN (-SHRT_MAX - 1)
#define SHRT_MAX __SHRT_MAX__
# define USHRT_MAX (SHRT_MAX * 2U + 1U)
# define USHRT_MAX (SHRT_MAX * 2 + 1)
#define INT_MIN (-INT_MAX - 1)
#define INT_MAX __INT_MAX__
#define UINT_MAX (INT_MAX * 2U + 1U)
#define LONG_MIN (-LONG_MAX - 1L)
#define LONG_MAX __LONG_MAX__
#define ULONG_MAX (LONG_MAX * 2UL + 1UL)
# define LLONG_MIN (-LLONG_MAX - 1LL)
# define LLONG_MAX __LONG_LONG_MAX__
# define ULLONG_MAX (LLONG_MAX * 2ULL + 1ULL)
# define LONG_LONG_MIN (-LONG_LONG_MAX - 1LL)
# define LONG_LONG_MAX __LONG_LONG_MAX__
# define ULONG_LONG_MAX (LONG_LONG_MAX * 2ULL + 1ULL)
~~~
