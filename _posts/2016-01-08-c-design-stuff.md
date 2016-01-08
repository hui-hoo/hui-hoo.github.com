---
layout: post
title: C语言设计的相关问题
date: 2016-01-08
category: c
---

1. 为什么需要语句分隔符?为什么C需要分号作为语句分隔符,而不是直接使用换行符?
   有了语句分隔符,那么进行语法解析的时候,就容易知道语句已结束,没有语句分隔符,
   那只能从上下文来推断语句是否结束.至于选择任何什么符号作为语句分隔符,这就得
   考虑人类的阅读习惯.毫无疑问,换行符是最佳选择(至少我是这么认为).但是,因为C
   语言想要支持单行多语句的情况,所以只能选用其他字符来做语句分隔符.
   至于选择分号作为语句分隔符,这个应该是C语言的祖先语言习惯有关.

   既然分号是语句分隔符,那么换行符又是什么作用呢?
   大部分情况下,换行符是美化代码,提高代码可读性的作用.不过,在有些情境下,换行符
   不可以省略.
   ~~~
   huihoo@lw:~/wspace/c$ cat hello.c 
   #include<stdio.h>
   int main(void){printf("this C stuffis easy\n");return 0;} 
   huihoo@lw:~/wspace/c$ gcc -Wall -pedantic -o run hello.c 
   huihoo@lw:~/wspace/c$ ./run 
   this C stuffis easy
   huihoo@lw:~/wspace/c$

   huihoo@lw:~/wspace/c$ cat hello.c 
   #include<stdio.h> int main(void){printf("this C stuffis easy\n");return 0;} 
   huihoo@lw:~/wspace/c$ gcc -Wall -pedantic -o run hello.c 

   .....(此处省略一堆GCC的输出)
   /usr/lib/gcc/x86_64-linux-gnu/4.7/../../../x86_64-linux-gnu/crt1.o: In function
   `_start':
   (.text+0x20): undefined reference to `main'
   collect2: error: ld returned 1 exit status
   ~~~
从这里可以看出,预编译指令和真正的c代码之间的newline是不可以省略的.
   
2. 
