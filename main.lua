function love.load()
	-- get screen width and height
	width, height = love.graphics.getDimensions()
	
	-- create a new font
	smallfont = love.graphics.newFont("neuropol.ttf", 50)
	largefont = love.graphics.newFont("neuropol.ttf", 200)
	
	-- sounds
	blip = love.audio.newSource("blip.wav", "static")
	
	-- score
	score = 0
	
	-- create a table to store food information
	food = {x = 448, y = 512}
	-- use eaten to increase snake size
	eaten = false
	
	-- create a table to store snake information
	size = 32
	snake = {
		{x = 320, y = 320},
		{x = 288, y = 320},
		{x = 256, y = 320}
	}
	
	-- direction of travel initially
	direction = "right"
	
	-- timer for updating snake movement 
	timer = 0
	-- miliseconds, smaller is faster
	movementdelay = 0.05
	
end

function love.update(dt)
	-- update timer
	timer = timer + dt

	-- Update the snake's movement if movementdelay is reached
	if timer > movementdelay then
		updatesnake(dt)
		timer = 0
	end
	-- update food
	updatefood()
end

function love.draw()
	-- draw snake
	drawsnake()
	-- draw food
	drawfood()
	-- draw score
	-- set color to white RGBA
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setFont(smallfont)
	love.graphics.print(score, width / 2 - 32, 10)
	
	if score == -1 then
		gameover()
	end
	
end

function updatesnake(dt)
	-- get user input change direction
	if love.keyboard.isDown("a") and direction ~= "right" then
		direction = "left"
	elseif love.keyboard.isDown("d") and direction ~= "left" then
		direction = "right"
	elseif love.keyboard.isDown("w") and direction ~= "down" then
		direction = "up"
	elseif love.keyboard.isDown("s") and direction ~= "up" then
		direction = "down"
	end

	-- create new segment based on direction	
	head = {}
	
	if direction == "left" then
		head = {x = snake[1].x - size, y = snake[1].y}  
	elseif direction == "right" then
		head = {x = snake[1].x + size, y = snake[1].y}
	elseif direction == "up" then
		head = {x = snake[1].x, y = snake[1].y - size}
	else 
		head = {x = snake[1].x, y = snake[1].y + size}
	end
	-- insert new head and pop off tail
	table.insert(snake, 1, head)
	if eaten == true then
		score = score + 1
		eaten = false
	else 
		table.remove(snake)
	end
	-- check snake head bounds
	if snake[1].x < 0 then
		score = -1	
	elseif snake[1].x > width - size then
		score = -1
	elseif snake[1].y < 0 then
		score = -1
	elseif snake[1].y > height - size then
		score = -1
	end
	-- check if snake hits itself
	for i = 2, #snake do
	   if snake[1].x < snake[i].x + size and 
	   snake[1].x + size > snake[i].x and
	   snake[1].y < snake[i].y + size and
	   snake[1].y + size > snake[i].y then
		score = -1
		end
	end
	
end

function drawsnake()
	-- loop through segments and draw each as rectangle
	for i = 1, #snake do
		-- set color to green RGBA
		love.graphics.setColor(0, 1, 0, 1)
		love.graphics.rectangle("fill", snake[i].x, snake[i].y, size, size)		
	end
end

function updatefood(dt)
	-- check if snake's head and food collide
	-- AABB check
	if food.x < snake[1].x + size and 
	   food.x + size > snake[1].x and
	   food.y < snake[1].y + size and
	   food.y + size > snake[1].y then
	   eaten = true
	   love.audio.play(blip)
	   food.x = math.random(1, width / 32 - 1) * 32
	   food.y = math.random(1, height / 32 - 1) * 32
	end
end

function drawfood()
	-- set color to red RGBA
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("fill", food.x, food.y, size, size)
end

function gameover()
	-- clear screen and print game over
	love.graphics.clear( )
	love.graphics.setFont(largefont)
	love.graphics.print("GAME", 100, 100)
	love.graphics.print("OVER", 400, 300)
	love.graphics.setFont(smallfont)
	love.graphics.print("Press SPACEBAR", 400, 600)
	-- if player presses spacebar restart
	if love.keyboard.isDown("space") then
		love.load()
	end
	
end