#!/bin/sh

source /koolshare/scripts/base.sh
eval `dbus export cfddns`
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
CONFIG_FILE="/tmp/cfddns_status.json"
LOG_FILE="/tmp/upload/cfddns_log.txt"
LOGTIME=$(TZ=UTC-8 date -R "+%Y-%m-%d %H:%M:%S")
CRU_NAME="cfddns_update"
CRU_CMD="/koolshare/scripts/cfddns_config.sh update"
[ "$cfddns_method" = "" ] && cfddns_method="curl -s --interface ppp0 whatismyip.akamai.com"
[ "$cfddns_ttl" = "" ] && cfddns_ttl="1"
[ "$cfddns_refresh" = "" ] && cfddns_refresh="10"
get_type="A"
record_exists=""

if [ "$cfddns_name" = "@" ];then
	cfddns_name_domain=$cfddns_domain
else
	cfddns_name_domain=$cfddns_name.$cfddns_domain
fi

get_bol() {
	case "$cfddns_proxied" in
		1)
			echo "true"
		;;
		0|*)
			echo "false"
		;;
	esac
}

# 判断 Cloudflare 接口是否返回成功
cf_ok() {
	echo "$1" | grep -qE '"success"[[:space:]]*:[[:space:]]*true'
}

get_record_response() {
	curl -kLsX GET "https://api.cloudflare.com/client/v4/zones/$cfddns_zid/dns_records?type=$get_type&name=${cfddns_name_domain}&order=type&direction=desc&match=all" \
	-H "X-Auth-Email: $cfddns_email" \
	-H "X-Auth-Key: $cfddns_akey" \
	-H "Content-type: application/json"
}

create_record() {
	curl -kLsX POST "https://api.cloudflare.com/client/v4/zones/$cfddns_zid/dns_records" \
	-H "X-Auth-Email: $cfddns_email" \
	-H "X-Auth-Key: $cfddns_akey" \
	-H "Content-Type: application/json" \
	--data '{"type":"'$get_type'","name":"'${cfddns_name_domain}'","content":"'$update_to_ip'","ttl":'$cfddns_ttl',"proxied":'$(get_bol)'}'
}

update_record() {
	curl -kLsX PUT "https://api.cloudflare.com/client/v4/zones/$cfddns_zid/dns_records/$cfddns_id" \
	-H "X-Auth-Email: $cfddns_email" \
	-H "X-Auth-Key: $cfddns_akey" \
	-H "Content-Type: application/json" \
	--data '{"type":"'$get_type'","name":"'${cfddns_name_domain}'","content":"'$update_to_ip'","ttl":'$cfddns_ttl',"proxied":'$(get_bol)'}'
}

# 基础参数检查
check_base(){
	if [ -z "$cfddns_email" -o -z "$cfddns_akey" ];then
		echo_date "Email 或 API KEY 未填写！"
		dbus set cfddns_status="【$LOGTIME】：Email/API KEY 未填写！"
		exit 1
	fi
	if [ -z "$cfddns_zid" ];then
		echo_date "Zone ID 未填写！"
		dbus set cfddns_status="【$LOGTIME】：Zone ID 未填写！"
		exit 1
	fi
	if [ -z "$cfddns_name_domain" -o "$cfddns_name_domain" = "." ];then
		echo_date "域名未填写！"
		dbus set cfddns_status="【$LOGTIME】：域名未填写！"
		exit 1
	fi
}

get_info(){
	check_base
	get_type="A"
	cfddns_result=`get_record_response`

	if ! cf_ok "$cfddns_result";then
		echo_date "获取解析记录失败！原始返回如下："
		echo "$cfddns_result"
		dbus set cfddns_status="【$LOGTIME】：获取IPV4解析记录错误！"
		exit 1
	fi

	# 记录ID（32位hex）
	cfddns_id=`echo "$cfddns_result" | grep -oE '"id"[[:space:]]*:[[:space:]]*"[a-f0-9]{32}"' | head -n1 | grep -oE '[a-f0-9]{32}'`
	# 当前解析IP
	current_ip=`echo "$cfddns_result" | grep -oE '"content"[[:space:]]*:[[:space:]]*"([0-9]{1,3}\.){3}[0-9]{1,3}"' | head -n1 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}'`

	if [ -n "$cfddns_id" ];then
		record_exists=1
		echo_date CloudFlare IP为 $current_ip
	else
		record_exists=0
		echo_date "未找到【${cfddns_name_domain}】的A记录，稍后将自动创建"
	fi

	localip=`$cfddns_method 2>&1`
	if [ $(echo "$localip" | grep -c "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$") -gt 0 ];then 
		echo_date 本地IP为 $localip
	else
		dbus set cfddns_status="【$LOGTIME】：获取本地IP错误！"
		exit 1
	fi
}

get_local_ipv6(){
	localipv6=`curl -s http://v4v6.ipv6-test.com/json/defaultproto.php | grep -oE '([a-f0-9]{1,4}(:[a-f0-9]{1,4}){7}|[a-f0-9]{1,4}(:[a-f0-9]{1,4}){0,7}::[a-f0-9]{0,4}(:[a-f0-9]{1,4}){0,7})' 2>&1`
}

