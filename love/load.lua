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

function love.load()
    love.debug.setFlag("input")

    require('game/controls')
    require('game/sounds')
    require('libs/gamejolt')
    require('libs/fsm')
    require('game/update')
    require('game/draw')

    Component = require('libs/component')

    Menu = require('game/menu')
    SettingsMenu = require('game/settings_menu')

    love.mouse.setVisible(false)
    love.mouse.setGrabbed(true)

    -- set the player's top speed
    local top_speed = 500

    -- global variables for integration with dp menus
    W_HEIGHT = love.viewport.getHeight()
    SCORE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 14)
    SPACE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 64)

    game.variables = {}

    function game.init ()
        -- create game objects
        game.player = Ship(0, 0, 2, 5, top_speed)

        -- enable the movement and guns
        game.player.movement_enabled = false
        game.player.violence_enabled = false

        game.player.input = {
            up = {},
            down = {},
            left = {},
            right = {},
            gun = {}
        }

        game.player.reticle = { r = 5 }
        game.player.score = 0
        game.player.multiplier = 0

        game.score = 0
        game.score_multiplier = 1
        game.next_multiplier_at = function ()
            return game.score_multiplier*100
        end
        game.time_since_fired = 0

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

    end

    function game.set (key, value)
        game.variables[key] = value
    end

    function game.get (key)
        return game.variables[key]
    end

    -- happens once before anything
    game.init()

    love.viewport.setFullscreen()
    love.viewport.setupScreen()

    menu          = Menu()
    settings_menu = SettingsMenu()
    gj = GameJolt(conf.floor_height, conf.side_length)

    state_machine = FSM()

    state_machine.addState({
        name       = "run",
        init       = function ()
            game.init()
        end,
        draw       = function ()
            game.draw()
            -- score_band.draw()
        end,
        update     = game.update,
        keypressed = game.keypressed,
        keyreleased = game.keyreleased,
        mousepressed = game.mousepressed,
        mousereleased = game.mousereleased
    })

    local profile = nil

    state_machine.addState({
        name       = "start",
        init       = function ()
            menu.show(function (options)
                profile = settings_menu.recoverProfile()

                if profile then
                    gj.connect_user(profile.username, profile.token)
                end

                game.set(options.arity, true)
                --game.set(options.mode, true)

                menu.reset()
            end)
        end,
        draw = function ()
            love.graphics.setColor(55, 55, 55, 255)
            game.draw()
            love.graphics.setColor(255, 255, 255, 255)
            menu.draw()
        end,
        keypressed = function (key)
            if (key == "escape") then
                love.event.quit()
            end

            menu.keypressed(key)
        end,
        mousepressed = menu.mousepressed,
        update     = function (dt)
            game.update(dt)
            menu.update(dt)
        end
    })

    state_machine.addState({
        name       = "settings",
        init       = function ()
            game.set("settings", nil)
            settings_menu.show(function (options)
                profile = settings_menu.recoverProfile()
                game.set(options.mode, true)

            end)
        end,
        draw       = settings_menu.draw,
        keypressed = settings_menu.keypressed,
        update     = settings_menu.update,
        textinput  = settings_menu.textinput
    })

    state_machine.addState({
        name       = "win",
        init       = function ()
            -- talk to GameJolt
            --diff = score_band.getDifference()
            gj.add_score(game.score .. " points", game.score)
            game.player.explode = nil
        end,
        update = function (dt) end,
        draw       = function () end
    })

    -- start the game when the player chooses a menu option
    state_machine.addTransition({
        from      = "start",
        to        = "run",
        condition = function ()
            return not menu.isShowing() and not game.get("settings")
        end
    })

    state_machine.addTransition({
        from      = "start",
        to        = "settings",
        condition = function ()
            return game.get("settings")
        end
    })

    state_machine.addTransition({
        from      = "settings",
        to        = "start",
        condition = function ()

            return state_machine.isSet("escape") or not settings_menu.isShowing()
        end
    })

    -- reset the game if there is a winner
    state_machine.addTransition({
        from      = "run",
        to        = "win",
        condition = function ()
            -- when the explosion animation for the player is over
            return game.player.explode == 0
        end
    })

    -- return to the menu screen if any player presses escape
    state_machine.addTransition({
        from      = "run",
        to        = "start",
        condition = function ()
            if game.player.explode == nil and state_machine.isSet("escape") then
                game.init()

                return true
            end
        end
    })

    -- restart the game if the player presses space
    state_machine.addTransition({
        from      = "win",
        to        = "start",
        condition = function ()
            return true
        end
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.keyreleased = state_machine.keyreleased
    love.mousepressed = state_machine.mousepressed
    love.mousereleased = state_machine.mousereleased
    love.textinput  = state_machine.textinput
    love.draw       = state_machine.draw

    state_machine.start()
end
