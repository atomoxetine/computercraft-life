
Stack = {
    container = {},
    len = 0
}

function Stack:new()
    local stack = setmetatable({}, self)
    self.__index = self
    stack.container = {}
    return stack
end

function Stack:push(value)
    table.insert(self.container, value)
    self.len = self.len + 1
end

function Stack:pop()
    self.len = self.len - 1
    return table.remove(self.container, self.len+1)
end

function Stack:top()
    return self.container[self.len]
end

function Stack:size()
    return self.len
end

function Stack:empty()
    return self.len == 0
end