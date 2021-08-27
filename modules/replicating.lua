require("modules.inventory")
require("modules.pos")
require("modules.global")

ReplicatingPhase = {

    CRAFT = {},

    platformX = nil,
    platformY = nil,
    platformZ = nil,
    platformDirection = nil,

    chestX = nil,
    chestY = nil,
    chestZ = nil
}

function ReplicatingPhase:new()
    local object = setmetatable({}, self)
    self.__index = self
    object.progress = setmetatable({}, {__index = function () return 0 end})
    return object
end

function ReplicatingPhase:run()
    goToPos(nil, 100 + round(math.random(-20, 20)), nil)

    Inventory.safeSort()

    self:craft("computercraft:turtle_normal")
    self:craft("minecraft:diamond_pickaxe")
    self:craft("mining_turtle")
    self:craft("minecraft:crafting_table")
    self:craft("crafty_mining_turtle")
    self:craft("computercraft:disk_drive")
    self:craft("computercraft:disk")
end







function ReplicatingPhase:buildPlatform()
    self.platformX = posX
    self.platformY = posY
    self.platformZ = posZ
    self.platformDirection = facing

    turtle.select(Inventory.slot["minecraft:cobblestone"][1])

    local b = false
    for i=1, 7, 1 do
        for j=1, 7, 1 do
            if i == 4 and j == 4 then
                turtle.select(Inventory.slot["minecraft:dirt"][1])
                turtle.placeDown()
                turtle.select(Inventory.slot["minecraft:cobblestone"][1])
            else
                turtle.placeDown()
            end
            
            if j < 7 then forward() end
        end
        if i == 7 then break end

        if b then turnRight() forward() turnRight()
        else turnLeft() forward() turnLeft() end
        b = not b
    end
end



function ReplicatingPhase:craft(item, amount)
    amount = amount or 1

    if Inventory.count[item] >= amount then return Inventory.slot[item][1] end
    
    while not Inventory.slot[item] do
        self.CRAFT[item](self, item, amount)
    end

    return Inventory.slot[item][1]
end



function ReplicatingPhase:getIngredients(item)
    local list = {}

    local recipe = RECIPE[item] or FURNACE_RECIPE[item]
    
    for i=1, 3, 1 do
        for j=1, 3, 1 do
            if recipe and recipe[i] and recipe[i][j] then
                if not list[recipe[i][j]] then
                    list[recipe[i][j]] = 1
                else
                    list[recipe[i][j]] = list[recipe[i][j]] + 1
                end
            end
        end
    end

    return list
end



--default crafting function
ReplicatingPhase.CRAFT = setmetatable({}, {
    __index = function (self, item, amount) return function (self, item, amount)

        amount = amount or 1

        print("CRAFT: " .. item .. " " .. amount)

        if RECIPE[item] then
            amount = math.ceil(amount/RECIPE[item].amount)
    
            local ingredients = self:getIngredients(item)
            for ingredient, count in pairs(ingredients) do
                print("next ingredient: " .. ingredient)
                self:craft(ingredient, count*amount)
            end

            if not self.chestX then

                goToPos(self.platformX, self.platformY+1, self.platformZ)

                self.chestX = posX
                self.chestY = posY - 1
                self.chestZ = posZ

                turtle.select(Inventory.slot["minecraft:cobblestone"][1])

                for i=1,4,1 do
                    forward()
                    turtle.placeDown()
                    back()
                    turnRight()
                end
            else
                goToPos(self.chestX, self.chestY+1, self.chestZ)
            end

            for _item, slots in pairs(Inventory.slot) do
                for i, slot in ipairs(slots) do
                    local data = turtle.getItemDetail(slot)
                    if data then
                        turtle.select(slot)
                        if not ingredients[data.name] then
                            turtle.dropDown()
                        else
                            turtle.dropDown(Inventory.count[data.name] - amount*ingredients[data.name])
                        end
                    end
                end
            end
            local slot = Inventory.craft(RECIPE[item], amount)

            local success = turtle.suckDown()
            while success do
                success = turtle.suckDown()
            end

            Inventory.safeSort()
            
            return slot

        elseif FURNACE_RECIPE[item] then
            local fuel

            local ingredient = FURNACE_RECIPE[item][1][1]
            if not Inventory.slot[ingredient] then self:craft(ingredient) end
            
            if Inventory.slot["minecraft:charcoal"] then fuel = "minecraft:charcoal"
            elseif Inventory.slot["minecraft:coal"] then fuel = "minecraft:coal"
            else fuel = "minecraft:spruce_planks" end

            self:craft("minecraft:spruce_planks", math.max(math.ceil(10*amount/FUEL[fuel]) - Inventory.count[fuel], 0))

            

            local slot = self:craft("minecraft:furnace")

            goToPos(self.platformX, self.platformY+2, self.platformZ)
            turtle.select(slot)
            turtle.placeDown()
            turtle.select(Inventory.slot[ingredient][1])
            turtle.dropDown(amount)
            forward()
            down()
            turnRight()
            turnRight()
            turtle.select(Inventory.slot[fuel][1])
            turtle.drop(math.ceil(10*amount/FUEL[fuel]))
            os.sleep(10*amount+1)
            turtle.dig()

            Inventory.safeSort()

            return Inventory.slot[item][1]

        end
    end
    end})




