-- 用来存储sysstat历史统计信息的PostgreSQL 数据库
-- 密码和用户可根据自己的需要更改
-- 更改用户密码或数据库名后请牢记更新数据入库的程序.

-- 创建角色
create role sar nosuperuser nocreatedb nocreaterole noinherit login encrypted password 'DIGOAL';
-- 创建表空间(可选)
create tablespace tbs_sar owner digoal location '/home/sar/tbs_sar';
-- 创建数据库
create database sar with owner digoal template template0 encoding 'UTF8' tablespace tbs_sar;
-- 赋予数据库和表空间权限给角色sar
grant all on database sar to sar;
grant all on tablespace tbs_sar to sar;
-- 使用sar用户登录sar数据库, 创建与用户名同名的schema.
\c sar sar
create schema sar authorization sar;

-- 创建序列, 用于server主键
create sequence seq_server_id start with 1 increment by 1;

-- 创建server 表, 存储linux主机信息.
create table server(
id int primary key,
ip inet not null unique,
info text);

-- 注册时调用的函数, 根据服务器IP分配一个server ID. 如果已经存在则直接返回存在的ID.
create or replace function get_server_id (i_ip inet) returns int as $BODY$
declare
v_id int;
begin
select id into v_id from server where ip=i_ip;
if not found then
  insert into server(id, ip) values(nextval('seq_server_id'::regclass), i_ip);
  select id into v_id from server where ip=i_ip;
end if;
return v_id;
exception 
when others then
  return -1;
end
$BODY$ language plpgsql;


-- 根据server id获取服务器IP的函数, 用于在输出报告时使用.
create or replace function get_ip (i_id int) returns inet as $BODY$
declare
v_ip inet;
begin
select ip into v_ip from server where id=i_id;
return v_ip;
exception
when others then
  return '0.0.0.0/0'::inet;
end
$BODY$ language plpgsql;


-- 根据server id获得服务器的info字段信息, 用于在输出报告时使用.
CREATE OR REPLACE FUNCTION sar.get_info(i_id integer)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
v_info text;
begin
select coalesce(info,'noinfo') into v_info from server where id=i_id;
  return v_info;
exception
when others then
  return 'noinfo';
end
$function$;


-- 输入在server表里面有记录, 并且前一天没有sysstat信息入库的服务器信息. 用于在输出报告时使用. 也用于监控数据是否正常入库.
CREATE OR REPLACE FUNCTION sar.get_server_nodata_yesterday()
 RETURNS SETOF text
 LANGUAGE plpgsql
AS $function$
declare
v_result text;
begin
perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_context where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_context: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_context where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_cpu where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_cpu: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_cpu where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_inode where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_inode: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_inode where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_io where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_io: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_io where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_load where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_load: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_load where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_mem where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_mem: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_mem where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_mem_swap where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_mem_swap: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_mem_swap where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_page where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_page: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_page where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_proc where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_proc: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_proc where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

perform 1 from (select s1.* from server s1 left outer join
  (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_swap where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null) t;
if found then
  return next 'sar_swap: ';
  return query select s1.ip||', '||s1.info from server s1 left outer join
    (select * from (select server_id,row_number() over (partition by server_id order by s_date desc) from sar_swap where s_date=current_date-1) t1 
    where row_number=1) t2 on (s1.id=t2.server_id) where t2.server_id is null;
end if;

return;
end
$function$;


-- 存储sar -b 的信息表. Report I/O and transfer rate statistics.
create table sar_io
(server_id int not null,
s_date date not null,
s_time time not null,
tps numeric,
rtps numeric,
wtps numeric,
bread_p_s numeric,
bwrtn_p_s numeric,
unique(server_id,s_date,s_time));

-- 存储sar -B 的信息表. Report paging statistics
create table sar_page
(server_id int not null,
s_date date not null,
s_time time not null,
pgpgin_p_s numeric,
pgpgout_p_s numeric,
fault_p_s numeric,
majflt_p_s numeric,
unique(server_id,s_date,s_time));

-- 存储sar -c 的信息表. Report process creation activity.
create table sar_proc
(server_id int not null,
s_date date not null,
s_time time not null,
proc_p_s numeric,
unique(server_id,s_date,s_time));

-- 存储sar -q 的信息表. Report queue length and load averages.
create table sar_load
(server_id int not null,
s_date date not null,
s_time time not null,
runq_sz numeric,
plist_sz numeric,
ldavg_1 numeric,
ldavg_5 numeric,
ldavg_15 numeric,
unique(server_id,s_date,s_time));

-- 存储sar -r 的信息表. Report memory and swap space utilization statistics.
create table sar_mem_swap
(server_id int not null,
s_date date not null,
s_time time not null,
kbmemfree numeric,
kbmemused numeric,
percnt_memused numeric,
kbbuffers numeric,
kbcached numeric,
kbswpfree numeric,
kbswpused numeric,
percnt_swpused numeric,
kbswpcad numeric,
unique(server_id,s_date,s_time));

-- 存储sar -R 的信息表. Report memory statistics.
create table sar_mem
(server_id int not null,
s_date date not null,
s_time time not null,
frmpg_p_s numeric,
bufpg_p_s numeric,
campg_p_s numeric,
unique(server_id,s_date,s_time));

-- 存储sar -u 的信息表. Report CPU utilization.
create table sar_cpu
(server_id int not null,
s_date date not null,
s_time time not null,
percnt_user numeric,
percnt_nice numeric,
percnt_system numeric,
percnt_iowait numeric,
percnt_steal numeric,
percnt_idle numeric,
unique(server_id,s_date,s_time));

-- 存储sar -v 的信息表. Report status of inode, file and other kernel tables.
create table sar_inode
(server_id int not null,
s_date date not null,
s_time time not null,
dentunusd numeric,
file_sz numeric,
inode_sz numeric,
super_sz numeric,
percnt_super_sz numeric,
dquot_sz numeric,
percnt_dquot_sz numeric,
rtsig_sz numeric,
percnt_rtsig_sz numeric,
unique(server_id,s_date,s_time));

-- 存储sar -w 的信息表. Report system switching activity.
create table sar_context
(server_id int not null,
s_date date not null,
s_time time not null,
cswch_p_s numeric,
unique(server_id,s_date,s_time));

-- 存储sar -W 的信息表. Report swapping statistics.
create table sar_swap
(server_id int not null,
s_date date not null,
s_time time not null,
pswpin_p_s numeric,
pswpout_p_s numeric,
unique(server_id,s_date,s_time));



-- # Author : Digoal zhou
-- # Email : digoal@126.com
-- # Blog : http://blog.163.com/digoal@126/