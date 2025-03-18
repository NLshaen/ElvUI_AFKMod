local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local AFK = E:GetModule('AFK')
local CH = E:GetModule('Chat')
local AddOnName, Engine = ...

-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)

-- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local AFKMod = E:NewModule('AFKMod', 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
Engine[1] = AFKMod
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[AddOnName] = Engine

AFKMod.Configs = {}
AFKMod.Title = C_AddOns.GetAddOnMetadata(AddOnName, 'Title')
AFKMod.Version = C_AddOns.GetAddOnMetadata(AddOnName, 'Version')
--Version = tonumber(Version)

local Title = AFKMod.Title
local Version = AFKMod.Version
local By =  'by |cFF8866ccNLshaaen|r Trapman Sulfuron'
--local title = print("|cFFdd2244%s|r", Title)
--local by = print("by |cFF8866ccNLshaaen|r alias |cFF34dd61Trapman Sulfuron|r |cFFdd2244v%s|r", Version)
--local title = SetFormattedText('%s', tostring(Title))

-- Default options
P["AFKMod"] = {
	AFKMod_enable = {
        enabled = true
    },
    AFKMod_Dark = {
        enabled = false
    },
    AFKMod_White = {
		enabled = false
	}
}
-- Function we can call when a setting changes.
-- In this case it just checks if "SomeToggleOption" is enabled. If it is it prints the value of "SomeRangeOption"
-- otherwise it tells you that "SomeToggleOption" is disabled.
function AFKMod:UpdateOptions()
	local AFKMod_enabled = E.db.AFKMod.enabled
	local AFKMod_Dark = E.db.AFKMod.dark
	local AFKMod_White = E.db.AFKMod.white

	if AFKMod_enabled then
		print("AFKMod is enabled", AFKMod_enabled)
	else
		print("AFKMod is disabled")
	end
	if AFKMod_Dark then
		print("Dark Mod is enabled", AFKMod_Dark)
	else
		print("AFKMod_Dark is disabled")
	end
	if AFKMod_White then
		print("White Mod is enabled", AFKMod_White)
	else
		print("AFKMod_White is disabled")
	end
end
-- This function inserts our GUI table into the ElvUI Options.
-- You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function AFKMod:InsertOptions()
	E.Options.args.AFKMod = {
		order = 4,
		type = "group",
		name = "AFKMod",
		args = {
			AFKMod_name = {
				order = 1,
				type = 'header',
				name = Title..' [v'..Version..'] '..By,
			},
			AFKMod_enabled = {
				order = 2,
				type = "toggle",
				name = "Enabled",
				desc = "Display the AFKMOD screen ON or OFF",
				set = function(info, value)
					E.db.AFKMod.enabled = value
					AFKMod:UpdateOptions()-- We changed a setting, call our Update function
				end,
				get = function(info)
					return E.db.AFKMod.enabled
				end
			},
			AFKMod_Dark = {
				order = 3,
				type = "toggle",
				name = "Dark Mod enabled",
				desc = "Activate the Dark Mod AFK display !!!",
				get = function(info)
					return E.db.AFKMod.dark
				end,
				set = function(info, value)
					E.db.AFKMod.dark = value
					AFKMod:UpdateOptions() -- We changed a setting, call our Update function
				end,
			},
			AFKMod_White = {
				order = 4,
				type = "toggle",
				name = "White Mod enabled",
				desc = "Activate the White Mod AFK display !!!",
				get = function(info)
					return E.db.AFKMod.white
				end,
				set = function(info, value)
					E.db.AFKMod.white = value
					AFKMod:UpdateOptions() -- We changed a setting, call our Update function
				end,
			},
		},
	}
end

--local LCS = LibStub("LibClassicSpecs")
--local MAJOR, MINOR = 'LibClassicSpecs-ElvUI', 1003
--local LCS = LibStub:NewLibrary(MAJOR, MINOR)

local _G = _G
local date = date
local select = select
local format, random, floor = string.format, random, floor
local unpack = unpack
local tostring, pcall = tostring, pcall
local format, strsub, gsub = format, strsub, gsub

local CloseAllWindows = CloseAllWindows
--local CharacterFrameToggle = ToggleCharacter("PaperDollFrame") -- Open character frame
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetGuildInfo = GetGuildInfo
local GetTime = GetTime
local GetGameTime = GetGameTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local UIParent = UIParent
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK
local UnitStat = UnitStat
local UnitHealth = UnitHealth
local UnitClass = UnitClass
local GetAverageItemLevel = GetAverageItemLevel
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
--local GetClampedCurrentExpansionLevel = GetClampedCurrentExpansionLevel
--local GetExpansionDisplayInfo = GetExpansionDisplayInfo
local Chat_GetChatCategory = Chat_GetChatCategory
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture

local C_PetBattles_IsInBattle = C_PetBattles and C_PetBattles.IsInBattle

local CinematicFrame = _G.CinematicFrame
local CharacterFrame = _G.CharacterFrame
local MovieFrame = _G.MovieFrame
local DNDstr = _G.DND
local AFKstr = _G.AFK

local CAMERA_SPEED = 0.025
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}
local printKeys = {
	PRINTSCREEN = true,
}

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

