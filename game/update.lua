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

-- move the pip side to side
function move_pip (pip, direction)
    local x = pip.x + direction

    -- clamp the move
    x = math.max(math.min(game.width, x), 0)

    -- if the pip would move and the board contains the target space
    -- TODO this appears to be wrong since game.board[x] should be game.board[y][x]
    if (x ~= pip.x and game.board[x]) then

        -- check for collision
        if not (game.board[pip.y][x] == true) then
            pip.x = x
        end
    end
end

-- move the pip down one row
function step_pip (pip)
    -- check for a pip in the next square
    if (pip.y + 1 > game.height or game.board[pip.y + 1][pip.x] == true) then
        -- remove the pip and add to the board
        game.pip = nil
        game.board[pip.y][pip.x] = true
        clear_rows(pip.y)
    end

    pip.y = math.min(game.height, pip.y + 1)
end

function next_pip ()
    return {
        x = game.width/2, y = 1, dim = game.scale
    }
end

function love.update (dt)
    local player = game.player
    local direction = 0

    game.time = game.time + dt

    -- there should be a pip
    if (game.pip == nil) then
        game.pip = next_pip()
    end

    -- process input 4 times per step
    if (game.time > game.step/game.input_rate) then

        -- consume an input from the buffer
        if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
        if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end

        if (player.left) then direction = -1 end
        if (player.right) then direction = 1 end

        move_pip(game.pip, direction)

        player.up = false
        player.left = false
        player.right = false
    end

    -- move the piece down every step
    if (game.time > game.step) then
        game.time = 0

        if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end

        if (not player.up) then
            step_pip(game.pip)
        else
            drop_pip(game.pip)
        end

    end
end
