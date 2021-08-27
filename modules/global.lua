
MIN_FUEL = 200

FUEL = {["minecraft:coal"] = 80,
             ["minecraft:charcoal"] = 80,
             ["minecraft:coal_block"] = 800}

VEIN = {["minecraft:coal_ore"]=true,
       ["minecraft:diamond_ore"]=true,
       ["minecraft:iron_ore"]=true,
       ["minecraft:redstone_ore"]=true,
       ["minecraft:dirt"]=true}

ORE_TO_ITEM = {
    ["minecraft:coal_ore"] = "minecraft:coal",
    ["minecraft:diamond_ore"] = "minecraft:diamond",
    ["minecraft:redstone_ore"] = "minecraft:redstone"}

setmetatable(ORE_TO_ITEM, {__index = function (table, key) return key end })

ALLOW_DUPLICATES = {["minecraft:water_bucket"] = true}
setmetatable(ALLOW_DUPLICATES, {__index = function () return false end})

--relationship between needed resources and amount needed for replicating
OBJECTIVES = {["minecraft:cobblestone"] = 64,
              ["minecraft:redstone"] = 3,
              ["minecraft:dirt"] = 1,
              ["minecraft:iron_ore"] = 13,
              ["minecraft:diamond"] = 3,
              ["minecraft:water_bucket"] = 2,
              ["minecraft:spruce_sapling"] = 1,
              ["minecraft:sugar_cane"] = 1,
              ["minecraft:sand"] = 6,
              ["minecraft:coal"] = 0,
              ["minecraft:bone_meal"] = 0,
              ["minecraft:spruce_log"] = 0,
              ["minecraft:furnace"] = 0,
              ["computercraft:disk_drive"] = 0,
              ["computercraft:turtle_normal"] = 0,
              ["computercraft:turtle_advanced"] = 0}

OBJECTIVE_ORDER = {"minecraft:diamond",
                   "minecraft:redstone",
                   "minecraft:iron_ore",
                   "minecraft:cobblestone",
                   "minecraft:dirt",
                   "minecraft:sand",
                   "minecraft:spruce_sapling",
                   "minecraft:sugar_cane",
                   "minecraft:water_bucket"
                   }

--[[
    explaination:

    cobblestone: nest structure
    sand: making glass to craft computers
    dirt: growing trees and sugar canes
    iron: crafting turtles and a bucket
    diamond: crafting pickaxes to craft mining turtles
    water bucket: growing sugar canes and making more water buckets
    spruce sapling: growing trees to make pickaxes, chests and fuel
    sugar cane: making paper to craft floppy disks
    redstone: crafting computers and disk drives
    coal: initial fuel for new turtle

    everything with 0 value are not essential, but are useful

]]--


--relationship between initial resources and amount needed for a new turtle
ESSENTIALS = {["minecraft:water_bucket"] = 2,
              ["minecraft:spruce_sapling"] = 1,
              ["minecraft:sugar_cane"] = 1,
              ["minecraft:coal"] = 5}




function wait(seconds)
    local initial = os.clock()
    while os.clock() - initial < seconds do end
end

function extractSign(number)
    if type(number) ~= "number" then return nil end
    
    if number < 0 then return -1
    elseif number > 0 then return 1
    else return 0 end
end

function autoRefuel()
    if turtle.getFuelLevel() < MIN_FUEL then Inventory.refuel() end
end

function inspect()
    local success, data = turtle.inspect()
    if success then return data.name
    else return "minecraft:air" end
end

function inspectDown()
    local success, data = turtle.inspectDown()
    if success then return data.name
    else return "minecraft:air" end
end

function inspectUp()
    local success, data = turtle.inspectUp()
    if success then return data.name
    else return "minecraft:air" end
end

function dig()
    local result = turtle.dig()
    if result then Inventory.instantCleanup() Inventory.recount() return true
    else return false end
end

function digUp()
    local result = turtle.digUp()
    if result then Inventory.instantCleanup() Inventory.recount() return true
    else return false end
end

function digDown()
    local result = turtle.digDown()
    if result then Inventory.instantCleanup() Inventory.recount() return true
    else return false end
end