function drop_pip (pip)
    local x, y = pip.x, pip.y + 1

    -- iterate over the current column from the pip
    while (y <= game.height and game.board[y][x] ~= true) do
        pip.y = y
        y = y + 1
    end

    game.pip = nil
    game.board[pip.y][pip.x] = true
    clear_rows(pip.y)
end

function clear_rows (y)
    local pips = 0

    for i = 1, game.width, 1 do
        if (game.board[y][i]) then
            pips = pips + 1
        end
    end

    if (pips == game.width) then
        for i = 1, game.width, 1 do
            game.board[y][i] = false
        end

        -- move things down
        for yy = y, 1, -1 do
            for xx = 1, game.width, 1 do
            print(yy, xx)
                if (game.board[yy][xx] == true) then
                    -- move row down
                    local pip = game.board[yy][xx]
                    game.board[yy][xx] = false
                    game.board[yy + 1][xx] = true
                end
            end
        end
    end
end

function update_pip (pip, direction)
    -- check for a pip in the next square
    if (pip.y + 1 > game.height or game.board[pip.y + 1][pip.x] == true) then
        -- remove the pip and add to the board
        game.pip = nil
        game.board[pip.y][pip.x] = true
        clear_rows(pip.y)
    end

    if (direction ~= 0) then
        local p = pip.x + direction

        -- check for out of bounds
        p = math.max(math.min(game.width, p), 0)

        if (p ~= pip.x and game.board[p]) then
            if not (game.board[pip.y][p] == true) then
                pip.x = p
            end
        end
    end

    pip.y = math.min(game.height, pip.y + 1)
end

function next_pip ()
    return {
        x = game.width/2, y = 1, dim = game.scale
    }
end

function love.update (dt)
    game.time = game.time + dt

    if (game.time > game.step) then
        game.time = 0
        --if there is no pip make a pip
        --if there is a pip update it

        if (game.pip == nil) then
            game.pip = next_pip()
        else
            local player = game.player
            local direction = 0

            -- process an input from the buffer
            if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end
            if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
            if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end

            if (player.left) then direction = -1 end
            if (player.right) then direction = 1 end

            if (not player.up) then
                update_pip(game.pip, direction)
            else
                drop_pip(game.pip)
            end

            player.up = false
            player.left = false
            player.right = false

            player.input.up = {}
            player.input.left = {}
            player.input.right = {}
        end
    end
end
