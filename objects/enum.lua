Enum = (function() 
    local enum = {
    }

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

        for i, v in ipairs(arg) do
            self[v] = max;
            max = max + 1;
            count = i;
        end

        return obj;
    end

    return enum;
end)()