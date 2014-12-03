local STAR_SEED = 0x9d2c5680;
local STAR_TILE_SIZE = 256;
local rshift, lshift, arshift, bxor, tohex = bit.rshift, bit.lshift, bit.arshift, bit.bxor, bit.tohex

local function populationMethod (starscale, ii, jj)
    local method = 1

    -- in the foreground
    if starscale == 1 then
        -- if this is in a strip of the belt
        local distance = math.sqrt(math.pow(ii, 2) + math.pow(jj, 2))

        if distance > 7 then
            local empty_space = 7

            if distance % empty_space < 2 then
                method = 4
            elseif distance % empty_space > 6 then
                method = 3
            end
        else
            if distance < 2 then
                method = 5
            end
        end
    end

    return method
end

local function restoreStars (hash, tile_size, xoff, yoff, x_lerp, y_lerp, i, j, populate, stars)
    -- populate with 3 stars
    for n = 0, 2 do
        local px = (hash % tile_size) + (i - xoff);
        hash = rshift(hash, 3)

        local py = (hash % tile_size) + (j - yoff);
        hash = rshift(hash, 3)

        table.insert(stars, {
            x = px - x_lerp,
            y = py - y_lerp
        })
    end
end

local function restoreRocks (hash, tile_size, xoff, yoff, x_lerp, y_lerp, i, j, populate)
    local id = hash

    -- populate with 3 asteroids
    for n = 0, 2 do
        local px = (hash % tile_size) + (i - xoff);
        hash = rshift(hash, 3)

        local py = (hash % tile_size) + (j - yoff);
        hash = rshift(hash, 3)

        local r = tile_size/4
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
            color = 150 + (hash % 55),
        }

        -- one of the rocks should have a factory
        if n == 0 and (populate > 2) then
            local w = rock.r/5
            local color = {
                work = { 0, 100, 100 },
                frame = { 0, 100, 255 }
            }

            -- putting north rocks facing north yo
            local offset
            if populate == 4 then
                offset = - rock.r
            else
                offset = 0
            end

            if populate == 5 then
                color = {
                    work = { 100, 100, 0 },
                    frame = { 255, 100, 0 }
                }
            end

            local factory = {
                id = id,
                rock = { x = rock.x + offset, y = rock.y + offset, r = rock.r },
                w = w,
                x = rock.x + rock.r/2 - w/2 + offset,
                y = rock.y + rock.r/2 - w/2 + offset,
                color = color
            }

            if game.all_factories[id] == nil then
                -- the stats
                game.all_factories[id] = {
                    sx = rock.sx + offset,
                    sy = rock.sy + offset,
                    work = 600,
                    ready = 600,
                    passive = populate == 5
                }
            end

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

            restoreStars(hash, size, xoff, yoff, x_lerp, y_lerp, i, j, populate, stars)
--          local populate = populationMethod(starscale, ii, jj)

--          if populate == 1 then
--              restoreStars(hash, size, xoff, yoff, x_lerp, y_lerp, i, j, populate, stars)
--          elseif populate > 1 then
--              restoreRocks(hash, size, xoff, yoff, x_lerp, y_lerp, i, j, populate)
--          end
        end
    end

    return stars
end

return lookUpStars
