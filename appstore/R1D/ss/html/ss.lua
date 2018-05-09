module("luci.controller.api.ss", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true

    entry({"api", "misstar", "get_ss"}, call("get_ss"), (""), 601)
    entry({"api", "misstar", "set_dns"}, call("set_dns"), (""), 601)
    
    entry({"api", "misstar", "get_ssstatus"}, call("get_ssstatus"), (""), 602)
    
    entry({"api", "misstar", "conn_ss"}, call("conn_ss"), (""), 603)
    entry({"api", "misstar", "dconn_ss"}, call("dconn_ss"), (""), 604)

    entry({"api", "misstar", "getssdetail"}, call("getssdetail"), (""), 605)
    
    entry({"api", "misstar", "set_ss"}, call("set_ss"), (""), 606)
    entry({"api", "misstar", "del_ss"}, call("del_ss"), (""), 607)
    entry({"api", "misstar", "set_ss_lancon"}, call("set_lancon"), (""), 608)
    entry({"api", "misstar", "get_ss_devlist"}, call("get_devlist"), (""), 609)
    
	entry({"api", "misstar", "set_dns"}, call("set_dns"), (""), 610)
    entry({"api", "misstar", "get_dns"}, call("get_dns"), (""), 611)
    
    entry({"api", "misstar", "add_pac"}, call("add_pac"), (""), 612)
    entry({"api", "misstar", "del_pac"}, call("del_pac"), (""), 613)
    entry({"api", "misstar", "add_white"}, call("add_white"), (""), 614)
    entry({"api", "misstar", "del_white"}, call("del_white"), (""), 615)
    
end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")

function get_ss()
    local result = {}
    local list = getSSList()
    local current = getSSInfo("interface")
    local version = uci:get("misstar","ss","version")
    
    local ss_acl_default_mode=uci:get("misstar","ss","ss_acl_default_mode")
    local LanCon={}
	local conf=LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | awk -F ',' '{print $1}'")
	local hostlist=string.split(conf,'\n')
	for i,v in pairs(hostlist) do 
		if hostlist[i] ~= '' then
            	local item = {
            		["mac"] = LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $1}'"),
            	    ["name"] = LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $2}'"),
            	    ["ip"] = LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $3}'"),
            	    ["mode"] = tonumber(LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | grep '"  ..hostlist[i]..  "' | awk -F ',' '{print $4}'"))
          		}
           		table.insert(LanCon, item)
		end
	end

	result["LanCon"]=LanCon

    result["ss_acl_default_mode"]=ss_acl_default_mode
    result["code"] = 0
    result["current"] = current
    result["list"] = list
    result["version"] = version
    LuciHttp.write_json(result)
end

function getSSInfo(interface)
    local info = {
        proto = "",
        server = "",
        username = "",
        password = "",
        id = ""
    }
    local id = uci:get("misstar","ss","id")
    local enable=uci:get("misstar","ss","enable")
    if id then
        info.id = id
        info.enable = enable
    end
    return info
end


function getSSList()
    local result = {}
    uci:foreach("misstar", "ss",
        function(s)
            local item = {
            	["ss_server"] = s.ss_server,
                ["ss_name"] = s.ss_name,
                ["ss_server_port"] = s.ss_server_port,
                ["ss_mode"] = s.ss_mode,
                ["id"] = s.id
            }
            table.insert(result, item)
            -- result[s.id] = item
        end
    )
    return result
end

function getssdetail()
    local result = {}
    local ss_detail= {}
    local id=LuciHttp.formvalue("id")
    ss_detail.ss_name = uci:get("misstar",id,"ss_name")
    ss_detail.ss_method = uci:get("misstar",id,"ss_method")
    ss_detail.ssr_enable = uci:get("misstar",id,"ssr_enable")
    ss_detail.ssr_protocol = uci:get("misstar",id,"ssr_protocol")
    ss_detail.ssr_obfs = uci:get("misstar",id,"ssr_obfs")
    ss_detail.ss_server = uci:get("misstar",id,"ss_server")
    ss_detail.ss_server_port = uci:get("misstar",id,"ss_server_port")
    ss_detail.ss_password = uci:get("misstar",id,"ss_password")
    ss_detail.ss_mode = uci:get("misstar",id,"ss_mode")
    result["code"]=0
    result["ss_detail"]=ss_detail
    LuciHttp.write_json(result)
