love.viewport = require('libs/viewport').newSingleton()

function love.draw()
    local player = game.player

    love.graphics.setColor(100, 100, 100)
    love.graphics.draw(game.star_field, -game.player.x/10, -game.player.y/10, 0, 1)
    love.graphics.setColor(200, 200, 200)
    love.graphics.draw(game.star_field, -game.player.x/5, -game.player.y/5, 0, 3)
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(game.star_field, -game.player.x*2, -game.player.y*2, 0, 10)

    love.graphics.push()
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

    love.graphics.pop()
end
