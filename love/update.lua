local STAR_SEED = 0x9d2c5680;
local STAR_TILE_SIZE = 256;
local rshift, lshift, arshift, bxor, tohex = bit.rshift, bit.lshift, bit.arshift, bit.bxor, bit.tohex

-- Robert Jenkins' 96 bit Mix Function.
-- Taken from http://nullprogram.com/blog/2011/06/13/
local function mix (a, b, c)

    a=a-b;  a=a-c;  a=bxor(a, (rshift(c, 13)));
    b=b-c;  b=b-a;  b=bxor(b, (lshift(a, 8)));
    c=c-a;  c=c-b;  c=bxor(c, (rshift(b, 13)));
    a=a-b;  a=a-c;  a=bxor(a, (rshift(c, 12)));
    b=b-c;  b=b-a;  b=bxor(b, (lshift(a, 16)));
    c=c-a;  c=c-b;  c=bxor(c, (rshift(b, 5)));
    a=a-b;  a=a-c;  a=bxor(a, (rshift(c, 3)));
    b=b-c;  b=b-a;  b=bxor(b, (lshift(a, 10)));
    c=c-a;  c=c-b;  c=bxor(c, (rshift(b, 15)));

    return c
end

local strip_stagger = 500
local function lookUpStars (xoff, yoff, starscale)
    local size = STAR_TILE_SIZE / starscale
    local w, h = love.viewport.getWidth(), love.viewport.getHeight()

    local sx, sy = math.floor(xoff) - size, math.floor(yoff) - size

    local x_lerp = (xoff % size)
    local y_lerp = (yoff % size)

    local stars = {}

    for i = sx, w + sx + size*3, size do
        for j = sy, h + sy + size*3, size do
            -- each square in the lattice is indexed uniquely
            -- so that it produces a unique hash
            local ii, jj = math.floor(i / size), math.floor(j / size)
            local hash = mix(STAR_SEED, ii, jj)

            local populate = 1

            -- in the foreground
            if starscale == 1 then
                -- if this is in a strip of the belt
                local distance = math.sqrt(math.pow(ii, 2) + math.pow(jj, 2))

                if distance % 7 < 2 then
                    populate = 2
                elseif distance % 7 > 6 then
                    populate = 3
                end
            end

            if populate == 1 then
                -- populate with 3 stars
                for n = 0, 2 do
                    local px = (hash % size) + (i - xoff);
                    hash = rshift(hash, 3)

                    local py = (hash % size) + (j - yoff);
                    hash = rshift(hash, 3)

                    table.insert(stars, {
                        x = px - x_lerp,
                        y = py - y_lerp
                    })
                end
            elseif populate == 2 or populate == 3 then
                local id = hash

                -- populate with 3 asteroids
                for n = 0, 2 do
                    local px = (hash % size) + (i - xoff);
                    hash = rshift(hash, 3)

                    local py = (hash % size) + (j - yoff);
                    hash = rshift(hash, 3)

                    local r = size/4
                    hash = rshift(hash, 3)

                    local rock = {
                        verts = {},
                        x = px - x_lerp,
                        y = py - y_lerp,
                        -- was lost, and totally just GUESSED that I needed game.camera here
                        -- TODO I need to rewrite this whole thing so that the coords coming out
                        -- are in the same space as all other game objects, WITHOUT this bullshit here
                        sx = px - x_lerp - game.camera.x,
                        sy = py - y_lerp - game.camera.y,
                        r = r,
                        color = color
                    }

                    -- one of the rocks should have a factory
                    if n == 0 and populate == 3 then
                        local w = rock.r/5

                        local factory = {
                            id = id,
                            rock = rock,
                            w = w,
                            x = rock.x + rock.r/2 - w/2,
                            y = rock.y + rock.r/2 - w/2,
                        }

                        if game.all_factories[id] == nil then
                            -- the stats
                            game.all_factories[id] = {
                                sx = rock.sx,
                                sy = rock.sy,
                                work = 900,
                                ready = 900
                            }
                        end

                        -- graphics
                        table.insert(game.active_factories, factory)
                    end

                    local theta = 0
                    local num_verts = 5 + (hash % 3) + (hash % 5) + (hash % 7)
                    local arc_size = 2*math.pi/num_verts

                    for i = 1, num_verts do
                        -- use arithmetic shift so that we don't run out of numbers

                        theta = (i - 1) * arc_size
                        theta = theta + (hash % arc_size)

                        -- we want angles around the circle
                        local vx = r*math.cos(theta)
                        local vy = r*math.sin(theta)

                        table.insert(rock.verts, rock.x + vx)
                        table.insert(rock.verts, rock.y + vy)
                    end

                    -- reach out to the global and define asteroids
                    table.insert(game.active_asteroids, rock)
                end
            end
        end
    end

    return stars
end

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

    -- collide rocks with every other table
    for i, rock in pairs(game.active_asteroids) do
        -- if distance from rock center to object center overwhelms rock's r
        -- then explode object

        -- collide with player
        do
            local dx, dy = player.x - rock.sx, player.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if square_distance < math.pow(rock.r, 2) then
                player.explode = true
            end
        end

        -- collide with ships
        for i, ship in pairs(game.ships) do
            local dx, dy = ship.x - rock.sx, ship.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if square_distance < math.pow(rock.r, 2) then
                ship.explode = true
            end
        end

        for i = #(game.enemy_bullets), 1, -1 do
            local bullet = game.enemy_bullets[i]

            local dx, dy = bullet.x - rock.sx, bullet.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            if square_distance < math.pow(rock.r, 2) then
                bullet.explode = 3
                table.remove(game.enemy_bullets, i)
                table.insert(game.explosions, bullet)
            end
        end

        for i = #(game.player_bullets), 1, -1 do
            local bullet = game.player_bullets[i]

            -- if the bullet has struck the player, explode
            -- control forces: ships fly to maintain constant distance from player
            local dx, dy = bullet.x - rock.sx, bullet.y - rock.sy
            local square_distance = math.pow(dx, 2) + math.pow(dy, 2)

            -- explode the player if the ship has collided
            if square_distance < math.pow(rock.r, 2) then
                bullet.explode = 3
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
    -- collide bullets with player, TODO collide with rocks
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
    -- TODO collide with rocks
    do
        local fx, fy = 0, 0

        if player.explode ~= true then
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
    end

    -- player bullet update: explore the table backward
    -- collide with enemy, TODO collide with rocks
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

        update_position(bullet, dt)
    end

    -- factories update
    for i, factory in pairs(game.active_factories) do
        local factory = game.all_factories[factory.id]

        factory.work = factory.work + 1
        if factory.work > factory.ready then
            local wing = {}

            for i = 1, math.floor(math.random() * 3) do
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
