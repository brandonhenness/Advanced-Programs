-- Advanced Tunnel by Henness
-- Version 1.3.4 1/4/2013

-- Config
Version = "v1.3.4"
HeightQuestion = true
WidthQuestion = true
LengthQuestion = true
TorchesQuestion = true

-- Functions
function version() -- Version function
	return Version
end

function clearscreen() -- Clearscreen function
	term.clear()
	regwrite( "Advanced Tunnel", 12, 1 )
	regwrite( version(), 2, 12 )
	regwrite( "Designed by Henness", 17, 12 )
	term.setCursorPos( 1, 3 )
end

function regwrite(string, columnVar, rowVar) -- Write a string to the cords
	term.setCursorPos( columnVar, rowVar )
	write (string)
end

function arcwrite(number, columnVar, rowVar) -- Write a number "right to left" to the cords
	digits = math.ceil(math.log10(number))
	if 10^digits == number then
		digits = digits + 1
	end
	term.setCursorPos( columnVar, rowVar )
	while digits > 1 do
		digits = digits - 1
		columnVar = columnVar - 1
		term.setCursorPos( columnVar, rowVar )
	end
	write (number)
end

function createtable() -- Make a table function
clearscreen()
print ( [[
 +--------------------------------+
 |Blocks Mined:                 0 |
 |Torches Placed:               0 |
 +--------------------------------+
 |             Status             |
 |[                              ]|
 |                0%              |
 +--------------------------------+
]] )
placedValue = 0
minedValue = 0
end

function updatetable() -- Update the table
	-- Update Blocks Mined
	minedValue = minedValue + 1
	arcwrite(minedValue, 33, 4)
	
	-- Update Percentage
	if length > 0 then
		area = (height * width * length)
	else
		area = minedValue
	end
	percentage = math.ceil((minedValue / area) * 100)
	arcwrite(percentage, 19, 9)
	
	-- Update Percentage Bar
	percentageBar = math.floor(percentage * 0.3)
	columnVar = 4
	while percentageBar > 0 do
		regwrite( "=", columnVar, 8 )
		percentageBar = percentageBar - 1
		columnVar = columnVar + 1
	end
end

function placetorch() -- Place a torch
	if torches == true then
		if lengthSpacingVar == 0 and ( spaceFromWallVar == 0 or widthSpacingVar == 0 ) then
			turtle.placeDown()
			if turtle.getItemCount(1) == 0 then
				noTorches = true
			end
			spaceFromWallVar = -1
			widthSpacingVar = widthSpacing
			-- Update Torches Placed
			placedValue = placedValue + 1
			arcwrite(placedValue, 33, 5)
		else
			spaceFromWallVar = spaceFromWallVar - 1
			widthSpacingVar = widthSpacingVar - 1
		end
	end
end

function widthtest() -- Test width for numbers that = 4+10n
	widthTestVar = width
	while widthTestVar > 4 do
		widthTestVar = widthTestVar - 10
	end
	if widthTestVar == 4 then
		return true
	end
end

function setspacing() -- Calculate spacing of torches
	if width < 6 then
		if math.fmod( width, 2 ) == 0 then -- If even
			if width == 2 then
				lengthSpacing = 9
				spaceFromWall = ( 1 + ( -1 )^placedValue ) / 2
			else
				lengthSpacing = 7
				spaceFromWall = (( 1 + ( -1 )^placedValue ) / 2 ) + 1
			end
		else -- If odd
			spaceFromWall = math.floor( width / 2 )
			if width == 5 then
				lengthSpacing = 6
			elseif width == 3 then
				lengthSpacing = 8
			else
				lengthSpacing = 10
			end
		end
		widthSpacing = -1
	else
		if math.fmod( width, 2 ) == 0 then -- If even
			widthSpacing = 4
			lengthSpacing = 4
			if widthtest() == true or width == 6 then
				spaceFromWall = 0			
			else
				spaceFromWallVar = width
				while spaceFromWallVar > 7 do
					spaceFromWallVar = spaceFromWallVar - ( widthSpacing + 1 )
				end
				spaceFromWall = ( spaceFromWallVar - 1 ) / 2
			end
		else -- If odd
			widthSpacing = 5
			lengthSpacing = 4
			if width == 7 then
				spaceFromWall = 0
			else
				spaceFromWallVar = width
				while spaceFromWallVar > 7 do
					spaceFromWallVar = spaceFromWallVar - ( widthSpacing + 1 )
				end
				spaceFromWall = ( spaceFromWallVar - 1 ) / 2
			end
		end
	end
	spaceFromWallVar = spaceFromWall
	widthSpacingVar = widthSpacing
	lengthSpacingVar = lengthSpacing
end

function digdown() -- Dig down and update the table
	if turtle.detectDown() then
		turtle.digDown()
	end
	updatetable()
end

function digup() -- Dig up and update the table
	while turtle.detectUp() do
		turtle.digUp()
		sleep(0.5)
	end
	updatetable()
end

function digforward() -- Dig forward and update the table
	local moved = moveforward()
	if not moved and turtle.detect() then
		repeat turtle.dig() until moveforward()
		local moved = true
	elseif not moved and not turtle.detect() then
		repeat turtle.attack() until moveforward()
	end
	updatetable()
end

function moveforward() -- Move forward
	return turtle.forward()
end

