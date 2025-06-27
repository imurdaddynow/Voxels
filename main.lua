function love.load()
    -- Load spritesheets
    walkRight = love.graphics.newImage("Sprites/Character/CharacterWalkRight.png")
    walkLeft = love.graphics.newImage("Sprites/Character/CharacterWalkLeft.png")

    -- Make sprites crisp (no smoothing)
    walkRight:setFilter("nearest", "nearest")
    walkLeft:setFilter("nearest", "nearest")

    -- Animation settings
    frame_width = 32   -- Set to your frame width
    frame_height = 48  -- Set to your frame height
    num_frames = 4     -- Set to your number of frames
    frame_time = 0.12  -- Seconds per frame

    -- Generate quads for each frame
    quadsRight = {}
    quadsLeft = {}
    for i = 0, num_frames - 1 do
        table.insert(quadsRight, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, walkRight:getDimensions()))
        table.insert(quadsLeft, love.graphics.newQuad(i * frame_width, 0, frame_width, frame_height, walkLeft:getDimensions()))
    end

    -- Animation state
    current_frame = 1
    timer = 0
    direction = "right"
    moving = false

    -- Character position
    x = 400
    y = 300
    speed = 120
    scale = 1.5 -- Reduced size, less blurry

    -- Load and set filter for dirt
    dirt = love.graphics.newImage("Sprites/World/grass.png")
    dirt:setFilter("nearest", "nearest")

    -- Calculate scaled dirt size to match character
    dirt_width = frame_width * scale
    dirt_height = frame_height * scale

    -- Scatter dirt tiles
    num_dirt = 20 -- Number of dirt tiles
    dirt_positions = {}
    math.randomseed(os.time())
    for i = 1, num_dirt do
        local x = math.random(0, love.graphics.getWidth() - dirt_width)
        local y = math.random(0, love.graphics.getHeight() - dirt_height)
        table.insert(dirt_positions, {x = x, y = y})
    end
end

function love.update(dt)
    moving = false
    local dx, dy = 0, 0

    if love.keyboard.isDown("d") then
        dx = dx + 1
        direction = "right"
        moving = true
    end
    if love.keyboard.isDown("a") then
        dx = dx - 1
        direction = "left"
        moving = true
    end
    if love.keyboard.isDown("w") then
        dy = dy - 1
        moving = true
    end
    if love.keyboard.isDown("s") then
        dy = dy + 1
        moving = true
    end

    -- Normalize diagonal movement
    if dx ~= 0 and dy ~= 0 then
        dx = dx / math.sqrt(2)
        dy = dy / math.sqrt(2)
    end

    x = x + dx * speed * dt
    y = y + dy * speed * dt

    if moving then
        timer = timer + dt
        if timer >= frame_time then
            timer = timer - frame_time
            current_frame = current_frame % num_frames + 1
        end
    else
        current_frame = 1 -- Idle frame
    end
end

function love.draw()
    -- Draw dirt tiles
    for _, pos in ipairs(dirt_positions) do
        love.graphics.draw(dirt, pos.x, pos.y, 0, scale, scale)
    end

    -- Draw character
    local quad, image
    if direction == "right" then
        image = walkRight
        quad = quadsRight[current_frame]
    else
        image = walkLeft
        quad = quadsLeft[current_frame]
    end
    love.graphics.draw(image, quad, x, y, 0, scale, scale)
end