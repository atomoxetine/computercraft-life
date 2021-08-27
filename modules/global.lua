
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

function round(number)
    if number - math.floor(number) <= 0.5 then return math.floor(number)
    else return math.ceil(number) end
end




MIN_FUEL = 200

FUEL = {["minecraft:coal"] = 80,
        ["minecraft:charcoal"] = 80,
        ["minecraft:coal_block"] = 800,
        ["minecraft:spruce_planks"] = 15}

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
              ["computercraft:disk"] = 0,
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

local XX = nil
local TU = "computercraft:turtle_normal"
local IR = "minecraft:iron_ingot"
local CO = "computercraft:computer_normal"
local CH = "minecraft:chest"
local PL = "minecraft:spruce_planks"
local SO = "minecraft:stone"
local RE = "minecraft:redstone"
local GP = "minecraft:glass_pane"
local GL = "minecraft:glass"
local DD = "computercraft:disk_drive"
local DS = "computercraft:disk"
local PA = "minecraft:paper"
local SU = "minecraft:sugar_cane"
local DP = "minecraft:diamond_pickaxe"
local ST = "minecraft:stick"
local DI = "minecraft:diamond"
local CT = "minecraft:crafting_table"
local BU = "minecraft:bucket"
local WO = "minecraft:spruce_log"
local FU = "minecraft:furnace"
local CB = "minecraft:cobblestone"

local MT = "mining_turtle"
local CMT = "crafty_mining_turtle"

RECIPE = {
    [TU] = {{IR,IR,IR},
            {IR,CO,IR},
            {IR,CH,IR}, amount=1},

    [CH] = {{PL,PL,PL},
            {PL,XX,PL},
            {PL,PL,PL}, amount=1},

    [CO] = {{SO,SO,SO},
            {SO,RE,SO},
            {SO,GP,SO}, amount=1},

    [GP] = {{XX,XX,XX},
            {GL,GL,GL},
            {GL,GL,GL}, amount=16},

    [DD] = {{SO,SO,SO},
            {SO,RE,SO},
            {SO,RE,SO}, amount=1},

    [DS] = {{PA,RE,XX},
            {XX,XX,XX},
            {XX,XX,XX}, amount=1},

    [PA] = {{XX,XX,XX},
            {SU,SU,SU},
            {XX,XX,XX}, amount=3},

    [DP] = {{DI,DI,DI},
            {XX,ST,XX},
            {XX,ST,XX}, amount=1},

    [ST] = {{PL,XX,XX},
            {PL,XX,XX},
            {XX,XX,XX}, amount=4},

    [CT] = {{PL,PL,XX},
            {PL,PL,XX},
            {XX,XX,XX}, amount=1},

    [BU] = {{IR,XX,IR},
            {XX,IR,XX},
            {XX,XX,XX}, amount=1},

    [PL] = {{XX,XX,XX},
            {XX,WO,XX},
            {XX,XX,XX}, amount=4},

    [FU] = {{CB,CB,CB},
            {CB,XX,CB},
            {CB,CB,CB}, amount=1},

    [MT] = {{TU,DP,XX},
            {XX,XX,XX},
            {XX,XX,XX}, amount=1},
    
    [CMT]= {{TU,CT,XX},
            {XX,XX,XX},
            {XX,XX,XX}, amount=1}
    
}

FURNACE_RECIPE = {
    ["minecraft:stone"] = {{"minecraft:cobblestone"}, amount=1},
    ["minecraft:iron_ingot"] = {{"minecraft:iron_ore"}, amount=1},
    ["minecraft:charcoal"] = {{"minecraft:spruce_log"}, amount=1},
    ["minecraft:glass"] = {{"minecraft:sand"}, amount=1}
}