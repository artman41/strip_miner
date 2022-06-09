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

    for _=1,5 do
        if not miner:mine_wall() then
            Logger.error("Failed to mine wall!")
            break
        end
    end

    miner.movement:return_to_origin();
end

main(...)