end

function set_ss()
    local code = 0
    local result = {}
    local ss_name = LuciHttp.formvalue("ss_name")
    local ss_server = LuciHttp.formvalue("ss_server")
    local ss_server_port = LuciHttp.formvalue("ss_server_port")
    local ss_password = LuciHttp.formvalue("ss_password")
    local ss_method = LuciHttp.formvalue("ss_method")
    local ss_mode = LuciHttp.formvalue("ss_mode")
    local ssr_enable = LuciHttp.formvalue("ssr_enable")
    local ssr_protocol = LuciHttp.formvalue("ssr_protocol")
    local ssr_obfs = LuciHttp.formvalue("ssr_obfs")
    local id = LuciHttp.formvalue("id")
    
    LuciUtil.exec("uci set misstar." ..id.. "=ss")
    LuciUtil.exec("uci set misstar." ..id.. ".ss_name=" ..ss_name)
    LuciUtil.exec("uci set misstar." ..id.. ".ss_server=" ..ss_server)
	LuciUtil.exec("uci set misstar." ..id.. ".ss_server_port=" ..ss_server_port)
    LuciUtil.exec("uci set misstar." ..id.. ".ss_password=" ..ss_password)
    LuciUtil.exec("uci set misstar." ..id.. ".ss_method=" ..ss_method)
    LuciUtil.exec("uci set misstar." ..id.. ".ss_mode=" ..ss_mode)
    LuciUtil.exec("uci set misstar." ..id.. ".ssr_enable=" ..ssr_enable)
    LuciUtil.exec("uci set misstar." ..id.. ".ssr_protocol=" ..ssr_protocol)
    LuciUtil.exec("uci set misstar." ..id.. ".ssr_obfs=" ..ssr_obfs)
    LuciUtil.exec("uci set misstar." ..id.. ".id=" ..id)
	LuciUtil.exec("uci commit misstar")
	

    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = XQErrorUtil.getErrorMessage(result.code)
    end
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
    	LuciUtil.exec("uci set misstar.ss.ss_acl_default_mode=" ..mode)
		LuciUtil.exec("uci commit misstar")
    else 
    	LuciUtil.exec("sed -i '/" ..mac.. "/d' /etc/misstar/applications/ss/config/LanCon.conf")
    	if opt == 'submit' then
			name=LuciUtil.exec("cat /tmp/dhcp.leases | grep -i " ..mac.. " | awk '{print $4}'")
			ip=LuciUtil.exec("cat /tmp/dhcp.leases | grep -i '"  ..mac..  "' | awk -F ' ' '{print $3}'")
			LuciUtil.exec("echo " ..mac.. "," ..string.sub(name,1,-2).. "," ..string.sub(ip,1,-2).. "," ..mode.. " >> /etc/misstar/applications/ss/config/LanCon.conf")
    	end
    end
    LuciUtil.exec("/etc/misstar/applications/ss/script/ss restart")
    result["code"]=0
    result["list"]=deviceList
    LuciHttp.write_json(result)
end




function del_ss()
    local result = {}
    local id = LuciHttp.formvalue("id")
    uci:delete("misstar", id)
    uci:commit("misstar")
    result["code"] = 0
    LuciHttp.write_json(result)
end

function dconn_ss()
    local result = {}
    LuciUtil.exec("uci set misstar.ss.enable=0")
    uci:commit("misstar")
    LuciUtil.exec("/etc/misstar/applications/ss/script/ss restart")
    result["code"] = 0
    LuciHttp.write_json(result)
end

function conn_ss()
    local result = {}
    local id = LuciHttp.formvalue("id")
    LuciUtil.exec("uci set misstar.ss.id=" ..id)
    LuciUtil.exec("uci set misstar.ss.enable=1")
    uci:commit("misstar")
    LuciUtil.exec("/etc/misstar/applications/ss/script/ss restart")
    result["code"] = 0
    LuciHttp.write_json(result)
end

