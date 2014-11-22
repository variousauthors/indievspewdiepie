-- Set-up global Input objects.
love.inputman = require('libs/inputman').newSingleton()

-- Screw the literally zillions of input callbacks, we're going to use two
-- custom events instead.
--
function love.inputpressed(state)
    love.debug.printIf('input', 'pressed:', state)

    -- player inputpressed
    game.player[state] = true

    -- An example of input/sound
    if(state == 'select') then love.soundman.run('select') end
end

function love.inputreleased(state)
    love.debug.printIf('input', 'released:', state)

    -- player inputreleased
    game.player[state] = false
end

-- Maybe we want to use keypressed as well for a few global
--
function love.keypressed(key)
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

function love.joystickadded(j)
    love.inputman.updateJoysticks()
end

function love.joystickremoved(j)
    love.inputman.updateJoysticks()
end