get_info_ipv6(){
	get_type="AAAA"
	get_local_ipv6
	if [ "$localipv6" != "" ];then 
		echo_date 本地IP为 $localipv6
		cfddns_result=`get_record_response`
		if cf_ok "$cfddns_result";then 
			cfddns_id=`echo "$cfddns_result" | grep -oE '"id"[[:space:]]*:[[:space:]]*"[a-f0-9]{32}"' | head -n1 | grep -oE '[a-f0-9]{32}'`
			current_ipv6=`echo "$cfddns_result" | grep -oE '"content"[[:space:]]*:[[:space:]]*"[0-9a-f:]+"' | head -n1 | grep -oE '([a-f0-9]{1,4}(:[a-f0-9]{1,4}){2,})'`
			echo_date CfddsnIP为 $current_ipv6
		else
			dbus set cfddns_status="【$LOGTIME】：获取IPV6解析记录错误！"
			exit 1
		fi
	else
		echo_date 没有IPV6地址！
	fi
}

update_ip(){
	update_result=`update_record`
	if cf_ok "$update_result";then 
		echo_date 更新成功！
	else
		echo_date 更新失败!请检查设置！
		echo "$update_result"
		exit 1
	fi
}

create_ip(){
	update_result=`create_record`
	if cf_ok "$update_result";then 
		echo_date 记录创建成功！
	else
		echo_date 记录创建失败!请检查设置！
		echo "$update_result"
		exit 1
	fi
}

check_update(){
	echo_date "CloudFlare DDNS更新启动!"
	get_info
	if [ "$record_exists" = "0" ];then
		update_to_ip=$localip
		echo_date "目标A记录不存在，开始创建！"
		create_ip
		dbus set cfddns_status="【$LOGTIME】：记录：${cfddns_name_domain} 已创建，IP：$localip"
	elif [ "$localip" = "$current_ip" ];then
		echo_date 两个IP相同，跳过更新！
		dbus set cfddns_status="【$LOGTIME】：IP地址：$localip 未发生变化，跳过！"
	else
		update_to_ip=$localip
		echo_date 两个IP不相同，开始更新！
		update_ip
		dbus set cfddns_status="【$LOGTIME】：IP地址：$localip 更新成功！"
	fi
	
	# if [ "$cfddns_ipv6" = "1" ];then
	# 	get_info_ipv6
	# 	if [ "$localipv6" = "$current_ipv6" ];then
	# 		echo_date 两个IPV6相同，跳过更新！
	# 	else
	# 		update_to_ip=$localipv6
	# 		echo_date 两个IPV6不相同，开始更新！
	# 		update_ip
	# 	fi
	# fi
	echo_date "======================================"
}

# 依据「刷新间隔(分钟)」生成 cron 表达式
build_cron(){
	case "$cfddns_refresh" in
		5)		echo "*/5 * * * *"	;;
		10)		echo "*/10 * * * *"	;;
		15)		echo "*/15 * * * *"	;;
		20)		echo "*/20 * * * *"	;;
		30)		echo "*/30 * * * *"	;;
		60)		echo "0 * * * *"	;;
		120)	echo "0 */2 * * *"	;;
		180)	echo "0 */3 * * *"	;;
		240)	echo "0 */4 * * *"	;;
		360)	echo "0 */6 * * *"	;;
		480)	echo "0 */8 * * *"	;;
		720)	echo "0 */12 * * *"	;;
		1440)	echo "0 4 * * *"	;;
		*)		echo "*/10 * * * *"	;;
	esac
}

# 添加/更新定时任务
add_cfddns_cru(){
	stop_cfddns
	local cron_expr=`build_cron`
	cru a "$CRU_NAME" "$cron_expr $CRU_CMD"
	echo_date "已设置定时更新任务 → 【$cron_expr】"
}

# 移除定时任务
stop_cfddns(){
	cru d "$CRU_NAME" >/dev/null 2>&1
	sed -i "/$CRU_CMD/d" /var/spool/cron/crontabs/* >/dev/null 2>&1
}

# ====================================used by init or cru====================================
case $1 in
start)
	#此处为开机自启，wan重启动设计
	if [ "$cfddns_enable" = "1" ];then
		logger "[软件中心]: 启动CloudFlare DDNS！"

		until [ $(date +%Y) -gt 2018 ]
		do
			sleep 1
		done
		
		echo_date "======================================" >> $LOG_FILE
		echo_date "检测到网络拨号..." >> $LOG_FILE
		check_update >> $LOG_FILE
		add_cfddns_cru >> $LOG_FILE
	else
		logger "[软件中心]: CloudFlare DDNS未设置开机启动，跳过！"
		stop_cfddns
	fi
	;;
update)
	# 日志超过 64KB 时清空，避免无限增长
	if [ -f "$LOG_FILE" ] && [ `wc -c < "$LOG_FILE"` -gt 65536 ];then
		echo "" > $LOG_FILE
	fi
	check_update >> $LOG_FILE
	;;
esac
# ====================================submit by web====================================
case $2 in
1)
	#此处为web提交动设计
	echo "" > $LOG_FILE
	http_response "$1"
	if [ "$cfddns_enable" = "1" ];then
		[ ! -L "/koolshare/init.d/S99cfddns.sh" ] && ln -sf /koolshare/scripts/cfddns_config.sh /koolshare/init.d/S99cfddns.sh
		echo_date "======================================" >> $LOG_FILE
		check_update >> $LOG_FILE
		add_cfddns_cru >> $LOG_FILE
	else
		echo_date "关闭CloudFlare DDNS!" >> $LOG_FILE
		stop_cfddns
	fi
	echo XU6J03M6 >> $LOG_FILE
	;;
esac
