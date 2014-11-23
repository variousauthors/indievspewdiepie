-- Just an example to help

local controls = {
    select = {'k_return', 'j1_a'},
    up = {'k_up', 'k_w'},
    down = {'k_down', 'k_s'},
    left = {'k_left', 'k_a'},
    right = {'k_right', 'k_d'},
    gun = { 'm_l' }
}

love.inputman.setStateMap(controls)

function game.keypressed(key)

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

function game.keyreleased(key)

    if key == "d" then key = "right" end
    if key == "w" then key = "up" end
    if key == "s" then key = "down" end
    if key == "a" then key = "left" end

    -- player inputpressed
    if game.player.input[key] ~= nil then
        table.insert(game.player.input[key], false)
    end
end

function game.mousepressed (x, y, button)
    print("mousepressed")
    if button == "l" then button = "gun" end

    -- player inputpressed
    if game.player.input[button] ~= nil then
        table.insert(game.player.input[button], true)
    end
end

function game.mousereleased (x, y, button)
    print("mousereleased")
    if button == "l" then button = "gun" end

    -- player inputpressed
    if game.player.input[button] ~= nil then
        table.insert(game.player.input[button], false)
    end
end
