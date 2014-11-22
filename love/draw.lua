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

   -- local sx = ((xoff - w/2) / size) * size - size;
   -- local sy = ((yoff - h/2) / size) * size - size;
    local sx, sy = math.floor(xoff) - size, math.floor(yoff) - size

    local x_lerp = (xoff % size)
    local y_lerp = (yoff % size)

    love.graphics.rectangle('fill', sx, sy, 10, 10)

    for i = sx, w + sx + size*3, size do
        for j = sy, h + sy + size*3, size do
            -- each square in the lattice is indexed uniquely
            -- so that it produces a unique hash
            local hash = mix(STAR_SEED, math.floor(i / size), math.floor(j / size))

            -- this saved me a few times for debugging
--          love.graphics.setColor(200, 0, 0)
--          love.graphics.rectangle('line', i - xoff, j - yoff, size, size)
--          love.graphics.setColor(255, 255, 255)

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


    love.graphics.setColor(255, 255, 255)
    love.graphics.circle('fill', player.x, player.y, 10)

    -- Draw here
    for i, ship in pairs(game.ships) do

        -- shop draw
        love.graphics.setColor(255, 255, 255)
        love.graphics.circle('fill', ship.x, ship.y, 10)
    end

    love.graphics.pop()
end
