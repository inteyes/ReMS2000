-- Plain lua code extracted from *.panel file

function setGlobalVars()

	sharedValues = {}

	sharedValues.selectedPreset			= 1				-- Selected program on the panel
	sharedValues.selectedBank 			= 1 			-- Selected bank on the panel
	sharedValues.synthPreset			= 0 			-- Selected program on the MS2000
	sharedValues.synthBank 				= 0 			-- Selected bank on the MS2000
	sharedValues.synthProgram			= 0 			-- Calculated synth program number (bank + preset) for writing
	sharedValues.selectedTimbre 		= 0
	sharedValues.selectedSequence		= 0
	sharedValues.midiActivity			= 0 			-- Midi activity flag for blinking the indicator
	sharedValues.reachStatus			= 0			
	sharedValues.timbreMode 			= tmSynth		-- Current global mode - synthesizer / vocoder
	sharedValues.voiceMode				= vmUndefined	-- More specific mode description
	sharedValues.deviceStatus 			= dsOffline		-- Device status according to the panel
	sharedValues.operationMode			= omDefault		-- Synthesizer operation mode (Program, Edit, Global)
	sharedValues.hintMessage			= ""
	sharedValues.saveToRamEnabled		= 0				-- Flag to show if preset belong or not to specific program of the bank
	sharedValues.allowChangeSeq			= false			-- Flag to prevent auto sequence changing			
	sharedValues.isSequencerDragging	= false
	sharedValues.sequencerStartY		= 0
	sharedValues.sequencerKnob			= 0				-- Knob to be affected by sequencer dragging
	sharedValues.sequencerKnobValue		= 0				-- Value at the moment of drag begins
	sharedValues.applySettingsOnCatch	= false			-- Required for settings merging routine
	sharedValues.ignoreSettingsButton	= true			-- Workaround for strange behaviour when settings page was not closed before saving state
	sharedValues.customBGColor			= SEQ_BACKGROUND
	sharedValues.playMessageTuple		= {}			-- Program Play mode can send 3 messages in a row, but Ctrlr do not recognize them as multimessage
	sharedValues.resetDWGS				= true			-- Flag to process OSC1 Control2 bounds and formula
	sharedValues.restartRequired		= false			-- Flag to indicate if panel restart is required

	-- SysEx formula templates for non-visual components, will be overriden in certain methods
	sharedValues.osc1SEValues 	= {0xF0, 0x42, 0x00, 0x58, 0x41, 0x49, 0x00, 0x00, 0x00, 0xF7}
	sharedValues.osc2SEValues 	= {0xF0, 0x42, 0x00, 0x58, 0x41, 0x4D, 0x00, 0x00, 0x00, 0xF7}
	sharedValues.oscModSEValues = {0xF0, 0x42, 0x00, 0x58, 0x41, 0x4E, 0x00, 0x00, 0x00, 0xF7}
	sharedValues.filterSEValues = {0xF0, 0x42, 0x00, 0x58, 0x41, 0x54, 0x00, 0x00, 0x00, 0xF7}
	sharedValues.LFO1SEValues 	= {0xF0, 0x42, 0x00, 0x58, 0x41, 0x68, 0x00, 0x00, 0x00, 0xF7}
	sharedValues.LFO2SEValues 	= {0xF0, 0x42, 0x00, 0x58, 0x41, 0x6D, 0x00, 0x00, 0x00, 0xF7}

	panelSettings = {}

	panelSettings.sendProgOnStartup	= 0
	panelSettings.sendOnProgChange	= 0
	panelSettings.reqProgOnChange	= 0	-- Request program on change synthesizer's program number
	panelSettings.autocheckLCDMode	= 0	-- Force LCD mode on every poll cycle
	panelSettings.disableWarnings	= 0	-- Disable all warning dialogs. Might be dangerous
	panelSettings.clockSource		= 2
	panelSettings.localMode			= 1
	panelSettings.continuousPolling	= 1
	panelSettings.selectorsSource	= pbsPanel	-- Flag to recognize where to cycle program - on the panel, or on the synthesizer side
	panelSettings.selectedSkin		= csDefault

	-- Skin colors
	skinColors = {}

	-- Init default colors
	defaultScheme()

	-- Timer flags
	timerFlags = {}

	-- Flags to indicate if some kind of data is expected or not
	-- Data that not expected will be ignored on input
	timerFlags.waitForSingleProgram	= false
	timerFlags.waitForBulkDump		= false
	timerFlags.waitForSettings		= false
	timerFlags.waitForWriteReply	= false

	-- Patch bank
	presetBank = initPresetBank()

	-- Current program data buffer. It's INIT program by default
	dataBuffer = copyTable(presetBank[1][1])

	-- Vocoder buffer
	vocoderBuffer = initVocoderBuffer()

	-- Timbre clipboard
	timbreClipboard = {}

	-- Sequence clipboard
	seqClipboard = {}
end

function setGlobalConstants()

	panelVersion = "1.3.3"

	-- Color definitions
	COMP_DISABLED_ALPHA	= 0.5
	COMP_ENABLED_ALPHA	= 1

	-- LCD
	LCD_BASE		= Colour(0xFF333333)
	LCD_BACKLIGHT  	= Colour(0xFFc4e283)
	LCD_DIGITS 	   	= Colour(0xFFb5ca87)
	LCD_TEXT		= Colour(0xFF202020)
	LCD_GLOW_START 	= Colour(0x25FFFFFF)
	LCD_GLOW_END   	= Colour(0x00FFFFFF)

	-- Icons
	ICON_ORANGE	= Colour(0xFFC6A34E)
	ICON_GREEN	= Colour(0xFF66BB66)
	ICON_RED	= Colour(0xFFDD6666)

	-- Drawing colors
	COLOR_SURFACE_LINE		= Colour(0xFFBABABA)
	COLOR_SURFACE_LINE_DARK	= Colour(0xFF9A9A9A) 
	COLOR_GREY_TEXT			= Colour(0xFF9A9A9A)
	COLOR_TRANSPARENT		= Colour(0x00000000)
	COLOR_PANEL_BG			= Colour(0xFF334657)
	COLOR_SETUP_BG			= Colour(0xFA334657)
	COLOR_PANEL_BG_BLK		= Colour(0xFF353535)
	COLOR_SETUP_BG_BLK		= Colour(0xFA353535)
	COLOR_VOCODER_LABEL		= Colour(0xFFAAAAAA)
	COLOR_COMBO_TEXT		= Colour(0xFFA6914F)
	COLOR_BUFFER_COPY		= Colour(0xFFA6524A)
	COLOR_BUFFER_COPY_V		= Colour(0xFF4A85A6)
	COLOR_BUFFER_TEXT		= Colour(0xFFFAFAFA)
	COLOR_BUFFER_TEXT_EMPTY	= Colour(0xFFBABABA)
	COLOR_EMERGENCY			= Colour(0xFF993333)
	COLOR_SEQ_BG_BLACK		= Colour(0xFF1A2024)
	COLOR_GROUPBOX_OUTLINE	= Colour(0xFFA3A3A3)
	COLOR_GROUPBOX_LABEL	= Colour(0xFFBABABA)

	-- Sequencer
	SEQ_BACKGROUND		= Colour(0xFF2A3034)
	SEQ_BG_ALTER		= Colour(0xFF252A2E)
	SEQ_BG_ALTER_BLACK	= Colour(0xFF202529)
	SEQ_NUMBER_ONE   	= Colour(0xFF00FF00)
	SEQ_NUMBER_TWO   	= Colour(0xFF00CCFF)
	SEQ_NUMBER_THREE 	= Colour(0xFFFFCC00)
	SEQ_GRAYED_OUT		= Colour(0xFFBABABA)

	-- Operation modes
	omDefault = 0
	omLCD 	  = 1
	omGlobal  = 2

	-- Device status
	dsOnline	= 0
	dsBusy		= 1
	dsOffline	= 2
	dsError		= 3

	-- Error codes
	errMaxValExceeded = 0

	-- Timbre modes
	tmSynth		= 0
	tmVocoder	= 1

	-- Voice modes
	vmUndefined	= -1
	vmSingle	= 0
	vmSplit		= 1
	vmDual		= 2
	vmVocoder	= 3

	-- Destination program buffer
	dbSynth		= 0
	dbVocoder	= 1

	-- Color scheme
	csDefault	= 0
	csBlack		= 1
	csNordLead	= 2
	csJP8080	= 3

	-- Supported file extensions
	SUPPORTED_EXT_MASK		= "*.syx;*.mid"
	SUPPORTED_EXT_MASK_ALT	= "*.syx;*.mid;*.prg"

	-- Bank \ program selection source
	pbsPanel	= 0
	pbsSynth	= 1

	-- Program data values
	DATA_PREAMBLE_BYTES		= 5		-- SysEx header
	COMMON_DATA_SIZE		= 38	-- Shared values for both timbres

	-- Dump size values
	-- Raw MIDI data
	SINGLE_PROGRAM_SIZE		= 297	-- (291 + 5 bytes SysEx header + F7)
	GLOBAL_DATA_SIZE		= 235	-- (229 + SysEx data)
	PROGRAM_BANK_DUMP_SIZE	= 37163	-- (37157 + SysEx data)
	ALL_DATA_DUMP_SIZE		= 37392 -- (37386 + SysEx data)
	MKSINGLE_PROGRAM_SIZE	= SINGLE_PROGRAM_SIZE + 2 --(MicroKorg program size)

	-- Special cases
	HANDSON_DUMP_SIZE		= 37395

	-- MIDI-to-Program converted data size
	SINGLE_PROGRAM_INT_SIZE = 254	

	TIMBRE_DATA_SIZE		= 108
	TIMBRE_ONE_STARTBYTE	= DATA_PREAMBLE_BYTES + COMMON_DATA_SIZE + 1
	TIMBRE_TWO_STARTBYTE	= TIMBRE_ONE_STARTBYTE + TIMBRE_DATA_SIZE

	-- Buffer copy values
	SEQUENCE_STARTBYTE_DISP		= 53
	SEQUENCE_DATA_SIZE			= 55
	VOCODER_SEQDATA_STARTBYTE	= 47
	VOCODER_SEQDATA_SIZE		= 32

	-- Timbre values
	OSC1_WAVEFORM_DISP	= 7
	OSC2_WAVEFORM_DISP	= 12 -- WARNING, packed byte, bits 0~1
	OSCMODULATION_DISP	= 12 -- WARNING, packed byte, bits 4~5
	FILTER_TYPE_DISP	= 19
	LFO1_TYPE_DISP		= 38 -- WARNING, packed byte, bits 0~1
	LFO2_TYPE_DISP		= 41 -- WARNING, packed byte, bits 0~1

	-- Vocoder values
	OSC1_WAVEFORM_VCD_DISP	= 8
	FILTER_TYPE_VCD_DISP	= 22
	LFO1_TYPE_VCD_DISP		= 41
	LFO2_TYPE_VCD_DISP		= 44

	SYSEX_VAL_DIFF		= 272	-- Difference between modulator numbers on different layers
	SYSEX_VAL_DIFF_ALT	= 400

	-- Dump type
	dtInvalidSz	= -1
	dtProgBank	= 0
	dtAllData	= 1
	dtHandson	= 2

	-- PopUp result values
	prOpenProgram		= 1
	prOpenDump			= 2
	prSaveProgram		= 10
	prSaveDump			= 11
	prSaveToRAM			= 12
	prRenameProgram		= 15
	prInitProgram		= 20
	prInitBank			= 21
	prRequestProgram	= 30
	prWriteProgram		= 31
	prRequestSysexDump	= 40
	prWriteSysexDump	= 41

	-- Timer values
	POLL_TIMER			= 10000	-- Constant synth availability polling
	SHOWHINT_TIMER		= 15000	-- How long hint will be shown
	STARTUP_TIMER		= 250	-- Delay before applying all startup data
	BLINKMIDI_TIMER		= 75	-- How long midi indicator shown
	WAIT_PROGRAM_TIMER	= 3000	-- Wait for program to be received
	WAIT_BANK_TIMER		= 22000 -- Wait for program bank to be received
	POLLSTATE_TIMER		= 3000	-- Timeout for synth mode request
	WAITFORSET_TIMER	= 3000	-- Timeout for synth settings request
	DELAY_PROG_REQUEST	= 300	-- Delay before run request

	STARTUP_TIMER_ID		= 1
	HINT_TIMER_ID			= 10
	POLL_TIMER_ID			= 20
	BLINKMIDI_TIMER_ID		= 30
	WAIT_PROGRAM_TIMER_ID	= 40
	WAIT_BANK_TIMER_ID		= 41
	POLLSTATE_TIMER_ID		= 50
	WAITFORSET_TIMER_ID		= 80
	DELAY_PROG_REQUEST_ID	= 90
	WAITFORWRITE_REPLY_ID	= 100 -- Will indicate if write ok reply was or was not received

	DEFINE_DEBUG = false
end

function startupSequence()

	-- Starting up the panel here
	panelReady = false

	-- Prevent panel from sending MIDI-messages while initialization goes
	mutePanelOut(true)

	setGlobalConstants()
	setGlobalVars()
	restoreGlobalSettings()
end

function runPanelOperations()

	-- Methods that run after panel fully loaded (in my dreams, haha)

	-- Paint custom component windows
	getComp("uiSequencerScreen"):repaint()
	getComp("LCDScreen"):repaint()

	-- Enable panel MIDI-output
	mutePanelOut(false)

	-- Shut down all lamps
	shutDownTheLights()

	-- ... except this one
	setLightState("imgSeqLamp0", true)

	-- Poll synth status
	pollSynthStatus()
	requestOperationMode()

	-- Sync buffer parameters with controls
	if sharedValues.saveToRamEnabled == 0 then
		applyProgramData(dataBuffer, nil, nil, true)
	else
		applyProgramData(dataBuffer, sharedValues.selectedBank, sharedValues.selectedPreset, true)
	end

	-- Sending program on startup, if option was selected
	if panelSettings.sendProgOnStartup == 1 then
		sendBufferedProgramNosync()
	end

	-- Request settings on startup
	requestSynthSettings()

	-- Run polling synth if it's enabled in the panel settings
	if panelSettings.continuousPolling == 1 then
		synthPoller()
	end

	-- Request LCD mode. Useful if synthesizer controls are automated in DAW
	if panelSettings.autocheckLCDMode == 0 then
		checkLCDModeEnabled()
	end

	-- Hide settings, if they were opened on save state moment
	setModValue("btnSettings", 0)

	-- Check if resources reloading required
	checkPanelVersion()

	-- Panel initialized, all the procedures are reachable now
	panelReady = true
end

function finalStartupOperations()

	setColorScheme(panelSettings.selectedSkin)

	-- Run timer to avoid firing scripts up while panel initializing
	startupTimer()
end


-- Short aliases for often used methods

function modByName(modname)
	return panel:getModulatorByName(modname)
end


function getComp(modname)
	return modByName(modname):getComponent()
end


function setCompProp(modname, propname, propvalue)
	-- propvalue should be string
	
	return panel:getModulatorByName(modname):getComponent():setPropertyString(propname, propvalue)
end


function getCompProp(modname, propname)	
	return panel:getModulatorByName(modname):getComponent():getProperty(propname)
end


function getCompPropN(modname, propname)	
	return panel:getModulatorByName(modname):getComponent():getPropertyInt(propname)
end


function setCompPropN(modname, propname, propvalue)
	-- propvalue should be integer
	
	return panel:getModulatorByName(modname):getComponent():setPropertyInt(propname, propvalue)
end


function getModProp(modulator, prop)
	return modulator:getProperty(prop)
end	


function getModPropN(modulator, prop)
	return modulator:getPropertyInt(prop)
end	


function getModValue(modname)

	return modByName(modname):getModulatorValue()
end


function hideLayer(layername)
	panel:getCanvas():getLayerByName(layername):setVisible(false)
end


function showLayer(layername)
	panel:getCanvas():getLayerByName(layername):setVisible(true)
end


function hideLayerN(layerid)
	panel:getCanvas():getLayerFromArray(layerid):setVisible(false)
end


function showLayerN(layerid)
	panel:getCanvas():getLayerFromArray(layerid):setVisible(true)
end

function calculateLSBMSB(calcVal, fullByte, nibbleLSB)
	
	local fB = 0x07
	local lsM = 0x7F

	if fullByte ~= nil then
		if fullByte then
			fB = 0x08

			if nibbleLSB ~= nil then
				if not nibbleLSB then
					lsM = 0xFF
				end
			end
		end
	end

    local lsb = bit.band(calcVal, lsM)
    local msb = bit.rshift(calcVal, fB)

	return {lsb, msb}
end

function restoreValueFromLSMS(msb, lsb)

	return msb * 0x80 + lsb
end

function arrayToString(inpBytes)
	
	local i
	local resStr = ""

	for i = 0, inpBytes:getSize() - 1 do
		resStr = resStr .. string.format("%x ", inpBytes:getByte(i))
	end

	return resStr
end

function tableToString(inpTable, hexOut)

	local i
	local resStr = ""
	local fmt = "%s "

	if hexOut ~= nil then
		if hexOut then
			fmt = "%.2X "
		end
	end

	for i = 1, #inpTable do
		resStr = resStr .. string.format(fmt, inpTable[i])
	end

	return resStr
end

function blockExecution(src)

	-- Thanks dnaldoog for this precious function!

	local set = {
  	[0] = false, --value("initialValue", 0),
  	true, --value("changedByHost", 1),
  	false, --value("changedByMidiIn", 2),
  	false, --value("changedByMidiController", 3),
  	false, --value("changedByGUI", 4),
  	false, --value("changedByLua", 5),
  	true, --value("changedByProgram", 6),
  	false,  --value("changedByLink", 7),
  	false, --value("changeByUnknown", 8)
  	} -- false allows function to be run 

	-- Little bit modified result
	return (set[src] and (not panelReady))
end

function midiToProgramData(rawPatchData, seekBytes)
	
	local dataSize = #rawPatchData - seekBytes - 1
	local blockSize = 8
	local dataBlockCount = math.ceil(dataSize / blockSize)
	local bytesRemain = blockSize
	local i, j

	local msbBytes = {}
	local dataChunk = {}
	local processedData = {}
	
	-- Insert header to the final table as is
	for i = 1, seekBytes do
		table.insert(processedData, rawPatchData[i])
	end

	-- Process data, according to the KORG's midi implementation doc
	-- It uses 1 + 7 "7BIT byte" chunks to store 1MSB + 7LSB bytes (in my understanding, at least)
	-- Zeroes and Ones from 1st byte used to indicate MSB value of each byte in a chunk
	for j = 0, dataBlockCount - 1 do

		if j == dataBlockCount - 1 then
			bytesRemain = dataSize - ((dataBlockCount - 1) * blockSize)
		end

		-- Getting 8 bytes of data to make calculations
		for i = 0, bytesRemain - 1 do
			table.insert(dataChunk, rawPatchData[seekBytes + 1 + (j * blockSize) + i])
		end

		-- Convert 1st byte to "1"s and "0"s
		msbBytes = Dec2Bin(dataChunk[1])

		-- Apply MSB bits for mapped bytes
		for i = 2, bytesRemain do

			dataChunk[i] = dataChunk[i] + (0x80 * msbBytes[i - 1])
			table.insert(processedData, dataChunk[i])
		end

		dataChunk = {}
 	end

	-- End of SysEx
	table.insert(processedData, 0xF7)

	return processedData
end

function programToMIDIData(bufferData, seekBytes)
	
	local programDataSize = #bufferData - seekBytes - 1
	local blockSize = 7
	local dataBlockCount = math.ceil(programDataSize / 7)

	local i, j
	local lsms = {}
	local msbBytes = {}
	local dataChunk = {}
	local bytesRemain = 7
	local processedData = {}

	-- Insert header to the final table as is
	for i = 1, seekBytes do
		table.insert(processedData, bufferData[i])
	end

	-- Constructing MS2000-compatible MIDI data format to store or send
	-- All values must be pretended as LSB and MSB, MSB data moved to a single byte
	-- and placed before the data chunk (which is 7 bytes long)

	for i = 0, dataBlockCount - 1 do

		if i == dataBlockCount - 1 then
			bytesRemain = programDataSize - ((dataBlockCount - 1) * blockSize)
		end

		-- Construct MSB-bits array
		for j = 0, bytesRemain - 1 do

			lsms = calculateLSBMSB(bufferData[seekBytes + 1 + (i * blockSize) + j])

			-- Collect MSB bit
			table.insert(msbBytes, lsms[2])

			-- Insert LSB Value into result table
			table.insert(dataChunk, lsms[1])
		end

		-- Insert "shared" MSB value as 1st byte of this chunk
		table.insert(processedData, Bin2Dec(msbBytes))

		for j = 1, #dataChunk do
			table.insert(processedData, dataChunk[j])
		end

		dataChunk = {}
		msbBytes = {}
	end

	-- End of SysEx
	table.insert(processedData, 0xF7)

	return processedData
end

