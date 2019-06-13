# -*- coding: utf-8 -*-
"""
Created on Mon Aug  6 18:39:24 2018
2018-08-06
地图信息面向对象开发
多线程采集在另外一个包内实现
采用schedule和threading模块
@author: Administrator
"""

import pandas as pd
import math
import urllib
import json
import time


class Baidumap:
    def __init__(self,service='place',ping_freq=0.1):
        """
        百度地图的爬虫框架，通过百度地图api进行信息采集
        默认json返回
        input_info:输入信息
        services：服务，分为地点检索，经纬度查询等，默认是地点检索。
        """
        self.token = 'xxxxx' #your token
        self.service = service
        self.service_dict = {
                #地点检索，输入地址或关键字，返回搜索信息
                'place':'http://api.map.baidu.com/place/v2/search?',
                #地理编码，输入地址，返回百度经纬度
                #或者逆地理编码，输入百度经纬度，返回地址
                'geocoder':'http://api.map.baidu.com/geocoder/v2/?',
                #坐标转换，将其他坐标系转换为百度坐标系
                'geoconv':'http://api.map.baidu.com/geoconv/v1/?',
                }
        self.sleep_time = 0.5#unit   -second
        
    def urlGenerator(self,**arg):
        """
        service_place
            url生成器，可以理解为url字符串拼接具体参数如下：
            query    检索关键字 必选
            tag      检索分类偏好 可选
            region    检索行政区划区域增加区域内数据召回权重，
                      如需严格限制召回数据在区域内，请搭配使用city_limit参数  必选
            city_limit 区域数据召回限制，为true时，仅召回region对应区域内数据 可选
            output    输出格式为json或者xml 可选
            scope     检索结果详细程度。取值为1 或空，则返回基本信息；取值为2，
                      返回检索POI详细信息   可选
            filter     检索过滤条件 设置该字段可以提高检索速度和过滤精度，详情见文档 可选
            page_num   分页页码,与page_size配合使用 可选
            page_size  单次召回POI数量，默认为10条记录，最大返回20条。 可选
            ak         开发者的访问密匙  必选
            sn         开发者的权限签名，ak校检方式为sn时，必选
            timestamp  时间戳，必选
        service_geocoder
            address 标准的结构化地址信息【推荐，地址结构越完整，解析精度越高】 必选
            city    地址所在的城市名。用于指定上述地址所在的城市，当多个城市都有上述地址时，
                    该参数起到过滤作用，但不限制坐标召回城市。 
            ret_coordtype 返回国测局经纬度坐标或百度米制坐标
        """
        arg_list = [a+'='+urllib.request.quote(b) for a,b in list(arg.items())]
        scheme = self.service_dict.get(self.service)
        url_str = scheme + '&'.join(arg_list)  + '&output=json' + '&ak=' + self.token
        return url_str
    
    def request(self,url):
        """
        输入url地址，返回对应的json信息
        """
        try:
            js = urllib.request.urlopen(url).read().decode('utf-8')
        except Exception as e:
            print(e)
        ret = json.loads(js)
        return ret
    
    def getPlaceResult(self,url):
        """
        返回地点检索的所有数据，
        """
        if self.service != 'place':
            raise Exception('该实例不是地点检索,请实例化时，选择place作为service参数的值')
        if 'page_num=0' not in url:
            raise Exception('url中不含页码页面，请加入page_num网关')
        ret = self.request(url)
        total = ret.get('total')
        page_nums = int(total/10)+1
        results_list = []#初始化序列容器
        for i in range(page_nums):
            new_url = url.replace("page_num=0",'page_num='+str(i))#重新拼接url
            new_ret = self.request(new_url)#新的jsoN
            new_list = new_ret.get('results')#新的返回值
            results_list.extend(new_list)
            time.sleep(self.sleep_time)#如果因为ping的速度过快，这里调整
        return pd.DataFrame(results_list) #返回dataframe对象

    def transCoordinate(self,df_coordinate):
        """
        输入一个{'lat':37.92,'lng':112.535}百度坐标系df,
        *lat(纬度)前，lng（经度）后*，必须，否则返回结果错误
        输出一个腾讯坐标系（可以在excel_powermap中使用），输出格式为dataframe
        腾讯坐标系目前是10万次配额
        /ws/coord/v1/translate
        一般是读入一个经纬度做字典的Series结构，如下
        纬度前，经度后，纬度和经度之间用","分隔，每组坐标之间使用";"分隔；
        批量支持坐标个数以HTTP GET方法请求上限为准 
         批量进行坐标转换,一组10个经纬度为宜，中间需要sleep 0.5秒
         type = 3写定转换百度坐标
        """
        tencent_token = 'xxx-xxx-xxx'#your tencent token
        num = math.ceil(len(df_coordinate)/10)#向上取整
        total = []
        for i in range(num):
            df_coordinate_split = df_coordinate[i*10:(i+1)*10]
            coordi_list = [str(a.get('lat')) + ',' +str(a.get('lng')) 
                            for a in df_coordinate_split]
            coordi_str = ';'.join(coordi_list)
            url = """https://apis.map.qq.com/ws/coord/v1/translate?locations=%s&type=3&key=%s"""%(coordi_str,tencent_token)
            ret = urllib.request.urlopen(url).read().decode('utf-8')
            if """"status": 0""" not in ret:
                print('返回结果不正确')
            res = json.loads(ret).get('locations')
            total.extend(res)
            time.sleep(self.sleep_time)
        result = pd.DataFrame(total)
        return  result
    
    def getPlaceResult_detail(self,uid):
        """
        输入一个uid,该信息点的明细信息
        为了减少ping的次数，最好在使用getplaceresult中先筛选条件，
        然后再进入这里获得详细信息。
        """
        url = """http://api.map.baidu.com/place/v2/detail?uid=%s&output=json&scope=2&ak=%s"""%(
                uid,self.token)
        ret = self.request(url)
        res = pd.DataFrame(ret.get('result'))
        #todo,这里只是非常粗糙的进行了机构转换，需要具体把明细抽取出来
        return res




























        
