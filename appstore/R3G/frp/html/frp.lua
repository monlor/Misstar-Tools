module("luci.controller.api.frp", package.seeall)
function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_frp"}, call("get_frp"), (""), 670)
    entry({"api", "misstar", "set_frp"}, call("set_frp"), (""), 671)
    entry({"api", "misstar", "add_frp"}, call("add_frp"), (""), 672)
    entry({"api", "misstar", "del_frp"}, call("del_frp"), (""), 673)
    entry({"api", "misstar", "getdevlist"}, call("get_devlist"), (""), 674)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_frp()
    local code = 0
    local result = {}
    local set=false
    local frp_enable_switch=LuciHttp.formvalue("frp_enable")
    local server_addr=LuciHttp.formvalue("server_addr")
    local server_port=LuciHttp.formvalue("server_port")
    local privilege_token=LuciHttp.formvalue("privilege_token")

	LuciUtil.exec("uci set misstar.frp.enable=" ..frp_enable_switch)
	LuciUtil.exec("uci set misstar.frp.server_addr=" ..server_addr)
	LuciUtil.exec("uci set misstar.frp.server_port=" ..server_port)
	LuciUtil.exec("uci set misstar.frp.privilege_token=" ..privilege_token)
	
	LuciUtil.exec("uci commit misstar")
	
	LuciUtil.exec("/etc/misstar/applications/frp/script/frp stop")
	LuciUtil.exec("/etc/misstar/applications/frp/script/frp start")
	
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("frp_enable_switch")
    end
    LuciHttp.write_json(result)
end

function add_frp()
    local code = 0
    local result = {}
    local set=false
    local id=LuciHttp.formvalue("id")
    local type=LuciHttp.formvalue("type")
    local domain=LuciHttp.formvalue("domain")
    local localip=LuciHttp.formvalue("localip")
    local localport=LuciHttp.formvalue("localport")
    local remoteport=LuciHttp.formvalue("remoteport")
    local use_encryption=LuciHttp.formvalue("use_encryption")
    local use_compression=LuciHttp.formvalue("use_compression")
    
    LuciUtil.exec("sed -i '/" ..id.. "/d' /etc/misstar/applications/frp/config/frplist")
	LuciUtil.exec("echo " ..id.. "," ..type.. "," ..domain.. "," ..localip.. "," ..localport.. "," ..remoteport.. "," ..use_encryption.. "," ..use_compression.. " >> /etc/misstar/applications/frp/config/frplist")

	
	LuciUtil.exec("/etc/misstar/applications/frp/script/frp stop")
	LuciUtil.exec("/etc/misstar/applications/frp/script/frp start")
	
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("frp_enable_switch")
    end
    LuciHttp.write_json(result)
end


function del_frp()
    local code = 0
    local result = {}
    local set=false
    local id=LuciHttp.formvalue("id")
    
    LuciUtil.exec("sed -i '/" ..id.. "/d' /etc/misstar/applications/frp/config/frplist")

	LuciUtil.exec("/etc/misstar/applications/frp/script/frp stop")
	LuciUtil.exec("/etc/misstar/applications/frp/script/frp start")
	
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("frp_enable_switch")
    end
    LuciHttp.write_json(result)
end

function get_frp()
	local result = {}
	local frp_enable
	local frps = {}
	result.frp_enable = uci:get("misstar","frp","enable")
	result.server_addr = uci:get("misstar","frp","server_addr")
	result.server_port = uci:get("misstar","frp","server_port")
	result.privilege_token = uci:get("misstar","frp","privilege_token")

	result.version = uci:get("misstar","frp","version")
	result.frp_status=LuciUtil.exec("/etc/misstar/applications/frp/script/frp status")
	
	local conf=LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F ' ' '{print $1}'")
	local frplist=string.split(conf,'\n')
	for i,v in pairs(frplist) do 
		if frplist[i] ~= '' then
            	local item = {
            		["id"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $1}'"),
            		["type"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $2}'"),
            	    ["domain"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $3}'"),
            	    ["localip"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $4}'"),
            	    ["localport"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $5}'"),
            	    ["remoteport"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $6}'"),
            	    ["use_encryption"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $7}'"),
            	    ["use_compression"] = LuciUtil.exec("cat /etc/misstar/applications/frp/config/frplist | awk -F: '$0 ~ /^"  ..frplist[i]..  "/' | awk -F ',' '{printf $8}'")
          		}
           		table.insert(frps, item)
		end
	end
	result["frplist"]=frps
	
	result["code"]=0
	LuciHttp.write_json(result)
end

function get_devlist()
    local deviceList = {}
    
	local item = {
                ["devname"] = "MiWiFi-"..LuciUtil.exec("cat /proc/xiaoqiang/model"),
                ["ip"] = uci:get("network","lan","ipaddr")
    }
    
	table.insert(deviceList, item)
	
	local conf=LuciUtil.exec("cat /tmp/dhcp.leases | awk -F ' ' '{print $2}'")
	local hostlist=string.split(conf,'\n')
	for i,v in pairs(hostlist) do 
		if hostlist[i] ~= '' then
			hostlist[i]=string.upper(hostlist[i])
            local item = {
                ["devname"] = LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..hostlist[i]..  "' | awk -F ' ' '{printf $4}'"),
                ["ip"] = LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..hostlist[i]..  "' | awk -F ' ' '{printf $3}'")
          	}
           	table.insert(deviceList, item)
		end
	end
	
    local result={}
    result["code"]=0
    result["list"]=deviceList
    LuciHttp.write_json(result)
end