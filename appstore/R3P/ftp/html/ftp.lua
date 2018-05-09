module("luci.controller.api.ftp", package.seeall)



function index()
    local page   = node("api","misstar")
    page.target  = firstchild()
    page.title   = ("")
    page.order   = 100
    page.sysauth = "admin"
    page.sysauth_authenticator = "jsonauth"
    page.index = true
    
    
	entry({"api", "misstar", "get_ftp"}, call("get_ftp"), (""), 640)
	entry({"api", "misstar", "set_ftp"}, call("set_ftp"), (""), 641)
	entry({"api", "misstar", "pathcheck"}, call("pathcheck"), (""), 642)
	
	entry({"api", "misstar", "get_user"}, call("get_user"), (""), 643)
	entry({"api", "misstar", "add_user"}, call("add_user"), (""), 644)
	entry({"api", "misstar", "del_user"}, call("del_user"), (""), 645)

end

local LuciHttp = require("luci.http")
local XQConfigs = require("xiaoqiang.common.XQConfigs")
local XQSysUtil = require("xiaoqiang.util.XQSysUtil")
local XQErrorUtil = require("xiaoqiang.util.XQErrorUtil")
local uci = require("luci.model.uci").cursor()
local LuciUtil = require("luci.util")

function set_ftp()
	local result = {}
	local ftp_enable
	local rm_enable
	local root_enable
	local any_enable
	local write_enable
	local log_enable
	local chroot
	local ftp_port
	
    ftp_enable=LuciHttp.formvalue("ftp_enable")
    rm_enable=LuciHttp.formvalue("rm_enable")
    root_enable=LuciHttp.formvalue("root_enable")
    any_enable=LuciHttp.formvalue("any_enable")
    write_enable=LuciHttp.formvalue("write_enable")
    log_enable=LuciHttp.formvalue("log_enable")
    chroot=LuciHttp.formvalue("chroot")
    ftp_port=LuciHttp.formvalue("ftp_port")
    
    
	LuciUtil.exec("uci set misstar.ftp.enable=" ..ftp_enable)
	LuciUtil.exec("uci set misstar.ftp.rm_enable=" ..rm_enable)
	LuciUtil.exec("uci set misstar.ftp.root_enable=" ..root_enable)
	LuciUtil.exec("uci set misstar.ftp.any_enable=" ..any_enable)
	LuciUtil.exec("uci set misstar.ftp.write_enable=" ..write_enable)
	LuciUtil.exec("uci set misstar.ftp.log_enable=" ..log_enable)
	LuciUtil.exec("uci set misstar.ftp.ftp_port=" ..ftp_port)
	LuciUtil.exec("uci set misstar.ftp.chroot=" ..chroot)
	LuciUtil.exec("uci commit misstar")
	LuciUtil.exec("/etc/misstar/applications/ftp/script/vsftpd restart")

    code = 0
    result["code"] = code
    if result.code ~= 0 then
        result["msg"] = LuciHttp.formvalue("enable")
    end
    LuciHttp.write_json(result)
end



function get_ftp()
	local result = {}
	local enable
	local rm_enable
	local root_enable
	local any_enable
	local write_enable
	local ftp_user
	local user_path
	local log_enable
	local chroot
	local ftp_port
	
	ftp_status=LuciUtil.exec("ps | grep vsftp | grep -v grep | wc -l")
	
	ftp_enable = uci:get("misstar","ftp","enable")
	ftp_port = uci:get("misstar","ftp","ftp_port")
	rm_enable = uci:get("misstar","ftp","rm_enable")
	root_enable = uci:get("misstar","ftp","root_enable")
	any_enable = uci:get("misstar","ftp","any_enable")
	write_enable = uci:get("misstar","ftp","write_enable")
	chroot = uci:get("misstar","ftp","chroot")
	log_enable = uci:get("misstar","ftp","log_enable")
	local version = uci:get("misstar","ftp","version")
    result["version"] = version
	result["code"]=0
	result["ftp_enable"]=ftp_enable
	result["ftp_port"]=ftp_port
	result["rm_enable"]=rm_enable
	result["root_enable"]=root_enable
	result["any_enable"]=any_enable
	result["write_enable"]=write_enable
	result["ftp_status"]=ftp_status
	result["log_enable"]=log_enable
	result["chroot"]=chroot
	LuciHttp.write_json(result)
end


function pathcheck()
	local result = {}
	local userpath=LuciHttp.formvalue("userpath")
	result["userpath"]=LuciUtil.exec("/etc/misstar/applications/ftp/script/vsftpd pathcheck " ..userpath)
	result["code"]=0
	LuciHttp.write_json(result)
end


function add_user()
	local code = 0
	local result = {}
	local username=LuciHttp.formvalue("username")
	local password=LuciHttp.formvalue("password")
	local userpath=LuciHttp.formvalue("userpath")
	local ssh_enable=LuciHttp.formvalue("ssh_enable")
	
	LuciUtil.exec("/etc/misstar/applications/ftp/script/vsftpd add " ..username.. " " ..password.. " " ..userpath.. " " ..ssh_enable)
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "添加失败。"
    end
    LuciHttp.write_json(result)
end

function del_user()
	local code = 0
	local result = {}
	local username=LuciHttp.formvalue("username")
	LuciUtil.exec("/etc/misstar/applications/ftp/script/vsftpd del " ..username)
	result["code"] = 0
	if result.code ~= 0 then
        result["msg"] = "删除失败。"
    end
    LuciHttp.write_json(result)
end

function get_user()
	local code=0
	local result={}
	local users={}
	local conf=LuciUtil.exec("cat /etc/misstar/applications/ftp/config/userlist.conf")
	local userlist=string.split(conf,'\n')
	for i,v in pairs(userlist) do 
		if userlist[i] ~= '' then
            	local item = {
            		["username"] = userlist[i],
            	    ["userpath"] = LuciUtil.exec("cat /etc/passwd | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F : '{print $6}'"),
            	    ["binpath"] = LuciUtil.exec("cat /etc/passwd | awk -F: '$0 ~ /^"  ..userlist[i]..  "/' | awk -F : '{print $7}' | grep '/bin/ash' | wc -l")
          		}
           		table.insert(users, item)
		end
	end

	result["code"] = 0
	result["userlist"]=users
    LuciHttp.write_json(result)

end


function string.split(input, delimiter)  
    input = tostring(input)  
    delimiter = tostring(delimiter)  
    if (delimiter=='') then return false end  
    local pos,arr = 0, {}  
    -- for each divider found  
    for st,sp in function() return string.find(input, delimiter, pos, true) end do  
        table.insert(arr, string.sub(input, pos, st - 1))  
        pos = sp + 1  
    end  
    table.insert(arr, string.sub(input, pos))  
    return arr  
end  