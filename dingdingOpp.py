# -*- coding: utf-8 -*-
"""
Created on Tue Sep 25 16:20:06 2018
钉钉播报类包
钉钉文档
https://open-doc.dingtalk.com/docs/doc.htm?spm=a219a.7629140.0.0.p7hJKp&treeId=257&articleId=105735&docType=1
@author: peter
"""
import pandas as pd
import urllib
import json
import pyodbc
#需要安装为中文和英文开放的全宽库
#pip install tabulate[widechars]
import tabulate
#禁用全局宽字符而不用卸载使用以下命令
#tabulate.WIDE_CHARS_MODE = False
import datetime

class DingdingReporter():
    def __init__(self,webhook,listener_list):
        """
        钉钉播报的类库，参数必须选择机器人的webhook和@人的列表
        """
        self.webhook = webhook
        self.listener_list = listener_list
    
    
    def send_request(self,datas):
        #传入url和内容发送请求
        # 构建一下请求头部
        url = self.webhook
        header = {
            "Content-Type": "application/json",
            "Charset": "UTF-8"
        }
        sendData = json.dumps(datas)  # 将字典类型数据转化为json格式
        sendDatas = sendData.encode("utf-8")  # python3的Request要求data为byte类型
        # 发送请求
        request = urllib.request.Request(url=url, data=sendDatas, headers=header)
        # 将请求发回的数据构建成为文件格式
        opener = urllib.request.urlopen(request)
        # 7、打印返回的结果
        print(opener.read())

    
    def text_gennerator(self,text): 
        report_list = self.listener_list
        """
        传入一个报告人列表和文本文档，生成一个字典数据结构，
        整理成符合钉钉传入标准
        """
        user_tele = "@" + ";@".join(report_list)
        dic = {
             "msgtype": "text",
             "text": {
                 "content": "%s\n,%s"%(text,user_tele)
             },
             "at": {
                 "atMobiles": report_list, 
                 "isAtAll": False
             }
         }
        return dic
    
    def send_text(self,text,title=""):
        now = datetime.datetime.now()
        time_stamp = now.strftime('%Y-%m-%d %X')
        a = self.text_gennerator("\n".join([title,
                                            '播报时间:'+time_stamp,
                                            text
                                  ]))
        self.send_request(a)
    
        
    def getDataFromSQL(self,sql_sentence):
        """
        121生产服务器的地址和
        """
        conn_str = "".join(['DRIVER={SQL Server Native Client 10.0};',
                    "SERVER=xx.xx.xxx.xxx;",
                    "DATABASE=xxxx;",
                    "UID=xxxx;",
                    "PWD=xxxxr"])
        conn = pyodbc.connect(conn_str)#直接在数据库服务器上形成键值
        sql_str = sql_sentence
        return pd.read_sql(sql_str,conn)

    def dataFrameTostr(self,DataFrame,transform=False):
        """
        dataFrame 到文本格式输出
        pipe 默认格式 抽象的
        html  html格式
        simple 简易格式，但是不易整理
        plain  白板格式，没有任何内容
        另外，如果需要格式转换，则在参数transform设置为True
        这样做的好处是可以很好适应手机端，坏处是列多的话，可能会太长
        """
        x = tabulate.tabulate(DataFrame,
                              headers=DataFrame.columns,
                              tablefmt='pipe',
                              showindex='any',
                              floatfmt='.2f')
        if transform == True:
            DataFrame.fillna(value='',inplace=True)
            k = []
            for i in range(len(DataFrame)):
                row = DataFrame.iloc[i]
                l = list(zip(DataFrame.columns,row.values))
                z = []
                for n in l:
                    if isinstance(n[1],float):
                        text = str(n[0]) + ':' + format(n[1],',.2f')
                    else:
                        text = str(n[0]) + ':' + str(n[1])
                    z.append(text)
                text_mid = '\n'+'-'*20 + '\n' + '\n'.join(z) 
                k.append(text_mid)
            x = ''.join(k) + '\n' +'-'*20 
        return x

    def sqlToSend(self,sql_str,title="",transform=False):
        """
        直接写入sql,结果输出至webhood所在的群中
        """
        data = self.getDataFromSQL(sql_str)
        text = self.dataFrameTostr(data,transform=transform)
        self.send_text(text,title)
    
    













