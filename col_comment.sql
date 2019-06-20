

/*****************************************
创建一个查询字段备注的存储过程
给字段增加注释     sp_addextendedproperty
给字段更新注释     sp_updateextendedproperty
删除字段注释       sp_dropextendedproperty
数据字典查看       up_sys_gettableinfo tb_cg_tem
example:
--给 tb_cg_tem 表 添加表注释
EXECUTE sp_addextendedproperty
      @name = 'tb_cg_tem',
      @value = '苏珊团队架构表',
      @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'TABLE',
    @level1name=N'tb_cg_tem',
    @level2type=null,
    @level2name=null
--给 tb_cg_tem中的c_name字段添加注释为部门名称
EXECUTE sp_addextendedproperty
      @name = 'tb_cg_tem',
      @value = '部门名称',
      @level0type=N'SCHEMA',
    @level0name=N'dbo',
    @level1type=N'TABLE',
    @level1name=N'tb_cg_tem',
    @level2type=N'COLUMN',
    @level2name=N'c_name'
 
--删除表中列a1的描述属性：
 EXEC sp_dropextendedproperty 'MS_Description','user',dbo,'table','表','column',a1
******************************************/
if exists(select * from sysobjects where name = 'up_getdatadict')
      drop proc up_getDataDict
go
create proc up_getDataDict
                  @tb_name varchar(100),
                  @field_name varchar(100) = null, --默认是空，直接带出整表的数据
                  @is_search bit = False              --是否查找注释，真值为开启查找，同时关闭字段查找，默认假值
as
if (@is_search = 1)
      begin
            SELECT
                  c.name as columnName,
                  a.VALUE as columnDescript
            into #a
            FROM
                  sys.extended_properties a,
                  sysobjects b,
                  sys.columns c
            WHERE
                  a.major_id = b.id
                  AND c.object_id = b.id
                  AND c.column_id = a.minor_id
                  AND b.name = @tb_name
            select * from #a
            where cast(columnDescript as varchar(100)) like '%' + @field_name + '%' 
      end
if (@field_name is null or @field_name = '') and @is_search = 0
      begin
            SELECT
                  c.name as columnName,
                  a.VALUE as columnDescript
            FROM
                  sys.extended_properties a,
                  sysobjects b,
                  sys.columns c
            WHERE
                  a.major_id = b.id
                  AND c.object_id = b.id
                  AND c.column_id = a.minor_id
                  AND b.name = @tb_name
      end
if @is_search = 0 and not (@field_name is null or @field_name = '')
      begin
            set nocount on;
      
            SELECT
                  c.name as columnName,
                  a.VALUE as columnDescript
            FROM
                  sys.extended_properties a,
                  sysobjects b,
                  sys.columns c
            WHERE
                  a.major_id = b.id
                  AND c.object_id = b.id
                  AND c.column_id = a.minor_id
                  AND b.name = @tb_name
                  and c.name like '%' + @field_name + '%'
      end
