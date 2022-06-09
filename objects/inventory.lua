require("apis.turtle")
require("utils.logger")

Inventory = (function()
    
    -- { name = "modname:itemname", damage = 0, count = 1 } | nil
    local inventory = {
        data = {}
    }
    local fuels = {
        "minecraft:coal",
        "immersiveengineering:coal_coke"
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
        opts = opts or {}
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

    function inventory:has_empty_slot()
        self:update()
        local bool = false;
        for i = 1, 16 do
            if turtle.getItemCount(i) == 0 then
                bool = true
                break
            end
        end
        return bool;
    end

    function inventory:drop_items()
        local function has_value (tab, val)
            for index, value in ipairs(tab) do
                if value == val then
                    return true
                end
            end
        
            return false
        end
        self:update()
        for i = 1, 16 do
            local data = turtle.getItemDetail(i);
            if data ~= nil then
                if not has_value(fuels, data.name) and data.name ~= "minecraft:torch" and data.name ~= "minecraft:chest" then
                    turtle.select(i);
                    if not turtle.drop() then
                        return false;
                    end
                end
            end
        end
        return true;
    end

    return inventory;
end)()