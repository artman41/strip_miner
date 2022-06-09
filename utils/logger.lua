require("apis.term")
require("apis.colors")
require("utils.enum")
require("utils.opts")

local __loglevelinfo = {
    {"DEBUG", colors.gray},
    {"INFO", colors.white},
    {"NOTICE", colors.lightBlue},
    {"WARN", colors.yellow},
    {"ERROR", colors.red},
}

local __loglevels = {}
for i, v in ipairs(__loglevelinfo) do
    __loglevels[i] = v[1]
end

local LogLevel = Enum:new(
    {
        colour = function(self)
            local name = self:name();
            for _, v in ipairs(__loglevelinfo) do
                if name == v[1] then
                    return v[2];
                end
            end
            error(string.format("Unknown loglevel '%s'", name));
        end
    },
    table.unpack(__loglevels)
);

local LoggerOpts = OptsBuilder({
    loglevel = LogLevel.min(),
    file = ""
})();

Logger = (function()

    local logger = {
        loglevel = LogLevel:from(LogLevel.min()),
        log_file = nil
    }

    function logger:new(params)
        local obj = {};
        setmetatable(obj, self)
        self.__index = self;

        local opts = LoggerOpts:new(params)

        self:set_loglevel(opts.loglevel)
        if opts.file ~= "" then
            local file, err = io.open(opts.file, "w")
            if file == nil then
                self:error("Failed to open file %s with error %s", opts.file, err)
            else
                self.log_file = file;
            end
        end

        return obj;
    end

    function logger:set_loglevel(loglevel)
        if loglevel == nil then
            return false
        end

        if tonumber(loglevel) ~= nil then
            local loglevel = tonumber(loglevel);
            if loglevel < LogLevel.min() then
                loglevel = LogLevel.min()
            elseif loglevel > LogLevel.max() then
                loglevel = LogLevel.max()
            end
            self.loglevel = LogLevel:from(loglevel);
            return true;
        end

        if LogLevel[string.upper(loglevel)] ~= nil then
            self.loglevel = LogLevel[string.upper(loglevel)]
            return true;
        end

        return false;
    end

    function logger:debug(fmt, ...)
        logger:log(LogLevel.DEBUG, fmt, ...)
    end

    function logger:info(fmt, ...)
        logger:log(LogLevel.INFO, fmt, ...)
    end

    function logger:notice(fmt, ...)
        logger:log(LogLevel.NOTICE, fmt, ...)
    end

    function logger:warn(fmt, ...)
        logger:log(LogLevel.WARN, fmt, ...)
    end

    function logger:error(fmt, ...)
        logger:log(LogLevel.ERROR, fmt, ...)
    end

    function logger:log(loglevel, fmt, ...)
        if fmt == nil or fmt == "" then
            return
        end
        if loglevel.value() < self.loglevel.value() then
            return;
        end

        local debug_info = debug.getinfo(3);
        local prefix = string.format("[%s] %s:%d", string.upper(loglevel.name()), debug_info.short_src, debug_info.currentline)
        local str = string.format("%s " .. fmt, prefix, ...);
        if self.log_file ~= nil then
            self.log_file:write(str .. "\n");
            self.log_file:flush();
        end

        local colour = term.getTextColour()
        term.setTextColour(loglevel:colour())
        print(str)
        term.setTextColour(colour)
    end

    return logger;
end)()

Logger.DEFAULT = Logger:new({loglevel = "debug", file = nil})