function Bin2Dec(bitArr)

	local result = 0

	-- Since max value is 127, it cannot be more than 7 bits long
	if #bitArr > 7 then
		return result
	end

	local invBytes = {}
	local i

	for i = #bitArr, 1, -1 do
		table.insert(invBytes, bitArr[i])
	end

	for i = 1, #invBytes do
		result = result + (invBytes[i] * 2 ^ (#invBytes - i))
	end

	return result
end

function Dec2Bin(num)
	
	local result = {0, 0, 0, 0, 0, 0, 0}
	local bufTab = {}

	if (num > 0x7F) or (num == 0) then
		-- Wrong values passed, or it's zero
		return result
	end

	local invertBytes = {}
	local divided, divider = num, num
	local i

	while divided > 1 do

		divider = math.floor(divided / 2)

		if divided - (divider * 2) > 0 then
			table.insert(bufTab, 1)
		else
			table.insert(bufTab, 0)
		end

		divided = divider
 	end

	table.insert(bufTab, divider)

	for i = 1, #bufTab do
		result[i] = bufTab[i]
	end

	return result
end

function memBlockToTable(mbBytes)
	
	local i

	local mbData = {}

	for i = 0, mbBytes:getSize() - 1 do
		table.insert(mbData, mbBytes:getByte(i))
	end

	return mbData
end

function bankIDToName(bankID)
	
	return string.char(64 + bankID)
end

function extractPackByte(byteValue, firstBit, lastBit)

	local lBit

	if lastBit == nil then
		lBit = firstBit
	else
		lBit = lastBit
	end

	local valSize = lBit - firstBit + 1

	-- The simplest way to get bit-based value to me
	return bit.band(bit.rshift(byteValue, firstBit), (2 ^ valSize) - 1)
end

function packBitsToByte(srcValue, packValue, firstBit, lastBit)

	local lBit

	if lastBit == nil then
		lBit = firstBit
	else
		lBit = lastBit
	end

	-- What I do is subtract shifted value, which is stored in
	-- certain bits to make them filled with zeroes
	-- Then write new bits with the "OR" operation

	local existingValue = extractPackByte(srcValue, firstBit, lBit)

	local prepValue = srcValue - bit.lshift(existingValue, firstBit)

	local bitsToPack = bit.lshift(packValue, firstBit)

	--console(string.format("valueEx=%d, shiftedV=%d, srcV=%d, src-shift=%d, packVal=%d, shift=%d, shiftedPV=%d, fb=%d, lb=%d", existingValue, 
	--	bit.lshift(existingValue, firstBit), srcValue, prepValue, packValue, 8 - firstBit - valSize, bitsToPack, firstBit, lastBit))

	-- ([..0.. OR value] bits)
	return bit.bor(prepValue, bitsToPack)
end

function setSEFormulaMod(modName, modNumber)

	-- Replace mod values to new LS MS

	local lsms = calculateLSBMSB(modNumber, true)

	local seFormula = string.format("F0 42 3y 58 41 %.2X %.2X LS MS F7", lsms[1], lsms[2])

	modByName(modName):getMidiMessage():setPropertyString("midiMessageSysExFormula", seFormula)
end

function setNewModNumber(seTable, modNumber)

	local lsms = calculateLSBMSB(modNumber, true)

	local result = seTable

	result[6] = lsms[1]
	result[7] = lsms[2]

	return seTable
end

function enableControls(controlList, enable)
	
	-- Disabled controls must be inactive and half-transparent
	local i

	if not enable then

		for i = 1, #controlList do

			getComp(controlList[i]):setAlpha(COMP_DISABLED_ALPHA)
			setCompProp(controlList[i], "componentDisabled", "1")
		end
	else

		for i = 1, #controlList do

			getComp(controlList[i]):setAlpha(COMP_ENABLED_ALPHA)
			setCompProp(controlList[i], "componentDisabled", "0")
		end
	end
end

function normalizeSysExDumpData(dataTable)
	
	-- Throwing away data which is not belong to "midi dump data"
	-- Filter bytes - block must start with F0 and end with F7

	-- Other data will be cutted out

	local processedData = {}

	local i
	local readState = false
	local dataSize = #dataTable

	for i = 1, dataSize do

		if (not readState) then

			if dataTable[i] == 0xF0 then

				readState = true
				table.insert(processedData, dataTable[i])
			end
		else

			if dataTable[i] == 0xF7 then

				readState = false
			end

			table.insert(processedData, dataTable[i])
		end
	end

	return processedData
end

function concatTables(tabOne, tabTwo)
	
	local resultTable = copyTable(tabOne)
	local i

	for i = 1, #tabTwo do
		table.insert(resultTable, tabTwo[i])
	end

	return resultTable
end

function copyTable(srcTable)

	local i
	local result = {}

	for i = 1, #srcTable do
		table.insert(result, srcTable[i])
	end

	return result
end

function removeSystemSymbols(origStr)
	
	local  newStr = string.gsub(origStr, '[/\*:?"<>|]',  '')
	return newStr
end

--
-- CSV code acquired from http://lua-users.org/wiki/CsvUtils
-- CSV block begin

-- Used to escape "'s by toCSV
function escapeCSV (s)

	if string.find(s, '[,"]') then
		s = '"' .. string.gsub(s, '"', '""') .. '"'
	end
	
	return s
end

-- Convert from CSV string to table (converts a single line of a CSV file)
function fromCSV (s)

	s = s .. ','        -- ending comma
	local t = {}        -- table to collect fields
	local fieldstart = 1
	local i  = fieldstart

	repeat
		-- next field is quoted? (start with `"'?)
		if string.find(s, '^"', fieldstart) then
			local a, c

			repeat
				-- find closing quote
				a, i, c = string.find(s, '"("?)', i+1)
			until c ~= '"'    -- quote not followed by quote?

			if not i then error('unmatched "') end

			local f = string.sub(s, fieldstart+1, i-1)
			table.insert(t, (string.gsub(f, '""', '"')))
			fieldstart = string.find(s, ',', i) + 1
		else                -- unquoted; find next comma
			local nexti = string.find(s, ',', fieldstart)
			table.insert(t, string.sub(s, fieldstart, nexti-1))
			fieldstart = nexti + 1
		end
	until fieldstart > string.len(s)

	for i = 1, fieldstart do
		t[i] = tonumber(t[i])
	end
	
	return t
end

-- Convert from table to CSV string
function toCSV (tt)

	local s = ""

	-- assumption is that fromCSV and toCSV maintain data as ordered array
	for _,p in ipairs(tt) do  
		s = s .. "," .. escapeCSV(p)
	end

	return string.sub(s, 2)      -- remove first comma
end

--
-- CSV block end
--

function rndValue(modName)

	local currCtrlBounds = {}
	local rnd

	currCtrlBounds[1] = getComp(modName):getPropertyInt("uiSliderMin")
	currCtrlBounds[2] = getComp(modName):getPropertyInt("uiSliderMax")

	rnd = math.random(currCtrlBounds[1], currCtrlBounds[2])

	return rnd
end

function rndValueMan(min, max)

	return math.random(min, max)
end

function checkPanelVersion()

	local panelSettingsExt = {}
	local localVersion = ""

	-- Get local version if exists
	local settingsFile = getLocalSettingsFile()

	if settingsFile ~= nil then

		panelSettingsExt = json.decode(settingsFile:loadFileAsString())
		localVersion = panelSettingsExt.panelVersion

		if localVersion ~= panelVersion then

			-- Delete required file and display reload message
			removeResourceUpdateFile()

			sharedValues.restartRequired = true
			getComp("uiAboutInfo"):repaint()

			saveGlobalSettings()
		end
	end
end

function getLocalSettingsFile()

	local settingsFile = getLocalFile("config.json")

	-- Check if file is empty
	if settingsFile:getSize() > 0 then 

		return settingsFile
	else

		return nil
	end
end

function getLocalFile(fileName)

	local panelSharedDir, localFile

	-- Loading shared settings from file
	
	-- Getting file to load
	panelSharedDir = File.getSpecialLocation(File.currentExecutableFile):getChildFile(panel:getProperty("name"))
	localFile = File(panelSharedDir:getChildFile(fileName))

	-- Check if file exists
	if localFile:existsAsFile() == true then

		return localFile
	else

		return nil
	end
end

function removeResourceUpdateFile()

	local resourceReloadFile = getLocalFile(".delete_me_to_reload_resources")

	if resourceReloadFile ~= nil then
		
		resourceReloadFile:deleteFile()
	end
end

function getMidiInOut(getInput)

	local result = ""
	local midiCh = ""

	if getInput then
		result = panel:getProperty("panelMidiInputDevice")
		midiCh = panel:getProperty("panelMidiInputChannelDevice")

		if midiCh == "0" then
			midiCh = "All"
		end
	else
		result = panel:getProperty("panelMidiOutputDevice")
		midiCh = panel:getProperty("panelMidiOutputChannelDevice")
	end

	if result ~= "-- None" then

		result = result .. " : CH " .. midiCh
	end

	return result
end

function debugActions(mod, value, source)

	if blockExecution(source) then
		return
	end

	--prepareForExport()

	--setGlobalVars()
	--setGlobalConstants()
end

function bankListPopup(load)
	
	local popupWin = PopupMenu()

	popupWin:addSectionHeader("Select bank:")
	popupWin:addSeparator()

	popupWin:addSubMenu("Bank A", constructPresetBankMenu(1, "A", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank B", constructPresetBankMenu(2, "B", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank C", constructPresetBankMenu(3, "C", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank D", constructPresetBankMenu(4, "D", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank E", constructPresetBankMenu(5, "E", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank F", constructPresetBankMenu(6, "F", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank G", constructPresetBankMenu(7, "G", load), true, Image(), false, 0)
	popupWin:addSubMenu("Bank H", constructPresetBankMenu(8, "H", load), true, Image(), false, 0)

	return popupWin
end

function constructPresetBankMenu(bankNumber, bankName, load)
	
	local popupWin = PopupMenu()
	local bankID = 100 * bankNumber

	if not load then
		bankID = bankID + 1000
	end

	popupWin:addSectionHeader(string.format("Preset bank %s:", bankName))
	popupWin:addSeparator()

	for i = 1, 16 do
		popupWin:addItem(bankID + i, string.format("%d. %s", i, getPresetNameByID(bankNumber, i)), true, false)
	end

	return popupWin
end

function processPopupResult(puResult)

	-- Load preset range
	if (puResult >= 100) and (puResult < 900) then
		chosenPresetToBuffer(puResult, false)
	end

	-- Save current program to RAM
	if puResult == prSaveToRAM then
		if confirmDialog("Warning!", "This will erase selected program. Proceed?") then
			saveProgramToPatchBank(1000 + (sharedValues.selectedBank * 100) + sharedValues.selectedPreset)
		end
	end

	-- Save preset range
	if (puResult >= 1000) and (puResult < 1900) then
		if confirmDialog("Warning!", "This will erase selected program. Proceed?") then
			saveProgramToPatchBank(puResult)
		end
	end

	-- Remame current preset
	if puResult == prRenameProgram then
		renameProgram()
	end

	-- Open single program
	if puResult == prOpenProgram then
		openSingleProgramFile()
	end

	-- Open preset bank
	if puResult == prOpenDump then
		openProgramBankFile()
	end

	-- Export program to file
	if puResult == prSaveProgram then
		saveSingleProgramFile()
	end

	-- Export full bank to file
	if puResult == prSaveDump then
		saveProgramBankFile()
	end

	-- Init patch
	if puResult == prInitProgram then
		if confirmDialog("Warning!", "This will erase the program in the panel buffer. Proceed?") then
			initBufferWithInitPatch()
		end
	end
	
	-- Init program bank
	if puResult == prInitBank then
		if confirmDialog("Warning!", "This will erase all programs stored in RAM bank. Proceed?") then
			presetBank = initPresetBank()

			if panelSettings.sendOnProgChange == 1 then
				chosenPresetToBuffer(101, false)
			else
				chosenPresetToBuffer(101, true)
			end
		end
	end

	-- Request current program from device
	if puResult == prRequestProgram then
		if confirmDialog("Warning!", "This will erase the program in the panel buffer. Proceed?") then
			requestSingleProgram()
		end
	end

	-- Request bulk dump from device
	if puResult == prRequestSysexDump then
		if confirmDialog("Warning!", "This will erase the whole RAM bank in the panel. Proceed?") then
			requestProgramBank()
		end
	end

	-- Store current program on device
	if puResult == prWriteProgram then
		if confirmDialog("Warning!", "This will erase selected program on the hardware. Proceed?") then
			storeSingleProgram()
		end
	end

	-- Store bulk dump on device
	if puResult == prWriteSysexDump then
		if confirmDialog("Warning!", "This will erase the whole program bank on the hardware. Proceed?") then
			storeProgramBank()
		end
	end

	if puResult == -1 then
		debugActions()
	end
end

function drawOsc1Waveforms(comp, g)
	
	drawSaw(comp, g, 22, 5, 10, 2)
	drawPulse(comp, g, 31, 5, 10, 2)
	drawTriangle(comp, g, 60, 5, 10, 2)
	drawSine(comp, g, 76, 5, 2)	
end

function cycleOsc1Waveforms(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	local osc1WFAddress
	local currentValue

	if sharedValues.timbreMode == tmSynth then

		osc1WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSC1_WAVEFORM_DISP
		currentValue = dataBuffer[osc1WFAddress]
	else

		currentValue = vocoderBuffer[OSC1_WAVEFORM_VCD_DISP]
	end
	 
	currentValue = currentValue + 1

	if currentValue > 7 then
		currentValue = 0
	end

	setOsc1WaveformByValue(currentValue)
end

function setOsc1Waveform(comp)

	local selectedWave = getModPropN(comp:getOwner(), "modulatorCustomIndex")

	setOsc1WaveformByValue(selectedWave)
end

function setOsc1WaveformByValue(selectedWave, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end
	
	local lightModName = "imgOsc1Lamp"
	local osc1WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSC1_WAVEFORM_DISP
	local currentWave

	turnLightsOff(lightModName, 7)

	setLightState(string.format("%s%d", lightModName, selectedWave), true)

	if not blockMessage then

		checkLCDModeEnabled()

		-- Osc1 Waveform = 49(H)
		local lsms = calculateLSBMSB(selectedWave)
		local midiChan = getGlobalMidiChannel()
		local seMessage = copyTable(sharedValues.osc1SEValues)

		seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 
	
		sendSysExMessage(seMessage)
	end

	if sharedValues.timbreMode == tmSynth then

		currentWave = dataBuffer[osc1WFAddress]
		dataBuffer[osc1WFAddress] = selectedWave
	else

		currentWave = vocoderBuffer[OSC1_WAVEFORM_VCD_DISP]
		vocoderBuffer[OSC1_WAVEFORM_VCD_DISP] = selectedWave
	end

	-- DWGS assertions
	if tonumber(selectedWave) == 5 then

		-- Any => DWGS
		if (currentWave ~= 5) or (sharedValues.resetDWGS) then
			setDWGSWaveform(true)
		end
 	else

		-- DWGS => Any
		if (currentWave == 5) or (sharedValues.resetDWGS) then
			setDWGSWaveform(false)
		end
	end
end

function drawOsc2Waveforms(comp, g)
	
	drawSaw(comp, g, 22, 5, 10, 2)
	drawPulse(comp, g, 31, 5, 10, 2)
	drawTriangle(comp, g, 60, 5, 10, 2)
end

function cycleOsc2Waveforms(mod, value, source)

	if blockExecution(source) then
		return
	end

	local osc2WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSC2_WAVEFORM_DISP
	local currentValue = extractPackByte(dataBuffer[osc2WFAddress], 0, 1)

	currentValue = currentValue + 1

	if currentValue > 2 then
		currentValue = 0
	end

	setOsc2WaveformByValue(currentValue)
end

function setOsc2Waveform(comp)

	-- Ignore changes if lamp disabled (Vocoder)
	if comp:getPropertyInt("componentDisabled") == 1 then
		return
	end

	local selectedWave = getModProp(comp:getOwner(), "modulatorCustomIndex")
	
	setOsc2WaveformByValue(selectedWave)
end

function setOsc2WaveformByValue(selectedWave, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end

	local lightModName = "imgOsc2Lamp"

	-- Get OSC2 waveform byte number in data buffer
	local osc2WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSC2_WAVEFORM_DISP

	turnLightsOff(lightModName, 2)

	setLightState(string.format("%s%d", lightModName, selectedWave), true)

	if not blockMessage then

		checkLCDModeEnabled()

		-- Osc2 Waveform = 4D(H)
		local lsms = calculateLSBMSB(selectedWave)
		local midiChan = getGlobalMidiChannel()
		local seMessage = copyTable(sharedValues.osc2SEValues)

		seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 
	
		sendSysExMessage(seMessage)
	end

	-- Pack current value into assigned byte
	dataBuffer[osc2WFAddress] = packBitsToByte(dataBuffer[osc2WFAddress], selectedWave, 0, 1)
end

function calculateOscMod(ring, sync)
	
	if (ring or sync) == false then
		return 0
	elseif (ring == true) and (sync == false) then
		return 1
	elseif (ring == false) and (sync == true) then
		return 2
	else
		return 3
	end
end

function processOscModData(modValue, muteOutput)
	
	local ring
	local sync
	local OscModAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSCMODULATION_DISP

	if modValue == 0 then
		ring, sync = false, false
	elseif modValue == 1 then
		ring, sync = true, false
	elseif modValue == 2 then
		ring, sync = false, true
	else
		ring, sync = true, true
	end

	setLightState("imgOsc2ModLamp0", ring)
	setLightState("imgOsc2ModLamp1", sync)

	dataBuffer[OscModAddress] = packBitsToByte(dataBuffer[OscModAddress], calculateOscMod(ring, sync), 4, 5)
end

function cycleOscMod(mod, value, source)

	if blockExecution(source) then
		return
	end

	local OscModAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSCMODULATION_DISP
	local currentValue = extractPackByte(dataBuffer[OscModAddress], 4, 5)

	currentValue = currentValue + 1

	if currentValue > 3 then
		currentValue = 0
	end

	processOscModData(currentValue)
	sendOscModMessage(currentValue)
end

function sendOscModMessage(oscmodMode)

	checkLCDModeEnabled()

	-- Osc Modulation = 4E(H)
	local lsms = calculateLSBMSB(oscmodMode)
	local midiChan = getGlobalMidiChannel()
	local seMessage = copyTable(sharedValues.oscModSEValues)

	seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 

	sendSysExMessage(seMessage)
end

function setOscModMode(comp)

	-- Ignore changes if lamp disabled (Vocoder)
	if comp:getPropertyInt("componentDisabled") == 1 then
		return
	end

	local ownerMod = getModProp(comp:getOwner(), "name")
	local OscModAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + OSCMODULATION_DISP

	setLightState(ownerMod, not getLightState(ownerMod))

	local ringLight = getLightState("imgOsc2ModLamp0")
	local syncLight = getLightState("imgOsc2ModLamp1")	
	local oscmodMode = calculateOscMod(ringLight, syncLight)

	sendOscModMessage(oscmodMode)

	dataBuffer[OscModAddress] = packBitsToByte(dataBuffer[OscModAddress], oscmodMode, 4, 5)
end

function turnLightsOff(sharedName, lightsCount)

	local i

	for i = 0, lightsCount do
		setLightState(string.format("%s%d", sharedName, i), false)
	end
end

function getLightState(lightModName)
	
	if getCompProp(lightModName, "uiImageResource") == "radio_on" then
		return true
	else
		return false
	end
end

function setLightState(lightModName, lightStatus)

	if lightStatus == true then
		setCompProp(lightModName, "uiImageResource", "radio_on")
	else
		setCompProp(lightModName, "uiImageResource", "radio_off")
	end
end

function shutDownTheLights()
	
	-- Can help to keep correct lights glowing

	turnLightsOff("imgOsc1Lamp", 7)
	turnLightsOff("imgOsc2Lamp", 2)
	turnLightsOff("imgOsc2ModLamp", 1)
	turnLightsOff("imgFilterTypeLamp", 3)
	turnLightsOff("imgSeqLamp", 2)
	turnLightsOff("imgLFO1Lamp", 3)
	turnLightsOff("imgLFO2Lamp", 3)
end


function drawLCDScreen(comp, g)

	if not panelReady then
		return
	end

	local leftBorder = 5
	local topBorder = 5
	local fullW = comp:getWidth()
	local fullH = comp:getHeight()
	local rectCount = 16
	local rectSpace = 2
	local topSpacer = topBorder * 2 + math.floor(rectSpace / 2 + 0.5)
	local leftSpacer = leftBorder * 2 + math.floor(rectSpace / 2 + 0.5)

	-- Filling dark background
	g:fillAll(LCD_BASE)
	g:setColour(skinColors.LCDBacklight)

	-- Filling light green
	g:fillRoundedRectangle(leftBorder, topBorder, fullW - leftBorder * 2, 
												  fullH - topBorder * 2, 2)

	-- Setting a bit darker colour
	g:setColour(skinColors.LCDDigits)

	-- Filling background squares for chars
	local i	
	local j
	local rectWd = math.floor((fullW - 4 * leftBorder) / rectCount)
	local rectHg = math.floor((fullH - 4 * topBorder) / 2)
	local debug = false

	-- Rewritten from scratch
	for i = 0, rectCount - 1 do
		for j = 0, 1 do
			g:fillRect(leftSpacer + i * rectWd, topSpacer + j * rectHg,
					   rectWd - rectSpace, rectHg - rectSpace)
		end
	end

	-- Adding some glance
	g:setGradientFill(ColourGradient(LCD_GLOW_START, fullW, 0, LCD_GLOW_END,
					  fullW, fullH / 2, false))

	g:fillRoundedRectangle(1, 1, fullW - 2, fullH - 2, 1)
end

function paintSettingsBG(mod, g)

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()

	g:setColour(skinColors.customBG)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, 2)
end

function cycleFilterTypes(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	local FilterTypeAddress
	local currentValue
	local modMax = 3

	if sharedValues.timbreMode == tmSynth then

		FilterTypeAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + FILTER_TYPE_DISP
		currentValue = dataBuffer[FilterTypeAddress]
	else

		modMax = 4
		currentValue = vocoderBuffer[FILTER_TYPE_VCD_DISP]
	end

	currentValue = currentValue + 1

	if currentValue > modMax then
		currentValue = 0
	end

	setFilterTypeByValue(currentValue)
end

function setFilterType(comp)

	local selectedFilter = getModPropN(comp:getOwner(), "modulatorCustomIndex")

	if sharedValues.timbreMode == tmSynth then

		FilterTypeAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + FILTER_TYPE_DISP
		currentValue = dataBuffer[FilterTypeAddress]
	else

		currentValue = vocoderBuffer[FILTER_TYPE_VCD_DISP]
	end

	if sharedValues.timbreMode == tmVocoder then

		-- Vocoder filter have range from 0 to 4, 0 - no light indication
		if (currentValue - 1) == selectedFilter then
			setFilterTypeByValue(0)
		else
			setFilterTypeByValue(selectedFilter + 1)
		end
	else
		setFilterTypeByValue(selectedFilter)
	end
end

function setFilterTypeByValue(selectedFilter, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end

	local lightModName = "imgFilterTypeLamp"
	local FilterTypeAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + FILTER_TYPE_DISP
	local filterValue = selectedFilter

	turnLightsOff(lightModName, 3)

	if sharedValues.timbreMode == tmVocoder then
		filterValue = selectedFilter - 1
	end

	if (sharedValues.timbreMode == tmSynth) or 
	   ((sharedValues.timbreMode == tmVocoder) and (selectedFilter > 0)) then

		setLightState(string.format("%s%d", lightModName, filterValue), true)
	end

	if not blockMessage then

		checkLCDModeEnabled()

		-- Filter type = 54(H)
		local lsms = calculateLSBMSB(selectedFilter)
		local midiChan = getGlobalMidiChannel()
		local seMessage = copyTable(sharedValues.filterSEValues)

		seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 
	
		sendSysExMessage(seMessage)
	end

	if sharedValues.timbreMode == tmSynth then
		dataBuffer[FilterTypeAddress] = selectedFilter
	else
		vocoderBuffer[FILTER_TYPE_VCD_DISP] = selectedFilter
	end
end

function paintSequencer(comp, g)

	local i
	local roundRect = 3
	local canvasW = comp:getWidth()
	local canvasH = comp:getHeight()
	local canvasMid = canvasH / 2
	local figStartY = canvasMid
	local dashLen = 9
	local dashSpace = 1
	local dashCount = math.floor(canvasW / dashLen)
	local graphW = math.ceil(canvasW / 16)
	local maxGraphHeight = canvasMid * 0.75
	local drawProportion
	local lastStep = modByName("knobSeqLastStep"):getValue()

	g:setColour(skinColors.customBG)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, roundRect)

	-- Paint background, zebra-style
	g:setColour(skinColors.customBGAlter)

	for i = 1, 16 do
		if i % 2 > 0 then
			if i < 15 then
				g:fillRect(i * graphW, 0, graphW, canvasH)
			else
				g:fillRect(i * graphW, 0, graphW - roundRect, canvasH)
				g:fillRoundedRectangle(i * graphW, 0, graphW, canvasH, roundRect)
			end
		end
	end

	if sharedValues.timbreMode == tmSynth then

		drawProportion = maxGraphHeight / getSeqStepMaxVal(modByName(string.format("cbSeqKnob%d", 
													   	sharedValues.selectedSequence + 1)):getValue())[2]
	else
		if sharedValues.selectedSequence == 0 then
			maxGraphHeight = canvasH * 0.875

			-- Start bar from the bottom
			figStartY = canvasH
		end

		drawProportion = maxGraphHeight / getSeqStepMaxVal(sharedValues.selectedSequence)[2]
	end

	-- Dashed line only for +/- ranges
	g:setColour(skinColors.lineColor)

	-- Paint dashed line
	for i = 0, dashCount do

		if maxGraphHeight < canvasMid then
			g:fillRect(i * dashLen, canvasMid, dashLen - dashSpace, 1)
		else
			g:fillRect(i * dashLen, canvasMid * 1.125, dashLen - dashSpace, 1)
		end
	end

	local knobVal
	local graphEnd
	
	if sharedValues.selectedSequence == 0 then
		g:setColour(skinColors.seqOneBars)
	elseif sharedValues.selectedSequence == 1 then
		g:setColour(skinColors.seqTwoBars)
	else
		g:setColour(skinColors.seqThreeBars)
	end

	g:setFont(Font(10.0, 0))

	for i = 1, 16 do
		if i == lastStep + 1 then
			g:setColour(skinColors.seqGrayedOut)
		end

		knobVal = modByName(string.format("knobSeq%dStep%d", 
										  sharedValues.selectedSequence + 1, i)):getValue()

		if knobVal >= 0 then
			g:setOpacity(0.42 - skinColors.seqOpacityMinus)

			graphEnd = knobVal * drawProportion
			g:fillRect((i - 1) * graphW, figStartY - graphEnd, graphW - 1, graphEnd + 1)
			g:setOpacity(0.9)

			-- Paint these tiny value labels
			g:drawText(tostring(knobVal), (i - 1) * graphW, 
			           figStartY - graphEnd - 9, 20, 8, Justification(Justification.left), false)  
		else
			-- Negative values are more transparent
			g:setOpacity(0.30 - skinColors.seqOpacityMinus)

			graphEnd = math.abs(knobVal * drawProportion)
			g:fillRect((i - 1) * graphW, canvasMid, graphW - 1, graphEnd)
			g:setOpacity(0.9)

			g:drawText(tostring(knobVal), (i - 1) * graphW, 
			           canvasMid + graphEnd + 2, 20, 8, Justification(Justification.left), false)
		end
	end	

	g:setOpacity(1)
end
                       "
function lampFiring(mod, value, source)

	if blockExecution(source) then
		return
	end

	local modName = getModProp(mod, "name")

	-- Block sequence changing until last control will be set
	if sharedValues.allowChangeSeq then
		selectSequenceByValue(getModPropN(mod, "modulatorCustomIndex"))
	end

	if  ((modName == "knobSeq3Step16") and (sharedValues.timbreMode == tmSynth)) or
 		((modName == "knobSeq2Step16") and (sharedValues.timbreMode == tmVocoder))then

		sharedValues.allowChangeSeq = true
	end
end

function paintSeq2BG(mod, g)

	g:setColour(skinColors.customBG)
	g:fillRoundedRectangle(0, 0, mod:getWidth(), mod:getHeight(), 2)

	local i
	local spacer = 4
	local textH = 9

	local mainSeqRect = getCompProp("uiSequencerScreen", "componentRectangle")
	local mainSeqWidth = getComp("uiSequencerScreen"):getWidth()
	local mainSeqWLeft = tonumber(string.sub(mainSeqRect, 1, string.find(mainSeqRect, " ")))
	local graphW = math.floor(mainSeqWidth / 16 + 0.5)

	local knobSeqBGRect = getCompProp("uiSeq2BG", "componentRectangle")
	local knobSeqBGLeft = tonumber(string.sub(knobSeqBGRect, 1, string.find(knobSeqBGRect, " ")))
	local canvasH = mod:getHeight()

	local startX = math.abs(mainSeqWLeft - knobSeqBGLeft) - 2

	g:setColour(skinColors.darkText)
	g:setFont(Font(8.0, 1))

	for i = 1, 16 do

		-- Step numbers
		g:drawText(tostring(i), startX + (i - 1) * graphW, spacer, graphW, textH,
				 				     Justification(Justification.centred), false)

		g:drawText(tostring(i), startX + (i - 1) * graphW, canvasH - (textH + spacer), graphW, textH,
									 Justification(Justification.centred), false)
	end
end

function externalRepaintSequencer()
	
	getComp("uiSequencerScreen"):repaint()
end

function lampFiringComp(comp, value, source)

	if blockExecution(source) then
		return
	end

	-- Ignore changes if lamp disabled (Vocoder)
	if comp:getPropertyInt("componentDisabled") == 1 then
		return
	end

	selectSequenceByValue(getModPropN(comp:getOwner(), "modulatorCustomIndex"))
end

function sequencerMouseDown(comp, event)

	local barW = (comp:getWidth() / 16)
	local cBar = math.ceil(event.x / barW)

	-- Catch knob name and value to operate on it
	sharedValues.sequencerKnob = string.format("knobSeq%dStep%d", sharedValues.selectedSequence + 1, cBar)
	sharedValues.sequencerKnobValue = getModValue(sharedValues.sequencerKnob)

	sharedValues.sequencerStartY = event.y
	sharedValues.isSequencerDragging = true
end

function sequencerMouseUp()

	sharedValues.isSequencerDragging = false
end

function sequencerMouseDrag(comp, event)

	if sharedValues.isSequencerDragging == true then

		local bounds
		local newValue
		local compH = comp:getHeight()
		local ratio, barRatio
		local deltaY = sharedValues.sequencerStartY - event.y
		local currKnobValue = getModValue(sharedValues.sequencerKnob)

		if sharedValues.timbreMode == tmSynth then
			bounds = getSeqStepMaxVal(modByName(string.format("cbSeqKnob%d", 
												sharedValues.selectedSequence + 1)):getValue())
		else
			bounds = getSeqStepMaxVal(sharedValues.selectedSequence)
		end

		if bounds[1] < 0 then
			barRatio = 1.25
		else
			barRatio = 1.125
		end

		ratio = (math.abs(bounds[1]) + math.abs(bounds[2])) / compH

		newValue = math.floor(sharedValues.sequencerKnobValue + (deltaY * ratio * barRatio))

		-- Set min or max values if they were exceeded
		if newValue < bounds[1] then
 			newValue = bounds[1]
 		elseif newValue > bounds[2] then
			newValue = bounds[2]
		end

		modByName(sharedValues.sequencerKnob):setModulatorValue(newValue, false, true, false)
	end
end

function selectSequenceByValue(seqNumber)

	if sharedValues.selectedSequence ~= seqNumber then

		turnLightsOff("imgSeqLamp", 2)
		setLightState(string.format("imgSeqLamp%d", seqNumber), true)
		sharedValues.selectedSequence = seqNumber
	end

	-- Repaint SEQ graph since modulator value is changed
	getComp("uiSequencerScreen"):repaint()
end

function sequencerMouseDblClick(comp, event)
	-- Resetting related knob to its default value by double click

	local barW = (comp:getWidth() / 16)
	local cBar = math.ceil(event.x / barW)

	local opKnob = string.format("knobSeq%dStep%d", sharedValues.selectedSequence + 1, cBar)

	setModValue(opKnob, getCompPropN(opKnob, "uiSliderDoubleClickValue"))
end

function setSelectedTimbre(mod, value, source)

	if blockExecution(source) then
		return
	end

	local selTimbre = tonumber(getModProp(mod, "modulatorCustomIndex"))

	if sharedValues.selectedTimbre == selTimbre then
		return
	end

	selectTimbreByValue(selTimbre, false, false)
end

function selectTimbreByValue(selTimbre, muteOutput, noSync)

	if sharedValues.selectedTimbre == selTimbre then
		return
	end

	if selTimbre == 0 then
		setLightState("imgTimbreLamp0", true)
		setLightState("imgTimbreLamp1", false)
	else
		setLightState("imgTimbreLamp0", false)
		setLightState("imgTimbreLamp1", true)
	end

	sharedValues.selectedTimbre = selTimbre

	if not noSync then

		if (sharedValues.voiceMode == vmSplit) or (sharedValues.voiceMode == vmDual) then

			assertSysExFormulas(selTimbre)
			syncTimbreWithBuffer(selTimbre - 1)
			applyTimbreData(selTimbre, dataBuffer)
		end
	end

	if not muteOutput then

		local midiChan = 0xB0 + getGlobalMidiChannel(true)
		local seMessage = {midiChan, 0x5F, 0x7f * sharedValues.selectedTimbre}

		sendSysExMessage(seMessage)
	end
end

function paintRandomizeButton(mod, g)

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()
	local rectRounding = 2

	g:setColour(skinColors.labelTextColor)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, rectRounding)

	g:setColour(skinColors.customBG)
	g:setFont(Font(10, 1))
	g:drawText("RANDOMIZE", 4, 3, canvasW, 10, Justification(Justification.left), false)
end

function drawLFO1Waveforms(comp, g)
	
	drawSaw(comp, g, 16, 5, 10, 2)
	drawPulse(comp, g, 26, 5, 10, 2)
	drawTriangle(comp, g, 55, 5, 10, 2)
end

function setLFO1Type(comp)

	local selectedType = getModProp(comp:getOwner(), "modulatorCustomIndex")

	setLFO1TypeByValue(selectedType)
end

function cycleLFO1Type(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	local LFO1WFAddress
	local currentValue

	if sharedValues.timbreMode == tmSynth then

		LFO1WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + LFO1_TYPE_DISP
		currentValue = extractPackByte(dataBuffer[LFO1WFAddress], 0, 1)
	else

		currentValue = extractPackByte(vocoderBuffer[LFO1_TYPE_VCD_DISP], 0, 1)
	end

	currentValue = currentValue + 1

	if currentValue > 3 then
		currentValue = 0
	end

	setLFO1TypeByValue(currentValue)
end

function setLFO1TypeByValue(selectedType, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end

	local lightModName = "imgLFO1Lamp"
	local LFO1WFAddress

	turnLightsOff(lightModName, 3)

	setLightState(string.format("%s%d", lightModName, selectedType), true)

	if not blockMessage then

		checkLCDModeEnabled()

		-- LFO1 type = 68(H)
		local lsms = calculateLSBMSB(selectedType)
		local midiChan = getGlobalMidiChannel()
		local seMessage = copyTable(sharedValues.LFO1SEValues)

		seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 
	
		sendSysExMessage(seMessage)
	end

	if sharedValues.timbreMode == tmSynth then

		LFO1WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + LFO1_TYPE_DISP
		dataBuffer[LFO1WFAddress] = packBitsToByte(dataBuffer[LFO1WFAddress], selectedType, 0, 1)
	else

		vocoderBuffer[LFO1_TYPE_VCD_DISP] = packBitsToByte(vocoderBuffer[LFO1_TYPE_VCD_DISP], selectedType, 0, 1)
	end
end

function drawLFO2Waveforms(comp, g)
	
	drawSaw(comp, g, 16, 5, 10, 2)
	drawPulse(comp, g, 26, 5, 10, 2, true)
	drawSine(comp, g, 51, 5, 2)
end

function setLFO2Type(comp)

	local selectedType = getModProp(comp:getOwner(), "modulatorCustomIndex")

	setLFO2TypeByValue(selectedType)
end

function cycleLFO2Type(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	local LFO2WFAddress
	local currentValue

	if sharedValues.timbreMode == tmSynth then

		LFO2WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + LFO2_TYPE_DISP
		currentValue = extractPackByte(dataBuffer[LFO2WFAddress], 0, 1)
	else

		currentValue = extractPackByte(vocoderBuffer[LFO2_TYPE_VCD_DISP], 0, 1)
	end

	currentValue = currentValue + 1

	if currentValue > 3 then
		currentValue = 0
	end

	setLFO2TypeByValue(currentValue)
end

function setLFO2TypeByValue(selectedType, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end

	local lightModName = "imgLFO2Lamp"
	local LFO2WFAddress

	turnLightsOff(lightModName, 3)

	setLightState(string.format("%s%d", lightModName, selectedType), true)

	if not blockMessage then

		checkLCDModeEnabled()

		-- LFO2 type = 6D(H)
		local lsms = calculateLSBMSB(selectedType)
		local midiChan = getGlobalMidiChannel()
		local seMessage = copyTable(sharedValues.LFO2SEValues)

		seMessage[3], seMessage[8], seMessage[9] = midiChan, lsms[1], lsms[2] 
	
		sendSysExMessage(seMessage)
	end

	if sharedValues.timbreMode == tmSynth then

		LFO2WFAddress = TIMBRE_ONE_STARTBYTE + (sharedValues.selectedTimbre * TIMBRE_DATA_SIZE) + LFO2_TYPE_DISP
		dataBuffer[LFO2WFAddress] = packBitsToByte(dataBuffer[LFO2WFAddress], selectedType, 0, 1)
	else

		vocoderBuffer[LFO2_TYPE_VCD_DISP] = packBitsToByte(vocoderBuffer[LFO2_TYPE_VCD_DISP], selectedType, 0, 1)
	end
end

function drawSine(comp, g, startY, spacer, lineW)
	
	g:setColour(skinColors.lineColor)

	local figureW = comp:getWidth() - (2 * spacer)
 	local sinCoeff = (2 * math.pi) / figureW

	local i
	local prevX = 0
	local prevY = startY
	local sinVal

	-- Eh, looks like drawing a simple sine is not that easy task to me
	for i = 0, figureW - 1 do
		sinVal = prevY + sin((i + (figureW / 4)) * -sinCoeff)
		g:drawLine(spacer + prevX, prevY, spacer + i, sinVal, lineW)
		prevX = i
		prevY = sinVal
	end
end

function drawPulse(comp, g, startY, spacer, figH, lineW, isShort)

	local shortPulse

	if isShort == nil then
		shortPulse = false
	else
		shortPulse = isShort
	end

	g:setColour(skinColors.lineColor)

	local figureW = comp:getWidth() - (2 * spacer)
	local halfLine = lineW / 2
	local halfFig = figureW / 2
	local halfFigH = figH / 2

	g:drawLine(spacer, startY + (figH / 2), spacer, startY, lineW)

	g:drawLine(spacer - halfLine, startY, spacer + halfFig, startY, lineW)

	if not isShort then
		g:drawLine(spacer + halfFig - halfLine, startY - halfLine, 
			   	   spacer + halfFig - halfLine, startY + figH + halfLine, lineW)

		g:drawLine(spacer + halfFig - halfLine, startY + figH,
 			       spacer + 2 * halfFig, startY + figH, lineW)

		g:drawLine(spacer + 2 * halfFig - halfLine, startY + figH, 
			       spacer + 2 * halfFig - halfLine, startY + (figH / 2), lineW)
	else
		g:drawLine(spacer + halfFig - halfLine, startY - halfLine, 
			   	   spacer + halfFig - halfLine, startY + halfFigH + halfLine, lineW)

		g:drawLine(spacer + halfFig - halfLine, startY + halfFigH,
 			       spacer + 2 * halfFig, startY + halfFigH, lineW)
	end
end

function drawSaw(comp, g, startY, spacer, figH, lineW)
	
	g:setColour(skinColors.lineColor)

	local figureW = comp:getWidth() - (2 * spacer)

	g:drawLine(spacer, startY, spacer + figureW, startY - figH, lineW)
	g:drawLine(spacer + figureW - lineW / 2, startY - figH, spacer + figureW - lineW / 2, startY, lineW)
end

function drawTriangle(comp, g, startY, spacer, figH, lineW)
	
	g:setColour(skinColors.lineColor)

	local figureW = comp:getWidth() - (2 * spacer)

	g:drawLine(spacer, startY, spacer + figureW / 2, startY - figH, lineW)
	g:drawLine(spacer + figureW / 2, startY - figH, spacer + figureW, startY, lineW)
end

function drawSynthReachableIcon(g, startX, startY)

	local iconColor
	local ds = sharedValues.deviceStatus

	if ds == dsOffline then
		iconColor = skinColors.lineColorDark
	elseif ds == dsOnline then
		iconColor = ICON_GREEN
	elseif ds == dsBusy then
		iconColor = ICON_ORANGE
	elseif ds == dsError then
		iconColor = ICON_RED
	end

	g:setColour(iconColor)

	g:drawLine(startX + 11, startY + 4, startX + 7, startY, 2)
	g:drawLine(startX, startY + 8, startX + 12, startY + 8, 2)
	g:drawLine(startX, startY + 4, startX + 12, startY + 4, 2)
	g:drawLine(startX + 1, startY + 8, startX + 5, startY + 12, 2)	
end

function drawSynthClockIcon(g, startX, startY)
	
	local iconColor

	g:setColour(skinColors.lineColorDark)

	g:drawLine(startX, startY + 12, startX + 7, startY, 2)
	g:drawLine(startX + 6, startY, startX + 13, startY + 12, 2)
	g:drawLine(startX, startY + 11, startX + 13, startY + 11, 2)
	g:drawLine(startX + 6, startY + 11, startX + 12, startY + 3, 2)

	if panelSettings.clockSource == 0 then

		-- Internal clock source
		g:drawArrow(Line(startX + 13, startY + 6, startX + 24, startY + 6), 2, 4, 4)
	elseif panelSettings.clockSource == 1 then

		-- External clock source
		g:drawArrow(Line(startX + 24, startY + 6, startX + 13, startY + 6), 2, 5, 5)
	else

		-- Auto clock source
		g:setFont(Font(10, 1))
		g:drawText("A", startX + 13, startY + 1, 10, 10, Justification(Justification.left), false)
	end
end

function drawLocalIcon(g, startX, startY)

	local iconColor

	if panelSettings.localMode == 0 then
		iconColor = skinColors.lineColorDark
	elseif panelSettings.localMode == 1 then
		iconColor = ICON_GREEN
	end

	g:setColour(iconColor)

	g:fillRect(startX, startY, 4, 12)
	g:fillRect(startX + 5, startY, 4, 12)
	g:fillRect(startX + 10, startY, 4, 12)

	g:setColour(skinColors.customBG)

	g:fillRect(startX + 3, startY, 3, 7)
	g:fillRect(startX + 8, startY, 3, 7)
end

function drawPanelModeIcon(g, startX, startY)
	
	g:setColour(skinColors.lineColorDark)
	g:setFont(Font(14, 1))

	local xDisp = 4

	if sharedValues.operationMode == omDefault then

		g:drawText("P", startX + xDisp, startY, 12, 12, Justification(Justification.left), false)
	elseif sharedValues.operationMode == omLCD then

		g:fillRect(startX + (xDisp / 2), startY, 13, 13)
		g:setColour(skinColors.customBG)
		g:drawText("E", startX + xDisp, startY, 13, 12, Justification(Justification.left), false)
	else

		g:fillRect(startX + (xDisp / 2), startY, 13, 13)
		g:setColour(skinColors.customBG)
		g:drawText("G", startX + xDisp, startY, 12, 12, Justification(Justification.left), false)
	end
end

function genAlertWindow(alertTitle, alertMessage)
	
	utils.warnWindow(alertTitle, alertMessage)
end

function confirmDialog(title, message)

	local result = true

	if panelSettings.disableWarnings == 0 then
		result = utils.questionWindow(title, message, "OK", "Cancel")
	end

	return result
end

function genAssertErrorMessage(errSource, srcMax, srcVal, errCode)

	if not DEFINE_DEBUG then
		return
	end

	local errorMessage = "Assertion Error:"

	if errCode == errMaxValExceeded then

	
		errorMessage = string.format("%s the %s value %d exceeded by %d for the controller %s", errorMessage, 
									"Maximum", srcMax, srcVal - srcMax, errSource)
		errorMessage = errorMessage .. "\nFalling back to maximum value"
	end

	console(errorMessage)
end

function openFileDialog(title, ext)

	local bulkDump = utils.openFileWindow(title, File(""), ext, true)

	-- If file exists, then proceed
	if bulkDump:existsAsFile() then
		return bulkDump
	else
		return nil
	end
end

function paintInfoWindow(mod, g)

	g:setColour(skinColors.customBG)
	g:fillAll()

	local frameW = mod:getWidth()
	local frameH = mod:getHeight()
	local iconSpacer = 10
	local iconCount = 4

	local rightSpacer = 8
	local iconW = 12
	local iconH = 12
	local iconX = 12
	local iconY = 6

	drawPanelModeIcon(g, iconX, iconY)
	drawSynthReachableIcon(g, iconX + (iconW + iconSpacer), iconY)
	drawLocalIcon(g, iconX + ((iconW + iconSpacer) * 2), iconY)
	drawSynthClockIcon(g, iconX + ((iconW + iconSpacer) * 3), iconY)
end

function externalRepaintInfoWindow()

	getComp("uiInfoScreen"):repaint()
end

function paintAboutInfo(mod, g)
	
	g:setColour(skinColors.customBG)
	g:fillAll()

	g:setColour(skinColors.darkText)
	g:setFont(Font(9, 1))
	g:drawText("Created by inteyes", 10, 2, 100, 10, Justification(Justification.left), false)
	g:drawText("with Ctrlr 5.3.201", 10, 12, 100, 10, Justification(Justification.left), false)

	g:setFont(Font(10, 1))
	g:drawText("  --- KORG ---", 155, 2, 100, 10, Justification(Justification.left), false)
	g:drawText("   Re:MS2000", 153, 12, 100, 10, Justification(Justification.left), false)

	g:fillRoundedRectangle(240, 12, 47, 10, 1)

	g:drawText("MIDI IN    : ", 552, 2, 100, 10, Justification(Justification.left), false)
	g:drawText("MIDI OUT : ", 552, 12, 100, 10, Justification(Justification.left), false)
	g:drawText(getMidiInOut(true), 608, 2, 160, 10, Justification(Justification.left), false)
	g:drawText(getMidiInOut(false), 608, 12, 160, 10, Justification(Justification.left), false)

	if sharedValues.restartRequired == true then
		g:setColour(ICON_ORANGE)
		g:fillRoundedRectangle(292, 12, 110, 10, 1)
	end

	g:setColour(skinColors.customBG)
	g:drawText("v. " .. panelVersion, 246, 12, 100, 10, Justification(Justification.left), false)
	g:drawText("RESTART SUGGESTED", 298, 12, 150, 10, Justification(Justification.left), false)
end

function externalRepaintHintWindow()
	
	getComp("uiHintScreen"):repaint()
end

function paintMidiActivity(mod, g)
	
	g:setColour(skinColors.customBG)
	g:fillAll()

	if sharedValues.midiActivity == 1 then
		g:setColour(ICON_ORANGE)
	end

	g:fillEllipse(2, 7, 10, 10)
end

function blinkMidiLight()
	
	sharedValues.midiActivity = 1
	externalRepaintMidiActivity()
	blinkMidiLightTimer()
end

function externalRepaintMidiActivity()
	
	getComp("uiMidiActivity"):repaint()
end

function applyVocoderLabels(vocoderSelected)

	local textColor
	local labelBG 
	local i

	local onlyColorChangeLabels = {
		"lblTimbreMidiCh",
		"lblTimbreAssign",
		"lblEG2Reset",
		"lblEG1Reset",
		"lblTimbreTrigger",
		"lblTimbrePriority",
		"lblTimbreDetune",
		"lblTimbreTune",
		"lblTimbreBendRange",
		"lblTimbreTranspose",
		"lblTimbreVibrato",
		"lblTimbrePorta",
		"lblAmpDistortion",
		"lblAmpVeloSens",
		"lblAmpKeyTrack",
		"lblLFO1KeySync",
		"lblLFO1TempoSync",
		"lblLFO1SyncNote",
		"lblLFO2KeySync",
		"lblLFO2TempoSync",
		"lblLFO2SyncNote",
		"lblOsc1Control1",
		"lblOsc1Control2",
		"lblOsc1WaveCycle",
		"lblMixerOsc1",
		"lblMixerNoise",
		"lblFilterCutoff",
		"lblFilterResonance",
		"lblEG1Attack",
		"lblEG2Attack",
		"lblEG1Decay",
		"lblEG2Decay",
		"lblEG1Sustain",
		"lblEG2Sustain",
		"lblEG1Release",
		"lblEG2Release",
		"lblAmpLevel",
		"lblLFO1TypeCycle",
		"lblLFO2TypeCycle",
		"lblLFO1Frequency",
		"lblLFO2Frequency",
		"lblArpOnOff",
		"lblArpLatch",
		"lblArpKeySync",
		"lblArpTempo",
		"lblArpGate",
		"lblArpResolution",
		"lblArpSwing",
		"lblArpTempo",
		"lblArpType",
		"lblArpRange"
	}

	--Change text and background for dedicated labels
	if vocoderSelected then

		-- Color depends on selected skin
		textColor = skinColors.vocoderText:toString()
		labelBG = skinColors.vocoderElements:toString()

		alterLableProps("lblFilter24LPF", "+ 1", labelBG, textColor)
		alterLableProps("lblFilter12LPF", "+ 2", labelBG, textColor)
		alterLableProps("lblFilter12BPF", "-  1", labelBG, textColor)
		alterLableProps("lblFilter12HPF", "-  2", labelBG, textColor)
		alterLableProps("lblOsc2Semitone", "HPF LEVEL", labelBG, textColor)
		alterLableProps("lblOsc2Tune", "THRESHOLD", labelBG, textColor)
		alterLableProps("lblMixerOsc2", "DIRECT", labelBG, textColor)
		alterLableProps("lblFilterTypeCycle", "FORMANT SHIFT", labelBG, textColor)
		alterLableProps("lblFilterKbdTrack", "E.F.SENSE", labelBG, textColor)
		alterLableProps("lblAmpPan", "DIRECT", labelBG, textColor)
		alterLableProps("lblSequence1", "LVL", labelBG, textColor)
		alterLableProps("lblSequence2", "PAN", labelBG, textColor)
		alterLableProps("lblFilterVeloSens", "GATE SENS", labelBG, textColor)
		alterLableProps("lblAmpEG2Gate", "HPF GATE", labelBG, textColor)
		alterLableProps("lblFilterEG1Int", "FC MOD INT", labelBG, textColor)
		alterLableProps("lblPatchSource1", "FC MOD SOURCE", labelBG, textColor)
	else

		textColor = skinColors.labelTextColor:toString()
		labelBG = COLOR_TRANSPARENT:toString()

		alterLableProps("lblFilter24LPF", "24LPF", labelBG, textColor)
		alterLableProps("lblFilter12LPF", "12LPF", labelBG, textColor)
		alterLableProps("lblFilter12BPF", "12BPF", labelBG, textColor)
		alterLableProps("lblFilter12HPF", "12HPF", labelBG, textColor)
		alterLableProps("lblOsc2Semitone", "SEMITONE", labelBG, textColor)
		alterLableProps("lblOsc2Tune", "TUNE", labelBG, textColor)
		alterLableProps("lblMixerOsc2", "OSC 2", labelBG, textColor)
		alterLableProps("lblFilterTypeCycle", "FILTER TYPE", labelBG, textColor)
		alterLableProps("lblFilterKbdTrack", "KBD TRK", labelBG, textColor)
		alterLableProps("lblAmpPan", "PAN", labelBG, textColor)
		alterLableProps("lblSequence1", "SEQ 1", labelBG, textColor)
		alterLableProps("lblSequence2", "SEQ 2", labelBG, textColor)
		alterLableProps("lblFilterVeloSens", "VELO SENS", labelBG, textColor)
		alterLableProps("lblAmpEG2Gate", "EG2 / GATE", labelBG, textColor)
		alterLableProps("lblFilterEG1Int", "EG 1 INT", labelBG, textColor)
		alterLableProps("lblPatchSource1", "SOURCE 1", labelBG, textColor)
	end

	for i = 1, #onlyColorChangeLabels do
		alterLabelColors(onlyColorChangeLabels[i], labelBG, textColor)
	end
end

function alterLableProps(modName, lblText, bgColor, textColor)

	alterLabelColors(modName, bgColor, textColor)
	getComp(modName):setText(lblText)
end

function alterLabelColors(modName, bgColor, textColor)

	setCompProp(modName, "uiLabelTextColour", textColor)
	setCompProp(modName, "uiLabelBgColour", bgColor)
end

function paintTimbreCPButtons(mod, g)

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()
	local rectRounding = 2
	local compSource = getModPropN(mod:getOwner(), "modulatorCustomIndex")

	local bgColor = skinColors.customBG
	local textColor = skinColors.copyColorTextEmpty

	-- If clipboard is not empty, set another BG and text color for "Copy" button
	if compSource == 0 then
		if #timbreClipboard ~= 0 then

			if timbreClipboard[1] == tmSynth then
				bgColor = skinColors.copyTimbreData
			else
				bgColor = skinColors.copyVocoderData
			end

			textColor = skinColors.copyColorText
		end
	else
		if #seqClipboard ~= 0 then

			if seqClipboard[1] == tmSynth then
				bgColor = skinColors.copyTimbreData
			else
				bgColor = skinColors.copyVocoderData
			end

			textColor = skinColors.copyColorText
		end
	end

	-- Copy button background
	g:setColour(bgColor)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, rectRounding)

	g:setColour(skinColors.labelTextColor)

	-- Paste button background
	g:fillRect(canvasW / 2, 0, 5, canvasH)
	g:fillRoundedRectangle(canvasW / 2, 0, canvasW / 2, canvasH, rectRounding)

	g:setColour(textColor)

	-- Copy button text
	g:setFont(Font(10, 1))
	g:drawText("COPY", 4, 3, canvasW / 2, 10, Justification(Justification.left), false)

	g:setColour(skinColors.customBG)

	-- Paste button text
	g:drawText("PASTE", (canvasW / 2) + 1, 3, canvasW / 2, 10, Justification(Justification.left), false)
end

function bufferMouseClick(comp, event, source)

	if blockExecution(source) then
		return
	end

	local compSource = getModPropN(comp:getOwner(), "modulatorCustomIndex")
	local canvasW = comp:getWidth()

	-- Handling Timbre Buffer button press
	if compSource == 0 then

		if event.x < (canvasW / 2) then

			copyTimbreToClipboard()
		else
			pasteTimbreFromClipboard()
		end
	else

		-- Handling Sequence Buffer button press
		if event.x < (canvasW / 2) then

			copySequenceToClipboard()
		else
			pasteSequenceFromClipboard()
		end
	end
end

function repaintTimbreCPButtons()
	
	getComp("uiTimbreBuffer"):repaint()
	getComp("uiSequenceBuffer"):repaint()
end

function paintSynthSideLines(mod, g)

	local spacer = 10
	local roundDisp = 2

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()

	local lineW = 2

	-- Draw straight lines
	g:setColour(skinColors.lineColor)

	g:fillRoundedRectangle(	canvasW - 14, spacer, canvasW - (canvasW - 14), 
							canvasH - (spacer * 2), roundDisp)

	g:fillRect(0, canvasH / 2 - 1, canvasW - 14, lineW)

	-- Color depends on selected skin
	g:setColour(skinColors.groupBoxMainWin)
	g:fillRoundedRectangle(	canvasW - 14 + lineW, spacer + lineW, canvasW - (canvasW - 14 - lineW), 
							canvasH - (spacer * 2) - (lineW * 2), roundDisp)
end

function paintSynthSideSelector(mod, g)

	local bgColor = skinColors.customBG
	local lineColor = COLOR_GREY_TEXT

	if panelSettings.selectorsSource ~= pbsPanel then
		lineColor = ICON_ORANGE
	end

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()

	local spacerH = 8
	local spacerV = 5

	local startX = spacerH
	local startY = spacerV

	local iconW = (canvasW / 1.65) - (spacerH * 2)
	local iconH = canvasH - (spacerV * 2)

	local kbSX, kbSY, kbH, spc

	local rectRounding = 2

	-- Selector background
	g:setColour(bgColor)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, rectRounding)

	-- Icon outline
	g:setColour(lineColor)
	g:fillRect(startX, startY, iconW, iconH)

	-- Selected bank on synth
	g:setFont(Font(12, 1))
	g:drawText(string.format("%s%.2d", bankIDToName(sharedValues.synthBank + 1), sharedValues.synthPreset + 1), 
			   startX + iconW + 5, startY + 2, 24, 10, Justification(Justification.left), false) 

	-- Icon surface
	g:setColour(bgColor)
	g:fillRect(startX + 1, startY + 1, iconW - 2, iconH - 2)

	-- Icon KB surface
	g:setColour(lineColor)

	kbSX = startX + (iconW / 3)
	kbSY = startY + (iconH / 2.5) + 1

	g:fillRect(kbSX, kbSY, iconW - (iconW / 3) - 1, iconH - (iconH / 2.5) - 1)

	-- Knobs on the icon
	g:fillEllipse(startX + 2, startY + 2, 3, 3)
	g:fillEllipse(startX + 7, startY + 2, 3, 3)

	-- Pitch/Bend wheels
	g:fillRect(startX + 3, startY + (iconH / 2), 1, iconH / 3)
	g:fillRect(startX + 5, startY + (iconH / 2), 1, iconH / 3)

	-- Keys on keyboard
	g:setColour(bgColor)

	kbH = iconH - (kbSY - startY)
	spc = (iconW - (iconW - kbSX)) / 3

	-- White keys
	g:fillRect(kbSX + spc - 1, kbSY, 1, kbH)
	g:fillRect(kbSX + (spc * 2) - 1, kbSY, 1, kbH)
	g:fillRect(kbSX + (spc * 3) - 2, kbSY, 1, kbH)

	-- Black keys
	g:fillRect(kbSX + spc - 2, kbSY, 3, 5)
	g:fillRect(kbSX + (spc * 2) - 2, kbSY, 3, 5)
end

function defaultScheme()

	-- Default (blue) color scheme

	-- Background
	skinColors.panelBG			= COLOR_PANEL_BG
	skinColors.customBG			= SEQ_BACKGROUND
	skinColors.customBGAlter	= SEQ_BG_ALTER

	-- Text
	skinColors.labelTextColor	= COLOR_SURFACE_LINE
	skinColors.darkText			= COLOR_GREY_TEXT
	skinColors.comboText		= COLOR_COMBO_TEXT

	-- Label
	skinColors.vocoderElements	= COLOR_VOCODER_LABEL
	skinColors.vocoderText		= COLOR_PANEL_BG

	-- Draw
	skinColors.lineColor		= COLOR_SURFACE_LINE
	skinColors.lineColorDark	= COLOR_SURFACE_LINE_DARK

	-- Sequencer
	skinColors.seqOneBars		= SEQ_NUMBER_ONE
	skinColors.seqTwoBars		= SEQ_NUMBER_TWO
	skinColors.seqThreeBars		= SEQ_NUMBER_THREE
	skinColors.seqGrayedOut		= SEQ_GRAYED_OUT
	skinColors.seqOpacityMinus	= 0

	-- Copy / Paste buttons
	skinColors.copyTimbreData		= COLOR_BUFFER_COPY
	skinColors.copyVocoderData		= COLOR_BUFFER_COPY_V
	skinColors.copyColorText		= COLOR_BUFFER_TEXT
	skinColors.copyColorTextEmpty	= COLOR_BUFFER_TEXT_EMPTY

	-- LCD
	skinColors.LCDBacklight		= LCD_BACKLIGHT
	skinColors.LCDDigits		= LCD_DIGITS
	skinColors.LCDText			= LCD_TEXT

	-- Group box
	skinColors.groupBoxBG				= skinColors.panelBG
	skinColors.groupBoxMainWin			= skinColors.panelBG
	skinColors.groupBoxOutline			= COLOR_GROUPBOX_OUTLINE
	skinColors.groupBoxOutlineMainWin	= skinColors.groupBoxOutline
	skinColors.groupBoxLabel			= COLOR_GROUPBOX_LABEL
	skinColors.groupBoxLabelMainWin		= skinColors.groupBoxLabel
	skinColors.groupBoxRounding			= 0

	-- Settings layer
	skinColors.settingsAlpha	= 0.99
end

function blackScheme()

	-- Default (blue) color scheme

	-- Background
	skinColors.panelBG			= COLOR_PANEL_BG_BLK
	skinColors.customBG			= COLOR_SEQ_BG_BLACK
	skinColors.customBGAlter	= SEQ_BG_ALTER_BLACK

	-- Text
	skinColors.labelTextColor	= COLOR_SURFACE_LINE
	skinColors.darkText			= COLOR_GREY_TEXT
	skinColors.comboText		= COLOR_COMBO_TEXT

	-- Label
	skinColors.vocoderElements	= COLOR_VOCODER_LABEL
	skinColors.vocoderText		= COLOR_PANEL_BG_BLK

	-- Draw
	skinColors.lineColor		= COLOR_SURFACE_LINE
	skinColors.lineColorDark	= COLOR_SURFACE_LINE_DARK

	-- Sequencer
	skinColors.seqOneBars		= SEQ_NUMBER_ONE
	skinColors.seqTwoBars		= SEQ_NUMBER_TWO
	skinColors.seqThreeBars		= SEQ_NUMBER_THREE
	skinColors.seqGrayedOut		= SEQ_GRAYED_OUT
	skinColors.seqOpacityMinus	= 0.1

	-- Copy / Paste buttons
	skinColors.copyTimbreData		= COLOR_BUFFER_COPY
	skinColors.copyVocoderData		= COLOR_BUFFER_COPY_V
	skinColors.copyColorText		= COLOR_BUFFER_TEXT
	skinColors.copyColorTextEmpty	= COLOR_SURFACE_LINE

	-- LCD
	skinColors.LCDBacklight		= LCD_BACKLIGHT
	skinColors.LCDDigits		= LCD_DIGITS
	skinColors.LCDText			= LCD_TEXT

	-- Group box
	skinColors.groupBoxBG				= skinColors.panelBG
	skinColors.groupBoxMainWin			= skinColors.panelBG
	skinColors.groupBoxOutline			= COLOR_GROUPBOX_OUTLINE
	skinColors.groupBoxOutlineMainWin	= skinColors.groupBoxOutline
	skinColors.groupBoxLabel			= COLOR_GROUPBOX_LABEL
	skinColors.groupBoxLabelMainWin		= skinColors.groupBoxLabel
	skinColors.groupBoxRounding			= 0

	-- Settings layer
	skinColors.settingsAlpha	= 0.99
end

function nordScheme()

	-- Yet another theme

	-- Background
	skinColors.panelBG			= Colour(0xFF64262c)
	skinColors.customBG			= Colour(0xFF26262e)
	skinColors.customBGAlter	= SEQ_BG_ALTER

	-- Text
	skinColors.labelTextColor	= Colour(0xFFd9def1)
	skinColors.darkText			= COLOR_GREY_TEXT
	skinColors.comboText		= Colour(0xFFd9def1)

	-- Label
	skinColors.vocoderElements	= skinColors.customBG
	skinColors.vocoderText		= skinColors.labelTextColor

	-- Draw
	skinColors.lineColor		= Colour(0xFFd9def1)
	skinColors.lineColorDark	= COLOR_SURFACE_LINE_DARK

	-- Sequencer
	skinColors.seqOneBars		= Colour(0xFFDA4545)
	skinColors.seqTwoBars		= skinColors.labelTextColor
	skinColors.seqThreeBars		= Colour(0xFFb5abdc)
	skinColors.seqGrayedOut		= Colour(0xFF9A9A9A)
	skinColors.seqOpacityMinus	= 0.1

	-- Copy / Paste buttons
	skinColors.copyTimbreData		= skinColors.panelBG
	skinColors.copyVocoderData		= COLOR_BUFFER_COPY_V
	skinColors.copyColorText		= COLOR_BUFFER_TEXT
	skinColors.copyColorTextEmpty	= COLOR_BUFFER_TEXT

	-- LCD
	skinColors.LCDBacklight		= LCD_BACKLIGHT
	skinColors.LCDDigits		= LCD_DIGITS
	skinColors.LCDText			= LCD_TEXT

	-- Group box
	skinColors.groupBoxBG				= Colour(0xFF3e3e46)
	skinColors.groupBoxMainWin			= skinColors.customBG
	skinColors.groupBoxOutline			= skinColors.lineColorDark
	skinColors.groupBoxOutlineMainWin	= skinColors.groupBoxOutline
	skinColors.groupBoxLabel			= Colour(0xFFd9def1)
	skinColors.groupBoxLabelMainWin		= skinColors.groupBoxLabel
	skinColors.groupBoxRounding			= 2

	-- Settings layer
	skinColors.settingsAlpha	= 0.99
end

function jp8080Scheme()

	-- Roland JP8080-like scheme

	-- Background
	skinColors.panelBG			= Colour(0xFF435a82)
	skinColors.customBG			= Colour(0xFF0a1519)
	skinColors.customBGAlter	= Colour(0xFF0e1a1e)

	-- Text
	skinColors.labelTextColor	= Colour(0xFFdce8e8)
	skinColors.darkText			= Colour(0xFFd2d6d6)
	skinColors.comboText		= Colour(0xFFdca358)

	-- Label
	skinColors.vocoderElements	= skinColors.customBG
	skinColors.vocoderText		= skinColors.labelTextColor

	-- Draw
	skinColors.lineColor		= skinColors.labelTextColor
	skinColors.lineColorDark	= COLOR_SURFACE_LINE

	-- Sequencer
	skinColors.seqOneBars		= Colour(0xFF4c6fb2)
	skinColors.seqTwoBars		= Colour(0xFFdca358)
	skinColors.seqThreeBars		= Colour(0xFF14aee0)
	skinColors.seqGrayedOut		= SEQ_GRAYED_OUT
	skinColors.seqOpacityMinus	= 0

	-- Copy / Paste buttons
	skinColors.copyTimbreData		= COLOR_BUFFER_COPY
	skinColors.copyVocoderData		= COLOR_BUFFER_COPY_V
	skinColors.copyColorText		= COLOR_BUFFER_TEXT
	skinColors.copyColorTextEmpty	= COLOR_BUFFER_TEXT_EMPTY

	-- LCD
	skinColors.LCDBacklight		= LCD_BACKLIGHT
	skinColors.LCDDigits		= LCD_DIGITS
	skinColors.LCDText			= LCD_TEXT

	-- Group box
	skinColors.groupBoxBG				= Colour(0xFF1a2529)
	skinColors.groupBoxMainWin			= Colour(0xFF3b697e)
	skinColors.groupBoxOutline			= Colour(0xFF182227)
	skinColors.groupBoxOutlineMainWin	= Colour(0xFF31586a)
	skinColors.groupBoxLabel			= Colour(0xFFdca358)
	skinColors.groupBoxLabelMainWin		= skinColors.labelTextColor
	skinColors.groupBoxRounding			= 10

	-- Settings layer
	skinColors.settingsAlpha	= 1
end

function setColorScheme(colorScheme)

	local i, customIndex
	local controlList = {}

	if colorScheme == csDefault then
		defaultScheme()
	elseif colorScheme == csBlack then
		blackScheme()
	elseif colorScheme == csNordLead then
		nordScheme()
	elseif colorScheme == csJP8080 then
		jp8080Scheme()
	end

	-- Changing panel BG colors
	panel:getPanelEditor():setPropertyString("uiPanelBackgroundColour1", skinColors.panelBG:toString())

	controlList = panel:getModulatorsWildcard("grp*", false)

	for i = 1, #controlList do
		if type(controlList[i]) == "userdata" then

			controlList[i]:getComponent():setPropertyInt("uiGroupOutlineRoundAngle", skinColors.groupBoxRounding)

			customIndex = controlList[i]:getPropertyInt("modulatorCustomIndexGroup")

			if customIndex ~= 2 then
				controlList[i]:getComponent():setPropertyString("uiGroupOutlineColour1", skinColors.groupBoxOutline:toString())
			end

			if customIndex == 1 then

				controlList[i]:getComponent():setPropertyString("uiGroupBackgroundColour1", skinColors.groupBoxBG:toString())
				controlList[i]:getComponent():setPropertyString("uiGroupTextColour", skinColors.groupBoxLabel:toString())
			elseif customIndex == 2 then

				controlList[i]:getComponent():setPropertyString("uiGroupOutlineColour1", skinColors.groupBoxOutlineMainWin:toString())
				controlList[i]:getComponent():setPropertyString("uiGroupBackgroundColour1", skinColors.groupBoxMainWin:toString())
				controlList[i]:getComponent():setPropertyString("uiGroupTextColour", skinColors.groupBoxLabelMainWin:toString())
			end
		end
	end

	-- Changing label colors
	controlList = panel:getModulatorsWildcard("lbl*", false)

	for i = 1, #controlList do
		if type(controlList[i]) == "userdata" then

			if	((controlList[i]:getPropertyInt("modulatorCustomIndexGroup") == 1) and (sharedValues.timbreMode == tmVocoder)) or
 				controlList[i]:getProperty("name") == "lblSettingsSPOS" then

				controlList[i]:getComponent():setPropertyString("uiLabelTextColour", skinColors.vocoderText:toString())
				controlList[i]:getComponent():setPropertyString("uiLabelBgColour", skinColors.vocoderElements:toString())
			elseif controlList[i]:getPropertyInt("modulatorCustomIndexGroup") == 2 then

				controlList[i]:getComponent():setPropertyString("uiLabelTextColour", skinColors.LCDText:toString())
			else

				controlList[i]:getComponent():setPropertyString("uiLabelBgColour", "00000000")
				controlList[i]:getComponent():setPropertyString("uiLabelTextColour", skinColors.labelTextColor:toString())
			end
		end
	end

	-- Changing combo text colors
	controlList = panel:getModulatorsWildcard("cb*", false)

	for i = 1, #controlList do
		if type(controlList[i]) == "userdata" then

			controlList[i]:getComponent():setPropertyString("uiComboTextColour", skinColors.comboText:toString())
		end
	end

	-- Settings window color
	setCompProp("grpSettingsBackground", "uiGroupBackgroundColour1", skinColors.panelBG:toString())
	getComp("grpSettingsBackground"):setAlpha(skinColors.settingsAlpha)

	panelSettings.selectedSkin = colorScheme
end

function paintButtonEmergency(mod, g)

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()
	local crossW = 4

	g:setColour(SEQ_BACKGROUND)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, 2)

	if panel:getPanelEditor():getPropertyInt("uiPanelMenuBarVisible") == 0 then
		g:setColour(COLOR_EMERGENCY)
	else
		g:setColour(COLOR_VOCODER_LABEL)
	end

	g:fillRect((canvasW / 2) - (crossW / 2), 4, crossW, canvasH - 8)
	g:fillRect(4, (canvasW / 2) - (crossW / 2), canvasH - 8, crossW)
end

function emergencyClick()

	if panel:getPanelEditor():getPropertyInt("uiPanelMenuBarVisible") == 1 then
		panel:getPanelEditor():setPropertyInt("uiPanelMenuBarVisible", 0)
	else
		panel:getPanelEditor():setPropertyInt("uiPanelMenuBarVisible", 1)
	end

	getComp("btnEmergency"):repaint()
end

function paintMIDISettingsButton(mod, g)

	local canvasW = mod:getWidth()
	local canvasH = mod:getHeight()

	g:setColour(SEQ_BACKGROUND)
	g:fillRoundedRectangle(0, 0, canvasW, canvasH, 2)

	g:setColour(COLOR_VOCODER_LABEL)
	g:fillRoundedRectangle(4, 4, canvasW - 8, canvasH - 8, 1)

	g:setColour(SEQ_BACKGROUND)
	g:setFont(Font(13, 1))
	g:drawText("M", 5, 3, canvasW - 6, 14, Justification(Justification.left), false)
end

function midiSettingsClick()

	getComp("btnMidiDeviceDialogHidden"):click()
end

function setOperationMode(opMode, muteOutput)

	local blockMessage = false

	if muteOutput ~= nil then
		blockMessage = muteOutput
	end

	local seMessage = {}

	-- Request operation mode
	if not blockMessage then
		local gChan = getGlobalMidiChannel()

		-- MODE CHANGE = 4E(H)
		if (panelSettings.autocheckLCDMode == 1) and (opMode ~= 1) then
			seMessage = {0xF0, 0x42, gChan, 0x58, 0x4E, 0x01, 0x00, 0xF7}
		else
			seMessage = {0xF0, 0x42, gChan, 0x58, 0x4E, opMode, 0x00, 0xF7}
		end

		sendSysExMessage(seMessage)
	end

	if blockMessage then
		-- Change this value only if changes coming from parser
		sharedValues.operationMode = opMode
	end

	externalRepaintInfoWindow()
end

function sendSysExMessage(message)

	panel:sendMidiMessageNow(CtrlrMidiMessage(message))
end

function inputMIDIParser(midiMessage)

	blinkMidiLight()

	local msgData = midiMessage:getData()
	local msgSize = midiMessage:getSize()

	-- Usable data is longer than 3 bytes

	-- MIDI data
	if msgSize == 2 then

		-- Selected patch and bank
		if msgData:getByte(0) == (0xC0 + getGlobalMidiChannel(true))then
			captureProgramChangeMessage(msgData)
		end

	elseif msgSize == 3 then

		-- Incoming message from Program Play mode
		if msgData:getByte(0) == (0xB0 + getGlobalMidiChannel(true)) then

			processProgramPlayMessage(memBlockToTable(msgData))
		end

	-- SysEx parameter data
	elseif (msgSize >= 6) and (msgSize <= 15) then 

		local opType = msgData:getByte(4) 
		local opParam = msgData:getByte(5)

		local controlLS = msgData:getByte(5)
		local controlMS = msgData:getByte(6)

		-- Request replies may be caught here

		-- Identity reply
		if msgSize == 15 then
			if opType == 0x02 then
				if (msgData:getByte(5) == 0x42) and 
				   (msgData:getByte(6) == 0x58) and
				   (msgData:getByte(7) == 0x00) then

					setSynthReachStatus(dsOnline)
				end
			end
		end

		-- Exchange replies
		if msgSize == 6 then
			-- Write | Load successful reply
			if (opType == 0x21) or (opType == 0x23) then
				writeOKReply()
			end

			-- Write error reply
			if (opType == 0x22) or (opType == 0x24) then
				writeErrorReply()
			end
		end

		if msgSize == 8 then

			-- Mode data pushed from HW
			if opType == 0x4E then
				setOperationMode(opParam, true)
			end
		end

		-- Parameters transmission
		if msgSize == 10 then

			-- Requested mode data response
			if opType == 0x42 then
				setOperationMode(opParam, true)
			end

			-- Control change
			if opType == 0x41 then

				-- Since this panel use fancy "lamp radiobuttons" which aren't actual controllers, 
				-- incoming data handling code is required for them

				-- OSC1 waveform changed
				if	(controlLS == sharedValues.osc1SEValues[6]) and
					(controlMS == sharedValues.osc1SEValues[7])	then

					setOsc1WaveformByValue(msgData:getByte(7), true)
				end

				-- OSC2 waveform changed
				if	(controlLS == sharedValues.osc2SEValues[6]) and
 					(controlMS == sharedValues.osc2SEValues[7]) then

					setOsc2WaveformByValue(msgData:getByte(7), true)
				end

				-- OSC Modulation
				if	(controlLS == sharedValues.oscModSEValues[6]) and
 					(controlMS == sharedValues.oscModSEValues[7]) then

					processOscModData(msgData:getByte(7))
				end

				-- Filter type changed
				if	(controlLS == sharedValues.filterSEValues[6]) and
					(controlMS == sharedValues.filterSEValues[7]) then

					setFilterTypeByValue(msgData:getByte(7), true)
				end

				-- LFO1 waveform changed
				if	(controlLS == sharedValues.LFO1SEValues[6]) and
 					(controlMS == sharedValues.LFO1SEValues[7]) then

					setLFO1TypeByValue(msgData:getByte(7), true)
				end

				-- LFO2 waveform changed
				if	(controlLS == sharedValues.LFO2SEValues[6]) and
 					(controlMS == sharedValues.LFO2SEValues[7]) then

					setLFO2TypeByValue(msgData:getByte(7), true)
				end
			end
		end

	elseif  msgSize >= GLOBAL_DATA_SIZE then 

		local opType = msgData:getByte(4) 

		-- Current program data dump
		if (opType == 0x40) and (timerFlags.waitForSingleProgram == true) then
			captureProgramDumpData(msgData)
		end

		-- Patch bank data dump
		if (opType == 0x4C) and (timerFlags.waitForBulkDump == true) then
			captureBulkDumpData(msgData)
		end

		-- Global data dump
		if (opType == 0x51) and (timerFlags.waitForSettings == true) then
			captureGlobalSettings(msgData)
		end

		-- All data dump
		--if opType == 0x50 then
		--end
	end
end

function checkLCDModeEnabled(modulator, modulatorValue, source)

	if blockExecution(source) then
		return
	end

	-- In order for sysex-driven knobs to work the LCD operation mode must be set

	if sharedValues.operationMode ~= omLCD then
		setOperationMode(omLCD)
		requestOperationMode()
	end

	return modulatorValue 
end

function getGlobalMidiChannel(pureValue)

	local mcByte = 0x30

	if pureValue ~= nil then
		if pureValue == true then
			mcByte = 0
		end
	end
		
	return mcByte + (panel:getPropertyInt("panelMidiOutputChannelDevice") - 1)
end

function muteModulator(modName, disable)
	
	if disable then
		modByName(modName):setPropertyString("modulatorMute", "1")
	else
		modByName(modName):setPropertyString("modulatorMute", "0")
	end
end

function mutePanelOut(disableOutput)
	
	if disableOutput then
		panel:setPropertyInt("panelMidiPauseOut", 1)
	else
		panel:setPropertyInt("panelMidiPauseOut", 0)
	end
end

function checkProgramModeEnabled()

	if sharedValues.operationMode ~= omDefault then
		setOperationMode(omDefault)
		requestOperationMode()
	end

	return modulatorValue 
end

function processPlayMessageTuple()

	-- Current table consists of modulator MSB, LSB and Value

	local modMSB = sharedValues.playMessageTuple[1]
	local modLSB = sharedValues.playMessageTuple[2]
	local modValue = sharedValues.playMessageTuple[3]

	local reqLCD = false

	if modMSB == 0x00 then

		if modLSB == 0x02 then
			setModValue("btnArpOnOff", bit.band(modValue, 0x01))
		end

		if modLSB == 0x03 then
			setModValue("cbArpRange", modValue)
		end

		if modLSB == 0x04 then
			setModValue("btnArpLatch", bit.band(modValue, 0x01))
		end

		if modLSB == 0x07 then
			setModValue("cbArpType", math.floor(modValue / 0x16))
		end

		-- Continuous controls will request for setting the LCD mode
		-- Arp Gate
		if modLSB == 0x0A then

			reqLCD = true
		end

	elseif modMSB == 0x04 then

		if modLSB == 0x00 then
			setModValue("cbPatchSource1", math.floor(modValue / 0x10))
		end

		if modLSB == 0x01 then
			setModValue("cbPatchSource2", math.floor(modValue / 0x10))
		end

		if modLSB == 0x02 then
			setModValue("cbPatchSource3", math.floor(modValue / 0x10))
		end

		if modLSB == 0x03 then
			setModValue("cbPatchSource4", math.floor(modValue / 0x10))
		end

		if modLSB == 0x08 then
			setModValue("cbPatchDestination1", math.floor(modValue / 0x10))
		end

		if modLSB == 0x09 then
			setModValue("cbPatchDestination2", math.floor(modValue / 0x10))
		end

		if modLSB == 0x0A then
			setModValue("cbPatchDestination3", math.floor(modValue / 0x10))
		end

		if modLSB == 0x0B then
			setModValue("cbPatchDestination4", math.floor(modValue / 0x10))
		end

		-- Sequence knobs range
		if (modLSB >= 0x10) and (modLSB <= 0x3F) then

			reqLCD = true
		end
	end

	return reqLCD
end

function assertSeqKnobBounds(mod, selectedMode, source)
	
	if blockExecution(source) then
		return
	end

	if sharedValues.timbreMode == tmSynth then

		local knobGroup = getModPropN(mod, "modulatorCustomIndex") + 1
	
		assertSeqKnobBoundsByValue(knobGroup, selectedMode)
	end
end

function getSeqStepMaxVal(selectedMode)

	local minV, maxV, defV

	if sharedValues.timbreMode == tmSynth then

		-- Synthesizer mode:

		-- As manual states:
		-- When Knob is "Step Length" (2)				00~7F : - 6~0~+ 6 (*2-6)
    	-- When Knob is "Pitch" or "OSC2 Semi" (1 or 6)	00~7F : -24~0~+24 (*2-7)
    	-- When Knob is others							00~7F : -63~0~+63 (*2-8)


		if selectedMode == 2 then
 			minV, maxV, defV = -6, 6, 0
		elseif selectedMode == 1 or selectedMode == 6 then
			minV, maxV, defV = -24, 24, 0
		else
			minV, maxV, defV = -63, 63, 0
		end
	else

		-- Vocoder mode:

		-- SEQ1 - Level [0~127]
		-- SEQ2 - Pan [-63/+63]

		if selectedMode == 0 then
			minV, maxV, defV = 0, 127, 64
		else
			minV, maxV, defV = -63, 63, 0
		end
	end

	return {minV, maxV, defV}
end

function syncPanelWithBuffer()

	-- Write timbre knob values to buffer in order to save / send actual values

	-- StartByte disposition
	local sb = DATA_PREAMBLE_BYTES + 1 

	-- Program name size = 12B
	-- Stored directly in dataBuffer

	-- Bytes 12~15 not in use

	-- Byte 16 - packed byte
  	-- Bit 6,7 - Timbre Voice [0~2 = 1+3, 2+2, 3+1]
	dataBuffer[sb + 16] = packBitsToByte(dataBuffer[sb + 16], getModValue("cbTimbreVoice"), 6, 7)

	-- Bit 4,5 - Voice Mode [0~3 = Single, Split, Layer(Dual?), Vocoder]
	dataBuffer[sb + 16] = packBitsToByte(dataBuffer[sb + 16], getModValue("cbTimbreVoiceMode"), 4, 5)

	-- Bit 0-3 - not used

	-- Byte 17 - packed byte
	-- Bit 4~7 - Scale Key [0~11 = C,C#,D,D#,E,F,F#,G,G#,A,A#,B]
	dataBuffer[sb + 17] = packBitsToByte(dataBuffer[sb + 17], getModValue("cbTimbreScaleKey"), 4, 7)

	-- Bit 0~3 - Scale Type [0~9 = Equal Temp~User Scale]
	dataBuffer[sb + 17] = packBitsToByte(dataBuffer[sb + 17], getModValue("cbTimbreScaleType"), 0, 3)
	
	-- 18 - Split Point [0~127 = C-1~G9]
	dataBuffer[sb + 18] = getModValue("knobTimbreSplitPoint")

	-- DELAY FX

	-- Byte 19 - packed byte
  	-- Bit 7 - Delay tempo sync [0, 1 = Off, On]
	dataBuffer[sb + 19] = packBitsToByte(dataBuffer[sb + 19], getModValue("btnDelayTempoSync"), 7)

	-- Bit 4~6 - not use
	-- Bit 0~3 - Time Base [0~14 = 1/32~1/1]
	dataBuffer[sb + 19] = packBitsToByte(dataBuffer[sb + 19], getModValue("cbDelaySyncNote"), 0, 3)

	-- Byte 20 - Delay Time [0~127]
	dataBuffer[sb + 20] = getModValue("knobDelayTime")

	-- Byte 21 - Delay Depth [0~127]
	dataBuffer[sb + 21] = getModValue("knobDelayFeedback")

	-- Byte 22 - Delay Type [0~2 = StereoDelay, CrossDelay, L/R Delay]
	dataBuffer[sb + 22] = getModValue("cbDelayType")

	-- MOD FX

	-- Byte 23 - Mod LFO Speed [0~127]
	dataBuffer[sb + 23] = getModValue("knobDelaySpeed")

	-- Byte 24 - Mod Depth [0~127]
	dataBuffer[sb + 24] = getModValue("knobDelayDepth")

	-- Byte 25 - Mod Type [0~2 = Cho/Flg, Ensemble, Phaser]
	dataBuffer[sb + 25] = getModValue("cbModType")

	-- EQ

	-- Byte 26 - Hi Freq [0~29 = 1.00~18.0 KHz]
	dataBuffer[sb + 26] = getModValue("knobEQHighFreq")

	-- Byte 27 - Hi Gain [64+/-12 = 0+/-12]
	dataBuffer[sb + 27] = getModValue("knobEQHighGain") + 64

	-- Byte 28 - Lo Freq [0~29 = 40~1000 Hz]
	dataBuffer[sb + 28] = getModValue("knobEQLowFreq")

	-- Byte 29 - Lo Gain [64+/-12 = 0+/-12]
	dataBuffer[sb + 29] = getModValue("knobEQLowGain") + 64

	-- ARPEGGIO

	-- Byte 30 - Tempo (MSB) [20~300]
	-- Byte 31 - Tempo (LSB)

	dataBuffer[sb + 30] = calculateLSBMSB(getModValue("knobArpTempo"), true, false)[2]
	dataBuffer[sb + 31] = calculateLSBMSB(getModValue("knobArpTempo"), true, false)[1]

	-- Byte 32
	-- Bit 7 - Arpeggio On/Off [0, 1 = Off, On]
	dataBuffer[sb + 32] = packBitsToByte(dataBuffer[sb + 32], getModValue("btnArpOnOff"), 7)

	-- Bit 6 - Latch [0, 1 = Off, On]
	dataBuffer[sb + 32] = packBitsToByte(dataBuffer[sb + 32], getModValue("btnArpLatch"), 6)

	-- Bit 4,5 - Target [0~2 = Both, Timb1, Timb2]
	dataBuffer[sb + 32] = packBitsToByte(dataBuffer[sb + 32], getModValue("cbArpTarget"), 4, 5)

	-- Bit 1 - not use
	-- Bit 0 - Key Sync [0, 1 = Off, On]
	dataBuffer[sb + 32] = packBitsToByte(dataBuffer[sb + 32], getModValue("btnArpKeySync"), 0)

	-- Byte 33
	-- Bit 0~3 - Type [0~5 = Up~Trigger]
	dataBuffer[sb + 33] = packBitsToByte(dataBuffer[sb + 33], getModValue("cbArpType"), 0, 3)

	-- Bit 4~7 - Range [0~3 = 1~4 Octave]
	dataBuffer[sb + 33] = packBitsToByte(dataBuffer[sb + 33], getModValue("cbArpRange"), 4, 7)

	-- Byte 34 - Gate time [0~100 = 0~100 %]
	dataBuffer[sb + 34] = getModValue("knobArpGate")

	-- Byte 35 - Resolution [0~5 = 1/24, 1/16, 1/12, 1/8, 1/6, 1/4]
	dataBuffer[sb + 35] = getModValue("cbArpResolution")

	-- Byte 36 - Swing [0+/-100 = 0+/-100 %]
	dataBuffer[sb + 36] = bit.band(getModValue("knobArpSwing"), 0xFF)

	-- Byte 37 - (dummy byte)

	if sharedValues.timbreMode == tmSynth then
		syncTimbreWithBuffer(sharedValues.selectedTimbre)
	else
		syncVocoderWithBuffer()
	end
end

function assertSysExFormulas(timbreNumber)

	-- Accepted values are:
	-- 0 - for Timbre mode, Timbre 1
	-- 1 - for Timbre mode, Timbre 2
	-- 2 - for Vocoder mode

	local i, j, startPoint
	local numShift
	local startPoint
	local lsms

	if (timbreNumber == 0) or (timbreNumber == 1) then

		numShift = timbreNumber * SYSEX_VAL_DIFF
		numShiftAlter = timbreNumber * SYSEX_VAL_DIFF_ALT

		-- Numbers were verified one-by-one

		-- Non-visual components
		sharedValues.osc1SEValues 		= setNewModNumber(sharedValues.osc1SEValues,	numShift + 0x49)
		sharedValues.oscModSEValues		= setNewModNumber(sharedValues.oscModSEValues,	numShift + 0x4E)
		sharedValues.osc2SEValues		= setNewModNumber(sharedValues.osc2SEValues,	numShift + 0x4D)
		sharedValues.filterSEValues		= setNewModNumber(sharedValues.filterSEValues,	numShift + 0x54)
		sharedValues.LFO1SEValues		= setNewModNumber(sharedValues.LFO1SEValues,	numShift + 0x68)
		sharedValues.LFO2SEValues		= setNewModNumber(sharedValues.LFO2SEValues,	numShift + 0x6D)

		-- Visual components
		-- Formulas in the synth mode can be calculated
		setSEFormulaMod("cbTimbreMidiCh", numShift + 0x43)
		setSEFormulaMod("cbTimbreAssign", numShift + 0x40)
		setSEFormulaMod("btnEG2Reset", numShift + 0x13D)
		setSEFormulaMod("btnEG1Reset", numShift + 0x13C)
		setSEFormulaMod("cbTimbreTrigger", numShift + 0x41)
		setSEFormulaMod("cbTimbrePriority", numShiftAlter + 0x7E)
		setSEFormulaMod("knobTimbreDetune", (numShift * 2) + 0x42)
		setSEFormulaMod("knobTimbreTune", numShift + 0x45)
		setSEFormulaMod("knobTimbreBendRange", numShift + 0x48)
		setSEFormulaMod("knobTimbreTranspose", numShift + 0x44)
		setSEFormulaMod("knobTimbreVibrato", numShift + 0x46)
		setSEFormulaMod("knobOsc1Control1", numShift + 0x4A)
		setSEFormulaMod("knobOsc2Semitone", numShift + 0x4F)
		setSEFormulaMod("knobOsc2Tune", numShift + 0x50)
		setSEFormulaMod("knobMixerOsc1", numShift + 0x51)
		setSEFormulaMod("knobMixerOsc2", numShift + 0x52)
		setSEFormulaMod("knobMixerNoise", numShift + 0x53)
		setSEFormulaMod("knobTimbrePorta", numShift + 0x47)
		setSEFormulaMod("knobFilterCutoff", numShift + 0x55)
		setSEFormulaMod("knobFilterResonance", numShift + 0x56)
		setSEFormulaMod("knobFilterEG1Int", numShift + 0x57)
		setSEFormulaMod("knobFilterVeloSens", numShift + 0x62)
		setSEFormulaMod("knobFilterKbdTrk", numShift + 0x58)
		setSEFormulaMod("knobAmpLevel", numShift + 0x59)
		setSEFormulaMod("knobAmpPan", numShift + 0x5A)
		setSEFormulaMod("btnAmpEG2Gate", numShift + 0x5B)
		setSEFormulaMod("btnAmpDistortion", numShift + 0x5C)
		setSEFormulaMod("knobEG1Attack", numShift + 0x5E)
		setSEFormulaMod("knobEG1Decay", numShift + 0x5F)
		setSEFormulaMod("knobEG1Sustain", numShift + 0x60)
		setSEFormulaMod("knobEG1Release", numShift + 0x61)
		setSEFormulaMod("knobEG2Attack", numShift + 0x63)
		setSEFormulaMod("knobEG2Decay", numShift + 0x64)
		setSEFormulaMod("knobEG2Sustain", numShift + 0x65)
		setSEFormulaMod("knobEG2Release", numShift + 0x66)
		setSEFormulaMod("knobAmpVeloSens", numShift + 0x67)
		setSEFormulaMod("knobAmpKeyTrack", numShift + 0x5D)
		setSEFormulaMod("knobLFO1Frequency", numShift + 0x69)
		setSEFormulaMod("cbLFO1KeySync", numShift + 0x6C)
		setSEFormulaMod("btnLFO1TempoSync", numShift + 0x6B)
		setSEFormulaMod("cbLFO1SyncNote", numShift + 0x6A)
		setSEFormulaMod("knobLFO2Frequency", numShift + 0x6E)
		setSEFormulaMod("cbLFO2KeySync", numShiftAlter + 0x71)
		setSEFormulaMod("btnLFO2TempoSync", numShiftAlter + 0x70)
		setSEFormulaMod("cbLFO2SyncNote", numShift + 0x6F)
		setSEFormulaMod("cbPatchSource1", numShiftAlter + 0x72)
		setSEFormulaMod("cbPatchSource2", numShiftAlter + 0x75)
		setSEFormulaMod("cbPatchSource3", numShiftAlter + 0x78)
		setSEFormulaMod("cbPatchSource4", numShiftAlter + 0x7B)
		setSEFormulaMod("cbPatchDestination1", numShiftAlter + 0x73)
		setSEFormulaMod("cbPatchDestination2", numShiftAlter + 0x76)
		setSEFormulaMod("cbPatchDestination3", numShiftAlter + 0x79)
		setSEFormulaMod("cbPatchDestination4", numShiftAlter + 0x7C)
		setSEFormulaMod("knobPatch1Amount", numShiftAlter + 0x74)
		setSEFormulaMod("knobPatch2Amount", numShiftAlter + 0x77)
		setSEFormulaMod("knobPatch3Amount", numShiftAlter + 0x7A)
		setSEFormulaMod("knobPatch4Amount", numShiftAlter + 0x7D)
		setSEFormulaMod("btnSeqOnOff", numShift + 0x100)
		setSEFormulaMod("cbSeqRunMode", numShift + 0x103)
		setSEFormulaMod("cbSeqResolution", numShift + 0x105)
		setSEFormulaMod("knobSeqLastStep", numShift + 0x101)
		setSEFormulaMod("cbSeqType", numShift + 0x102)
		setSEFormulaMod("cbSeqKeySync", numShift + 0x104)
		setSEFormulaMod("cbSeqKnob1", numShift + 0x106)
		setSEFormulaMod("cbSeqMotion1", numShift + 0x107)
		setSEFormulaMod("cbSeqKnob2", numShift + 0x118)
		setSEFormulaMod("cbSeqMotion2", numShift + 0x119)
		setSEFormulaMod("cbSeqKnob3", numShift + 0x12A)
		setSEFormulaMod("cbSeqMotion3", numShift + 0x12B)

		startPoint = 0x107
		for j = 1, 3 do
			for i = 1, 16 do
				setSEFormulaMod(string.format("knobSeq%dStep%d", j, i), numShift + startPoint + i + (18 * (j - 1)))
			end
		end
	else

		-- Non-visual components
		sharedValues.osc1SEValues 		= setNewModNumber(sharedValues.osc1SEValues, 0x270)
		sharedValues.filterSEValues		= setNewModNumber(sharedValues.filterSEValues, 0x300)
		sharedValues.LFO1SEValues		= setNewModNumber(sharedValues.LFO1SEValues, 0x318)
		sharedValues.LFO2SEValues		= setNewModNumber(sharedValues.LFO2SEValues, 0x320)

		setSEFormulaMod("cbTimbreMidiCh", 0x263)
		setSEFormulaMod("cbTimbreAssign", 0x260)
		setSEFormulaMod("btnEG2Reset", 0x267)
		setSEFormulaMod("btnEG1Reset", 0x266)
		setSEFormulaMod("cbTimbreTrigger", 0x261)
		setSEFormulaMod("cbTimbrePriority", 0x264)
		setSEFormulaMod("knobTimbreDetune", 0x262)
		setSEFormulaMod("knobTimbreTune", 0x269)
		setSEFormulaMod("knobTimbreBendRange", 0x26C)
		setSEFormulaMod("knobTimbreTranspose", 0x268)
		setSEFormulaMod("knobTimbreVibrato", 0x26A)
		setSEFormulaMod("knobTimbrePorta", 0x26B)
		setSEFormulaMod("knobOsc1Control1", 0x271)
		setSEFormulaMod("knobOsc2Semitone", 0x27B)
		setSEFormulaMod("knobOsc2Tune", 0x27D)
		setSEFormulaMod("knobMixerOsc1", 0x278)
		setSEFormulaMod("knobMixerOsc2", 0x279)
		setSEFormulaMod("knobMixerNoise", 0x27A)
		setSEFormulaMod("knobFilterCutoff", 0x301)
		setSEFormulaMod("knobFilterResonance", 0x302)
		setSEFormulaMod("knobFilterEG1Int", 0x304)
		setSEFormulaMod("knobFilterVeloSens", 0x27C)
		setSEFormulaMod("knobFilterKbdTrk", 0x305)
		setSEFormulaMod("knobAmpLevel", 0x308)
		setSEFormulaMod("knobAmpPan", 0x309)
		setSEFormulaMod("btnAmpEG2Gate", 0x27E)
		setSEFormulaMod("btnAmpDistortion", 0x30A)
		setSEFormulaMod("knobAmpVeloSens", 0x30B)
		setSEFormulaMod("knobAmpKeyTrack", 0x30C)
		setSEFormulaMod("knobEG1Attack", 0x314)
		setSEFormulaMod("knobEG1Decay", 0x315)
		setSEFormulaMod("knobEG1Sustain", 0x316)
		setSEFormulaMod("knobEG1Release", 0x317)
		setSEFormulaMod("knobEG2Attack", 0x310)
		setSEFormulaMod("knobEG2Decay", 0x311)
		setSEFormulaMod("knobEG2Sustain", 0x312)
		setSEFormulaMod("knobEG2Release", 0x313)
		setSEFormulaMod("knobLFO1Frequency", 0x319)
		setSEFormulaMod("cbLFO1KeySync", 0x31C)
		setSEFormulaMod("btnLFO1TempoSync", 0x31B)
		setSEFormulaMod("cbLFO1SyncNote", 0x31A)
		setSEFormulaMod("knobLFO2Frequency", 0x321)
		setSEFormulaMod("cbLFO2KeySync", 0x324)
		setSEFormulaMod("btnLFO2TempoSync", 0x323)
		setSEFormulaMod("cbLFO2SyncNote", 0x322)
		setSEFormulaMod("cbPatchSource1", 0x303)

		startPoint = 0x32F
		for j = 1, 2 do
			for i = 1, 16 do
				setSEFormulaMod(string.format("knobSeq%dStep%d", j, i), startPoint + i + (16 * (j - 1)))
			end
		end
	end

	-- Make new formulas work for input messages
	panel:getInputComparator():rehashComparator()
end

function setModValue(modname, modvalue)

	local modVal = modvalue
	local modMax = getModPropN(modByName(modname), "modulatorMax")

	if modvalue > modMax then
		modVal = modMax
		genAssertErrorMessage(modname, modMax, modvalue, errMaxValExceeded)
 	end

	modByName(modname):setModulatorValue(modvalue, false, false, false)
end

function setModValueCheck(modname, modvalue)

	-- Set value only if the control is enabled
	if getComp(modname):getPropertyInt("componentDisabled") == 1 then
		return
	end

	local modVal = modvalue
	local modMax = getModPropN(modByName(modname), "modulatorMax")

	if modvalue > modMax then
		modVal = modMax
		genAssertErrorMessage(modname, modMax, modvalue, errMaxValExceeded)
 	end

	modByName(modname):setModulatorValue(modvalue, false, false, false)
end

function assertSeqKnobBoundsByValue(knobGroup, selectedMode)
	
	local i
	local minV, maxV, defV
	local currKnob

	local knobBounds = getSeqStepMaxVal(selectedMode)

	minV, maxV, defV = knobBounds[1], knobBounds[2], knobBounds[3]

	for i = 1, 16 do

		currKnob = string.format("knobSeq%dStep%d", knobGroup, i)

		setCompPropN(currKnob, "uiSliderMin", minV)
		setCompPropN(currKnob, "uiSliderMax", maxV)
		setCompPropN(currKnob, "uiSliderDoubleClickValue", defV)

		if modByName(currKnob):getValue() > maxV then
			modByName(currKnob):setModulatorValue(maxV, false, false, false)
		end

		if modByName(currKnob):getValue() < minV then
			modByName(currKnob):setModulatorValue(minV, false, false, false)
		end

		getComp(currKnob):repaint()
	end

	externalRepaintSequencer()
end

function syncTimbreWithBuffer(layerToSync)

	-- Write timbre knob values to buffer in order to save / send actual values
	-- or just to change timbre layer

	local sb 

	if layerToSync == 0 then
		-- First byte of Timbre One data
		sb = TIMBRE_ONE_STARTBYTE -- 45
	else
		-- First byte of Timbre Two data
		sb = TIMBRE_TWO_STARTBYTE -- 152
	end

	-- Synth parameter (Mode = Single, Split, Dual)
	-- Bytes 38~145 - TIMBRE1 DATA

	-- Byte 0 - MIDI ch. [-1, 0~15 = GLB, 1~16 ch]
	dataBuffer[sb] = bit.band(getModValue("cbTimbreMidiCh") - 1, 0xFF)

	-- Byte 1 - packed byte
   	-- Bit 6,7 - Assign Mode [0, 1, 2 = Mono, Poly, Unison]
	dataBuffer[sb + 1] = packBitsToByte(dataBuffer[sb + 1], tonumber(getModValue("cbTimbreAssign")), 6, 7)

	-- Bit 5 - EG2 reset [0, 1 = Off, On]
	dataBuffer[sb + 1] = packBitsToByte(dataBuffer[sb + 1], getModValue("btnEG2Reset"), 5)

	-- Bit 4 - EG1 reset [0, 1 = Off, On]
	dataBuffer[sb + 1] = packBitsToByte(dataBuffer[sb + 1], getModValue("btnEG1Reset"), 4)

	-- Bit 3 - Trigger Mode [0, 1 = Single, Multi (use Mono / Unison Mode)]
	dataBuffer[sb + 1] = packBitsToByte(dataBuffer[sb + 1], getModValue("cbTimbreTrigger"), 3)

	-- Bit 0~1 - Key Priority [0~2 = Last, Low, High]
	dataBuffer[sb + 1] = packBitsToByte(dataBuffer[sb + 1], getModValue("cbTimbrePriority"), 0, 1)

	-- Byte 2 - Unison Detune [0~99=0~99 cent (use Unison Mode)]
	dataBuffer[sb + 2] = getModValue("knobTimbreDetune")

	-- PITCH

	-- Byte 3 - Tune [64+/-50 = 0+/-50 cent]
	dataBuffer[sb + 3] = getModValue("knobTimbreTune") + 64

	-- Byte 4 - Bend Range [64+/-12 = 0+/-12 note]
	dataBuffer[sb + 4] = getModValue("knobTimbreBendRange") + 64

	-- Byte 5 - Transpose [64+/-24 = 0+/-24 note]
	dataBuffer[sb + 5] = getModValue("knobTimbreTranspose") + 64

	-- Byte 6 - Vibrato Int [64+/-63 = 0+/-63]
	dataBuffer[sb + 6] = getModValue("knobTimbreVibrato") + 64

	-- OSC1

	-- Byte 7 - Wave [0~7 = Saw~Audio In]
	-- Stored directly in buffer, not in modulator, so no reason to sync it

	-- Byte 8 - Waveform CTRL1 [0~127]
	dataBuffer[sb + 8] = getModValue("knobOsc1Control1")

	if dataBuffer[sb + 7] ~= 5 then -- DWGS not selected

		-- Byte 9 - Waveform CTRL2 [0~127]
		dataBuffer[sb + 9] = getModValue("knobOsc1Control2")
	else
 
		-- Byte 10 - DWGS Wave [0~63 = DWGS No. 1~64 (when OSC1 Wave is "DWGS")]
		dataBuffer[sb + 10] = getModValue("knobOsc1Control2")
	end

	-- Byte 11 - (dummy byte)

	-- OSC2

	-- Byte 12 - packed byte
  	-- Bit 6,7 - not use
	-- Bit 4,5 - Mod Select [0~3 = Off, Ring, Sync, RingSync]
	-- Stored directly in buffer

	-- Bit 2,3 - not use
	-- Bit 0,1 - Wave [0~2 = Saw, Squ, Tri]
	-- Stored directly in buffer

	-- Byte 13 - Semitone [64+/-24 = 0+/-24 note]
	dataBuffer[sb + 13] = getModValue("knobOsc2Semitone") + 64

	-- Byte 14 - Tune [64+/-63=0+/-63]
	dataBuffer[sb + 14] = getModValue("knobOsc2Tune") + 64

	-- PITCH (2)

	-- Byte 15 - packed byte
  	-- Bit B7 - not use
	-- Bit B0~6 - Portamento Time [0~127]
	dataBuffer[sb + 15] = packBitsToByte(dataBuffer[sb + 15], getModValue("knobTimbrePorta"), 0, 6)

	-- MIXER

	-- Byte 16 - OSC1 Level [0~127]
	dataBuffer[sb + 16] = getModValue("knobMixerOsc1")

	-- Byte 17 - OSC2 Level [0~127]
	dataBuffer[sb + 17] = getModValue("knobMixerOsc2")

	-- Byte 18 - Noise [0~127]
	dataBuffer[sb + 18] = getModValue("knobMixerNoise")

	-- FILTER

	-- Byte 19 - Filter Type [0~3 = 24LPF, 12LPF, 12BPF, 12HPF]
	-- Stored directly in buffer

	-- Byte 20 - Filter Cutoff [0~127]
	dataBuffer[sb + 20] = getModValue("knobFilterCutoff")

	-- Byte 21 - Filter Resonance [0~127]
	dataBuffer[sb + 21] = getModValue("knobFilterResonance")

	-- Byte 22 - Filter EG1 Intensity [64+/-63 = 0+/-63]
	dataBuffer[sb + 22] = getModValue("knobFilterEG1Int") + 64

	-- Byte 23 - Filter Velocity Sense [64+/-63 = 0+/-63]
	dataBuffer[sb + 23] = getModValue("knobFilterVeloSens") + 64

	-- Byte 24 - Filter Keyboard Track [64+/-63 = 0+/-63]
	dataBuffer[sb + 24] = getModValue("knobFilterKbdTrk") + 64

	-- AMP

	-- Byte 25 - Amp Level [0~127]
	dataBuffer[sb + 25] = getModValue("knobAmpLevel")

	-- Byte 26 - Amp Panpot [0~64~127 = L64~CNT~R63]
	dataBuffer[sb + 26] = getModValue("knobAmpPan") + 64

	-- Byte 27 - packed byte
  	-- Bit 7 - not use
	-- Bit 6 - Amp SW [0, 1 = EG2, Gate]
	dataBuffer[sb + 27] = packBitsToByte(dataBuffer[sb + 27], getModValue("btnAmpEG2Gate"), 6)

	-- Bit 1~5 - not use
	-- Bit 0   | Distortion [0, 1 = Off, On]
	dataBuffer[sb + 27] = packBitsToByte(dataBuffer[sb + 27], getModValue("btnAmpDistortion"), 0)

	-- Byte 28 - Velocity Sense [64+/-63 = 0+/-63]
	dataBuffer[sb + 28] = getModValue("knobAmpVeloSens") + 64

	-- Byte 29 - Keyboard Track [64+/-63 = 0+/-63]
	dataBuffer[sb + 29] = getModValue("knobAmpKeyTrack") + 64

	-- EG1

	-- Byte 30 - Attack [0~127]
	dataBuffer[sb + 30] = getModValue("knobEG1Attack")

	-- Byte 31 - Decay [0~127]
	dataBuffer[sb + 31] = getModValue("knobEG1Decay")

	-- Byte 32 - Sustain [0~127]
	dataBuffer[sb + 32] = getModValue("knobEG1Sustain")

	-- Byte 33 - Release [0~127]
	dataBuffer[sb + 33] = getModValue("knobEG1Release")

	-- EG2

	-- Byte 34 - Attack [0~127]
	dataBuffer[sb + 34] = getModValue("knobEG2Attack")

	-- Byte 35 - Decay [0~127]
	dataBuffer[sb + 35] = getModValue("knobEG2Decay")

	-- Byte 36 - Sustain [0~127]
	dataBuffer[sb + 36] = getModValue("knobEG2Sustain")

	-- Byte 37 - Release [0~127]
	dataBuffer[sb + 37] = getModValue("knobEG2Release")

	-- LFO1

	-- Byte 38 - packed byte
	-- Bit 6,7 - not use
	-- Bit 4,5 - Key Sync [0~2 = OFF, Timbre, Voice]
	dataBuffer[sb + 38] = packBitsToByte(dataBuffer[sb + 38], getModValue("cbLFO1KeySync"), 4, 5)

	-- Bit 2,3 - not use
	-- Bit 0,1 - Wave [0~3 = Saw, Squ, Tri, S/H]
	-- Stored directly in buffer

	-- Byte 39 - LFO1 Frequency [0~127]
	dataBuffer[sb + 39] = getModValue("knobLFO1Frequency")

	-- Byte 40 - packed byte
  	-- Bit 7 - LFO1 Tempo Sync [0, 1 = Off, On]
	dataBuffer[sb + 40] = packBitsToByte(dataBuffer[sb + 40], getModValue("btnLFO1TempoSync"), 7)

	-- Bit 5,6 - not use
	-- Bit 0~4 - LFO1 Sync Note [0~14 = 1/1~1/32]
	dataBuffer[sb + 40] = packBitsToByte(dataBuffer[sb + 40], getModValue("cbLFO1SyncNote"), 0, 4)

	-- LFO2

	-- Byte 41 - packed byte
  	-- Bit 6,7 - not use
	-- Bit 4,5 - Key Sync [0~2 = OFF, Timbre, Voice]
	dataBuffer[sb + 41] = packBitsToByte(dataBuffer[sb + 41], getModValue("cbLFO2KeySync"), 4, 5)

	-- Bit 2,3 - not use
	-- Bit 0,1 - Wave [0~3 = Saw, Squ(+), Sin, S/H]
	-- Stored directly in buffer

	-- Byte 42 - LFO2 Frequency [0~127]
	dataBuffer[sb + 42] = getModValue("knobLFO2Frequency")

	-- Byte 43 - packed byte
  	-- Bit 7 - LFO2 Tempo Sync [0, 1 = Off, On]
	dataBuffer[sb + 43] = packBitsToByte(dataBuffer[sb + 43], getModValue("btnLFO2TempoSync"), 7)

	-- Bit 5,6 - not use
	-- Bit 0~4 - LFO2 Sync Note [0~14 = 1/1~1/32]
	dataBuffer[sb + 43] = packBitsToByte(dataBuffer[sb + 43], getModValue("cbLFO2SyncNote"), 0, 4)

	-- PATCH

	-- Byte 44 - packed byte
  	-- Bit 4~7 - Patch1 Destination [0~7 = PITCH~LFO2FREQ]
	dataBuffer[sb + 44] = packBitsToByte(dataBuffer[sb + 44], getModValue("cbPatchDestination1"), 4, 7)

	-- Bit 0~3 - Patch1 Source [0~7 = EG1~MIDI2]
	dataBuffer[sb + 44] = packBitsToByte(dataBuffer[sb + 44], getModValue("cbPatchSource1"), 0, 3)

	-- Byte 45 - Patch1 Intensity [64+/-63 = 0+/-63]
	dataBuffer[sb + 45] = getModValue("knobPatch1Amount") + 64

	-- Byte 46 - packed byte
  	-- Bit 4~7 - Patch2 Destination [0~7 = PITCH~LFO2FREQ]
	dataBuffer[sb + 46] = packBitsToByte(dataBuffer[sb + 46], getModValue("cbPatchDestination2"), 4, 7)

	-- Bit 0~3 - Patch2 Source [0~7 = EG1~MIDI2]
	dataBuffer[sb + 46] = packBitsToByte(dataBuffer[sb + 46], getModValue("cbPatchSource2"), 0, 3)

	-- Byte 47 - Patch2 Intensity [64+/-63 = 0+/-63]
	dataBuffer[sb + 47] = getModValue("knobPatch2Amount") + 64

	-- Byte 48 - packed byte
  	-- Bit 4~7 - Patch3 Destination [0~7=PITCH~LFO2FREQ]
	dataBuffer[sb + 48] = packBitsToByte(dataBuffer[sb + 48], getModValue("cbPatchDestination3"), 4, 7)

	-- Bit 0~3 - Patch3 Source [0~7 = EG1~MIDI2]
	dataBuffer[sb + 48] = packBitsToByte(dataBuffer[sb + 48], getModValue("cbPatchSource3"), 0, 3)

	-- Byte 49 - Patch3 Intensity [64+/-63 = 0+/-63]
	dataBuffer[sb + 49] = getModValue("knobPatch3Amount") + 64

	-- Byte 50 - packed byte
  	-- Bit 4~7 - Patch4 Destination [0~7 = PITCH~LFO2FREQ]
	dataBuffer[sb + 50] = packBitsToByte(dataBuffer[sb + 50], getModValue("cbPatchDestination4"), 4, 7)

	-- Bit 0~3 - Patch4 Source [0~7 = EG1~MIDI2]
	dataBuffer[sb + 50] = packBitsToByte(dataBuffer[sb + 50], getModValue("cbPatchSource4"), 0, 3)

	-- Byte 51 - Patch4 Intensity [64+/-63 = 0+/-63]
	dataBuffer[sb + 51] = getModValue("knobPatch4Amount") + 64

	-- SEQ

	-- Byte 52 - packed byte
 	-- Bit 7 - SEQ On/Off [0, 1 = Off, On]
	dataBuffer[sb + 52] = packBitsToByte(dataBuffer[sb + 52], getModValue("btnSeqOnOff"), 7)

	-- Bit 6 - SEQ Run Mode [0, 1 = 1Shot, Loop (only Loop when KeySync is "OFF".)]
	dataBuffer[sb + 52] = packBitsToByte(dataBuffer[sb + 52], getModValue("cbSeqRunMode"), 6)

	-- Bit 5 - not use
	-- Bit 0~4 - SEQ Resolution [0~15 = 1/48~1/1]
	dataBuffer[sb + 52] = packBitsToByte(dataBuffer[sb + 52], getModValue("cbSeqResolution"), 0, 4)

	-- Byte 53 - packed byte
  	-- Bit 4~7 - SEQ Last Step [0~15 = 1~16]
	dataBuffer[sb + 53] = packBitsToByte(dataBuffer[sb + 53], getModValue("knobSeqLastStep") - 1, 4, 7)

	-- Bit 2,3 - SEQ Type [0~3 = Fowrd,Reverse,Alt1,Alt2]
	dataBuffer[sb + 53] = packBitsToByte(dataBuffer[sb + 53], getModValue("cbSeqType"), 2, 3)

	-- Bit 0,1 - SEQ Key Sync [0~2 = OFF, Timbre,Voice]
	dataBuffer[sb + 53] = packBitsToByte(dataBuffer[sb + 53], getModValue("cbSeqKeySync"), 0, 1)

	-- SEQ1 parameter
	-- Byte 54 - Knob 1 [0~30 = None~Patch4Int]
	dataBuffer[sb + 54] = getModValue("cbSeqKnob1")

	-- Byte 55 - packed byte
	-- Bit 1~7 - not use
	-- Bit 0 - SEQ1 Motion Type [0, 1 = Smooth, Step]
	dataBuffer[sb + 55] = packBitsToByte(dataBuffer[sb + 55], getModValue("cbSeqMotion1"), 0)

	-- Byte 56~71 - SEQ1 Step Value [64+/-63 = 0+/-63]
	for i = 1, 16 do
		dataBuffer[sb + 55 + i] = getModValue(string.format("knobSeq1Step%d", i)) + 64
	end

	-- SEQ2 parameter
	-- Byte 72 - Knob 2 [0~30 = None~Patch4Int]
	dataBuffer[sb + 72] = getModValue("cbSeqKnob2")
	
	-- Byte 73 - packed byte
	-- Bit 1~7 - not use
	-- Bit 0 - SEQ2 Motion Type [0, 1 = Smooth, Step]
	dataBuffer[sb + 73] = packBitsToByte(dataBuffer[sb + 73], getModValue("cbSeqMotion2"), 0)

	-- Byte 74~89 - SEQ2 Step Value [64+/-63 = 0+/-63]
	for i = 1, 16 do
		dataBuffer[sb + 73 + i] = getModValue(string.format("knobSeq2Step%d", i)) + 64
	end

	-- SEQ3 parameter
	-- Byte 90 - Knob 3 [0~30 = None~Patch4Int]
	dataBuffer[sb + 90] = getModValue("cbSeqKnob3")
	
	-- Byte 91 - packed byte
	-- Bit 1~7 - not use
	-- Bit 0 - SEQ3 Motion Type [0, 1 = Smooth, Step]
	dataBuffer[sb + 91] = packBitsToByte(dataBuffer[sb + 73], getModValue("cbSeqMotion3"), 0)

	-- Byte 92~107 - SEQ3 Step Value [64+/-63 = 0+/-63]
	for i = 1, 16 do
		dataBuffer[sb + 91 + i] = getModValue(string.format("knobSeq3Step%d", i)) + 64
	end

	-- Synth parameter (Mode = Split, Dual) - will be applied same actions, but
	-- start byte will be shifted
	-- Bytes 146~253 - TIMBRE2 DATA
end

function syncVocoderWithBuffer()

	-- Applying vocoder data with buffer
	local sb
	local i

	sb = 1

	-- Byte 0 - MIDI ch [-1, 0~15 = GLB, 1~16ch]
	vocoderBuffer[sb] = bit.band(getModValue("cbTimbreMidiCh") - 1, 0xFF)

	-- Byte 1  
	-- Bit 6,7 - Assign Mode [0, 1, 2 = Mono, Poly, Unison]
	vocoderBuffer[sb + 1] = packBitsToByte(vocoderBuffer[sb + 1], tonumber(getModValue("cbTimbreAssign")), 6, 7)

	-- Bit 5 - EG2 reset [0, 1 = Off, On]
	vocoderBuffer[sb + 1] = packBitsToByte(vocoderBuffer[sb + 1], getModValue("btnEG2Reset"), 5)

	-- Bit 4 - EG1 reset [0, 1 = Off, On]
	vocoderBuffer[sb + 1] = packBitsToByte(vocoderBuffer[sb + 1], getModValue("btnEG1Reset"), 4)

	-- Bit 3 - Trigger Mode [0,1=Single,Multi] (use Mono/Unison Mode)
	vocoderBuffer[sb + 1] = packBitsToByte(vocoderBuffer[sb + 1], getModValue("cbTimbreTrigger"), 3)

	-- Bit 0~1 - Key Priority [0~2 = Last, Low, High]
	vocoderBuffer[sb + 1] = packBitsToByte(vocoderBuffer[sb + 1], getModValue("cbTimbrePriority"), 0, 1)

	-- Byte 2 - Unison Detune [0~99 = 0~99 cent] (use Unison Mode)
	vocoderBuffer[sb + 2] = getModValue("knobTimbreDetune")

	-- PITCH

	-- Byte 3 - Tune [64+/-50 = 0+/-50[cent]
	vocoderBuffer[sb + 3] = getModValue("knobTimbreTune") + 64

	-- Byte 4 - Bend Range [64+/-12 = 0+/-12[note]
	vocoderBuffer[sb + 4] = getModValue("knobTimbreBendRange") + 64

	-- Byte 5 - Transpose [64+/-24 = 0+/-24[note]
	vocoderBuffer[sb + 5] = getModValue("knobTimbreTranspose") + 64

	-- Byte 6 - Vibrato Int [64+/-63 = 0+/-63
	vocoderBuffer[sb + 6] = getModValue("knobTimbreVibrato") + 64

	-- OSC

	-- Byte 7 - Wave [0~7 = Saw~Audio In]
	-- Stored directly in buffer, not in modulator, so no reason to sync it

	-- Byte 8 - Waveform CTRL1 [0~127]
	vocoderBuffer[sb + 8] = getModValue("knobOsc1Control1")

	if vocoderBuffer[sb + 7] ~= 5 then -- DWGS not selected

		-- Byte 9 - Waveform CTRL2 [0~127]
		vocoderBuffer[sb + 9] = getModValue("knobOsc1Control2")
	else
 
		-- Byte 10 - DWGS Wave [0~63 = DWGS No. 1~64 (when OSC1 Wave is "DWGS")]
		vocoderBuffer[sb + 10] = getModValue("knobOsc1Control2")
	end

	-- Byte 11 - (dummy byte)

	-- AUDIO IN2

	-- Byte 12
	-- Bit 1~7 - not use
	-- Bit 0 - HPF Gate [0, 1 = Dis, Ena]
	vocoderBuffer[sb + 12] = packBitsToByte(vocoderBuffer[sb + 12], getModValue("btnAmpEG2Gate"), 0, 1)

	-- Byte 13 - (dummy byte)

	-- PITCH (2)

	-- Byte 14
	-- Bit 7 - not use [(0)
	-- Bit 0~6 - Portamento Time [0~127]
	vocoderBuffer[sb + 14] = packBitsToByte(vocoderBuffer[sb + 14], getModValue("knobTimbrePorta"), 0, 6)

	-- MIXER

	-- Byte 15 - OSC1 Level [0~127]
	vocoderBuffer[sb + 15] = getModValue("knobMixerOsc1")

	-- Byte 16 - Ext1 Level [0~127]
	vocoderBuffer[sb + 16] = getModValue("knobMixerOsc2")

	-- Byte 17 - Noise Level [0~127]
	vocoderBuffer[sb + 17] = getModValue("knobMixerNoise")

	-- AUDIO IN2 (2)

	-- Byte 18 - HPF Level [0~127]
	vocoderBuffer[sb + 18] = getModValue("knobOsc2Semitone")

	-- Byte 19 - Gate Sense [0~127]
	vocoderBuffer[sb + 19] = getModValue("knobFilterVeloSens")

	-- Byte 20 - Threshold [0~127]
	vocoderBuffer[sb + 20] = getModValue("knobOsc2Tune")

	-- FILTER

	-- Byte 21 - Shift [0~4 = 0, +1, +2, -1, -2]
	-- Stored directly in buffer

	-- Byte 22 - Cutoff [64+/-63 = 0+/-63]
	vocoderBuffer[sb + 22] = getModValue("knobFilterCutoff") + 64

	-- Byte 23 - Resonance [0~127]
	vocoderBuffer[sb + 23] = getModValue("knobFilterResonance")

	-- Byte 24 - Mod Source [0~7 = EG1~MIDI2]
	vocoderBuffer[sb + 24] = getModValue("cbPatchSource1")

	-- Byte 25 - Intensity [64+/-63 = 0+/-63]
	vocoderBuffer[sb + 25] = getModValue("knobFilterEG1Int") + 64

	-- Byte 26 - E.F.Sense [0~127]
	vocoderBuffer[sb + 26] = getModValue("knobFilterKbdTrk")

	-- AMP

	-- Byte 27 - Level [0~127]
	vocoderBuffer[sb + 27] = getModValue("knobAmpLevel")

	-- Byte 28 - Direct Level [0~127]
	vocoderBuffer[sb + 28] = getModValue("knobAmpPan")

	-- Byte 29
	-- Bit 1~7 - not use
	-- Bit 0 - Distortion On/Off [0, 1 = Off, On]
	vocoderBuffer[sb + 29] = packBitsToByte(vocoderBuffer[sb + 29], getModValue("btnAmpDistortion"), 0)

	-- Byte 30 - Vel.Sense [64+/-63 = 0+/-63]
	vocoderBuffer[sb + 30] = getModValue("knobAmpVeloSens") + 64

	-- Byte 31 - KeyTrack [64+/-63 = 0+/-63]
	vocoderBuffer[sb + 31] = getModValue("knobAmpKeyTrack") + 64

	-- EG1

	-- Byte 32 - Attack [0~127]
	vocoderBuffer[sb + 32] = getModValue("knobEG1Attack")

	-- Byte 33 - Decay [0~127]
	vocoderBuffer[sb + 33] = getModValue("knobEG1Decay")

	-- Byte 34 - Sustain [0~127]
	vocoderBuffer[sb + 34] = getModValue("knobEG1Sustain")

	-- Byte 35 - Release [0~127]
	vocoderBuffer[sb + 35] = getModValue("knobEG1Release")

	-- EG2

	-- Byte 36 - Attack [0~127]
	vocoderBuffer[sb + 36] = getModValue("knobEG2Attack")

	-- Byte 37 - Decay [0~127]
	vocoderBuffer[sb + 37] = getModValue("knobEG2Decay")

	-- Byte 38 - Sustain [0~127]
	vocoderBuffer[sb + 38] = getModValue("knobEG2Sustain")

	-- Byte 39 - Release [0~127]
	vocoderBuffer[sb + 39] = getModValue("knobEG2Release")

	-- LFO1

	-- Byte 40
	-- Bit 6,7 - not use
	-- Bit 4,5 - Key Sync [0~2 = OFF, Timbre, Voice]
	vocoderBuffer[sb + 40] = packBitsToByte(vocoderBuffer[sb + 40], getModValue("cbLFO1KeySync"), 4, 5)

	-- Bit 2,3 - not use
	-- Bit 0,1 - Wave [0~3 = Saw, Squ, Tri, S/H]
	-- Stored directly in buffer

	-- Byte 41 - Frequency [0~127]
	vocoderBuffer[sb + 41] = getModValue("knobLFO1Frequency")

	-- Byte 42
	-- Bit 7 - Tempo Sync [0,1 = Off,On]
	vocoderBuffer[sb + 42] = packBitsToByte(vocoderBuffer[sb + 42], getModValue("btnLFO1TempoSync"), 7)

	-- Bit 5,6 - not use
	-- Bit 0~4 - Sync Note [0~14 = 1/1~1/32]
	vocoderBuffer[sb + 42] = packBitsToByte(vocoderBuffer[sb + 42], getModValue("cbLFO1SyncNote"), 0, 4)

	-- LFO2

	-- Byte 43
	-- Bit 6,7 - not use
	-- Bit 4,5 - Key Sync [0~2 = OFF, Timbre, Voice]
	vocoderBuffer[sb + 43] = packBitsToByte(vocoderBuffer[sb + 43], getModValue("cbLFO2KeySync"), 4, 5)

	-- Bit 2,3 - not use
	-- Bit 0,1 - Wave [0~3 = Saw, Squ(+), Sin, S/H]
	-- Stored directly in buffer

	-- Byte 44 - Frequency [0~127]
	vocoderBuffer[sb + 44] = getModValue("knobLFO2Frequency")

	-- Byte 45
	-- Bit 7 - Tempo Sync [0, 1 = Off, On]
	vocoderBuffer[sb + 45] = packBitsToByte(vocoderBuffer[sb + 45], getModValue("btnLFO2TempoSync"), 7)

	-- Bit 5,6 - not use
	-- Bit 0~4 - Sync Note [0~14 = 1/1~1/32]
	vocoderBuffer[sb + 45] = packBitsToByte(vocoderBuffer[sb + 45], getModValue("cbLFO2SyncNote"), 0, 4)

	-- CH LEVEL [0]~[15] = CH[1]~[16]

	-- Byte 46~61 - Level [0~15] - 0~127
	for i = 1, 16 do
		vocoderBuffer[sb + 45 + i] = getModValue(string.format("knobSeq1Step%d", i))
	end

	-- CH PAN  [0]~[15] = CH[1]~[16]

	-- Byte 62~77 - Pan  [0~15] - 1~64~127 = L63~CNT~R63
	for i = 1, 16 do
		vocoderBuffer[sb + 61 + i] = getModValue(string.format("knobSeq2Step%d", i)) + 64
	end
end

function prepareForExport()
	
	chosenPresetToBuffer(101, true)

	panelSettings.sendProgOnStartup	= 0
	panelSettings.sendOnProgChange	= 0
	panelSettings.getSetupOnStart	= 1
	panelSettings.continuousPolling	= 1
	panelSettings.autocheckLCDMode	= 0
	panelSettings.disableWarnings	= 0
	panelSettings.clockSource		= 2
	panelSettings.localMode			= 1

	setModValue("btnSendProgramOnStartup", panelSettings.sendProgOnStartup)
	setModValue("btnSendDataOnProgramChange", panelSettings.sendOnProgChange)
	setModValue("btnContinuousPolling", panelSettings.continuousPolling)
	setModValue("btnAutocheckLCDMode", panelSettings.autocheckLCDMode)
	setModValue("btnDisableWarnings", panelSettings.disableWarnings)
	setModValue("cbClockSource", panelSettings.clockSource)
	setModValue("btnSettingsLocalMode", panelSettings.localMode)
end

function placeTimbreDataIntoBuffer(programData, inputStartByte, destBuffer, bufferStartByte)

	local i, c = 0, 0

	for i = inputStartByte, inputStartByte + (TIMBRE_DATA_SIZE * 2) - 1 do

		-- Copy input data into dataBuffer
		if destBuffer == dbSynth then

			dataBuffer[bufferStartByte + c] = programData[i]
		else

			vocoderBuffer[bufferStartByte + c] = programData[i]
		end	

		c = c + 1
	end
end

function setVoiceModeByValue(voiceMode)

	local modList = {
		"cbTimbreVoice", 
		"knobTimbreSplitPoint",
		"btnTimbreTwo",
		"lblTimbreSplitPointValue",
		"cbArpTarget"
	}

	-- Force updating the OSC 1 Control 2
	sharedValues.resetDWGS = true

	if voiceMode == vmVocoder then

		enableControls(modList, false)
		setVocoderMode(true)

		selectTimbreByValue(0, true, true)
		applyVocoderData(vocoderBuffer)

	else

		enableControls(modList, true)
		setVocoderMode(false)
	end

	if voiceMode == vmSingle then

		selectTimbreByValue(0, true, false)
		enableControls(modList, false)

		-- Vocoder or Init => Single
		if (sharedValues.voiceMode ~= vmSplit) and (sharedValues.voiceMode ~= vmDual) then

			applyTimbreData(0, dataBuffer)
		end

	elseif voiceMode == vmSplit then

		enableControls(modList, true)

		-- Vocoder or Init => Split
		if (sharedValues.voiceMode ~= vmSingle) and (sharedValues.voiceMode ~= vmDual) then

			applyTimbreData(0, dataBuffer)
		end

	elseif voiceMode == vmDual then

		enableControls(modList, true)

		-- Vocoder or Init => Split
		if (sharedValues.voiceMode ~= vmSingle) and (sharedValues.voiceMode ~= vmSplit) then

			applyTimbreData(0, dataBuffer)
		end

	end

	sharedValues.voiceMode = voiceMode
end

function setVocoderMode(vocoderEnabled)

	local i
	local knobList = {
		"knobOsc2Semitone",
		"knobOsc2Tune", 
		"knobFilterKbdTrk", 
		"knobAmpPan", 
		"knobFilterVeloSens"
	}

	local modLIst = {
		"btnOsc2OscModCycle",
		"btnOsc2WaveCycle",
		"imgOsc2Lamp0",
		"imgOsc2Lamp1",
		"imgOsc2Lamp2",
		"imgOsc2ModLamp0",
		"imgOsc2ModLamp1",
		"cbPatchDestination1",
		"cbPatchDestination2",
		"cbPatchDestination3",
		"cbPatchDestination4",
		"cbPatchSource2",
		"cbPatchSource3",
		"cbPatchSource4",
		"knobPatch1Amount",
		"knobPatch2Amount",
		"knobPatch3Amount",
		"knobPatch4Amount",
		"knobSeqLastStep",
		"cbSeqKnob1",
		"cbSeqKnob2",
		"cbSeqKnob3",
		"cbSeqMotion1",
		"cbSeqMotion2",
		"cbSeqMotion3",
		"cbSeqType",
		"cbSeqRunMode",
		"cbSeqKeySync",
		"cbSeqResolution",
		"btnSeqOnOff",
		"imgSeqLamp2"
	}

	for i = 1, 16 do
		table.insert(modLIst, string.format("knobSeq3Step%d", i))
	end

	-- Vocoder used to have these fancy "inverted color" labels
	applyVocoderLabels(vocoderEnabled)

	if vocoderEnabled then

		-- Synchronizing values

		if sharedValues.voiceMode ~= vmUndefined then

			syncTimbreWithBuffer(sharedValues.selectedTimbre)
		else

			-- Reset all "synth"-related values to its defaults
			resetVocoderControls(true)
		end

		turnLightsOff("imgOsc2ModLamp", 1)
		turnLightsOff("imgOsc2Lamp", 2)

		sharedValues.timbreMode = tmVocoder

		-- Change bounds
		for i = 1, #knobList do

			getComp(knobList[i]):setPropertyInt("uiSliderMin", 0)
			getComp(knobList[i]):setPropertyInt("uiSliderMax", 127)
			getComp(knobList[i]):setPropertyInt("uiSliderDoubleClickValue", 64)

			getComp(knobList[i]):repaint()
		end

		-- The "Cutoff" knob is invertd here - 0~127 => -63~63
 		specialBounds("knobFilterCutoff", -63, 63, 0)

		assertSeqKnobBoundsByValue(1, 0)
		assertSeqKnobBoundsByValue(2, 1)

		-- Set new formulas
		assertSysExFormulas(2)

		-- Disable some controls
		enableControls(modLIst, false)
	else
		-- Synchronizing values
		if sharedValues.voiceMode == vmVocoder then
			syncVocoderWithBuffer()
		end

		sharedValues.timbreMode = tmSynth

		-- Revert bounds
		for i = 1, #knobList do

			if knobList[i] ~= "knobOsc2Semitone" then

				getComp(knobList[i]):setPropertyInt("uiSliderMin", -63)
				getComp(knobList[i]):setPropertyInt("uiSliderMax", 63)
				getComp(knobList[i]):setPropertyInt("uiSliderDoubleClickValue", 0)
			else

				getComp(knobList[i]):setPropertyInt("uiSliderMin", -24)
				getComp(knobList[i]):setPropertyInt("uiSliderMax", 24)
				getComp(knobList[i]):setPropertyInt("uiSliderDoubleClickValue", 0)
			end

			getComp(knobList[i]):repaint()
		end

		-- The "Cutoff" knob again requires some special treatment
		specialBounds("knobFilterCutoff", 0, 127, 100)

		-- Set usual formulas
		assertSysExFormulas(0)

		-- Enable controls
		enableControls(modLIst, true)
	end
end

function specialBounds(knobName, minValue, maxValue, defaultValue)

	getComp(knobName):setPropertyInt("uiSliderMin", minValue)
	getComp(knobName):setPropertyInt("uiSliderMax", maxValue)
	getComp(knobName):setPropertyInt("uiSliderDoubleClickValue", defaultValue)

	getComp(knobName):repaint()
end

--[[

	VERSION 1.3.3 (23.02.2022)

	[+] Added connected MIDI device information to the Info panel
	[+] Resetting related knob value by double-clicking on the sequencer area
	[*] Virtual Patch labels are now correctly named


	VERSION 1.3.0 (21.08.2021)

	[+] Internal MIDI Device dialog selection window is now accessible from the Settings page
	[+] Version checking on startup. If version differs, then the panel will delete the
		".delete_me_to_reload_resources" file and will suggest to restart the panel

	[*] "Emergency" button now called by double click instead of mouse down event
	[*] "Get file" routines rewritten
	[*] Request LCD mode on startup


	VERSION 1.2.7 (15.08.2021)

	[+] Timbre randomizer

	[F] Arp Swing value interpretation fixed (-100~+100)
	[F] OSC 1 Control 2 now transmits the correct SysEx for DWGS Waveform

	[*] Code cleanup
	[*] Some color schemes tweaking



	VERSION 1.2.3 (08.08.2021)

	[+] Add some extra compatibility for reading dumps (some "Hands-On" MID dump was found and processed)

	[*] Further CC => SysEx controls transition. Helps to avoid problems with Dual / Split voice modes
		value interference,	when both layers are set to the same non-global midi-channel
		Maybe it is a bad decision as sysex narrows down the automation capabilities (MS2K can barely more than 1 automation at a time)
		Time (or feedback) will tell

	[*] Looks like microKORG SysEx dumps are compatible too, quick test with no issues



	VERSION 1.2 (04.08.2021)

	[+] Program Play mode values are processing now. Maybe will be redone in the future
	[+] New "Initialize program bank" option

	[F] If save to disk operations cancelled, no unnecessary actions will be executed 
	[F] Osc2 Semitone bounds fixed for synth <=> vocoder transitions

	[*] "Rename program" dialog will not allow to input more than 12 characters now
	[*] Further code cleanup, some methods were united during this process
	[*] Minor bugfixes



	VERSION 1.1 (02.08.2021)

	[+] Color scheme change implemented
	[+] "Request data on program change" button added.It will request current program from MS2000
		right after receiving the "program change" message from the synthesizer

	[F] No more random synthesizer config rewriting on startup
	[F] Fixed annoying behaviour of the Settings button on startup. Still have no 100% sure that it will always work

	[-] "Request synthesizer settings on startup" button was removed from settings.
		This operation will run by default

	[*] Ctrlr panel menu is hidden for restricted instances now.
		It still accessible with "emergency" [+] button on the settings page
	[*] Rearranged settings page
	[*] More typos fixed
	[*] Timers code rewritten
	[*] Redone timbre selection operations a bit
	[*] Code cleanup, data flow corrected to avoid excessive data sending and looping



	VERSION 1.0 Release (31.07.2021)

	[+] Now it is possible to control preset and bank selection on the hardware ("HARDWARE" selector)
	[+] Quick select program on the synthesizer by right clicking the "HARDWARE" selector
	[+] Change sequencer values by dragging mouse on the graphic
	[+] "Request settings from synthesizer" button in the panel settings menu

	[F] Vocoder => Synth (and vice versa) transition when selecting a preset now works correctly

	[*] Panel settings now stored in an external file ("[APPDATA]/ReMS2000/config.json"), so any instance of this panel will use them
	[*] Altered timbre assign behaviour - "Detune" knob is only available when "Unison" timbre mode is selected
	[*] Using midi channel data when parsing and sending the "program change" messages
	[*] Some global => local vars improper usage eliminated
	[*] Slight UI Tweaking



	VERSION 1.0 beta 3 (30.07.2021)

	[+] *.prg format for single program is now supported
	[+] New Copy / Paste function for Timbre / Sequence data implemented

	[F] Fixed some byte adress dispositions in the buffers (OSC1 Waveform, Filter, LFO1, LFO2)
	[F] Fixed wrong preset naming after state recovery
	[F] Sync buffers before saving state
	[F] Fixed turning on the SEQ1 lamp on startup



	VERSION 1.0 beta 2 (28.07.2021)

	[+] VOCODER mode is now supported
	[+] Option for requesting synth setup on startup

	[F] Fixed some value / boundaries issues

	[*] Virtual patch rewritten for using sysex instead of MultiMessages
	[*] Bunch of rewritten code (oooh, that vocoder...)
	[*] New LCD font for better match
	[*] Slightly rearranged GUI
	[*] Fixed some typos in the comments
	[*] Bugfixes



	VERSION 1.0 beta 1 (25.07.2021)
	
	- Initial release
--]]

function initPatchRawData()
	
	-- Raw patch data which should be converted to make it usable
	-- Mostly for testing and reference purposes

	-- INIT Patch
	return {
	-- SysEx Header
	0xF0, 0x42, 0x30, 0x58, 0x40, 
 	-- Program data begin
	--MS    B1    B2    B3    B4    B5    B6    B7   
	0x00, 0x49, 0x4E, 0x49, 0x54, 0x20, 0x50, 0x72, 
	0x00, 0x6F, 0x67, 0x72, 0x61, 0x6D, 0x00, 0x0B, 
	0x00, 0x00, 0x00, 0x40, 0x00, 0x3C, 0x00, 0x28, 
	0x00, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x14, 0x40, 
	0x00, 0x0F, 0x40, 0x00, 0x78, 0x00, 0x00, 0x50, 
	0x08, 0x01, 0x00, 0x00, 0x7F, 0x70, 0x0A, 0x40, 
	0x00, 0x42, 0x40, 0x45, 0x00, 0x00, 0x00, 0x00,  
	0x00, 0x00, 0x00, 0x40, 0x40, 0x00, 0x7F, 0x00, 
	0x00, 0x00, 0x01, 0x7F, 0x0A, 0x40, 0x40, 0x40, 
	0x00, 0x7F, 0x40, 0x00, 0x40, 0x40, 0x00, 0x40, 
	0x00, 0x7F, 0x00, 0x00, 0x40, 0x7F, 0x00, 0x02, 
	0x00, 0x0A, 0x03, 0x02, 0x46, 0x0C, 0x02, 0x40, 
	0x00, 0x03, 0x40, 0x42, 0x40, 0x43, 0x40, 0x43, 
	0x01, 0x71, 0x01, 0x01, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x01, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x00, 0x01, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x7F, 
	0x00, 0x70, 0x0A, 0x40, 0x42, 0x40, 0x45, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x40, 
	0x00, 0x00, 0x7F, 0x00, 0x00, 0x01, 0x7F, 0x0A, 
	0x00, 0x40, 0x40, 0x40, 0x7F, 0x40, 0x00, 0x40, 
	0x00, 0x40, 0x00, 0x40, 0x7F, 0x00, 0x00, 0x40, 
	0x00, 0x7F, 0x00, 0x02, 0x0A, 0x03, 0x02, 0x46, 
	0x00, 0x0C, 0x02, 0x40, 0x03, 0x40, 0x42, 0x40, 
	0x08, 0x43, 0x40, 0x43, 0x71, 0x01, 0x01, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x00, 0x01, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x01, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x00, 0x40, 0x40, 
	-- Program data end
	0xF7
	}
end

function initPatchData()
	
	-- This data is good to work with, but it should
	-- be converted before sending to the synth

	-- INIT Patch
	return {
	-- SysEx Header
	0xF0, 0x42, 0x30, 0x58, 0x40,
	-- Program data begin
	--B1    B2    B3    B4    B5    B6    B7 
	0x49, 0x4E, 0x49, 0x54, 0x20, 0x50, 0x72,
	0x6F, 0x67, 0x72, 0x61, 0x6D, 0x00, 0x00,
	0x00, 0x00, 0x40, 0x00, 0x3C, 0x05, 0x28,
	0x00, 0x00, 0x14, 0x00, 0x00, 0x14, 0x40,
	0x0F, 0x40, 0x00, 0x78, 0x00, 0x00, 0x50,
	0x01, 0x00, 0x00, 0xFF, 0x70, 0x0A, 0x40,
	0x42, 0x40, 0x45, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x40, 0x40, 0x00, 0x7F, 0x00,
	0x00, 0x01, 0x7F, 0x14, 0x40, 0x40, 0x40,
	0x7F, 0x40, 0x00, 0x40, 0x40, 0x00, 0x40,
	0x7F, 0x00, 0x00, 0x40, 0x7F, 0x00, 0x02,
	0x0A, 0x03, 0x02, 0x46, 0x0C, 0x02, 0x40,
	0x03, 0x40, 0x42, 0x40, 0x43, 0x40, 0x43,
	0xF1, 0x01, 0x01, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x01,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x00, 0x01, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0xFF,
	0x70, 0x0A, 0x40, 0x42, 0x40, 0x45, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x40,
	0x00, 0x7F, 0x00, 0x00, 0x01, 0x7F, 0x14,
	0x40, 0x40, 0x40, 0x7F, 0x40, 0x00, 0x40,
	0x40, 0x00, 0x40, 0x7F, 0x00, 0x00, 0x40,
	0x7F, 0x00, 0x02, 0x0A, 0x03, 0x02, 0x46,
	0x0C, 0x02, 0x40, 0x03, 0x40, 0x42, 0x40,
	0x43, 0x40, 0x43, 0xF1, 0x01, 0x01, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x00, 0x01, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x01,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 
	-- Program data end
	0xF7
	}
end

function initPresetBank()
	
	local progBankStorage = {}
	local progBank = {}
	local i, j

	for i = 1, 8 do

		progBank = {}
		for j = 1, 16 do

			table.insert(progBank, initPatchData())
		end

		table.insert(progBankStorage, progBank)
	end

	return progBankStorage
end

function initVocoderBuffer()

	-- Vocoder buffer init data
	return {
	0xFF, 0x70, 0x0A, 0x40, 0x42, 0x40, 0x45, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x7F, 0x00, 0x00, 0x00, 0x64, 0x00, 
	0x00, 0x40, 0x14, 0x02, 0x40, 0x1E, 0x7F, 
	0x00, 0x00, 0x40, 0x40, 0x00, 0x40, 0x7F, 
	0x00, 0x00, 0x40, 0x7F, 0x00, 0x02, 0x0A, 
	0x03, 0x02, 0x46, 0x0C, 0x7F, 0x7F, 0x7F, 
	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 
	0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x40, 
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 
	0x40, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 
	0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x00, 
	0x00, 0x00, 0x00, 0x40, 0x00, 0x3C, 0x05, 
	0x28, 0x00, 0x00, 0x14, 0x00, 0x00, 0x14, 
	0x40, 0x0F, 0x40, 0x00, 0x78, 0x00, 0x00, 
	0x50, 0x01, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	}
end

function initSynthBuffer()
	
	-- Synth buffer init data
	return {
	0xFF, 0x70, 0x0A, 0x40, 0x42, 0x40, 0x45,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40,
	0x40, 0x00, 0x7F, 0x00, 0x00, 0x01, 0x7F,
	0x14, 0x40, 0x40, 0x40, 0x7F, 0x40, 0x00,
	0x40, 0x40, 0x00, 0x40, 0x7F, 0x00, 0x00,
	0x40, 0x7F, 0x00, 0x02, 0x0A, 0x03, 0x02,
	0x46, 0x0C, 0x02, 0x40, 0x03, 0x40, 0x42,
	0x40, 0x43, 0x40, 0x43, 0xF1, 0x01, 0x01,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x00, 0x01, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x00,
	0x01, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0xFF, 0x70, 0x0A, 0x40,
	0x42, 0x40, 0x45, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x40, 0x40, 0x00, 0x7F, 0x00,
	0x00, 0x01, 0x7F, 0x14, 0x40, 0x40, 0x40,
	0x7F, 0x40, 0x00, 0x40, 0x40, 0x00, 0x40,
	0x7F, 0x00, 0x00, 0x40, 0x7F, 0x00, 0x02,
	0x0A, 0x03, 0x02, 0x46, 0x0C, 0x02, 0x40,
	0x03, 0x40, 0x42, 0x40, 0x43, 0x40, 0x43,
	0xF1, 0x01, 0x01, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x00, 0x01,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x00, 0x01, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40,
	0x40, 0x40, 0x40, 0x40, 0x40, 0x40
	}
end

function resetVocoderControls()

	local i

	for i = 1, 16 do
		modByName(string.format("knobSeq3Step%d", i)):setValue(0, false)
	end

	setModValue("knobSeqLastStep", 16)
	setModValue("cbSeqKnob1", 0)
	setModValue("cbSeqKnob2", 0)
	setModValue("cbSeqKnob3", 0)
	setModValue("cbSeqMotion1", 1)
	setModValue("cbSeqMotion1", 1)
	setModValue("cbSeqMotion1", 1)
	setModValue("cbSeqType", 0)
	setModValue("cbSeqRunMode", 1)
	setModValue("cbSeqKeySync", 1)
	setModValue("cbSeqResolution", 3)
	setModValue("btnSeqOnOff", 0)
	setModValue("cbArpTarget", 2)
	setModValue("cbPatchDestination1", 0)
	setModValue("cbPatchDestination2", 0)
	setModValue("cbPatchDestination3", 4)
	setModValue("cbPatchDestination4", 4)
	setModValue("cbPatchSource2", 3)
	setModValue("cbPatchSource2", 2)
	setModValue("cbPatchSource2", 3)
	setModValue("knobPatch2Amount", 0)
	setModValue("knobPatch3Amount", 0)
	setModValue("knobPatch4Amount", 0)
	setModValue("knobFilterEG1Int", 0)
end

function randomizeProgramData()

	-- Program randomization

	if not confirmDialog("Warning!", "This will erase current timbre in the panel buffer. Proceed?") then
		return
	end

	-- Set random seed (thanks to Poseemo for this advice)
	math.randomseed(Time.getMillisecondCounterHiRes())

	local i, j
	local ctrlName

	-- Voice values are skipped

	-- Combos
	setModValueCheck("cbTimbreAssign", rndValueMan(0, 2))
	setModValueCheck("cbTimbreTrigger", rndValueMan(0, 1))
	setModValueCheck("cbDelayType", rndValueMan(0, 2))
	setModValueCheck("cbModType", rndValueMan(0, 2))
	setModValueCheck("cbLFO1KeySync", rndValueMan(0, 2))
	setModValueCheck("cbLFO2KeySync", rndValueMan(0, 2))
	setModValueCheck("cbLFO1SyncNote", rndValueMan(0, 14))
	setModValueCheck("cbLFO2SyncNote", rndValueMan(0, 14))
	setModValueCheck("cbPatchSource1", rndValueMan(0, 7))
	setModValueCheck("cbPatchSource2", rndValueMan(0, 7))
	setModValueCheck("cbPatchSource3", rndValueMan(0, 7))
	setModValueCheck("cbPatchSource4", rndValueMan(0, 7))
	setModValueCheck("cbPatchDestination1", rndValueMan(0, 7))
	setModValueCheck("cbPatchDestination2", rndValueMan(0, 7))
	setModValueCheck("cbPatchDestination3", rndValueMan(0, 7))
	setModValueCheck("cbPatchDestination4", rndValueMan(0, 7))
	setModValueCheck("cbPatchDestination4", rndValueMan(0, 7))
	setModValueCheck("cbSeqType", rndValueMan(0, 3))
	setModValueCheck("cbSeqRunMode", rndValueMan(0, 1))
	setModValueCheck("cbSeqKeySync", rndValueMan(0, 2))
	setModValueCheck("cbSeqResolution", rndValueMan(0, 15))
	setModValueCheck("cbSeqKnob1", rndValueMan(0, 30))
	setModValueCheck("cbSeqKnob2", rndValueMan(0, 30))
	setModValueCheck("cbSeqKnob3", rndValueMan(0, 30))
	setModValueCheck("cbSeqMotion1", rndValueMan(0, 1))
	setModValueCheck("cbSeqMotion2", rndValueMan(0, 1))
	setModValueCheck("cbSeqMotion3", rndValueMan(0, 1))
	setModValueCheck("cbArpResolution", rndValueMan(0, 5))
	setModValueCheck("cbArpRange", rndValueMan(0, 3))
	setModValueCheck("cbArpType", rndValueMan(0, 5))

	-- Virtual controls
	setOsc1WaveformByValue(rndValueMan(0, 6), true)
	setLFO1TypeByValue(rndValueMan(0, 3), true)
	setLFO2TypeByValue(rndValueMan(0, 3), true)

	if sharedValues.timbreMode == tmSynth then

		setOsc2WaveformByValue(rndValueMan(0, 2), true)
		processOscModData(rndValueMan(0, 3), true)

		-- Change Cutoff max value for HP Filter to avoid barely heard sound
		j = rndValueMan(0, 3)
		setFilterTypeByValue(j, true)
	else

		j = 0
		setFilterTypeByValue(rndValueMan(0, 4), true)
	end

	-- Buttons
	setModValueCheck("btnEG1Reset", rndValueMan(0, 1))
	setModValueCheck("btnEG2Reset", rndValueMan(0, 1))
	setModValueCheck("btnAmpEG2Gate", rndValueMan(0, 1))
	setModValueCheck("btnAmpDistortion", rndValueMan(0, 1))
	setModValueCheck("btnLFO1TempoSync", rndValueMan(0, 1))
	setModValueCheck("btnLFO2TempoSync", rndValueMan(0, 1))
	setModValueCheck("btnSeqOnOff", rndValueMan(0, 1))
	setModValueCheck("btnDelayTempoSync", rndValueMan(0, 1))
	setModValueCheck("btnArpOnOff", rndValueMan(0, 1))
	setModValueCheck("btnArpLatch", rndValueMan(0, 1))
	setModValueCheck("btnArpKeySync", rndValueMan(0, 1))

	-- Knobs
	setModValueCheck("knobOsc1Control1", rndValue("knobOsc1Control1"))
	setModValueCheck("knobOsc1Control2", rndValue("knobOsc1Control2"))
	setModValueCheck("knobOsc2Semitone", rndValue("knobOsc2Semitone"))
	setModValueCheck("knobOsc2Tune", rndValue("knobOsc2Tune"))
	setModValueCheck("knobMixerNoise", rndValue("knobMixerNoise") * 0.5)
	setModValueCheck("knobMixerOsc2", rndValueMan(45, 127))
	setModValueCheck("knobMixerOsc1", rndValueMan(45, 127))

	if (sharedValues.timbreMode == tmSynth) and (j == 3) then
		setModValueCheck("knobFilterCutoff", rndValueMan(0, 40))
	else
		setModValueCheck("knobFilterCutoff", rndValueMan(30, 127))
	end

	setModValueCheck("knobFilterResonance", rndValue("knobFilterResonance") * 0.3)
	setModValueCheck("knobFilterEG1Int", rndValue("knobFilterEG1Int") * 0.4)
	setModValueCheck("knobFilterKbdTrk", rndValue("knobFilterKbdTrk"))
	setModValueCheck("knobFilterVeloSens", rndValue("knobFilterVeloSens"))
	setModValueCheck("knobTimbreTranspose", rndValue("knobTimbreTranspose") * 0.2)
	setModValueCheck("knobTimbreTune", rndValue("knobTimbreTune"))
	setModValueCheck("knobTimbreBendRange", rndValue("knobTimbreBendRange"))
	setModValueCheck("knobTimbreVibrato", rndValue("knobTimbreVibrato"))
	setModValueCheck("knobTimbreDetune", rndValue("knobTimbreDetune"))
	setModValueCheck("knobTimbrePorta", rndValue("knobTimbrePorta"))
	setModValueCheck("knobAmpLevel", rndValueMan(110, 127))
	setModValueCheck("knobAmpPan", rndValue("knobAmpPan") * 0.4)
	setModValueCheck("knobAmpKeyTrack", rndValue("knobAmpKeyTrack"))
	setModValueCheck("knobAmpVeloSens", rndValue("knobAmpVeloSens"))
	setModValueCheck("knobDelayTime", rndValue("knobDelayTime"))
	setModValueCheck("knobDelayFeedback", rndValue("knobDelayFeedback"))
	setModValueCheck("knobDelayDepth", rndValue("knobDelayDepth"))
	setModValueCheck("knobDelaySpeed", rndValue("knobDelaySpeed"))
	setModValueCheck("knobEQLowFreq", rndValue("knobEQLowFreq"))
	setModValueCheck("knobEQLowGain", rndValueMan(-4, 12))
	setModValueCheck("knobEQHighFreq", rndValue("knobEQHighFreq"))
	setModValueCheck("knobEQHighGain", rndValueMan(-4, 12))
	setModValueCheck("knobLFO1Frequency", rndValue("knobLFO1Frequency"))
	setModValueCheck("knobLFO2Frequency", rndValue("knobLFO2Frequency"))
	setModValueCheck("knobSeqLastStep", rndValue("knobSeqLastStep"))
	setModValueCheck("knobEG1Attack", rndValue("knobEG1Attack") * 0.3)
	setModValueCheck("knobEG2Attack", rndValue("knobEG2Attack") * 0.3)
	setModValueCheck("knobEG1Decay", rndValue("knobEG1Decay"))
	setModValueCheck("knobEG2Decay", rndValue("knobEG2Decay"))
	setModValueCheck("knobEG1Sustain", rndValue("knobEG1Sustain"))
	setModValueCheck("knobEG2Sustain", rndValue("knobEG2Sustain"))
	setModValueCheck("knobEG1Release", rndValue("knobEG1Release"))
	setModValueCheck("knobEG2Release", rndValue("knobEG2Release"))
	setModValueCheck("knobPatch1Amount", rndValue("knobPatch1Amount") * 0.5)
	setModValueCheck("knobPatch2Amount", rndValue("knobPatch2Amount") * 0.5)
	setModValueCheck("knobPatch3Amount", rndValue("knobPatch3Amount") * 0.5)
	setModValueCheck("knobPatch4Amount", rndValue("knobPatch4Amount") * 0.5)
	setModValueCheck("knobArpGate", rndValueMan(33, 127))
	setModValueCheck("knobArpSwing", rndValue("knobArpSwing") * 0.8)

	-- Sequence steps
	for i = 1, 3 do
		for j = 1, 16 do

			ctrlName = string.format("knobSeq%dStep%d", i, j)
			setModValueCheck(ctrlName, rndValue(ctrlName))
		end
	end
end

function getPresetNameByID(bankNumber, presetNumber)
	
	local i
	local bytesSkip = DATA_PREAMBLE_BYTES + 1
	local pName = ""

	for i = bytesSkip, bytesSkip + 11 do
		pName = pName .. string.char(presetBank[bankNumber][presetNumber][i])
	end

	return pName
end

function getPresetNameFromBuffer()
	
	local i
	local bytesSkip = DATA_PREAMBLE_BYTES + 1
	local pName = ""

	for i = bytesSkip, bytesSkip + 11 do
		pName = pName .. string.char(dataBuffer[i])
	end

	return pName
end

function displayProgramName(programName, bank, preset)
	
	local prefix

	if (bank == nil) or (preset == nil) then
		sharedValues.saveToRamEnabled = 0
		prefix = "Buf:"
	else
		sharedValues.saveToRamEnabled = 1
		prefix = string.format("%s%.2d:", bankIDToName(bank), preset)
	end

	getComp("lblScreenStrOne"):setText(prefix .. programName)
end

function chosenPresetToBuffer(rawNumber, muteOutput)

	local rawN = rawNumber

	-- Save preset routines use bigger IDs
	if rawN > 1000 then
		rawN = rawN - 1000
	end

	-- Select timbre one
	selectTimbreByValue(0, false, true)

	local bank = math.floor(rawN / 100)
	local preset = rawN - (bank * 100)

	dataBuffer = copyTable(presetBank[bank][preset])

	sharedValues.selectedBank = bank
	sharedValues.selectedPreset = preset

	applyProgramData(dataBuffer, bank, preset, muteOutput)
end

function initBufferWithInitPatch()

	dataBuffer = initPatchData()
	applyProgramData(dataBuffer, nil, nil, false)
end

function cyclePresets(mod, value, source)

	if blockExecution(source) then
		return
	end

	local cycleDirection = getModPropN(mod, "modulatorCustomIndex")

	-- Choose, where selection must happen
	if panelSettings.selectorsSource == pbsPanel then

		if cycleDirection == 1 then

			sharedValues.selectedPreset = sharedValues.selectedPreset + 1

			if sharedValues.selectedPreset > 16 then

				cycleBankValues(true, pbsPanel)
				sharedValues.selectedPreset = 1
			end
 		else

			sharedValues.selectedPreset = sharedValues.selectedPreset - 1

			if sharedValues.selectedPreset < 1 then

				cycleBankValues(false, pbsPanel)
				sharedValues.selectedPreset = 16
			end
		end

		chosenPresetToBuffer((sharedValues.selectedBank * 100) + sharedValues.selectedPreset, false)

	else

		if cycleDirection == 1 then

			sharedValues.synthPreset = sharedValues.synthPreset + 1

			if sharedValues.synthPreset > 15 then

				cycleBankValues(true, pbsSynth)
				sharedValues.synthPreset = 0
			end
 		else

			sharedValues.synthPreset = sharedValues.synthPreset - 1

			if sharedValues.synthPreset < 0 then

				cycleBankValues(false, pbsSynth)
				sharedValues.synthPreset = 15
			end
		end

		-- Send calculated preset number to MS2000
		selectPresetOnSynth()
	end
end

function cycleBanks(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	local cycleDirection = getModPropN(mod, "modulatorCustomIndex")

	-- Choose, where selection must happen
	if panelSettings.selectorsSource == pbsPanel then

		if cycleDirection == 1 then
			cycleBankValues(true, pbsPanel)
		else
			cycleBankValues(false, pbsPanel)
		end

		chosenPresetToBuffer((sharedValues.selectedBank * 100) + sharedValues.selectedPreset, false)
	else

		if cycleDirection == 1 then
			cycleBankValues(true, pbsSynth)
		else
			cycleBankValues(false, pbsSynth)
		end

		selectPresetOnSynth()
	end
end

function cycleBankValues(increase, selectionDest)

	if selectionDest == pbsPanel then

		if increase then
			sharedValues.selectedBank = sharedValues.selectedBank + 1

			if sharedValues.selectedBank > 8 then
				sharedValues.selectedBank = 1
			end
		else

			sharedValues.selectedBank = sharedValues.selectedBank - 1

			if sharedValues.selectedBank < 1 then
				sharedValues.selectedBank = 8
			end
		end
	else

		if increase then
			sharedValues.synthBank = sharedValues.synthBank + 1

			if sharedValues.synthBank > 7 then
				sharedValues.synthBank = 0
			end
		else

			sharedValues.synthBank = sharedValues.synthBank - 1

			if sharedValues.synthBank < 0 then
				sharedValues.synthBank = 7
			end
		end
	end
end

function renameProgram()
	
	-- Construct dialog window
	local modalWindow = AlertWindow("Info", "Input new program name:", AlertWindow.InfoIcon)

	modalWindow:addButton("OK", 1, KeyPress(KeyPress.returnKey), KeyPress())
	modalWindow:addButton("Cancel", 0, KeyPress(KeyPress.escapeKey), KeyPress())
	modalWindow:addTextEditor("ProgName", getPresetNameByID(sharedValues.selectedBank, sharedValues.selectedPreset), "12 characters max", false)

	modalWindow:getTextEditor("ProgName"):setInputRestrictions(12, "")
	modalWindow:setModalHandler(applyNewProgramName)

	modalWindow:runModalLoop()
end

function applyNewProgramName(result, window)
	
	window:setVisible (false)

	if result == 1 and window:getTextEditor("ProgName") ~= nil then

		local i
		local bank, preset = sharedValues.selectedBank, sharedValues.selectedPreset
		local bytesSkip = DATA_PREAMBLE_BYTES + 1
		local bs = bytesSkip - 1
		local cByte
		local newName = window:getTextEditor("ProgName"):getText()

		for i = bytesSkip, bytesSkip + 11 do

			cByte = string.byte(string.sub(newName, i - bs, i - bs))

			if cByte ~= nil then

				presetBank[bank][preset][i] = cByte

				-- Make sure current buffer will contain the same name
				dataBuffer[i] = cByte
			else

				presetBank[bank][preset][i] = string.byte(" ")
				dataBuffer[i] = string.byte(" ")
			end
		end

		displayProgramName(getPresetNameByID(bank, preset), bank, preset)
	end
end

function openSingleProgramFile()
	
	-- File open dialog
	local bulkDump = openFileDialog("Select Korg MS2000 / microKORG program file", SUPPORTED_EXT_MASK_ALT)
	local dumpBytes = MemoryBlock()

	-- If file exists, then proceed
	if bulkDump ~= nil then
		dumpBytes = MemoryBlock(bulkDump:getSize())
		bulkDump:loadFileAsData(dumpBytes)
	else
		return
	end

	local rawDumpBytesData = normalizeSysExDumpData(memBlockToTable(dumpBytes))

	-- If it's a microKORG file, then it's required to cut two extra bytes
	if #rawDumpBytesData == MKSINGLE_PROGRAM_SIZE then

		-- Check microKORG *.prg signature
		if (rawDumpBytesData[2] == 0x82) and (rawDumpBytesData[3] == 0x28) then

			rawDumpBytesData = cutBytesFromDump(rawDumpBytesData, 2, 2)
		end
	end

	if (#rawDumpBytesData ~= SINGLE_PROGRAM_SIZE) then
		genAlertWindow("Warning", "Wrong file size, operation cancelled")
	else
		
		dataBuffer = midiToProgramData(rawDumpBytesData, DATA_PREAMBLE_BYTES)
		applyProgramData(dataBuffer, nil, nil, false)
		-- Congratulations! MS2000 program successfully imported!
	end
end

function openProgramBankFile()

	-- File open dialog
	local bulkDump = openFileDialog("Select Korg MS2000 bulk dump file", SUPPORTED_EXT_MASK)
	local dumpBytes = MemoryBlock()

	-- If file exists, then proceed
	if bulkDump ~= nil then
		dumpBytes = MemoryBlock(bulkDump:getSize())
		bulkDump:loadFileAsData(dumpBytes)
	else
		return
	end

	local rawDumpBytesData = normalizeSysExDumpData(memBlockToTable(dumpBytes))
	local dumpType = checkBulkDumpSize(#rawDumpBytesData)

	if dumpType ~= dtInvalidSz then

		if dumpType == dtHandson then

			-- Check microKORG *.prg signature
			if (rawDumpBytesData[3] == 0xA4) and (rawDumpBytesData[4] == 0x0F) then

				rawDumpBytesData = cutBytesFromDump(rawDumpBytesData, 2, 3)
			end
		end

		presetBank = slicePresets(midiToProgramData(rawDumpBytesData, DATA_PREAMBLE_BYTES))

		dataBuffer = copyTable(presetBank[1][1])

		chosenPresetToBuffer(101, false) -- 1 - bank, 01 - preset number
		-- Congratulations! MS2000 bulk dump successfully imported!
	else

		genAlertWindow("Warning", "Wrong file size, operation cancelled")
	end
end

function saveSingleProgramFile()
	
	-- Default filename will be like current preset name
	local cPresName = getPresetNameFromBuffer()

	-- File to save
	local dumpFile = utils.saveFileWindow("Save current program to file..", File(removeSystemSymbols(cPresName)), "*.syx", true)

	if not dumpFile:isValid() then
		return
	end

	local programData

	-- Sync data before saving
	syncPanelWithBuffer()

	-- Merge vocoder data if necessary
	if sharedValues.timbreMode == tmSynth then
		programData = copyTable(dataBuffer)
	else
		programData = getMergedTimbreVocoderData()
	end

	-- Writing data to the file
	dumpFile:replaceWithData(MemoryBlock(programToMIDIData(programData, DATA_PREAMBLE_BYTES)))
end

function saveProgramBankFile()
	
	-- Default filename will be like current preset name
	local cPresName = "ReMS2000 Bulk Dump " .. os.date("%Y %m %d")

	-- File to save
	local dumpFile = utils.saveFileWindow("Save program bank to file..", File(removeSystemSymbols(cPresName)), "*.syx", true)

	if not dumpFile:isValid() then
		return
	end

	-- Writing data to the file
	dumpFile:replaceWithData(MemoryBlock(prepareBulkDump()))
end

function saveProgramToPatchBank(rawNumber)
	
	local bank = math.floor((rawNumber - 1000) / 100)
	local preset = rawNumber % 100
	local patchData

	syncPanelWithBuffer()

	-- Buffer ==> presetBank[bank][preset]

	-- If timbre type is vocoder, we have to merge data first
	if sharedValues.timbreMode == tmSynth then
		presetBank[bank][preset] = copyTable(dataBuffer)
	else
		presetBank[bank][preset] = getMergedTimbreVocoderData()
	end

	-- Run assertions by opening saved program from bank
	chosenPresetToBuffer(rawNumber, true)
end

function selectPresetOnSynth()

	checkProgramModeEnabled()
	sendSysExMessage({0xC0 + getGlobalMidiChannel(true), (sharedValues.synthPreset) + (sharedValues.synthBank * 16)})

	if	(panelSettings.reqProgOnChange == 1) then
		-- Data here must be delayed, because it takes a while for the synthesizer to process program change
		delayedProgramRequest()
	end

	getComp("uiSynthSideSelector"):repaint()
end

function slicePresets(bulkDump)
	
	local i, j, c
	local startByte, cProg = 0, -1

	local bankData = {}
	local progBank = {}
	local currPatch = {}

	-- Ignore global data, maybe in the future...

	for i = 1, 8 do
		progBank = {}

		for j = 1, 16 do

			currPatch = {0xF0, 0x42, 0x30, 0x58, 0x40}

			cProg = cProg + 1
			startByte = DATA_PREAMBLE_BYTES + (cProg * SINGLE_PROGRAM_INT_SIZE) + 1

			for c = 0, SINGLE_PROGRAM_INT_SIZE - 1 do

				table.insert(currPatch, bulkDump[startByte + c])
			end

			table.insert(currPatch, 0xF7)
			table.insert(progBank, currPatch)
		end

		table.insert(bankData, progBank)
	end

	return bankData
end

function sendBufferedProgram(mod, value, source)

	if blockExecution(source) then
		return
	end

	local programToSend

	syncPanelWithBuffer()

	-- If timbre type is vocoder, we have to merge data first
	if sharedValues.timbreMode == tmSynth then
		programToSend = copyTable(dataBuffer)
	else
		programToSend = getMergedTimbreVocoderData()
	end

	-- Replace MIDI channel in the existing data
	programToSend[3] = getGlobalMidiChannel()

	sendSysExMessage(programToMIDIData(programToSend, DATA_PREAMBLE_BYTES))
end

function sendBufferedProgramNosync()

	local programToSend

	-- If timbre type is vocoder, we have to merge data first
	if sharedValues.timbreMode == tmSynth then
		programToSend = copyTable(dataBuffer)
	else
		programToSend = getMergedTimbreVocoderData()
	end

	-- Replace MIDI channel in the existing data
	programToSend[3] = getGlobalMidiChannel()

	sendSysExMessage(programToMIDIData(programToSend, DATA_PREAMBLE_BYTES))
end

function storeProgramBank()
	
	sendSysExMessage(prepareBulkDump())
	waitForWriteReply(WAIT_BANK_TIMER)
end

function prepareBulkDump()
	
	local i, j, c
	local midiCh = getGlobalMidiChannel()
	local bulkDump = {0xF0, 0x42, midiCh, 0x58, 0x4C}

	-- Cut extra bytes (SysEx Header, SysEx End) from every program
	for i = 1, 8 do
		for j = 1, 16 do

			for c = (DATA_PREAMBLE_BYTES + 1), #presetBank[i][j] - 1 do
				table.insert(bulkDump, presetBank[i][j][c])
			end
		end
	end

	table.insert(bulkDump, 0xF7)

	return programToMIDIData(bulkDump, DATA_PREAMBLE_BYTES)
end

function mergePanelSynthSettings(mod, value, source)

	if blockExecution(source) then
		return
	end

	-- Request, replace required bits, send back

	-- I have no intension to manage all global settings via this panel,
	-- but only the "Clock mode" and "Local mode" settings

	sharedValues.applySettingsOnCatch = true
	requestSynthSettings()
end

function getMergedTimbreVocoderData()
	
	-- Merge dataBuffer with vocoder data

	local i
	local mergedData = copyTable(dataBuffer)

	for i = TIMBRE_ONE_STARTBYTE, TIMBRE_ONE_STARTBYTE + (TIMBRE_DATA_SIZE * 2) - 1 do

		mergedData[i] = vocoderBuffer[i - TIMBRE_ONE_STARTBYTE + 1]
	end

	return mergedData
end

function checkBulkDumpSize(dumpSize)
	
	-- Check if opened data size is correct
	-- Return type of dump, if size is correct

	local result = dtInvalidSz

	if dumpSize == PROGRAM_BANK_DUMP_SIZE then
		result = dtProgBank
	elseif dumpSize == ALL_DATA_DUMP_SIZE then
		result = dtAllData
	elseif dumpSize == HANDSON_DUMP_SIZE then
		result = dtHandson
	end

	return result
end

function cutBytesFromDump(sourceTable, bFrom, bCount)

	local i
	local result = {}

	for i = 1, #sourceTable do

		if (i < bFrom) or (i >= (bFrom + bCount)) then

			table.insert(result, sourceTable[i])
		end
	end

	return result
end

function setVoiceModeReactions(mod, value, source)

	if blockExecution(source) then
		return
	end

	if sharedValues.voiceMode ~= value then

		setVoiceModeByValue(value)
	end
end

function setLFO1TempoSyncReactions(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	if value == 1 then
		enableControls({"knobLFO1Frequency"}, false)
		enableControls({"cbLFO1SyncNote"}, true)
	else
		enableControls({"knobLFO1Frequency"}, true)
		enableControls({"cbLFO1SyncNote"}, false)
	end
end

function setLFO2TempoSyncReactions(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	if value == 1 then
		enableControls({"knobLFO2Frequency"}, false)
		enableControls({"cbLFO2SyncNote"}, true)
	else
		enableControls({"knobLFO2Frequency"}, true)
		enableControls({"cbLFO2SyncNote"}, false)
	end
end

function setDelayTempoSyncReactions(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	if value == 1 then
		enableControls({"knobDelayTime"}, false)
		enableControls({"cbDelaySyncNote"}, true)
	else
		enableControls({"knobDelayTime"}, true)
		enableControls({"cbDelaySyncNote"}, false)
	end
end

function setTimbreAssignReactions(mod, value, source)
	
	if blockExecution(source) then
		return
	end

	if value == 0 then

		-- Mono
		enableControls({"cbTimbreTrigger"}, true)
		enableControls({"knobTimbreDetune"}, false)
	elseif value == 2 then

		-- Unison
		enableControls({"cbTimbreTrigger", "knobTimbreDetune"}, true)
	else

		-- Poly
		enableControls({"cbTimbreTrigger", "knobTimbreDetune"}, false)
	end
end

function setDWGSWaveform(dwgsSet)

	-- OSC 1 Control 2 requires special treatment because it's using
	-- different sysex for DWGS waveform... Two layer depencies here

	if dwgsSet then

		specialBounds("knobOsc1Control2", 0x00, 0x3F, 0x1F)

		if sharedValues.timbreMode == tmSynth then
			if sharedValues.selectedTimbre == 0 then
				setSEFormulaMod("knobOsc1Control2", 0x4C)
			else
				setSEFormulaMod("knobOsc1Control2", 0x15C)
			end
		else
			setSEFormulaMod("knobOsc1Control2", 0x273)
		end
	else

		specialBounds("knobOsc1Control2", 0x00, 0x7F, 0x40)

		if sharedValues.timbreMode == tmSynth then
			if sharedValues.selectedTimbre == 0 then
				setSEFormulaMod("knobOsc1Control2", 0x4B)
			else
				setSEFormulaMod("knobOsc1Control2", 0x15B)
			end
		else
			setSEFormulaMod("knobOsc1Control2", 0x272)
		end
	end

	-- Apply new SysEx Formula
	panel:getInputComparator():rehashComparator()
end

function startupTimer()

	timer:setCallback (STARTUP_TIMER_ID, startupCallback)
	timer:startTimer(STARTUP_TIMER_ID, STARTUP_TIMER)
end

function startupCallback()

 	runPanelOperations()
	timer:stopTimer(STARTUP_TIMER_ID)
end

function synthPoller()

	-- Endless polling synthesizer loop
	timer:stopTimer(POLL_TIMER_ID)

	timer:setCallback (POLL_TIMER_ID, synthPollerCallback)
	timer:startTimer(POLL_TIMER_ID, POLL_TIMER)
end

function synthPollerCallback()

	-- Do not poll device if it's busy
	if not (sharedValues.deviceStatus == dsBusy) then
 		pollSynthStatus()

		-- Check if LCD mode is set on the synth (only if this option was selected)
		-- Pretty undesirable thing, but someone can find this handy
		if panelSettings.autocheckLCDMode == 1 then
			checkLCDModeEnabled()
		end
	end
end

function blinkMidiLightTimer()

	timer:setCallback (BLINKMIDI_TIMER_ID, blinkMidiLightTimerCallback)
	timer:stopTimer(BLINKMIDI_TIMER_ID) 
	timer:startTimer(BLINKMIDI_TIMER_ID, BLINKMIDI_TIMER)
end

function blinkMidiLightTimerCallback()

 	sharedValues.midiActivity = 0
	externalRepaintMidiActivity()

	timer:stopTimer(BLINKMIDI_TIMER_ID)
end

function delayedProgramRequest()

	-- Stop timer if it's already running
	timer:stopTimer(DELAY_PROG_REQUEST_ID)

	timer:setCallback(DELAY_PROG_REQUEST_ID, delayedProgramRequestCallback)
	timer:startTimer(DELAY_PROG_REQUEST_ID, DELAY_PROG_REQUEST)
end

function delayedProgramRequestCallback()

 	requestSingleProgram()

	timer:stopTimer(DELAY_PROG_REQUEST_ID)
end

function requestSynthSettings()

	-- Send synthesizer settings request
	sendSysExMessage({0xF0, 0x42, getGlobalMidiChannel(), 0x58, 0x0E, 0xF7})

	-- Stop timer if it's already running
	timer:stopTimer(WAITFORSET_TIMER_ID)

	timerFlags.waitForSettings = true
	setSynthReachStatus(dsBusy)

	timer:setCallback(WAITFORSET_TIMER_ID, requestSynthSettingsCallback)
	timer:startTimer(WAITFORSET_TIMER_ID, WAITFORSET_TIMER)
end

function requestSynthSettingsCallback()

 	-- Set synth error on timeout
	if timerFlags.waitForSettings == true then
		setSynthReachStatus(dsError, true)
	end

	-- Resetting the flags
	timerFlags.waitForSettings = false
	sharedValues.applySettingsOnCatch = false

	timer:stopTimer(WAITFORSET_TIMER_ID)
end

function requestSingleProgram()

	-- Request single program
	sendSysExMessage({0xF0, 0x42, getGlobalMidiChannel(), 0x58, 0x10, 0xF7})

	-- Stop timer if it's already running
	timer:stopTimer(WAIT_PROGRAM_TIMER_ID)

	timerFlags.waitForSingleProgram	= true
	setSynthReachStatus(dsBusy)

	timer:setCallback(WAIT_PROGRAM_TIMER_ID, requestSingleProgramCallback)
	timer:startTimer(WAIT_PROGRAM_TIMER_ID, WAIT_PROGRAM_TIMER)
end

function requestSingleProgramCallback()

 	-- Set synth error on timeout
	if timerFlags.waitForSingleProgram == true then
		setSynthReachStatus(dsError, true)
	end

	timerFlags.waitForSingleProgram	= false

	timer:stopTimer(WAIT_PROGRAM_TIMER_ID)
end

function waitForWriteReply(timeOut)

	-- Stop timer if it's already running
	timer:stopTimer(WAITFORWRITE_REPLY_ID)

	timerFlags.waitForWriteReply = true
	setSynthReachStatus(dsBusy)

	timer:setCallback(WAITFORWRITE_REPLY_ID, waitForWriteReplyCallback)
	timer:startTimer(WAITFORWRITE_REPLY_ID, timeOut)
end

function waitForWriteReplyCallback()

 	-- Set synth error on timeout
	if timerFlags.waitForWriteReply == true then
		setSynthReachStatus(dsError, true)
	end

	timerFlags.waitForWriteReply = false

	timer:stopTimer(WAITFORWRITE_REPLY_ID)
end

function requestProgramBank()
	
	-- Request program bank
	sendSysExMessage({0xF0, 0x42, getGlobalMidiChannel(), 0x58, 0x1C, 0xF7})

	-- Stop timer if it's already running
	timer:stopTimer(WAIT_BANK_TIMER_ID)

	timerFlags.waitForBulkDump	= true
	setSynthReachStatus(dsBusy)

	timer:setCallback(WAIT_BANK_TIMER_ID, requestProgramBankCallback)
	timer:startTimer(WAIT_BANK_TIMER_ID, WAIT_BANK_TIMER)
end

function requestProgramBankCallback()

 	-- Set synth error on timeout
	if timerFlags.waitForBulkDump == true then
		setSynthReachStatus(dsError, true)
	end

	timerFlags.waitForBulkDump	= false

	timer:stopTimer(WAIT_BANK_TIMER_ID)
end

function saveStateOperations(stateData)

	local i, j

	-- Syncing buffer is required here
	syncPanelWithBuffer()

	-- Save data buffer
	-- Merge vocoder data with program data if necessary
	if sharedValues.timbreMode == tmSynth then

		stateData:setProperty("dataBuffer", toCSV(dataBuffer), nil)
	else

		stateData:setProperty("dataBuffer", toCSV(getMergedTimbreVocoderData()), nil)
	end

	-- Save program bank
	for i = 1, 8 do
		for j = 1, 16 do 
			stateData:setProperty(string.format("bank%dProgram%d", i, j), toCSV(presetBank[i][j]), nil)
		end
	end

	stateData:setProperty("selectedPreset",		tostring(sharedValues.selectedPreset), nil)
	stateData:setProperty("selectedBank",		tostring(sharedValues.selectedBank), nil)
	stateData:setProperty("saveToRamEnabled",	tostring(sharedValues.saveToRamEnabled), nil)

	stateData:setProperty("sendProgOnStartup",	tostring(panelSettings.sendProgOnStartup), nil) -- Decided not to make this "Global"
	stateData:setProperty("clockSource",		tostring(panelSettings.clockSource), nil)
	stateData:setProperty("localMode",			tostring(panelSettings.localMode), nil)
end

function loadStateOperations(stateData)
	
	local i, j

	-- Restore data buffer
	dataBuffer = fromCSV(stateData:getProperty("dataBuffer"))

	-- Restore program bank
	for i = 1, 8 do
		for j = 1, 16 do 
			presetBank[i][j] = fromCSV(stateData:getProperty(string.format("bank%dProgram%d", i, j)))
		end
	end

	sharedValues.selectedPreset			= tonumber(stateData:getProperty("selectedPreset"))
	sharedValues.selectedBank 			= tonumber(stateData:getProperty("selectedBank"))
	sharedValues.saveToRamEnabled		= tonumber(stateData:getProperty("saveToRamEnabled"))

	panelSettings.sendProgOnStartup		= tonumber(stateData:getProperty("sendProgOnStartup"))
	panelSettings.clockSource			= tonumber(stateData:getProperty("clockSource"))
	panelSettings.localMode				= tonumber(stateData:getProperty("localMode"))
end

function restoreGlobalSettings()

	local panelSettingsExt = {}
	local panelSettingsExtStr

	local settingsFile = getLocalSettingsFile()

	-- Loading shared settings from file
	if settingsFile ~= nil then

		panelSettingsExt = json.decode(settingsFile:loadFileAsString())

		panelSettings.sendOnProgChange		= panelSettingsExt.sendOnProgChange
		panelSettings.autocheckLCDMode		= panelSettingsExt.autocheckLCDMode
		panelSettings.continuousPolling		= panelSettingsExt.continuousPolling
		panelSettings.disableWarnings		= panelSettingsExt.disableWarnings
		panelSettings.selectedSkin			= panelSettingsExt.selectedSkin
		panelSettings.reqProgOnChange		= panelSettingsExt.reqProgOnChange
	end
end

function saveGlobalSettings()

	local settingsFileDir, settingsFile
	local panelSettingsExt = {}
	local panelSettingsExtStr

	-- Saving some of the settings into external file to make them shared

	-- Preparing data
	panelSettingsExt.sendOnProgChange	= panelSettings.sendOnProgChange
	panelSettingsExt.autocheckLCDMode	= panelSettings.autocheckLCDMode
	panelSettingsExt.continuousPolling	= panelSettings.continuousPolling
	panelSettingsExt.disableWarnings	= panelSettings.disableWarnings
	panelSettingsExt.selectedSkin		= panelSettings.selectedSkin
	panelSettingsExt.reqProgOnChange	= panelSettings.reqProgOnChange
	panelSettingsExt.panelVersion		= panelVersion

	-- Encode settings as json string
	panelSettingsExtStr = json.encode(panelSettingsExt)

	-- Prepare file to save
	settingsFileDir = File.getSpecialLocation(File.currentExecutableFile):getChildFile(panel:getProperty("name"))
	settingsFile = File(settingsFileDir:getChildFile("config.json"))

	-- Check if file exists
	if settingsFile:existsAsFile() == false then
		
		-- File not exist. Check if it can be created
		if settingsFile:create() == false then
			return
		end
	end

	-- Ok, writing settings there
	settingsFile:replaceWithText(panelSettingsExtStr, false, false)
end

function requestOperationMode()

	sendSysExMessage({0xF0, 0x42, getGlobalMidiChannel(), 0x58, 0x12, 0xF7})
end

function captureProgramChangeMessage(msgData)

	local currProgram = {sharedValues.synthBank, sharedValues.synthPreset}

	sharedValues.synthBank = bit.rshift(msgData:getByte(1), 4)
	sharedValues.synthPreset = bit.band(msgData:getByte(1), 0x0F)

	getComp("uiSynthSideSelector"):repaint()

	-- Request current program, if such a setting has been set
	if	(panelSettings.reqProgOnChange == 1) and 
 		((currProgram[1] ~= sharedValues.synthBank) or (currProgram[2] ~= sharedValues.synthPreset)) then

		requestSingleProgram()
	end
end

function requestSynthSettingsMod(mod, value, source)

	if blockExecution(source) then
		return
	end

	requestSynthSettings()
end

function pollSynthStatus()

	-- Reset reach flag
	sharedValues.reachStatus = 0

	-- Send status request, expecting reply data on input
	sendSysExMessage({0xF0, 0x7E, getGlobalMidiChannel(true), 0x06, 0x01, 0xF7})

	timer:setCallback (POLLSTATE_TIMER_ID, pollSynthStatusCallback)
	timer:startTimer(POLLSTATE_TIMER_ID, POLLSTATE_TIMER)
end

function pollSynthStatusCallback()

 	-- Set synth offline on timeout
	if sharedValues.reachStatus == 0 then
		setSynthReachStatus(dsOffline)
	end

	timer:stopTimer(POLLSTATE_TIMER_ID)
end
