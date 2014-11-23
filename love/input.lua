-- Set-up global Input objects.
love.inputman = require('libs/inputman').newSingleton()

-- Screw the literally zillions of input callbacks, we're going to use two
-- custom events instead.
--
--  function love.inputpressed(state)
--      love.debug.printIf('input', 'pressed:', state)

--      -- player inputpressed
--      table.insert(game.player.input[state], true)

--      -- An example of input/sound
--      if(state == 'select') then love.soundman.run('select') end
--  end

--  function love.inputreleased(state)
--      love.debug.printIf('input', 'released:', state)

--      -- player inputreleased
--      table.insert(game.player.input[state], false)
--  end

-- Maybe we want to use keypressed as well for a few global
--
function love.keypressed(key)

    if key == "d" then key = "right" end
    if key == "w" then key = "up" end
    if key == "s" then key = "down" end
    if key == "a" then key = "left" end

    -- player inputpressed
    if game.player.input[key] ~= nil then
        table.insert(game.player.input[key], true)
    end

    if(key == 'f10' or key == 'escape') then
        love.event.quit()
    elseif(key == 'f11') then
        love.viewport.setFullscreen()
        love.viewport.setupScreen()
    elseif(key == 'f12') then
        love.inputman.threadStatus()
        love.soundman.threadStatus()
    end
end

function love.keyreleased(key)

    if key == "d" then key = "right" end
    if key == "w" then key = "up" end
    if key == "s" then key = "down" end
    if key == "a" then key = "left" end

    -- player inputpressed
    if game.player.input[key] ~= nil then
        table.insert(game.player.input[key], false)
    end
end

function love.mousepressed (x, y, button)
    if button == "l" then button = "gun" end

    -- player inputpressed
    if game.player.input[button] ~= nil then
        table.insert(game.player.input[button], true)
    end
end

function love.mousereleased (x, y, button)
    if button == "l" then button = "gun" end

    -- player inputpressed
    if game.player.input[button] ~= nil then
        table.insert(game.player.input[button], false)
    end
end

function love.joystickadded(j)
    love.inputman.updateJoysticks()
end

function love.joystickremoved(j)
    love.inputman.updateJoysticks()
end
