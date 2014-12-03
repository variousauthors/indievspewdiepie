local lookUpStars = require('game/starfield')

local function update_velocity (ship, dt, fx, fy)
    fx = fx or 0
    fy = fy or 0

    local vx, vy, x, y

    vx, vy = ship.vx, ship.vy
    m = ship.m

    -- calculate other forces

    -- F = ma
    vx, vy = vx + (fx/m)*dt, vy + (fy/m)*dt

    -- cap the magnitude of velocity
    -- TODO I want to clamp the magnitude before external forces like
    -- gravity, but after controls and engines
    local square_magnitude = math.pow(vx, 2) + math.pow(vy, 2)
    if  square_magnitude > ship.square_max_speed then
        local theta = math.atan2(vy, vx)
        local mag = ship.max_speed

        vx = mag*math.cos(theta)
        vy = mag*math.sin(theta)
    end

    ship.vx = vx
    ship.vy = vy
end

local function update_position (ship, dt)
    ship.x = ship.x + ship.vx*dt
    ship.y = ship.y + ship.vy*dt
end

-- physics
-- momentum, p = gamma*m*v
-- gamma = 1 / sqrt(1 - v^2 / c^2)
--
-- use the previous p_o to get the p_1 etc...
--
-- gravity drops off with 1/r^2 where r is distance to center of mass
--

local bullet_factor = 1

