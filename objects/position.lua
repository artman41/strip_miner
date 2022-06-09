require("utils.logger")

Position = (function()
    local position = {
    }

    local private = {}

    local is_int = function(n)
        return (type(n) == "number") and (math.floor(n) == n)
    end

    function position:new(x, y, z)
        local obj = {};
        setmetatable(obj, self)
        self.__index = self;

        private[obj]  = {
            X = x or 0;
            Y = y or 0;
            Z = z or 0;
        }

        return obj;
    end

    function position:clone()
        return position:new(self:getX(), self:getY(), self:getZ())
    end

    function position:tostring()
        return "(" .. tostring(private[self].X) .. ", " .. tostring(private[self].Y) .. ", " .. tostring(private[self].Z) .. ")";
    end

    function position:getX()
        return private[self].X;
    end

    function position:setX(v)
        if not is_int(v) then
            return false
        end
        private[self].X = v;
    end

    function position:getY()
        return private[self].Y;
    end

    function position:setY(v)
        if not is_int(v) then
            return false
        end
        private[self].Y = v;
    end

    function position:getZ()
        return private[self].Z;
    end

    function position:setZ(v)
        if not is_int(v) then
            return false
        end
        private[self].Z = v;
    end

    function position:diff(pos_)
        local status, ret;

        status, ret = pcall(function() return pos_:getX() end)
        if not status then
            Logger.DEFAULT:error("Failed to get X from %s with error '%s'", tostring(pos_), tostring(ret))
            return nil;
        end
        local x = ret;

        status, ret = pcall(function() return pos_:getY() end)
        if not status then
            Logger.DEFAULT:error("Failed to get Y from %s with error '%s'", tostring(pos_), tostring(ret))
            return nil;
        end
        local y = ret;

        status, ret = pcall(function() return pos_:getZ() end)
        if not status then
            Logger.DEFAULT:error("Failed to get Z from %s with error '%s'", tostring(pos_), tostring(ret))
            return nil;
        end
        local z = ret;
        
        local diff = position:new(x - self:getX(), y - self:getY(), z - self:getZ());

        return diff;
    end

    return position;
end)()