-- create these early and set the chat as moveable so the drag sticks
local afk = CreateFrame('Frame', 'ElvUIAFKFrame')
local chat = CreateFrame('ScrollingMessageFrame', 'ElvUIAFKChat', afk)
local character = CreateFrame('Frame', 'ElvUICharacterFrame', afk)
local bottom = CreateFrame('Frame', nil, afk)
local top = CreateFrame('Frame', nil, afk)
local stats = CreateFrame('Frame', nil, afk)
local logoWC = CreateFrame('Frame', nil, afk)
local currentTimeServerFrame = CreateFrame('Frame', nil, afk)

chat:SetMovable(true)

AFKMod.afk = afk
afk.chat = chat
afk.bottom = bottom
afk.top = top
afk.stats = stats
afk.logoWC = logoWC
afk.currentTimeServerFrame = currentTimeServerFrame

--[[
-- LCS Function
function AFK:SpecName()
	local currentSpecIndex = GetSpecialization()
	if currentSpecIndex then
		local specID, specName = GetSpecializationInfo(currentSpecIndex)
		print("Current Spec:", specName)
	else
		print("Specialization data not available.")
	end
end
]]

function AFKMod:OnEnable()
    print("ElvUI plugin AFKMod is enabled !")
    self:HookIntoElvUI()
end

function AFKMod:HookIntoElvUI()
    if E.db.AFKMod then
        print("AFKMod Parameters loaded !")
    end
end

function AFKMod:UpdateTimer()
	local time = GetTime() - self.startTime
	bottom.time:SetFormattedText('%02d:%02d', floor(time/60), time % 60)
end

function AFKMod:CameraSpin(status)
	if status and E.db.general.afkSpin then
		MoveViewLeftStart(CAMERA_SPEED)
	else
		MoveViewLeftStop()
	end
end

function AFKMod:SetAFK(status)
	if status then
		AFKMod:CameraSpin(status)
		--AFK:SpecName()
		CloseAllWindows()
		UIParent:Hide()

		afk:Show()
			
		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo('player')
			bottom.guild:SetFormattedText('<%s> %s', guildName, guildRankName)
		else
			bottom.guild:SetText(L["No Guild"])
		end

		local model = bottom.model
		model.curAnimation = 'flex'
		model.startTime = GetTime()
		model.duration = 10
		model.isIdle = nil
		model.idleDuration = 60
		model:SetUnit('player')
		model:SetAnimation(82) -- flex animation
		-- model:SetAnimation(60) -- talking animation
		-- model:SetAnimation(61) -- drink animation
		-- model:SetAnimation(67) -- wave animation

		AFKMod.startTime = GetTime()
		AFKMod.timer = AFKMod:ScheduleRepeatingTimer('UpdateTimer', 1)

		bottom.LogoTop:SetVertexColor(unpack(E.media.rgbvaluecolor))

		stats:RegisterEvent('UNIT_STATS')
		stats:RegisterEvent('PLAYER_ENTERING_WORLD')
		stats:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')

		chat:RegisterEvent('CHAT_MSG_WHISPER')
		chat:RegisterEvent('CHAT_MSG_BN_WHISPER')
		chat:RegisterEvent('CHAT_MSG_GUILD')

		AFKMod.isAFK = true
	elseif AFKMod.isAFK then
		UIParent:Show()
		CharacterFrame:Hide()
		afk:Hide()

		AFKMod:CameraSpin()
		AFKMod:CancelTimer(AFKMod.timer)
		AFKMod:CancelTimer(AFKMod.animTimer)

		bottom.time:SetText('00:00')

		chat:UnregisterAllEvents()
		chat:Clear()

		if E.Retail and _G.PVEFrame:IsShown() then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		AFK.isAFK = false
	end
