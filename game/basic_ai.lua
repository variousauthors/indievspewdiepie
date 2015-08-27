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

function basic_ai_update(player, dt)
    local fx, fy = 0, 0

    if player.explode == nil then
        -- process an input from the buffer
 --     if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end
 --     if #(player.input.down) > 0 then player.down = table.remove(player.input.down, 1) end
 --     if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
 --     if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end
 --     if #(player.input.gun) > 0 then player.gun = table.remove(player.input.gun, 1) end

        -- make clever AI decisions

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
        multiplier_acquisition_rate = math.pow(game.active_ship_count, 1.5)
        game.time_since_fired = game.time_since_fired + dt*multiplier_acquisition_rate

        if player.charge > 1 then
            if player.gun == true then
                love.soundman.run('player_laser')
                game.time_since_fired = 0

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

