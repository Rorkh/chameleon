local object = {}

local querygen = require("database.querygen")
local sqlite = require("lsqlite3complete")

function object:new(model_struct, struct, model_name, database)
	local obj = {}
		obj.database = database
		obj.model = model_struct
		obj.model_name = model_name
		obj.keys = {}

		self.changes = {}
		self.uid = struct.uid

	for key, value in pairs(struct) do
		if key ~= "uid" then
			table.insert(obj.keys, key)
			self[key] = value
		end
	end

	function obj:delete()
		self.database:instance():exec(querygen.delete(self.model_name, self.uid))
	end

	function obj:insert()
		local struct, len = {}, 0
		for _, v in ipairs(self.keys) do
			len = len + 1
			struct[v] = self[v] 
		end
			
		self.database:instance():exec(querygen.insert(self.model_name, struct, len))

		return true
	end

	function obj:save()
		if not self.uid then error("Trying to save not inserted object.") end

		local struct, len = {}, 0
		for k, v in pairs(self.changes) do
			len = len + 1
			struct[k] = v
		end
		
		self.database:instance():exec(querygen.update(self.model_name, struct, len, self.uid))

		return true
	end

	setmetatable(obj, self)
	self.__newindex = function(table, key, value)
		if key == "uid" then error("uid key is reserved and can't be used") end
		self[key] = value
		self.changes[key] = value
	end
	self.__index = self

	return obj
end

return object
