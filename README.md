linux_performance_analyze
=========================

Linux have a rpm sysstat, when you install it, it will add a crontab in /etc/cron.d/sysstat, it's content like below :
# run system activity accounting tool every 10 minutes
*/10 * * * * root /usr/lib64/sa/sa1 1 1
# generate a daily summary of process accounting at 23:53
53 23 * * * root /usr/lib64/sa/sa2 -A

You can use command sar view the history of sysstat collected, but we see the history will rotated automatic.
This linux_performance_analyze project will use postgresql store the sysstat history data.
These Linux hosts must registed in postgresql, and then every day load it's sar info into postgresql.
And we can use postgresql's SQL analyze the hosts performance, like performance's system activity information and TOP resource consume's hosts, and so on.
OK, Let's use it , easy know bulk linux Hosts's performance data, and can enjoy selflife.

# Author : Digoal zhou
# Email : digoal@126.com
# Blog : http://blog.163.com/digoal@126/