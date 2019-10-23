/********************************
  2019-10-17
  oracle 内置函数梳理
  https://docs.oracle.com/javadb/10.8.3.0/ref/rrefsqlj55788.html
  ①Standard built-in functions
*********************************/

-- abs absval
-- 返回数值表达式的绝对值。返回类型是参数的类型。
-- 支持所有内置的数字类型(DECIMAL、DOUBLE PRECISION、
-- FLOAT、INTEGER、BIGINT、numeric、REAL和SMALLINT)。

select abs('-3') from dual;
select abs(-3.00) from dual


-- acos
-- ACOS函数返回指定数字的反余弦值。
-- 这个特定的数是你想要的角度的余弦值，单位是弧度。
-- 指定的数字必须是双精度数字。如果指定的数字为空，则此函数的结果为空。
-- 如果指定数字的绝对值大于1，则返回一个异常，表明该值超出范围(SQL state 22003)。
-- pai
select acos(-1.0) from dual;

-- asin
-- ASIN函数返回指定数字的反正弦值。
select asin(sin(2)) from dual;

-- atan
-- ATAN函数返回指定数字的反正切值。

select atan(100) from dual;

-- cast
-- 日期/时间值可以始终与TIMESTAMP相互转换。
-- 如果将DATE转换为TIMESTAMP，则生成的TIMESTAMP的TIME分量始终为00:00:00。
-- 如果将TIME数据值转换为TIMESTAMP，则在执行CAST时DATE组件将设置为CURRENT_DATE的值。
-- 如果将TIMESTAMP转换为DATE，则TIME组件将被静默截断。
-- 如果将TIMESTAMP转换为TIME，则DATE组件将被静默截断。

select CAST ('-10101001' as number)  from dual;


--ceil  ceiling
-- CEIL和CEILING函数将指定的数字向上舍入，
-- 并返回大于或等于指定数字的最小数字。

select ceil(10.0111) from dual;

/*******************************************************
  2019-10-18
  字符串函数
*******************************************************/

-- lower 小写
-- upper 大写
-- initcap 首字母大写
select initcap('hello world') from dual;
-- length 和 lengthb有别，这个也可以用在一个字符串上有几个中文上
select lengthb('你好 世界') from dual;
select length('你好 世界') from dual;

select lengthb('你是lebron james吗？') - length('你是lebron james吗？') as cn_char
from dual;

-- SUBSTR 截取指定的字符串长度

-- INSTR  查找位置，类似查找下标索引,下标从1开始,第三个参数为从第几下标开始查询
select instr('abcdabcd','a',4) from dual;

-- REPLACE 替换
select replace('ali mohd khan','mohd','mohammed') from dual;

-- TRANSLATE 这个函数用于加密字符。凯撒密码
-- 例如，可以使用这个函数用编码字符替换给定字符串中的字符。
-- python彩蛋this就是用凯撒密码做的，有兴趣可以看下实现哦~

select translate('interface','ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
      'BCDEFGHIJKLMNOPQRSTUVWXYZAbcdefghijklmnopqrstuvwxyza') Caesar_pw from dual;

-- SOUNDEX 这个函数用于检查发音，而不是精确的字符。
-- 例如，许多人把名字写成smith或smyth或smythe，但他们的发音只有smith。

select *
from CUSTOMERS
where soundex(address) = soundex('kuta'); --实际为Kota

-- RPAD 将给定的字符串右对齐到n个字符

select rpad(name,10),name from CUSTOMERS;

-- lpad 同上左对齐

select lpad(name,10,'*'),name from CUSTOMERS;

-- trim 取消空格
-- ltrim 取消左侧空格
-- rtrim 取消右侧空格

-- CONCAT 将字符串链接
Select concat(concat(name,' live in  '),ADDRESS) words from customers;

-- nullif
-- Oracle / PLSQL NULLIF函数比较expr1和expr2。
-- 如果expr1和expr2相等，则NULLIF函数将返回NULL。 否则，它返回expr1

select NULLIF(12, 13) from dual;
select NULLIF(12, 12) from dual;
select NULLIF('bacon', 'hotdog') from dual;


-- CURRENT_DATE
-- 当前日期返回当前日期;如果在一条语句中执行多次，则返回的值不会改变。
-- 这意味着即使在获取游标中的行之间有很长时间的延迟，该值也是固定的。

select current_date from DUAL;

-- CURRENT ISOLATION
-- 当前隔离以char(2)值的形式返回当前隔离级别，
-- 该值可以是“”(空白)、“UR”、“CS”、“RS”或“RR”。


/*设置隔离级别示例*/
COMMIT;

