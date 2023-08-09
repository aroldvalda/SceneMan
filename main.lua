local sceneMan = require ("sceneMan")

function love.load ()
    local initialRectW = 300 -- Initial size of the gameplay rectangle

	sceneMan:newScene ("game", require ("gameScene"), initialRectW) -- Here we pass the initial rectangle width into the scene
	sceneMan:newScene ("menu", require ("menuScene")) -- This scene doesn't need any extra values, so we don't pass anything

    -- This is where the fun begins!
    sceneMan:push ("game")
    sceneMan:push ("menu")
end

function love.update (dt)
	-- We pass dt from love.update into each scene
	sceneMan:event ("update", dt)
end

function love.draw ()
    local rng = math.random ()
    
    -- We can pass any values we desire into these events
    sceneMan:event ("draw", rng)
end

function love.keypressed (key)
	-- The event name can also be anything we want, so long as we use the same name inside the scenes we define
	sceneMan:event ("key", key)
end