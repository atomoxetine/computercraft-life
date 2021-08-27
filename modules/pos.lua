require("modules.global")

--relative coordinate system
posX = 0
posY = 0
posZ = 0
facing = 1

FACING_ADD = {{x=1,z=0},
              {x=0,z=1},
              {x=-1,z=0},
              {x=0,z=-1}}

function forward()
    if not turtle.forward() then return false end
    
    posX = posX + FACING_ADD[facing].x
    posZ = posZ + FACING_ADD[facing].z

    return true
end

function back()
    if not turtle.back() then return false end
    
    posX = posX - FACING_ADD[facing].x
    posZ = posZ - FACING_ADD[facing].z

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
    if not direction then return end
    
    local diff = direction - facing
    if diff > 2 then diff = -1
    elseif diff < -2 then diff = 1 end
    
    for i=1, math.abs(diff), 1 do
        if diff > 0 then turnRight()
        elseif diff < 0 then turnLeft() end
    end
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
    if extractSign(deltaX) == -1 then directionX = 3 end

    local directionZ = 2
    if extractSign(deltaZ) == -1 then directionZ = 4 end

    for i=1, math.abs(deltaY), 1 do
        if deltaY > 0 then
            while not up() do digUp() end
        elseif deltaY < 0 then
            while not down() do digDown() end
        end
    end

    if deltaX ~= 0 then turnTo(directionX)
        for i=1, math.abs(deltaX), 1 do
            while not forward() do dig() end
        end
    end

    if deltaZ ~= 0 then turnTo(directionZ)
        for i=1, math.abs(deltaZ), 1 do
            while not forward() do dig() end
        end
    end
end