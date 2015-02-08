--[[
	settings.lua
		Methods for initializing and sharing settings between characters
--]]

local ADDON, Addon = ...
local SETS = ADDON .. '_Sets'
local CURRENT_VERSION = GetAddOnMetadata(ADDON, 'Version')

local Cache = LibStub('LibItemCache-1.1')
local L = LibStub('AceLocale-3.0'):GetLocale(ADDON)

local function SetDefaults(target, defaults)
	for k, v in pairs(defaults) do
		if type(v) == 'table'  and k ~= '__index' then
			target[k] = SetDefaults(target[k] or {}, v)
		end
	end
	
	defaults.__index = defaults
	return setmetatable(target, defaults)
end

local SettingsDefaults = {
	enabled = true,
	money = true, broker = true,
	bagFrame = true, sort = true, search = true, options = true,

	layer = 'HIGH',
	color = {0, 0, 0, 0.5},
	alpha = 1,
	scale = 1,
}

local ProfileDefaults = {
	brokerObject = 'BagnonLauncher',
	hiddenBags = {},
	spacing = 2,
}

local BaseProfile = {
	inventory = SetDefaults({
		leftSideFilter = true,
		point = 'BOTTOMRIGHT',
		x = -50, y = 100,
		itemScale = 1,
		columns = 8,
		width = 384,
		height = 512,
	}, ProfileDefaults),

	bank = SetDefaults({
		point = 'LEFT',
		itemScale = 0.8,
		columns = 16,
		width = 512,
		height = 512,
	}, ProfileDefaults)
}


--[[ Settings ]]--

function Addon:StartupSettings()
	_G[SETS] = SetDefaults(_G[SETS] or {}, {
		version = CURRENT_VERSION,
		players = {},
		frames = {
			inventory = SetDefaults({
				borderColor = {1, 1, 1, 1},
			}, SettingsDefaults),

			bank = SetDefaults({
				borderColor = {1, 1, 0, 1},
			}, SettingsDefaults),
		},

		flashFind = true, tipCount = true,
		fading = true,

		glowAlpha = 0.5,
		glowQuality = true, glowNew = true, glowQuest = true, glowSets = true, glowUnusable = true,

		emptySlots = true, colorSlots = true,
		leatherColor = {1, .6, .45},
		enchantColor = {0.64, 0.83, 1},
		inscribeColor = {.64, 1, .82},
		engineerColor = {.68, .63, .25},
		tackleColor = {0.42, 0.59, 1},
		refrigeColor = {1, .5, .5},
		gemColor = {1, .65, .98},
		mineColor = {1, .81, .38},
		herbColor = {.5, 1, .5},
		reagentColor = {1, .87, .68},
		normalColor = {1, 1, 1},
	})

	self.sets = _G[SETS]
	self:UpdateSettings()
	
	for _, player in Cache:IteratePlayers() do
		self:StartupProfile(player)
	end

	self.profile = self:GetProfile()
end

function Addon:UpdateSettings()
	local expansion, patch, release = strsplit('.', self.sets.version)
	local version = tonumber(expansion) * 10000 + tonumber(patch or 0) * 100 + tonumber(release or 0)

	-- nothing to do, yay!

	if self.sets.version ~= CURRENT_VERSION then
		self.sets.version = CURRENT_VERSION
		self:Print(format(L.Updated, self.sets.version))
	end
end


--[[ Profiles ]]--

function Addon:StartupProfile(player)
	local realm, player = Cache:GetPlayerAddress(player)
	self.sets.players[realm] = self.sets.players[realm] or {}
	self.sets.players[realm][player] = SetDefaults(self.sets.players[realm][player] or {}, BaseProfile)
end

function Addon:GetProfile(player)
	local realm, player = Cache:GetPlayerAddress(player)
	return self.sets.players[realm][player]
end