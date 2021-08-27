ReplicatingPhase = {}

function ReplicatingPhase:new()
    object = setmetatable({}, self)
    self.__index = self
    return object
end

function ReplicatingPhase:run()
    
end