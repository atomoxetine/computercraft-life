require("modules.inventory")
require("modules.pos")
require("modules.global")

local TURN_PROBABILITY = 1/16
local hasDescended = false

PreparingPhase = {
    progress = setmetatable({}, {__index = function () return 0 end}),
    SOLVE = setmetatable({}, {__index = function () return PreparingPhase.SOLVE["minecraft:diamond"] end})
}

function PreparingPhase:new()
    local object = setmetatable({}, self)
    self.__index = self
    object.progress = setmetatable({}, {__index = function () return 0 end})
    return object
end

function PreparingPhase:run()
    math.randomseed(os.time() + os.clock())
    Inventory.cleanup()
    for i, objective in ipairs(OBJECTIVE_ORDER) do
        while self.progress[objective] < OBJECTIVES[objective] do
            autoRefuel()
            print("preparingphase.run")
            self.SOLVE[objective](self)
            self:updateProgress()
        end
    end
end



function PreparingPhase:updateProgress()
    self.progress = setmetatable({}, {__index = function () return 0 end})
    for item, slots in pairs(Inventory.slot) do
        local count = 0
        for i, slot in ipairs(slots) do
            local data = turtle.getItemDetail(slot)
            count = count + data.count
        end
        self.progress[item] = count
    end
end




function PreparingPhase:descend()
    local data = inspectDown()
    while data ~= "minecraft:bedrock" do
        if not down() then
            digDown()
            down()
        end
        data = inspectDown()
    end
    posY = 0
    for i=1, 5, 1 do
        if not up() then
            digUp()
            up()
        end
    end

    hasDescended = true
end

function PreparingPhase:mine()
    dig()
    forward()

    if math.random() <= TURN_PROBABILITY then
        --if math.random() <= 0.5 then turnRight()
        --else turnLeft() end
        turnRight()
    end
end




PreparingPhase.SOLVE["minecraft:diamond"] = function (self)
    if not hasDescended then
        self:descend()
    elseif posY > 10 then
        goToPos(nil, 10, nil)
    else
        self:mine()
    end
end

PreparingPhase.SOLVE["minecraft:redstone"] = PreparingPhase.SOLVE["minecraft:diamond"]
PreparingPhase.SOLVE["minecraft:iron_ore"] = PreparingPhase.SOLVE["minecraft:diamond"]
PreparingPhase.SOLVE["minecraft:cobblestone"] = PreparingPhase.SOLVE["minecraft:diamond"]
PreparingPhase.SOLVE["minecraft:dirt"] = PreparingPhase.SOLVE["minecraft:diamond"]

PreparingPhase.SOLVE["minecraft:sand"] = function (self)
    local data = inspectDown()

    if data == "minecraft:sand" or data == "minecraft:grass_block" then
        digDown()
        dig()
        forward()
    elseif not hasDescended then
        self:descend()
    elseif posY < 40 then
        local data = inspect()
        while data ~= "minecraft:sand" and posY < 85 do
            digUp()
            turtle.suckUp()
            Inventory.instantCleanup()
            up()
        end
    else
        local data = inspectDown()
        while (data ~= "minecraft:sand" or data ~= "minecraft:grass_block") and posY > 40 do
            down()
        end
    end
end