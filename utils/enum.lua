Enum = (function() 
    local enum = {
        value_to_enum = {}
    }

    -- enum:new(Entries...)
    -- enum:new(EntryMetaTable, Entries...)
    function enum:new(...)
        local obj = {};
        setmetatable(obj, self)
        self.__index = self;

        local min = 0;
        local max = min;
        local count = 0;

        self.min = function() return min end
        self.max = function() return max end
        self.count = function() return count end

        local base_entry = nil
        if type(arg[1]) == "table" then
            base_entry = table.remove(arg, 1)
        end

        for i, v in ipairs(arg) do
            local value = max;
            local entry = {};
            if base_entry ~= nil then
                setmetatable(entry, base_entry)
                base_entry.__index = base_entry;
            end
            entry.name = function() return v end;
            entry.value = function() return value end;
            self[v] = entry;
            self.value_to_enum[value] = entry;
            max = max + 1;
            count = i;
        end

        return obj;
    end

    function enum:from(value)
        local value = tonumber(value);
        if value == nil or value < self.min() or value > self.max() then
            return nil;
        end
        return self.value_to_enum[value];
    end

    return enum;
end)()