# -*- coding: utf-8 -*-
"""
Created on Sun May 12 10:11:50 2019
数据库信息查询类

码值字段    field_comment -->  fkidornr
@author: zhangtong
"""

import pandas as pd

import cx_Oracle
from sqlalchemy import types,create_engine

class Oracleinfo(object):
    def __init__(self,**kwds):
        """
        初始化这个类的时候需要填入以下信息
        user:用户名
        pwd:密码
        host:地址
        port:端口
        instance:实例化名称
        """
        engine = create_engine(
        ''.join(['oracle+cx_oracle://',#连接模式
                '%s:'%kwds.get('user'),
                '%s@'%kwds.get('pwd'),
                '%s:%s'%(kwds.get('host'),kwds.get('port')),
                '/?service_name=%s'%kwds.get('instance')]))
        try:
            engine.connect()
            print('链接正常可以使用')
            self.engine = engine
            self.user = kwds.get('user')
        except Exception as e:
            print('链接异常')
            print(e)
    
    def read_sql(self,sql_text,fillna=True):
        df = pd.read_sql(sql_text,self.engine)
        if fillna == True:
            df.fillna(value='',inplace=True)
            return df
        elif fillna == False:
            return df
        else:pass
        
    def check_object(self,ob_name,c_type='FUNCTION',details=False):
        """
        查找函数,存储过程是否存在
        PROCEDURE    FUNCTION
        """
        if details == False:
            sql_text = """
                    select distinct name,type 
                    from user_source
                    where name = '%s' and type = '%s'"""%(ob_name,c_type)
            df = self.read_sql(sql_text)
            if ob_name in df['name'].to_list():
                return True
            else:
                return False
        if details == True:
            sql_text = """
                    select TEXT
                    from user_source
                    where name = '%s' and type = '%s'"""%(ob_name,c_type)
            df = self.read_sql(sql_text)
        return ''.join(df['text'].to_list())
    
    def check_table(self,tb_name):
        """
        查询表是否存在
        """
        return self.engine.engine.has_table(tb_name)
    
    def to_sql(self,df,tb_name,if_exists='append',chunksize=1000):
        #将null填充为‘’可以防止下一步写入时候出现ORA-00906 错误
        df.fillna(value='',inplace=True)
        #强制将object类型的字段转换为varchar,防止写入时默认为bolb类型，严重降低效率
        dtyp = {c:types.VARCHAR(df[c].str.len().max())
            for c in df.columns[df.dtypes == 'object'].tolist()}
        df.to_sql(tb_name,self.engine,if_exists=if_exists,
                  chunksize =chunksize,index=False,dtype=dtyp)
        print('df已经写入完毕')
    
    