function largetunnel() -- Mine a tunnel larger then one wide
	widthvar = width - 1
	while widthvar > 0 do
 		if tunnelheight == 1 then
			digdown()
			placetorch()
			moveforward()
		end 
		if tunnelheight == 2 then
			digdown()
			placetorch()
			digforward()
		end
 		if tunnelheight == 3 then
			digup()
			digdown()
			placetorch()
			digforward()
		end
		if tunnelheight > 3 then
			digup()
			digdown()
			digforward()
		end 
		widthvar = widthvar - 1
	end
	if tunnelheight == 1 then
		digdown()
		tunnelheight = tunnelheight - 1
	elseif tunnelheight == 2 then
		digdown()
		tunnelheight = tunnelheight - 2
	elseif tunnelheight == 3 then
		digup()
		digdown()
		tunnelheight = tunnelheight - 3
	else
		digup()
		digdown()
		tunnelheight = tunnelheight - 3
		if tunnelheight == 1 then
			turtle.down()
		end
		if tunnelheight == 2 then
			turtle.down()
			digdown()
			turtle.down()
		end
		if tunnelheight >= 3 then
			turtle.down()
			digdown()
			turtle.down()
			digdown()
			turtle.down()
		end
	end
end

function smalltunnel() -- Mine a one wide tunnel
	if tunnelheight == 2 then
		digdown()
	end
	if tunnelheight == 3 then
		digup()	
		digdown()
	end
	if tunnelheight > 3 then
		digup()
		digdown()
		turtle.down()
		tunnelheight = tunnelheight - 3
		while tunnelheight > 1 do
			digdown()
			turtle.down()
			tunnelheight = tunnelheight - 1
		end
		digdown()
	end
	placetorch()
end

-- Questions
clearscreen()
while HeightQuestion == true do -- Height Question
	print("Height of tunnel?")
	height = tonumber(read())
	clearscreen()
	if height == nil then
		print( "Please answer with a number." )
	elseif height >= 2 then
		HeightQuestion = false
		startheight = height - 3
	elseif height == 1 then
		print( "The tunnel height must be larger than one." )
	elseif height == 0 then
		print( "The tunnel height can't be infinite." )
	else
		print( "The tunnel height must be positive." )
	end
end

clearscreen()
while WidthQuestion == true do -- Width Question
	print("Width of tunnel?")
	width = tonumber(read())
	clearscreen()
	if width == nil then
		print( "Please answer with a number." )
	elseif width > 0 then
		WidthQuestion = false
	elseif width == 0 then
		print( "The tunnel width can't be infinite." )
	else
		print( "The tunnel width must be positive." )
	end
end

clearscreen()
while LengthQuestion == true do -- Length Question
	print("Length of tunnel?")
	length = tonumber(read())
	clearscreen()
	if length == nil then
		print( "Please answer with a number." )
	elseif length > 0 then
		LengthQuestion = false
		lengthVar = 0	
	elseif length == 0 then
		LengthQuestion = false
		Infinitelength = true
		TorchesQuestion = false
		TorchSpacingQuestion = false
		lengthVar = (-1)
	else
		print( "The tunnel length must be positive." )
	end
end

clearscreen()
while TorchesQuestion == true do -- Torch Question
	print("Place torches?")
	light = string.lower(read())
	clearscreen()
	if light == ( 'yes' ) then
		if turtle.getItemCount(1) == 0 then
			print("Please place torches in the first inventory slot.")
		else
		torches = true
		TorchesQuestion = false
		noTorches = false
		setspacing()
		lengthSpacingVar = 0
		end
	elseif light == ( 'no' ) then
		torches = false
		TorchesQuestion = false
	else
		print("Please answer yes or no.")
	end
end

-- Create the gui
createtable()

-- Mining Loop
turtle.up()
while startheight > 0 do
	local moved = turtle.up()
	if not moved and turtle.detectUp() then
		repeat turtle.digUp() until turtle.up()
		local moved = true
	elseif not moved and not turtle.detectUp() then
		repeat turtle.attackUp() until turtle.up()
	end
	startheight = startheight - 1
end
while lengthVar < length do
	lengthVar = lengthVar + 1
	digforward()
	if width > 1 then
		turtle.turnRight()
	end

	-- Mine a one wide tunnel or a larger tunnel.
	tunnelheight = height
	if width > 1 then
		while tunnelheight > 0 do
			largetunnel()
			turtle.turnRight()
			turtle.turnRight()
			if tunnelheight > 0 then
				largetunnel()
				if tunnelheight > 0 then
					turtle.turnRight()
					turtle.turnRight()
				end
			else
				widthvar = width - 1
				while widthvar > 0 do
					moveforward()
					widthvar = widthvar - 1
				end
			end
		end
	else
		smalltunnel()
	end
	if torches == true then
		if lengthSpacingVar == 0 then
			spaceFromWallVar = spaceFromWall
			widthSpacingVar = widthSpacing
			lengthSpacingVar = lengthSpacing
		else
			spaceFromWallVar = spaceFromWall
			widthSpacingVar = widthSpacing
			lengthSpacingVar = lengthSpacingVar - 1
		end
	end
	startheight = height - 3
	while startheight > 0 do
		turtle.up()
		startheight = startheight - 1
	end

	-- Infinite Length
	if Infinitelength == true then
		lengthVar = lengthVar - 1
	end

	-- Stop or Continue
	if lengthVar == length or noTorches == true then
		if width > 1 then
			turtle.turnLeft()
		else
			turtle.turnRight()
			turtle.turnRight()
		end
		while lengthVar > 0 do
			moveforward()
			lengthVar = lengthVar - 1
		end
		while startheight < ( height - 3 ) do
			turtle.down()
			startheight = startheight + 1
		end
		turtle.turnLeft()
		turtle.turnLeft()
		lengthVar = length
		term.setCursorPos( 1, 11 )
		if noTorches == true then
			print ("Out of Torches!")
		else
			print ("Tunnel Complete!")
		end
		term.setCursorPos( 1, 2 )
	else
		if width > 1 then
			turtle.turnRight()
		end
	end
end