end

function AFKMod:OnEvent(event, arg1)
	if event == 'PLAYER_REGEN_ENABLED' then
		AFKMod:UnregisterEvent(event)
	elseif event == 'UPDATE_BATTLEFIELD_STATUS' or event == 'PLAYER_REGEN_DISABLED' or event == 'LFG_PROPOSAL_SHOW' then
		if event ~= 'UPDATE_BATTLEFIELD_STATUS' or (GetBattlefieldStatus(arg1) == 'confirm') then
			AFKMod:SetAFK(false)
		end

		if event == 'PLAYER_REGEN_DISABLED' then
			AFKMod:RegisterEvent('PLAYER_REGEN_ENABLED', 'OnEvent')
		end

		return
	elseif (not E.db.general.afk) or (event == 'PLAYER_FLAGS_CHANGED' and arg1 ~= 'player') or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	elseif UnitCastingInfo('player') then
		AFKMod:ScheduleTimer('OnEvent', 30)
		return -- Don't activate afk if player is crafting stuff, check back in 30 seconds
	end

	AFKMod:SetAFK(UnitIsAFK('player') and not (E.Retail and C_PetBattles_IsInBattle()))
end

function AFKMod:Chat_OnMouseWheel(delta)
	if delta == 1 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	elseif delta == -1 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	end
end

