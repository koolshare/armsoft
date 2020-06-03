#! /bin/sh
frps_pid=`ps | grep -w frps | grep -v grep | awk '{print $1}'`
frps_status=`ps | grep -w frps | grep -cv grep`
frps_version=`/koolshare/bin/frps -v`
if [ "$frps_status" == "1" ];then
	echo frps  $frps_version  进程运行正常！（PID：$frps_pid） > /tmp/.frps.log
else
	echo frps  $frps_version 【警告】：进程未运行！ > /tmp/.frps.log
fi
echo XU6J03M6 >> /tmp/.frps.log
sleep 2
rm -rf /tmp/.frps.log