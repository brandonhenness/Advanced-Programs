-- Advanced Ore Finder by Henness
-- Version 3.1 1/12/2014

-- Config
local program = "Advanced Orefinder"
local version = "v3.1"
local author = "Henness"
local tSave = {}

local ores_mined, tCordsInput, select, screenw, screenh, fuel_level, _sFile

screenw,screenh = term.getSize()

-- Functions

--[[
	Most of the loc movement functions were written by Mikeemoo,
	for his killer program. If you would like to see his program
	you can download it from: http://pastebin.com/UCES36jD
]]

local loc = {}
loc = {
	paused = false,
	
	x = 0,
	y = 0,
	z = 0,
	facing = 0,
	
	facingToAxis = {
		[0] = { axis = 'z', unit = 1 },
		[1] = { axis = 'x', unit = -1 },
		[2] = { axis = 'z', unit = -1 },
		[3] = { axis = 'x', unit = 1 }
	},
	
	pause = function()
		while loc.paused do
			sleep(1)
		end
	end,
	
	getAxisForFacing = function()
		return loc.facingToAxis[loc.facing]['axis'], loc.facingToAxis[loc.facing]['unit']
	end,

	turnLeft = function()
		loc.pause()
		loc.facing = (loc.facing - 1) % 4
		turtle.turnLeft()
	end,

	turnRight = function()
		loc.pause()
		loc.facing = (loc.facing + 1) % 4
		turtle.turnRight()
	end,

	moveForward = function()
		loc.pause()
		if turtle.forward() then
			local axis, unit = loc.getAxisForFacing()
			loc[axis] = loc[axis] + unit
			return true
		end
		return false
	end,
	
	moveBack = function()
		loc.pause()
		if turtle.back() then
			local axis, unit = loc.getAxisForFacing()
			loc[axis] = loc[axis] - unit
			return true
		end
		return false
	end,

	face = function(faceto)
		local dirdif = (faceto - loc.facing) % 4
		if dirdif == 1 then
			loc.turnRight()
		elseif dirdif == 2 then
			loc.turnRight()
			loc.turnRight()
		elseif dirdif == 3 then
			loc.turnLeft()
		end
	end,

	movez = function(d)
		if d < loc.z then loc.face(2) elseif d > loc.z then loc.face(0) end
		return loc.moveForward()
	end,

	movex = function(d)
		if d < loc.x then loc.face(1) elseif d > loc.x then loc.face(3) end
		return loc.moveForward()
	end,

	movey = function(d)
		if d < loc.y then
			return loc.moveDown()
		end
		return loc.moveUp()
	end,

	moveUp = function()
		loc.pause()
		if turtle.up() then
			loc.y = loc.y + 1
			return true
		end
		return false
	end,

	moveDown = function()
		loc.pause()
		if turtle.down() then
			loc.y = loc.y - 1
			return true
		end
		return false
	end,

	moveTo = function(x, y, z, facing)
		if y > loc.y then
			while loc.y < y do
				while not loc.moveUp() do
					if turtle.detectUp() then
						turtle.select(1)
						turtle.digUp()
					else
						turtle.attackUp()
					end
				end
			end
		end
		while x ~= loc.x do
			while not loc.movex(x) do
				if turtle.detect() then
					turtle.select(1)
					turtle.dig()
				else
					turtle.attack()
				end
			end
		end
		while z ~= loc.z do
			while not loc.movez(z) do
				if turtle.detect() then
					turtle.select(1)
					turtle.dig()
				else
					turtle.attack()
				end
			end
		end
		if y < loc.y then
			while loc.y > y do
				while not loc.moveDown() do
					if turtle.detectDown() then
						turtle.select(1)
						turtle.digDown()
					else
						turtle.attackDown()
					end
				end
			end
		end
		loc.face(facing)
		return true
	end,
	
	moveToPos = function(pos)
		return loc.moveTo(pos.x, pos.y, pos.z, pos.facing)
	end,

	distanceTo = function(x, y, z)
		return math.abs(x) - loc.x + math.abs(y) - loc.y + math.abs(z) - loc.z
	end, 

	distanceToPos = function(pos)
		return loc.distanceTo(pos.x, pos.y, pos.z)
	end
}

-- Orefinder
function saveTable(table,name)
	local file = fs.open(name,"w")
	file.write(textutils.serialize(table))
	file.close()
end

function loadTable(name)
	local file = fs.open(name,"r")
	local data = file.readAll()
	file.close()
	return textutils.unserialize(data)
