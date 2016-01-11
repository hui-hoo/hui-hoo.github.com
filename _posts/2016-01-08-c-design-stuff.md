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
   
2. 在C代码中,"123\n456"中的\n是由编译器来替换成真正的换行符,还是printf等输出函数来
替换?

~~~
huihoo@lw:~/wspace/c$ cat hello.c 
#include <stdio.h> 
#include <stdlib.h>

int main(void)
{ 
      char *p = malloc(10);  
        scanf("%s", p);
          printf("%s", p);
            return 0;
} 
huihoo@lw:~/wspace/c$ make
gcc -Wall -pedantic -o run hello.c
huihoo@lw:~/wspace/c$ ./run 
123\n456
123\n456huihoo@lw:~/wspace/c$


huihoo@lw:~/wspace/c$ cat hello.c 
#include <stdio.h> 
#include <stdlib.h>

int main(void)
{ 
      char *p = "123123\n456456";
        printf("%s", p);
          return 0;
} 
huihoo@lw:~/wspace/c$ make
gcc -Wall -pedantic -o run hello.c
huihoo@lw:~/wspace/c$ ./run 
123123
456456huihoo@lw:~/wspace/c$ strings run |grep -A2 123123
123123
456456
;*3$"
huihoo@lw:~/wspace/c$
~~~

第一个实验利用的是用户的输入不会经过编译器处理,直接送给printf输出
函数处理.

从第二个实验可以看出,字符串常量"123123\n456456"在二进制中存储为
123123换行符456456,这就证明将\n转为换行符是编译器所为,而不是运行时
才由printf等输出函数进行转换.
   
两个实验都证明了\n的转换是编译时处理,而不是运行时处理.
继续拓展开来,也就是说,C语言中的字符串是不是所见即所得,也就是说,不是
按照编码规则,逐个字符转换成机器编码,而是先根据转换规则,比如说\n替换
成换行符,\t替换成水平分隔符等规则,对字符串进行处理,然后才按照编码规
则,逐个字符转换成机器编码.

为什么不采用所见即所得的字符串呢?
根据我推测,有可能是水平分隔符和空格难以区分,而\t和空格的区别就很明显
而且,还有很多非打印字符难以从键盘输入,比如说垂直分隔符.
转义的思路就是用两个以上的字符来表示另外的字符,为了转义的简便,一般会
选一个字符作为转义字符,比如说常见的\.\0组合表示NULL, \b表示退格等等.


3. 
