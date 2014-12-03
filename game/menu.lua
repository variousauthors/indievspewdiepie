
return function ()
    local showing       = false
    local hide_callback = function () end
    local cursor_pos    = 0
    local choice        = "launch"
    local mode          = "dynamic"
    local menu_index    = 0
    local time, flash   = 0, 0

    local inputs = {
        {   -- language_select
            clear      = function ()
            end,
            keypressed = function (key)
                choice = "launch"
                cursor_pos = 0
            end
        },
        {   -- language_select
            clear      = function ()
            end,
            keypressed = function (key)
                choice = "settings"
                cursor_pos = 90
            end
        },
    }

    local drawCursor = function (x, y)
        local icon = ">"

        love.graphics.setFont(SCORE_FONT)
        love.graphics.print(icon, x, y + cursor_pos)
    end

    local drawSubtitle = function (x, y)
        love.graphics.setFont(SCORE_FONT)
        love.graphics.printf("there is a king in space, who lurks", x, y, 576, "right")
    end

    local drawTitle = function (x, y)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.print("GUNSHIP SOULS", x, y)
    end

    local title_part    = Component(0, 0, drawTitle)
    local subtitle_part = Component(0, 80, drawSubtitle)
    local choice_part   = Component(0, 200, Component(0, 0, ""), Component(200, 0, drawCursor), Component(230, 0, "LAUNCH"))
    local settings      = Component(0, 200, Component(0, 0, ""), Component(200, 0, drawCursor), Component(230, 90, "SETTINGS"))

    local component = Component(100, W_HEIGHT/2 - 200, title_part, subtitle_part, choice_part, settings)

    local draw = function ()
        local r, g, b = love.graphics.getColor()
        love.graphics.setColor({ 255, 255, 255 })

        component.draw(0, 0)

        love.graphics.setColor({ r, g, b })
    end

    local update = function (dt)
        time  = time + 2*dt
        flash = math.floor(time)%2
    end

    local show = function (callback)
        hide_callback = callback
        showing = true

        if not showing then
            if callback then callback() end
        end
    end

    local hide = function ()
        if hide_callback then hide_callback({ arity = choice, mode = mode }) end
        showing = false
    end

    local isShowing = function ()
        return showing
    end

    local mousepressed = function (x, y, button)
        choice = "launch"
        hide()
    end

    local keypressed = function (key)
        if key == "return" or key == " " then
            hide()
        end

        if key == "up" then
            menu_index = (menu_index - 1)%(#inputs)
        elseif key == "down" then
            menu_index = (menu_index + 1)%(#inputs)
        end

        if inputs[menu_index + 1].keypressed then
            inputs[menu_index + 1].keypressed(key)
        end
    end

    local textinput = function (key)
        if inputs[menu_index + 1].textinput then
            inputs[menu_index + 1].textinput(key)
        end
    end

    local reset = function ()
        play_together = false
    end

    return {
        draw           = draw,
        update         = update,
        keypressed     = keypressed,
        mousepressed   = mousepressed,
        textinput      = textinput,
        show           = show,
        hide           = hide,
        isShowing      = isShowing,
        reset          = reset,

        TOGETHER       = "together"
    }

end