SET TRANSACTION READ ONLY NAME 'Toronto';

SELECT product_id, quantity_on_hand FROM inventories
   WHERE warehouse_id = 5
   ORDER BY product_id;

COMMIT;

-- CURRENT_TIME
-- 当前时间返回当前时间;如果在一条语句中执行多次，则返回的值不会改变。
-- 这意味着即使在获取游标中的行之间有很长时间的延迟，该值也是固定的。
--   current 返回会话session中的时间，而sys time 返回系统时间
SELECT SYSDATE, CURRENT_TIMESTAMP  FROM DUAL;

select CURRENT_TIMESTAMP from dual;



-- CURRENT_USER
-- 在外部存储例程中使用时，CURRENT_USER，USER和SESSION_USER
-- 都返回创建SQL会话的用户的授权标识符。
-- 当在存储例程中使用时，会话用户也总是返回此值。


-- date
-- DATE函数从一个值返回一个日期。
-- 参数必须是日期、时间戳、小于或等于2,932,897的正数、
-- 日期或时间戳的有效字符串表示形式、长度为7但不是CLOB、
-- LONG VARCHAR或XML值的字符串。如果参数是长度为7的字符串，
-- 它必须以yyyynnn的形式表示一个有效日期，其中yyyy是表示一年的数字，
-- 而nnn是001到366之间的数字，表示那一年的一天。函数的结果是一个日期。
-- 如果参数可以为空，则结果可以为空;如果参数为空，则结果为空值。

/*************************************
  2019-10-21
  oracle date函数
**************************************/
----------------------------------------------------------------------------------------
-- add_months
select ADD_MONTHS(sysdate,4) from dual;
-- CURRENT_DATE
-- CURRENT_TIMESTAMP

-- DBTIMEZONE 返回当前数据库的时区
SELECT DBTIMEZONE FROM dual;

-- EXTRACT 从日期时间值中提取日期时间字段的值，例如年、月、日。
-- 小时，分秒无法解析
select EXTRACT(year FROM SYSDATE) from dual;

-- 截取time部分
select substr(to_char(sysdate,'yyyy-mm-dd hh:mi:ss'),12,20) from dual;

-- FROM_TZ 将时间戳和时区转换为具有时区值的时间戳
select FROM_TZ(TIMESTAMP '2017-08-08 08:09:10', '-09:00') from dual;

-- last_day 获取指定日期的当月的最后一天。
-- 需要注意的是，时间time部分返回当前的时间部分，而不是23：59：59
select last_day(sysdate) from dual;

-- LOCALTIMESTAMP 返回表示会话时区中的当前日期和时间的时间戳值。
-- 中美时差8小时 囧
SELECT LOCALTIMESTAMP FROM dual;

-- MONTHS_BETWEEN 返回两个日期之间的月数。
select MONTHS_BETWEEN( DATE '2017-07-01',
    DATE '2017-01-01' )  as diff_days from dual;

-- 计算两天直接的天数使用以下方法
select trunc(sysdate) - to_date('2019-08-01', 'yyyy-mm-dd') diff
from dual;

-- new_time 将一个时区的日期转换为另一个时区的日期
select NEW_TIME( TO_DATE( '08-07-2017 01:30:45', 'MM-DD-YYYY HH24:MI:SS' ),
    'AST', 'PST' ) as new_t
from dual;

-- NEXT_DAY 获得比指定日期晚的第一个工作日。
select next_day(sysdate,'星期一') from dual;

-- ROUND  返回四舍五入到特定度量单位的日期。
-- 非常实用的区别上下午的办法
select ROUND(sysdate, 'dd') from dual;
select ROUND(DATE '2017-07-16', 'MM') from dual;

-- SESSIONTIMEZONE 获取会话时区 默认utc
SELECT SESSIONTIMEZONE FROM dual;

-- sysdate返回Oracle数据库所在的操作系统的当前系统日期和时间。
select sysdate from dual;
SELECT SYSTIMESTAMP FROM dual;


-- TO_CHAR 将日期或间隔值转换为指定格式的字符串。
select TO_CHAR( DATE'2019-10-21', 'DL' ) from dual;

-- 带或不带句号的公元指示符。
select TO_CHAR( DATE'2019-10-21', 'AD' ) from dual;

select TO_CHAR( DATE'2019-10-21', 'BC' ) from dual;

--21世纪
select TO_CHAR( DATE'2001-10-21', 'SCC' ) from dual;

select TO_CHAR( DATE'2001-10-21', 'CC' ) from dual;

-- Day of week (1-7). 周日为第一天
select TO_CHAR( sysdate, 'D' ) from dual;

