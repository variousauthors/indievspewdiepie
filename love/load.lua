function Ship (x, y, m, r, max, gold)
    local ship = {
        x = x,
        y = y,
        vx = 0,
        vy = 0,
        m = m,
        r = r,
        max_speed = max,
        square_max_speed = math.pow(max, 2),
        target_radius = gold,
        charge = 0,
        engine_tic = 0,
        fade_tic = 60,
        initial_fade_tic = 60,
        points_value = 100
    }

    if gold ~= nil then ship.square_target_radius = math.pow(gold, 2) end

    return ship
end

function init_board ()
    local board = {}
    local i, j

    for y = 1, game.height, 1 do
        board[y] = {}

        for x = 1, game.width, 1 do
            board[y][x] = false

        end
    end

    return board
end

function love.load()
    love.debug.setFlag("input")

    require('game/controls')
    require('game/sounds')
    require('libs/gamejolt')
    require('libs/fsm')
    require('game/update')
    require('game/draw')

    -- load update functions
    require('game/player')
    require('game/basic_ai')

    game = {}
    game.player = {}
    game.player.has_input = false
    game.player.input = {
        up = {},
        down = {},
        left = {},
        right = {}
    }
    game.colors = {
        { 200, 55, 55 }, -- red
        { 55, 200, 55 }, -- green
        { 55, 55, 200 }, -- blue
        white = { 200, 200, 200 }
    }

    game.scale = 10
    game.height = 20
    game.width = 10
    game.board = init_board()
    game.update_timer = 0
    game.match_target = 3
    game.input_timer = 4
    game.rate = 1
    game.step = 0.1 * game.rate
    game.input_rate = 4

end
