local file = io.open("/etc/misstar/luci/js/nav.json", "r")
assert(file)
local data = file:read("*a")    --读取文件
file:close()

local cjson = require "cjson"
local json = cjson.decode(data);

---添加节点
function insertnode(tab,data)
	local b = loadstring("return "..data);
	data = b();
	table.insert(tab, table.maxn(tab),data)
	--table.insert(json[1]["children"], table.maxn(json[1]["children"]),{["title"]="远程管理",["icon"]="&#xe63c;",	["href"]="rm"})
end

--删除节点
function deletenode(tab,data)
	for i,v in pairs(tab) do 
		if( tab[i]["href"] == data ) then
			table.remove(tab, i)
		end
	end
end  


--写入文件
function save(data)
	path = "/etc/misstar/luci/js/nav.json"
	mode = mode or "w+b"
	local file = io.open(path, mode)
	if file then
		if file:write(data) == nil then return false end   
		io.close(file)
		return true
	else
		return false
	end
 end


if arg[1] == "add" then   
	insertnode(json[1]["children"],arg[2])
	save(cjson.encode(json))
	print(0)
elseif arg[1] == "del" then 
	deletenode(json[1]["children"],arg[2])
	save(cjson.encode(json))
	print(0)
else  
	print "Error"
	return false
end  
