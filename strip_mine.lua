--[[

!!GOALS

- Strip Mine
- Auto Torch
- Return to Chest + Dump Inv
- Refuel

- Setup with just a chest, coal & torches in inv

!! OPTIONALS

- Crafting Torches (probably useless)
- 

--]]

require("utils.require")
require("objects.miner")
require("utils.logger")

Logger.DEFAULT = Logger:new({loglevel = "debug", file = "/strip_miner/strip_mine.log"})

function main(...)
    local miner = Miner:new(2)

    miner:setup()

    Logger.DEFAULT:debug("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring())
    -- for _, value in ipairs(arg) do
    --     if value == "f" then
    --         miner.movement:forward();
    --     elseif value == "b" then
    --         miner.movement:back();
    --     elseif value == "l" then
    --         miner.movement:left();
    --     elseif value == "r" then
    --         miner.movement:right();
    --     elseif value == "u" then
    --         miner.movement:up();
    --     elseif value == "d" then
    --         miner.movement:down();
    --     end
    -- end
    -- Logger.DEFAULT:debug("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring())

    for _=1,5 do
        if not miner:mine_wall() then
            Logger.error("Failed to mine wall!")
            break
        end
    end

    miner.movement:return_to_origin();
    Logger.DEFAULT:debug("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring())
end

main(...)