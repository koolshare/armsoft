#!/bin/sh

#alias echo_date='echo $(date +%Y年%m月%d日\ %X)'
export KSROOT=/koolshare
source $KSROOT/scripts/base.sh
model=`nvram get productid`
#=================================================

#网卡温度
case "$model" in
RT-AC5300)
	interface_2g=`nvram get wl0_ifname`
	interface_5g1=`nvram get wl1_ifname`
	interface_5g2=`nvram get wl2_ifname`
	interface_2g_temperature=`wl -i ${interface_2g} phy_tempsense | awk '{print $1}'` 2>/dev/null
	interface_5g1_temperature=`wl -i ${interface_5g1} phy_tempsense | awk '{print $1}'` 2>/dev/null
	interface_5g2_temperature=`wl -i ${interface_5g2} phy_tempsense | awk '{print $1}'` 2>/dev/null
	[ -n "${interface_2g_temperature}" ] && interface_2g_temperature_c=`expr ${interface_2g_temperature} / 2 + 20`°C || interface_2g_temperature_c="offline"
	[ -n "${interface_5g1_temperature}" ] && interface_5g1_temperature_c=`expr ${interface_5g1_temperature} / 2 + 20`°C || interface_5g1_temperature_c="offline"
	[ -n "${interface_5g2_temperature}" ] && interface_5g2_temperature_c=`expr ${interface_5g2_temperature} / 2 + 20`°C || interface_5g2_temperature_c="offline"
	wl_temperature="2.4G：${interface_2g_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G-1：${interface_5g1_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G-2：${interface_5g2_temperature_c}"
	;;
*)
	interface_2g=`nvram get wl0_ifname`
	interface_5g1=`nvram get wl1_ifname`
	interface_2g_temperature=`wl -i ${interface_2g} phy_tempsense | awk '{print $1}'` 2>/dev/null
	interface_5g1_temperature=`wl -i ${interface_5g1} phy_tempsense | awk '{print $1}'` 2>/dev/null
	[ -n "${interface_2g_temperature}" ] && interface_2g_temperature_c=`expr ${interface_2g_temperature} / 2 + 20`°C || interface_2g_temperature_c="offline"
	[ -n "${interface_5g1_temperature}" ] && interface_5g1_temperature_c=`expr ${interface_5g1_temperature} / 2 + 20`°C || interface_5g1_temperature_c="offline"
	wl_temperature="2.4G：${interface_2g_temperature_c} &nbsp;&nbsp;|&nbsp;&nbsp; 5G-1：${interface_5g1_temperature_c}"
	;;
esac
#=================================================

http_response "$wl_temperature"
