love.debug.setFlag("input")

local some_max = 200

local function Ship (x, y, m, max)
    local square_max = math.pow(max, 2)

    return {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        m = m,
        max_speed = max,
        square_max_speed = square_max
    }
end

game.player = Ship(0, 0, 2, some_max)
game.player.up = false
game.player.down = false
game.player.left = false
game.player.right = false

game.ships = {
    Ship(0, 0, 3, some_max), Ship(0, some_max, 3, some_max), Ship(0, 200, 3, some_max)
}

game.camera = {
    x = 0,
    y = 0
}
