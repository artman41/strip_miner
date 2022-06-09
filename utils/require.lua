require = (function()
    local lua_require = require;

    local function filename()
        local str = debug.getinfo(3, "S").source:sub(2)
        return str:match("^.*/(.*).lua$") or str
    end

    return function (str)
        local success, err = pcall(lua_require, str)
        if not success then
            local logname = string.format("%s-error.log", filename());
            local f = io.open(logname, "w")
            if f ~= nil then
                f:write(err)
                print("Wrote error @ " .. logname)
                f:close()
            end
            error(string.format("Failed to require '%s'", str))
            return false, err
        end
        return true, nil
    end
end)()