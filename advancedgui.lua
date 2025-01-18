-- Advanced GUI by Henness
-- Version 1.1 2/5/2013

-- Config
screenw,screenh = term.getSize()

-- Functions
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

function printReverse(str, xpos, ypos)
	term.setCursorPos(xpos - (#str-1), ypos)
	term.write (str)
end

function printForward(str, xpos, ypos)
	term.setCursorPos(xpos, ypos)
	term.write (str)
end

function printCentered(str, ypos)
	term.setCursorPos(screenw/2 - #str/2, ypos)
	term.write(str)
end

function printRight(str, ypos)
	term.setCursorPos(screenw - #str, ypos)
	term.write(str)
end

function printLeft(str, ypos)
	term.setCursorPos(1, ypos)
	term.write(str)
end

function drawHeader()
	local author = "[by Henness]"
	printCentered("Advanced Program's", 1)
	printCentered(string.rep("-", screenw), 2) 
	printCentered(string.rep("-", screenw-#author)..author, screenh)
end

function drawMain()
	term.clear()
	drawHeader()
	printLeft("  OreFinder", 4)
	printLeft("  Tunnel", 5)
	printLeft("  Exit", screenh-1)

	local ypos = 4
	if select == 2 then ypos = 5
	elseif select == 3 then ypos = screenh-1 end
	printLeft(">", ypos)
end

function drawOreFinder()
	term.clear()
	drawHeader()
	if fs.exists("ofpreset") then
		preset = loadTable("ofpreset")
	else
		preset = {
			[1] = {
				values = {"000", "000", "00", "00", "PRESET #1", "0"}
			},
			[2] = {
				values = {"000", "000", "00", "00", "PRESET #2", "0"}
			},
			[3] = {
				values = {"000", "000", "00", "00", "PRESET #3", "0"}
			}
		}
		saveTable(preset, "ofpreset")
	end

	local namea = preset[1].values[5]
	local nameb = preset[2].values[5]
	local namec = preset[3].values[5]
	printLeft("  Continue", 4)
	printLeft("  New", 5)
	printLeft("  "..namea, 7)
	printLeft("  "..nameb, 8)
	printLeft("  "..namec, 9)
	printLeft("  Back", screenh-1)
	for i=1,screenh-3 do
		printRight("|"..string.rep(" ", 21), i+2)
	end
	if select == 1 then
		printLeft(">", 4)
	elseif select == 2 then
		printLeft(">", 5)
	elseif select == 3 then
		local width = preset[1].values[1]
		local length = preset[1].values[2]
		local hours = preset[1].values[3]
		local minutes = preset[1].values[4]
		local ignore = preset[1].values[6]
		printLeft(">", 7)
		printRight("| "..namea..string.rep(" ", 20-#namea), 4)
		printRight("|   Size: "..string.rep("0", 3-#width)..width.."x"..string.rep("0", 3-#length)..length..string.rep(" ", 5), 6)
		printRight("|   Time:  "..string.rep("0", 2-#hours)..hours..":"..string.rep("0", 2-#minutes)..minutes..string.rep(" ", 6), 7)
		printRight("| Ignore:   "..string.rep(" ", 2-#ignore)..ignore..string.rep(" ", 8), 9)
	elseif select == 4 then
		local width = preset[2].values[1]
		local length = preset[2].values[2]
		local hours = preset[2].values[3]
		local minutes = preset[2].values[4]
		local ignore = preset[2].values[6]
		printLeft(">", 8)
		printRight("| "..nameb..string.rep(" ", 20-#nameb), 4)
		printRight("|   Size: "..string.rep("0", 3-#width)..width.."x"..string.rep("0", 3-#length)..length..string.rep(" ", 5), 6)
		printRight("|   Time:  "..string.rep("0", 2-#hours)..hours..":"..string.rep("0", 2-#minutes)..minutes..string.rep(" ", 6), 7)
		printRight("| Ignore:   "..string.rep(" ", 2-#ignore)..ignore..string.rep(" ", 8), 9)
	elseif select == 5 then
		local width = preset[3].values[1]
		local length = preset[3].values[2]
		local hours = preset[3].values[3]
		local minutes = preset[3].values[4]
		local ignore = preset[3].values[6]
		printLeft(">", 9)
		printRight("| "..namec..string.rep(" ", 20-#namec), 4)
		printRight("|   Size: "..string.rep("0", 3-#width)..width.."x"..string.rep("0", 3-#length)..length..string.rep(" ", 5), 6)
		printRight("|   Time:  "..string.rep("0", 2-#hours)..hours..":"..string.rep("0", 2-#minutes)..minutes..string.rep(" ", 6), 7)
		printRight("| Ignore:   "..string.rep(" ", 2-#ignore)..ignore..string.rep(" ", 8), 9)
	elseif select == 6 then
		printLeft(">", screenh-1)
	end
end

function drawOreFinderContinue()
	local continueList = {
		"+-------------------------------+",
		"|                               |",
		"|  Would you like to continue   |",
		"|   your previous excavation?   |",
		"|                               |",
		"|        YES          NO        |",
		"+-------------------------------+"
	}
	for i=1,#continueList do
		if i == #continueList-1 then
			if select == 1 then
				printCentered("|       [YES]         NO        |", 4 + i)
			elseif select == 2 then
				printCentered("|        YES         [NO]       |", 4 + i)
			end
		else
			printCentered(continueList[i], 4 + i)
		end
	end
end

function drawOreFinderStart()
	local startList = {
		"+-------------------------------+",
		"|                               |",
		"|  Are you sure you would like  |",
		"|   to start a new excavation?  |",
		"|                               |",
		"|        YES          NO        |",
		"+-------------------------------+"
	}
	for i=1,#startList do
		if i == #startList-1 then
			if select == 1 then
				printCentered("|       [YES]         NO        |", 4 + i)
			elseif select == 2 then
				printCentered("|        YES         [NO]       |", 4 + i)
			end
		else
			printCentered(startList[i], 4 + i)
		end
	end
end

function drawOreFinderNoFile()
	local nofileList = {
		"+-------------------------------+",
		"|                               |",
		"|            ERROR!             |",
		"|    No save file was found.    |",
		"|                               |",
		"|             [OK]              |",
		"+-------------------------------+"
	}
	for i=1,#nofileList do
		printCentered(nofileList[i], 4 + i)
	end
end

function drawOreFinderPreset()
	local presetList = {
		"+-------------------------------+",
		"|                               |",
		"|    Size: 000x000              |",
		"|    Time:  00:00               |",
		"|                               |",
		"|    START    CANCEL    EDIT    |",
		"+-------------------------------+"
	}
	Name = preset[presetstate].values[5]
	Width = preset[presetstate].values[1]
	Length = preset[presetstate].values[2]
	Hours = preset[presetstate].values[3]
	Minutes = preset[presetstate].values[4]
	Ignore = preset[presetstate].values[6]
	for i=1,#presetList do
		if i == 2 then
			printCentered("|                               |", 4 + i)
			printCentered(Name, 4 + i)
		elseif i == 3 then
			printCentered("|      Size: " .. string.rep("0", 3-#Width) .. Width .. "x" .. string.rep("0", 3-#Length) .. Length .. string.rep(" ", 12) .. "|", 4 + i)
		elseif i == 4 then
			printCentered("|      Time:  " .. string.rep("0", 2-#Hours) .. Hours .. ":" .. string.rep("0", 2-#Minutes) .. Minutes .. string.rep(" ", 13) .. "|", 4 + i)
		elseif i == 5 then
			printCentered("|    Ignore:   " .. string.rep(" ", 2-#Ignore) .. Ignore .. string.rep(" ", 15) .. "|", 4 + i)
		elseif i == #presetList-1 then
			if select == 1 then
				printCentered("|   [START]   CANCEL    EDIT    |", 4 + i)
			elseif select == 2 then
				printCentered("|    START   [CANCEL]   EDIT    |", 4 + i)
			elseif select == 3 then
				printCentered("|    START    CANCEL   [EDIT]   |", 4 + i)
			end
		else
			printCentered(presetList[i], 4 + i)
		end
	end
end

function drawOreFinderNew()
	while true do
		while true do
			while true do
				term.clear()
				drawHeader()
				printCentered("Input variables for the excavation.", 4)
				printLeft("   Width: ", 6)
				printLeft("  Length: ", 7)
				printLeft("  Ignore: ", 9)
				term.setCursorPos(12, 6)
				Width = tonumber(read())
				if Width ~= nil and Width > 0 then
					break
				end
			end
			term.setCursorPos(12, 7)
			Length = tonumber(read())
			if Length ~= nil and Length > 0 then
				break
			end
		end
		term.setCursorPos(12, 9)
		Ignore = tonumber(read())
		if Ignore ~= nil and Ignore >= 0 and Ignore < 16 then
			break
		end
	end
	menustate = "orefinderstart"
	mopt[menustate].draw()
end

function drawOreFinderEdit()
	while true do
		while true do
			while true do
				while true do
					term.clear()
					drawHeader()
					printCentered("Input variables for preset " .. presetname .. ".", 4)
					printLeft("    Name: ", 6)
					printLeft("   Width: ", 8)
					printLeft("  Length: ", 9)
					printLeft("  Ignore: ", 11)
					term.setCursorPos(12, 6)
					Name = tostring(read())
					if Name ~= nil and #Name < 15 then
						break
					end
				end
				term.setCursorPos(12, 8)
				Width = tonumber(read())
				if Width ~= nil and Width > 0 then
					break
				end
			end
			term.setCursorPos(12, 9)
			Length = tonumber(read())
			if Length ~= nil and Length > 0 then
				break
			end
		end
		term.setCursorPos(12, 11)
		Ignore = tonumber(read())
		if Ignore ~= nil and Ignore >= 0 and Ignore < 16 then
			break
		end
	end
	preset[presetstate].values[5] = Name
	preset[presetstate].values[1] = tostring(Width)
	preset[presetstate].values[2] = tostring(Length)
	preset[presetstate].values[6] = tostring(Ignore)
	saveTable(preset, "ofpreset")
	drawOreFinder()
	menustate = "orefinderpreset"
	mopt[menustate].draw()
end

function gui()
	term.clear()
	select = 1
	menustate = "main"
	mopt = {
		["main"] = {
			options = {"orefinder", "tunnel", "exit"},
			draw = drawMain
		},
		["orefinder"] = {
			options = {"orefindercontinue", "orefindernew", "orefinderpreset", "orefinderpreset", "orefinderpreset", "main"},
			draw = drawOreFinder
		},
		["orefindercontinue"] = {
			options = {"orefinderrun", "orefinder"},
			draw = drawOreFinderContinue
		},
		["orefindernofile"] = {
			options = {"orefinder"},
			draw = drawOreFinderNoFile
		},
		["orefindernew"] = {
			draw = drawOreFinderNew
		},
		["orefinderpreset"] = {
			options = {"orefinderstart", "orefinder", "orefinderedit"},
			draw = drawOreFinderPreset
		},
		["orefinderstart"] = {
			options = {"orefinderrun", "orefinder"},
			draw = drawOreFinderStart
		},
		["orefinderedit"] = {
			draw = drawOreFinderEdit
		}
	}
	while true do
		mopt[menustate].draw()
		local id, key = os.pullEvent("key")
		-- DOWN = 208 UP = 200 LEFT = 203 RIGHT = 205 ENTER = 28
		if key == 200 and select > 1 then
			select = select-1
		elseif key == 208 and select < #mopt[menustate].options then
			select = select+1
		elseif key == 203 and select > 1 then
			select = select-1
		elseif key == 205 and select < #mopt[menustate].options then
			select = select+1
		elseif key == 28 then
			if mopt[menustate].options[select] == "exit" then
				break
			elseif mopt[menustate].options[select] == "orefindercontinue" then
				if fs.exists("orefinder.save") then
					menustate = "orefindercontinue"
				else
					menustate = "orefindernofile"
				end
			elseif mopt[menustate].options[select] == "orefinderrun" then
				if menustate == "orefindercontinue" then
					-- Run OreFinder with with save file
					shell.run("advancedorefinder", "orefinder.save")
					menustate = "orefinder"
				else
					-- Run OreFinder with Width and Length
					local _tSave = {
						w = 1,
						l = 1,
						width = Width,
						length = Length,
						ignore = Ignore,
						safemode = true
					}
					saveTable(_tSave, "orefinder.save")
					shell.run("advancedorefinder", "orefinder.save")
					menustate = "orefinder"
				end
			elseif mopt[menustate].options[select] == "tunnel" then
				-- Run Tunnel
				shell.run("advancedtunnel")
				menustate = "main"
			else
				if mopt[menustate].options[select] == "orefinderpreset" then
					drawOreFinder()
					if select == 3 then
						presetstate = 1
						presetname = "one"
					elseif select == 4 then
						presetstate = 2
						presetname = "two"
					elseif select == 5 then
						presetstate = 3
						presetname = "three"
					end
				end
				menustate = mopt[menustate].options[select]
			end
			select = 1
		end
	end
	term.clear()
	term.setCursorPos(1,1)
end

-- RUN
gui()