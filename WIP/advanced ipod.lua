-- Advanced Ipod by Henness
-- Version 1.0 12/18/2012

-- Config
screenw,screenh = term.getSize()
guiList = {
	" /////,^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ ",
	"o^ %xxxx333333oo33oo3o33333333333oo  /",
	"u  M                              M  /",
	"u  M                              N  ,",
	"u  M                              H  ,",
	"u^ M                              H  ,",
	"u^ M                              H  ,",
	"u^ M                              H  ,",
	"u^ M                              H  ,",
	"u^^M                              H  ,",
	"u^^M                              H  ^",
	"u^^M                              H  ^",
	"X^^M                              H  ^",
	"X^^Nyyyyyyyyyyyyyyyy88888888888888M  ^",
	"X,,,^^^^^^^^^                        ^",
	"X,,,,,^^^^^^^^                       ^",
	"X,,,,,^^^^^^^^   ^^^^                ^",
	"X,,,,,,^^^^^^,///,//////,            ^",
	"X,,,,,,,^^,///(<<<<<<<<</(/^         ^",
 	"X,,,,,,,,/<<(<<<<<<<<<<<<(<</        ^",
 	"X,/,,,,,(&<<<<<&&////<&&<<<&&/       ^",
 	"X///,,,/&&&&%%&/      /&&<<&&&^      ^",
 	"X//////<(//%%%%        <%%%////      ^",
 	"X//////<%ooooo3^       %ooooo%/      ,",
 	"X///////o3333333<,^^^/o333oo33,      ,",
 	"8///////<33333333333333333333/^^     ,",
 	"8/////////%333xxxxxxxxxx333%/^^^^^   ,",
 	"8/<<(///////&3xxx%%o%xx3o&/,^^^^^^^  ,",
 	"y(<<<</////////(<&&&<<//,,,^^^^^^^^^ /",
 	"y<<<<<<//////////////,,,,,,,,^^^^^^^^/",
 	"8(<<<<<(//////////////,,,,,,,,^^^^^^^<",
 	" uu3o%%%&&<<<<<<(/////////////////CJ<^",
 	" ^,,////////////////////////////,,^^  "
}
  
