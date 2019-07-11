#!/bin/sh
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
DIR=$(cd $(dirname $0); pwd)

# 判断路由架构和平台
case $(uname -m) in
	armv7l)
		if [ "`uname -o|grep Merlin`" ] && [ -d "/koolshare" ] && [ -n "`nvram get buildno|grep 384`" ];then
			echo_date 固件平台【koolshare merlin armv7l 384】符合安装要求，开始安装插件！
		else
			echo_date 本插件适用于【koolshare merlin armv7l 384】固件平台，你的固件平台不能安装！！！
			echo_date 退出安装！
			rm -rf /tmp/rog* >/dev/null 2>&1
			exit 1
		fi
		;;
	*)
		echo_date 本插件适用于【koolshare merlin armv7l 384】固件平台，你的平台：$(uname -m)不能安装！！！
		echo_date 退出安装！
		rm -rf /tmp/rog* >/dev/null 2>&1
		exit 1
	;;
esac

# 安装插件
cp -rf /tmp/rog/scripts/* /koolshare/scripts/
cp -rf /tmp/rog/webs/* /koolshare/webs/
cp -rf /tmp/rog/res/* /koolshare/res/
cp -rf /tmp/rog/uninstall.sh /koolshare/scripts/uninstall_rog.sh
chmod +x /koolshare/scripts/rog*
chmod +x /koolshare/scripts/uninstall_rog.sh

# 离线安装用
dbus set rog_version="$(cat $DIR/version)"
dbus set softcenter_module_rog_version="$(cat $DIR/version)"
dbus set softcenter_module_rog_description="一些小功能的插件"
dbus set softcenter_module_rog_install="1"
dbus set softcenter_module_rog_name="rog"
dbus set softcenter_module_rog_title="ASUS工具箱"

# 完成
echo_date "ASUS工具箱插件安装完毕！"
rm -rf /tmp/rog* >/dev/null 2>&1
exit 0
