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
            Logger.DEFAULT:debug("New Direction is %d", newDirection);
            if newDirection < Direction.min() then
                newDirection = newDirection + Direction.count();
            end
            Logger.DEFAULT:debug("New Direction is fixed to %d", newDirection);
            if Direction:from(newDirection) == nil then
                error(string.format("Bad Direction: %d", newDirection));
                return false;
            end
            self.direction = Direction:from(newDirection);
            return true;
        end
        Logger.DEFAULT:warn("Failed to turn left!");
        return false;
    end

    function movement:turnRight()
        if turtle.turnRight() then
            local newDirection = self.direction.value() + 1;
            Logger.DEFAULT:debug("New Direction is %s", newDirection);
            if newDirection > Direction.max() then
                newDirection = newDirection - Direction.count();
            end
            Logger.DEFAULT:debug("New Direction is fixed to %s", newDirection);
            if Direction:from(newDirection) == nil then
                error(string.format("Bad Direction: %d", newDirection));
                return false;
            end
            self.direction = Direction:from(newDirection);
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
        local anchor = self:drop_anchor();
        if self:rotate_to(Direction.LEFT) then
            if self:forward() then
                if self:rotate_to(Direction.FORWARD) then
                    self:remove_anchor(anchor);
                    return true;
                end
            end
        end
        self:return_to_anchor(anchor);
        return false;
    end

    function movement:right()
        local anchor = self:drop_anchor();
        if self:rotate_to(Direction.RIGHT) then
            if self:forward() then
                if self:rotate_to(Direction.FORWARD) then
                    self:remove_anchor(anchor);
                    return true;
                end
            end
        end
        self:return_to_anchor(anchor);
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

        self:rotate_to(Direction.FORWARD);

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

    function movement:rotate_to(direction)
        Logger.DEFAULT:debug("Rotating from facing %s to facing %s", self.direction:name(), direction:name())

        local function turnLeft(i)
            for _=1,i do
                if not self:turnLeft() then
                    return false;
                end
            end
            return true;
        end

        local function turnRight(i)
            for _=1,i do
                if not self:turnRight() then
                    return false;
                end
            end
            return true;
        end

        if self.direction == Direction.FORWARD then
            if direction == Direction.LEFT then
                if not turnLeft(1) then
                    return false;
                end
            elseif direction == Direction.RIGHT then
                if not turnRight(1) then
                    return false;
                end
            elseif direction == Direction.BACKWARD then
                if not turnRight(2) then
                    return false;
                end
            end
        elseif self.direction == Direction.RIGHT then
            if direction == Direction.FORWARD then
                if not turnLeft(1) then
                    return false;
                end
            elseif direction == Direction.BACKWARD then
                if not turnRight(1) then
                    return false;
                end
            elseif direction == Direction.LEFT then
                if not turnRight(2) then
                    return false;
                end
            end
        elseif self.direction == Direction.BACKWARD then
            if direction == Direction.RIGHT then
                if not turnLeft(1) then
                    return false;
                end
            elseif direction == Direction.LEFT then
                if not turnRight(1) then
                    return false;
                end
            elseif direction == Direction.FORWARD then
                if not turnRight(2) then
                    return false;
                end
            end
        elseif self.direction == Direction.LEFT then
            if direction == Direction.BACKWARD then
                if not turnLeft(1) then
                    return false;
                end
            elseif direction == Direction.FORWARD then
                if not turnRight(1) then
                    return false;
                end
            elseif direction == Direction.RIGHT then
                if not turnRight(2) then
                    return false;
                end
            end
        end

        return true;
    end

    function movement:drop_anchor()
        local index=#self.anchors+1;
        self.anchors[index] = {pos = self.pos_current:clone(), direction = Direction:from(self.direction:value())};
        return index;
    end

    function movement:remove_anchor(index)
        self.anchors[index] = nil;
    end

    function movement:return_to_anchor(index, attempts)
        local anchor = self.anchors[index];
        Logger.DEFAULT:debug("(Returning to Anchor) Current Pos: %s, anchor pos: %s", self.pos_current:tostring(), anchor.pos:tostring())
        self:return_to(anchor.pos, attempts or 3);
        self:rotate_to(anchor.direction);
        self:remove_anchor(index);
    end

    movement.Direction = Direction;

    return movement;
end)()