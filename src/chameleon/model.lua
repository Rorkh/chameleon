local model = {}

local object = require("chameleon.object")
local querygen = require("chameleon.querygen")
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
		local data = {}

		for row in database:nrows(querygen.select(self.name, struct)) do
			table.insert(data, object:new(obj.struct, row, self.name, self.database))
		end

		if next(data) == nil then return false end

		return #data == 1 and data[1] or data
	end
	
	setmetatable(obj, self)
	self.__index = self
	
	return obj
end

return model
