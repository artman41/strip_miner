require("apis.turtle")
require("utils.enum");
require("objects.position");
require("utils.logger")

Movement = (function()
    Direction = Enum:new(
        "FORWARD",
        "RIGHT",
        "BACKWARD",
        "LEFT"
    );

    local movement = {
        pos_origin  = Position:new(0, 0, 0),
        pos_current = Position:new(0, 0, 0),
        direction = Direction.FORWARD
    }

    function movement:new()
        local obj = {};
        setmetatable(obj, self);
        self.__index = self;

        return obj;
    end

    function movement:turnLeft()
        if turtle.turnLeft() then
            local newDirection = self.direction.value() - 1;
            if newDirection < Direction.min() then
                newDirection = newDirection + Direction.count();
            end
            self.direction = Direction:from(newDirection) or error(string.format("Bad Direction: %d", newDirection));
            return true;
        end
        return false;
    end

    function movement:turnRight()
        if turtle.turnRight() then
            local newDirection = self.direction.value() + 1;
            if newDirection > Direction.max() then
                newDirection = newDirection - Direction.count();
            end
            self.direction = Direction:from(newDirection) or error(string.format("Bad Direction: %d", newDirection));
            return true;
        end
        return false;
    end

    function movement:forward()
        if turtle.forward() then
            if self.direction == Direction.FORWARD then
                self.pos_current:setZ(self.pos_current:getZ() + 1);
            elseif self.direction == Direction.BACKWARD then
                self.pos_current:setZ(self.pos_current:getZ() - 1);
            elseif self.direction == Direction.RIGHT then
                self.pos_current:setX(self.pos_current:getX() + 1);
            elseif self.direction == Direction.LEFT then
                self.pos_current:setX(self.pos_current:getX() - 1);
            end;
            return true;
        end
        return false;
    end

    function movement:back()
        if turtle.back() then
            if self.direction == Direction.FORWARD then
                self.pos_current:setZ(self.pos_current:getZ() - 1);
            elseif self.direction == Direction.BACKWARD then
                self.pos_current:setZ(self.pos_current:getZ() + 1);
            elseif self.direction == Direction.RIGHT then
                self.pos_current:setX(self.pos_current:getX() - 1);
            elseif self.direction == Direction.LEFT then
                self.pos_current:setX(self.pos_current:getX() + 1);
            end
            return true;
        end
        return false;
    end

    function movement:left()
        if self:turnLeft() then
            if self:forward() then
                if self:turnRight() then
                    return true;
                else
                    self:back();
                    self:turnRight();
                end
            else
                self:turnRight();
            end
        end
        return false;
    end

    function movement:right()
        if self:turnRight() then
            if self:forward() then
                if self:turnLeft() then
                    return true;
                else
                    self:back();
                    self:turnLeft();
                end
            else
                self:turnLeft();
            end
        end
        return false;
    end

    function movement:up()
        if turtle.up() then
            self.pos_current:setY(self.pos_current:getY() + 1);
            return true;
        end
        return false;
    end

    function movement:down()
        if turtle.down() then
            self.pos_current:setY(self.pos_current:getY() - 1);
            return true;
        end
        return false;
    end

    function movement:return_to_origin(attempts)
        local diff = self.pos_current:diff(self.pos_origin);
        if diff == nil then
            error("Failed to diff pos_current '" .. self.pos_current:tostring() .. "' against pos_origin '" .. self.pos_origin:tostring() .."'")
            return;
        end
        local travel_x = diff:getX();
        local travel_y = diff:getY();
        local travel_z = diff:getZ();

        local attempts = tonumber(attempts) or 3;

        while attempts > 0 do

            while travel_x < 0 do
                if not self:left() then
                    break
                end
                travel_x = travel_x + 1
            end
            
            while travel_x > 0 do
                if not self:right() then
                    break
                end
                travel_x = travel_x - 1
            end

            while travel_y < 0 do
                if not self:down() then
                    break
                end
                travel_y = travel_y + 1
            end
            
            while travel_y > 0 do
                if not self:up() then
                    break
                end
                travel_y = travel_y - 1
            end
            
            while travel_z < 0 do
                if not self:back() then
                    break
                end
                travel_z = travel_z + 1
            end
            
            while travel_z > 0 do
                if not self:forward() then
                    break
                end
                travel_z = travel_z - 1
            end

            if travel_x == 0 and travel_y == 0 and travel_z == 0 then
                break;
            else
                attempts = attempts - 1
            end
        end

        if not (travel_x == 0 and travel_y == 0 and travel_z == 0) then
            error(string.format("Failed to return to origin! left to travel: %dx, %dy, %dz", travel_x, travel_y, travel_z))
            return;
        end
    end

    movement.Direction = Direction;

    return movement;
end)()