--由系统定义的nls 语言，比如星期一
select TO_CHAR( sysdate, 'DAY' ) from dual;

--一个月当中的第几天
select TO_CHAR( sysdate, 'DD' ) from dual;

--一年当中的第几天
select TO_CHAR( sysdate, 'DDD' ) from dual;

-- 长日期格式由NLS日期格式参数决定。只有TS元素，用空格隔开。

select TO_CHAR( sysdate, 'DL' ) from dual;

-- 短日期格式由NLS领域和NLS语言参数控制。只与TS元素一起使用，中间用空格隔开。
select TO_CHAR( sysdate, 'DS' ) from dual;

-- 天的缩写,当然如果nls是中文，将返回如星期一之类的数据
select TO_CHAR( sysdate, 'DY' ) from dual;

-- 缩写的时代名，如日本帝国、台湾官员等。中国大陆此项无用
select TO_CHAR( sysdate, 'E' ) from dual;

select TO_CHAR( sysdate, 'EE' ) from dual;

--日期的小数部分
select TO_CHAR( sysdate, 'FF' ) from dual;

-- 返回一个没有前导或尾随空格的值。
select TO_CHAR( sysdate, 'FM' ) from dual;

-- 需要字符数据和格式模型之间的精确匹配。
select TO_CHAR( sysdate, 'FX' ) from dual;

--12小时制的小时部分
select TO_CHAR( sysdate, 'HH' ) from dual;
select TO_CHAR( sysdate, 'HH12' ) from dual;
--24小时制的小时部分
select TO_CHAR( sysdate, 'HH24' ) from dual;

-- 一年中的一周(1-52或1-53)根据ISO标准。第几个工作周
select TO_CHAR( sysdate, 'IW' ) from dual;

-- ISO年份的最后1位、2位或3位4位数字。
select TO_CHAR( sysdate, 'IYYY' ) from dual;
select TO_CHAR( sysdate, 'IYY' ) from dual;
select TO_CHAR( sysdate, 'IY' ) from dual;
select TO_CHAR( sysdate, 'I' ) from dual;


-- 儒略日，即自公元前4712年1月1日起的天数。
select TO_CHAR( sysdate, 'J' ) from dual;

-- 0-59分钟
select TO_CHAR( sysdate, 'MI' ) from dual;

-- 从01到12的月份，1月是01。
select TO_CHAR( sysdate, 'MM' ) from dual;

--上午或下午
select TO_CHAR( sysdate, 'PM' ) from dual;

-- 年的四分之一(1,2,3,4;1月3月= 1)。就是季度的意思
select TO_CHAR( sysdate, 'Q' ) from dual;

-- 罗马数字月(I-XII;1 =I)
select TO_CHAR( sysdate, 'RM' ) from dual;

-- 允许您仅使用两位数存储21世纪的20世纪日期。
select TO_CHAR( sysdate, 'RR' ) from dual;

-- 一年。接受4位或2位输入。如果为两位数，则提供与RR相同的效果。
-- 如果您不希望使用此功能，请输入4位数字的年份。
select TO_CHAR( sysdate, 'RRRR' ) from dual;

-- 0-59秒
select TO_CHAR( sysdate, 'SS' ) from dual;

-- 午夜过后几秒(0-86399)。5个S
select TO_CHAR( sysdate, 'SSSSS' ) from dual;

-- 在短时间格式中，取决于NLS领域和NLS语言参数。仅与DL或DS元素一起使用，以空格分隔。
select TO_CHAR( sysdate, 'TS' ) from dual;



-- 夏令时信息。
--
-- TZD值是带有夏时制信息的缩写时区字符串。
--
-- 它必须与TZR中指定的区域相对应。
--
-- 在时间戳和间隔格式中有效，但在DATE格式中无效。
select TO_CHAR( sysdate, 'TZD' ) from dual;
select TO_CHAR( sysdate, 'TZH' ) from dual;
select TO_CHAR( sysdate, 'TZM' ) from dual;

select TO_CHAR( sysdate, 'TZR' ) from dual;


-- 一年的周数，从1到53。第一周从一年的第一天开始，一直持续到第七天。
-- 有别于IW
select TO_CHAR( sysdate, 'WW' ) from dual;

-- 一个月的第几周，范围是1到5.第1周从该月的第一天开始，到第七天结束。
select TO_CHAR( sysdate, 'W' ) from dual;

-- 4位数的年份，带逗号
select TO_CHAR( sysdate, 'Y,YYY' ) from dual;

--英文年
select TO_CHAR( sysdate, 'YEAR' ) from dual;
select TO_CHAR( sysdate, 'SYEAR' ) from dual;

--------------------------------------------------------------------------






