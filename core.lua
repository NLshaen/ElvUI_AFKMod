-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local CH = E:GetModule('Chat')
local AddOnName, Engine = ...
--local addonName, addonTable = ...

-- Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local AFKMod = E:NewModule('AFKMod', 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
Engine[1] = AFKMod
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[AddOnName] = Engine

E.db.AFKMod = E.db.AFKMod or {}
AFKMod.Configs = {}
AFKMod.Title = C_AddOns.GetAddOnMetadata(AddOnName, 'Title')
AFKMod.Version = C_AddOns.GetAddOnMetadata(AddOnName, 'Version')
--Version = tonumber(Version)

local Title = AFKMod.Title
local Version = AFKMod.Version
local By =  'by |cFF8866ccNLshaaen|r alias |cFF6c914dTrapman|r Sulfuron'
--local title = print("|cFFdd2244%s|r", Title)
--local by = print("by |cFF8866ccNLshaaen|r alias |cFF34dd61Trapman Sulfuron|r |cFFdd2244v%s|r", Version)
--local title = SetFormattedText('%s', tostring(Title))

-- Default options
P["AFKMod"] = {
	enabled = true,
	dark = {
		enabled = true
	},
	white = {
		enabled = true
	}
}
-- Function we can call when a setting changes.
-- In this case it just checks if "SomeToggleOption" is enabled. If it is it prints the value of "SomeRangeOption"
-- otherwise it tells you that "SomeToggleOption" is disabled.
function AFKMod:UpdateOptions()
	local enabled = E.db.AFKMod.enabled
	local dark = E.db.AFKMod.dark
	local white = E.db.AFKMod.white

	if enabled then
		AFKMod:ToggleAFKMod()
		print("AFKMod is enabled", enabled)
	else
		self:UnregisterAllEvents()
		AFKMod:DisableAFKMode()
		print("AFKMod is disabled")
	end
	if dark then
		print("Dark Mod is enabled", dark)
	else
		print("AFKMod_Dark is disabled")
	end
	if white then
		print("White Mod is enabled", white)
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
		name = "|cFF8866ccAFKMod|r",
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
				set = function(info, value)
					E.db.AFKMod.dark = value
					AFKMod:UpdateOptions() -- We changed a setting, call our Update function
				end,
				get = function(info)
					return E.db.AFKMod.dark
				end
			},
			AFKMod_White = {
				order = 4,
				type = "toggle",
				name = "White Mod enabled",
				desc = "Activate the White Mod AFK display !!!",
				set = function(info, value)
					E.db.AFKMod.white = value
					AFKMod:UpdateOptions() -- We changed a setting, call our Update function
				end,
				get = function(info)
					return E.db.AFKMod.white
				end
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
local GetPrimaryTalentTree = GetPrimaryTalentTree
local GetTalentTabInfo = GetTalentTabInfo
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
--local afk = CreateFrame('Frame', 'ElvUIAFKFrame')
local afk = CreateFrame('Frame', 'AFKModFrame')
local chat = CreateFrame('ScrollingMessageFrame', 'AFKModChat', afk)
local model = CreateFrame('Frame', 'AFKModModelFrame', afk)
local bottom = CreateFrame('Frame', nil, afk)
local top = CreateFrame('Frame', nil, afk)
local stats = CreateFrame('Frame', nil, afk)
local logoWC = CreateFrame('Frame', nil, afk)
local TimeServer= CreateFrame('Frame', nil, afk)

chat:SetMovable(true)

AFKMod.AFKMode = afk
afk.chat = chat
afk.bottom = bottom
afk.top = top
afk.stats = stats
afk.logoWC = logoWC
afk.model = model
afk.TimeServer = TimeServer

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
    --print("ElvUI plugin AFKMod is enabled !")
    self:HookIntoElvUI()
end

function AFKMod:HookIntoElvUI()
    if E.db.AFKMod then
        --print("AFKMod Parameters loaded !")
		return E.db.AFKMod
    end
end

function AFKMod:OnEvent(event, unit)
    if event == "PLAYER_FLAGS_CHANGED" and unit == "player" then
        if UnitIsAFK("player") then
            self:EnableAFKMode()
        else
            self:DisableAFKMode()
        end
    end
end

function AFKMod:CameraSpin(status)
	if status and E.db.general.afkSpin then
		MoveViewLeftStart(CAMERA_SPEED)
	else
		MoveViewLeftStop()
	end
end

function AFKMod:EnableAFKMode()
    if not self.AFKFrame then

		afk:SetFrameLevel(1)
		afk:SetScale(E.uiscale)
		afk:SetAllPoints(UIParent)
		afk:EnableKeyboard(true)
		afk:SetScript('OnKeyDown', AFK.OnKeyDown)
		--afk:Hide()

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

        afk.text = afk:CreateFontString(nil, "OVERLAY")
		--self.AFKFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 32, "OUTLINE")
		afk.text:SetFont("Fonts\\EXPRESSWAY.TTF", 24, "OUTLINE")
        afk.text:SetPoint("TOP", afk, "TOP", 0, -15)
        afk.text:SetText(format("|cff00ff00%s|r is AFK", UnitName("player")))

