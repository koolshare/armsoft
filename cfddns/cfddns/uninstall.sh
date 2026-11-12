#!/bin/sh
source /koolshare/scripts/base.sh

# 移除定时更新任务
cru d cfddns_update >/dev/null 2>&1
sed -i "/cfddns_config.sh update/d" /var/spool/cron/crontabs/* >/dev/null 2>&1

find /koolshare/init.d/ -name "*cfddns*" | xargs rm -rf
rm -rf /koolshare/res/icon-cfddns.png
rm -rf /koolshare/scripts/cfddns*.sh
rm -rf /koolshare/scripts/uninstall_cfddns.sh
rm -rf /koolshare/webs/Module_cfddns.asp
