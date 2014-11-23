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
        engine_tic = 0
    }

    if gold ~= nil then ship.square_target_radius = math.pow(gold, 2) end

    return ship
end

function love.load()
    love.debug.setFlag("input")

    require('game/controls')
    require('game/sounds')
    require('libs/gamejolt')

    gj = GameJolt(conf.floor_height, conf.side_length)
    --gj.connect_user(profile.username, profile.token)

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)

    local some_max = 500

    -- import image assets
    game.star_field = love.graphics.newImage('assets/star_field.png')

    -- create game objects
    game.player = Ship(0, 0, 2, 5, some_max)
    game.player.input = {
        up = {},
        down = {},
        left = {},
        right = {},
        gun = {}
    }

    game.player.reticle = { r = 5 }

    game.boss = { }
    game.mother_ship = {
        x = 0, y = 0,
        charge = 4
    }

    game.active_asteroids = {}
    game.active_factories = {}
    game.all_factories = {} -- indexed by id
    game.star_layers = {}
    game.explosions = {}

    game.ships = { }
    game.wings = {} -- collections of ships that flock

    game.enemy_bullets = {}
    game.player_bullets = {}

    game.camera = {
        x = 0,
        y = 0
    }

--  love.viewport.setFullscreen()
--  love.viewport.setupScreen()
end
