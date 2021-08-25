
--relative coordinate system
posX = 0
posY = 0
posZ = 0
local facing = 1

local facingAdd = {{posX=1,posZ=0},
                   {posX=0,posZ=1},
                   {posX=-1,posZ=0},
                   {posX=0,posZ=-1}}

function forward()
    if not turtle.forward() then return false end
    
    posX = posX + facingAdd[facing].posX
    posZ = posZ + facingAdd[facing].posZ

    return true
end

function back()
    if not turtle.back() then return false end
    
    posX = posX - facingAdd[facing].posX
    posZ = posZ - facingAdd[facing].posZ

    return true
end

function up()
    if not turtle.up() then return false end
    
    posY = posY + 1
    return true
end

function down()
    if not turtle.down() then return false end
    
    posY = posY - 1
    return true
end

function turnRight()
    if not turtle.turnRight() then return false end
    
    facing = facing + 1
    if facing > 4 then facing = facing - 4 end
    return true
end

function turnLeft()
    if not turtle.turnLeft() then return false end
    
    facing = facing - 1
    if facing < 1 then facing = facing + 4 end
    return true
end