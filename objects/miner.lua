require("apis.turtle")
require("objects.movement")
require("objects.inventory")
require("utils.enum")
require("utils.opts")
require("utils.logger")

Miner = (function()

    local MinerOpts = OptsBuilder({
        radius = 1, -- default to 3x3
        refuelThreshold = 0.1 -- 10%
    })();
    
    local miner = {
        movement = Movement:new(),
        inventory = Inventory:new(),
        radius = 0,
        refuelThreshold = 0, -- 10%
        timeSinceLastRefuel = 0
    }

    function miner:new(params)
        local obj = {};
        setmetatable(obj, self);
        self.__index = self;

        local default_opts = MinerOpts:new({})
        local opts = MinerOpts:new(params)

        obj.radius = tonumber(opts.radius) or default_opts.radius; 
        obj.refuelThreshold = tonumber(opts.refuelThreshold) or default_opts.refuelThreshold;
        return obj;
    end

    -- Utility
    (function()
        -- Returns UNIX timestamp in seconds
        function miner.unix_timestamp()
            return os.time(os.date("!*t"))
        end
    end)();

    -- Refuel
    (function()
        function miner:should_refuel()
            if tonumber(turtle.getFuelLimit()) == nil then
                return false;
            end
            local refuelThreshold = turtle.getFuelLimit() * self.refuelThreshold;
            return turtle.getFuelLevel() <= refuelThreshold;
        end
        function miner:try_refuel()
            local ret = {
                success = false;
                refueled = false;
            }
            -- If it's been 15 or less seconds since the last refuel,
            --  just skip the attempt - there's no way the fuel will
            --  have ran out since then.
            if self.unix_timestamp() - self.timeSinceLastRefuel <= 15 then
                ret.success = true;
                return ret;
            end
            if miner:should_refuel() then
                local fuelSlot = miner.inventory:find_fuel();
                if fuelSlot == nil then
                    ret.success = false;
                    return ret;
                end
                turtle.select(fuelSlot);
                turtle.refuel();
                self.timeSinceLastRefuel = self.unix_timestamp();
                ret.success = true;
                ret.refueled = true;
                return ret;
            end
            ret.success = true;
            return ret;
        end
        function miner:wait_for_fuel()
            Logger.DEFAULT:info("Waiting for fuel...")
            local fuel_slot = self.inventory:find_fuel();
            while fuel_slot == nil do
                Logger.DEFAULT:info("Press any key once fuel has been inserted...")
                os.pullEvent("key")

                fuel_slot = self.inventory:find_fuel();
            end
        end
        function miner:refuel_check()
            if not self:try_refuel().success then
                Logger.DEFAULT:debug("Failed to refuel.")
                if turtle.getFuelLevel() == 0 then
                    Logger.DEFAULT:warn("Fuel Level is 0! Fuel Needed!")
                    local retry = true;
                    while retry do
                        self:wait_for_fuel();
                        retry = not self:try_refuel().success;
                    end
                end
            end
        end
    end)();

    -- Setup
    (function()
        function miner:setup()
            Logger.DEFAULT:info("Setting up...")
            Logger.DEFAULT:info("Mining Radius: %d", self.radius)
            Logger.DEFAULT:info("Refuel Threshold: %d%%", self.refuelThreshold * 100)
            Logger.DEFAULT:notice("The miner assumes that it is placed at the Center-Bottom of the wall.")
            print("Press any key to continue...")
            os.pullEvent("key")
        end
    end)();

    -- Mining
    (function()

        function miner:mine_block(direction)
            miner:refuel_check()
            if direction == nil or direction == "f" then
                if not turtle.detect() then
                    return true;
                end
                return turtle.dig()
            elseif direction == "u" then
                if not turtle.detectUp() then
                    return true;
                end
                return turtle.digUp()
            elseif direction == "d" then
                if not turtle.detectDown() then
                    return true;
                end
                return turtle.digDown()
            end
            return false
        end
        function miner:mine_sides()
            local anchor = self.movement:drop_anchor()
            if not self.movement:turnLeft() then
                Logger.DEFAULT:error("Failed to turn left!");
                return false;
            end
            local is_ok = true;
            for _=1,self.radius do
                if not self:mine_block()  then
                    Logger.DEFAULT:error("Failed to mine block!");
                    is_ok = false;
                    break;
                end
                if not self.movement:forward()  then
                    Logger.DEFAULT:error("Failed to move forward!");
                    is_ok = false
                    break;
                end
            end
            self.movement:return_to_anchor(anchor)
            if not is_ok then
                return false;
            end
            local anchor = self.movement:drop_anchor()
            if not self.movement:turnRight() then
                Logger.DEFAULT:error("Failed to turn right!");
                return false;
            end
            local is_ok = true;
            for _=1,self.radius do
                if not self:mine_block() then
                    Logger.DEFAULT:error("Failed to mine block!");
                    is_ok = false;
                    break;
                end
                if not self.movement:forward() then
                    Logger.DEFAULT:error("Failed to move forward!");
                    is_ok = false;
                    break
                end
            end
            self.movement:return_to_anchor(anchor)
            if not is_ok then
                return false;
            end
            return true;
        end
        function miner:mine_wall()
            if not self:mine_block() then
                Logger.DEFAULT:error("Failed to mine block!");
                return false;
            end
            if not self.movement:forward() then
                Logger.DEFAULT:error("Failed to move forwards!");
                return false;
            end
            if not self:mine_sides() then
                Logger.DEFAULT:error("Failed to mine sides!");
                return false;
            end
            local anchor = self.movement:drop_anchor()
            local is_ok = true;
            for _=1,self.radius do
                if not self:mine_block("u")  then
                    Logger.DEFAULT:error("Failed to mine block up!");
                    is_ok = false;
                    break;
                end
                if not self.movement:up()  then
                    Logger.DEFAULT:error("Failed to move up!");
                    is_ok = false;
                    break;
                end
                if not self:mine_sides()  then
                    Logger.DEFAULT:error("Failed to mine sides!");
                    is_ok = false;
                    break;
                end
            end
            self.movement:return_to_anchor(anchor)
            if not is_ok then
                return false;
            end
            return true
        end
    end)();

    return miner;
end)()