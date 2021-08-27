require("modules.inventory")
require("modules.pos")
require("modules.global")
require("libraries.stack")

local TURN_PROBABILITY = 1/16
local hasDescended = false

PreparingPhase = {
    progress = setmetatable({}, {__index = function () return 0 end}),
    SOLVE = setmetatable({}, {__index = function () return PreparingPhase.SOLVE["minecraft:diamond"] end}),
    lastCleanupTime = 0
}

function PreparingPhase:new()
    local object = setmetatable({}, self)
    self.__index = self
    self.lastCleanupTime = os.clock()
    object.progress = setmetatable({}, {__index = function () return 0 end})
    return object
end

function PreparingPhase:run()
    math.randomseed(os.time() + os.clock())
    Inventory.cleanup()
    self:updateProgress()
    for i, objective in ipairs(OBJECTIVE_ORDER) do
        while self.progress[objective] < OBJECTIVES[objective] do
            autoRefuel()
            self.SOLVE[objective](self)
            if os.clock() - self.lastCleanupTime >= 10 then
                Inventory.cleanup()
                self.lastCleanupTime = os.clock()
            end
            self:updateProgress()
        end
    end
end



function PreparingPhase:updateProgress()
    self.progress = setmetatable({}, {__index = function () return 0 end})
    for item, slots in pairs(Inventory.slot) do
        if OBJECTIVES[item] then
            local count = 0
            for i, slot in ipairs(slots) do
                local data = turtle.getItemDetail(slot)
                count = count + data.count
            end
            self.progress[item] = count
        end
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
    local initialFacing = facing
    local initialX = posX
    local initialY = posY
    local initialZ = posZ
    self:mineVein()
    goToPos(initialX, initialY, initialZ)
    turnTo(initialFacing)
    dig()
    forward()

    if math.random() <= TURN_PROBABILITY then
        --if math.random() <= 0.5 then turnRight()
        --else turnLeft() end
        turnRight()
    end
end



function PreparingPhase:mineVein()
    local verified = setmetatable({}, {__index = function () return false end})
    local available = Stack:new()

    available:push({posX, posY, posZ})

    while not available:empty() do
        local crr, key

        repeat
            crr = available:pop()
            key = tostring(crr[1]) .. ";" .. tostring(crr[2]) .. ";" .. tostring(crr[3])
        until available:empty() or not verified[key]

        if verified[key] then break end

        goToPos(crr[1], crr[2], crr[3])
        
        verified[key] = true


        local entries = {}

        for i=1, 4, 1 do
            local k = {}
            k.block = inspect()
            k.item = ORE_TO_ITEM[k.block]
            k.x = posX + FACING_ADD[facing].x
            k.y = posY
            k.z = posZ + FACING_ADD[facing].z
            k.key = tostring(k.x) .. ";" .. tostring(k.y) .. ";" .. tostring(k.z)
            table.insert(entries, k)

            if i ~= 4 then turnRight() end
        end

        local k = {}
        k.block = inspectUp()
        k.item = ORE_TO_ITEM[k.block]
        k.x = posX
        k.y = posY + 1
        k.z = posZ
        k.key = tostring(k.x) .. ";" .. tostring(k.y) .. ";" .. tostring(k.z)
        table.insert(entries, k)

        local k = {}
        k.block = inspectDown()
        k.item = ORE_TO_ITEM[k.block]
        k.x = posX
        k.y = posY - 1
        k.z = posZ
        k.key = tostring(k.x) .. ";" .. tostring(k.y) .. ";" .. tostring(k.z)
        table.insert(entries, k)

        for i, k in ipairs(entries) do
            if VEIN[k.block] and not verified[k.key] then
                if Inventory.count[k.item] < 64 or (Inventory.count[k.item] >= 64 and ALLOW_DUPLICATES[k.item]) then
                    available:push({k.x, k.y, k.z})
                end
            end
        end
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


PreparingPhase.SOLVE["minecraft:sand"] = function (self)
    local data = inspect()

    if data == "minecraft:sand" or data == "minecraft:grass_block" then
        dig()
        forward()
    elseif not hasDescended then
        self:descend()
    elseif posY < 40 then
        data = inspect()
        while data ~= "minecraft:sand" and posY < 85 do
            digUp()
            turtle.suckUp()
            Inventory.instantCleanup()
            up()
            data = inspect()
        end
    else
        data = inspectDown()
        while data == "minecraft:air" do
            down()
            data = inspectDown()
        end
        digDown()
        down()
    end
end