love.viewport = require('libs/viewport').newSingleton()

function love.draw()
    local player = game.player

    -- translate everything so the camera is centered on the player
    love.graphics.translate(game.camera.x, game.camera.y)

    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', player.x, player.y, 10)

    -- Draw here
    for i, ship in pairs(game.ships) do

        -- shop draw
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('fill', ship.x, ship.y, 10)
    end
end