--[[
        -- Create Top Transparent Frame
        self.TopFrame = CreateFrame("Frame", "TopAFKFrame", afk)
		self.TopFrame:SetTemplate('Transparent')
        self.TopFrame:SetPoint("TOP", afk, "TOP", 0, 0)
        self.TopFrame:SetSize(afk:GetWidth(), 200)
        self.TopFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
        self.TopFrame:SetBackdropColor(0, 0, 0, 0.95)

        -- Create Bottom Transparent Frame
        self.BottomFrame = CreateFrame("Frame", "BottomAFKFrame", afk)
		self.BottomFrame:SetTemplate('Transparent')
        self.BottomFrame:SetPoint("BOTTOM", afk, "BOTTOM", 0, 0)
        self.BottomFrame:SetSize(afk:GetWidth(), 200)
        self.BottomFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
        self.BottomFrame:SetBackdropColor(0, 0, 0, 0.95)
]]

		-- Create Logo NLUI Transparent Frame
		self.LogoFrame = CreateFrame("Frame", "NLUILogoFrame", afk)
		self.LogoFrame:SetSize(600, 210)
		self.LogoFrame:SetPoint("CENTER", afk, "CENTER", 0, 0)
		-- Create Logo NLUI texture
		self.LogoFrame.texture = self.LogoFrame:CreateTexture(nil, "OVERLAY")
		self.LogoFrame.texture:SetAllPoints(self.LogoFrame)
		self.LogoFrame.texture:SetTexture("Interface\\AddOns\\ELvUI_AFKMod\\Media\\Textures\\NLUI_target.tga")

		-- Date and time
		local DateServer = date("%A %d %B %Y")
		self.DateServerFrame = CreateFrame("Frame", "DateAFKFrame", afk)
		self.DateServerFrame:Size(10)
		self.DateServerFrame:Point('TOPRIGHT', afk, 'TOPRIGHT', -125, -25)
		--self.DateServerFrame:FontTemplate(nil, 18)

		self.DateServerFrame.text = self.DateServerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		self.DateServerFrame.text:FontTemplate(nil, 14)
		self.DateServerFrame.text:SetPoint("CENTER")
		self.DateServerFrame.text:SetFormattedText('%s', tostring(DateServer))

		--local currentTime = date("%H:%M:%S")
		--local hours, minutes = GetGameTime()
		self.TimeServerFrame = CreateFrame('Frame', "TimeServerAFKFrame", afk)
		self.TimeServerFrame:Size(10)
		self.TimeServerFrame:Point('TOPRIGHT', afk, 'TOPRIGHT', -100, -50)
				
		self.TimeServerFrame.text = self.TimeServerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		self.TimeServerFrame.text:FontTemplate(nil, 14)
		self.TimeServerFrame.text:SetPoint("CENTER")
		self.TimeServerFrame.text:SetText("Local Time: Loading...")
		
		-- Function to update time
		function AFKMod:UpdateTime()
			local hours, minutes = GetGameTime()
			self.TimeServerFrame.text:SetText(string.format("Local Time: %02d:%02d", hours, minutes))
		end
		
		-- Set up update event
		self.TimeServerFrame:SetScript("OnUpdate", function(self, elapsed)
			self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
			if self.timeSinceLastUpdate >= 1 then  -- Update every second
				AFKMod:UpdateTime()
				self.timeSinceLastUpdate = 0
			end
		end)

		local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = E.myfaction, 150, 0, 0, 0, 0
		if factionGroup == 'Neutral' then
			factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = 'Panda', 90, 15, 10, 20, -5
		end

		local faction = bottom:CreateTexture(nil, 'OVERLAY')
		faction:Point('BOTTOMLEFT', bottom, 'BOTTOMLEFT', 50, 50)
		faction:SetTexture(format([[Interface\Timer\%s-Logo]], factionGroup))
		faction:Size(size, size)
		bottom.faction = faction

		-- Level Class Specialization
		function AFKMod:UpdateSpecInfo()
			--local specIndex = GetSpecialization()
			local specid = GetPrimaryTalentTree()
			if specid then
				--local id, name, description, icon, background, role = GetSpecializationInfo(specIndex)
				local id, name = GetTalentTabInfo(specid)
				--bottom.lcs:SetFormattedText('%s %s', id, name)
				bottom.lcs:SetFormattedText('|cffffd100Level %s|r %s %s', E.mylevel, name, E.myclass)
			else
				bottom.lcs:SetText(L["No Spec"])
			end
		end

		local classColor = E:ClassColor(E.myclass)
		local lcs = bottom:CreateFontString(nil, 'OVERLAY')
		lcs:FontTemplate(nil, 20)
		--lcs:SetFormattedText('|cffffd100LEVEL %s|r  %s %s', E.mylevel, E.myspec, E.myclass)
		lcs:SetText(L["No Spec"])
		lcs:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', 0, -50)
		lcs:SetTextColor(classColor.r, classColor.g, classColor.b)
		bottom.lcs = lcs
	
		local classColor = E:ClassColor(E.myclass)
		local titlecurrentid = GetCurrentTitle()
		local titlecurrentname = GetTitleName(titlecurrentid)
		local name = bottom:CreateFontString(nil, 'OVERLAY')
		name:FontTemplate(nil, 20)
		name:SetFormattedText('%s %s', E.myname, titlecurrentname)
		name:Point('TOPLEFT', bottom.faction, 'TOPRIGHT', 0, -25)
		name:SetTextColor(classColor.r, classColor.g, classColor.b)
		bottom.name = name

		function AFKMod:UpdateGuildInfo()
			local guildName, guildRankName = GetGuildInfo("player")
			if IsInGuild then
				bottom.guild:SetFormattedText('<%s> %s - %s %s', guildName, guildRankName, E.myrealm, E.myfaction)
			else
				bottom.guild:SetText(L["No Guild"])
			end
		end

		local guild = bottom:CreateFontString(nil, 'OVERLAY')
		guild:FontTemplate(nil, 20)
		guild:SetText(L["No Guild"])
		guild:Point('TOPLEFT', bottom.name, 'BOTTOMLEFT', 0, -30)
		guild:SetTextColor(0.7, 0.7, 0.7)
		bottom.guild = guild
