---
layout: post
title: 精通nginx
date: 2015-01-01
category: nginx
---

###nginx配置文件路径
~~~
wspace@mmweb:~/nginx/bin$ ls ../etc/  
wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] open() "/home/wspace/nginx/etc/nginx.conf" failed (2: No such file or directory)
wspace@mmweb:~/nginx/bin$

wspace@mmweb:~/nginx/bin$ ./nginx -c ../etc.old/nginx.conf
nginx: [emerg] open() "/home/wspace/nginx/../etc.old/nginx.conf" failed (2: No such file or directory)
wspace@mmweb:~/nginx/bin$ ./nginx -c etc.old/nginx.conf
nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
wspace@mmweb:~/nginx/bin$

wspace@mmweb:~/nginx/bin$ ./nginx -p /home/wspace/etc.old -c nginx.conf
nginx: [alert] could not open error log file: open() "/home/wspace/etc.old/data/log/error.log" failed (2: No such file or directory)
2016/01/28 12:36:11 [emerg] 15290#0: open() "/home/wspace/etc.old/nginx.conf" failed (2: No such file or directory)
wspace@mmweb:~/nginx/bin$
~~~
如果命令行没有使用-c选项,那么nginx会从编译时指定的配置文件路径读取配置.
如果使用-c,且使用相对路径,那么是*相对于编译时的prefix*,除非使用-p选项.

###如果nginx配置文件不可读,报错是啥?
~~~
wspace@mmweb:~/nginx/bin$ ls -l ../etc/nginx.conf
---------- 1 wspace wspace 0 1月  29 02:13 ../etc/nginx.conf
wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] open() "/home/wspace/nginx/etc/nginx.conf" failed (13: Permission denied)
wspace@mmweb:~/nginx/bin$
~~~

###如果配置文件存在且可读,但是为空
~~~
wspace@mmweb:~/nginx/bin$ chmod 600 ../etc/nginx.conf
wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] no "events" section in configuration
wspace@mmweb:~/nginx/bin$ ls -l ../etc/nginx.conf
-rw------- 1 wspace wspace 0 1月  29 02:13 ../etc/nginx.conf
wspace@mmweb:~/nginx/bin$
~~~
这么看来,events是nginx启动的必需section.
~~~
wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] unexpected end of file, expecting ";" or "}" in /home/wspace/nginx/etc/nginx.conf:2
wspace@mmweb:~/nginx/bin$ cat ../etc/nginx.conf
events
wspace@mmweb:~/nginx/bin$

wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] unexpected end of file, expecting "}" in /home/wspace/nginx/etc/nginx.conf:2
wspace@mmweb:~/nginx/bin$ cat ../etc/nginx.conf
events {
wspace@mmweb:~/nginx/bin$


wspace@mmweb:~/nginx/bin$ ./nginx 
nginx: [emerg] unexpected "}" in /home/wspace/nginx/etc/nginx.conf:1
wspace@mmweb:~/nginx/bin$ cat ../etc/nginx.conf
events }
wspace@mmweb:~/nginx/bin$


~~~
";"是语句结束符,"}"是section结束符,因为nginx只读到了events,直到文件结束都没有读到两个结束符,这肯定
是语法错误.

###nginx能启动的最小配置
~~~
wspace@mmweb:~/nginx/bin$ ./nginx 
wspace@mmweb:~/nginx/bin$ cat ../etc/nginx.conf
events {}
wspace@mmweb:~/nginx/bin$

wspace@mmweb:~/nginx/bin$ ./nginx 
wspace@mmweb:~/nginx/bin$ netstat -anltp | grep nginx
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
wspace@mmweb:~/nginx/bin$
~~~
既然没有报错,那么events{}就是一个合法的section.但是,没有监听任何端口.

###nginx会监听端口的最小配置
~~~
wspace@mmweb:~/nginx/bin$ ./nginx 
wspace@mmweb:~/nginx/bin$ netstat -anltp | grep nginx
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
tcp        0      0 0.0.0.0:8000                0.0.0.0:*                   LISTEN      16742/nginx         
wspace@mmweb:~/nginx/bin$ cat ../etc/nginx.conf 
events {}

http {
    server {
    }
}
wspace@mmweb:~/nginx/bin$
wspace@mmweb:~/nginx/bin$ curl 127.0.0.1:8000
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
~~~
因为wspace不是root用户,无权限监听80端口,所有nginx改为监听8000端口.

###用python写客户端来测试nginx
~~~
1 #!/usr/bin/env python
 2 
 3 import socket
 4 import sys
 5 
 6 def send_request(sock, method, path, http_version, request_headers, body=None):
 7     request_line = "%s %s HTTP/%s\n" % (method, path, http_version)
 8     http_msg = request_line + "\n".join([":".join(kv) for kv in request_headers.items()]) + "\n\r\n"
 9     sock.sendall(http_msg)
10 
11 
12 remote_ip = "127.0.0.1"
13 remote_port = 8000
14 ip_port_pair = (remote_ip, remote_port)
15 
16 sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0)
17 sock.connect(ip_port_pair)
18 
19 method = "GET"
20 path = "/"
21 http_version = "1.1"
22 request_headers = {}
23 #request_headers["Host"] = "127.0.0.1"
24 
25 send_request(sock, method, path, http_version, request_headers)
26 
27 data = sock.recv(1024)
28 print(data)

wspace@mmweb:~/nginx/bin$ ./client.py 
HTTP/1.1 400 Bad Request
Server: nginx/1.9.10
Date: Fri, 29 Jan 2016 04:24:11 GMT
Content-Type: text/html
Content-Length: 173
Connection: close

<html>
<head><title>400 Bad Request</title></head>
<body bgcolor="white">
<center><h1>400 Bad Request</h1></center>
<hr><center>nginx/1.9.10</center>
</body>
</html>
~~~
如果请求头部没有Host,则nginx会认为该请求是错误的,返回400,即所谓的客户端错误.

~~~
wspace@mmweb:~/nginx/bin$ ./client.py 
HTTP/1.1 200 OK
Server: nginx/1.9.10
Date: Fri, 29 Jan 2016 04:24:49 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Thu, 28 Jan 2016 09:46:49 GMT
Connection: keep-alive
ETag: "56a9e389-264"
Accept-Ranges: bytes

<!DOCTYPE html>
<html>
<head> 
.....
</html>
~~~
如果请求头有Host, 那么ntinx会返回200,所以说,对于默认配置的ngxin,Host头部不可以省略.







