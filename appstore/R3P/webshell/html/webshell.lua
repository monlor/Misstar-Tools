module("luci.controller.api.webshell", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "on_webshell"}, call("on_webshell"), (""), 650)
	entry({"api", "misstar", "off_webshell"}, call("off_webshell"), (""), 651)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function on_webshell()
    local code = 0
    local result = {}
    local set=false
	LuciUtil.exec("/etc/misstar/applications/webshell/script/webshell start")
    result["code"] = 0
    LuciHttp.write_json(result)
end

function off_webshell()
    local code = 0
    local result = {}
    local set=false
	LuciUtil.exec("/etc/misstar/applications/webshell/script/webshell stop")
	code=0
    result["code"] = code
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("webshell_enable_switch")
    end
    LuciHttp.write_json(result)
end