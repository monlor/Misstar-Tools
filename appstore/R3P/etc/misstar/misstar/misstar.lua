module("luci.controller.api.misstar", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true

    entry({"api", "misstar", "update"}, call("mis_update"), (""), 601)
    entry({"api", "misstar", "uninstall"}, call("mis_uninstall"), (""), 602)
    entry({"api", "misstar", "appstore"}, call("appstore"), (""), 603)
    
    entry({"api", "misstar", "get_status"}, call("get_status"), (""), 691)
    
end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")


function mis_update()
    local result = {}
    local code=LuciUtil.exec("wget http://www.misstar.com/tools/appstore/update.sh -O /tmp/update.sh >/dev/null 2>/dev/null && chmod +x /tmp/update.sh >/dev/null 2>/dev/null && /tmp/update.sh >/dev/null 2>/dev/null")
    result["code"] = code
    result["list"] = list
    if code ~= 0 then
       result["msg"] = XQErrorUtil.getErrorMessage(code)
    end
    LuciHttp.write_json(result)
    
end

function mis_uninstall()
    local result = {}
    local code=LuciUtil.exec("/etc/misstar/scripts/uninstall.sh")
    result["code"] = code
    LuciHttp.write_json(result)
end

function appstore()
    local result = {}
    local id=LuciHttp.formvalue("id")
    local operate=LuciHttp.formvalue("operate")
    local code=LuciUtil.exec("/etc/misstar/scripts/appmanager " ..operate.. " " ..id)
    result["code"] = 0
    if code ~= 0 then
       result["msg"] = XQErrorUtil.getErrorMessage(code)
    end
    LuciHttp.write_json(result)
end


function get_status()
	local result= {}

	local version=uci:get("misstar","misstar","version")
	local counter=uci:get("misstar","misstar","counter")
	
	
	result["code"]=0
	result["counter"]=counter
	result["version"]=version
	
	LuciHttp.write_json(result)
end


module ("xiaoqiang.util.XQErrorUtil", package.seeall)

function getErrorMessage(errorCode)
    local errorList = {}
    -- 如果code大于1000 则是需要打印msg到客户端
    errorList[1801] = _("下载安装包失败")
    errorList[1802] = _("解压安装包失败")
    errorList[1803] = _("导入配置信息失败")
    errorList[1804] = _("下载升级包失败")
    errorList[1805] = _("解压升级包失败")
    errorList[1806] = _("安装升级包失败")
    errorList[1807] = _("文件不存在或者已经损坏,可以尝试重新下载")
    
    if (errorList[errorCode] == nil) then
        return translate(_("未知错误"))
    else
        return translate(errorList[errorCode])
    end
end
