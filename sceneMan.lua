local sceneMan = {
    scenes = {}, -- All created scenes will be stored here.
    stack = {}, -- Scenes that are pushed will be stored here.
    shared = {}, -- Variables that are shared between scenes can be stored here
}

--- Adds a new scene to Scene Man and initializes it via its load method.
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
-- If you try to push or insert a deleted scene, Scene Man will throw an error!
-- @param name (string) The name of the scene that should be deleted
function sceneMan:deleteScene (name)
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
-- Scenes at the top of the stack will have their functions called last
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
function sceneMan:push (name)
    if self.scenes[name] == nil then
        error ('Attempt to enter undefined scene "' .. name .. '"')
    end
    
    self.stack[#self.stack + 1] = self.scenes[name]
    if self.scenes[name].whenAdded ~= nil then
        self.scenes[name]:whenAdded ()
    end
end

--- Pops a scene off of the stack.
function sceneMan:pop ()
    if #self.stack >= 1 then
        local temp = self.stack[#self.stack]
        self.stack[#self.stack] = nil
        if temp.whenRemoved ~= nil then
            temp:whenRemoved ()
        end
    end
end

--- Removes all scenes from the stack.
function sceneMan:clearStack ()
    self.stack = {}
end

--- Adds a scene to the stack at a given index.
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
-- @param index (int) The position within the stack that the scene should be inserted at
-- @return (bool) True if the operation was successful
function sceneMan:insert (name, index)
    if self.scenes[name] == nil then
        error ('Attempt to enter undefined scene "' .. name .. '"')
    end
    
    if index >= 1 and index <= #self.stack then
        table.insert (self.stack, index, name)
        if self.scenes[name].whenAdded ~= nil then
            self.scenes[name]:whenAdded ()
        end
        return true
    end
    return false
end

--- Removes a scene from the stack at a certain index.
-- @param index (int) The position within the stack that the scene should be removed at
-- @return (bool) True if the operation was successful
function sceneMan:remove (index)
    if index >= 1 and index <= #self.stack then
        local temp = self.stack[index]
        table.remove (self.stack, index)
        if temp.whenRemoved ~= nil then
            temp.whenRemoved ()
        end
    end
end

--- Fires an event callback for all scene on the stack.
-- @param eventName (string) The name of the event
-- @param ... (varargs) A series of values that will be passed to the scenes' event callbacks
function sceneMan:event (eventName, ...)
    for i = 1, #self.stack do
        local scene = self.stack[i]
        if scene[eventName] ~= nil then
            scene[eventName] (scene, ...)
        end
        if i >= #self.stack then
            break
        end
    end
end

return sceneMan