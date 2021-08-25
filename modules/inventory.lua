require("modules.preparing")



Inventory = {
    --get slot from item name
    slot = {},
    leastFreeSlot = 1

}



function Inventory:dump(index)
    select(index)
    if not turtle.refuel() then turtle.dropDown() end
    select(1)
end



function Inventory:dumpTrash()
    --[[
    for name, idx in pairs(self.slot) do
        if not OBJECTIVES[name] then
            self:dump(idx)
        end
    end
    ]]--
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data and not OBJECTIVES[data.name] then
            self:dump(i)
        end
    end
    turtle.select(1)
end



function Inventory:sort()
    self.slot = {}
    self.leastFreeSlot = 1
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            if self.slot[data.name] then
                if data.name == "minecraft:water_bucket" then
                    turtle.transferTo(self.leastFreeSlot)
                    self.slot[data.name] = {self.slot[data.name], self.leastFreeSlot}
                    self.leastFreeSlot = self.leastFreeSlot + 1
                elseif not turtle.transferTo(self.slot[data.name]) then
                    self:dump(i)
                end
            else
                self.slot[data.name] = self.leastFreeSlot
                self.leastFreeSlot = self.leastFreeSlot + 1
                if i ~= self.slot[data.name] then turtle.transferTo(self.slot[data.name]) end
            end
        end
    end
    turtle.select(1)
end



function Inventory:cleanup()
    self:dumpTrash()
    self:sort()
end