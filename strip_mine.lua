--[[

!!GOALS

[x] Strip Mine
[x] Auto Torch
[ ] Return to Chest + Dump Inv
[x] Refuel

[x] Setup with just a chest, coal & torches in inv

!! OPTIONALS

- Crafting Torches (probably useless)
- 

--]]

require("utils.require")
require("objects.miner")
require("utils.logger")
require("utils.input")
require("utils.string")

Logger.DEFAULT = Logger:new({loglevel = "debug", file = "/strip_miner/strip_mine.log"})

function get_args(...)
    local args = {}
    for _, v in ipairs(arg) do
        local split = string.split(v, "=");
        args[split[1]] = split[2]
    end
    return args;
end

function main(...)

    local args = get_args(...);
    
    local params = {
        radius          = tonumber(args["radius"]) or Input.getNumber("Radius?", {min = 1}),
        refuelThreshold = tonumber(args["refuelThreshold"]) or Input.getNumber("Refuel Threshold?", {min = 0, max = 0.99}),
        distance        = tonumber(args["distance"]) or Input.getNumber("Distance?", {min = 1}),
    }

    if params.radius % 1 > 0 then
        params.radius = params.radius - (params.radius % 1)
    end

    if params.distance % 1 > 0 then
        params.distance = params.distance - (params.distance % 1)
    end

    local miner = Miner:new(params)

    miner:setup()

    local chest_anchor = (function ()
        turtle.turnRight()
        local is_block, data = turtle.inspect()

        local anchor = nil;
        if is_block and data.name == "minecraft:chest" then
            anchor = miner.movement:drop_anchor(true)
        end
        turtle.turnLeft()
        return anchor;
    end)();

    function mine_wall()
        if not miner:mine_wall() then
            if miner.inventory:has_empty_slot() then
                Logger.DEFAULT:error("Failed to mine the wall!");
                return false;
            else
                if chest_anchor == nil then
                    Logger.DEFAULT:error("Inventory is full and there's no chest!");
                    return false;
                end
                local anchor = miner.movement:drop_anchor();
                miner.movement:return_to_anchor(chest_anchor);
                if not miner.inventory:drop_items() then
                    Logger.DEFAULT:error("Inventory is full and Chest is full!");
                    return false;
                end
                miner.movement:return_to_anchor(anchor);
            end
        end
        return true;
    end

    for step=1,params.distance do
        if not mine_wall() then
            break;
        end
        -- Place chest if we haven't already
        if chest_anchor == nil then
            local anchor = miner.movement:drop_anchor()
            miner.movement:rotate_to(Movement.Direction.RIGHT)
            for _=1,miner.radius-1 do
                miner.movement:forward()
            end
            local slot = nil;
            while slot == nil do
                slot = miner.inventory:find("minecraft:chest");
                if slot == nil then
                    Input.wait_for_key("Press any key once a chest has been inserted...")
                end
            end
            turtle.select(slot);
            turtle.place()
            chest_anchor = miner.movement:drop_anchor(true);
            miner.movement:return_to_anchor(anchor);
        end
        if step % 4 == 1 then
            Logger.DEFAULT:debug("Trying to place torch")
            local slot = miner.inventory:find("minecraft:torch");
            Logger.DEFAULT:debug("Maybe found torches @ slot %s", slot)
            if slot ~= nil then
                turtle.select(slot);
                local anchor = miner.movement:drop_anchor()
                miner.movement:rotate_to(Movement.Direction.LEFT)
                for _=1,miner.radius-1 do
                    miner.movement:forward()
                end
                for _=1,math.ceil(miner.radius/2) do
                    miner.movement:up()
                end
                turtle.place()
                miner.movement:return_to_anchor(anchor);
            end
        end
    end

    miner.movement:return_to_anchor(chest_anchor);
    repeat
        local dropped = turtle.drop()
    until dropped

    miner.movement:return_to_origin();
end

main(...)