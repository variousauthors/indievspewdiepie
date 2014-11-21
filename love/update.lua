
function love.update(dt)

    --Update here
    for i, ship in pairs(game.ships) do
    end

    -- player update
    local player = game.player
    local fx, fy, vx, vy, x, y

    fx, fy = 0, 0
    vx, vy = player.vx, player.vy
    x, y = player.x, player.y
    m = player.m

    -- calculate control forces
    if game.player.up == true then fy = fy - 1000 end
    if game.player.down == true then fy = fy + 1000 end
    if game.player.left == true then fx = fx - 1000 end
    if game.player.right == true then fx = fx + 1000 end

    -- calculate other forces

    -- F = ma
    vx, vy = vx + (fx/m)*dt, vy + (fy/m)*dt

    -- cap the magnitude of velocity
    local square_magnitude = math.pow(vx, 2) + math.pow(vy, 2)
    if  square_magnitude > player.square_max_speed then
        local theta = math.atan2(vy, vx)
        local mag = player.max_speed

        vx = mag*math.cos(theta)
        vy = mag*math.sin(theta)
    end

    print(vx, vy, math.sqrt(math.pow(vx, 2) + math.pow(vy, 2)), player.max_speed)

    player.vx = vx
    player.vy = vy
    player.x = x + vx*dt
    player.y = y + vy*dt

    -- camera update
    local cx = love.viewport.getWidth() / 2
    local cy = love.viewport.getHeight() / 2

    -- coords of the player relative to the origin
    local px, py = player.x, player.y

    game.camera.x = cx - px
    game.camera.y = cy - py
end
