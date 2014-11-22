function love.load()
    love.debug.setFlag("input")

    require('game/controls')
    require('game/sounds')
    require('game/load')

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)

    local some_max = 200

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
            charge = 0
        }

        if gold ~= nil then ship.square_target_radius = math.pow(gold, 2) end

        return ship
    end

    -- import image assets
    game.star_field = love.graphics.newImage('assets/star_field.png')

    -- create game objects
    game.player = Ship(0, 0, 2, 10, some_max)
    game.player.up = false
    game.player.down = false
    game.player.left = false
    game.player.right = false

    game.player.reticle = { r = 5 }

    game.boss = { }
    game.mother_ship = {
        x = 0, y = 0,
        charge = 4
    }

    game.active_asteroids = {}

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
