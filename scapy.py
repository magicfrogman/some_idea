# -*- coding: utf-8 -*-
"""
Created on Sun Jun 16 20:57:36 2019
scapy test
@author: zhangtong
"""
from scapy.all import *
import time


z = [] #初始化一个序列
def sniff_prn(package):
    src = package['IP'].src
    dst = package['IP'].dst
    sport = package['TCP'].sport
    dport = package['TCP'].dport
    z.append([src,dst,sport,dport])

#同步
#sniff(filter="tcp and ( port 80 or port 110 )",
#        #过滤条件，可以写成函数过滤，也可以bpf语法
#            prn=sniff_prn,#回调函数
#            count = 10)

#=============================================================================


#异步
t = AsyncSniffer(filter="tcp and ( port 80 or port 110 )",
        #过滤条件，可以写成函数过滤，也可以bpf语法
            prn=sniff_prn,#回调函数
            session=IPSession,
          )
t.start()
time.sleep(5) # 5秒内走过的流量
t.stop()

#=============================================================================

