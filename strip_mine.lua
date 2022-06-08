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

require("strip_miner.objects.miner")

function main(...)
    local miner = Miner.new(2)

    if miner:should_setup() then
        miner:setup()
    end

    print(string.format("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring()))
    for _, value in ipairs(arg) do
        if value == "f" then
            miner.movement:forward();
        elseif value == "b" then
            miner.movement:back();
        elseif value == "l" then
            miner.movement:left();
        elseif value == "r" then
            miner.movement:right();
        elseif value == "u" then
            miner.movement:up();
        elseif value == "d" then
            miner.movement:down();
        end
    end
    print(string.format("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring()))
    miner.movement:return_to_origin();
    print(string.format("o: %s, c: %s", miner.movement.pos_origin:tostring(), miner.movement.pos_current:tostring()))
end

main(...)