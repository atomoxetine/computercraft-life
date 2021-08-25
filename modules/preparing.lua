
local MIN_FUEL = 1

local FUEL_GAIN = {}
FUEL_GAIN["minecraft:coal"] = 80
FUEL_GAIN["minecraft:charcoal"] = 80
FUEL_GAIN["minecraft:coal_block"] = 800

--relationship between needed resources and amount needed for replicating
OBJECTIVES = {}
OBJECTIVES["minecraft:cobblestone"] = 64
OBJECTIVES["minecraft:sand"] = 6
OBJECTIVES["minecraft:dirt"] = 2
OBJECTIVES["minecraft:iron_ore"] = 13
OBJECTIVES["minecraft:diamond"] = 3
OBJECTIVES["minecraft:water_bucket"] = 2
OBJECTIVES["minecraft:spruce_sapling"] = 1
OBJECTIVES["minecraft:sugar_cane"] = 1
OBJECTIVES["minecraft:redstone"] = 3
OBJECTIVES["minecraft:coal"] = 5
OBJECTIVES["minecraft:bone_meal"] = 0
OBJECTIVES["minecraft:spruce_log"] = 0
OBJECTIVES["minecraft:furnace"] = 0
OBJECTIVES["computercraft:disk_drive"] = 0
OBJECTIVES["computercraft:turtle_normal"] = 0
OBJECTIVES["computercraft:turtle_advanced"] = 0

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
ESSENTIALS = {}
ESSENTIALS["minecraft:water_bucket"] = 2
ESSENTIALS["minecraft:spruce_sapling"] = 1
ESSENTIALS["minecraft:sugar_cane"] = 1
ESSENTIALS["minecraft:coal"] = 5