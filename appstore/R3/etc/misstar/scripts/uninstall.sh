#!/bin/sh
#---------------------------------------------------------------- 
# Shell Name：uninstall 
# Description：Plug-in uninstall script
# Author：Starry
# E-mail: starry@misstar.com
# Time：2016-11-06 02:30 CST
# Copyright © 2016 Misstar Tools. All rights reserved.
#----------------------------------------------------------------*/
mount -o remount,rw /
applist=$(ls  /etc/misstar/applications/)
if [ "$applist" != '' ];then
	for app in $applist
	do
		/etc/misstar/applications/$app/script/$app stop
	done
fi

sed -i '/misstar/d' /usr/lib/lua/luci/controller/web/index.lua
sed -i '/\"misstar\"/d' /usr/lib/lua/luci/view/web/inc/header.htm
sed -i '/misstar/,/end/d' /usr/lib/lua/luci/view/web/inc/header.htm
sed -i '/misstar/d' /etc/firewall.user
sed -i '/misstar/d' /etc/crontabs/root
rm -rf /usr/lib/lua/luci/view/web/setting/misstar
rm -rf /usr/lib/lua/luci/view/web/inc/menu.htm
rm -rf /www/xiaoqiang/web/luci
rm -rf /etc/config/ss-redir
rm -rf /etc/config/misstar
rm -rf /etc/misstar
rm -rf /userdisk/data/misstar
rm -rf /extdisks/sd[a-z][0-9]/misstar

LUAPATH="/usr/lib/lua/luci"
WEBPATH="/www/xiaoqiang/web"

umount -lf $LUAPATH 2>/dev/null
umount -lf $WEBPATH 2>/dev/null
umount /
rm -rf /tmp/luci-modulecache/* /tmp/luci-index

