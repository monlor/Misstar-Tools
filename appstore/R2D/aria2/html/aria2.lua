module("luci.controller.api.aria2", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_aria2"}, call("get_aria2"), (""), 660)
	entry({"api", "misstar", "set_aria2"}, call("set_aria2"), (""), 661)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_aria2()
    local code = 0
    local result = {}
    local set=false
    local aria2_enable_switch=LuciHttp.formvalue("enable")
    local user_path=LuciHttp.formvalue("user_path")
	LuciUtil.exec("uci set misstar.aria2.enable=" ..aria2_enable_switch.. "")
	LuciUtil.exec("uci set misstar.aria2.user_path=" ..user_path.. "")
	LuciUtil.exec("uci commit misstar ")
	LuciUtil.exec("/etc/misstar/applications/aria2/script/aria2 restart")
	code = 0
    result["code"] = code
    LuciHttp.write_json(result)
end



function get_aria2()
	local result = {}
	local adm_enable
	aria2_enable = uci:get("misstar","aria2","enable")
	user_path = uci:get("misstar","aria2","user_path")
	local aria2_status=LuciUtil.exec("ps | grep aria2c | grep -v grep | wc -l")
	local version = uci:get("misstar","aria2","version")
    result["version"] = version
	result["code"]=0
	result["aria2_enable"]=aria2_enable
	result["user_path"]=user_path
	result["aria2_status"]=aria2_status
	LuciHttp.write_json(result)
end