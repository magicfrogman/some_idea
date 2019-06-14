/***************************************************
Oracle库字段信息查询
包括了外键关联到的表及字段，但是这里为了保持用户及表，字段的唯一性
采取了简单粗暴的切割办法，无法呈现完整的外键-外键表及字段信息
****************************************************/

--      select * from (
select t1.owner,
       t1.table_name,
       t2.column_name,
       t2.data_type,
       DECODE(T2.DATA_TYPE,
              'VARCHAR2',
              TO_CHAR(T2.DATA_LENGTH),
              'NUMBER',
              '(' || T2.DATA_PRECISION || ',' || NVL(T2.DATA_SCALE, 0) || ')',
              '-')                                               AS DATA_LENGTH,
       t3.comments,
       DECODE(T2.NULLABLE, 'N', 'Y', 'N')                        AS ISNOTNULL,
       DECODE(T4.CONSTRAINT_TYPE, 'P', t4.main_CONSTRAINT_NAME, NULL) AS PK_NAME,
       DECODE(T4.CONSTRAINT_TYPE, 'R', t4.main_CONSTRAINT_NAME, t4.sub_CONSTRAINT_NAME) AS FK_NAME,
       t4.R_OWNER,
       t4.R_CONSTRAINT_NAME,
       t4.R_TABLE_NAME,
       t4.R_COLUMN_NAME,
       T2.DATA_DEFAULT,
--       F_COUNT_DATA1(T1.TABLE_NAME, T1.OWNER, T2.COLUMN_NAME)    
'' AS YLSJ1,
--       F_COUNT_DATA2(T1.TABLE_NAME, T1.OWNER, T2.COLUMN_NAME)    
'' AS YLSJ2,
--       F_COUNT_DATA3(T1.TABLE_NAME, T1.OWNER, T2.COLUMN_NAME)    
'' AS YLSJ3

from all_tab_columns t2
         join all_tables t1
              on t2.table_name = t1.table_name and t2.owner = t1.owner
         left join all_col_comments t3
                   on t2.table_name = t3.table_name and t2.owner = t3.owner and t2.column_name = t3.column_name
         left join ( --外键信息查询
    select a.CONSTRAINT_NAME as main_CONSTRAINT_NAME,
           b.CONSTRAINT_NAME as sub_CONSTRAINT_NAME,
           a.CONSTRAINT_TYPE,
           a.TABLE_NAME,
           a.COLUMN_NAME,
           a.OWNER,
           decode(a.R_OWNER, NULL, b.R_OWNER, a.R_OWNER)                               as R_OWNER,
           decode(a.R_CONSTRAINT_NAME, NULL, b.R_CONSTRAINT_NAME, a.R_CONSTRAINT_NAME) as R_CONSTRAINT_NAME,
           decode(a.R_TABLE_NAME, NULL, b.R_TABLE_NAME, a.R_TABLE_NAME)                as R_TABLE_NAME,
           decode(a.R_COLUMN_NAME, NULL, b.R_COLUMN_NAME, a.R_COLUMN_NAME)             as R_COLUMN_NAME
    from (
             select *
             from (
                      select row_number()
                              over (partition by a.table_name,b.COLUMN_NAME,b.OWNER order by a.CONSTRAINT_TYPE) c_rank，
                          a.CONSTRAINT_NAME
                           , a.CONSTRAINT_TYPE
                           , b.TABLE_NAME
                           , b.COLUMN_NAME
                           , b.OWNER
                           , a.R_OWNER
                           , a.R_CONSTRAINT_NAME
                           ,
                          c.TABLE_NAME R_TABLE_NAME
                           ,
                          c.COLUMN_NAME R_COLUMN_NAME

                      from all_constraints a
                          left join all_cons_columns b
                      on a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
                          and a.OWNER = b.OWNER
                          and a.TABLE_NAME = b.TABLE_NAME

                          --带出外键关联的表和字段
                          left join all_cons_columns c
                          on a.R_CONSTRAINT_NAME = c.CONSTRAINT_NAME
                          and a.R_OWNER = c.OWNER

                      where (a.CONSTRAINT_TYPE = 'R' or a.CONSTRAINT_TYPE = 'P')
                          and a.OWNER = 'SYS' --这里修改owner
                  )
             where c_rank = 1) a
             left outer join
         (
             select *
             from (
                      select row_number()
                              over (partition by a.table_name,b.COLUMN_NAME,b.OWNER order by a.CONSTRAINT_TYPE) c_rank，
                          a.CONSTRAINT_NAME
                           , a.CONSTRAINT_TYPE
                           , b.TABLE_NAME
                           , b.COLUMN_NAME
                           , b.OWNER
                           ,
                          a.R_OWNER
                           , a.R_CONSTRAINT_NAME
                           ,
                          c.TABLE_NAME R_TABLE_NAME
                           ,
                          c.COLUMN_NAME R_COLUMN_NAME

                      from all_constraints a
                          left join all_cons_columns b
                      on a.CONSTRAINT_NAME = b.CONSTRAINT_NAME
                          and a.OWNER = b.OWNER
                          and a.TABLE_NAME = b.TABLE_NAME

                          --带出外键关联的表和字段
                          left join all_cons_columns c
                          on a.R_CONSTRAINT_NAME = c.CONSTRAINT_NAME
                          and a.R_OWNER = c.OWNER

                      where (a.CONSTRAINT_TYPE = 'R' or a.CONSTRAINT_TYPE = 'P')
                          and a.OWNER = 'SYS' --这里修改owner
                  )
             where c_rank = 2) b
         on a.OWNER = b.OWNER and a.TABLE_NAME = b.TABLE_NAME and a.COLUMN_NAME = b.COLUMN_NAME
) t4
                   on t2.table_name = t4.table_name and t2.OWNER = t4.OWNER and t2.COLUMN_NAME = t4.COLUMN_NAME
where t2.owner = 'SYS' --这里修改owner

