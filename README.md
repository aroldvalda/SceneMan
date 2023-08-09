## SceneMan

Scene Man is a simple and lightweight scene/gamestate manager! (No relation to [lucassardois/sceneman](https://github.com/lucassardois/sceneman))

It is useful for separating your game into distinct “screens” that are stored in separate files. It can also be used to easily separate game logic from GUI logic. Below are some examples that demonstrate how Scene Man can be used.

### Features:

*   Stack-based: Multiple scenes can be layered over one another at the same time. Scenes can also pop and push other scenes onto the stack at any time
*   Extremely flexible: custom callbacks are trivial to define and can be used in any situation (updating, drawing, detecting mouse clicks, etc)
*   Small size: The entire system is less than 200 lines long. It should take up next to no space inside your projects
*   Portable: Works in any Lua-based frameworks or game engines

### Usage:

See the [Example](https://github.com/KINGTUT10101/SceneMan/wiki/Example) page on the wiki.

### Documentation:

#### Storage tables:

```lua
sceneMan.scenes = {}, -- All created scenes will be stored here.
sceneMan.stack = {}, -- Scenes that are pushed will be stored here.
sceneMan.shared = {}, -- Variables that are shared between scenes can be stored here
```

#### Methods:

```lua
--- Adds a new scene to Scene Man and initializes it via its load method.
-- This will call the scene's "load" method
-- @param name (string) The name of the new scene. This will be used later to push, insert, and remove this scene from the stack
-- @param scene (table) A table containing the scene's attributes and callback functions
-- @param ... (varargs) A series of values that will be passed to the scene's "load" callback
sceneMan:newScene (name, scene, ...)

--- Removes a scene from Scene Man and calls its delete method.
-- This will call the scene's "delete" method
-- If you try to push or insert a deleted scene, Scene Man will throw an error!
-- @param name (string) The name of the scene that should be deleted
-- @param ... (varargs) A series of values that will be passed to the scene's "delete" callback
sceneMan:deleteScene (name)

--- Returns the current size of the stack.
-- @return (int) The size of the stack
sceneMan:getStackSize ()

--- Gives the name of the current scene. It will return nil is there are no scenes on the stack.
-- @return (string) The name of the scene at the top of the stack
sceneMan:getCurrentScene ()

--- Adds a scene from the scenes table onto the stack.
-- This will call the scene's "whenAdded" method
-- Scenes at the top of the stack will have their functions called last
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
sceneMan:push (name)

--- Pops a scene off of the stack.
-- This will call the topmost scene's "whenRemoved" method
sceneMan:pop ()

--- Adds a scene to the stack at a given index.
-- This will call the scene's "whenAdded" method
-- @raise When the given scene name isn't registered inside Scene Man
-- @param name (string) The name of the scene to add to the top of the stack
-- @param index (int) The position within the stack that the scene should be inserted at
-- @return (bool) True if the operation was successful
sceneMan:insert (name, index)

--- Removes a scene from the stack at a certain index.
-- This will call the scene's "whenRemoved" method
-- @param index (int) The position within the stack that the scene should be removed at
-- @return (bool) True if the operation was successful
sceneMan:remove (index)

--- Removes all scenes from the stack.
-- This will call all the scenes' "whenRemoved" methods, starting from the topmost scene
sceneMan:clearStack ()

--- Fires an event callback for all scenes on the stack.
-- @param eventName (string) The name of the event
-- @param ... (varargs) A series of values that will be passed to the scenes' event callbacks
sceneMan:event (eventName, ...)
```
