module("luci.controller.api.rm", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_rm"}, call("get_rm"), (""), 630)
    entry({"api", "misstar", "set_rm"}, call("set_rm"), (""), 631)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_rm()
    local code = 0
    local result = {}
    local set=false
    local web_enable_switch=LuciHttp.formvalue("web_enable")
    local sshd_enable_switch=LuciHttp.formvalue("ssh_enable")
    local web_port=LuciHttp.formvalue("web_port")
    local ssh_port=LuciHttp.formvalue("ssh_port")
    LuciUtil.exec("/etc/misstar/applications/rm/script/rm web disable")
    LuciUtil.exec("/etc/misstar/applications/rm/script/rm sshd disable")
	LuciUtil.exec("uci set misstar.rm.web_enable=" ..web_enable_switch)
	LuciUtil.exec("uci set misstar.rm.web_port=" ..web_port)
	LuciUtil.exec("uci set misstar.rm.sshd_enable=" ..sshd_enable_switch)
	LuciUtil.exec("uci set misstar.rm.sshd_port=" ..ssh_port)
	LuciUtil.exec("uci commit misstar")
	LuciUtil.exec("/etc/misstar/applications/rm/script/rm web enable")
	LuciUtil.exec("/etc/misstar/applications/rm/script/rm sshd enable")
	
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("rm_enable_switch")
    end
    LuciHttp.write_json(result)
end


function get_rm()
	local result = {}
	local web_enable
	local sshd_enable
	result.web_enable = uci:get("misstar","rm","web_enable")
	result.web_port = uci:get("misstar","rm","web_port")
	result.web_status=LuciUtil.exec("/etc/misstar/applications/rm/script/rm web status")
	result.sshd_enable = uci:get("misstar","rm","sshd_enable")
	result.sshd_port = uci:get("misstar","rm","sshd_port")
	result.sshd_status=LuciUtil.exec("/etc/misstar/applications/rm/script/rm sshd status")
	result.version = uci:get("misstar","rm","version")
	result["code"]=0
	LuciHttp.write_json(result)
end
