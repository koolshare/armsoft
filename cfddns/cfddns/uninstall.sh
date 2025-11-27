#!/bin/sh
source /koolshare/scripts/base.sh

find /koolshare/init.d/ -name "*cfddns*" | xargs rm -rf
rm -rf /koolshare/res/icon-cfddns.png
rm -rf /koolshare/scripts/cfddns*.sh
rm -rf /koolshare/scripts/uninstall_cfddns.sh
rm -rf /koolshare/webs/Module_cfddns.asp

# 删除crontab中的配置
username=`nvram show|grep http_username|awk -F '=' '{print $2}'`
filename=/tmp/var/spool/cron/crontabs/$username
sed -i '/S99cfddns.sh/d' $filename