end

function moveDown(h)
	while not loc.movey(h) do
		if turtle.detectDown() then
			turtle.digDown()
			if turtle.detectDown() then
				return false
			end
		else
			turtle.attackDown()
		end
	end
	return true
end

function compareForward(a, b)
	loc.pause()
	for i=a,b do
		turtle.select(i)
		if turtle.compare() then
			return false
		end				
	end
	return true
end

function findDown(d)
	if not d then d = loc.y end
	local h = loc.y - d
	while loc.y ~= h do
		if not moveDown(h) then
			break
		end
		for j=1,4 do
			if compareForward(1, tSave.ignore) then
				if not space() then
					returnToChest()
				end
				turtle.select(1)
				turtle.dig()
				ores_mined = ores_mined + 1
			end
			loc.turnRight()
		end
	end
end

function refuel(ammount)
	if turtle.getFuelLevel() == "unlimited" then
		return true
	end
	local needed = ammount or loc.distanceToPos(tSave.startPos) * 2 + 1
	if turtle.getFuelLevel() < needed then
		for n=tSave.ignore+1,16 do
			loc.pause()
			if turtle.getItemCount(n) > 0 then
				turtle.select(n)
				if turtle.refuel(1) then
					while turtle.getItemCount(n) > 0 and turtle.getFuelLevel() < needed do
						turtle.refuel(1)
					end
					if turtle.getFuelLevel() >= needed then
						turtle.select(1)
						return true
					end
				end
			end
		end
		turtle.select(1)
		return false
	end
	return true
end

function unload()
	for n=1,16 do
		loc.pause()
		if turtle.getItemCount(n) > 0 then
			turtle.select(n)
			if n <= tSave.ignore then
				if (not tSave.safemode  and n == 1) or n > 1 then
					turtle.drop(turtle.getItemCount(n) - 1)
				end
			else
				turtle.drop()
			end
		end
	end
	turtle.select(1)
end

function space()
	for n=1,16 do
		if turtle.getItemCount(n) == 0 then
			return true
		end
	end
	return false
end

function returnToChest()
	local returnPos = {x = loc.x, y = loc.y, z = loc.z, facing = loc.facing}
	local fuelNeeded = loc.distanceToPos(tSave.startPos) * 2 + 1
	loc.moveToPos(tSave.startPos)
	loc.face((loc.facing + 2) % 4)
	if not refuel(fuelNeeded) then
		unload()
		while not refuel(fuelNeeded) do
			loc.pause()
			sleep(1)
		end
	else
		unload()	
	end
	loc.moveToPos(returnPos)
end

function forward()
	if not space() then
		returnToChest()
	end
	while not loc.moveForward() do
		if turtle.detect() then
			turtle.select(1)
			turtle.dig()
		else
			turtle.attack()
		end
	end
end

function oreFinder()
	loc.moveToPos(tSave.returnPos)
	while tSave.w <= tSave.width do
		while tSave.l <= tSave.length do
			if not refuel() or not space() then
				returnToChest()
			end
			if math.fmod((loc.x + 4) - (loc.z - 1) * 2, 5) == 0 then
				tSave.returnPos = {x = loc.x, y = loc.y, z = loc.z, facing = loc.facing}
				saveTable( tSave, _sFile )
				findDown()
				loc.moveToPos(tSave.returnPos)
				if tSave.safemode then
					turtle.select(1)
					turtle.placeDown()
				end
			end
			turtle.select(1)
			turtle.digUp()
			if tSave.l ~= tSave.length then
				forward()
			elseif tSave.l == tSave.length and tSave.w ~= tSave.width then
				if loc.facing == tSave.startPos.facing then
					loc.turnRight()
					forward()
					loc.turnRight()
				else
					loc.turnLeft()
					forward()
					loc.turnLeft()
				end
			end
			tSave.l = tSave.l + 1
		end
		tSave.w = tSave.w + 1
		tSave.l = 1
	end
	loc.moveToPos(tSave.startPos)
	returnToChest()
	fs.delete(_sFile)
	return true
end

-- GUI
function printNormal(str, xpos, ypos)
	term.setCursorPos(xpos, ypos)
	term.write (str)
end

