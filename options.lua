-- import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local AFKMod, E, L, V, P, G = unpack(select(2, ...))

function AFKMod:SetupOptions()
	-- Register plugin so options are properly inserted when config is loaded
		print("|cff00ff00ElvUI_AFKMod SetupOptions !!!|r")
end

-- Register the module with ElvUI. ElvUI will now call MyPlugin:Initialize() when ElvUI is ready to load our plugin.
-- E:RegisterModule(AFKMod:GetName())