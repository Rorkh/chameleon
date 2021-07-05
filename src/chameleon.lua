local database = {}

local model = require("chameleon.model")
local sqlite = require("lsqlite3complete")
local querygen = require("chameleon.querygen")

local fields = require("chameleon.fields")
local flags = require("chameleon.flags")

function database:new(filename)
	local obj = {}
		self.models = {}
		obj.field = fields
		obj.flags = flags
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
		self._instance:exec("VACUUM")
        end

	setmetatable(obj, self)
	self.__index = self

	return obj
end

return database
