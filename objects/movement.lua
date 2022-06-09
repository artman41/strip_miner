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
        anchors = {},
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
        Logger.DEFAULT:warn("Failed to turn left!");
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
        Logger.DEFAULT:warn("Failed to turn right!");
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
        self:return_to(self.pos_origin, attempts)
    end

    function movement:return_to(pos, attempts)
        local diff = self.pos_current:diff(pos);
        if diff == nil then
            error(string.format("Failed to diff pos_current '%s' against pos_origin '%s'", self.pos_current:tostring(), self.pos_origin:tostring()))
            return;
        end
        local travel_x = diff:getX();
        local travel_y = diff:getY();
        local travel_z = diff:getZ();

        Logger.DEFAULT:debug("to travel, x=%d y=%d z=%d", travel_x, travel_y, travel_z);

        local attempts = tonumber(attempts) or 3;

        local diff = (Direction.FORWARD.value() - self.direction.value()) * -1

        if diff >=3 then
            for _=3,diff do
                self:turnRight()
            end
        else
            for _=1,diff do
                self:turnLeft()
            end
        end

        while attempts > 0 do

            while travel_x < 0 do
                if not self:left() then
                    Logger.DEFAULT:debug("Couldn't move left, will try again next attempt.")
                    break
                end
                travel_x = travel_x + 1
            end
            
            while travel_x > 0 do
                if not self:right() then
                    Logger.DEFAULT:debug("Couldn't move right, will try again next attempt.")
                    break
                end
                travel_x = travel_x - 1
            end

            while travel_y < 0 do
                if not self:down() then
                    Logger.DEFAULT:debug("Couldn't move down, will try again next attempt.")
                    break
                end
                travel_y = travel_y + 1
            end
            
            while travel_y > 0 do
                if not self:up() then
                    Logger.DEFAULT:debug("Couldn't move up, will try again next attempt.")
                    break
                end
                travel_y = travel_y - 1
            end
            
            while travel_z < 0 do
                if not self:back() then
                    Logger.DEFAULT:debug("Couldn't move back, will try again next attempt.")
                    break
                end
                travel_z = travel_z + 1
            end
            
            while travel_z > 0 do
                if not self:forward() then
                    Logger.DEFAULT:debug("Couldn't move forward, will try again next attempt.")
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

    function movement:drop_anchor()
        local index=#self.anchors+1;
        self.anchors[index] = self.pos_current:clone();
        return index;
    end

    function movement:return_to_anchor(index, attempts)
        local pos_anchor = self.anchors[index];
        Logger.DEFAULT:debug("(Returning to Anchor) Current Pos: %s, anchor pos: %s", self.pos_current:tostring(), pos_anchor:tostring())
        self:return_to(pos_anchor, attempts or 3);
        self.anchors[index] = nil;
    end

    movement.Direction = Direction;

    return movement;
end)()