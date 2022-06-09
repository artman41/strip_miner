function OptsBuilder(base)
    return function()
        local opts = base or {}

        function opts:new(params)
            local obj = {};
            setmetatable(obj, self)
            self.__index = self;

            if params ~= nil and type(params) == "table" then
                for k, v in pairs(base or {}) do
                    if k ~= "__index" then
                        obj[k] = params[k] or v
                    end
                end
            end

            return obj;
        end

        return opts;
    end
end