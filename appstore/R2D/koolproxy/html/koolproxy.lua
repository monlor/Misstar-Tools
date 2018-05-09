module("luci.controller.api.koolproxy", package.seeall)


function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_koolproxy"}, call("get_koolproxy"), (""), 632)
    entry({"api", "misstar", "set_koolproxy"}, call("set_koolproxy"), (""), 633)
    
    entry({"api", "misstar", "get_devlist"}, call("get_devlist"), (""), 634)
    entry({"api", "misstar", "set_lancon"}, call("set_lancon"), (""), 635)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_koolproxy()
    local code = 0
    local result = {}
    local set=false
    local koolproxy_enable_switch=LuciHttp.formvalue("enable")
    local koolproxy_mode=LuciHttp.formvalue("koolproxy_mode")
	LuciUtil.exec("uci set misstar.koolproxy.enable=" ..koolproxy_enable_switch)
	LuciUtil.exec("uci set misstar.koolproxy.mode=" ..koolproxy_mode)
	LuciUtil.exec("uci commit misstar ")
	LuciUtil.exec("/etc/misstar/applications/koolproxy/script/koolproxy restart")
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("koolproxy_enable_switch")
    end
    LuciHttp.write_json(result)
end



function get_koolproxy()
	local result = {}
	local koolproxy_enable
	koolproxy_enable = uci:get("misstar","koolproxy","enable")
	koolproxy_mode = uci:get("misstar","koolproxy","mode")
	koolproxy_status=LuciUtil.exec("ps | grep koolproxy | grep -v grep | wc -l")
	local version = uci:get("misstar","koolproxy","version")
	local koolproxy_acl_default_mode=uci:get("misstar","koolproxy","koolproxy_acl_default_mode")
	local v_update_date=LuciUtil.exec("head -n 10 /etc/misstar/applications/koolproxy/bin/data/rules/koolproxy.txt | grep update | grep video | awk '{print $3,$4}'")
	local s_update_date=LuciUtil.exec("head -n 10 /etc/misstar/applications/koolproxy/bin/data/rules/koolproxy.txt | grep update | grep rules | awk '{print $3,$4}'")
	local kp_version=LuciUtil.exec("/etc/misstar/applications/koolproxy/bin/koolproxy -v")
	local ss_id=uci:get("misstar","ss","id")
	local ss_enable=uci:get("misstar","ss","enable")
	
	if ss_id==nil then
		ss_id=1
	end

	local ss_mode=uci:get("misstar",ss_id,"ss_mode")
	
	if ss_enable == '1' and ss_mode == 'wholemode' then
		ss_mode=1
	else
		ss_mode=0
	end
	
	result["ss_mode"]=ss_mode
	result["v_update_date"]=v_update_date
	result["s_update_date"]=s_update_date
	local LanCon={}
	local conf=LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | awk -F ',' '{print $1}'")
	local hostlist=string.split(conf,'\n')
	for i,v in pairs(hostlist) do 
		if hostlist[i] ~= '' then
            	local item = {
            		["mac"] = LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $1}'"),
            	    ["name"] = LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $2}'"),
            	    ["ip"] = LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $3}'"),
            	    ["mode"] = tonumber(LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $4}'"))
          		}
           		table.insert(LanCon, item)
		end
	end

	result["LanCon"]=LanCon

	
    result["version"] = version
    result["kp_version"] = kp_version
	result["code"]=0
	result["enable"]=koolproxy_enable
	result["mode"]=koolproxy_mode
	result["status"]=koolproxy_status
	result["koolproxy_acl_default_mode"]=koolproxy_acl_default_mode
	LuciHttp.write_json(result)
end

function get_devlist()
    local deviceList = {}

	local conf=LuciUtil.exec("cat /tmp/dhcp.leases | awk -F ' ' '{print $2}'")
	local hostlist=string.split(conf,'\n')
	for i,v in pairs(hostlist) do 
		if hostlist[i] ~= '' then
			hostlist[i]=string.upper(hostlist[i])
			local isexist= LuciUtil.exec("cat /etc/misstar/applications/koolproxy/config/LanCon.conf | grep -i '" ..hostlist[i].. "' | wc -l")
            if tonumber(isexist) == 0 then
            	local item = {
            		["mac"] = hostlist[i],
            	    ["devname"] = LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..hostlist[i]..  "' | awk -F ' ' '{print $4}'"),
            	    ["ip"] = LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..hostlist[i]..  "' | awk -F ' ' '{print $3}'")
          		}
           		table.insert(deviceList, item)
           	end
		end
	end
	
    local result={}
    result["code"]=0
    result["list"]=deviceList
    LuciHttp.write_json(result)
end


function set_lancon()
	local code = 0
    local result = {}
    local set=false
    local mac=LuciHttp.formvalue("mac")
    local mode=LuciHttp.formvalue("mode")
    local opt=LuciHttp.formvalue("opt")
    local name
    local ip
    if mac == 'default' then
    	LuciUtil.exec("uci set misstar.koolproxy.koolproxy_acl_default_mode=" ..mode)
		LuciUtil.exec("uci commit misstar")
    else 
    	LuciUtil.exec("sed -i '/" ..mac.. "/d' /etc/misstar/applications/koolproxy/config/LanCon.conf")
    	if opt == 'submit' then
			name=LuciUtil.exec("cat /tmp/dhcp.leases | grep -i " ..mac.. " | awk '{print $4}'")
			ip=LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..mac..  "' | awk -F ' ' '{print $3}'")
			LuciUtil.exec("echo " ..mac.. "," ..string.sub(name,1,-2).. "," ..string.sub(ip,1,-2).. "," ..mode.. " >> /etc/misstar/applications/koolproxy/config/LanCon.conf")
    	end
    end
    LuciUtil.exec("/etc/misstar/applications/koolproxy/script/koolproxy restart")
    result["code"]=0
    result["list"]=deviceList
    LuciHttp.write_json(result)
end