function get_ssstatus()
	local ss_status={}
	local result = {}
	ss_status.ss_status=LuciUtil.exec("/etc/misstar/applications/ss/script/ss status")
	ss_status.ss_dnsstatus=LuciUtil.exec("/etc/misstar/applications/ss/script/ss dnsstatus")
	local id=uci:get("misstar","ss","id")
	ss_status.ss_node=uci:get("misstar",id,"ss_name")
	result["code"]=0
	result["ss_status"]=ss_status
	LuciHttp.write_json(result)
end

function get_dns()
	local dns_info={}
	local result = {}
	dns_info.dns_mode = uci:get("misstar","ss","dns_mode")
	dns_info.dns_server = uci:get("misstar","ss","dns_server")
	dns_info.dns_port = uci:get("misstar","ss","dns_port")
	
	dns_info.dns_red_enable = uci:get("misstar","ss","dns_red_enable")
	dns_info.dns_red_ip = uci:get("misstar","ss","dns_red_ip")

	
	dns_info.pac_customize=LuciUtil.exec("cat /etc/misstar/applications/ss/config/pac_customize.conf")

	dns_info.chn_list=LuciUtil.exec("cat /etc/misstar/applications/ss/config/chnroute_customize.conf")
	
	result["code"]=0
	result["dns_info"]=dns_info
	LuciHttp.write_json(result)
end



function set_dns()
	local code = 0
    local result = {}
    local dns_mode = LuciHttp.formvalue("dns_mode")
	local dns_server = LuciHttp.formvalue("dns_server")
	local dns_port = LuciHttp.formvalue("dns_port")
	
	local dns_red_enable = LuciHttp.formvalue("dns_red_enable")
	local dns_red_ip = LuciHttp.formvalue("dns_red_ip")

    LuciUtil.exec("uci set misstar.ss.dns_mode=" ..dns_mode)
    LuciUtil.exec("uci set misstar.ss.dns_server=" ..dns_server)
    LuciUtil.exec("uci set misstar.ss.dns_port=" ..dns_port)
    
    LuciUtil.exec("uci set misstar.ss.dns_red_enable=" ..dns_red_enable)
    LuciUtil.exec("uci set misstar.ss.dns_red_ip=" ..dns_red_ip)
    
	LuciUtil.exec("uci commit misstar ")
	
	LuciUtil.exec("/etc/misstar/applications/ss/script/ss dnsconfig")
	
    set=true
    
    if set then
        code = 0
    else
        code = 1583
    end
    result["code"] = code
    if result.code ~= 0 then
        result["msg"] = XQErrorUtil.getErrorMessage(result.code)
    end
    LuciHttp.write_json(result)
end

function get_devlist()
    local deviceList = {}

	local conf=LuciUtil.exec("cat /tmp/dhcp.leases | awk -F ' ' '{print $2}'")
	local hostlist=string.split(conf,'\n')
	for i,v in pairs(hostlist) do 
		if hostlist[i] ~= '' then
			hostlist[i]=string.upper(hostlist[i])
			local isexist= LuciUtil.exec("cat /etc/misstar/applications/ss/config/LanCon.conf | grep -i '" ..hostlist[i].. "' | wc -l")
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



function add_pac()
	local code = 0
	local result = {}
	local address=LuciHttp.formvalue("address")
	code=LuciUtil.exec("echo " ..address.. " >> /etc/misstar/applications/ss/config/pac_customize.conf")
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "添加失败。"
    end
    LuciHttp.write_json(result)
end

function del_pac()
	local code = 0
	local result = {}
	local address=LuciHttp.formvalue("address")
	code=LuciUtil.exec("sed -i '/" ..address.. "/d' /etc/misstar/applications/ss/config/pac_customize.conf")
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "删除失败。"
    end
    LuciHttp.write_json(result)
end

function add_white()
	local code = 0
	local result = {}
	local address=LuciHttp.formvalue("address")
	code=LuciUtil.exec("echo " ..address.. " >> /etc/misstar/applications/ss/config/chnroute_customize.conf")
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "添加失败。"
    end
    LuciHttp.write_json(result)
end


function del_white()
	local code = 0
	local result = {}
	local address=LuciHttp.formvalue("address")
	code=LuciUtil.exec("sed -i '/" ..address.. "/d' /etc/misstar/applications/ss/config/chnroute_customize.conf")
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "删除失败。"
    end
    LuciHttp.write_json(result)
end
