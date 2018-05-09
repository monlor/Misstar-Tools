module("luci.controller.api.adm", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_adm"}, call("get_adm"), (""), 620)
    entry({"api", "misstar", "set_adm"}, call("set_adm"), (""), 621)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_adm()
    local code = 0
    local result = {}
    local set=false
    local adm_enable_switch=LuciHttp.formvalue("enable")
    local adm_mode=LuciHttp.formvalue("mode")
	LuciUtil.exec("uci set misstar.adm.enable=" ..adm_enable_switch)
	LuciUtil.exec("uci set misstar.adm.mode=" ..adm_mode)	
	LuciUtil.exec("uci commit misstar ")
	LuciUtil.exec("/etc/misstar/applications/adm/script/adm restart")
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("adm_enable_switch")
    end
    LuciHttp.write_json(result)
end



function get_adm()
	local result = {}
	local adm_enable
	adm_enable = uci:get("misstar","adm","enable")
	adm_mode = uci:get("misstar","adm","mode")
	adm_status=LuciUtil.exec("ps | grep adm | grep -v grep | wc -l")
	local version = uci:get("misstar","adm","version")
    result["version"] = version
	result["code"]=0
	result["enable"]=adm_enable
	result["mode"]=adm_mode
	result["status"]=adm_status
	LuciHttp.write_json(result)
end