--[[
		-- Level Class Specialization
		local classColor = E:ClassColor(E.myclass)
		local level = UnitLevel("player")
		local _, class = UnitClass("player")
		--local specID = GetSpecialization()
    	--local specName = specID and select(2, GetSpecializationInfo(specID)) or "No Spec"
		self.Level.text = self.BottomFrame:CreateFontString(nil, 'OVERLAY')
		--self.Level.text:FontTemplate(nil, 20)
		self.Level.text:SetFont("Fonts\\EXPRESSWAY.TTF", 24, "OUTLINE")
		self.Level.text:SetPoint('BOTTOMLEFT', afk, 'BOTTOMLEFT', 0, 50)
		self.Level.text:SetFormattedText('%s', E.myclass)
		--self.Level.text:SetTextColor(classColor.r, classColor.g, classColor.b)
]]
		AFKMod.isAFK = true

    end
	CloseAllWindows()
	UIParent:Hide()
	afk:Show()
	top:Show()
	bottom:Show()
	self.LogoFrame:Show()
	AFKMod:CameraSpin(CAMERA_SPEED)
	self.DateServerFrame:Show()
	self.DateServerFrame.text:Show()
	self.TimeServerFrame:Show()
	self.TimeServerFrame.text:Show()
	AFKMod:UpdateTime()
	AFKMod:UpdateSpecInfo()
	AFKMod:UpdateGuildInfo()
