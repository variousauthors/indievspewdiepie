-- FOR THE TIME BEING, THIS FILE IS DEFUNCT
-- DEFER TO GAME/DRAW

love.viewport = require('libs/viewport').newSingleton()

function draw_pip (pip)
    love.graphics.rectangle('fill', pip.x * game.scale, pip.y * game.scale, pip.dim, pip.dim)
end

function draw_board ()
    local i, j

    for y = 1, #(game.board) do
        for x = 1, #(game.board[y]) do
            if (game.board[y][x] == true) then
                love.graphics.rectangle('fill', x * game.scale, y * game.scale, game.scale, game.scale)
            end
        end
    end

    love.graphics.rectangle('line', game.scale, game.scale, game.width * game.scale, game.height * game.scale)
end

function love.draw()

    if (game.pip ~= nil) then
        draw_pip(game.pip)
    end

    draw_board()
end
