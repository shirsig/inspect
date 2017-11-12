local print, format_string, format_value, print_pair, print_table, inspect, setting, max_depth

function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 0, 0)
end

function format_string(s)
	return '"' .. gsub(gsub(s, '\\', '\\\\'), '"', '\"') .. '"'
end

function format_value(v)
	return type(v) == 'string' and format_string(v) or tostring(v)
end

function print_pair(k, v, depth)
	local padding = strrep(' ', depth * 4)
	print(padding .. '[' .. format_value(k) .. ']' .. ' = ' .. format_value(v))
	if type(v) == 'table' then
		if next(v) then
			print(padding .. '{')
			if depth == max_depth then
				print(padding .. '    ...')
			else
				print_table(v, depth + 1)
			end
			print(padding .. '}')
		end
	end
end

function print_table(t, depth)
	for i, v in ipairs(t) do
		print_pair(i, v, depth)
	end
	for k, v in pairs(t) do
		if type(k) ~= 'number' or k < 1 or k > getn(t) then
			print_pair(k, v, depth)
		end
	end
end

function inspect(_, ...)
	local n = arg.n
	arg.n = nil
	if n == 0 then
		print('[1] = nil')
	else
		table.setn(arg, n)
		max_depth = max_depth or 2
		print_table(arg, 0)
		max_depth = nil
	end
	return unpack(arg)
end

local function setting(v)
	if type(v) == 'number' then
		max_depth = v
	elseif type(v) == 'function' then
		print('#' .. v())
	else
		print('#' .. v)
	end
end

p = setmetatable({}, {
	__metatable=false,
	__call=inspect,
	__pow=inspect,
	__index = function(self, key)
		setting(key)
		return self
	end,
	__newindex = function(self, key, value)
		setting(key)
		inspect(nil, value)
		return self
	end,
})