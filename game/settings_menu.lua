
USERNAME = 0
TOKEN    = 1

return function ()
    local showing       = false
    local hide_callback = function () end
    local cursor_pos    = 0
    local menu_index    = 0
    local username      = ""
    local token         = ""
    local mode          = "STATIC"
    local time, flash   = 0, 0

    local inputs = {
        {   -- username
            clear      = function ()
                username = ""
                username_cursor_pos = 200
            end,
            textinput = function (key)
                username = username .. key
            end
        },
        {   -- token
            clear      = function ()
                token = ""
                token_cursor_pos = 200
            end,
            textinput = function (key)
                token = token .. key
            end
        }
    }

    local drawCursor = function (x, y)
        local icon = ""

        love.graphics.print(icon, x + cursor_pos, y)
    end

    local drawUsername = function (x, y)
        local icon = ""
        if flash == 0 and menu_index == USERNAME then icon = "_" end
        
        drawCursor(x, y)
        love.graphics.print(username .. icon, x, y)
    end

    local drawToken = function (x, y)
        local icon = ""
        if flash == 0 and menu_index == TOKEN then icon = "_" end

        drawCursor(x, y)
        love.graphics.print(token .. icon, x, y)
    end

    local drawMode = function (x, y)
        local left_icon  = ""
        local right_icon = ""

        if menu_index == MODE then
            left_icon  = "< "
            right_icon = " >"
        end

        drawCursor(x, y)
        love.graphics.print(left_icon .. mode .. right_icon, x, y)
    end

    local drawModeBlurb = function (x, y)
        if mode == "STATIC" then
            love.graphics.print("Think carefully about every move", x, y)
        else
            love.graphics.print("The path you choose will get brighter,\ngiving the fastest player an advantage", x, y)
        end
    end

    local drawSubtitle = function (x, y)
        love.graphics.setFont(SCORE_FONT)
        love.graphics.printf("there is a king in space, who lurks", x, y, 576, "right")
    end

    local drawTitle = function (x, y)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.print("GUNSHIP SOULS", x, y)
    end

    -- TODO redo this with proper nesting. SUCK GOAT.
    local title_part    = Component(0, 0, drawTitle)
    local subtitle_part = Component(0, 80, drawSubtitle)
    local talk1         = Component(30, 140, Component(0, 0, "Multiplayer Mode"))
    local mode_part     = Component(30, 170, Component(60, 0, drawMode))
    local mode_blurb    = Component(30, 200, Component(60, 0, drawModeBlurb))
    local talk2         = Component(30, 140, Component(0, 0, "GameJolt API integration"))
    local talk3         = Component(30, 170, Component(60, 0, "Sign in to upload your HIGH-SCORE to GameJolt!"))
    local username_part = Component(30, 200, Component(60, 0, "USERNAME"), Component(180, 0, drawUsername))
    local token_part    = Component(30, 230, Component(60, 0, "TOKEN"), Component(180, 0, drawToken))
    local controls_part = Component(30, 440, Component(0, 0, "Controls: to customize the controls, modify controls.lua"), Component(180, 0, drawToken))

    local component = Component(100, W_HEIGHT/2 - 200, title_part, subtitle_part, talk2, talk3, username_part, token_part)

    local draw = function ()
        component.draw(0, 0)
    end

    local update = function (dt)
        time = time + 2*dt
        flash = math.floor(time)%2
    end

    local writeProfile = function ()
        print("writeProfile")
        local hfile = love.filesystem.newFile("profile.lua", "w")
        if hfile == nil then return end

        hfile:write('return { username = "' .. username .. '", token = "' .. token .. '" }')

        hfile:close()
    end

    local findProfile = function ()
        print("findProfile")
        return love.filesystem.isFile("profile.lua")
    end

    local recoverProfile = function ()
        print("recoverProfile")
        local profile = love.filesystem.load("profile.lua")
        local status, result = pcall(profile)
        if status then return result end
    end

    local show = function (callback)
        hide_callback = callback
        showing = true

        if not showing then
            callback()
        end
    end

    local hide = function ()
        hide_callback({ mode = mode })
        showing = false
    end

    local isShowing = function ()
        return showing
    end

    local keypressed = function (key)
        if menu_index == TOKEN and key == "return" then
            writeProfile()

            hide()
        end

        if key == "down" or (key == "return" and menu_index < (#inputs - 1)) then
            menu_index = (menu_index + 1)%(#inputs)
            inputs[menu_index + 1].clear()
        end

        if key == "up" then
            menu_index = (menu_index - 1)%(#inputs)
            inputs[menu_index + 1].clear()
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

    return {
        draw           = draw,
        update         = update,
        keypressed     = keypressed,
        textinput      = textinput,
        show           = show,
        hide           = hide,
        recoverProfile = recoverProfile,
        isShowing      = isShowing
    }

end
