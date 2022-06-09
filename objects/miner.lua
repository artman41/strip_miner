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
            if self.unix_timestamp() - self.lastRefuelTime <= 15 then
                return ret{success = true};
            end
            if miner:should_refuel() then
                local fuelSlot = miner.inventory:find_fuel();
                if fuelSlot == nil then
                    return ret{success = false};
                end
                turtle.select(fuelSlot);
                turtle.refuel();
                return ret{success = true, refueled = true};
            end
            return ret{success = true};
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
        function miner:mine_block()
            miner:refuel_check()
            turtle.dig()
            return false
        end
        function miner:mine_wall()
            return false
        end
    end)();

    return miner;
end)()