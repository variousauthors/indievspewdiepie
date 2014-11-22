love.viewport = require('libs/viewport').newSingleton()

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
local function drawStars (xoff, yoff, starscale)
    local r, g, b = love.graphics.getColor()
    local size = STAR_TILE_SIZE / starscale
    local w, h = love.viewport.getWidth(), love.viewport.getHeight()

    local sx, sy = math.floor(xoff) - size, math.floor(yoff) - size

    local x_lerp = (xoff % size)
    local y_lerp = (yoff % size)

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
                if distance % 5 < 2 then
                    populate = 2
                end
            end

            if populate == 1 then
                -- populate with 3 stars
                for n = 0, 2 do
                    local px = (hash % size) + (i - xoff);
                    hash = rshift(hash, 3)

                    local py = (hash % size) + (j - yoff);
                    hash = rshift(hash, 3)

                    love.graphics.point(px - x_lerp, py - y_lerp)
                end
            elseif populate == 2 then
                -- populate with 3 asteroids
                for n = 0, 2 do
                    local px = (hash % size) + (i - xoff);
                    hash = rshift(hash, 3)

                    local py = (hash % size) + (j - yoff);
                    hash = rshift(hash, 3)

                    local r = size/4
                    hash = rshift(hash, 3)

                    love.graphics.setColor(255, 0, 0)
                    love.graphics.print("asteroids", i -xoff, j -yoff)
                    love.graphics.setColor(r, g, b)

                    local verts = {}
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

                        table.insert(verts, px + vx - x_lerp)
                        table.insert(verts, py + vy - y_lerp)

                    end

                    table.insert(game.active_asteroids, verts)
                end
            end
        end
    end
end

function love.draw()
    local player = game.player

    -- passing in negative camera offset so that the stars appear
    -- to travel in the opposite direction to the camera
    love.graphics.setColor(255, 255, 255)
    drawStars(- game.camera.x, - game.camera.y, 1)
    love.graphics.setColor(200, 200, 200)
    drawStars(- game.camera.x/4, - game.camera.y/4, 3)
    love.graphics.setColor(100, 100, 100)
    drawStars(- game.camera.x/8, - game.camera.y/8, 9)

    for i, rock in pairs(game.active_asteroids) do
        love.graphics.polygon('fill', rock)
    end

    -- empty the asteroid data for next run
    game.active_asteroids = {}

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
