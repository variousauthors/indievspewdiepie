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

--[[
--
--
--]]
local function drawStars (xoff, yoff, starscale)
    local size = STAR_TILE_SIZE / starscale
    local w, h = love.viewport.getWidth(), love.viewport.getHeight()

    local sx, sy = math.floor(xoff) - size, math.floor(yoff) - size

    local x_lerp = (xoff % size)
    local y_lerp = (yoff % size)

    for i = sx, w + sx + size*3, size do
        for j = sy, h + sy + size*3, size do
            -- each square in the lattice is indexed uniquely
            -- so that it produces a unique hash
            local hash = mix(STAR_SEED, math.floor(i / size), math.floor(j / size))

            for n = 0, 2 do
                local px = (hash % size) + (i - xoff);
                hash = arshift(hash, 3)

                local py = (hash % size) + (j - yoff);
                hash = arshift(hash, 3)

                love.graphics.point(px - x_lerp, py - y_lerp)
            end
        end
    end
end

function love.draw()
    local player = game.player

    love.graphics.setColor(255, 255, 255)
    drawStars(- game.camera.x, - game.camera.y, 1)
    love.graphics.setColor(200, 200, 200)
    drawStars(- game.camera.x/4, - game.camera.y/4, 3)
    love.graphics.setColor(100, 100, 100)
    drawStars(- game.camera.x/8, - game.camera.y/8, 9)

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
        love.graphics.circle('fill', bullet.x, bullet.y, 3)
    end

    love.graphics.pop()
end