function game.update (dt)
    local player = game.player
    local active_ship_count = 0
    local time_since_fired = game.time_since_fired

    if player.explode == nil then
        dt = dt * bullet_factor
    end

    -- collide rocks with every other table
    for i, rock in pairs(game.active_asteroids) do
        -- if distance from rock center to object center overwhelms rock's r
        -- then explode object

        -- collide with player
        do
            if player.explode == nil then
                local dx, dy = player.x - rock.sx, player.y - rock.sy
                local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

                if square_distance < math.pow(rock.r, 2) then
                    player.explode = 5
                    love.soundman.run('player_explodes')
                    table.insert(game.explosions, player)
                end
            end
        end

        -- collide with ships
        -- TODO if the rock has a factory, then it should not collide
        for i, ship in pairs(game.ships) do
            if ship.explode == nil then
                local dx, dy = ship.x - rock.sx, ship.y - rock.sy
                local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

                if square_distance < math.pow(rock.r, 2) then
                    ship.explode = 5
                    table.insert(game.explosions, ship)
                end
            end
        end

        -- rock beats bullet
        for i = #(game.enemy_bullets), 1, -1 do
            local bullet = game.enemy_bullets[i]

            local dx, dy = bullet.x - rock.sx, bullet.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if square_distance < math.pow(rock.r, 2) then
                bullet.explode = 3
                love.soundman.run('bullet_rock')
                table.remove(game.enemy_bullets, i)
                table.insert(game.explosions, bullet)
            end
        end

        -- rock beats bullet
        for i = #(game.player_bullets), 1, -1 do
            local bullet = game.player_bullets[i]

            local dx, dy = bullet.x - rock.sx, bullet.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if square_distance < math.pow(rock.r, 2) then
                bullet.explode = 3
                love.soundman.run('bullet_rock')
                table.remove(game.player_bullets, i)
                table.insert(game.explosions, bullet)
            end
        end
    end

    -- player should check for other ships
    -- player should check for bullets
    -- every ship should check for player bullets

    -- enemy update
    -- update velocity, collide with player, TODO collide with rocks

    -- active_ship_count used to calculate score multiplier
    active_ship_count = 0

    for i, ship in pairs(game.ships) do
        local fx, fy = 0, 0

        if ship.explode == nil then
            active_ship_count = active_ship_count + 1
            -- explode the player if the ship has collided
            local dx, dy = ship.x - player.x, ship.y - player.y
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if player.explode == nil then
                if square_distance < math.pow(ship.r + player.r, 2) then
                    player.explode = 5
                    love.soundman.run('player_explodes')

                    ship.explode = 5
                    table.insert(game.explosions, player)
                    table.insert(game.explosions, ship)
                end
            end

            -- control forces: ships fly to maintain constant distance from player
            -- ships try to stay in an orbit around the player, within the goldylocks zone
            if not (square_distance < ship.square_target_radius + 1000 and ship.square_target_radius - 1000 < square_distance) then
                ship.orbiting = false
                -- the distance is positive, then the force must be negative
                fx = -dx
                fy = -dy
            else
                if orbiting == false then
                    -- choose an orbit direction
                    -- TODO should just be tangent to the player, in either direction
                    if ship.vx > ship.vy then
                        fy = 1000
                    elseif ship.vy > ship.vx then
                        fx = 1000
                    else
                        print("IMPOSSIBLE!")
                    end

                    ship.orbiting = true
                end
            end

            update_velocity(ship, dt, fx, fy)
            update_position(ship, dt)

            -- shoot at the player! bullets have a constant velocity + the velocity of the ship
            -- TODO this could be improved: the ai rarely hits!
            ship.charge = ship.charge + dt
            if ship.charge > 1 then
                love.soundman.run('laser')
                local bullet = {
                    x = ship.x, y = ship.y, speed = 200, r = 3
                }

                -- get the distance to the player
                local dx = ship.x - player.x
                local dy = ship.y - player.y
                local distance = math.sqrt(math.pow(dx, 2) + math.pow(dy, 2))

                -- divide by dt to see how many steps are between
                local hit_time = (distance/bullet.speed) -- in seconds

                -- predict the player's movement forward by that many steps
                local future_x = player.x + player.vx*hit_time
                local future_y = player.y + player.vy*hit_time

                -- determine the vector to that spot
                local theta = math.atan2(future_y - ship.y, future_x - ship.x)
                local mag = bullet.speed + math.sqrt(math.pow(ship.vx, 2) + math.pow(ship.vy, 2))

                bullet.vx = mag*math.cos(theta)
                bullet.vy = mag*math.sin(theta)

                table.insert(game.enemy_bullets, bullet)

                ship.charge = ship.charge - (1 + math.random())
            end
        else
            update_velocity(ship, dt, fx, fy)
            update_position(ship, dt)
        end
    end

    local closest_bullet = 1000
    -- enemy bullet update: explore the table backward
    -- collide bullets with player, TODO collide with rocks
    for i = #(game.enemy_bullets), 1, -1 do
        local bullet = game.enemy_bullets[i]

        -- if the bullet has struck the player, explode
        -- control forces: ships fly to maintain constant distance from player
        local dx, dy = bullet.x - player.x, bullet.y - player.y
        local square_distance = math.pow(dx, 2) + math.pow(dy, 2)
        closest_bullet = math.min(closest_bullet, square_distance)

        -- explode the player if the ship has collided
        if player.explode == nil then
            if square_distance < math.pow(player.r, 2) then
                player.explode = 5
                love.soundman.run('player_explodes')
                table.remove(game.enemy_bullets, i)
                table.insert(game.explosions, player)
            end
        end

        update_position(bullet, dt)
    end

    if closest_bullet < 1000 then
        bullet_factor = math.max(0.25, 1 - 300/closest_bullet)
    else
        bullet_factor = 1
    end

    -- player update
    -- calculate control forces
    -- TODO collide with rocks
    do
        local fx, fy = 0, 0

        if player.explode == nil then
            -- process an input from the buffer
            if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end
            if #(player.input.down) > 0 then player.down = table.remove(player.input.down, 1) end
            if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
            if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end
            if #(player.input.gun) > 0 then player.gun = table.remove(player.input.gun, 1) end

            if player.up == true then fy = fy - 1000 end
            if player.down == true then fy = fy + 1000 end
            if player.left == true then fx = fx - 1000 end
            if player.right == true then fx = fx + 1000 end

            -- update the reticle
            local mx, my = love.mouse.getPosition()
            local h = love.viewport.getHeight()/2
            local w = love.viewport.getWidth()/2

            local rx, ry = mx - w, my - h
            local theta = math.atan2(ry, rx)

            player.reticle.theta = theta
            player.reticle.rx = 100*math.cos(theta) + w
            player.reticle.ry = 100*math.sin(theta) + h

            player.charge = math.min(1.5, player.charge + dt)

            -- used to calculate score multiplier
            multiplier_acquisition_rate = math.pow(active_ship_count, 1.5)
            time_since_fired = time_since_fired + dt*multiplier_acquisition_rate

            if player.charge > 1 then
                if player.gun == true then
                    love.soundman.run('player_laser')
                    time_since_fired = 0

                    player.gun = false
                    local bullet = {
                        x = player.x, y = player.y, speed = 200, r = 3
                    }

                    local theta = player.reticle.theta
                    local mag = bullet.speed

                    bullet.vx = mag*math.cos(theta) + player.vx
                    bullet.vy = mag*math.sin(theta) + player.vy

                    table.insert(game.player_bullets, bullet)

                    player.charge = player.charge - 1/3
                end
            end
        end

        update_velocity(player, dt, fx, fy)
        update_position(player, dt)
    end

    -- calculate the score multiplier
    do
        -- if you've dodged long enough, multiplier goes up
        if time_since_fired > game.next_multiplier_at() then
            game.score_multiplier = game.score_multiplier + 1

            time_since_fired = 0
        end

        -- if you've killed them all, then reset multiplier?
        -- TODO I'm not sure if this is more fun...
        if active_ship_count == 0 then
            game.score_multiplier = 1
        end

        -- for draw routine
        game.time_since_fired = time_since_fired
    end

    -- player bullet update
    for i = #(game.player_bullets), 1, -1 do
        local bullet = game.player_bullets[i]

        for i = #(game.ships), 1, -1 do
            local ship = game.ships[i]

            if ship.explode == nil then
                local square_distance = math.pow(ship.x - bullet.x, 2) + math.pow(ship.y - bullet.y, 2)

                if square_distance < math.pow(ship.r + bullet.r, 2) then
                    ship.explode = 5
                    ship.show_score = true
                    game.score = game.score + (ship.points_value * game.score_multiplier)
                    love.soundman.run('ship_explodes')
                    table.insert(game.explosions, ship)
                end
            end
        end

        update_position(bullet, dt)
    end

    -- factories update
    for i, factory in pairs(game.active_factories) do
        local factory = game.all_factories[factory.id]

        factory.work = factory.work + 1
        if factory.work > factory.ready then
            if factory.passive == true then
                factory.work = 0
            else
                love.soundman.run('ship_complete')
                local wing = {}

                for i = 1, math.floor(math.random() * 5) do
                    local theta = math.random(0, 2*math.pi)
                    local x = factory.sx + 100*math.cos(theta)
                    local y = factory.sy + 100*math.sin(theta)

                    local ship = Ship(x, y, 3, 10, 200, 100)

                    table.insert(wing, ship)
                    ship.wing = #(game.wings) + 1

                    table.insert(game.ships, ship)

                    factory.work = 0
                end

                table.insert(game.wings, wing)
            end
        end
    end

    -- camera update
    local cx = love.viewport.getWidth() / 2
    local cy = love.viewport.getHeight() / 2

    -- coords of the player relative to the graphics origin
    local px, py = player.x, player.y

    game.camera.x = cx - px
    game.camera.y = cy - py

    -- generate stars and asteroids for the currently active space
    game.star_layers = {}
    game.active_asteroids = {}
    game.active_factories = {}

    -- passing in negative camera offset so that the stars appear
    -- to travel in the opposite direction to the camera
    table.insert(game.star_layers, lookUpStars(- game.camera.x, - game.camera.y, 1))
    table.insert(game.star_layers, lookUpStars(- game.camera.x/4, - game.camera.y/4, 3))
    table.insert(game.star_layers, lookUpStars(- game.camera.x/8, - game.camera.y/8, 9))
end
