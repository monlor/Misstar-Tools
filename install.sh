#!/bin/sh
#---------------------------------------------------------------- 
# Shell Name：install
# Description：Plug-in install script
# Author：Starry
# E-mail: starry@misstar.com
# Time：2016-11-06 02:30 CST
# Version: 1.6.11.07
# Copyright © 2016 Misstar Tools. All rights reserved.
#----------------------------------------------------------------*/
clear

echo ""
echo "---------------------------------------------------------------"
echo '   __  __ _                         _______          _        '
echo '  |  \/  (_)        _              |__   __|        | |       '
echo '  | \  / |_ ___ ___| |_ __ _ _ __     | | ___   ___ | |___    '
echo '  | |\/| | / __/ __| __/ _` | `__|    | |/ _ \ / _ \| / __|   '
echo '  | |  | | \__ \__ \ || (_| | |       | | (_) | (_) | \__ \   '
echo '  |_|  |_|_|___/___/\__\__,_|_|       |_|\___/ \___/|_|___/   '
echo "---------------------------------------------------------------"


echo "欢迎使用小米路由Misstar Tools工具箱"
echo "当前版本：2.17.05.21"
echo "问题反馈&技术交流QQ群：523723125/157558789"

## Check The Router Hardware Model 
model=$(cat /proc/xiaoqiang/model)

if [ "$model" == "R2D" -o "$model" == "R1D" -o "$model" == "R3D" -o "$model" == "R3P" -o "$model" == "R3" -o "$model" == "R1CM" -o "$model" == "R3G" ];then
	echo "本工具箱作折腾、学习、研究之用，请勿用于非法用途，对路由器安全有高要求的请不要安装！"
else
	echo "对不起，本工具箱暂时只支持小米R1D,R2D,R3,Mini路由器。"
	exit
fi 


echo -n "[按任意键继续，按Ctrl+C 退出安装]:"

read continue

mount -o remount,rw /
rm -rf /usr/share/datacenter/文件共享说明.jpg >/dev/null 2>&1


if [ "$model" == "R1D" -o "$model" == "R2D" -o "$model" == "R3D"  ];then
        MIWIFIPATH="/etc"
elif [ "$model" == "R3" -o "$model" == "R3P" -o "$model" == "R3G" ];then
        if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?$') -eq 0 ];
        then
                MIWIFIPATH="/etc"
        else
        		echo "检测到外部存储，请选择安装位置："
        		while :
        		do
        			echo "1，内置存储(推荐)      2，U盘/移动硬盘（如果内置存储满，请选择这个）"
        			read location
        			if [ "$location" == '1' ] ;then
               		 	MIWIFIPATH="/etc"
               		 	break
               		 elif [ "$location" == '2' ] ; then
               		 	MIWIFIPATH=$(df|awk '/\/extdisks\/sd[a-z][0-9]?$/{print $6;exit}')
               		 	break
                	fi
                done
        fi
elif [ "$model" == "R1CM" ];then
	if [ $(df|grep -Ec '\/extdisks\/sd[a-z][0-9]?$') -eq 0 ];then
		echo "未找到外置存储设备，退出..."
		return 1
	else
		MIWIFIPATH=$(df|awk '/\/extdisks\/sd[a-z][0-9]?$/{print $6;exit}')
	fi
else
        echo "暂不支持您的路由器。"
        return 1
fi

rm -rf $MIWIFIPATH/misstar
mkdir $MIWIFIPATH/misstar

if [ "$MIWIFIPATH" != "/etc" ]; then
	rm -rf /etc/misstar
	ln -s $MIWIFIPATH/misstar /etc/
fi

echo "检查磁盘空间。.."
result=$(df -h | grep -E 'etc' | grep '100%' | wc -l)
if [ "$result" == '0' ];then
	echo "完成"
else
	df -h | grep -E 'etc'
	echo "磁盘空间不足，请清理后安装。"
	exit
fi

echo "开始下载安装包..."

url="http://www.misstar.com/tools/appstore/$model"

wget ${url}/misstar.mt -O /tmp/misstar.mt

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

echo "开始解压安装包..."

if [ "$model" == "R3P" -o "$model" == "R3G" ];then
	tar -zxvf /tmp/misstar.mt -C / >/dev/null 2>&1
else
	unzip -o -P Misstar_Tools@2017 /tmp/misstar.mt -d / >/dev/null 2>&1
fi

if [ $? -eq 0 ];then
    echo "解压完成，开始安装："
else 
    echo "解压失败，正在退出..."
    exit
fi

chmod +x /etc/misstar/scripts/*


cp -rf /etc/misstar/config/misstar /etc/config/misstar

touch /etc/firewall.user
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


/etc/misstar/scripts/misstarini

if [ $? -eq 0 ];then
    snmd5=$(echo `nvram get wl1_maclist` `nvram get SN`  | md5sum | awk '{print $1}')
    counter=`curl "http://www.misstar.com/tools/counter.php?sha1sum=$snmd5" -s | awk -F "\"" '{print $4}'`
    uci set misstar.misstar.counter=$counter
    uci commit misstar
    echo -e "安装完成，请刷新网页。"
else 
    echo "安装失败。"
    exit
fi

rm -rf /tmp/misstar.mt
rm -rf /tmp/install.sh