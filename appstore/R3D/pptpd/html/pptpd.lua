module("luci.controller.api.pptpd", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_pptpd"}, call("get_pptpd"), (""), 624)
	entry({"api", "misstar", "set_pptpd"}, call("set_pptpd"), (""), 625)
	entry({"api", "misstar", "add_pptpd_user"}, call("add_pptpd_user"), (""), 626)
	entry({"api", "misstar", "del_pptpd_user"}, call("del_pptpd_user"), (""), 627)
	entry({"api", "misstar", "get_conn_list"}, call("get_conn_list"), (""), 628)
	entry({"api", "misstar", "get_user_list"}, call("get_user_list"), (""), 629)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_pptpd()
    local code = 0
    local result = {}
    local set=false
	local pptpd_enable = LuciHttp.formvalue("pptpd_enable")
	local pptpd_localip = LuciHttp.formvalue("pptpd_localip")
	local pptpd_ip_min = LuciHttp.formvalue("pptpd_ip_min")
	local pptpd_ip_max = LuciHttp.formvalue("pptpd_ip_max")
	local pptpd_dns1 = LuciHttp.formvalue("pptpd_dns1")
	local pptpd_dns2 = LuciHttp.formvalue("pptpd_dns2")
    
    
	LuciUtil.exec("uci set misstar.pptpd.enable=" ..pptpd_enable)
	LuciUtil.exec("uci set misstar.pptpd.localip=" ..pptpd_localip)
	LuciUtil.exec("uci set misstar.pptpd.ip_min=" ..pptpd_ip_min)
	LuciUtil.exec("uci set misstar.pptpd.ip_max=" ..pptpd_ip_max)
	LuciUtil.exec("uci set misstar.pptpd.dns1=" ..pptpd_dns1)
	LuciUtil.exec("uci set misstar.pptpd.dns2=" ..pptpd_dns2)
	
	
	LuciUtil.exec("uci commit misstar ")
	
	result["code"]=LuciUtil.exec("/etc/misstar/applications/pptpd/script/pptpd restart")
	result["code"]=0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("adm_enable_switch")
    end
    LuciHttp.write_json(result)
end



function get_pptpd()
	local result = {}
	pptpd_enable = uci:get("misstar","pptpd","enable")
	pptpd_localip = uci:get("misstar","pptpd","localip")
	pptpd_ip_min = uci:get("misstar","pptpd","ip_min")
	pptpd_ip_max = uci:get("misstar","pptpd","ip_max")
	pptpd_dns1 = uci:get("misstar","pptpd","dns1")
	pptpd_dns2 = uci:get("misstar","pptpd","dns2")
	pptpd_status=LuciUtil.exec("ps | grep pptpd | grep -v grep | wc -l")
	local version = uci:get("misstar","pptpd","version")
    result["version"] = version
	result["code"]=0
	result["pptpd_enable"]=pptpd_enable
	result["pptpd_localip"]=pptpd_localip
	result["pptpd_status"]=pptpd_status
	result["pptpd_ip_min"]=pptpd_ip_min
	result["pptpd_ip_max"]=pptpd_ip_max
	result["pptpd_dns1"]=pptpd_dns1
	result["pptpd_dns2"]=pptpd_dns2
	LuciHttp.write_json(result)
end


function get_user_list()
	local code=0
	local result={}
	local users={}
	local conf=LuciUtil.exec("cat /etc/ppp/chap-secrets | grep '#Misstar' | awk -F ' ' '{print $1}'")
	local userlist=string.split(conf,'\n')
	for i,v in pairs(userlist) do 
		if userlist[i] ~= '' then
            	local item = {
            		["username"] = userlist[i],
            	    ["password"] = LuciUtil.exec("cat /etc/ppp/chap-secrets | grep '#Misstar' | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $3}'")
          		}
           		table.insert(users, item)
		end
	end

	result["code"] = 0
	result["userlist"]=users
    LuciHttp.write_json(result)

end


function get_conn_list()
	local code=0
	local result={}
	local users={}
	local conf=LuciUtil.exec("cat /tmp/pptp_connected | awk -F ' ' '{print $1}'")
	local userlist=string.split(conf,'\n')
	for i,v in pairs(userlist) do 
		if userlist[i] ~= '' then
            	local item = {
            		["username"] = LuciUtil.exec("cat /tmp/pptp_connected | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $4}'"),
            	    ["localip"] = LuciUtil.exec("cat /tmp/pptp_connected | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $2}'"),
            	    ["remoteip"] = LuciUtil.exec("cat /tmp/pptp_connected | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $3}'"),
            	    ["conntime1"] = LuciUtil.exec("cat /tmp/pptp_connected | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $5}'"),
            	    ["conntime2"] = LuciUtil.exec("cat /tmp/pptp_connected | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F ' ' '{print $6}'")
          		}
           		table.insert(users, item)
		end
	end

	result["code"] = 0
	result["userlist"]=users
    LuciHttp.write_json(result)
end


function add_pptpd_user()
	local code = 0
	local result = {}
	local username=LuciHttp.formvalue("username")
	local password=LuciHttp.formvalue("password")	
	LuciUtil.exec("/etc/misstar/applications/pptpd/script/pptpd  add " ..username.. " " ..password)
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "添加失败。"
    end
    LuciHttp.write_json(result)
end

function del_pptpd_user()
	local code = 0
	local result = {}
	local username=LuciHttp.formvalue("username")
	LuciUtil.exec("/etc/misstar/applications/pptpd/script/pptpd  del " ..username)
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "删除失败。"
    end
    LuciHttp.write_json(result)
end