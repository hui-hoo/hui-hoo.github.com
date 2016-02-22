---
layout: post
title: python相关小细节
date: 2015-01-01
category: python
---

## python单词首字母大写
~~~
[root@mmweb ~]# ./123.py 
I'M A Normal String
I'm A Normal String
[root@mmweb ~]# cat 123.py 
#!/usr/bin/env python
#-*- coding:utf-8 -*-

import string

print("I'm a normal string".title())
print(string.capwords("I'm a normal string"))
[root@mmweb ~]#
~~~
str内置title方法认为单引号也是单词分界符,所以也把m转成大写,而string.capwords则是以空白符
作为单词分界符,因此capwords更符合日常需求.

###further reading
https://bugs.python.org/issue7008

##正则表达式中backreference的小技巧
~~~
wspace@lw:~$ python
Python 2.7.3 (default, Mar 13 2014, 11:03:55) 
[GCC 4.7.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import re
>>> re.search(r'(b?)o\1', 'o')
<_sre.SRE_Match object at 0x7f7aa807f300>
>>> mo = re.search(r'(b?)o\1', 'o')
>>> mo.group()
'o'
>>> mo = re.search(r'(b)?o\1', 'o')
>>> mo
>>>
要想用郑则表达式表示要么同时出现,要么同时不出现的字符串,可以用后向引用来实现.


~~~

##神奇的引用问题
~~~
pace@lw:~$ python
Python 2.7.3 (default, Mar 13 2014, 11:03:55) 
[GCC 4.7.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> lists = [[]] * 3
>>> lists
[[], [], []]
>>> lists[0].append(3)
>>> lists
[[3], [3], [3]]
>>> for l in lists:
...     print id(l)
... 
140394936665800
140394936665800
140394936665800
>>>
~~~
关键在于lists = [[]] * 3这个语句,生成的空列表都是同个对象.


##PYTHONPATH环境变量
~~~
wspace@lw:~/playground$ echo $PYTHONPATH

wspace@lw:~/playground$ ./123.py 
['/usr/local/home/playground', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-linux2', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', '/usr/lib/pymodules/python2.7']
wspace@lw:~/playground$ cat 123.py 
#!/usr/bin/env python


import sys

print sys.path
wspace@lw:~/playground$

wspace@lw:~/playground$ export PYTHONPATH="/usr/local"
wspace@lw:~/playground$ ./123.py 
['/usr/local/home/playground', '/usr/local', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-linux2', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', '/usr/lib/pymodules/python2.7']
wspace@lw:~/playground$

wspace@lw:~/playground$ echo $PYTHONPATH
/usr/local
wspace@lw:~/playground$ python -E 123.py 
['/usr/local/home/playground', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-linux2', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', '/usr/lib/pymodules/python2.7']
wspace@lw:~/playground$
~~~
sys.path是module的搜索路径列表,而第一个路径是程序运行的当前目录,紧接着的是PYTHONPATH环境变量里的路径,后面才是系统默认的搜索路径.
如果python使用了-E选项,则会忽略与python相关的一切环境变量,包括PYTHONPATH,不过该变量还是存在的.

