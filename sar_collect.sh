#!/bin/bash
# 配置环境变量, psql命令需要包含在PATH中
export LANG=en_US.utf8
export PGHOME=/home/postgres/pgsql
export LD_LIBRARY_PATH=$PGHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
export DATE=`date +"%Y%m%d%H%M"`
export PATH=$PGHOME/bin:$PATH:.

# 配置PostgreSQL数据库连接, 避免风暴随机等待60秒内
DB_URL="-h 192.168.1.100 -p 5432 -U sar -d sar"
sleep $(($RANDOM%60))

NET_DEV="`/sbin/route -n|grep UG|awk '{print $8}'|head -n 1`"
IP_ADDR="'`/sbin/ip addr show $NET_DEV|grep inet|grep "global $NET_DEV$"|awk '{print $2}'`'"
SAR_FILE="/var/log/sa/sa`date -d -1day +%d`"
SAR_DATE="'`date -d -1day +%Y-%m-%d`'"
SERVER_ID="`psql -A -t $DB_URL -c "select * from get_server_id($IP_ADDR)"`"

# sar -b, sar_io tps      rtps      wtps   bread/s   bwrtn/s
SQL=`sar -b -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_io(server_id, s_date, s_time, tps, rtps, wtps, bread_p_s, bwrtn_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5",",$6",",$7");"}'`
psql $DB_URL -c "$SQL"

# sar -B, sar_page pgpgin/s pgpgout/s   fault/s  majflt/s
SQL=`sar -B -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_page(server_id, s_date, s_time, pgpgin_p_s, pgpgout_p_s, fault_p_s, majflt_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5",",$6");"}'`
psql $DB_URL -c "$SQL"

# sar -c, sar_proc proc/s
SQL=`sar -c -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_proc(server_id, s_date, s_time, proc_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3");"}'`
psql $DB_URL -c "$SQL"

# sar -q, sar_load runq-sz  plist-sz   ldavg-1   ldavg-5  ldavg-15
SQL=`sar -q -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_load(server_id, s_date, s_time, runq_sz, plist_sz, ldavg_1, ldavg_5, ldavg_15) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5",",$6",",$7");"}'`
psql $DB_URL -c "$SQL"

# sar -r, sar_mem_swap kbmemfree kbmemused  %memused kbbuffers  kbcached kbswpfree kbswpused  %swpused  kbswpcad
SQL=`sar -r -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_mem_swap(server_id, s_date, s_time, kbmemfree, kbmemused, percnt_memused, kbbuffers, kbcached, kbswpfree, kbswpused, percnt_swpused, kbswpcad) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5",",$6",",$7",",$8",",$9",",$10",",$11");"}'`
psql $DB_URL -c "$SQL"

# sar -R, sar_mem frmpg/s   bufpg/s   campg/s
SQL=`sar -R -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_mem(server_id, s_date, s_time, frmpg_p_s, bufpg_p_s, campg_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5");"}'`
psql $DB_URL -c "$SQL"

# sar -u, sar_cpu %user     %nice   %system   %iowait    %steal     %idle
SQL=`sar -u -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_cpu(server_id, s_date, s_time, percnt_user, percnt_nice, percnt_system, percnt_iowait, percnt_steal, percnt_idle) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$4",",$5",",$6",",$7",",$8",",$9");"}'`
psql $DB_URL -c "$SQL"

# sar -v, sar_inode dentunusd   file-sz  inode-sz  super-sz %super-sz  dquot-sz %dquot-sz  rtsig-sz %rtsig-sz
SQL=`sar -v -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_inode(server_id, s_date, s_time, dentunusd, file_sz, inode_sz, super_sz, percnt_super_sz, dquot_sz, percnt_dquot_sz, rtsig_sz, percnt_rtsig_sz) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4",",$5",",$6",",$7",",$8",",$9",",$10",",$11");"}'`
psql $DB_URL -c "$SQL"

# sar -w, sar_context cswch/s
SQL=`sar -w -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_context(server_id, s_date, s_time, cswch_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3");"}'`
psql $DB_URL -c "$SQL"

# sar -W, sar_swap pswpin/s pswpout/s
SQL=`sar -W -f $SAR_FILE|grep -E 'AM[ ]+([0-9]+|\.+|all|-)|PM[ ]+([0-9]+|\.+|all|-)'|awk '{print "insert into sar_swap(server_id, s_date, s_time, pswpin_p_s, pswpout_p_s) values('$SERVER_ID', '$SAR_DATE',","\47"$1$2"\47,",$3",",$4");"}'`
psql $DB_URL -c "$SQL"



# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/