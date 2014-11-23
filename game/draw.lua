love.viewport = require('libs/viewport').newSingleton()

local ar, ag, ab

local setColor = function (r, g, b)
    love.graphics.setColor(r*ar, g*ag, b*ab)
end

function game.draw()
    local player = game.player

    -- get the ambient offset from full colour
    ar, ag, ab = love.graphics.getColor()
    ar, ag, ab = ar/255, ag/255, ab/255

    -- TODO for some reason stars exist in their own coordinate space?
    for i, star_layer in pairs(game.star_layers) do
        for j, star in pairs(star_layer) do
            love.graphics.point(star.x, star.y)
        end
    end

    for i, rock in pairs(game.active_asteroids) do
        setColor(rock.color, rock.color, rock.color)
        love.graphics.polygon('fill', rock.verts)
        setColor(255, 255, 255)
    end

    for i, factory in pairs(game.active_factories) do
        local rock = factory.rock
        local stats = game.all_factories[factory.id]

        local percent_done = (1 - stats.work/stats.ready)
        local inner_width = (rock.r - factory.w)*percent_done + factory.w

        -- draw the work timer indicator
        setColor(unpack(factory.color.work))
        love.graphics.setLineWidth(5)
        love.graphics.rectangle('line', rock.x + (rock.r - inner_width)/2, rock.y + (rock.r - inner_width)/2, inner_width, inner_width)

        -- draw the frame
        setColor(unpack(factory.color.frame))
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', rock.x, rock.y, rock.r, rock.r)
        love.graphics.rectangle('line', factory.x, factory.y, factory.w, factory.w)

        -- restore the context
        love.graphics.setLineWidth(1)
        setColor(255, 255, 255)
    end

    -- translate everything so the camera is centered on the player
    love.graphics.push()
    love.graphics.translate(game.camera.x, game.camera.y)

    -- draw the player
    do
        if player.explode == nil then
            player.engine_tic = (player.engine_tic + 1) % 3

            if player.engine_tic == 0 then
                setColor(255, 100, 100)
                love.graphics.circle('line', player.x, player.y, player.r)
            end

            setColor(255, 255, 255)
            love.graphics.circle('fill', player.x, player.y, player.r - 1)
            setColor(255, 255, 255)
        end
    end

    -- Draw here
    for i, ship in pairs(game.ships) do
        if ship.explode == nil then
            ship.engine_tic = (ship.engine_tic + 1) % 3

            if ship.engine_tic == 0 then
                setColor(100, 100, 255)
                love.graphics.circle('line', ship.x, ship.y, ship.r)
            end

            setColor(255, 255, 255)
            love.graphics.circle('fill', ship.x, ship.y, ship.r - 2)
        elseif ship.fade_tic > 0 then
            -- draw a word
            ship.fade_tic = ship.fade_tic - 1
            local a = ship.fade_tic/ship.initial_fade_tic

            setColor(255*a, 255*a, 255*a)
            love.graphics.print(ship.points_value * game.score_multiplier, ship.x, ship.y)
            setColor(255, 255, 255)
        end
    end

    for i, bullet in pairs(game.enemy_bullets) do
        setColor(0, 255, 255)
        love.graphics.circle('fill', bullet.x, bullet.y, bullet.r)
    end

    for i, bullet in pairs(game.player_bullets) do
        setColor(255, 100, 0)
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
            setColor(255, 0, 0)
            love.graphics.circle('fill', explosion.x, explosion.y, explosion.r * 3)
        end
    end

    love.graphics.pop()

    -- draw the score bar
    do
        local w = 200
        local h = 15
        local x = 0 + h - player.x
        local y = love.viewport.getHeight() - h*3 - player.y

        -- multiplier and bar
        setColor(255, 255, 255)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle('line', player.x + x, player.y + y, w, h + 2)
        love.graphics.print('multiplier x' .. game.score_multiplier, player.x + x, player.y + y - h - 2)
        love.graphics.setLineWidth(1)

        -- score
        love.graphics.print('score: ' .. game.score, player.x + x, player.y + y + h + 2)

        x = x + 1
        y = y + 1

        setColor(100, 100, 100)
        love.graphics.rectangle('fill', player.x + x, player.y + y, w - 2, h)
        w = w * (game.time_since_fired / game.next_multiplier_at())
        h = h
        setColor(255, 100, 0)
        love.graphics.rectangle('fill', player.x + x, player.y + y, w, h)
        setColor(255, 255, 255)
    end

    -- draw the reticle
    local mx, my = love.mouse.getPosition()

    setColor(255, 0, 0)
    love.graphics.circle('line', player.reticle.rx, player.reticle.ry, player.reticle.r)
    love.graphics.circle('fill', mx, my, player.reticle.r)
    setColor(255, 255, 255)
end
