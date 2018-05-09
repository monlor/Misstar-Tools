#!/bin/sh
#---------------------------------------------------------------- 
# Shell Name：update
# Description：Plug-in install script
# Author：Starry
# E-mail: starry@misstar.com
# Time：2016-11-06 02:30 CST
# Version: 1.6.11.07
# Copyright © 2016 Misstar Tools. All rights reserved.
#----------------------------------------------------------------*/
clear
echo "欢迎使用小米路由Misstar Tools工具箱"
echo "当前版本：1.16.11.06"
echo "问题反馈&技术交流QQ群：523723125"

## Check The Router Hardware Model 
mode=$(cat /proc/xiaoqiang/model)


sed -i '/misstar/d' /etc/firewall.user
echo 'CHECKPATH="$(ls /extdisks/sd*/misstar/scripts/misstarini 2>/dev/null)" #misstar' >> /etc/firewall.user
echo 'if [ ! -f "$CHECKPATH" ];then #misstar' >> /etc/firewall.user
echo '	CHECKPATH="$(ls /userdisk/data/misstar/scripts/misstarini 2>/dev/null)" #misstar' >> /etc/firewall.user
echo 'fi #misstar' >> /etc/firewall.user
echo 'if [ ! -f "$CHECKPATH" ];then #misstar' >> /etc/firewall.user
echo '	CHECKPATH="$(ls /etc/misstar/scripts/misstarini 2>/dev/null)" #misstar' >> /etc/firewall.user
echo 'fi #misstar' >> /etc/firewall.user
echo 'if [ -f "$CHECKPATH" ]; then #misstar' >> /etc/firewall.user
echo '	$CHECKPATH #misstar' >> /etc/firewall.user
echo 'fi #misstar' >> /etc/firewall.user


echo "开始下载安装包..."

url="https://raw.githubusercontent.com/monlor/Misstar-Tools/master/appstore/$mode"

curl -kL ${url}/misstar.mt -o /tmp/misstar.mt

if [ $? -eq 0 ];then
    echo "安装包下载完成！"
else 
    echo "下载安装包失败，正在退出..."
    exit
fi


mount -o remount,rw /

if [ $? -eq 0 ];then
    echo "挂载文件系统成功。"
else 
    echo "挂载文件系统失败，正在退出..."
    exit
fi


tar -zxvf /tmp/misstar.mt -C / >/dev/null 2>&1


if [ $? -eq 0 ];then
    echo "压缩包解压完成，开始安装："
else 
    echo "压缩包解压失败，正在退出..."
    exit
fi

rm -rf /tmp/etc/misstar/config
rm -rf /tmp/etc/misstar/luci/js/nav.json
rm -rf /tmp/etc/misstar/scripts/Dayjob
rm -rf /tmp/etc/misstar/scripts/file_check
rm -rf /tmp/etc/misstar/scripts/Monitor


cp -rf /tmp/etc /

uci set misstar.misstar.version='2.7.05.21'
uci commit misstar

chmod +x /etc/misstar/scripts/*

if [ $? -eq 0 ];then
	snmd5=$(echo `nvram get wl1_maclist` `nvram get SN`  | md5sum | awk '{print $1}')
	id=`uci get misstar.misstar.counter`
    counter=`curl "https://raw.githubusercontent.com/monlor/Misstar-Tools/master/counter2.php?sha1sum=$snmd5&id=$id" -s | awk -F "\"" '{print $4}'`
    echo -e "安装完成，请刷新网页。"
else 
    echo "安装失败。"
    exit
fi

/etc/misstar/scripts/misstarini
