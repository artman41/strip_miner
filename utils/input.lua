Input = (function() 
    local input = {}

    function input:new(...)
        local obj = {};
        setmetatable(obj, self)
        self.__index = self;

        return obj;
    end

    function input.wait_for_key(prompt)
        io.stdout:write(prompt);
        io.stdout:flush();
        ---@diagnostic disable-next-line: undefined-field
        local key = os.pullEvent("key")
        io.stdout:write("\n");
        io.stdout:flush();
        return key;
    end

    function input.getNumber(prompt, constraints)
        constraints = constraints or {};
        local value = nil;
        while value == nil do
            io.stdout:write(prompt .. " ");
            io.stdout:flush();
            value = tonumber(io.stdin:read("l"))
            if constraints.min ~= nil then
                if constraints.min > value then
                    value = nil
                end
            end
            if constraints.max ~= nil then
                if constraints.max < value then
                    value = nil
                end
            end
        end
        return value;
    end

    return input;
end)()