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

        -- control forces: ships fly to maintain constant distance from player
        local dx, dy = ship.x - player.x, ship.y - player.y
        local square_distance = math.pow(dx, 2) + math.pow(dy, 2)
        local fx, fy

        -- explode the player if the ship has collided
        if square_distance < math.pow(ship.r + player.r, 2) then
            player.explode = true
            ship.explode = true
        end

        if ship.explode ~= true then
            if not (square_distance < ship.square_target_radius + 1000 and ship.square_target_radius - 1000 < square_distance) then
                ship.orbiting = false
                -- the distance is positive, then the force must be negative
                fx = -dx
                fy = -dy
            else
                if orbiting == false then
                    -- choose an orbit direction
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
        end

        update_velocity(ship, dt, fx, fy)
        update_position(ship, dt)
    end

    -- calculate control forces
    local fx, fy = 0, 0

    if player.explode ~= true then
        if player.up == true then fy = fy - 1000 end
        if player.down == true then fy = fy + 1000 end
        if player.left == true then fx = fx - 1000 end
        if player.right == true then fx = fx + 1000 end
    end

    update_velocity(player, dt, fx, fy)
    update_position(player, dt)

    -- player update

    -- camera update
    local cx = love.viewport.getWidth() / 2
    local cy = love.viewport.getHeight() / 2

    -- coords of the player relative to the graphics origin
    local px, py = player.x, player.y

    game.camera.x = cx - px
    game.camera.y = cy - py
end
