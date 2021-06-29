local model = {}

local object = require("database.object")
local querygen = require("database.querygen")
local sqlite = require("lsqlite3complete")

function model:instance(database, name, struct)
	table.insert(struct, {"INTEGER PRIMARY KEY AUTOINCREMENT", "uid"})

	local obj = {}
		self.database = database
		obj.struct = struct
		obj.name = name
	
	function obj:clear()
		self.database:instance():exec(querygen.clear(self.name))
	end
	
	function obj:new(struct)
		return object:new(obj.struct, struct, self.name, self.database)
	end

	function obj:get(struct)
		local database = self.database:instance()
		local data
		for row in database:nrows(querygen.select(self.name, struct)) do
			if not data then data = row end
		end

		if not data then return false end

		return object:new(obj.struct, data, self.name, self.database)
	end
	
	setmetatable(obj, self)
	self.__index = self
	
	return obj
end

return model
