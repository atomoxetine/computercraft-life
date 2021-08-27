require("modules.global")



Inventory = {
    --get slot(s) from item name
    slot = {},
    leastFreeSlot = 1,
    --get count from item name
    count = setmetatable({}, {__index = function () return 0 end})
}



function Inventory.dump(slot)
    turtle.select(slot)
    if not turtle.refuel() then turtle.dropDown() end
end



function Inventory.dumpTrash()
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data and not OBJECTIVES[data.name] then
            Inventory.dump(i)
        end
    end
    turtle.select(1)
end



function Inventory.sort()
    Inventory.slot = {}
    Inventory.leastFreeSlot = 1
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            if Inventory.slot[data.name] then
                if not turtle.transferTo(Inventory.slot[data.name][1]) then
                    if ALLOW_DUPLICATES[data.name] then
                        turtle.transferTo(Inventory.leastFreeSlot)
                        table.insert(Inventory.slot[data.name], Inventory.leastFreeSlot)
                        Inventory.leastFreeSlot = Inventory.leastFreeSlot + 1
                    else
                        Inventory.dump(i)
                    end
                end
            else

                Inventory.slot[data.name] = {Inventory.leastFreeSlot}
                Inventory.leastFreeSlot = Inventory.leastFreeSlot + 1
                if i ~= Inventory.slot[data.name][1] then turtle.transferTo(Inventory.slot[data.name][1]) end
            end
        end
    end
    turtle.select(1)
end


function Inventory.cleanup()
    Inventory.dumpTrash()
    Inventory.sort()
    if Inventory.leastFreeSlot >= 17 then
        Inventory.freeStorage()
        Inventory.sort()
    end
    Inventory.recount()
    turtle.select(1)
end


--deprecated
function Inventory.fastCleanup()
    Inventory.slot = {}
    Inventory.leastFreeSlot = 17
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data and OBJECTIVES[data.name] then
            if Inventory.slot[data.name] then
                if not turtle.transferTo(Inventory.slot[data.name][1]) then
                    if ALLOW_DUPLICATES[data.name] then
                        table.insert(Inventory.slot[data.name], i)
                    else
                        Inventory.dump(i)
                        Inventory.leastFreeSlot = math.min(Inventory.leastFreeSlot, i)
                    end
                else
                    Inventory.leastFreeSlot = math.min(Inventory.leastFreeSlot, i)
                end
            else
                Inventory.slot[data.name] = {i}
            end
        else
            if data then Inventory.dump(i) end
            Inventory.leastFreeSlot = math.min(Inventory.leastFreeSlot, i)
        end
    end
    turtle.select(1)
    Inventory.recount()
end



function Inventory.refuel()
    Inventory.dumpTrash()
    while turtle.getFuelLevel() < MIN_FUEL do
        local success = false
        for fuel, amount in pairs(FUEL) do
            if Inventory.slot[fuel] and Inventory.slot[fuel][1] then
                turtle.select(Inventory.slot[fuel][1])
                success = success or turtle.refuel(math.ceil((MIN_FUEL - turtle.getFuelLevel())/FUEL[fuel]))
                if success then break end
            end
        end
        if not success then
            print("OUT OF FUEL")
            break
        end
    end
    turtle.select(1)
end


--meant to be called only if inventory is completely full
function Inventory.freeStorage()
    for item, slot in pairs(Inventory.slot) do
        if OBJECTIVES[item] == 0 then
            Inventory.dump(slot)
            break
        end
    end
end


--[[
How it works:

after calling Inventory.cleanup(), every essential item will be
among slots 1 and leastFreeSlot-1, inclusive, so if an unidentified item
enters the turtle inventory from mining, it will be at exactly leastFreeSlot,
considering that the turtle has slot 1 selected, so instantCleanup() only checks
if leastFreeSlot has something important and calls Inventory.dump() or updates
Inventory.slot

]]--
function Inventory.instantCleanup()
    local item = turtle.getItemDetail(Inventory.leastFreeSlot)
    if item then
        if OBJECTIVES[item.name] then
            if Inventory.slot[item.name] and not ALLOW_DUPLICATES[item.name] then 
                Inventory.dump(Inventory.leastFreeSlot)
            else
                if not Inventory.slot[item.name] then Inventory.slot[item.name] = {} end
                table.insert(Inventory.slot[item.name], Inventory.leastFreeSlot)
                Inventory.leastFreeSlot = Inventory.leastFreeSlot + 1
            end
        else Inventory.dump(Inventory.leastFreeSlot) end
    end

    if Inventory.leastFreeSlot >= 17 then Inventory.cleanup() end
    turtle.select(1)
end



function Inventory.recount()
    Inventory.count = setmetatable({}, {__index = function () return 0 end})
    
    for item, slots in pairs(Inventory.slot) do
        for i, slot in ipairs(slots) do
            local data = turtle.getItemDetail(slot)
            if data then Inventory.count[item] = Inventory.count[item] + data.count end
        end
    end
end



--uses 13 as default buffer
function Inventory.switch(slot1, slot2, amount)
    local buffer = 13

    if not (turtle.getItemDetail(slot1) and turtle.getItemDetail(slot2)) then
        if turtle.getItemDetail(slot1) then
            turtle.select(slot1)
            turtle.transferTo(slot2, amount)
        elseif turtle.getItemDetail(slot2) then
            turtle.select(slot2)
            turtle.transferTo(slot2, amount)
        end
    else

        turtle.select(slot1)
        turtle.transferTo(buffer)
        turtle.select(slot2)
        turtle.transferTo(slot1)
        turtle.select(buffer)
        turtle.transferTo(slot2)

    end
end

function Inventory.craft(recipe, amount)
    Inventory.safeSort()
    for i=3, 1, -1 do
        for j=3, 1, -1 do
            if recipe[i][j] then
                Inventory.switch(Inventory.slot[recipe[i][j]][1], 1 + 4*i + j, amount)
            end
        end
    end
    turtle.select(1)
    turtle.craft()
    return 1
end




function Inventory.safeSort()
    Inventory.slot = {}
    Inventory.leastFreeSlot = 1
    for i=1, 16, 1 do
        turtle.select(i)
        local data = turtle.getItemDetail()
        if data then
            if Inventory.slot[data.name] then
                if not turtle.transferTo(Inventory.slot[data.name][1]) then
                    turtle.transferTo(Inventory.leastFreeSlot)
                    table.insert(Inventory.slot[data.name], Inventory.leastFreeSlot)
                    Inventory.leastFreeSlot = Inventory.leastFreeSlot + 1
                end
            else

                Inventory.slot[data.name] = {Inventory.leastFreeSlot}
                Inventory.leastFreeSlot = Inventory.leastFreeSlot + 1
                if i ~= Inventory.slot[data.name][1] then turtle.transferTo(Inventory.slot[data.name][1]) end
            end
        end
    end
    turtle.select(1)
    Inventory.recount()
end