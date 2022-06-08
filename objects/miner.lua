require("strip_miner.objects.turtle")
require("strip_miner.objects.enum")
require("strip_miner.objects.movement")
require("strip_miner.objects.inventory")

Miner = (function()
    
    local miner = {
        movement = Movement:new(),
        inventory = Inventory:new(),
        radius = 0,
        refuelThreshold = 0.1, -- 10%
        timeSinceLastRefuel = 0
    }

    function miner:new(radius, refuelThreshold)
        if tonumber(radius) == nil then
            error("Radius required")
        end
        local obj = {
        };
        setmetatable(obj, self)
        self.__index = self;

        obj.radius = tonumber(radius)
        obj.refuelThreshold = refuelThreshold or miner.refuelThreshold
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
            print("Waiting for fuel...")
            local fuel_slot = self.inventory:find_fuel();
            while fuel_slot == nil do
                print("Press any key once fuel has been inserted...")
                os.pullEvent("key")

                fuel_slot = self.inventory:find_fuel();
            end
        end
    end)();

    -- Setup
    (function()
        function miner:should_setup()
            return false;
        end

        function miner:setup()
            print("Setting up...")
        end
    end)();

    -- Mining
    (function()
        function miner:mine_block()
            if not self:try_refuel().success then
                if turtle.getFuelLevel() == 0 then
                    local retry = true;
                    while retry do
                        self:wait_for_fuel();
                        retry = not self:try_refuel().success;
                    end
                else
                    print("Couldn't refuel.")
                end
            end
            turtle.dig()
            return false
        end
        function miner:mine_wall()
            return false
        end
    end)();

    return miner;
end)()