function printReverse(str, xpos, ypos)
	term.setCursorPos(xpos - (#str-1), ypos)
	term.write (str)
end

function printLeft(str, ypos)
	term.setCursorPos(1, ypos)
	term.write(str)
end

function printCentered(str, ypos)
	term.setCursorPos(screenw/2 - #str/2 + 1, ypos)
	term.write(str)
end

function printRight(str, ypos)
	term.setCursorPos(screenw - #str, ypos)
	term.write(str)
end

function readLines( sLines, _sReplaceChar )
	term.setCursorBlink( true )
	local w, h = term.getSize()
	local nPos = 0
	local nSelect = 1
	local vSelect = 1
	local function redraw( _sCustomReplaceChar )
		local nScroll = 0
		if sLines[nSelect].sx + nPos >= w then
			nScroll = (sLines[nSelect].sx + nPos) - w
		end
		term.setCursorPos( sLines[nSelect].sx, sLines[nSelect].sy )
		local sReplace = _sCustomReplaceChar or _sReplaceChar
		if sReplace then
			term.write( string.rep(sReplace, string.len(sLines[nSelect].text) - nScroll) )
		else
			term.write( string.sub( sLines[nSelect].text, nScroll + 1 ) )
		end
		term.setCursorPos( sLines[nSelect].sx + nPos - nScroll, sLines[nSelect].sy )
	end
	for nVar, tVar in ipairs(sLines) do
		nSelect = nVar
		redraw()
		if tVar.text ~= "" then
			vSelect = nVar
		end
	end
	nSelect = vSelect
	nPos = #sLines[nSelect].text
	redraw()
	while true do
		local sEvent, param = os.pullEvent()
		if sEvent == "char" then
			sLines[nSelect].text = string.sub( sLines[nSelect].text, 1, nPos ) .. param .. string.sub( sLines[nSelect].text, nPos + 1 )
			nPos = nPos + 1
			redraw()
		elseif sEvent == "key" then
			if param == keys.enter then
				-- Enter
				if nSelect < #sLines then
					nSelect = nSelect + 1
					if sLines[nSelect].text == "" then
						nPos = 0
					else
						nPos = #sLines[nSelect].text
					end
					redraw()
				else
					break
				end
			elseif param == keys.left then
				-- Left
				if nPos > 0 then
					nPos = nPos - 1
					redraw()
				end
			elseif param == keys.right then
				-- Right				
				if nPos < string.len(sLines[nSelect].text) then
					nPos = nPos + 1
					redraw()
				end
			elseif param == keys.up or param == keys.down then
				-- Up or down
				if param == keys.up then
					-- Up
					if nSelect > 1 then
						nSelect = nSelect - 1
						if sLines[nSelect].text == "" then
							nPos = 0
						else
							nPos = #sLines[nSelect].text
						end
						redraw()
					end
				else
					-- Down
					if nSelect < #sLines then
						nSelect = nSelect + 1
						if sLines[nSelect].text == "" then
							nPos = 0
						else
							nPos = #sLines[nSelect].text
						end
						redraw()
					else
						break
					end
				end
				redraw()
			elseif param == keys.backspace then
				-- Backspace
				if nPos > 0 then
					redraw(" ");
					sLines[nSelect].text = string.sub( sLines[nSelect].text, 1, nPos - 1 ) .. string.sub( sLines[nSelect].text, nPos + 1 )
					nPos = nPos - 1					
					redraw()
				end
			elseif param == keys.home then
				-- Home
				nPos = 0
				redraw()		
			elseif param == keys.delete then
				if nPos < string.len(sLines[nSelect].text) then
					redraw(" ");
					sLines[nSelect].text = string.sub( sLines[nSelect].text, 1, nPos ) .. string.sub( sLines[nSelect].text, nPos + 2 )				
					redraw()
				end
			elseif param == keys["end"] then
				-- End
				nPos = string.len(sLines[nSelect].text)
				redraw()
			end
		end
	end
	term.setCursorBlink( false )
	return sLines
end

local function findModem()
  for _, v in pairs( rs.getSides() ) do
        if peripheral.isPresent( v ) and peripheral.getType( v ) == "modem" then
          return true, v
        end
  end
  return false, nil
end

local function locate()
	local x,y,z,facing
	local exist, side = findModem()
	if exist then
		rednet.open(side)
		printCentered("Receiving coordinates from host...", 4)
		x,y,z = gps.locate(3)
		if x and y and z then
			forward()
			local tmpx,tmpy,tmpz = gps.locate(3)
			if tmpx > x then
				facing = 3
			elseif tmpx < x then
				facing = 1
			elseif tmpz > z then
				facing = 0
			elseif tmpz < z then
				facing = 2
			end
			printCentered("At:"..x.."/"..y.."/"..z.."/"..facing,3)
			loc.moveBack()
			return x,y,z,facing
		else
			printCentered("Unable to get GPS cords.  Please,", 3)
			printCentered("enter the turtles cords manually.", 4)
		end
	else
		printCentered("No wireless modem found, please", 3)
		printCentered("enter the cords manualy.", 4)
	end
	printLeft("     x: ", 6)
	printLeft("     y: ", 7)
	printLeft("     z: ", 8)
	printLeft("  face: ", 9)
	while true do
		readLines( tCordsInput )
		x,y,z,facing = tonumber(tCordsInput[1].text),tonumber(tCordsInput[2].text),tonumber(tCordsInput[3].text),tonumber(tCordsInput[4].text)
		if x ~= nil and y ~= nil and y > 0 and y < 256 and z ~= nil and facing ~= nil and facing < 4 and facing >= 0 then
			return x,y,z,facing
		end
	end
end

local function drawHeader()
	printCentered(program, 1)
	printLeft(string.rep("-", screenw), 2) 
	printLeft("["..version.."]"..string.rep("-", screenw-#author-#version-7).."[by "..author.."]", screenh)
end

local function drawMainMenu()
	term.clear()
	drawHeader()
	printLeft(string.rep("-", screenw), screenh-2)
	if loc.paused then
		if select == 1 then
			printCentered("[RESUME]  REFUEL   SAVE   EXIT ", screenh-1)
		elseif select == 2 then
			printCentered(" RESUME  [REFUEL]  SAVE   EXIT ", screenh-1)
		elseif select == 3 then
			printCentered(" RESUME   REFUEL  [SAVE]  EXIT ", screenh-1)
		elseif select == 4 then
			printCentered(" RESUME   REFUEL   SAVE  [EXIT]", screenh-1)
		end
	else
		printCentered("[PAUSE]", screenh-1)
	end
end

local function drawGPSMenu()
	if select == 2 then
		printCentered("[DONE]", screenh-1)
	elseif select == 1 then
		term.clear()
		drawHeader()
		printLeft(string.rep("-", screenw), screenh-2)
		printCentered(" DONE ", screenh-1)
		loc.x,loc.y,loc.z,loc.facing = locate()
		select = 2
		drawGPSMenu()
	end
end

local function drawRefuelMenu()
	local refuelList = {
		"+-------------------------------+",
		"|    Are you sure you want to   |",
		"|       refuel the turtle.      |",
		"|                               |",
		"|        YES          NO        |",
		"+-------------------------------+"
	}
	for i=1,#refuelList do
		if i == #refuelList-1 then
			if select == 1 then
				printCentered("|       [YES]         NO        |", 3 + i)
			elseif select == 2 then
				printCentered("|        YES         [NO]       |", 3 + i)
			end
		else
			printCentered(refuelList[i], 3 + i)
		end
	end
end

local function drawRefuel()
	local refuelList = {
		"+-------------------------------+",
		"|      Turtle fuel level is     |",
		"|                               |",
		"|                               |",
		"|              OK               |",
		"+-------------------------------+"
	}
	for i=1,#refuelList do
		if i == #refuelList-1 then
			printCentered("|             [OK]              |", 3 + i)
		elseif i == #refuelList-3 then
			printCentered(refuelList[i], 3 + i)
			printCentered(fuel_level, 3 + i)
		else
			printCentered(refuelList[i], 3 + i)
		end
	end
end

local function drawSaveMenu()
	local saveList = {
		"+-------------------------------+",
		"|    Would you like to save?    |",
		"|                               |",
		"|                               |",
		"|        YES          NO        |",
		"+-------------------------------+"
	}
	for i=1,#saveList do
		if i == #saveList-1 then
			if select == 1 then
				printCentered("|       [YES]         NO        |", 3 + i)
			elseif select == 2 then
				printCentered("|        YES         [NO]       |", 3 + i)
			end
		else
			printCentered(saveList[i], 3 + i)
		end
	end
end

local function drawExitMenu()
	local exitList = {
		"+-------------------------------+",
		"|    Would you like to save     |",
		"|        before exiting?        |",
		"|                               |",
		"|        YES          NO        |",
		"+-------------------------------+"
	}
	for i=1,#exitList do
		if i == #exitList-1 then
			if select == 1 then
				printCentered("|       [YES]         NO        |", 3 + i)
			elseif select == 2 then
				printCentered("|        YES         [NO]       |", 3 + i)
			end
		else
			printCentered(exitList[i], 3 + i)
		end
	end
end

local function drawResultMenu()
	local resultList = {
		"+-------------------------------+",
		"|                               |",
		"|    Ores mined this session!   |",
		"|                               |",
		"|             [OK]              |",
		"+-------------------------------+"
	}
	for i=1,#resultList do
		if i == #resultList-1 then
			printCentered("|             [OK]              |", 3 + i)
		elseif i == #resultList-4 then
			printCentered(resultList[i], 2 + i)
			printCentered(ores_mined, 2 + i)
		else
			printCentered(resultList[i], 3 + i)
		end
	end
end

local function runOreFinder(_sSave)
	tSave = {}
	tSave = loadTable(_sSave)
	local menustate = "gpsmenu"
	local function rungui()
		local mopt = {
			["main"] = {
				options = {"toggle_pause", "refuelmenu", "savemenu", "exitmenu"},
				draw = drawMainMenu
			},
			["gpsmenu"] = {
				options = {"locate", "exit"},
				draw = drawGPSMenu
			},
			["refuelmenu"] = {
				options = {"refuel", "main"},
				draw = drawRefuelMenu
			},
			["refuel"] = {
				options = {"main"},
				draw = drawRefuel
			},
			["savemenu"] = {
				options = {"save", "main"},
				draw = drawSaveMenu
			},
			["exitmenu"] = {
				options = {"save_exit", "exit"},
				draw = drawExitMenu
			},
			["resultmenu"] = {
				options = {"exit"},
				draw = drawResultMenu
			}
		}
		tCordsInput = {
			{text = "", sx = 9, sy = 6},
			{text = "", sx = 9, sy = 7},
			{text = "", sx = 9, sy = 8},
			{text = "", sx = 9, sy = 9}
		}
		select = 1
		fuel_level = tostring(turtle.getFuelLevel())
		ores_mined = 0
		while true do
			mopt[menustate].draw()
			local sEvent, param = os.pullEvent()
			if sEvent == "key" then
				if param == keys.up and select > 1 then
					select = select-1
				elseif param == keys.down and select < #mopt[menustate].options then
					if loc.paused then
						select = select+1
					end
				elseif param == keys.left and select > 1 then
					select = select-1
				elseif param == keys.right and select < #mopt[menustate].options then
					if loc.paused then
						select = select+1
					end
				elseif param == keys.enter then
					if mopt[menustate].options[select] == "save" or mopt[menustate].options[select] == "save_exit" then
						saveTable(tSave, _sSave)
						if mopt[menustate].options[select] == "save_exit" then
							break
						end
						menustate = "main"
					elseif mopt[menustate].options[select] == "exit" then
						break
					elseif mopt[menustate].options[select] == "toggle_pause" then
						if loc.paused then
							loc.paused = false
						else
							loc.paused = true
						end
					elseif mopt[menustate].options[select] == "refuel" then
						if turtle.getFuelLevel() ~= "unlimited" then
							for i=tSave.ignore+1,16 do
								if turtle.getItemCount(i) > 0 then
									turtle.select(i)
									turtle.refuel(turtle.getItemCount(i))
								end
							end
							turtle.select(1)
						end
						fuel_level = tostring(turtle.getFuelLevel())
						menustate = mopt[menustate].options[select]
						select = 1
					else
						menustate = mopt[menustate].options[select]
						select = 1
					end
				end
			end
		end
	end
	rungui()
	menustate = "main"
	if not tSave.startPos then
		tSave.startPos = {x = loc.x, y = loc.y, z = loc.z, facing = loc.facing}
		tSave.returnPos = {x = loc.x, y = loc.y, z = loc.z, facing = loc.facing}
	end
	saveTable(tSave, _sFile)
	parallel.waitForAny(oreFinder, rungui)
	if not fs.exists(_sFile) then
		menustate = "resultmenu"
		rungui()
	end
end

local tArgs = { ... }
if turtle.getFuelLevel() > 0 or turtle.getFuelLevel() == "unlimited" then
	if #tArgs == 1 then
		_sFile = tostring(tArgs[1])
		if fs.exists(_sFile) then
			runOreFinder(_sFile)
			term.setCursorPos(1,1)
			term.clear()
		end
	else
		error("Usage: advancedorefinder <save file>")
	end
else
	error("Error, there must be fuel in the turtle!")
end