-- Functions
function printCentered(str, ypos)
	term.setCursorPos(screenw/2 - #str/2, ypos)
	term.write(str)
end

function drawIntro()
	for i=1,screenh do
		for j=1,i do
			printCentered(guiList[j], screenh-i+j)
		end
		sleep(0.001)
	end
	sleep(0.5)
end

function drawMain()
	term.clear()
	term.setCursorPos(1,1)
	for i=1,screenh do
		printCentered(guiList[i], i)
	end
	printCentered("Ipod", 4)
	printCentered("    Play                      ", 6)
	printCentered("    Exit                      ", 11)
	printCentered("                    by Henness", 13)
	if select == 1 then
		printCentered("  > Play                      ", 6)
	elseif select == 2 then
		printCentered("  > Exit                      ", 11)
	end
end

function drawPlay()
	term.clear()
	term.setCursorPos(1,1)
	for i=1,screenh do
		printCentered(guiList[i], i)
	end
	printCentered("Ipod", 4)
	printCentered(name, 5)
	printCentered("    Replay                    ", 7)
	printCentered("    Stop                      ", 8)
	printCentered("    Next                      ", 9)
	printCentered("    Previous                  ", 10)
	printCentered("    Back                      ", 12)
	printCentered("                    by Henness", 13)
	if select == 1 then
		printCentered("  > Replay                    ", 7)
	elseif select == 2 then
		printCentered("  > Stop                      ", 8)
	elseif select == 3 then
		printCentered("  > Next                      ", 9)
	elseif select == 4 then
		printCentered("  > Previous                  ", 10)
	elseif select == 5 then
		printCentered("  > Back                      ", 12)
	end
end

function drawNoDisk()
	nodiskList = {
		"+---------------+",
		"| No Disk Found |",
		"+---------------+"
	}
	for i=1,#nodiskList do
		printCentered(nodiskList[i], 6+i)
	end
end

function rednetOpen()
	sides = {
		"right",
		"left",
		"back",
		"top",
		"bottom",
		"front"
	}
	for key, value in pairs(sides) do
		if peripheral.getType(value) == "modem" then
			rednet.open(value)
			break
		end
	end
end

function runInterface()
	term.clear()
	drawIntro()
	rednetOpen()
	diskchanger = false
	side = "right"
	select = 1
	menustate = "main"
	mopt = {
		["main"] = {
			options = {"play", "exit"},
			draw = drawMain
		},
		["play"] = {
			options = {"replay", "stop", "next", "previous", "main"},
			draw = drawPlay
		},
		["nodisk"] = {
			options = {"main"},
			draw = drawNoDisk
		}
	}
	while true do
		mopt[menustate].draw()
		local event, id, message  = os.pullEvent()
		-- DOWN = 208 UP = 200 LEFT = 203 RIGHT = 205 ENTER = 28
		if id == 200 and select > 1 then
			select = select-1
		elseif id == 208 and select < #mopt[menustate].options then
			select = select+1
		elseif id == 203 and select > 1 then
			select = select-1
		elseif id == 205 and select < #mopt[menustate].options then
			select = select+1
		elseif id == 28 then
			if mopt[menustate].options[select] == "exit" then
				if diskchanger then
					rednet.send(diskchangerid, "exit")
				end
				break
			elseif mopt[menustate].options[select] == "play" then
				if diskchanger then
					rednet.send(diskchangerid, "playDisk")
				else
					if disk.isPresent(side) then
						name = "Playing "..disk.getAudioTitle(side)
						disk.playAudio(side)
						menustate = "play"
					else
						menustate = "nodisk"
						select = 1
					end
				end
			elseif mopt[menustate].options[select] == "replay" then
				if diskchanger then
					rednet.send(diskchangerid, "playDisk")
				else
					if disk.isPresent(side) then
						name = "Playing "..disk.getAudioTitle(side)
						disk.playAudio(side)
					else
						menustate = "nodisk"
						select = 1
					end
				end
			elseif mopt[menustate].options[select] == "stop" then
				if disk.isPresent(side) then
					name = disk.getAudioTitle(side).." stoped"
					disk.stopAudio(side)
				else
					menustate = "nodisk"
					select = 1
				end
			elseif mopt[menustate].options[select] == "next" then
				if diskchanger then
					rednet.send(diskchangerid, "nextDisk")
				end
			elseif mopt[menustate].options[select] == "previous" then
				if diskchanger then
					rednet.send(diskchangerid, "previousDisk")
				end
			else
				menustate = mopt[menustate].options[select]
				select = 1
			end
		elseif event == "disk" and disk.hasAudio(id) and diskchanger then
			name = "Playing "..disk.getAudioTitle(id)
			side = id
			disk.playAudio(id)
			menustate = "play"
		elseif event == "rednet_message" and message == "DiskChangerRequest" then
			diskchangerid = id
			rednet.send(diskchangerid, "DiskChangerAccepted")
			rednet.send(diskchangerid, "getDiskNames")
			while true do
				local event, id, message  = os.pullEvent()
				if event == "rednet_message" and message == "true" and id == diskchangerid then
					diskchanger = true
					break
				end
			end
		end
	end
	term.clear()
	term.setCursorPos(1,1)
end

function getDiskNames()
	diskNamesList = {}
	turtle.suck()
	for i=1,16 do
		if turtle.getItemCount(i) > 0 then
			turtle.select(i)
			turtle.drop()
			diskNamesList[i] = disk.getAudioTitle("front")
			turtle.suck()
		end
	end
	return true
end

function playDisk()
	turtle.suck()
	turtle.select(selecteddisk)
	turtle.drop()
	currentdisk = disk.getAudioTitle("front")
	print("Playing "..currentdisk)
	diskend = os.startTimer(diskTimes[currentdisk])
end

function nextDisk()
	turtle.suck()
	if selecteddisk < #diskNamesList then
		selecteddisk = selecteddisk + 1
	else
		selecteddisk = 1
	end
	turtle.select(selecteddisk)
	turtle.drop()
	currentdisk = disk.getAudioTitle("front")
	print("Playing "..currentdisk)
	diskend = os.startTimer(diskTimes[currentdisk])
end

function previousDisk()
	turtle.suck()
	if selecteddisk == 1  then
		selecteddisk = #diskNamesList
	else
		selecteddisk = selecteddisk -1
	end
	turtle.select(selecteddisk)
	turtle.drop()
	currentdisk = disk.getAudioTitle("front")
	print("Playing "..currentdisk)
	diskend = os.startTimer(diskTimes[currentdisk])
end

function runDiskChanger()
	rednetOpen()
	rednet.broadcast("DiskChangerRequest")
	selecteddisk = 1
	diskTimes = {
		["C418 - 13"] = 181,
		["C418 - cat"] = 189,
		["C418 - blocks"] = 354,
		["C418 - chirp"] = 187,
		["C418 - far"] = 172,
		["C418 - mall"] = 205,
		["C418 - mellohi"] = 98,
		["C418 - stal"] = 151,
		["C418 - strad"] = 193,
		["C418 - ward"] = 250,
		["C418 - 11"] = 70,
		["C418 - wait"] = 235,
		["shuffling"] = 67,
		["Eastern Isles"] = 376,
		["Trade Winds"] = 240
	}
	while true do
		local event, id, message  = os.pullEvent()
		if event == "rednet_message" and message == "DiskChangerAccepted" then
			IpodID = id
			print("conected to "..IpodID)
		elseif event == "rednet_message" and message == "getDiskNames"  and id == IpodID then
			if getDiskNames() then
				rednet.send(IpodID, "true")
			end
		elseif event == "rednet_message" and message == "playDisk" and id == IpodID then
			playDisk()
		elseif event == "rednet_message" and message == "nextDisk" and id == IpodID then
			nextDisk()
		elseif event == "rednet_message" and message == "previousDisk" and id == IpodID then
			previousDisk()
		elseif event == "rednet_message" and message == "exit" and id == IpodID then
			break
		elseif event == "timer" and id == diskend then
			nextDisk()
		end
	end
end

-- RUN
if turtle then
	runDiskChanger()
else
	runInterface()
end