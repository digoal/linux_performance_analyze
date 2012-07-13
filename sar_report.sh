#!/bin/bash
# 配置环境变量, psql命令需要包含在PATH中
export LANG=en_US.utf8
export PGHOME=/home/postgres/pgsql
export LD_LIBRARY_PATH=$PGHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
export DATE=`date +"%Y%m%d%H%M"`
export PATH=$PGHOME/bin:$PATH:.

# 配置接收报告邮件的地址, 多个以空格隔开
EMAIL="digoal@126.com test@digoal.org"

# 配置PostgreSQL meta数据库连接, 本例将脚本放在PostgreSQL meta库的服务器上, 并且配置pg_hba.conf 允许127.0.0.1 trust认证. 所以不需要配置.pgpass文件.
DB_URL="-h 127.0.0.1 -p 5432 -U sar -d sar"

echo -e `date +%F\ %T` >/tmp/sar_report.log

echo -e "\n---- DailyAvgValue TOP10: ----\n" >>/tmp/sar_report.log

echo -e "\n1. ldavg_15 TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(ldavg_15),2) ldavg_15 from sar_load where s_date=current_date-1 group by server_id order by ldavg_15 desc limit 10;" >>/tmp/sar_report.log

echo -e "\n2. rtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(rtps),2) rtps from sar_io where s_date=current_date-1 group by server_id order by rtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n3. wtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(wtps),2) wtps from sar_io where s_date=current_date-1 group by server_id order by wtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n4. iowait TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(percnt_iowait),2) percnt_iowait from sar_cpu where s_date=current_date-1 group by server_id order by percnt_iowait desc limit 10;" >>/tmp/sar_report.log

echo -e "\n5. swap_page_in_out TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(pswpin_p_s+pswpout_p_s),2) pswpin_out_p_s from sar_swap where s_date=current_date-1 group by server_id order by pswpin_out_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n6. swap_usage TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(percnt_swpused),2) percnt_swpused from sar_mem_swap where s_date=current_date-1 group by server_id order by percnt_swpused desc limit 10;" >>/tmp/sar_report.log

echo -e "\n7. newproc_p_s TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(proc_p_s),2) proc_p_s from sar_proc where s_date=current_date-1 group by server_id order by proc_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n---- WeeklyAvgValue TOP10: ----\n" >>/tmp/sar_report.log

echo -e "\n1. ldavg_15 TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(ldavg_15),2) ldavg_15 from sar_load where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by ldavg_15 desc limit 10;" >>/tmp/sar_report.log

echo -e "\n2. rtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(rtps),2) rtps from sar_io where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by rtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n3. wtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(wtps),2) wtps from sar_io where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by wtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n4. iowait TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(percnt_iowait),2) percnt_iowait from sar_cpu where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by percnt_iowait desc limit 10;" >>/tmp/sar_report.log

echo -e "\n5. swap_page_in_out TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(pswpin_p_s+pswpout_p_s),2) pswpin_out_p_s from sar_swap where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by pswpin_out_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n6. swap_usage TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(percnt_swpused),2) percnt_swpused from sar_mem_swap where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by percnt_swpused desc limit 10;" >>/tmp/sar_report.log

echo -e "\n7. newproc_p_s TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),round(avg(proc_p_s),2) proc_p_s from sar_proc where s_date<=current_date-1 and s_date>=current_date-7 group by server_id order by proc_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n---- DailyMaxValue TOP10: ----\n" >>/tmp/sar_report.log

echo -e "\n1. ldavg_15 TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,runq_sz,plist_sz,ldavg_1,ldavg_5,ldavg_15 from (select *,row_number() over (partition by server_id order by ldavg_15 desc) from sar_load where s_date=current_date-1) t where row_number=1 order by ldavg_15 desc limit 10;" >>/tmp/sar_report.log

echo -e "\n2. rtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,tps,rtps,wtps,bread_p_s,bwrtn_p_s from (select *,row_number() over (partition by server_id order by rtps desc) from sar_io where s_date=current_date-1) t where row_number=1 order by rtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n3. wtps TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,tps,rtps,wtps,bread_p_s,bwrtn_p_s from (select *,row_number() over (partition by server_id order by wtps desc) from sar_io where s_date=current_date-1) t where row_number=1 order by wtps desc limit 10;" >>/tmp/sar_report.log

echo -e "\n4. iowait TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,percnt_user,percnt_nice,percnt_system,percnt_iowait,percnt_steal,percnt_idle from (select *,row_number() over (partition by server_id order by percnt_iowait desc) from sar_cpu where s_date=current_date-1) t where row_number=1 order by percnt_iowait desc limit 10;" >>/tmp/sar_report.log

echo -e "\n5. swap_page_in_out TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,pswpin_p_s,pswpout_p_s from (select *,row_number() over (partition by server_id order by pswpin_p_s+pswpout_p_s desc) from sar_swap where s_date=current_date-1) t where row_number=1 order by pswpin_p_s+pswpout_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n6. swap_usage TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,kbmemfree,kbmemused,percnt_memused,kbbuffers,kbcached,kbswpfree,kbswpused,percnt_swpused,kbswpcad from (select *,row_number() over (partition by server_id order by percnt_swpused desc) from sar_mem_swap where s_date=current_date-1) t where row_number=1 order by percnt_swpused desc limit 10;" >>/tmp/sar_report.log

echo -e "\n7. newproc_p_s TOP10 :\n" >>/tmp/sar_report.log
psql $DB_URL -c "select get_info(server_id),get_ip(server_id),s_date,s_time,proc_p_s from (select *,row_number() over (partition by server_id order by proc_p_s desc) from sar_proc where s_date=current_date-1) t where row_number=1 order by proc_p_s desc limit 10;" >>/tmp/sar_report.log

echo -e "\n---- get_server_nodata_yesterday: ----\n" >>/tmp/sar_report.log
psql $DB_URL -c "select * from get_server_nodata_yesterday();" >>/tmp/sar_report.log

cat /tmp/sar_report.log|mutt -s "`date +$F` DB Servers RS Consume Top10" $EMAIL


# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/