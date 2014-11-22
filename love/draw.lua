love.viewport = require('libs/viewport').newSingleton()

function love.draw()
    local player = game.player

    for i, star_layer in pairs(game.star_layers) do
        for j, star in pairs(star_layer) do
            love.graphics.point(star.x, star.y)
        end
    end

    for i, rock in pairs(game.active_asteroids) do
        love.graphics.polygon('fill', rock)
    end

    -- empty the asteroid data for next run
    game.active_asteroids = {}
    game.star_layers = {}

    love.graphics.push()
    -- translate everything so the camera is centered on the player
    love.graphics.translate(game.camera.x, game.camera.y)

    if player.explode ~= true then
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('fill', player.x, player.y, player.r)
    else
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle('fill', player.x, player.y, player.r * 3)
    end

    -- Draw here
    for i, ship in pairs(game.ships) do

        -- shop draw
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('fill', ship.x, ship.y, ship.r)

        if ship.explode ~= true then
            love.graphics.setColor(255, 255, 255)
            love.graphics.circle('fill', ship.x, ship.y, ship.r)
        else
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle('fill', ship.x, ship.y, ship.r * 3)
        end
    end

    for i, bullet in pairs(game.enemy_bullets) do
        love.graphics.setColor(0, 255, 255)
        love.graphics.circle('fill', bullet.x, bullet.y, bullet.r)
    end

    for i, bullet in pairs(game.player_bullets) do
        love.graphics.setColor(255, 100, 0)
        love.graphics.circle('fill', bullet.x, bullet.y, bullet.r)
    end

    love.graphics.pop()

    -- draw the reticle
    local mx, my = love.mouse.getPosition()

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle('line', player.reticle.rx, player.reticle.ry, player.reticle.r)
    love.graphics.circle('fill', mx, my, player.reticle.r)
    love.graphics.setColor(255, 255, 255)
end
