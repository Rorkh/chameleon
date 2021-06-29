local database = {}

local model = require("database.model")
local sqlite = require("lsqlite3complete")
local querygen = require("database.querygen")

function database:new(filename)
	local obj = {}
		self.models = {}
		obj.field = require("database.fields")
		obj._instance = sqlite.open(filename)
	
	function obj:instance()
		return self._instance
	end

	function obj:model(name, struct)
		table.insert(self.models, name)
		self[name] = model:instance(self, name, struct)
	end

	function obj:register()
		local database = self._instance
		
		for _, name in ipairs(self.models) do
			database:exec(querygen.new_table(name, self[name].struct))
		end
	end

	function obj:vacuum()
		self.database:instance():exec("VACUUM")
        end

	setmetatable(obj, self)
	self.__index = self

	return obj
end

return database
