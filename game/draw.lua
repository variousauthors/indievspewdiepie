love.viewport = require('libs/viewport').newSingleton()

function game.draw()
    local player = game.player

    -- TODO for some reason stars exist in their own coordinate space?
    for i, star_layer in pairs(game.star_layers) do
        for j, star in pairs(star_layer) do
            love.graphics.point(star.x, star.y)
        end
    end

    for i, rock in pairs(game.active_asteroids) do
        love.graphics.setColor(rock.color, rock.color, rock.color)
        love.graphics.polygon('fill', rock.verts)
        love.graphics.setColor(255, 255, 255)
    end

    for i, factory in pairs(game.active_factories) do
        local rock = factory.rock
        local stats = game.all_factories[factory.id]

        local percent_done = (1 - stats.work/stats.ready)
        local inner_width = (rock.r - factory.w)*percent_done + factory.w

        -- draw the work timer indicator
        love.graphics.setColor(unpack(factory.color.work))
        love.graphics.setLineWidth(5)
        love.graphics.rectangle('line', rock.x + (rock.r - inner_width)/2, rock.y + (rock.r - inner_width)/2, inner_width, inner_width)

        -- draw the frame
        love.graphics.setColor(unpack(factory.color.frame))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', rock.x, rock.y, rock.r, rock.r)
        love.graphics.rectangle('line', factory.x, factory.y, factory.w, factory.w)

        -- restore the context
        love.graphics.setLineWidth(1)
        love.graphics.setColor(255, 255, 255)
    end

    -- translate everything so the camera is centered on the player
    love.graphics.push()
    love.graphics.translate(game.camera.x, game.camera.y)

    -- draw the player
    do
        if player.explode == nil then
            player.engine_tic = (player.engine_tic + 1) % 3

            if player.engine_tic == 0 then
                love.graphics.setColor(255, 100, 100)
                love.graphics.circle('line', player.x, player.y, player.r)
            end

            love.graphics.setColor(255, 255, 255)
            love.graphics.circle('fill', player.x, player.y, player.r - 1)
            love.graphics.setColor(255, 255, 255)
        end
    end

    -- Draw here
    for i, ship in pairs(game.ships) do
        if ship.explode == nil then
            ship.engine_tic = (ship.engine_tic + 1) % 3

            if ship.engine_tic == 0 then
                love.graphics.setColor(100, 100, 255)
                love.graphics.circle('line', ship.x, ship.y, ship.r)
            end

            love.graphics.setColor(255, 255, 255)
            love.graphics.circle('fill', ship.x, ship.y, ship.r - 2)
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

    for i = #(game.explosions), 1, -1 do
        local explosion = game.explosions[i]

        if not explosion.explode then
            explosion.explode = 3
        else
            explosion.explode = explosion.explode - 1
        end

        if explosion.explode < 0 then
            table.remove(game.explosions, i)
            -- TODO then we should clean up the explosions memory
        else
            -- explosion should be bigger than whatever was exploding
            love.graphics.setColor(255, 0, 0)
            love.graphics.circle('fill', explosion.x, explosion.y, explosion.r * 3)
        end
    end


    love.graphics.pop()

    -- draw the reticle
    local mx, my = love.mouse.getPosition()

    love.graphics.setColor(255, 0, 0)
    love.graphics.circle('line', player.reticle.rx, player.reticle.ry, player.reticle.r)
    love.graphics.circle('fill', mx, my, player.reticle.r)
    love.graphics.setColor(255, 255, 255)
end