function AFKMod:Chat_OnEvent(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local chatType = strsub(event, 10)
	local info = _G.ChatTypeInfo[chatType]

	local coloredName
	if event == 'CHAT_MSG_BN_WHISPER' then
		coloredName = CH:GetBNFriendColor(arg2, arg13)
	else
		coloredName = CH:GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	end

	local chatTarget
	local chatGroup = Chat_GetChatCategory(chatType)
	if chatGroup == 'BN_CONVERSATION' then
		chatTarget = tostring(arg8)
	elseif chatGroup == 'WHISPER' or chatGroup == 'BN_WHISPER' then
		if not(strsub(arg2, 1, 2) == '|K') then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2
		end
	end

	local playerLink
	if chatType ~= 'BN_WHISPER' and chatType ~= 'BN_CONVERSATION' then
		playerLink = '|Hplayer:'..arg2..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	else
		playerLink = '|HBNplayer:'..arg2..':'..arg13..':'..arg11..':'..chatGroup..(chatTarget and ':'..chatTarget or '')..'|h'
	end

	--Escape any % characters, as it may otherwise cause an 'invalid option in format' error
	arg1 = gsub(arg1, '%%', '%%%%')

	--Remove groups of many spaces
	arg1 = RemoveExtraSpaces(arg1)

	-- isMobile
	if arg14 then
		arg1 = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..arg1
	end

	local success, body = pcall(format, _G['CHAT_'..chatType..'_GET']..arg1, playerLink..'['..coloredName..']'..'|h')
	if not success then
		E:Print('An error happened in the AFK Chat module. Please screenshot this message and report it. Info:', chatType, arg1, _G['CHAT_'..chatType..'_GET'])
		return
	end

	if CH.db.shortChannels then
		body = body:gsub('|Hchannel:(.-)|h%[(.-)%]|h', CH.ShortChannel)
		body = body:gsub('^(.-|h) '..L["whispers"], '%1')
		body = body:gsub('<'..AFKstr..'>', '[|cffFF9900'..L["AFK"]..'|r] ')
		body = body:gsub('<'..DNDstr..'>', '[|cffFF3333'..L["DND"]..'|r] ')
		body = body:gsub('%[BN_CONVERSATION:', '%['..'')
	end

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = ChatHistory_GetAccessID(chatType, chatTarget, arg12 == '' and arg13 or arg12)
	self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

function AFKMod:Toggle()
	if E.db.general.afk then
		-- Update Stats when afk mode
		AFKMod:RegisterEvent("UNIT_STATS", 'OnEvent')
		AFKMod:RegisterEvent("PLAYER_ENTERING_WORLD", 'OnEvent')
		AFKMod:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", 'OnEvent')

		AFKMod:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent')
		AFKMod:RegisterEvent('LFG_PROPOSAL_SHOW', 'OnEvent')
		AFKMod:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent')

		E:SetCVar('autoClearAFK', 1)
	else
		AFKMod:UnregisterEvent('UNIT_STATS')
		AFKMod:UnregisterEvent('PLAYER_ENTERING_WORLD')
		AFKMod:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')

		AFKMod:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		AFKMod:UnregisterEvent('PLAYER_REGEN_DISABLED')
		AFKMod:UnregisterEvent('LFG_PROPOSAL_SHOW')
		AFKMod:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS')
	end

	if E.db.general.afkChat then
		chat:SetScript('OnEvent', AFK.Chat_OnEvent)
	else
		chat:SetScript('OnEvent', nil)
		chat:Clear()
	end
end

function AFKMod:LoopAnimations()
	local model = bottom.model
	if model.curAnimation == 'flex' then
		-- model:SetAnimation(69) -- dance animation
		-- model:SetAnimation(62) -- mining animation
		model:SetAnimation(97) -- sit animation
		model.curAnimation = 'sit'
		model.startTime = GetTime()
		model.duration = 300
		model.isIdle = false
		model.idleDuration = 60
	end
end

function AFKMod:ResetChatPosition(force)
	if force then
		chat:SetUserPlaced(false)
	end
    -- chatFrame afk mode position
	if not chat:IsUserPlaced() then
		chat:ClearAllPoints()
		chat:Point('BOTTOM', afk, 'BOTTOM', 50, 10)
		-- chat:Point('TOPLEFT', afk, 'TOPLEFT', 950, -4)
	end
end

function AFKMod:OnKeyDown(key)
	if ignoreKeys[key] then return end

	if printKeys[key] then
		Screenshot()
	elseif AFKMod.isAFK then
		AFKMod:SetAFK(false)
		AFKMod:ScheduleTimer('OnEvent', 60)
	end
end

function AFKMod:Model_OnUpdate()
	if not self.isIdle then
		local timePassed = GetTime() - self.startTime
		if timePassed > self.duration then
			self:SetAnimation(0)
			self.isIdle = true

			AFKMod.animTimer = AFKMod:ScheduleTimer('LoopAnimations', self.idleDuration)
		end
	end
end

function AFKMod:Initialize()
	AFKMod.Initialized = true

	afk:SetFrameLevel(1)
	afk:SetScale(E.uiscale)
	afk:SetAllPoints(UIParent)
	afk:EnableKeyboard(true)
	afk:SetScript('OnKeyDown', AFKMod.OnKeyDown)
	afk:Hide()

	chat:Size(450, 150)
	chat:FontTemplate()
	chat:SetJustifyH('LEFT')
	chat:SetMaxLines(450)
	chat:EnableMouseWheel(true)
	chat:SetFading(false)
	chat:EnableMouse(true)
	chat:RegisterForDrag('LeftButton')
	chat:SetScript('OnDragStart', chat.StartMoving)
	chat:SetScript('OnDragStop', chat.StopMovingOrSizing)
	chat:SetScript('OnMouseWheel', AFKMod.Chat_OnMouseWheel)
	AFKMod:ResetChatPosition()

	-- CharacterFrame position
	character:SetFrameLevel(1)
	character:SetTemplate('Transparent')
	character:Point('LEFT', afk, 'LEFT', 200, -E.Border)

	-- TopFrame position
	top:SetFrameLevel(0)
	top:SetTemplate('Transparent')
	--top:Point('TOP', afk, 'TOP', 0, (-E.Border * 0.15))
	top:Point('TOP', afk, 'TOP', 0, 0)
	top:Width(E.screenWidth + (E.Border*2))
	top:Height(E.screenHeight * 0.15)

	-- BottomFrame position
	bottom:SetFrameLevel(0)
	bottom:SetTemplate('Transparent')
	bottom:Point('BOTTOM', afk, 'BOTTOM', 0, (-E.Border * 0.15))
	bottom:Width(E.screenWidth + (E.Border*2))
	bottom:Height(E.screenHeight * 0.15)

	-- Title Text
	local TitleText = afk:CreateFontString(nil, 'OVERLAY')
	TitleText:SetPoint('TOP', afk, 'TOP', 0, -10)
	TitleText:FontTemplate(nil, 24)
	TitleText:SetText("Character Stats")

	-- Stats General
	local classColor = E:ClassColor(E.myclass)
	local StatsTextG = afk:CreateFontString(nil, 'OVERLAY')
	local health = math.floor(UnitHealth("player")/1000)
	local equippedItemLevel = select(1, GetAverageItemLevel())
	local itemlevel = math.floor(equippedItemLevel)

	StatsTextG:FontTemplate(nil, 12)
	StatsTextG:SetPoint('TOP', afk, 'TOP', -15, -40)
	StatsTextG:SetTextColor(classColor.r, classColor.g, classColor.b)
	StatsTextG:SetFormattedText('[GENERAL] Health: %sK Item level: %s', tostring(health), tostring(itemlevel))

	-- Stats Attributes
	local classColor = E:ClassColor(E.myclass)
	local StatsTextA = afk:CreateFontString(nil, 'OVERLAY')
	local strength = UnitStat("player", 1)
    local agility = UnitStat("player", 2)
    local stamina = UnitStat("player", 3)
    local intellect = UnitStat("player", 4)
    local spirit = UnitStat("player", 5)
	
	StatsTextA:FontTemplate(nil, 12)
	StatsTextA:SetPoint('TOP', afk, 'TOP', -15, -60)
	StatsTextA:SetTextColor(classColor.r, classColor.g, classColor.b)
	StatsTextA:SetFormattedText('[ATTRIBUTES] Strength: %s Agility: %s Stamina: %s Intellect: %s Spirit: %s', tostring(strength), tostring(agility), tostring(stamina), tostring(intellect), tostring(spirit))
	-- StatsText:SetScript("OnEvent", AFK.UpdateStats)
	-- StatsText:SetText(string.format("Strength: ".. Strength .."Agility: ", agility, "Stamina: ", stamina, "Intellect: ", intellect, "Spirit: ", spirit))

	-- Warcraft Logo
	local logoWCtex = afk:CreateTexture(nil, 'BACKGROUND')
	logoWCtex:Size(256, 128)
	logoWCtex:Point('TOPLEFT', top, 'TOPLEFT', 25, -25)
	logoWCtex:SetTexture("Interface\\Glues\\Common\\Glues-WoW-ClassicLogo")
	--logoWCtex:SetAllPoints(logoWC) -- Make it fit the frame

--[[	local version, build, date, tocversion = GetBuildInfo()
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-CataclysmLogo"  -- Par Cataclysm
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-ClassicLogo"  -- Par Classic
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-DragonflightLogo"  -- Dragonflight
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-ShadowlandsLogo"  -- Shadowlands
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-BattleforAzerothLogo"  -- BFA
	local logoWCPath = "Interface\\Glues\\Common\\Glues-WoW-LegionLogo"  -- Legion
]]
--[[
	-- WoW logo
	local logoWC = afk:CreateTexture(nil, 'OVERLAY')
	logoWC:Size(300, 150)
	logoWC:Point('TOPLEFT', top, 'TOPLEFT', 0, -5)
	--logoWC:SetFrameStrata("MEDIUM")
	--logoWC:SetFrameLevel(0)
	local currentExpansionLevel = GetClampedCurrentExpansionLevel();
	local expansionDisplayInfo = GetExpansionDisplayInfo(currentExpansionLevel);
	if expansionDisplayInfo then
		logoWC:SetTexture(expansionDisplayInfo)
	end
	top.logoWC = logoWC

]]

    -- Elvui LogoTop	
	local logoTop = afk:CreateTexture(nil, 'OVERLAY')
	logoTop:Size(320, 150)
	logoTop:Point('CENTER', bottom, 'CENTER', 0, 500)
	logoTop:SetTexture(E.Media.Textures.LogoTop)
	bottom.LogoTop = logoTop

	-- Elvui LogoBottom
	local logoBottom = afk:CreateTexture(nil, 'OVERLAY')
	logoBottom:Size(320, 150)
	logoBottom:Point('CENTER', bottom, 'CENTER', 0, 500)
	logoBottom:SetTexture(E.Media.Textures.LogoBottom)
	bottom.LogoBottom = logoBottom

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = E.myfaction, 150, 0, 0, 0, 0
	if factionGroup == 'Neutral' then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = 'Panda', 90, 15, 10, 20, -5
	end

	-- Faction Logo
	local faction = bottom:CreateTexture(nil, 'OVERLAY')
	faction:Point('BOTTOMLEFT', bottom, 'BOTTOMLEFT', offsetX, offsetY)
	faction:SetTexture(format([[Interface\Timer\%s-Logo]], factionGroup))
	faction:Size(size, size)
	bottom.faction = faction

	-- Level Class Specialization
	local classColor = E:ClassColor(E.myclass)
	--local specName = AFK:SpecName()
	local level = bottom:CreateFontString(nil, 'OVERLAY')
	level:FontTemplate(nil, 20)
	level:SetFormattedText('LEVEL %s %s %s', E.mylevel, E.myspec, E.myclass)
	level:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', nameOffsetX, nameOffsetY)
	level:SetTextColor(classColor.r, classColor.g, classColor.b)
	bottom.LCS = LCS

	-- Name Realm Faction
	local classColor = E:ClassColor(E.myclass)
	local name = bottom:CreateFontString(nil, 'OVERLAY')
	name:FontTemplate(nil, 20)
	name:SetFormattedText('%s %s %s', E.myname, E.myrealm, E.myfaction)
	name:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', 0, -25)
	name:SetTextColor(classColor.r, classColor.g, classColor.b)
	bottom.name = name

	-- Guild Rang
	local guild = bottom:CreateFontString(nil, 'OVERLAY')
	guild:FontTemplate(nil, 20)
	guild:SetText(L["No Guild"])
	guild:Point('TOPLEFT', bottom.name, 'BOTTOMLEFT', 0, -6)
	guild:SetTextColor(0.7, 0.7, 0.7)
	bottom.guild = guild

	local afkTime = bottom:CreateFontString(nil, 'OVERLAY')
	afkTime:FontTemplate(nil, 20)
	afkTime:SetText('00:00')
	afkTime:Point('TOPLEFT', bottom.guild, 'BOTTOMLEFT', 0, -6)
	afkTime:SetTextColor(0.7, 0.7, 0.7)
	bottom.time = afkTime

	--Use this frame to control position of the model
	local modelHolder = CreateFrame('Frame', nil, bottom)
	modelHolder:Size(250)
	modelHolder:Point('BOTTOMRIGHT', bottom, 'BOTTOMRIGHT', -200, 200)
	bottom.modelHolder = modelHolder

	local model = CreateFrame('PlayerModel', 'ElvUIAFKPlayerModel', modelHolder)
	model:Point('CENTER', modelHolder, 'CENTER')
	model:Size(E.screenWidth * 2, E.screenHeight * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	model:SetFacing(6)
	model:SetScript('OnUpdate', AFKMod.Model_OnUpdate)
	bottom.model = model

	-- Date and time
	local currentDatetext = date("%A %d %B %Y")
	local currentDateFrame = afk:CreateFontString(nil, 'OVERLAY', "GameFontNormalLarge")
	currentDateFrame:FontTemplate(nil, 18)
	currentDateFrame:Point('TOPRIGHT', top, 'TOPRIGHT', -40, -25)
	currentDateFrame:SetFormattedText('%s', tostring(currentDatetext))

    --local currentTime = date("%H:%M:%S")
	--local hours, minutes = GetGameTime()
	local currentTimeServerFrame = CreateFrame('Frame', "CurrentTimeServerFrame", top)
	currentTimeServerFrame:Size(10)
	currentTimeServerFrame:Point('TOPRIGHT', top, 'TOPRIGHT', -100, -50)
	top.currentTimeServerFrame = currentTimeServerFrame
	
	currentTimeServerFrame.text = currentTimeServerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	currentTimeServerFrame.text:FontTemplate(nil, 14)
	currentTimeServerFrame.text:SetPoint("CENTER")
	currentTimeServerFrame.text:SetText("Local Time: Loading...")
	
	-- Function to update time
	function AFKMod:UpdateTime()
		local hours, minutes = GetGameTime()
		currentTimeServerFrame.text:SetText(string.format("Local Time: %02d:%02d", hours, minutes))
	end
	
	-- Set up update event
	currentTimeServerFrame:SetScript("OnUpdate", function(self, elapsed)
		self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
		if self.timeSinceLastUpdate >= 1 then  -- Update every second
			AFKMod:UpdateTime()
			self.timeSinceLastUpdate = 0
		end
	end)
	
	-- currentTimeFrame:SetFormattedText('Local Time: %s', tostring(currentTime))
		-- Register plugin so options are properly inserted when config is loaded
	E.db.AFKMod = E.db.AFKMod or {}
	EP:RegisterPlugin(AddOnName, AFKMod.InsertOptions)
	print("|cff00ff00ElvUI_AFKMod Plugin loaded successfully !!!|r")

	AFKMod:Toggle()
	AFKMod.isActive = false
end

-- Register the module with ElvUI. ElvUI will now call MyPlugin:Initialize() when ElvUI is ready to load our plugin.
E:RegisterModule(AFKMod:GetName())
