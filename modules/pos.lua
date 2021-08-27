
--relative coordinate system
posX = 0
posY = 0
posZ = 0
local facing = 1

local facingAdd = {{x=1,z=0},
                   {x=0,z=1},
                   {x=-1,z=0},
                   {x=0,z=-1}}

function forward()
    if not turtle.forward() then return false end
    
    posX = posX + facingAdd[facing].x
    posZ = posZ + facingAdd[facing].z

    return true
end

function back()
    if not turtle.back() then return false end
    
    posX = posX - facingAdd[facing].x
    posZ = posZ - facingAdd[facing].z

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

function turnTo(direction)
    local diff = direction - facing
    if math.abs(direction + 4 - facing) < math.abs(diff) then diff = direction + 4 - facing end
    if diff > 0 then for i=1, diff, 1 do turnRight() end
    else for i=1, -diff, 1 do turnLeft() end end
end


--manhattan distance
function goToPos(x, y, z)
    x = x or posX
    y = y or posY
    z = z or posZ

    local deltaX = x - posX
    local deltaY = y - posY
    local deltaZ = z - posZ

    local directionX = 1
    if extractSign(deltaX) == -1 then directionX = 3
    else directionX = nil end

    local directionZ = 2
    if extractSign(deltaZ) == -1 then directionZ = 4
    else directionZ = nil end

    if deltaY > 0 then
        for i=1, deltaY, 1 do
            while not up() do turtle.digUp() end
        end
    else
        for i=1, -deltaY, 1 do
            while not down() do turtle.digDown() end
        end
    end

    turnTo(directionX)
    for i=1, math.abs(deltaX), 1 do
        while not forward() do turtle.dig() end
    end

    turnTo(directionZ)
    for i=1, math.abs(deltaZ), 1 do
        while not forward() do turtle.dig() end
    end
end