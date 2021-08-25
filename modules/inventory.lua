require("modules.preparing")

local ALLOW_DUPLICATES = {}
ALLOW_DUPLICATES["minecraft:water_bucket"] = true

Inventory = {
    --get slot(s) from item name
    slot = {},
    leastFreeSlot = 1

}



function Inventory:dump(index)
    select(index)
    if not turtle.refuel() then turtle.dropDown() end
end



function Inventory:dumpTrash()
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data and not OBJECTIVES[data.name] then
            self:dump(i)
        end
    end
end



function Inventory:sort()
    self.slot = {}
    self.leastFreeSlot = 1
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            if self.slot[data.name] then
                if not turtle.transferTo(self.slot[data.name][1]) then
                    if ALLOW_DUPLICATES[data.name] then
                        turtle.transferTo(self.leastFreeSlot)
                        table.insert(self.slot[data.name], self.leastFreeSlot)
                        self.leastFreeSlot = self.leastFreeSlot + 1
                    else
                        self:dump(i)
                    end
                end
            else

                self.slot[data.name] = {self.leastFreeSlot}
                self.leastFreeSlot = self.leastFreeSlot + 1
                if i ~= self.slot[data.name][1] then turtle.transferTo(self.slot[data.name][1]) end
            end
        end
    end
end



function Inventory:cleanup()
    self:dumpTrash()
    self:sort()
    turtle.select(math.min(self.leastFreeSlot, 16))
end



function Inventory:fastCleanup()
    self.slot = {}
    self.leastFreeSlot = 17
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data and OBJECTIVES[data.name] then
            if self.slot[data.name] then
                if not turtle.transferTo(self.slot[data.name][1]) then
                    if ALLOW_DUPLICATES[data.name] then
                        table.insert(self.slot[data.name], i)
                    else
                        self:dump(i)
                        self.leastFreeSlot = math.min(self.leastFreeSlot, i)
                    end
                else
                    self.leastFreeSlot = math.min(self.leastFreeSlot, i)
                end
            else
                self.slot[data.name] = {i}
            end
        else
            if data then self:dump(i) end
            self.leastFreeSlot = math.min(self.leastFreeSlot, i)
        end
    end
    turtle.select(math.min(self.leastFreeSlot, 16))
end
