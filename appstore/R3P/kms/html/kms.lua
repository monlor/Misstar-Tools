module("luci.controller.api.kms", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_kms"}, call("get_kms"), (""), 622)
	entry({"api", "misstar", "set_kms"}, call("set_kms"), (""), 623)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_kms()
    local code = 0
    local result = {}
    local set=false
    local kms_enable_switch=LuciHttp.formvalue("kms_enable")
    local kms_wan=LuciHttp.formvalue("kms_wan")
	LuciUtil.exec("uci set misstar.kms.enable=" ..kms_enable_switch)
	LuciUtil.exec("uci set misstar.kms.kms_wan=" ..kms_wan)	
	LuciUtil.exec("uci commit misstar ")
	LuciUtil.exec("/etc/misstar/applications/kms/script/kms restart")
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("adm_enable_switch")
    end
    LuciHttp.write_json(result)
end



function get_kms()
	local result = {}
	local adm_enable
	kms_enable = uci:get("misstar","kms","enable")
	kms_wan = uci:get("misstar","kms","kms_wan")
	kms_status=LuciUtil.exec("ps | grep kms | grep -v grep | wc -l")
	local version = uci:get("misstar","kms","version")
    result["version"] = version
	result["code"]=0
	result["kms_enable"]=kms_enable
	result["kms_wan"]=kms_wan
	result["kms_status"]=kms_status
	LuciHttp.write_json(result)
end
