local sceneMan = {
    scenes = {}, -- All created scenes will be stored here.
    stack = {}, -- Scenes that are pushed will be stored here.
    shared = {}, -- Variables that are shared between scenes can be stored here
    buffer = {}, -- Used to store the scene stack when the original scene stack is disabled
    frozen = false, -- If true, the buffer will be used instead of the original stack
}

--- A helper funciton that returns either the buffer or the stack based on the value of menuMan.frozen.
-- @return (table) The buffer if the frozen flag is true, other the stack
local function getStack ()
    return (sceneMan.frozen == true) and sceneMan.buffer or sceneMan.stack
end

--- Redirects stack-altering operations into the buffer instead.
function sceneMan:freeze ()
    if self.frozen == false then
        self.buffer = {} -- Resets the buffer

        -- Copies the stack into the buffer
        for i = 1, #self.stack do
            self.buffer[i] = self.stack[i]
        end
        self.frozen = true
    end
end

--- Copies the changes from the buffer back into the original stack.
function sceneMan:unfreeze ()
    if self.frozen == true then
        self.stack = {} -- Resets the stack

        -- Copies the buffer back into the stack
        for i = 1, #self.buffer do
            self.stack[i] = self.buffer[i]
        end
        self.frozen = false
    end
end

--- Adds a new scene to Scene Man and initializes it via its load method.
-- This will call the scene's "load" method
-- @param name (string) The name of the new scene. This will be used later to push, insert, and remove this scene from the stack
-- @param scene (table) A table containing the scene's attributes and callback functions
-- @param ... (varargs) A series of values that will be passed to the scene's "load" callback
function sceneMan:newScene (name, scene, ...)
    self.scenes[name] = scene
    self.scenes[name].name = name
    if self.scenes[name].load ~= nil then
        self.scenes[name]:load (self, ...)
    end
end

--- Removes a scene from Scene Man and calls its delete method.
-- This will call the scene's "delete" method
-- If you try to push or insert a deleted scene, Scene Man will throw an error!
-- @param name (string) The name of the scene that should be deleted
-- @param ... (varargs) A series of values that will be passed to the scene's "delete" callback
function sceneMan:deleteScene (name, ...)
    if self.scenes[name] ~= nil then
        if self.scenes[name].delete ~= nil then
            self.scenes[name]:delete ()
        end
        self.scenes[name] = nil
    end
end

--- Returns the current size of the stack.
-- @return (int) The size of the stack
function sceneMan:getStackSize ()
    return #self.stack
end

--- Gives the name of the current scene. It will return nil is there are no scenes on the stack.
-- @return (string) The name of the scene at the top of the stack
function sceneMan:getCurrentScene ()
    return #self.stack >= 1 and self.stack[#self.stack].name or nil
end

--- Adds a scene from the scenes table onto the stack.
-- This will call the scene's "whenAdded" method
-- Scenes at the top of the stack will have their functions called last
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
-- @param ... (varargs) A list of values that will be passed to the event's "whenAdded" callback function
function sceneMan:push (name, ...)
    local stack = getStack ()
    
    if self.scenes[name] == nil then
        error ('Attempt to enter undefined scene "' .. name .. '"')
    end
    
    stack[#stack + 1] = self.scenes[name]
    if self.scenes[name].whenAdded ~= nil then
        self.scenes[name]:whenAdded (...)
    end
end

--- Pops a scene off of the stack.
-- This will call the topmost scene's "whenRemoved" method
-- @param ... (varargs) A list of values that will be passed to the event's "whenRemoved" callback function
function sceneMan:pop (...)
    local stack = getStack ()
    
    if #stack >= 1 then
        local temp = stack[#stack]
        stack[#stack] = nil
        if temp.whenRemoved ~= nil then
            temp:whenRemoved (...)
        end
    end
end

--- Adds a scene to the stack at a given index.
-- This will call the scene's "whenAdded" method
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
-- @param index (int) The position within the stack that the scene should be inserted at
-- @param ... (varargs) A list of values that will be passed to the event's "whenAdded" callback function
-- @return (bool) True if the operation was successful
function sceneMan:insert (name, index, ...)
    local stack = getStack ()
    
    if self.scenes[name] == nil then
        error ('Attempt to enter undefined scene "' .. name .. '"')
    end
    
    if index >= 1 and index <= #stack then
        table.insert (stack, index, name)
        if self.scenes[name].whenAdded ~= nil then
            self.scenes[name]:whenAdded (...)
        end
        return true
    end
    return false
end

--- Removes a scene from the stack at a certain index.
-- This will call the scene's "whenRemoved" method
-- @param index (int) The position within the stack that the scene should be removed at
-- @param ... (varargs) A list of values that will be passed to the event's "whenRemoved" callback function
-- @return (bool) True if the operation was successful
function sceneMan:remove (index, ...)
    local stack = getStack ()
    
    if index >= 1 and index <= #stack then
        local temp = stack[index]
        table.remove (stack, index)
        if temp.whenRemoved ~= nil then
            temp:whenRemoved (...)
        end
    end
end

--- Removes all scenes from the stack, starting at the top.
-- This will call all the scenes' "whenRemoved" methods, starting from the topmost scene
-- This will automatically freeze the stack until all scenes have been iterated over
-- @param ... (varargs) A list of values that will be passed to the event's "whenRemoved" callback function
function sceneMan:clearStack (...)
    local prefrozen = self.frozen
    self:freeze ()
    self.buffer = {}
    
    for i = #self.stack, 1, -1 do
        if self.stack[i].whenRemoved ~= nil then
            self.stack[i]:whenRemoved (...)
        end
    end

    if prefrozen == false then
        self:unfreeze ()
    end
end

--- Fires an event callback for all scenes on the stack.
-- This will automatically freeze the stack until all scenes have been iterated over
-- @param eventName (string) The name of the event
-- @param ... (varargs) A series of values that will be passed to the scenes' event callbacks
function sceneMan:event (eventName, ...)
    local prefrozen = self.frozen
    self:freeze ()

    for i = 1, #self.stack do
        local scene = self.stack[i]
        if scene[eventName] ~= nil then
            scene[eventName] (scene, ...)
        end
        if i >= #self.stack then
            break
        end
    end

    if prefrozen == false then
        self:unfreeze ()
    end
end

return sceneMan