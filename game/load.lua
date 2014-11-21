love.debug.setFlag("input")

local some_max = 200

local function Ship (x, y, m, max, r)
    local ship = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        m = m,
        max_speed = max,
        square_max_speed = math.pow(max, 2),
        target_radius = r
    }

    if r ~= nil then ship.square_target_radius = math.pow(r, 2) end

    return ship
end

-- import image assets
game.star_field = love.graphics.newImage('assets/star_field.png')

-- create game objects
game.player = Ship(0, 0, 2, some_max)
game.player.up = false
game.player.down = false
game.player.left = false
game.player.right = false

game.ships = {
    Ship(0, 0, 3, some_max, 100),
    Ship(100, 100, 3, some_max, 100),
    Ship(200, 200, 3, some_max, 100)
}

game.camera = {
    x = 0,
    y = 0
}
