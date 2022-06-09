require("apis.turtle")
require("utils.logger")

Inventory = (function()
    
    -- { name = "modname:itemname", damage = 0, count = 1 } | nil
    local inventory = {
        data = {}
    }

    function inventory:new()
        local obj = {
        };
        setmetatable(obj, self)
        self.__index = self;

        obj:update();

        return obj;
    end

    function inventory:find(itemName, opts)
        if opts.tryupdate == nil then
            opts.tryupdate = true;
        end
        local function dofind()
            if self.data[itemName] ~= nil then
                local slot = tonumber(self.data[itemName].slot);
                local data = turtle.getItemDetail(slot);
                if data ~= nil and data.name == itemName then
                    return slot;
                end
            end
            return nil
        end

        local found = dofind();
        if found ~= nil then
            return found;
        elseif opts.tryupdate then
            self:update();
            return dofind();
        end
    end

    function inventory:find_fuel()
        local fuels = {
            "minecraft:coal",
            "immersiveengineering:coal_coke"
        }
        self:update()
        for _, fuel in ipairs(fuels) do
            local found = self:find(fuel, {tryupdate = false});
            if found ~= nil then
                return found
            end
        end
        return nil;
    end

    function inventory:update()
        for i = 1, 16 do
            local data = turtle.getItemDetail(i);
            if data ~= nil then
                self.data[data.name] = {
                    slot = i,
                    damage = data.damage,
                    count = data.count
                };     
            end
        end
    end

    return inventory;
end)()