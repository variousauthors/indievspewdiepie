function drop_pip (pip)
    local x, y = pip.x, pip.y + 1

    -- iterate over the current column from the pip
    while (y <= game.height and game.board[y][x] == false) do
        pip.y = y
        y = y + 1
    end

    game.pip = nil
    game.board[pip.y][pip.x] = pip
    clear_pips(pip)
end

function clear_pips (pip)
    local y = pip.y
    local pips = 0
    local Q = {}
    local marked = {}
    local index = 1
    local color = pip.color

    pip.marked = true
    table.insert(marked, pip)
    table.insert(Q, pip)

    while (#(Q) > 0) do
        local curr = table.remove(Q, 1)

        for i, v in ipairs({ 1, -1 }) do
            if (game.board[curr.y][curr.x + v]) then
                local adj = game.board[curr.y][curr.x + v]

                if (not adj.marked and adj.color == pip.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                end
            end

            if (game.board[curr.y + v] and game.board[curr.y + v][curr.x]) then
                local adj = game.board[curr.y + v][curr.x]

                if (not adj.marked and adj.color == pip.color) then
                    adj.marked = true
                    table.insert(Q, adj)
                    table.insert(marked, adj)
                end
            end
        end
    end

    -- if we have at least 3 pips marked for removal,
    -- remove all marked pips
    for i,v in ipairs(marked) do
        v.marked = false

        if (#(marked) >= game.match_target) then
            game.board[v.y][v.x] = false

--          -- move things down
--          for yy = y, 1, -1 do
--              for xx = 1, game.width, 1 do
--                  if (game.board[yy][xx] ~= false) then
--                      -- move row down
--                      local pip = game.board[yy][xx]
--                      game.board[yy][xx] = false
--                      game.board[yy + 1][xx] = pip
--                  end
--              end
--          end
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
        if not (game.board[pip.y][x] ~= false) then
            pip.x = x
        end
    end
end

-- move the pip down one row
function step_pip (pip)
    -- check for a pip in the next square
    if (pip.y + 1 > game.height or game.board[pip.y + 1][pip.x] ~= false) then
        -- remove the pip and add to the board
        game.pip = nil
        game.board[pip.y][pip.x] = pip
        clear_pips(pip)
    else
        pip.y = math.min(game.height, pip.y + 1)
    end
end

function next_pip ()
    local index = math.random(1, 3)

    return {
        x = game.width/2,
        y = 1,
        dim = game.scale,
        color = game.colors[index],
        marked = false
    }
end

function love.update (dt)
    local player = game.player
    local direction = 0

    game.update_timer = game.update_timer + dt
    game.input_timer = game.input_timer + dt

    -- there should be a pip
    if (game.pip == nil) then
        game.pip = next_pip()
    end

    -- process one set of inputs then cooldown
    if (game.input_timer < game.step/game.input_rate) then
        game.player.has_input = false
        player.input.left = {}
        player.input.right = {}

    elseif (game.player.has_input) then
        game.player.has_input = false
        game.input_timer = 0

        -- consume an input from the buffer
        if #(player.input.left) > 0 then player.left = table.remove(player.input.left, 1) end
        if #(player.input.right) > 0 then player.right = table.remove(player.input.right, 1) end

        if (player.left) then direction = -1 end
        if (player.right) then direction = 1 end

        move_pip(game.pip, direction)

        player.left = false
        player.right = false
        player.input.left = {}
        player.input.right = {}
    else
        if #(player.input.up) > 0 then player.up = table.remove(player.input.up, 1) end

        if (player.up) then
            drop_pip(game.pip)
            game.update_timer = 0
        end

        player.up = false

        player.input.up = {}

    end

    -- move the piece down every step
    if (game.update_timer > game.step) then
        game.update_timer = 0
        step_pip(game.pip)
    end

end
