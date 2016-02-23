---
layout: post
title: nginx的accept-mutex配置
date: 2015-01-04
category: nginx
---

###accept_mutex有啥用?

mutex是互斥之意,accept是socket编程里的accept,合起来的意思就是
当nginx发现有新的连接到达的时候,如果accept_mutex on,那么多个
worker进程则以串行的方式进行处理,只有其中一个worker会被唤醒,其
他woker继续睡觉,反之,accept_mutex off,则所有的worker都会被唤醒,
不过,最后只有一个worker会获取新连接,其他worker则重新去睡觉,这
就是[惊群问题](http://en.wikipedia.org/wiki/Thundering_herd_problem).

###怎么配置accept_mutex?
Nginx采取的是保守策略,默认开启accept_mutex,即不会有惊群问题.
Nginx作者Igor Sysoev曾给过相关的解释:

> OS may wake all processes waiting on accept() and select(), this is called thundering herd problem. This is a problem if you have a lot of workers as in Apache (hundreds and more), but this insensible if you have just several workers as nginx usually has. Therefore turning accept_mutex off is as scheduling incoming connection by OS via select/kqueue/epoll/etc (but not accept()).

这么说来,因为nginx的worker进程数量一般是CPU核数,最多也就是几十个,所以问题不大.
虽然把worker都唤醒带来额外的开销,但是面对一大堆连接的时候,一个一个连接分配,效率实在不乐观,所以如果你的网站访问量大,为了系统的吞吐量,可以考虑开启accept_mutex.
