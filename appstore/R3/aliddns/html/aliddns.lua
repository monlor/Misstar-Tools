module("luci.controller.api.aliddns", package.seeall)
function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_aliddns"}, call("get_aliddns"), (""), 635)
    entry({"api", "misstar", "set_aliddns"}, call("set_aliddns"), (""), 636)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function set_aliddns()
    local code = 0
    local result = {}
    local set=false
    local aliddns_enable_switch=LuciHttp.formvalue("aliddns_enable")
    local aliddns_dns=LuciHttp.formvalue("aliddns_dns")
    local aliddns_ttl=LuciHttp.formvalue("aliddns_ttl")
    local aliddns_cycle=LuciHttp.formvalue("aliddns_cycle")
    local aliddns_domain=LuciHttp.formvalue("aliddns_domain")
    local aliddns_name=LuciHttp.formvalue("aliddns_name")
    local aliddns_aks=LuciHttp.formvalue("aliddns_aks")
    local aliddns_aki=LuciHttp.formvalue("aliddns_aki")
    local aliddns_last_act=LuciHttp.formvalue("aliddns_last_act")
    
    
	LuciUtil.exec("uci set misstar.aliddns.enable=" ..aliddns_enable_switch)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_dns=" ..aliddns_dns)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_ttl=" ..aliddns_ttl)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_cycle=" ..aliddns_cycle)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_domain=" ..aliddns_domain)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_name=" ..aliddns_name)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_aks=" ..aliddns_aks)
	LuciUtil.exec("uci set misstar.aliddns.aliddns_aki=" ..aliddns_aki)
	
	LuciUtil.exec("uci commit misstar")
	
	LuciUtil.exec("/etc/misstar/applications/aliddns/script/aliddns stop")
	LuciUtil.exec("/etc/misstar/applications/aliddns/script/aliddns start")
	
    result["code"] = 0
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("aliddns_enable_switch")
    end
    LuciHttp.write_json(result)
end


function get_aliddns()
	local result = {}
	local aliddns_enable
	result.aliddns_enable = uci:get("misstar","aliddns","enable")
	result.aliddns_dns = uci:get("misstar","aliddns","aliddns_dns")
	result.aliddns_ttl = uci:get("misstar","aliddns","aliddns_ttl")
	result.aliddns_cycle = uci:get("misstar","aliddns","aliddns_cycle")
	result.aliddns_domain = uci:get("misstar","aliddns","aliddns_domain")
	result.aliddns_name = uci:get("misstar","aliddns","aliddns_name")
	result.aliddns_aks = uci:get("misstar","aliddns","aliddns_aks")
	result.aliddns_aki = uci:get("misstar","aliddns","aliddns_aki")
	result.aliddns_last_act = uci:get("misstar","aliddns","aliddns_last_act")
	result.version = uci:get("misstar","aliddns","version")
	result.aliddns_status=LuciUtil.exec("/etc/misstar/applications/aliddns/script/aliddns status")
	result["code"]=0
	LuciHttp.write_json(result)
end