end

function AFKMod:DisableAFKMode()
	
    if afk then
        afk:Hide()
		UIParent:Show()
		AFKMod.isAFK = false
    end
	if top then
		top:Hide()
		UIParent:Show()
		AFKMod.isAFK = false
    end
    if bottom then
		bottom.faction:Hide()
		bottom.lcs:Hide()
		bottom.name:Hide()
		bottom.guild:Hide()
		bottom:Hide()
		UIParent:Show()
		AFKMod.isAFK = false
    end
	if self.LogoFrame then
        self.LogoFrame:Hide()
		UIParent:Show()
		AFKMod.isAFK = false
    end
	if afk then
        AFKMod:CameraSpin()
		UIParent:Show()
		AFKMod.isAFK = false
    end
	if self.DateServerFrame then
		self.DateServerFrame:Hide()
		self.DateServerFrame.text:Hide()
		self.TimeServerFrame:Hide()
		self.TimeServerFrame.text:Hide()
		UIParent:Show()
		AFKMod.isAFK = false
		--AFKMod:UpdateTime()
	end
end

function AFKMod:ToggleAFKMod()
	if E.db.AFKMod then

		AFKMod:RegisterEvent('GUILD_ROSTER_UPDATE', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_GUILD_UPDATE', 'OnEvent')
		AFKMod:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED', 'OnEvent')

		AFKMod:RegisterEvent('UNIT_STATS', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_ENTERING_WORLD', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', 'OnEvent')

		AFKMod:RegisterEvent('PLAYER_FLAGS_CHANGED', 'OnEvent')
		AFKMod:RegisterEvent('PLAYER_REGEN_DISABLED', 'OnEvent')
		AFKMod:RegisterEvent('LFG_PROPOSAL_SHOW', 'OnEvent')
		AFKMod:RegisterEvent('UPDATE_BATTLEFIELD_STATUS', 'OnEvent')

		E:SetCVar('autoClearAFK', 1)
	else

		AFKMod:RegisterEvent('GUILD_ROSTER_UPDATE')
		AFKMod:RegisterEvent('PLAYER_GUILD_UPDATE')
		AFKMod:RegisterEvent('ACTIVE_TALENT_GROUP_CHANGED')

		AFKMod:UnregisterEvent('UNIT_STATS')
		AFKMod:UnregisterEvent('PLAYER_ENTERING_WORLD')
		AFKMod:UnregisterEvent('PLAYER_EQUIPMENT_CHANGED')
		AFKMod:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')

		AFKMod:UnregisterEvent('PLAYER_FLAGS_CHANGED')
		AFKMod:UnregisterEvent('PLAYER_REGEN_DISABLED')
		AFKMod:UnregisterEvent('LFG_PROPOSAL_SHOW')
		AFKMod:UnregisterEvent('UPDATE_BATTLEFIELD_STATUS')
	end

--[[
	if E.db.general.afkChat then
		chat:SetScript('OnEvent', AFKMod.Chat_OnEvent)
	else
		chat:SetScript('OnEvent', nil)
		chat:Clear()
	end

]]
end

function AFKMod:Initialize()
	AFKMod.Initialized = true

	EP:RegisterPlugin(AddOnName, AFKMod.InsertOptions)
	print(Title..' [v'..Version..'] '..By..' loaded successfully.')
    --self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")

	AFKMod:ToggleAFKMod()

	AFKMod.isActive = false
end

E:RegisterModule(AFKMod:GetName())
