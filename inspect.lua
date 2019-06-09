local print, format_string, format_value, print_pair, print_table, print_args, inspect, setting, max_depth

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
				print_table(depth + 1, v)
			end
			print(padding .. '}')
		end
	end
end

function print_table(depth, t)
	for i = 1, #t do
		print_pair(i, t[i], depth)
	end
	for k, v in pairs(t) do
		if type(k) ~= 'number' or k < 1 or k > #t then
			print_pair(k, v, depth)
		end
	end
end

function print_args(...)
	local n = select('#', ...)
	for i = 1, n do
		print_pair(i, select(i, ...), 0)
	end
end

function inspect(_, ...)
	if select('#', ...) == 0 then
		print('-')
	else
		max_depth = max_depth or 2
		print_args(...)
		max_depth = nil
	end
	return ...
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