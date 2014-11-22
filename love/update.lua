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

function love.update (dt)
    local player = game.player

    -- player should check for other ships
    -- player should check for bullets
    -- every ship should check for player bullets

    --Update here
    for i, ship in pairs(game.ships) do
        local fx, fy = 0, 0

        -- control forces: ships fly to maintain constant distance from player
        local dx, dy = ship.x - player.x, ship.y - player.y
        local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

        -- explode the player if the ship has collided
        if square_distance < math.pow(ship.r + player.r, 2) then
            player.explode = true
            ship.explode = true
        end

        if ship.explode ~= true then

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

    -- enemy bullet update: explore the table backward
    for i = #(game.enemy_bullets), 1, -1 do
        local bullet = game.enemy_bullets[i]

        -- if the bullet has struck the player, explode
        -- control forces: ships fly to maintain constant distance from player
        local dx, dy = bullet.x - player.x, bullet.y - player.y
        local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

        -- explode the player if the ship has collided
        if square_distance < math.pow(player.r, 2) then
            player.explode = true
            table.remove(game.enemy_bullets, i)
        end

        update_position(bullet, dt)
    end

    -- player update
    -- calculate control forces
    local fx, fy = 0, 0

    if player.explode ~= true then
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
        if player.charge > 1 then
            if player.gun == true then
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

    -- player bullet update: explore the table backward
    for i = #(game.player_bullets), 1, -1 do
        local bullet = game.player_bullets[i]

        for i = #(game.ships), 1, -1 do
            local ship = game.ships[i]

            if not ship.explode == true then
                local square_distance = math.pow(ship.x - bullet.x, 2) + math.pow(ship.y - bullet.y, 2)

                if square_distance < math.pow(ship.r + bullet.r, 2) then
                    ship.explode = true
                end
            end
        end
        -- if the bullet has struck the player, explode
        -- control forces: ships fly to maintain constant distance from player
--      local dx, dy = bullet.x - player.x, bullet.y - player.y
--      local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

--      -- explode the player if the ship has collided
--      if square_distance < math.pow(player.r, 2) then
--          player.explode = true
--          table.remove(game.enemy_bullets, i)
--      end

        update_position(bullet, dt)
    end

    -- TODO when should we remove bullets? Maybe there needs to be debris to
    -- soak them up?

    -- mother ship update
    -- launches ships
    local mom = game.mother_ship

    mom.charge = mom.charge + dt
    if mom.charge > 5 then
        local wing = {}

        for i = 1, math.floor(math.random() * 5) do
            local theta = math.random(0, 2*math.pi)
            local x = mom.x + 100*math.cos(theta)
            local y = mom.y + 100*math.sin(theta)

            local ship = Ship(x, y, 3, 10, 200, 100)

            table.insert(wing, ship)
            ship.wing = #(game.wings) + 1

            table.insert(game.ships, ship)
        end

        table.insert(game.wings, wing)

        mom.charge = mom.charge - (5 + math.random())
    end

    -- camera update
    local cx = love.viewport.getWidth() / 2
    local cy = love.viewport.getHeight() / 2

    -- coords of the player relative to the graphics origin
    local px, py = player.x, player.y

    game.camera.x = cx - px
    game.camera.y = cy - py
end
