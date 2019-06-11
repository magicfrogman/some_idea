# -*- coding: utf-8 -*-
"""
Created on Mon Jul 16 08:44:14 2018
apriori 类
@author: Administrator
"""

import pandas as pd
from itertools import chain,combinations
from collections import Counter

#chain负责将结果融合为一个列表方便Counter模块计数
#combinations负责生成流水号内组合（不重复），
#但是要注意排序，不然外部可能出现一个组合多个排序现象
#与combine不同的是permutations,但是生成的项目中有重复


#关联分析类
class Apriori():
    def __init__(self,dataframe,
                 idNo_col,
                 goodsNo_col,
                 item_num=2,
                 min_supp_count=20):
        """
            apriori算法的一个模块，输入一个DataFrame对象进行计算
        ，输出频繁项集.
        模块功能分为分割数据集，生成项集数量，
        """
        if ((idNo_col not in dataframe.columns) or 
            (goodsNo_col not in dataframe.columns)):
            raise Exception("input col is not in data.col,please fix it")
        self.df = dataframe.drop_duplicates([idNo_col,goodsNo_col])#流水去重
        self.idNo_col = idNo_col#这里指货号所在列
        self.goodsNo_col = goodsNo_col#聚类元数据,在这里指流水号
        self.item_num = item_num#项集数量，默认为2项集
        self.min_supp_count = min_supp_count#最小频次数量
        self.id_count = len(set(self.df[self.idNo_col]))
    
    def single_freq(self,is_freq = False):
        """
        min_supp_count 最小支持频次
        is_freq        返回结果是频繁项集还是非频繁项集，
                        [默认返回 非 频繁项集]
        """
        df = self.df[self.idNo_col].groupby(self.df[self.goodsNo_col]).count()
        if is_freq == False:
            df_result = df[df < self.min_supp_count]
        if is_freq == True:
            df_result = df[df >= self.min_supp_count]
        return df_result.to_dict()

    def freq_item(self):
        """
        主要负责输出数据的组合，期间需要对组内元素排序等
        split,apply,combine
        """
        df = self.df[self.goodsNo_col].groupby(self.df[self.idNo_col])#split
        not_freq_set = self.single_freq(is_freq = False)#find not_freq_item
        not_freq_set = set(not_freq_set.keys())
        def pro(x,combine_num = self.item_num):
            freq_set = set(x) - not_freq_set#初始集合中去除不频繁项
            combine = list(combinations(freq_set,combine_num))#生成组合
            combine = [tuple(sorted(list(a))) for a in combine]#组内元素排序
            return combine
        df_item = df.apply(pro)
        df_item_list = [a for a in df_item if len(a)>0]
        return df_item_list
    
    def freq_result(self):
        """
        直接输出结果
        """
        df_item = list(chain(*self.freq_item()))#融合
        count = Counter(df_item)
        df = pd.DataFrame(list(zip(count.keys(),count.values()))
            ,columns=["item","count"])#3.0和2.0语法不同，zip需要套一个list
        df['combine_supp'] = df['count']/self.id_count#组合支持度
             
        
        single_dict = self.single_freq(is_freq=True)
        m = []
        for i in range(len(df)):
            combine = df[u'item'].iloc[i]
            combine_supp = df[u'combine_supp'].iloc[i]
            n = []
            for j in combine:
                goods_supp = single_dict.get(j)/self.id_count
                goods_confidence = str(round((combine_supp/goods_supp)*100,2)) +'%'
                n.append(":".join([j,goods_confidence]))
            m.append("||".join(n))
        df[u'confidence'] = m
        df[u'item'] = ['||'.join(a) for a in df[u'item']]
        df['combine_supp'] = ['{:.2%}'.format(a)
                                for a in df['combine_supp']] #格式化百分比  
        df.sort_values(by = 'count',ascending = False,inplace = True)
        return df