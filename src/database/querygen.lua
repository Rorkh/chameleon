local querygen = {}

local f = string.format

function querygen.new_table(name, struct)
	local sql = f("CREATE TABLE IF NOT EXISTS %s (", name)

	for k, field in ipairs(struct) do
		local options = field[3] and table.concat(field[3], "") or ""
		local ending = k == #struct and "" or ", "

		sql = sql .. f("%s %s %s", field[2], field[1], options) .. ending
	end

	return sql .. ")"
end

function querygen.clear(name)
	return f("DELETE FROM %s", name)
end

function querygen.delete(name, uid)
	return f("DELETE FROM %s WHERE uid = %i", name, uid)
end

function querygen.select(name, struct)
	local sql = f("SELECT * FROM %s WHERE ", name)
	
	local i = 0
	for key, value in pairs(struct) do
		if type(value) == "string" then value = f("\"%s\"", value) end

		i = i + 1
		sql = sql .. (i == 1 and "" or "AND ") .. f("%s = %s ", key, value)
	end

	return sql
end

function querygen.insert(name, struct, len)
	local keys = ""
        local values = ""

        local i = 0

        for key, value in pairs(struct) do
		i = i + 1
		local ending = (i == len and "" or ",")

		keys = keys .. key .. ending
		values = values .. (type(value) == "string" and f("\"%s\"", value) or value) .. ending
        end

        return f("INSERT INTO %s (%s) VALUES (%s)", name, keys, values)
end

function querygen.update(name, struct, len, uid)
	local buf, i = "", 0

	for key, value in pairs(struct) do
		i = i + 1
		buf = buf .. f("%s = %s", key, (type(value) == "string" and f("\"%s\"", value) or value)) .. (len == i and "" or ", ") 
	end

	return f("UPDATE %s SET %s WHERE uid = %s", name, buf, uid)
end

return querygen
