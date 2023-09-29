-- Create the addon
Fizzle = LibStub("AceAddon-3.0"):NewAddon("Fizzle", "AceEvent-3.0", "AceHook-3.0", "AceConsole-3.0")
local defaults = {
	profile = {
		Percent = true,
		Border = true,
		Invert = false,
		HideText = false,
		DisplayWhenFull = true,
		modules = {
			["Inspect"] = true,
		},
	},
}
local L = LibStub("AceLocale-3.0"):GetLocale("Fizzle")
local crayon = LibStub("LibCrayon-3.0")
local fontSize = 12
local _G = _G
local sformat = string.format
local ipairs = ipairs
local db -- We'll put our saved vars here later
-- Make some of the inventory functions more local (ordered by string length!)
local GetItemQualityColor = GetItemQualityColor
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemDurability = GetInventoryItemDurability
-- Flag to check if the borders were created or not
local bordersCreated = false
local items, nditems -- our item slot tables
local gemElements = {}

CharacterModelFrameRotateRightButton:Hide()
CharacterModelFrameRotateLeftButton:Hide()
for i=1,5 do _G["MagicResFrame" .. i]:Hide()end
PlayerStatFrameLeftDropDown:Hide()
PlayerStatFrameRightDropDown:Hide()

CharacterAttributesFrame:Hide()

-- Return an options table full of goodies!
local function getOptions()
	local options = {
		type = "group",
		name = GetAddOnMetadata("Fizzle", "Title"),
		args = {
			fizzledesc = {
				type = "description",
				order = 0,
				name = GetAddOnMetadata("Fizzle", "Notes"),
			},
			percent = {
				name = L["Percent"],
				desc = L["Toggle percentage display."],
				type = "toggle",
				order = 100,
				width = "full",
				get = function() return db.Percent end,
				set = function() db.Percent = not db.Percent end,
			},
			border = {
				name = L["Border"],
				desc = L["Toggle quality borders."],
				type = "toggle",
				order = 200,
				width = "full",
				get = function() return db.Border end,
				set = function() db.Border = not db.Border end,
			},
			invert = {
				name = L["Invert"],
				desc = L["Show numbers the other way around. Eg. 0% = full durability , 100 = no durability."],
				type = "toggle",
				order = 300,
				width = "full",
				get = function() return db.Invert end,
				set = function() db.Invert = not db.Invert end,
			},
			hidetext = {
				name = L["Hide Text"],
				desc = L["Hide durability text."],
				type = "toggle",
				order = 400,
				width = "full",
				get = function() return db.HideText end,
				set = function() db.HideText = not db.HideText end,
			},
			showfull = {
				name = L["Show Full"],
				desc = L["Show durability when full."],
				type = "toggle",
				order = 500,
				width = "full",
				get = function() return db.DisplayWhenFull end,
				set = function() db.DisplayWhenFull = not db.DisplayWhenFull end,
			},
			-- Inspect module toggle
			inspect = {
				name = L["Inspect"],
				desc = L["Show item quality when inspecting people."],
				type = "toggle",
				order = 600,
				width = "full",
				get = function() return db.modules["Inspect"] end,
				set = function(info, v)
					db.modules["Inspect"] = v
					if v then
						Fizzle:EnableModule("Inspect")
					else
						Fizzle:DisableModule("Inspect")
					end
				end,
			}
		}
	}
	return options
end

function Fizzle:OnInitialize()
	-- Grab our db
	self.db = LibStub("AceDB-3.0"):New("FizzleDB", defaults)
	db = self.db.profile
	-- Register our options
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Fizzle", getOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Fizzle", GetAddOnMetadata("Fizzle", "Title"))
	-- Register chat command to open options dialog
	self:RegisterChatCommand("fizzle", function() InterfaceOptionsFrame_OpenToFrame(LibStub("AceConfigDialog-3.0").BlizOptions["Fizzle"].frame) end)
	self:RegisterChatCommand("fizz", function() InterfaceOptionsFrame_OpenToFrame(LibStub("AceConfigDialog-3.0").BlizOptions["Fizzle"].frame) end)
end

function Fizzle:OnEnable()
	self:SecureHook("CharacterFrame_OnShow")
	self:SecureHook("CharacterFrame_OnHide")
	if not bordersCreated then
		self:MakeTypeTable()
	end
end

function Fizzle:OnDisable()
	for _, item in ipairs(items) do
		_G[item .. "FizzleS"]:SetText("")
	end
	self:HideBorders()
end

function Fizzle:CreateBorder(slottype, slot, name, hasText)
	local gslot = _G[slottype..slot.."Slot"]
	if gslot then
		-- Create border
		local border = gslot:CreateTexture(slot .. name .. "B", "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
		border:SetBlendMode("ADD")
		border:SetAlpha(0.75)
		border:SetHeight(68)
		border:SetWidth(68)
		border:SetPoint("CENTER", gslot, "CENTER", 0, 1)
		border:Hide()

		-- Check if we need a text field creating
		if hasText then
			local str = gslot:CreateFontString(slot .. name .. "S", "OVERLAY")
			local font, _, flags = NumberFontNormal:GetFont()
			str:SetFont(font, fontSize, flags)
			str:SetPoint("CENTER", gslot, "BOTTOM", 0, 8)
		end
	end
end

function Fizzle:MakeTypeTable()
	-- Table of item types and slots.  Thanks Tekkub.
	items = {
		"Head",
		"Shoulder",
		"Chest",
		"Waist",
		"Legs",
		"Feet",
		"Wrist",
		"Hands",
		"MainHand",
		"SecondaryHand",
		"Ranged",
		"Back",
		"Finger0",
		"Finger1",
		"Neck",
	}
         
	-- Items without durability but with some quality, needed for border colouring.
	nditems = {
		"Ammo",
		"Trinket0",
		"Trinket1",
		"Relic",
		"Tabard",
	}
        
	itemslot = {
		"HeadSlot",
		"ShoulderSlot",
		"ChestSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"WristSlot",
		"HandsSlot",
		"MainHandSlot",
		"SecondaryHandSlot",
		"RangedSlot",
		"BackSlot",
		"Finger0Slot",
		"Finger1Slot",
		"NeckSlot",
	}
	for _, item in ipairs(items) do
		self:CreateBorder("Character", item, "Fizzle", true)
	end

	-- Same again, but for ND items, and only creating a border
	for _, nditem in ipairs(nditems) do
		self:CreateBorder("Character", nditem, "Fizzle", false)
	end
end

local enchantAttributes = {
	["1"] = "Rockbiter 3",
	["2"] = "Frostbr& 1",
	["3"] = "Flametongue 3",
	["4"] = "Flametongue 2",
	["5"] = "Flametongue 1",
	["6"] = "Rockbiter 2",
	["7"] = "Deadly Poison",
	["8"] = "Deadly Poison II",
	["9"] = "Poison (15 Dmg)",
	["10"] = "Poison (20 Dmg)",
	["11"] = "Poison (25 Dmg)",
	["12"] = "Frostbr& 2",
	["13"] = "Sharpened (+3 Damage)",
	["14"] = "Sharpened (+4 Damage)",
	["15"] = "Reinforced (+8 Armor)",
	["16"] = "Reinforced (+16 Armor)",
	["17"] = "Reinforced (+24 Armor)",
	["18"] = "Reinforced (+32 Armor)",
	["19"] = "Weighted (+2 Damage)",
	["20"] = "Weighted (+3 Damage)",
	["21"] = "Weighted (+4 Damage)",
	["22"] = "Crippling Poison",
	["23"] = "Mind-numbing Poison II",
	["24"] = "+5 Mana",
	["25"] = "Shadow Oil",
	["26"] = "Frost Oil",
	["27"] = "Sundered",
	["28"] = "+4 All Resists",
	["29"] = "Rockbiter 1",
	["30"] = "Scope (+1 Damage)",
	["31"] = "+4 Beastslaying",
	["32"] = "Scope (+2 Damage)",
	["33"] = "Scope (+3 Damage)",
	["34"] = "Counterweight (+20 Haste)",
	["35"] = "Mind Numbing Poison",
	["36"] = "Enchant: Fiery Blaze",
	["37"] = "Steel Weapon Chain",
	["38"] = "+5 Defense",
	["39"] = "Sharpened (+1 Damage)",
	["40"] = "Sharpened (+2 Damage)",
	["41"] = "+5 Health",
	["42"] = "Poison (Instant 20)",
	["43"] = "Iron Spike (8-12)",
	["44"] = "Absorption (10)",
	["63"] = "Absorption (25)",
	["64"] = "+3 Spirit",
	["65"] = "+1 All Resists",
	["66"] = "+1 Stamina",
	["67"] = "+1 Damage",
	["68"] = "+1 Strength",
	["69"] = "+2 Strength",
	["70"] = "+3 Strength",
	["71"] = "+1 Stamina",
	["72"] = "+2 Stamina",
	["73"] = "+3 Stamina",
	["74"] = "+1 Agility",
	["75"] = "+2 Agility",
	["76"] = "+3 Agility",
	["77"] = "+2 Damage",
	["78"] = "+3 Damage",
	["79"] = "+1 Intel",
	["80"] = "+2 Intel",
	["81"] = "+3 Intel",
	["82"] = "+1 Spirit",
	["83"] = "+2 Spirit",
	["84"] = "+3 Spirit",
	["85"] = "+3 Armor",
	["86"] = "+8 Armor",
	["87"] = "+12 Armor",
	["88"] = "",
	["89"] = "+16 Armor",
	["90"] = "+4 Agility",
	["91"] = "+5 Agility",
	["92"] = "+6 Agility",
	["93"] = "+7 Agility",
	["94"] = "+4 Intel",
	["95"] = "+5 Intel",
	["96"] = "+6 Intel",
	["97"] = "+7 Intel",
	["98"] = "+4 Spirit",
	["99"] = "+5 Spirit",
	["100"] = "+6 Spirit",
	["101"] = "+7 Spirit",
	["102"] = "+4 Stamina",
	["103"] = "+5 Stamina",
	["104"] = "+6 Stamina",
	["105"] = "+7 Stamina",
	["106"] = "+4 Strength",
	["107"] = "+5 Strength",
	["108"] = "+6 Strength",
	["109"] = "+7 Strength",
	["110"] = "+1 Defense",
	["111"] = "+2 Defense",
	["112"] = "+3 Defense",
	["113"] = "+4 Defense",
	["114"] = "+5 Defense",
	["115"] = "+6 Defense",
	["116"] = "+7 Defense",
	["117"] = "+4 Damage",
	["118"] = "+5 Damage",
	["119"] = "+6 Damage",
	["120"] = "+7 Damage",
	["121"] = "+20 Armor",
	["122"] = "+24 Armor",
	["123"] = "+28 Armor",
	["124"] = "Flametongue Totem 1",
	["125"] = "+1 Sword Skill",
	["126"] = "+2 Sword Skill",
	["127"] = "+3 Sword Skill",
	["128"] = "+4 Sword Skill",
	["129"] = "+5 Sword Skill",
	["130"] = "+6 Sword Skill",
	["131"] = "+7 Sword Skill",
	["132"] = "+1 Two-H&ed Sword Skill",
	["133"] = "+2 Two-H&ed Sword Skill",
	["134"] = "+3 Two-H&ed Sword Skill",
	["135"] = "+4 Two-H&ed Sword Skill",
	["136"] = "+5 Two-H&ed Sword Skill",
	["137"] = "+6 Two-H&ed Sword Skill",
	["138"] = "+7 Two-H&ed Sword Skill",
	["139"] = "+1 Mace Skill",
	["140"] = "+2 Mace Skill",
	["141"] = "+3 Mace Skill",
	["142"] = "+4 Mace Skill",
	["143"] = "+5 Mace Skill",
	["144"] = "+6 Mace Skill",
	["145"] = "+7 Mace Skill",
	["146"] = "+1 Two-H&ed Mace Skill",
	["147"] = "+2 Two-H&ed Mace Skill",
	["148"] = "+3 Two-H&ed Mace Skill",
	["149"] = "+4 Two-H&ed Mace Skill",
	["150"] = "+5 Two-H&ed Mace Skill",
	["151"] = "+6 Two-H&ed Mace Skill",
	["152"] = "+7 Two-H&ed Mace Skill",
	["153"] = "+1 Axe Skill",
	["154"] = "+2 Axe Skill",
	["155"] = "+3 Axe Skill",
	["156"] = "+4 Axe Skill",
	["157"] = "+5 Axe Skill",
	["158"] = "+6 Ase Skill",
	["159"] = "+7 Axe Skill",
	["160"] = "+1 Two-H&ed Axe Skill",
	["161"] = "+2 Two-H&ed Axe Skill",
	["162"] = "+3 Two-H&ed Axe Skill",
	["163"] = "+4 Two-H&ed Axe Skill",
	["164"] = "+5 Two-H&ed Axe Skill",
	["165"] = "+6 Two-H&ed Axe Skill",
	["166"] = "+7 Two-H&ed Axe Skill",
	["167"] = "+1 Dagger Skill",
	["168"] = "+2 Dagger Skill",
	["169"] = "+3 Dagger Skill",
	["170"] = "+4 Dagger Skill",
	["171"] = "+5 Dagger Skill",
	["172"] = "+6 Dagger Skill",
	["173"] = "+7 Dagger Skill",
	["174"] = "+1 Gun Skill",
	["175"] = "+2 Gun Skill",
	["176"] = "+3 Gun Skill",
	["177"] = "+4 Gun Skill",
	["178"] = "+5 Gun Skill",
	["179"] = "+6 Gun Skill",
	["180"] = "+7 Gun Skill",
	["181"] = "+1 Bow Skill",
	["182"] = "+2 Bow Skill",
	["183"] = "+3 Bow Skill",
	["184"] = "+4 Bow Skill",
	["185"] = "+5 Bow Skill",
	["186"] = "+6 Bow Skill",
	["187"] = "+7 Bow Skill",
	["188"] = "+2 Beast Slaying",
	["189"] = "+4 Beast Slaying",
	["190"] = "+6 Beast Slaying",
	["191"] = "+8 Beast Slaying",
	["192"] = "+10 Beast Slaying",
	["193"] = "+12 Beast Slaying",
	["194"] = "+14 Beast Slaying",
	["195"] = "+14 Crit",
	["196"] = "+28 Crit",
	["197"] = "+42 Crit",
	["198"] = "+56 Crit",
	["199"] = "10% On Get Hit: Shadow Bolt (10 Damage)",
	["200"] = "10% On Get Hit: Shadow Bolt (20 Damage)",
	["201"] = "10% On Get Hit: Shadow Bolt (30 Damage)",
	["202"] = "10% On Get Hit: Shadow Bolt (40 Damage)",
	["203"] = "10% On Get Hit: Shadow Bolt (50 Damage)",
	["204"] = "10% On Get Hit: Shadow Bolt (60 Damage)",
	["205"] = "10% On Get Hit: Shadow Bolt (70 Damage)",
	["206"] = "+2 Heal",
	["207"] = "+4 Heal",
	["208"] = "+7 Heal",
	["209"] = "+9 Heal",
	["210"] = "+11 Heal",
	["211"] = "+13 Heal",
	["212"] = "+15 Heal",
	["213"] = "+1 Fire SP",
	["214"] = "+3 Fire SP",
	["215"] = "+4 Fire SP",
	["216"] = "+6 Fire SP",
	["217"] = "+7 Fire SP",
	["218"] = "+9 Fire SP",
	["219"] = "+10 Fire SP",
	["220"] = "+1 Nature SP",
	["221"] = "+3 Nature SP",
	["222"] = "+4 Nature SP",
	["223"] = "+6 Nature SP",
	["224"] = "+7 Nature SP",
	["225"] = "+9 Nature SP",
	["226"] = "+10 Nature SP",
	["227"] = "+1 Frost SP",
	["228"] = "+3 Frost SP",
	["229"] = "+4 Frost SP",
	["230"] = "+6 Frost SP",
	["231"] = "+7 Frost SP",
	["232"] = "+9 Frost SP",
	["233"] = "+10 Frost SP",
	["234"] = "+1 Shadow SP",
	["235"] = "+3 Shadow SP",
	["236"] = "+4 Shadow SP",
	["237"] = "+6 Shadow SP",
	["238"] = "+7 Shadow SP",
	["239"] = "+9 Shadow SP",
	["240"] = "+10 Shadow SP",
	["241"] = "+2 Weapon Damage",
	["242"] = "+15 Health",
	["243"] = "+1 Spirit",
	["244"] = "+4 Intel",
	["245"] = "+5 Armor",
	["246"] = "+20 Mana",
	["247"] = "+1 Agility",
	["248"] = "+1 Strength",
	["249"] = "+2 Beastslaying",
	["250"] = "+1  Weapon Damage",
	["251"] = "+1 Intel",
	["252"] = "+6 Spirit",
	["253"] = "Absorption (50)",
	["254"] = "+25 Health",
	["255"] = "+3 Spirit",
	["256"] = "+5 Fire Resist",
	["257"] = "+10 Armor",
	["263"] = "Fishing Lure (+25 Fishing Skill)",
	["264"] = "Fishing Lure (+50 Fishing Skill)",
	["265"] = "Fishing Lure (+75 Fishing Skill)",
	["266"] = "Fishing Lure (+100 Fishing Skill)",
	["283"] = "Windfury 1",
	["284"] = "Windfury 2",
	["285"] = "Flametongue Totem 2",
	["286"] = "+2 Weapon Fire Damage",
	["287"] = "+4 Weapon Fire Damage",
	["288"] = "+6 Weapon Fire Damage",
	["289"] = "+8 Weapon Fire Damage",
	["290"] = "+10 Weapon Fire Damage",
	["291"] = "+12 Weapon Fire Damage",
	["292"] = "+14 Weapon Fire Damage",
	["303"] = "Orb of Fire",
	["323"] = "Instant Poison",
	["324"] = "Instant Poison II",
	["325"] = "Instant Poison III",
	["343"] = "+8 Agility",
	["344"] = "+32 Armor",
	["345"] = "+40 Armor",
	["346"] = "+36 Armor",
	["347"] = "+44 Armor",
	["348"] = "+48 Armor",
	["349"] = "+9 Agility",
	["350"] = "+8 Intel",
	["351"] = "+8 Spirit",
	["352"] = "+8 Strength",
	["353"] = "+8 Stamina",
	["354"] = "+9 Intel",
	["355"] = "+9 Spirit",
	["356"] = "+9 Stamina",
	["357"] = "+9 Strength",
	["358"] = "+10 Agility",
	["359"] = "+10 Intel",
	["360"] = "+10 Spirit",
	["361"] = "+10 Stamina",
	["362"] = "+10 Strength",
	["363"] = "+11 Agility",
	["364"] = "+11 Intel",
	["365"] = "+11 Spirit",
	["366"] = "+11 Stamina",
	["367"] = "+11 Strength",
	["368"] = "+12 Agility",
	["369"] = "+12 Intel",
	["370"] = "+12 Spirit",
	["371"] = "+12 Stamina",
	["372"] = "+12 Strength",
	["383"] = "+52 Armor",
	["384"] = "+56 Armor",
	["385"] = "+60 Armor",
	["386"] = "+16 Armor",
	["387"] = "+17 Armor",
	["388"] = "+18 Armor",
	["389"] = "+19 Armor",
	["403"] = "+13 Agility",
	["404"] = "+14 Agility",
	["405"] = "+13 Intel",
	["406"] = "+14 Intel",
	["407"] = "+13 Spirit",
	["408"] = "+14 Spirit",
	["409"] = "+13 Stamina",
	["410"] = "+13 Strength",
	["411"] = "+14 Stamina",
	["412"] = "+14 Strength",
	["423"] = "+1 Heal & SP",
	["424"] = "+2 Heal & SP",
	["425"] = "ZZOLD +4 Heal & SP",
	["426"] = "+5 Heal & SP",
	["427"] = "+6 Heal & SP",
	["428"] = "+7 Heal & SP",
	["429"] = "+8 Heal & SP",
	["430"] = "+9 Heal & SP",
	["431"] = "+11 Heal & SP",
	["432"] = "+12 Heal & SP",
	["433"] = "+11 Fire SP",
	["434"] = "+13 Fire SP",
	["435"] = "+14 Fire SP",
	["436"] = "+70 Crit",
	["437"] = "+11 Frost SP",
	["438"] = "+13 Frost SP",
	["439"] = "+14 Frost SP",
	["440"] = "+12 Heal",
	["441"] = "+20 Heal & +7 SP",
	["442"] = "+22 Heal",
	["443"] = "+11 Nature SP",
	["444"] = "+13 Nature SP",
	["445"] = "+14 Nature SP",
	["446"] = "+11 Shadow SP",
	["447"] = "+13 Shadow SP",
	["448"] = "+14 Shadow SP",
	["463"] = "Mithril Spike (16-20)",
	["464"] = "+4% Mount Speed",
	["483"] = "Sharpened (+6 Damage)",
	["484"] = "Weighted (+6 Damage)",
	["503"] = "Rockbiter 4",
	["504"] = "+80 Rockbiter",
	["523"] = "Flametongue 4",
	["524"] = "Frostbr& 3",
	["525"] = "Windfury 3",
	["543"] = "Flametongue Totem 3",
	["563"] = "Windfury Totem 2",
	["564"] = "Windfury Totem 3",
	["583"] = "+1 Agility / +1 Spirit",
	["584"] = "+1 Agility / +1 Intel",
	["585"] = "+1 Agility / +1 Stamina",
	["586"] = "+1 Agility / +1 Strength",
	["587"] = "+1 Intel / +1 Spirit",
	["588"] = "+1 Intel / +1 Stamina",
	["589"] = "+1 Intel / +1 Strength",
	["590"] = "+1 Spirit / +1 Stamina",
	["591"] = "+1 Spirit / +1 Strength",
	["592"] = "+1 Stamina/ +1 Strength",
	["603"] = "Crippling Poison II",
	["623"] = "Instant Poison IV",
	["624"] = "Instant Poison V",
	["625"] = "Instant Poison VI",
	["626"] = "Deadly Poison III",
	["627"] = "Deadly Poison IV",
	["643"] = "Mind-Numbing Poison III",
	["663"] = "Scope (+5 Damage)",
	["664"] = "Scope (+7 Damage)",
	["683"] = "Rockbiter 6",
	["684"] = "+15 Strength",
	["703"] = "Wound Poison",
	["704"] = "Wound Poison II",
	["705"] = "Wound Poison III",
	["706"] = "Wound Poison IV",
	["723"] = "+3 Intel",
	["724"] = "+3 Stamina",
	["743"] = "+2 Stealth",
	["744"] = "+20 Armor",
	["763"] = "+5 Shield Block",
	["783"] = "+10 Armor",
	["803"] = "Fiery Weapon",
	["804"] = "+10 Shadow Resist",
	["805"] = "+4 Weapon Damage",
	["823"] = "+3 Strength",
	["843"] = "+30 Mana",
	["844"] = "+2 Mining",
	["845"] = "+2 Herbalism",
	["846"] = "+2 Fishing",
	["847"] = "+1 All Stats",
	["848"] = "+30 Armor",
	["849"] = "+3 Agility",
	["850"] = "+35 Health",
	["851"] = "+5 Spirit",
	["852"] = "+5 Stamina",
	["853"] = "+6 Beastslaying",
	["854"] = "+6 Elemental Slayer",
	["855"] = "+5 Fire Resist",
	["856"] = "+5 Strength",
	["857"] = "+50 Mana",
	["863"] = "+10 Shield Block",
	["864"] = "+4 Weapon Damage",
	["865"] = "+5 Skinning",
	["866"] = "+2 All Stats",
	["883"] = "+15 Agility",
	["884"] = "+50 Armor",
	["903"] = "+3 All Resists",
	["904"] = "+5 Agility",
	["905"] = "+5 Intel",
	["906"] = "+5 Mining",
	["907"] = "+7 Spirit",
	["908"] = "+50 Health",
	["909"] = "+5 Herbalism",
	["910"] = "Increased Stealth",
	["911"] = "Minor Speed Increase",
	["912"] = "Demonslaying",
	["913"] = "+65 Mana",
	["923"] = "+5 Defense",
	["924"] = "+2 Defense",
	["925"] = "+3 Defense",
	["926"] = "+8 Frost Resist",
	["927"] = "+7 Strength",
	["928"] = "+3 All Stats",
	["929"] = "+7 Stamina",
	["930"] = "+2% Mount Speed",
	["931"] = "+10 Haste",
	["943"] = "+3 Weapon Damage",
	["963"] = "+7 Weapon Damage",
	["983"] = "+16 Agility",
	["1003"] = "Venomhide Poison",
	["1023"] = "Feedback 1",
	["1043"] = "+16 Strength",
	["1044"] = "+17 Strength",
	["1045"] = "+18 Strength",
	["1046"] = "+19 Strength",
	["1047"] = "+20 Strength",
	["1048"] = "+21 Strength",
	["1049"] = "+22 Strength",
	["1050"] = "+23 Strength",
	["1051"] = "+24 Strength",
	["1052"] = "+25 Strength",
	["1053"] = "+26 Strength",
	["1054"] = "+27 Strength",
	["1055"] = "+28 Strength",
	["1056"] = "+29 Strength",
	["1057"] = "+30 Strength",
	["1058"] = "+31 Strength",
	["1059"] = "+32 Strength",
	["1060"] = "+33 Strength",
	["1061"] = "+34 Strength",
	["1062"] = "+35 Strength",
	["1063"] = "+36 Strength",
	["1064"] = "+37 Strength",
	["1065"] = "+38 Strength",
	["1066"] = "+39 Strength",
	["1067"] = "+40 Strength",
	["1068"] = "+15 Stamina",
	["1069"] = "+16 Stamina",
	["1070"] = "+17 Stamina",
	["1071"] = "+18 Stamina",
	["1072"] = "+19 Stamina",
	["1073"] = "+20 Stamina",
	["1074"] = "+21 Stamina",
	["1075"] = "+22 Stamina",
	["1076"] = "+23 Stamina",
	["1077"] = "+24 Stamina",
	["1078"] = "+25 Stamina",
	["1079"] = "+26 Stamina",
	["1080"] = "+27 Stamina",
	["1081"] = "+28 Stamina",
	["1082"] = "+29 Stamina",
	["1083"] = "+30 Stamina",
	["1084"] = "+31 Stamina",
	["1085"] = "+32 Stamina",
	["1086"] = "+33 Stamina",
	["1087"] = "+34 Stamina",
	["1088"] = "+35 Stamina",
	["1089"] = "+36 Stamina",
	["1090"] = "+37 Stamina",
	["1091"] = "+38 Stamina",
	["1092"] = "+39 Stamina",
	["1093"] = "+40 Stamina",
	["1094"] = "+17 Agility",
	["1095"] = "+18 Agility",
	["1096"] = "+19 Agility",
	["1097"] = "+20 Agility",
	["1098"] = "+21 Agility",
	["1099"] = "+22 Agility",
	["1100"] = "+23 Agility",
	["1101"] = "+24 Agility",
	["1102"] = "+25 Agility",
	["1103"] = "+26 Agility",
	["1104"] = "+27 Agility",
	["1105"] = "+28 Agility",
	["1106"] = "+29 Agility",
	["1107"] = "+30 Agility",
	["1108"] = "+31 Agility",
	["1109"] = "+32 Agility",
	["1110"] = "+33 Agility",
	["1111"] = "+34 Agility",
	["1112"] = "+35 Agility",
	["1113"] = "+36 Agility",
	["1114"] = "+37 Agility",
	["1115"] = "+38 Agility",
	["1116"] = "+39 Agility",
	["1117"] = "+40 Agility",
	["1118"] = "+15 Intel",
	["1119"] = "+16 Intel",
	["1120"] = "+17 Intel",
	["1121"] = "+18 Intel",
	["1122"] = "+19 Intel",
	["1123"] = "+20 Intel",
	["1124"] = "+21 Intel",
	["1125"] = "+22 Intel",
	["1126"] = "+23 Intel",
	["1127"] = "+24 Intel",
	["1128"] = "+25 Intel",
	["1129"] = "+26 Intel",
	["1130"] = "+27 Intel",
	["1131"] = "+28 Intel",
	["1132"] = "+29 Intel",
	["1133"] = "+30 Intel",
	["1134"] = "+31 Intel",
	["1135"] = "+32 Intel",
	["1136"] = "+33 Intel",
	["1137"] = "+34 Intel",
	["1138"] = "+35 Intel",
	["1139"] = "+36 Intel",
	["1140"] = "+37 Intel",
	["1141"] = "+38 Intel",
	["1142"] = "+39 Intel",
	["1143"] = "+40 Intel",
	["1144"] = "+15 Spirit",
	["1145"] = "+16 Spirit",
	["1146"] = "+17 Spirit",
	["1147"] = "+18 Spirit",
	["1148"] = "+19 Spirit",
	["1149"] = "+20 Spirit",
	["1150"] = "+21 Spirit",
	["1151"] = "+22 Spirit",
	["1152"] = "+23 Spirit",
	["1153"] = "+24 Spirit",
	["1154"] = "+25 Spirit",
	["1155"] = "+26 Spirit",
	["1156"] = "+27 Spirit",
	["1157"] = "+28 Spirit",
	["1158"] = "+29 Spirit",
	["1159"] = "+30 Spirit",
	["1160"] = "+31 Spirit",
	["1161"] = "+32 Spirit",
	["1162"] = "+33 Spirit",
	["1163"] = "+34 Spirit",
	["1164"] = "+36 Spirit",
	["1165"] = "+37 Spirit",
	["1166"] = "+38 Spirit",
	["1167"] = "+39 Spirit",
	["1168"] = "+40 Spirit",
	["1183"] = "+35 Spirit",
	["1203"] = "+41 Strength",
	["1204"] = "+42 Strength",
	["1205"] = "+43 Strength",
	["1206"] = "+44 Strength",
	["1207"] = "+45 Strength",
	["1208"] = "+46 Strength",
	["1209"] = "+41 Stamina",
	["1210"] = "+42 Stamina",
	["1211"] = "+43 Stamina",
	["1212"] = "+44 Stamina",
	["1213"] = "+45 Stamina",
	["1214"] = "+46 Stamina",
	["1215"] = "+41 Agility",
	["1216"] = "+42 Agility",
	["1217"] = "+43 Agility",
	["1218"] = "+44 Agility",
	["1219"] = "+45 Agility",
	["1220"] = "+46 Agility",
	["1221"] = "+41 Intel",
	["1222"] = "+42 Intel",
	["1223"] = "+43 Intel",
	["1224"] = "+44 Intel",
	["1225"] = "+45 Intel",
	["1226"] = "+46 Intel",
	["1227"] = "+41 Spirit",
	["1228"] = "+42 Spirit",
	["1229"] = "+43 Spirit",
	["1230"] = "+44 Spirit",
	["1231"] = "+45 Spirit",
	["1232"] = "+46 Spirit",
	["1243"] = "+1 Arcane Resist",
	["1244"] = "+2 Arcane Resist",
	["1245"] = "+3 Arcane Resist",
	["1246"] = "+4 Arcane Resist",
	["1247"] = "+5 Arcane Resist",
	["1248"] = "+6 Arcane Resist",
	["1249"] = "+7 Arcane Resist",
	["1250"] = "+8 Arcane Resist",
	["1251"] = "+9 Arcane Resist",
	["1252"] = "+10 Arcane Resist",
	["1253"] = "+11 Arcane Resist",
	["1254"] = "+12 Arcane Resist",
	["1255"] = "+13 Arcane Resist",
	["1256"] = "+14 Arcane Resist",
	["1257"] = "+15 Arcane Resist",
	["1258"] = "+16 Arcane Resist",
	["1259"] = "+17 Arcane Resist",
	["1260"] = "+18 Arcane Resist",
	["1261"] = "+19 Arcane Resist",
	["1262"] = "+20 Arcane Resist",
	["1263"] = "+21 Arcane Resist",
	["1264"] = "+22 Arcane Resist",
	["1265"] = "+23 Arcane Resist",
	["1266"] = "+24 Arcane Resist",
	["1267"] = "+25 Arcane Resist",
	["1268"] = "+26 Arcane Resist",
	["1269"] = "+27 Arcane Resist",
	["1270"] = "+28 Arcane Resist",
	["1271"] = "+29 Arcane Resist",
	["1272"] = "+30 Arcane Resist",
	["1273"] = "+31 Arcane Resist",
	["1274"] = "+32 Arcane Resist",
	["1275"] = "+33 Arcane Resist",
	["1276"] = "+34 Arcane Resist",
	["1277"] = "+35 Arcane Resist",
	["1278"] = "+36 Arcane Resist",
	["1279"] = "+37 Arcane Resist",
	["1280"] = "+38 Arcane Resist",
	["1281"] = "+39 Arcane Resist",
	["1282"] = "+40 Arcane Resist",
	["1283"] = "+41 Arcane Resist",
	["1284"] = "+42 Arcane Resist",
	["1285"] = "+43 Arcane Resist",
	["1286"] = "+44 Arcane Resist",
	["1287"] = "+45 Arcane Resist",
	["1288"] = "+46 Arcane Resist",
	["1289"] = "+1 Frost Resist",
	["1290"] = "+2 Frost Resist",
	["1291"] = "+3 Frost Resist",
	["1292"] = "+4 Frost Resist",
	["1293"] = "+5 Frost Resist",
	["1294"] = "+6 Frost Resist",
	["1295"] = "+7 Frost Resist",
	["1296"] = "+8 Frost Resist",
	["1297"] = "+9 Frost Resist",
	["1298"] = "+10 Frost Resist",
	["1299"] = "+11 Frost Resist",
	["1300"] = "+12 Frost Resist",
	["1301"] = "+13 Frost Resist",
	["1302"] = "+14 Frost Resist",
	["1303"] = "+15 Frost Resist",
	["1304"] = "+16 Frost Resist",
	["1305"] = "+17 Frost Resist",
	["1306"] = "+18 Frost Resist",
	["1307"] = "+19 Frost Resist",
	["1308"] = "+20 Frost Resist",
	["1309"] = "+21 Frost Resist",
	["1310"] = "+22 Frost Resist",
	["1311"] = "+23 Frost Resist",
	["1312"] = "+24 Frost Resist",
	["1313"] = "+25 Frost Resist",
	["1314"] = "+26 Frost Resist",
	["1315"] = "+27 Frost Resist",
	["1316"] = "+28 Frost Resist",
	["1317"] = "+29 Frost Resist",
	["1318"] = "+30 Frost Resist",
	["1319"] = "+31 Frost Resist",
	["1320"] = "+32 Frost Resist",
	["1321"] = "+33 Frost Resist",
	["1322"] = "+34 Frost Resist",
	["1323"] = "+35 Frost Resist",
	["1324"] = "+36 Frost Resist",
	["1325"] = "+37 Frost Resist",
	["1326"] = "+38 Frost Resist",
	["1327"] = "+39 Frost Resist",
	["1328"] = "+40 Frost Resist",
	["1329"] = "+41 Frost Resist",
	["1330"] = "+42 Frost Resist",
	["1331"] = "+43 Frost Resist",
	["1332"] = "+44 Frost Resist",
	["1333"] = "+45 Frost Resist",
	["1334"] = "+46 Frost Resist",
	["1335"] = "+1 Fire Resist",
	["1336"] = "+2 Fire Resist",
	["1337"] = "+3 Fire Resist",
	["1338"] = "+4 Fire Resist",
	["1339"] = "+5 Fire Resist",
	["1340"] = "+6 Fire Resist",
	["1341"] = "+7 Fire Resist",
	["1342"] = "+8 Fire Resist",
	["1343"] = "+9 Fire Resist",
	["1344"] = "+10 Fire Resist",
	["1345"] = "+11 Fire Resist",
	["1346"] = "+12 Fire Resist",
	["1347"] = "+13 Fire Resist",
	["1348"] = "+14 Fire Resist",
	["1349"] = "+15 Fire Resist",
	["1350"] = "+16 Fire Resist",
	["1351"] = "+17 Fire Resist",
	["1352"] = "+18 Fire Resist",
	["1353"] = "+19 Fire Resist",
	["1354"] = "+20 Fire Resist",
	["1355"] = "+21 Fire Resist",
	["1356"] = "+22 Fire Resist",
	["1357"] = "+23 Fire Resist",
	["1358"] = "+24 Fire Resist",
	["1359"] = "+25 Fire Resist",
	["1360"] = "+26 Fire Resist",
	["1361"] = "+27 Fire Resist",
	["1362"] = "+28 Fire Resist",
	["1363"] = "+29 Fire Resist",
	["1364"] = "+30 Fire Resist",
	["1365"] = "+31 Fire Resist",
	["1366"] = "+32 Fire Resist",
	["1367"] = "+33 Fire Resist",
	["1368"] = "+34 Fire Resist",
	["1369"] = "+35 Fire Resist",
	["1370"] = "+36 Fire Resist",
	["1371"] = "+37 Fire Resist",
	["1372"] = "+38 Fire Resist",
	["1373"] = "+39 Fire Resist",
	["1374"] = "+40 Fire Resist",
	["1375"] = "+41 Fire Resist",
	["1376"] = "+42 Fire Resist",
	["1377"] = "+43 Fire Resist",
	["1378"] = "+44 Fire Resist",
	["1379"] = "+45 Fire Resist",
	["1380"] = "+46 Fire Resist",
	["1381"] = "+1 Nature Resist",
	["1382"] = "+2 Nature Resist",
	["1383"] = "+3 Nature Resist",
	["1384"] = "+4 Nature Resist",
	["1385"] = "+5 Nature Resist",
	["1386"] = "+6 Nature Resist",
	["1387"] = "+7 Nature Resist",
	["1388"] = "+8 Nature Resist",
	["1389"] = "+9 Nature Resist",
	["1390"] = "+10 Nature Resist",
	["1391"] = "+11 Nature Resist",
	["1392"] = "+12 Nature Resist",
	["1393"] = "+13 Nature Resist",
	["1394"] = "+14 Nature Resist",
	["1395"] = "+15 Nature Resist",
	["1396"] = "+16 Nature Resist",
	["1397"] = "+17 Nature Resist",
	["1398"] = "+18 Nature Resist",
	["1399"] = "+19 Nature Resist",
	["1400"] = "+20 Nature Resist",
	["1401"] = "+21 Nature Resist",
	["1402"] = "+22 Nature Resist",
	["1403"] = "+23 Nature Resist",
	["1404"] = "+24 Nature Resist",
	["1405"] = "+25 Nature Resist",
	["1406"] = "+26 Nature Resist",
	["1407"] = "+27 Nature Resist",
	["1408"] = "+28 Nature Resist",
	["1409"] = "+29 Nature Resist",
	["1410"] = "+30 Nature Resist",
	["1411"] = "+31 Nature Resist",
	["1412"] = "+32 Nature Resist",
	["1413"] = "+33 Nature Resist",
	["1414"] = "+34 Nature Resist",
	["1415"] = "+35 Nature Resist",
	["1416"] = "+36 Nature Resist",
	["1417"] = "+37 Nature Resist",
	["1418"] = "+38 Nature Resist",
	["1419"] = "+39 Nature Resist",
	["1420"] = "+40 Nature Resist",
	["1421"] = "+41 Nature Resist",
	["1422"] = "+42 Nature Resist",
	["1423"] = "+43 Nature Resist",
	["1424"] = "+44 Nature Resist",
	["1425"] = "+45 Nature Resist",
	["1426"] = "+46 Nature Resist",
	["1427"] = "+1 Shadow Resist",
	["1428"] = "+2 Shadow Resist",
	["1429"] = "+3 Shadow Resist",
	["1430"] = "+4 Shadow Resist",
	["1431"] = "+5 Shadow Resist",
	["1432"] = "+6 Shadow Resist",
	["1433"] = "+7 Shadow Resist",
	["1434"] = "+8 Shadow Resist",
	["1435"] = "+9 Shadow Resist",
	["1436"] = "+10 Shadow Resist",
	["1437"] = "+11 Shadow Resist",
	["1438"] = "+12 Shadow Resist",
	["1439"] = "+13 Shadow Resist",
	["1440"] = "+14 Shadow Resist",
	["1441"] = "+15 Shadow Resist",
	["1442"] = "+16 Shadow Resist",
	["1443"] = "+17 Shadow Resist",
	["1444"] = "+18 Shadow Resist",
	["1445"] = "+19 Shadow Resist",
	["1446"] = "+20 Shadow Resist",
	["1447"] = "+21 Shadow Resist",
	["1448"] = "+22 Shadow Resist",
	["1449"] = "+23 Shadow Resist",
	["1450"] = "+24 Shadow Resist",
	["1451"] = "+25 Shadow Resist",
	["1452"] = "+26 Resist Shadow",
	["1453"] = "+27 Shadow Resist",
	["1454"] = "+28 Shadow Resist",
	["1455"] = "+29 Shadow Resist",
	["1456"] = "+30 Shadow Resist",
	["1457"] = "+31 Shadow Resist",
	["1458"] = "+32 Shadow Resist",
	["1459"] = "+33 Shadow Resist",
	["1460"] = "+34 Shadow Resist",
	["1461"] = "+35 Shadow Resist",
	["1462"] = "+36 Shadow Resist",
	["1463"] = "+37 Shadow Resist",
	["1464"] = "+38 Shadow Resist",
	["1465"] = "+39 Shadow Resist",
	["1466"] = "+40 Shadow Resist",
	["1467"] = "+41 Shadow Resist",
	["1468"] = "+42 Shadow Resist",
	["1469"] = "+43 Shadow Resist",
	["1470"] = "+44 Shadow Resist",
	["1471"] = "+45 Shadow Resist",
	["1472"] = "+46 Shadow Resist",
	["1483"] = "+150 Mana",
	["1503"] = "+100 HP",
	["1504"] = "+125 Armor",
	["1505"] = "+20 Fire Resist",
	["1506"] = "+8 Strength",
	["1507"] = "+8 Stamina",
	["1508"] = "+8 Agility",
	["1509"] = "+8 Intel",
	["1510"] = "+8 Spirit",
	["1523"] = "+85/14 MANA/FR",
	["1524"] = "+75/14 HP/FR",
	["1525"] = "+110/14 AC/FR",
	["1526"] = "+10/14 STR/FR",
	["1527"] = "+10/14 STA/FR",
	["1528"] = "+10/14 AGI/FR",
	["1529"] = "+10/14 INT/FR",
	["1530"] = "+10/14 SPI/FR",
	["1531"] = "+10/10 STR/STA",
	["1532"] = "+10/10/110/15 STR/STA/AC/FR",
	["1543"] = "+10/10/100/15 INT/SPI/MANA/FR",
	["1563"] = "+2 AP",
	["1583"] = "+4 AP",
	["1584"] = "+6 AP",
	["1585"] = "+8 AP",
	["1586"] = "+10 AP",
	["1587"] = "+12 AP",
	["1588"] = "+14 AP",
	["1589"] = "+16 AP",
	["1590"] = "+18 AP",
	["1591"] = "+20 AP",
	["1592"] = "+22 AP",
	["1593"] = "+24 AP",
	["1594"] = "+26 AP",
	["1595"] = "+28 AP",
	["1596"] = "+30 AP",
	["1597"] = "+32 AP",
	["1598"] = "+34 AP",
	["1599"] = "+36 AP",
	["1600"] = "+38 AP",
	["1601"] = "+40 AP",
	["1602"] = "+42 AP",
	["1603"] = "+44 AP",
	["1604"] = "+46 AP",
	["1605"] = "+48 AP",
	["1606"] = "+50 AP",
	["1607"] = "+52 AP",
	["1608"] = "+54 AP",
	["1609"] = "+56 AP",
	["1610"] = "+58 AP",
	["1611"] = "+60 AP",
	["1612"] = "+62 AP",
	["1613"] = "+64 AP",
	["1614"] = "+66 AP",
	["1615"] = "+68 AP",
	["1616"] = "+70 AP",
	["1617"] = "+72 AP",
	["1618"] = "+74 AP",
	["1619"] = "+76 AP",
	["1620"] = "+78 AP",
	["1621"] = "+80 AP",
	["1622"] = "+82 AP",
	["1623"] = "+84 AP",
	["1624"] = "+86 AP",
	["1625"] = "+88 AP",
	["1626"] = "+90 AP",
	["1627"] = "+92 AP",
	["1643"] = "Sharpened (+8 Damage)",
	["1663"] = "Rockbiter 5",
	["1664"] = "Rockbiter 7",
	["1665"] = "Flametongue 5",
	["1666"] = "Flametongue 6",
	["1667"] = "Frostbr& 4",
	["1668"] = "Frostbr& 5",
	["1669"] = "Windfury 4",
	["1683"] = "Flametongue Totem 4",
	["1703"] = "Weighted (+8 Damage)",
	["1704"] = "Thorium Spike (20-30)",
	["1723"] = "Omen of Clarity",
	["1743"] = "MHTest02",
	["1763"] = "Cold Blood",
	["1783"] = "Windfury Totem 1",
	["1803"] = "Firestone 1",
	["1823"] = "Firestone 2",
	["1824"] = "Firestone 3",
	["1825"] = "Firestone 4",
	["1843"] = "Reinforced (+40 Armor)",
	["1863"] = "Feedback 2",
	["1864"] = "Feedback 3",
	["1865"] = "Feedback 4",
	["1866"] = "Feedback 5",
	["1883"] = "+7 Intel",
	["1884"] = "+9 Spirit",
	["1885"] = "+9 Strength",
	["1886"] = "+9 Stamina",
	["1887"] = "+7 Agility",
	["1888"] = "+5 All Resists",
	["1889"] = "+70 Armor",
	["1890"] = "+9 Spirit",
	["1891"] = "+4 All Stats",
	["1892"] = "+100 Health",
	["1893"] = "+100 Mana",
	["1894"] = "Icy Weapon",
	["1895"] = "+9 Damage",
	["1896"] = "+9 Weapon Damage",
	["1897"] = "+5 Weapon Damage",
	["1898"] = "Lifestealing",
	["1899"] = "Unholy Weapon",
	["1900"] = "Crusader",
	["1901"] = "+9 Intel",
	["1903"] = "+9 Spirit",
	["1904"] = "+9 Intel",
	["1923"] = "+3 Fire Resist",
	["1943"] = "+12 Defense",
	["1944"] = "+8 Defense",
	["1945"] = "+9 Defense",
	["1946"] = "+10 Defense",
	["1947"] = "+11 Defense",
	["1948"] = "+13 Defense",
	["1949"] = "+14 Defense",
	["1950"] = "+15 Defense",
	["1951"] = "+16 Defense",
	["1952"] = "+20 Defense",
	["1953"] = "+22 Defense",
	["1954"] = "+25 Defense",
	["1955"] = "+32 Defense",
	["1956"] = "+17 Defense",
	["1957"] = "+18 Defense",
	["1958"] = "+19 Defense",
	["1959"] = "+21 Defense",
	["1960"] = "+23 Defense",
	["1961"] = "+24 Defense",
	["1962"] = "+26 Defense",
	["1963"] = "+27 Defense",
	["1964"] = "+28 Defense",
	["1965"] = "+29 Defense",
	["1966"] = "+30 Defense",
	["1967"] = "+31 Defense",
	["1968"] = "+33 Defense",
	["1969"] = "+34 Defense",
	["1970"] = "+35 Defense",
	["1971"] = "+36 Defense",
	["1972"] = "+37 Defense",
	["1973"] = "+38 Defense",
	["1983"] = "+5 Block",
	["1984"] = "+10 Block",
	["1985"] = "+15 Block",
	["1986"] = "+20 Block",
	["1987"] = "BlockLevel 14",
	["1988"] = "BlockLevel 15",
	["1989"] = "BlockLevel 16",
	["1990"] = "BlockLevel 17",
	["1991"] = "BlockLevel 18",
	["1992"] = "BlockLevel 19",
	["1993"] = "BlockLevel 20",
	["1994"] = "BlockLevel 21",
	["1995"] = "BlockLevel 22",
	["1996"] = "BlockLevel 23",
	["1997"] = "BlockLevel 24",
	["1998"] = "BlockLevel 25",
	["1999"] = "BlockLevel 26",
	["2000"] = "BlockLevel 27",
	["2001"] = "BlockLevel 28",
	["2002"] = "BlockLevel 29",
	["2003"] = "BlockLevel 30",
	["2004"] = "BlockLevel 31",
	["2005"] = "BlockLevel 32",
	["2006"] = "BlockLevel 33",
	["2007"] = "BlockLevel 34",
	["2008"] = "BlockLevel 35",
	["2009"] = "BlockLevel 36",
	["2010"] = "BlockLevel 37",
	["2011"] = "BlockLevel 38",
	["2012"] = "BlockLevel 39",
	["2013"] = "BlockLevel 40",
	["2014"] = "BlockLevel 41",
	["2015"] = "BlockLevel 42",
	["2016"] = "BlockLevel 43",
	["2017"] = "BlockLevel 44",
	["2018"] = "BlockLevel 45",
	["2019"] = "BlockLevel 46",
	["2020"] = "BlockLevel 47",
	["2021"] = "BlockLevel 48",
	["2022"] = "BlockLevel 49",
	["2023"] = "BlockLevel 50",
	["2024"] = "BlockLevel 51",
	["2025"] = "BlockLevel 52",
	["2026"] = "BlockLevel 53",
	["2027"] = "BlockLevel 54",
	["2028"] = "BlockLevel 55",
	["2029"] = "BlockLevel 56",
	["2030"] = "BlockLevel 57",
	["2031"] = "BlockLevel 58",
	["2032"] = "BlockLevel 59",
	["2033"] = "BlockLevel 60",
	["2034"] = "BlockLevel 61",
	["2035"] = "BlockLevel 62",
	["2036"] = "BlockLevel 63",
	["2037"] = "BlockLevel 64",
	["2038"] = "BlockLevel 65",
	["2039"] = "BlockLevel 66",
	["2040"] = "+2 Ranged AP",
	["2041"] = "+5 Ranged AP",
	["2042"] = "+7 Ranged AP",
	["2043"] = "+10 Ranged AP",
	["2044"] = "+12 Ranged AP",
	["2045"] = "+14 Ranged AP",
	["2046"] = "+17 Ranged AP",
	["2047"] = "+19 Ranged AP",
	["2048"] = "+22 Ranged AP",
	["2049"] = "+24 Ranged AP",
	["2050"] = "+26 Ranged AP",
	["2051"] = "+29 Ranged AP",
	["2052"] = "+31 Ranged AP",
	["2053"] = "+34 Ranged AP",
	["2054"] = "+36 Ranged AP",
	["2055"] = "+38 Ranged AP",
	["2056"] = "+41 Ranged AP",
	["2057"] = "+43 Ranged AP",
	["2058"] = "+46 Ranged AP",
	["2059"] = "+48 Ranged AP",
	["2060"] = "+50 Ranged AP",
	["2061"] = "+53 Ranged AP",
	["2062"] = "+55 Ranged AP",
	["2063"] = "+58 Ranged AP",
	["2064"] = "+60 Ranged AP",
	["2065"] = "+62 Ranged AP",
	["2066"] = "+65 Ranged AP",
	["2067"] = "+67 Ranged AP",
	["2068"] = "+70 Ranged AP",
	["2069"] = "+72 Ranged AP",
	["2070"] = "+74 Ranged AP",
	["2071"] = "+77 Ranged AP",
	["2072"] = "+79 Ranged AP",
	["2073"] = "+82 Ranged AP",
	["2074"] = "+84 Ranged AP",
	["2075"] = "+86 Ranged AP",
	["2076"] = "+89 Ranged AP",
	["2077"] = "+91 Ranged AP",
	["2078"] = "+12 Dodge",
	["2079"] = "+1 Arcane SP",
	["2080"] = "+3 Arcane SP",
	["2081"] = "+4 Arcane SP",
	["2082"] = "+6 Arcane SP",
	["2083"] = "+7 Arcane SP",
	["2084"] = "+9 Arcane SP",
	["2085"] = "+10 Arcane SP",
	["2086"] = "+11 Arcane SP",
	["2087"] = "+13 Arcane SP",
	["2088"] = "+14 Arcane SP",
	["2089"] = "+16 Arcane SP",
	["2090"] = "+17 Arcane SP",
	["2091"] = "+19 Arcane SP",
	["2092"] = "+20 Arcane SP",
	["2093"] = "+21 Arcane SP",
	["2094"] = "+23 Arcane SP",
	["2095"] = "+24 Arcane SP",
	["2096"] = "+26 Arcane SP",
	["2097"] = "+27 Arcane SP",
	["2098"] = "+29 Arcane SP",
	["2099"] = "+30 Arcane SP",
	["2100"] = "+31 Arcane SP",
	["2101"] = "+33 Arcane SP",
	["2102"] = "+34 Arcane SP",
	["2103"] = "+36 Arcane SP",
	["2104"] = "+37 Arcane SP",
	["2105"] = "+39 Arcane SP",
	["2106"] = "+40 Arcane SP",
	["2107"] = "+41 Arcane SP",
	["2108"] = "+43 Arcane SP",
	["2109"] = "+44 Arcane SP",
	["2110"] = "+46 Arcane SP",
	["2111"] = "+47 Arcane SP",
	["2112"] = "+49 Arcane SP",
	["2113"] = "+50 Arcane SP",
	["2114"] = "+51 Arcane SP",
	["2115"] = "+53 Arcane SP",
	["2116"] = "+54 Arcane SP",
	["2117"] = "+1 Shadow SP",
	["2118"] = "+3 Shadow SP",
	["2119"] = "+4 Shadow SP",
	["2120"] = "+6 Shadow SP",
	["2121"] = "+7 Shadow SP",
	["2122"] = "+9 Shadow SP",
	["2123"] = "+10 Shadow SP",
	["2124"] = "+11 Shadow SP",
	["2125"] = "+13 Shadow SP",
	["2126"] = "+14 Shadow SP",
	["2127"] = "+16 Shadow SP",
	["2128"] = "+17 Shadow SP",
	["2129"] = "+19 Shadow SP",
	["2130"] = "+20 Shadow SP",
	["2131"] = "+21 Shadow SP",
	["2132"] = "+23 Shadow SP",
	["2133"] = "+24 Shadow SP",
	["2134"] = "+26 Shadow SP",
	["2135"] = "+27 Shadow SP",
	["2136"] = "+29 Shadow SP",
	["2137"] = "+30 Shadow SP",
	["2138"] = "+31 Shadow SP",
	["2139"] = "+33 Shadow SP",
	["2140"] = "+34 Shadow SP",
	["2141"] = "+36 Shadow SP",
	["2142"] = "+37 Shadow SP",
	["2143"] = "+39 Shadow SP",
	["2144"] = "+40 Shadow SP",
	["2145"] = "+41 Shadow SP",
	["2146"] = "+43 Shadow SP",
	["2147"] = "+44 Shadow SP",
	["2148"] = "+46 Shadow SP",
	["2149"] = "+47 Shadow SP",
	["2150"] = "+49 Shadow SP",
	["2151"] = "+50 Shadow SP",
	["2152"] = "+51 Shadow SP",
	["2153"] = "+53 Shadow SP",
	["2154"] = "+54 Shadow SP",
	["2155"] = "+1 Fire SP",
	["2156"] = "+3 Fire SP",
	["2157"] = "+4 Fire SP",
	["2158"] = "+6 Fire SP",
	["2159"] = "+7 Fire SP",
	["2160"] = "+9 Fire SP",
	["2161"] = "+10 Fire SP",
	["2162"] = "+11 Fire SP",
	["2163"] = "+13 Fire SP",
	["2164"] = "+14 Fire SP",
	["2165"] = "+16 Fire SP",
	["2166"] = "+17 Fire SP",
	["2167"] = "+19 Fire SP",
	["2168"] = "+20 Fire SP",
	["2169"] = "+21 Fire SP",
	["2170"] = "+23 Fire SP",
	["2171"] = "+24 Fire SP",
	["2172"] = "+26 Fire SP",
	["2173"] = "+27 Fire SP",
	["2174"] = "+29 Fire SP",
	["2175"] = "+30 Fire SP",
	["2176"] = "+31 Fire SP",
	["2177"] = "+33 Fire SP",
	["2178"] = "+34 Fire SP",
	["2179"] = "+36 Fire SP",
	["2180"] = "+37 Fire SP",
	["2181"] = "+39 Fire SP",
	["2182"] = "+40 Fire SP",
	["2183"] = "+41 Fire SP",
	["2184"] = "+43 Fire SP",
	["2185"] = "+44 Fire SP",
	["2186"] = "+46 Fire SP",
	["2187"] = "+47 Fire SP",
	["2188"] = "+49 Fire SP",
	["2189"] = "+50 Fire SP",
	["2190"] = "+51 Fire SP",
	["2191"] = "+53 Fire SP",
	["2192"] = "+54 Fire SP",
	["2193"] = "+1 Holy SP",
	["2194"] = "+3 Holy SP",
	["2195"] = "+4 Holy SP",
	["2196"] = "+6 Holy SP",
	["2197"] = "+7 Holy SP",
	["2198"] = "+9 Holy SP",
	["2199"] = "+10 Holy SP",
	["2200"] = "+11 Holy SP",
	["2201"] = "+13 Holy SP",
	["2202"] = "+14 Holy SP",
	["2203"] = "+16 Holy SP",
	["2204"] = "+17 Holy SP",
	["2205"] = "+19 Holy SP",
	["2206"] = "+20 Holy SP",
	["2207"] = "+21 Holy SP",
	["2208"] = "+23 Holy SP",
	["2209"] = "+24 Holy SP",
	["2210"] = "+26 Holy SP",
	["2211"] = "+27 Holy SP",
	["2212"] = "+29 Holy SP",
	["2213"] = "+30 Holy SP",
	["2214"] = "+31 Holy SP",
	["2215"] = "+33 Holy SP",
	["2216"] = "+34 Holy SP",
	["2217"] = "+36 Holy SP",
	["2218"] = "+37 Holy SP",
	["2219"] = "+39 Holy SP",
	["2220"] = "+40 Holy SP",
	["2221"] = "+41 Holy SP",
	["2222"] = "+43 Holy SP",
	["2223"] = "+44 Holy SP",
	["2224"] = "+46 Holy SP",
	["2225"] = "+47 Holy SP",
	["2226"] = "+49 Holy SP",
	["2227"] = "+50 Holy SP",
	["2228"] = "+51 Holy SP",
	["2229"] = "+53 Holy SP",
	["2230"] = "+54 Holy SP",
	["2231"] = "+1 Frost SP",
	["2232"] = "+3 Frost SP",
	["2233"] = "+4 Frost SP",
	["2234"] = "+6 Frost SP",
	["2235"] = "+7 Frost SP",
	["2236"] = "+9 Frost SP",
	["2237"] = "+10 Frost SP",
	["2238"] = "+11 Frost SP",
	["2239"] = "+13 Frost SP",
	["2240"] = "+14 Frost SP",
	["2241"] = "+16 Frost SP",
	["2242"] = "+17 Frost SP",
	["2243"] = "+19 Frost SP",
	["2244"] = "+20 Frost SP",
	["2245"] = "+21 Frost SP",
	["2246"] = "+23 Frost SP",
	["2247"] = "+24 Frost SP",
	["2248"] = "+26 Frost SP",
	["2249"] = "+27 Frost SP",
	["2250"] = "+29 Frost SP",
	["2251"] = "+30 Frost SP",
	["2252"] = "+31 Frost SP",
	["2253"] = "+33 Frost SP",
	["2254"] = "+34 Frost SP",
	["2255"] = "+36 Frost SP",
	["2256"] = "+37 Frost SP",
	["2257"] = "+39 Frost SP",
	["2258"] = "+40 Frost SP",
	["2259"] = "+41 Frost SP",
	["2260"] = "+43 Frost SP",
	["2261"] = "+44 Frost SP",
	["2262"] = "+46 Frost SP",
	["2263"] = "+47 Frost SP",
	["2264"] = "+49 Frost SP",
	["2265"] = "+50 Frost SP",
	["2266"] = "+51 Frost SP",
	["2267"] = "+53 Frost SP",
	["2268"] = "+54 Frost SP",
	["2269"] = "+1 Nature SP",
	["2270"] = "+3 Nature SP",
	["2271"] = "+4 Nature SP",
	["2272"] = "+6 Nature SP",
	["2273"] = "+7 Nature SP",
	["2274"] = "+9 Nature SP",
	["2275"] = "+10 Nature SP",
	["2276"] = "+11 Nature SP",
	["2277"] = "+13 Nature SP",
	["2278"] = "+14 Nature SP",
	["2279"] = "+16 Nature SP",
	["2280"] = "+17 Nature SP",
	["2281"] = "+19 Nature SP",
	["2282"] = "+20 Nature SP",
	["2283"] = "+21 Nature SP",
	["2284"] = "+23 Nature SP",
	["2285"] = "+24 Nature SP",
	["2286"] = "+26 Nature SP",
	["2287"] = "+27 Nature SP",
	["2288"] = "+29 Nature SP",
	["2289"] = "+30 Nature SP",
	["2290"] = "+31 Nature SP",
	["2291"] = "+33 Nature SP",
	["2292"] = "+34 Nature SP",
	["2293"] = "+36 Nature SP",
	["2294"] = "+37 Nature SP",
	["2295"] = "+39 Nature SP",
	["2296"] = "+40 Nature SP",
	["2297"] = "+41 Nature SP",
	["2298"] = "+43 Nature SP",
	["2299"] = "+44 Nature SP",
	["2300"] = "+46 Nature SP",
	["2301"] = "+47 Nature SP",
	["2302"] = "+49 Nature SP",
	["2303"] = "+50 Nature SP",
	["2304"] = "+51 Nature SP",
	["2305"] = "+53 Nature SP",
	["2306"] = "+54 Nature SP",
	["2307"] = "+2 Heal & +1 SP",
	["2308"] = "+4 Heal & +2 SP",
	["2309"] = "+7 Heal & +3 SP",
	["2310"] = "+9 Heal & +3 SP",
	["2311"] = "+11 Heal & +4 SP",
	["2312"] = "+13 Heal & +5 SP",
	["2313"] = "+15 Heal & +5 SP",
	["2314"] = "+18 Heal & +6 SP",
	["2315"] = "+20 Heal & +7 SP",
	["2316"] = "+22 Heal & +8 SP",
	["2317"] = "+24 Heal & +8 SP",
	["2318"] = "+26 Heal & +9 SP",
	["2319"] = "+29 Heal & +10 SP",
	["2320"] = "+31 Heal & +11 SP",
	["2321"] = "+33 Heal & +11 SP",
	["2322"] = "+35 Heal & +12 SP",
	["2323"] = "+37 Heal & +13 SP",
	["2324"] = "+40 Heal & +14 SP",
	["2325"] = "+42 Heal & +14 SP",
	["2326"] = "+44 Heal & +15 SP",
	["2327"] = "+46 Heal & +16 SP",
	["2328"] = "+48 Heal & +16 SP",
	["2329"] = "+51 Heal & +17 SP",
	["2330"] = "+53 Heal & +18 SP",
	["2331"] = "+55 Heal & +19 SP",
	["2332"] = "+57 Heal & +19 SP",
	["2333"] = "+59 Heal & +20 SP",
	["2334"] = "+62 Heal & +21 SP",
	["2335"] = "+64 Heal & +22 SP",
	["2336"] = "+66 Heal & +22 SP",
	["2337"] = "+68 Heal & +23 SP",
	["2338"] = "+70 Heal & +24 SP",
	["2339"] = "+73 Heal & +25 SP",
	["2340"] = "+75 Heal & +25 SP",
	["2341"] = "+77 Heal & +26 SP",
	["2342"] = "+79 Heal & +27 SP",
	["2343"] = "+81 Heal & +27 SP",
	["2344"] = "+84 Heal & +28 SP",
	["2363"] = "+1 MP5",
	["2364"] = "+1 MP5",
	["2365"] = "+1 MP5",
	["2366"] = "+2 MP5",
	["2367"] = "+2 MP5",
	["2368"] = "+2 MP5",
	["2369"] = "+3 MP5",
	["2370"] = "+3 MP5",
	["2371"] = "+4 MP5",
	["2372"] = "+4 MP5",
	["2373"] = "+4 MP5",
	["2374"] = "+5 MP5",
	["2375"] = "+5 MP5",
	["2376"] = "+6 MP5",
	["2377"] = "+6 MP5",
	["2378"] = "+6 MP5",
	["2379"] = "+7 MP5",
	["2380"] = "+7 MP5",
	["2381"] = "+8 MP5",
	["2382"] = "+8 MP5",
	["2383"] = "+8 MP5",
	["2384"] = "+9 MP5",
	["2385"] = "+9 MP5",
	["2386"] = "+10 MP5",
	["2387"] = "+10 MP5",
	["2388"] = "+10 MP5",
	["2389"] = "+11 MP5",
	["2390"] = "+11 MP5",
	["2391"] = "+12 MP5",
	["2392"] = "+12 MP5",
	["2393"] = "+12 MP5",
	["2394"] = "+13 MP5",
	["2395"] = "+13 MP5",
	["2396"] = "+14 MP5",
	["2397"] = "+14 MP5",
	["2398"] = "+14 MP5",
	["2399"] = "+15 MP5",
	["2400"] = "+15 MP5",
	["2401"] = "+1 health every 5 sec.",
	["2402"] = "+1 health every 5 sec.",
	["2403"] = "+1 health every 5 sec.",
	["2404"] = "+1 health every 5 sec.",
	["2405"] = "+1 health every 5 sec.",
	["2406"] = "+2 health every 5 sec.",
	["2407"] = "+2 health every 5 sec.",
	["2408"] = "+2 health every 5 sec.",
	["2409"] = "+2 health every 5 sec.",
	["2410"] = "+3 health every 5 sec.",
	["2411"] = "+3 health every 5 sec.",
	["2412"] = "+3 health every 5 sec.",
	["2413"] = "+3 health every 5 sec.",
	["2414"] = "+4 health every 5 sec.",
	["2415"] = "+4 health every 5 sec.",
	["2416"] = "+4 health every 5 sec.",
	["2417"] = "+4 health every 5 sec.",
	["2418"] = "+5 health every 5 sec.",
	["2419"] = "+5 health every 5 sec.",
	["2420"] = "+5 health every 5 sec.",
	["2421"] = "+5 health every 5 sec.",
	["2422"] = "+6 health every 5 sec.",
	["2423"] = "+6 health every 5 sec.",
	["2424"] = "+6 health every 5 sec.",
	["2425"] = "+6 health every 5 sec.",
	["2426"] = "+7 health every 5 sec.",
	["2427"] = "+7 health every 5 sec.",
	["2428"] = "+7 health every 5 sec.",
	["2429"] = "+7 health every 5 sec.",
	["2430"] = "+8 health every 5 sec.",
	["2431"] = "+8 health every 5 sec.",
	["2432"] = "+8 health every 5 sec.",
	["2433"] = "+8 health every 5 sec.",
	["2434"] = "+9 health every 5 sec.",
	["2435"] = "+9 health every 5 sec.",
	["2436"] = "+9 health every 5 sec.",
	["2437"] = "+9 health every 5 sec.",
	["2438"] = "+10 health every 5 sec.",
	["2443"] = "+7 Frost SP",
	["2463"] = "+7 Fire Resist",
	["2483"] = "+5 Fire Resist",
	["2484"] = "+5 Frost Resist",
	["2485"] = "+5 Arcane Resist",
	["2486"] = "+5 Nature Resist",
	["2487"] = "+5 Shadow Resist",
	["2488"] = "+5 All Resists",
	["2503"] = "+5 Defense",
	["2504"] = "+30 SP",
	["2505"] = "+55 Heal & +19 SP",
	["2506"] = "+28 Crit",
	["2523"] = "+30 Hit",
	["2543"] = "+10 Haste",
	["2544"] = "+8 Heal & SP",
	["2545"] = "+12 Dodge",
	["2563"] = "+15 Strength",
	["2564"] = "+15 Agility",
	["2565"] = "+4 MP5",
	["2566"] = "+24 Heal & +8 SP",
	["2567"] = "+20 Spirit",
	["2568"] = "+22 Intel",
	["2583"] = "+10 Defense/+10 Stamina/+15 Block Value",
	["2584"] = "+7 Defense, +10 Stamina, +24 Heal",
	["2585"] = "+28 AP/+12 Dodge",
	["2586"] = "+24 Ranged AP, +10 Stamina, +10 Hit",
	["2587"] = "+13 Heal & SP/+15 Intel",
	["2588"] = "+18 Heal & SP/+8 Spell Hit",
	["2589"] = "+18 Heal & SP/+10 Stamina",
	["2590"] = "+4 MP5/+10 Stamina/+24 Heal",
	["2591"] = "+10 Intel/+10 Stamina/+24 Heal",
	["2603"] = "Eternium Line",
	["2604"] = "+33 Heal & +11 SP",
	["2605"] = "+18 SP",
	["2606"] = "+30 AP",
	["2607"] = "+12 SP",
	["2608"] = "+13 SP",
	["2609"] = "+15 SP",
	["2610"] = "+14 SP",
	["2611"] = "REUSE R&om - 15 Spells All",
	["2612"] = "+18 SP",
	["2613"] = "+2% Threat",
	["2614"] = "+20 Shadow SP",
	["2615"] = "+20 Frost SP",
	["2616"] = "+20 Fire SP",
	["2617"] = "+30 Heal & +10 SP",
	["2618"] = "+15 Agility",
	["2619"] = "+15 Fire Resist",
	["2620"] = "+15 Nature Resist",
	["2621"] = "Subtlety",
	["2622"] = "+12 Dodge",
	["2623"] = "Minor Wizard Oil",
	["2624"] = "Minor Mana Oil",
	["2625"] = "Lesser Mana Oil",
	["2626"] = "Lesser Wizard Oil",
	["2627"] = "Wizard Oil",
	["2628"] = "Brilliant Wizard Oil",
	["2629"] = "Brilliant Mana Oil",
	["2630"] = "Deadly Poison V",
	["2631"] = "Feedback 6",
	["2632"] = "Rockbiter 8",
	["2633"] = "Rockbiter 9",
	["2634"] = "Flametongue 7",
	["2635"] = "Frostbr& 6",
	["2636"] = "Windfury 5",
	["2637"] = "Flametongue Totem 5",
	["2638"] = "Windfury Totem 4",
	["2639"] = "Windfury Totem 5",
	["2640"] = "Anesthetic Poison",
	["2641"] = "Instant Poison VII",
	["2642"] = "Deadly Poison VI",
	["2643"] = "Deadly Poison VII",
	["2644"] = "Wound Poison V",
	["2645"] = "Firestone 5",
	["2646"] = "+25 Agility",
	["2647"] = "+12 Strength",
	["2648"] = "+12 Defense",
	["2649"] = "+12 Stamina",
	["2650"] = "+15 SP",
	["2651"] = "+12 SP",
	["2652"] = "+20 Heal & +7 SP",
	["2653"] = "+18 Block Value",
	["2654"] = "+12 Intel",
	["2655"] = "+15 Shield Block",
	["2656"] = "Vitality",
	["2657"] = "+12 Agility",
	["2658"] = "Surefooted",
	["2659"] = "+150 Health",
	["2660"] = "+150 Mana",
	["2661"] = "+6 All Stats",
	["2662"] = "+120 Armor",
	["2663"] = "+7 Resist All",
	["2664"] = "+7 Resist All",
	["2665"] = "+35 Spirit",
	["2666"] = "+30 Intel",
	["2667"] = "Savagery",
	["2668"] = "+20 Strength",
	["2669"] = "+40 SP",
	["2670"] = "+35 Agility",
	["2671"] = "Sunfire",
	["2672"] = "Soulfrost",
	["2673"] = "Mongoose",
	["2674"] = "Spellsurge",
	["2675"] = "Battlemaster",
	["2676"] = "Superior Mana Oil",
	["2677"] = "Superior Mana Oil",
	["2678"] = "Superior Wizard Oil",
	["2679"] = "6 MP5",
	["2680"] = "+7 Resist All",
	["2681"] = "+10 Nature Resist",
	["2682"] = "+10 Frost Resist",
	["2683"] = "+10 Shadow Resist",
	["2684"] = "+100 AP vs Undead",
	["2685"] = "+60 SP vs Undead",
	["2686"] = "+8 Strength",
	["2687"] = "+8 Agility",
	["2688"] = "+8 Stamina",
	["2689"] = "+8 MP5",
	["2690"] = "+13 Heal & +5 SP",
	["2691"] = "+6 Strength",
	["2692"] = "+7 SP",
	["2693"] = "+6 Agility",
	["2694"] = "+6 Intel",
	["2695"] = "+6 Spell Crit",
	["2696"] = "+6 Defense",
	["2697"] = "+6 Hit",
	["2698"] = "+9 Stamina",
	["2699"] = "+6 Spirit",
	["2700"] = "+8 Spell Penetration",
	["2701"] = "+2 MP5",
	["2702"] = "+12 Agility (2 Red Gems)",
	["2703"] = "+4 Agility per different colored gem",
	["2704"] = "+12 Strength if 4 blue gems equipped",
	["2705"] = "+7 Heal +3 SP & +3 Intel",
	["2706"] = "+3 Defense & +4 Stamina",
	["2707"] = "+1 Mana every 5 Sec & +3 Intel",
	["2708"] = "+4 SP & +4 Stamina",
	["2709"] = "+7 Heal +3 SP & +1 MP5",
	["2710"] = "+3 Agility & +4 Stamina",
	["2711"] = "+3 Strength & +4 Stamina",
	["2712"] = "Sharpened (+12 Damage)",
	["2713"] = "Sharpened (+14 Crit & +12 Damage)",
	["2714"] = "Felsteel Spike (26-38)",
	["2715"] = "+31 Heal +11 SP & 5 MP5",
	["2716"] = "+16 Stamina & +100 Armor",
	["2717"] = "+26 AP & +14 Crit",
	["2718"] = "Lesser Rune of Warding",
	["2719"] = "Lesser Ward of Shielding",
	["2720"] = "Greater Ward of Shielding",
	["2721"] = "+15 SP & +14 Spell Crit",
	["2722"] = "Scope (+10 Damage)",
	["2723"] = "Scope (+12 Damage)",
	["2724"] = "Scope (+28 Crit)",
	["2725"] = "+8 Strength",
	["2726"] = "+8 Agility",
	["2727"] = "+18 Heal & +6 SP",
	["2728"] = "+9 SP",
	["2729"] = "+16 AP",
	["2730"] = "+8 Dodge",
	["2731"] = "+12 Stamina",
	["2732"] = "+8 Spirit",
	["2733"] = "+3 MP5",
	["2734"] = "+8 Intel",
	["2735"] = "+8 Crit",
	["2736"] = "+8 Spell Crit",
	["2737"] = "+8 Defense",
	["2738"] = "+4 Strength & +6 Stamina",
	["2739"] = "+4 Agility & +6 Stamina",
	["2740"] = "+5 SP & +6 Stamina",
	["2741"] = "+9 Heal +3 SP & +2 MP5",
	["2742"] = "+9 Heal +3 SP & +4 Intel",
	["2743"] = "+4 Defense & +6 Stamina",
	["2744"] = "+4 Intel & +2 MP5",
	["2745"] = "+46 Heal +16 SP & +15 Stamina",
	["2746"] = "+66 Heal +22 SP & +20 Stamina",
	["2747"] = "+25 SP & +15 Stamina",
	["2748"] = "+35 SP & +20 Stamina",
	["2749"] = "+12 Intel",
	["2750"] = "6 MP5",
	["2751"] = "+14 Crit",
	["2752"] = "+3 Crit & +3 Strength",
	["2753"] = "+4 Crit & +4 Strength",
	["2754"] = "+8 Parry",
	["2755"] = "+3 Hit & +3 Agility",
	["2756"] = "+4 Hit & +4 Agility",
	["2757"] = "+3 Crit & +4 Stamina",
	["2758"] = "+4 Crit & +6 Stamina",
	["2759"] = "+8 Resi",
	["2760"] = "+3 Spell Crit & +4 SP ",
	["2761"] = "+4 Spell Crit & +5 SP",
	["2762"] = "+3 Spell Crit & +4 Spell Penetration",
	["2763"] = "+4 Spell Crit & +5 Spell Penetration",
	["2764"] = "+8 Hit",
	["2765"] = "+10 Spell Penetration",
	["2766"] = "+8 Intel",
	["2767"] = "+8 Spell Hit",
	["2768"] = "+16 SP",
	["2769"] = "+11 Hit",
	["2770"] = "+7 SP",
	["2771"] = "+8 Spell Crit",
	["2772"] = "+14 Crit",
	["2773"] = "+16 Crit",
	["2774"] = "+11 Intel",
	["2775"] = "+11 Spell Crit",
	["2776"] = "+3 MP5",
	["2777"] = "+13 Spirit",
	["2778"] = "+13 Spell Penetration",
	["2779"] = "+16 Spirit",
	["2780"] = "+20 Spell Penetration",
	["2781"] = "+19 Stamina",
	["2782"] = "+10 Agility",
	["2783"] = "+14 Hit",
	["2784"] = "+12 Hit",
	["2785"] = "+13 Hit",
	["2786"] = "+7 Hit",
	["2787"] = "+8 Crit",
	["2788"] = "+9 Resi",
	["2789"] = "+15 Resi",
	["2790"] = "ZZOLDLesser Rune of Warding",
	["2791"] = "Greater Rune of Warding",
	["2792"] = "+8 Stamina",
	["2793"] = "+8 Defense",
	["2794"] = "+3 MP5",
	["2795"] = "Comfortable Insoles",
	["2796"] = "+15 Dodge",
	["2797"] = "+9 Dodge",
	["2798"] = "+$i Intel (+$n/+$f)",
	["2799"] = "+$i Stamina(+$n/+$f)",
	["2800"] = "+$i Armor (+$n/+$f)",
	["2801"] = "+8 Resi",
	["2802"] = "+$i Agility",
	["2803"] = "+$i Stamina",
	["2804"] = "+$i Intel",
	["2805"] = "+$i Strength",
	["2806"] = "+$i Spirit",
	["2807"] = "+$i Arcane Damage",
	["2808"] = "+$i Fire Damage",
	["2809"] = "+$i Nature Damage",
	["2810"] = "+$i Frost Damage",
	["2811"] = "+$i Shadow Damage",
	["2812"] = "+$i Heal",
	["2813"] = "+$i Defense",
	["2814"] = "+$i Health MP5",
	["2815"] = "+$i Dodge",
	["2816"] = "+$i MP5",
	["2817"] = "+$i Arcane Resist",
	["2818"] = "+$i Fire Resist",
	["2819"] = "+$i Frost Resist",
	["2820"] = "+$i Nature Resist",
	["2821"] = "+$i Shadow Resist",
	["2822"] = "+$i Spell Crit",
	["2823"] = "+$i Crit",
	["2824"] = "+$i SP",
	["2825"] = "+$i AP",
	["2826"] = "+$i Block",
	["2827"] = "+14 Spell Crit & 1% Spell Reflect",
	["2828"] = "Chance to Increase Spell Cast Speed",
	["2829"] = "+24 AP & Minor Speed",
	["2830"] = "+12 Crit& 5% Snare & Root Resist",
	["2831"] = "+18 Stamina& 5% Stun Resist",
	["2832"] = "+26 Heal +9 SP & 2% Reduced Threat",
	["2833"] = "+12 Defense& +Chance Restore Health",
	["2834"] = "+3 Melee Damage & Chance to Stun Target",
	["2835"] = "+12 Intel & +Chance Restore mana",
	["2836"] = "3 MP5",
	["2837"] = "+7 Spirit",
	["2838"] = "+7 Spell Crit",
	["2839"] = "+14 Spell Crit",
	["2840"] = "+21 Stamina",
	["2841"] = "+10 Stamina",
	["2842"] = "+8 Spirit",
	["2843"] = "+8 Spell Crit",
	["2844"] = "+8 Hit",
	["2845"] = "+11 Hit",
	["2846"] = "4 MP5",
	["2847"] = "4 MP5",
	["2848"] = "5 MP5",
	["2849"] = "+7 Dodge",
	["2850"] = "+13 Spell Crit",
	["2851"] = "+19 Stamina",
	["2852"] = "7 mana per 5 sec",
	["2853"] = "8 mana per 5 sec",
	["2854"] = "3 mana per 5 sec",
	["2855"] = "5 MP5",
	["2856"] = "+4 Resi",
	["2857"] = "+2 Crit",
	["2858"] = "+2 Crit",
	["2859"] = "+3 Resi",
	["2860"] = "+3 Hit",
	["2861"] = "+3 Defense",
	["2862"] = "+3 Resi",
	["2863"] = "+3 Intel",
	["2864"] = "+4 Spell Crit",
	["2865"] = "2 MP5",
	["2866"] = "+3 Spirit",
	["2867"] = "+2 Resi",
	["2868"] = "+6 Stamina",
	["2869"] = "+4 Intel",
	["2870"] = "+3 Parry",
	["2871"] = "+4 Dodge",
	["2872"] = "+9 Heal & +3 SP",
	["2873"] = "+4 Hit",
	["2874"] = "+4 Crit",
	["2875"] = "+3 Spell Crit",
	["2876"] = "+3 Dodge",
	["2877"] = "+4 Agility",
	["2878"] = "+4 Resi",
	["2879"] = "+3 Strength",
	["2880"] = "+3 Spell Hit",
	["2881"] = "1 MP5",
	["2882"] = "+6 Stamina",
	["2883"] = "+4 Stamina",
	["2884"] = "+2 Spell Crit",
	["2885"] = "+2 Crit",
	["2886"] = "+2 Hit",
	["2887"] = "+3 Crit",
	["2888"] = "+6 Block Value",
	["2889"] = "+5 SP",
	["2890"] = "+4 Spirit",
	["2891"] = "+10 Resi",
	["2892"] = "+4 Strength",
	["2893"] = "+3 Agility",
	["2894"] = "+7 Strength",
	["2895"] = "+4 Stamina",
	["2896"] = "+8 SP",
	["2897"] = "+3 Stamina, +4 Crit",
	["2898"] = "+3 Stamina, +4 Spell Crit",
	["2899"] = "+3 Stamina, +4 Crit",
	["2900"] = "+4 SP",
	["2901"] = "+2 SP",
	["2902"] = "+2 Crit",
	["2906"] = "+$i Stamina & +$i Intel",
	["2907"] = "+2 Parry",
	["2908"] = "+4 Spell Hit",
	["2909"] = "+2 Spell Hit",
	["2910"] = "+3 Heal & SP",
	["2911"] = "+10 Strength",
	["2912"] = "+12 SP",
	["2913"] = "+10 Crit",
	["2914"] = "+10 Spell Crit",
	["2915"] = "+5 Strength, +5 Crit",
	["2916"] = "+6 SP, +5 Spell Crit",
	["2917"] = "gem test enchantment",
	["2918"] = "+3 Stamina, +4 Crit",
	["2919"] = "+7 Strength",
	["2921"] = "+3 Stamina, +4 Crit",
	["2922"] = "+7 Strength",
	["2923"] = "+3 Stamina, +4 Spell Crit",
	["2924"] = "+8 SP",
	["2925"] = "+3 Stamina",
	["2926"] = "+2 Dodge",
	["2927"] = "+4 Strength",
	["2928"] = "+12 SP",
	["2929"] = "+2 Weapon Damage",
	["2930"] = "+20 Heal & +7 SP",
	["2931"] = "+4 All Stats",
	["2932"] = "+4 Defense",
	["2933"] = "+15 Resi",
	["2934"] = "+10 Spell Crit",
	["2935"] = "+15 Spell Hit",
	["2936"] = "+8 AP",
	["2937"] = "+20 SP",
	["2938"] = "+20 Spell Penetration",
	["2939"] = "Minor Speed & +6 Agility",
	["2940"] = "Minor Speed & +9 Stamina",
	["2941"] = "+2 Hit",
	["2942"] = "+6 Crit",
	["2943"] = "+14 AP",
	["2944"] = "+14 AP",
	["2945"] = "+20 AP",
	["2946"] = "+10 AP, +5 Crit",
	["2947"] = "+3 Resist All",
	["2948"] = "+4 Resist All",
	["2949"] = "+20 AP",
	["2950"] = "+10 Crit",
	["2951"] = "+4 Spell Crit",
	["2952"] = "+4 Crit",
	["2953"] = "+2 SP",
	["2954"] = "Weighted (+12 Damage)",
	["2955"] = "Weighted (+14 Crit & +12 Damage)",
	["2956"] = "+4 Strength",
	["2957"] = "+4 Agility",
	["2958"] = "+9 Heal & +3 SP",
	["2959"] = "+5 SP",
	["2960"] = "+8 AP",
	["2961"] = "+6 Stamina",
	["2962"] = "+4 Spirit",
	["2963"] = "+1 MP5",
	["2964"] = "+4 Intel",
	["2965"] = "+4 Crit",
	["2966"] = "+4 Hit",
	["2967"] = "+4 Spell Crit",
	["2968"] = "+4 Defense",
	["2969"] = "+20 AP & Minor Speed",
	["2970"] = "+12 SP & Minor Speed",
	["2971"] = "+12 AP",
	["2972"] = "+4 Block",
	["2973"] = "+6 AP",
	["2974"] = "+7 Heal +3 SP",
	["2975"] = "+5 Block Value",
	["2976"] = "+2 Defense",
	["2977"] = "+13 Dodge",
	["2978"] = "+15 Dodge & +10 Defense",
	["2979"] = "+29 Heal & +10 SP",
	["2980"] = "+33 Heal +11 SP & +4 MP5",
	["2981"] = "+15 Spell Power",
	["2982"] = "+18 Spell Power & +10 Spell Crit",
	["2983"] = "+26 AP",
	["2984"] = "+8 Shadow Resist",
	["2985"] = "+8 Fire Resist",
	["2986"] = "+30 AP & +10 Crit",
	["2987"] = "+8 Frost Resist",
	["2988"] = "+8 Nature Resist",
	["2989"] = "+8 Arcane Resist",
	["2990"] = "+13 Defense",
	["2991"] = "+15 Defense & +10 Dodge",
	["2992"] = "+5 MP5",
	["2993"] = "+6 MP5 & +22 Heal",
	["2994"] = "+13 Spell Crit",
	["2995"] = "+15 Spell Crit & +12 SP",
	["2996"] = "+13 Crit",
	["2997"] = "+15 Crit & +20 AP",
	["2998"] = "+7 All Resists",
	["2999"] = "+16 Defense & +17 Dodge",
	["3000"] = "+18 Stamina, +12 Dodge, & +12 Resi",
	["3001"] = "+35 Heal +12 SP & 7 MP5",
	["3002"] = "+22 Spell Power & +14 Spell Hit",
	["3003"] = "+34 AP & +16 Hit",
	["3004"] = "+18 Stamina & +20 Resi",
	["3005"] = "+20 Nature Resist",
	["3006"] = "+20 Arcane Resist",
	["3007"] = "+20 Fire Resist",
	["3008"] = "+20 Frost Resist",
	["3009"] = "+20 Shadow Resist",
	["3010"] = "+40 AP & +10 Crit",
	["3011"] = "+30 Stamina & +10 Agility",
	["3012"] = "+50 AP & +12 Crit",
	["3013"] = "+40 Stamina & +12 Agility",
	["3014"] = "Windfury Totem 5 (L70 Testing)",
	["3015"] = "+2 Strength",
	["3016"] = "+2 Intel",
	["3017"] = "+3 Block",
	["3018"] = "Rockbiter 9",
	["3019"] = "Rockbiter 9",
	["3020"] = "Rockbiter 9",
	["3021"] = "Rockbiter 1",
	["3022"] = "Rockbiter 1",
	["3023"] = "Rockbiter 1",
	["3024"] = "Rockbiter 2",
	["3025"] = "Rockbiter 2",
	["3026"] = "Rockbiter 2",
	["3027"] = "Rockbiter 3",
	["3028"] = "Rockbiter 3",
	["3029"] = "Rockbiter 3",
	["3030"] = "Rockbiter 4",
	["3031"] = "Rockbiter 4",
	["3032"] = "Rockbiter 4",
	["3033"] = "Rockbiter 5",
	["3034"] = "Rockbiter 5",
	["3035"] = "Rockbiter 5",
	["3036"] = "Rockbiter 6",
	["3037"] = "Rockbiter 6",
	["3038"] = "Rockbiter 6",
	["3039"] = "Rockbiter 7",
	["3040"] = "Rockbiter 7",
	["3041"] = "Rockbiter 7",
	["3042"] = "Rockbiter 8",
	["3043"] = "Rockbiter 8",
	["3044"] = "Rockbiter 8",
	["3045"] = "+5 Strength & +6 Stamina",
	["3046"] = "+11 Heal +4 SP & +4 Intel",
	["3047"] = "+6 Stamina & +5 Spell Crit",
	["3048"] = "+5 Agility & +6 Stamina",
	["3049"] = "+5 Crit & +2 MP5",
	["3050"] = "+6 SP & +4 Intel ",
	["3051"] = "+11 Heal +4 SP & +6 Stamina",
	["3052"] = "+10 AP & +4 Hit",
	["3053"] = "+5 Defense & +4 Dodge",
	["3054"] = "+6 SP & +6 Stamina",
	["3055"] = "+5 Agility & +4 Hit",
	["3056"] = "+5 Parry & +4 Defense",
	["3057"] = "+5 Strength & +4 Hit",
	["3058"] = "+5 Spell Crit & 2 MP5",
	["3059"] = "Spell Crit+5 & 2 MP5",
	["3060"] = "+5 Dodge & +6 Stamina",
	["3061"] = "+6 SP & +5 Spell Hit",
	["3062"] = "+6 Crit & +5 Dodge",
	["3063"] = "+5 Parry & +6 Stamina",
	["3064"] = "+5 Spirit & +9 Heal +3 SP",
	["3065"] = "+8 Strength",
	["3066"] = "+6 SP & +5 Spell Penetration",
	["3067"] = "+10 AP & +6 Stamina",
	["3068"] = "+5 Dodge & +4 Hit",
	["3069"] = "+11 Heal +4 SP & +4 Resi",
	["3070"] = "+8 AP & +5 Crit",
	["3071"] = "+5 Intel & +6 Stamina",
	["3072"] = "+5 Strength & +4 Crit",
	["3073"] = "+4 Agility & +5 Defense",
	["3074"] = "+4 Intel & +5 Spirit",
	["3075"] = "+5 Strength & +4 Defense",
	["3076"] = "+6 SP & +4 Spell Crit",
	["3077"] = "+5 Intel & 2 MP5",
	["3078"] = "+6 Stamina & +5 Defense",
	["3079"] = "+8 AP & +5 Resi",
	["3080"] = "+6 Stamina & +5 Resi",
	["3081"] = "+11 Heal +4 SP & +4 Spell Crit",
	["3082"] = "+5 Defense & 2 MP5",
	["3083"] = "+6 SP & +4 Spirit",
	["3084"] = "+5 Dodge & +4 Resi",
	["3085"] = "+6 Stamina & +5 Crit",
	["3086"] = "+11 Heal +4 SP & 2 MP5",
	["3087"] = "+5 Strength & +4 Resi",
	["3088"] = "+5 Spell Hit & +6 Stamina",
	["3089"] = "+5 Spell Hit & 2 MP5",
	["3090"] = "+5 Parry & +4 Resi",
	["3091"] = "+5 Spell Crit & +5 Spell Penetration",
	["3092"] = "+3 Crit",
	["3093"] = "+150 AP vs Undead & Demons",
	["3094"] = "+4 Expertise ",
	["3095"] = "+8 Resist All",
	["3096"] = "+17 Strength & +16 Intel",
	["3097"] = "+2 Spirit",
	["3098"] = "+4 Heal +2 SP",
	["3099"] = "+6 SP & +6 Stamina",
	["3100"] = "+11 Heal +4 SP & +6 Stamina",
	["3101"] = "+10 AP & +6 Stamina",
	["3102"] = "Poison",
	["3103"] = "+8 Strength",
	["3104"] = "+6 Spell Hit",
	["3105"] = "+8 Spell Hit",
	["3106"] = "+6 AP & +4 Stamina",
	["3107"] = "+8 AP & +6 Stamina",
	["3108"] = "+6 AP & +1 MP5",
	["3109"] = "+8 AP & +2 MP5",
	["3110"] = "+3 Spell Hit & +4 SP ",
	["3111"] = "+4 Spell Hit & +5 SP",
	["3112"] = "+4 Crit & +8 AP",
	["3113"] = "+3 Crit & +6 AP",
	["3114"] = "+4 AP",
	["3115"] = "+10 Strength",
	["3116"] = "+10 Agility",
	["3117"] = "+22 Heal & +8 SP",
	["3118"] = "+12 SP",
	["3119"] = "+20 AP",
	["3120"] = "+10 Dodge",
	["3121"] = "+10 Parry",
	["3122"] = "+15 Stamina",
	["3123"] = "+10 Spirit",
	["3124"] = "+4 MP5",
	["3125"] = "+13 Spell Penetration",
	["3126"] = "+10 Intel",
	["3127"] = "+10 Crit",
	["3128"] = "+10 Hit",
	["3129"] = "+10 Spell Crit",
	["3130"] = "+10 Defense",
	["3131"] = "+10 Resi",
	["3132"] = "+10 Spell Hit",
	["3133"] = "+5 Strength & +7 Stamina",
	["3134"] = "+5 Agility & +7 Stamina",
	["3135"] = "+10 AP & +7 Stamina",
	["3136"] = "+10 AP & +2 MP5",
	["3137"] = "+6 SP & +7 Stamina",
	["3138"] = "+11 Heal +4 SP & +2 MP5",
	["3139"] = "+5 Crit & +5 Strength",
	["3140"] = "+5 Spell Crit & +6 SP",
	["3141"] = "+11 Heal +4 SP & +5 Intel",
	["3142"] = "+5 Hit & +5 Agility",
	["3143"] = "+5 Spell Hit & +6 SP",
	["3144"] = "+5 Crit & +10 AP",
	["3145"] = "+5 Defense & +7 Stamina",
	["3146"] = "+5 Spell Crit & +6 Spell Penetration",
	["3147"] = "+5 Intel & +2 MP5",
	["3148"] = "+5 Crit & +7 Stamina",
	["3149"] = "+2 Agility",
	["3150"] = "+6 MP5",
	["3151"] = "+4 Heal +2 SP",
	["3152"] = "+2 Spell Crit",
	["3153"] = "+2 SP",
	["3154"] = "+12 Agility & 3% Increased CritDamage",
	["3155"] = "Chance to Increase Melee/Ranged Attack Speed ",
	["3156"] = "+8 AP & +6 Stamina",
	["3157"] = "+4 Intel & +6 Stamina",
	["3158"] = "+9 Heal +3 SP & +4 Spirit",
	["3159"] = "+8 AP & +4 Crit",
	["3160"] = "+5 SP & +4 Intel",
	["3161"] = "+4 Stamina & +4 Spell Crit",
	["3162"] = "+24 AP & 5% Stun Resist",
	["3163"] = "+14 SP & 5% Stun Resist",
	["3164"] = "+3 Stamina",
	["3197"] = "+20 AP",
	["3198"] = "+5 SP",
	["3199"] = "+170 Armor",
	["3200"] = "+4 Spirit & +9 Heal",
	["3201"] = "+7 Heal +3 SP & +3 Spirit",
	["3202"] = "+9 Heal +3 SP & +4 Spirit",
	["3204"] = "+3 Spell Crit",
	["3205"] = "+3 Crit",
	["3206"] = "+8 Agility",
	["3207"] = "+12 Strength",
	["3208"] = "+24 AP",
	["3209"] = "+12 Agility",
	["3210"] = "+14 SP",
	["3211"] = "+26 Heal & +9 SP",
	["3212"] = "+18 Stamina",
	["3213"] = "+5 MP5",
	["3214"] = "+12 Spirit",
	["3215"] = "+12 Resi",
	["3216"] = "+12 Intel",
	["3217"] = "+12 Spell Crit",
	["3218"] = "+12 Spell Hit",
	["3219"] = "+12 Hit",
	["3220"] = "+12 Crit",
	["3221"] = "+12 Defense",
	["3222"] = "+20 Agility",
	["3223"] = "Adamantite Weapon Chain",
	["3224"] = "+6 Agility",
	["3225"] = "Executioner",
	["3226"] = "+4 Resi & +6 Stamina",
	["3229"] = "+12 Resi",
	["3260"] = "+240 Armor",
	["3261"] = "+12 Spell Crit& 3% Increased CritDamage",
	["3262"] = "+15 Stamina",
	["3263"] = "+4 Crit",
	["3264"] = "+150 Armor, -10% Speed",
	["3265"] = "Blessed Weapon Coating",
	["3266"] = "Righteous Weapon Coating",
	["3267"] = "+4 Haste",
	["3268"] = "+15 Stamina",
	["3269"] = "Truesilver Line",
	["3270"] = "+8 Spell Haste",
	["3271"] = "+4 Spell Haste & +5 SP",
	["3272"] = "+4 Spell Haste & +6 Stamina",
	["3273"] = "Deathfrost",
	["3274"] = "+12 Defense & +10% Shield Block Value",
	["3275"] = "+14 SP & +2% Intel",
	["3280"] = "+4 Dodge & +6 Stamina",
	["3281"] = "+20 AP",
	["3282"] = "+12 SP",
	["3283"] = "+22 Heal & +8 SP",
	["3284"] = "+5 Resi & +7 Stamina",
	["3285"] = "+5 Spell Haste & +7 Stamina",
	["3286"] = "+5 Spell Haste & +6 SP",
	["3287"] = "+10 Spell Haste",
	["3289"] = "+10% Mount Speed",
	["3315"] = "+3% Mount Speed",
	["3318"] = "+11 Heal +4 SP & +5 Spirit",
	["3335"] = "+20 AP",
	["3336"] = "+10 Spell Crit",
	["3337"] = "+10 AP, +5 Crit",
	["3338"] = "+6 SP, +5 Spell Crit",
	["3339"] = "+12 SP",
	["3340"] = "+10 Crit",
	["3726"] = "+$i Haste",
}

local gemAttributes = {
	-- Red --
		-- Uncommon
	
		-- rare
	
		-- epic
    ["3118"] = "+12 SP",
	["3117"] = "+22 Heal & +8 SP",
	
	-- Yellow --
		-- Uncommon
	
		-- rare
	
		-- epic
	["3286"] = "+5 Sp.Haste & +6 SP",
	
	-- Blue --
		-- Uncommon
	
		-- rare
	
		-- epic
		
		
	-- Orange --
		-- Uncommon
	
		-- rare
	["3081"] = "+11 Heal +4 SP & +4 Spell Crit",
		-- epic
	["3141"] = "+11 Heal +4 SP & +5 Intel",
	
	-- Green --
		-- Uncommon
	
		-- rare
	
		-- epic
		
		
	-- Purple --
		-- Uncommon
	["3201"] = "+7 Heal +3 SP & +3 Spirit",
		-- rare
	["3202"] = "+9 Heal +3 SP & +4 Spirit",
		-- epic
	["3137"] = "+5 SP & +7 Stamina",
	["3138"] = "+11 Heal +4 SP & +2 MP5",
	
	-- Meta --
	 -- Earthstorm
	["2835"] = "+12 Intel & +Chance Restore mana",
	["3274"] = "+12 Defense & +10% Shield Block",
	["2831"] = "+18 Stamina & 5% Stun Resist",
	["2833"] = "+12 Defense & +Chance Restore Health",
	["3154"] = "+12 Agility & +3% Crit Damage",
	["2834"] = "+3 Melee & Chance to stun",
	["3163"] = "+14 Spell Damage & 5% Stun Resist",
	["2832"] = "+26 Heal +9 SP & 2% Reduced Threat",
	 -- Skyfire
	["2829"] = "+24 AP & +Minor Run Speed",
	["3162"] = "+24 AP & 5% Stun Resist",
	["3155"] = "+Chance Attack Speed Increase",
	["2830"] = "+12 Crit & 5% Snare and Root Resist",
	["3275"] = "+14 SP & +2 Intel",
	["2970"] = "+12 SP & +Minor Run Speed",
	["3261"] = "+12 Spell Crit & +3% Crit Damage",
	["2828"] = "+Chance Spell Cast Speed Increase",
	["2827"] = "+14 Spell Crit & 1% Spell Reflect",
}

local gemImagesByID = {
	-- Red --
		-- Uncommon
	-- "Interface\\Icons\\inv_misc_gem_bloodgem_02",
		-- rare
	-- "Interface\\Icons\\inv_jewelcrafting_livingruby_03",
		-- epic
    ["3118"] = "Interface\\Icons\\INV_Jewelcrafting_CrimsonSpinel_02",
	["3117"] = "Interface\\Icons\\INV_Jewelcrafting_CrimsonSpinel_02",
	
	-- Yellow --
		-- Uncommon
	-- "Interface\\Icons\\inv_misc_gem_goldendraenite_02",
		-- rare
	-- "Interface\\Icons\\inv_jewelcrafting_dawnstone_03",
		-- epic
	["3286"] = "Interface\\Icons\\inv_jewelcrafting_lionseye_02",
	
	-- Blue --
		-- Uncommon
	-- "Interface\\Icons\\inv_misc_gem_azuredraenite_02",
		-- rare
	-- "Interface\\Icons\\inv_jewelcrafting_starofelune_03",
		-- epic
	-- "Interface\\Icons\\inv_jewelcrafting_empyreansapphire_02",
	
	-- Orange --
		-- Uncommon
	-- "Interface\\Icons\\inv_misc_gem_flamespessarite_02",
		-- rare
	["3081"] = "Interface\\Icons\\inv_jewelcrafting_nobletopaz_03",
		-- epic
	["3141"] = "Interface\\Icons\\inv_jewelcrafting_pyrestone_02",
	
	-- Green --
		-- Uncommon
	-- "Interface\\Icons\\inv_misc_gem_deepperidot_02",
		-- rare
	-- "Interface\\Icons\\inv_jewelcrafting_talasite_03",
		-- epic
	-- "Interface\\Icons\\inv_jewelcrafting_seasprayemerald_02",
	
	-- Purple --
		-- Uncommon
	["3201"] = "Interface\\Icons\\inv_misc_gem_pearl_08",
	-- "Interface\\Icons\\inv_misc_gem_ebondraenite_02",
		-- rare
	["3202"] = "Interface\\Icons\\inv_misc_gem_pearl_07", -- gem pearl
	-- "Interface\\Icons\\inv_jewelcrafting_nightseye_03",
		-- epic
	["3138"] = "Interface\\Icons\\inv_jewelcrafting_shadowsongamethyst_02",
	["3137"] = "Interface\\Icons\\inv_jewelcrafting_shadowsongamethyst_02",
	
	-- Meta --
	 -- Earthstorm
	["2835"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["3274"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["2831"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["2833"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["3154"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["2834"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["3163"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	["2832"] = "Interface\\Icons\\inv_misc_gem_diamond_06",
	 -- Skyfire
	["2829"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["3162"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["3155"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["2830"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["3275"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["2970"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["3261"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["2828"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
	["2827"] = "Interface\\Icons\\inv_misc_gem_diamond_07",
}

local enchantTextPositions = {
	-- left
    Head = { point = "LEFT", relativePoint = "RIGHT", x = 4, y = 25 },
	Shoulder = { point = "LEFT", relativePoint = "RIGHT", x = 7, y = 25 },
	Back = { point = "LEFT", relativePoint = "RIGHT", x = 17, y = 25 },
	Chest = { point = "LEFT", relativePoint = "RIGHT", x = 4, y = 25 },
	Wrist = { point = "LEFT", relativePoint = "RIGHT", x = -35, y = -15 },
	
	
	-- Right
	Hands = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = -7 },
	Legs = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = -5 },
	Feet = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = -5 },
	Finger0 = { point = "RIGHT", relativePoint = "LEFT", x = -18, y = 10 },
	Finger1 = { point = "RIGHT", relativePoint = "LEFT", x = -18, y = 10 },
    
		
	-- Bottom
	MainHand = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = -10 },
	SecondaryHand = { point = "LEFT", relativePoint = "RIGHT", x = -35, y = -15 },
	Ranged = { point = "TOP", relativePoint = "TOP", x = 67, y = -5 },
	}
	
	
local gemTextPositions = {
	-- Left
    Head = { point = "LEFT", relativePoint = "RIGHT", x = 17, y = 12 },
	Neck = { point = "LEFT", relativePoint = "RIGHT", x = 30, y = 10 },
	Shoulder = { point = "LEFT", relativePoint = "RIGHT", x = 16, y = 12 },
	Back = { point = "LEFT", relativePoint = "RIGHT", x = 27, y = 10 },
	Chest = { point = "LEFT", relativePoint = "RIGHT", x = 17, y = 12 },
	Wrist = { point = "LEFT", relativePoint = "RIGHT", x = -22, y = 40 },
	
	
	-- Right
	Hands = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = 15 },
	Waist = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = 15 },
	Legs = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = 28 },
	Feet = { point = "RIGHT", relativePoint = "LEFT", x = -5, y = 18 },
	Finger0 = { point = "RIGHT", relativePoint = "LEFT", x = -18, y = 20 },
	Finger1 = { point = "RIGHT", relativePoint = "LEFT", x = -18, y = 20 },
    
		
	-- Bottom
	MainHand = { point = "LEFT", relativePoint = "RIGHT", x = -25, y = 52 },
	SecondaryHand = { point = "LEFT", relativePoint = "RIGHT", x = -20, y = 20 },
	Ranged = { point = "LEFT", relativePoint = "RIGHT", x = 5, y = 50 },
}


local emptysocketPositions = {
	-- Left
    Head = { point = "LEFT", relativePoint = "RIGHT", x = 5, y = -10 },
	Neck = { point = "LEFT", relativePoint = "RIGHT", x = 20, y = -10 },
	Shoulder = { point = "LEFT", relativePoint = "RIGHT", x = 5, y = 12 },
	Back = { point = "LEFT", relativePoint = "RIGHT", x = 20, y = -10 },
	Chest = { point = "LEFT", relativePoint = "RIGHT", x = 5, y = -10 },
	Wrist = { point = "LEFT", relativePoint = "RIGHT", x = 5, y = -15 },
	
	
	-- Right
	Hands = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 12 },
	Waist = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 12 },
	Legs = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 20 },
	Feet = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 10 },
	Finger0 = { point = "RIGHT", relativePoint = "LEFT", x = -20, y = 10 },
	Finger1 = { point = "RIGHT", relativePoint = "LEFT", x = -20, y = 10 },
    
		
	-- Bottom
	MainHand = { point = "LEFT", relativePoint = "RIGHT", x = -37, y = 52 },
	SecondaryHand = { point = "LEFT", relativePoint = "RIGHT", x = -20, y = 40 },
	Ranged = { point = "TOP", relativePoint = "TOP", x = 5, y = 50 },
}

-- Utility function to reverse a table
function table.reverse(arr)
    local i, j = 1, #arr
    while i < j do
        arr[i], arr[j] = arr[j], arr[i]
        i = i + 1
        j = j - 1
    end
end

function Fizzle:UpdateItems()
	-- Don't update unless the charframe is open.
	-- No point updating what we can't see.
	
	if CharacterFrame:IsVisible() then
		-- Go and set the durability string for each slot that has an item equipped that has durability.
		-- Thanks Tekkub again for the base of this code.
		for _, item in ipairs(items) do
			local id, _ = GetInventorySlotInfo(item .. "Slot")
			local itemLink = GetInventoryItemLink("player", id)
			local str = _G[item.."FizzleS"]
			local v1, v2 = GetInventoryItemDurability(id)
			v1, v2 = tonumber(v1) or 0, tonumber(v2) or 0
			local percent = v1 / v2 * 100

			if (((v2 ~= 0) and ((percent ~= 100) or db.DisplayWhenFull)) and not db.HideText) then
				local text
			
				-- Colour our string depending on current durability percentage
				str:SetTextColor(crayon:GetThresholdColor(v1/v2))

				if db.Invert then
					v1 = v2 - v1
					percent = 100 - percent
				end

				-- Are we showing the % or raw cur/max
				if db.Percent then
					text = sformat("%d%%", percent)
				else
					text = v1.."/"..v2
				end

				str:SetText(text)
			else
				-- No durability in slot, so hide the text.
				str:SetText("")
			end
             
			--Finally, colour the borders
			if db.Border then
				self:ColourBorders(id, item)
			end
			

		-- enchant
if not itemLink then
    -- Clear previous enchant text if any
    local enchantStr = _G[item.."FizzleSEnchant"]
    if enchantStr then
        enchantStr:SetText("")
    end
    -- DEFAULT_CHAT_FRAME:AddMessage("Item link is nil for slot: " .. item)
else
    local _, _, enchantID = string.find(itemLink, "item:%d+:(%d+)")
    local enchantText = enchantAttributes[enchantID]
    local str = _G[item.."FizzleS"]
    local position = enchantTextPositions[item]
    local enchantStr = _G[item.."FizzleSEnchant"] or str:GetParent():CreateFontString(item.."FizzleSEnchant", "OVERLAY")
    local font, _, flags = NumberFontNormal:GetFont()
    enchantStr:SetFont(font, fontSize, flags)

    if enchantID and enchantID ~= "0" then
        if enchantText then
            -- Update enchant text
            enchantStr:SetPoint(position.point, str, position.relativePoint, position.x, position.y)
            enchantStr:SetTextColor(0.1, 0.9, 0.1, 1)
            enchantStr:SetText(enchantText)
        else
            -- Clear enchant text if no enchantment is found in the table and print message
            enchantStr:SetText("")
            DEFAULT_CHAT_FRAME:AddMessage("Enchant ID not found in attributes table: " .. enchantID)
			DEFAULT_CHAT_FRAME:AddMessage("Item link: " .. (itemLink or "nil"))
        end
    else
        -- Clear enchant text if no enchantment is found
        enchantStr:SetText("")
    end
end


    
	
		-- gems
if not itemLink then
	if gemElements[item] then
     for _, element in ipairs(gemElements[item]) do
            element:Hide()
        end
    else
        gemElements[item] = {}
	end
else
    if gemElements[item] then
        for _, element in ipairs(gemElements[item]) do
            element:Hide()
        end
    else
        gemElements[item] = {}
    end
    local _, _, enchantID, gem1, gem2, gem3 = string.find(itemLink, "item:%d+:(%d+):(%d*):(%d*):(%d*)")
    local gems = {gem1, gem2, gem3}
    local yOffset = 0  -- Initial Y offset for the first gem text
    local str = _G[item.."FizzleS"]
    local position = gemTextPositions[item]
	
    -- Create a temporary tooltip to find the number of sockets
    local tooltip = CreateFrame("GameTooltip", "MyTooltip", nil, "GameTooltipTemplate")
    tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    tooltip:SetHyperlink(itemLink)
    local socketCount = 0
	local socketColors = {}  -- To store the colors of the empty sockets
	local usedSockets = 0  -- Initialize count of used sockets
    for i = 1, tooltip:NumLines() do
        local line = _G["MyTooltipTextLeft"..i]:GetText()
        if line and string.find(line, "Socket") and not string.find(line, "Socket Bonus") then
            socketCount = socketCount + 1
			if string.find(line, "Meta Socket") then
				table.insert(socketColors, "Meta")
            elseif string.find(line, "Red Socket") then
                table.insert(socketColors, "Red")
            elseif string.find(line, "Blue Socket") then
                table.insert(socketColors, "Blue")
            elseif string.find(line, "Yellow Socket") then
                table.insert(socketColors, "Yellow")
            else
                table.insert(socketColors, "Unknown")
            end
        end
    end


    
	table.reverse(socketColors)
    -- First loop to deal with filled gem slots
    for i, gemID in ipairs(gems) do
        if gemID and gemID ~= "0" then
            if gemAttributes[gemID] then
                local gemStr = str:GetParent():CreateFontString(nil, "OVERLAY")
                local font, _, flags = NumberFontNormal:GetFont()
                gemStr:SetFont(font, fontSize, flags)
                gemStr:SetPoint(position.point, str, position.relativePoint, position.x, position.y + yOffset)
                gemStr:SetTextColor(1, 0.8, 0, 1)
                gemStr:SetText(gemAttributes[gemID])

                local gemImage = str:GetParent():CreateTexture(nil, "OVERLAY")
                local imagePath = gemImagesByID[gemID] or "Interface\\Icons\\DefaultGemIcon"
                gemImage:SetTexture(imagePath)
                gemImage:SetWidth(12)
                gemImage:SetHeight(12)
                gemImage:SetPoint("RIGHT", gemStr, "LEFT", 0, 0)
                gemImage:Show()

                table.insert(gemElements[item], gemStr)
                table.insert(gemElements[item], gemImage)
				
                yOffset = yOffset - 11  -- Move Y offset down for the next line
                
                usedSockets = usedSockets + 1  -- Increment the count of used sockets
            else
                DEFAULT_CHAT_FRAME:AddMessage("Gem ID not found in attributes table: " .. gemID)
            end
        end
    end

    -- Calculate the number of empty sockets
    local emptySockets = socketCount - usedSockets
	
    -- Second loop to deal with empty sockets
    for i = 1, emptySockets do
				local socketColor = table.remove(socketColors) or "Unknown"
        -- Choose texture based on socket color
				local emptySocketPosition = emptysocketPositions["Empty" .. item] or emptysocketPositions[item]  -- Fallback to regular position if empty-specific is not available
    
                local texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Meta"

                if socketColor == "Red" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Red"
                elseif socketColor == "Blue" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Blue"
                elseif socketColor == "Yellow" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Yellow"
				elseif socketColor == "Meta" then
					texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Meta"
                end

                local gemImage = str:GetParent():CreateTexture(nil, "OVERLAY")
                gemImage:SetTexture(texturePath)
                gemImage:SetWidth(12)
                gemImage:SetHeight(12)
                gemImage:SetPoint(emptySocketPosition.point, str, emptySocketPosition.relativePoint, emptySocketPosition.x, position.y + yOffset)
				gemImage:Show()

                table.insert(gemElements[item], gemImage)
                socketCount = usedSockets - 1  -- Decrement remaining sockets to be displayed

                yOffset = yOffset - 11
            end
        
		 if usedSockets > 0 and usedSockets < 3 then	
		 local socketColor = table.remove(socketColors) or "Unknown"
			local emptySocketPosition = emptysocketPositions["Empty" .. item] or emptysocketPositions[item]  -- Fallback to regular position if empty-specific is not available
    
                local texturePath = ""

                if socketColor == "Red" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Red"
                elseif socketColor == "Blue" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Blue"
                elseif socketColor == "Yellow" then
                    texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Yellow"
				elseif socketColor == "Meta" then
					texturePath = "Interface\\ITEMSOCKETINGFRAME\\UI-EmptySocket-Meta"
                end

                local gemImage = str:GetParent():CreateTexture(nil, "OVERLAY")
                gemImage:SetTexture(texturePath)
                gemImage:SetWidth(12)
                gemImage:SetHeight(12)
                gemImage:SetPoint(emptySocketPosition.point, str, emptySocketPosition.relativePoint, emptySocketPosition.x, position.y + yOffset)
				gemImage:Show()

                table.insert(gemElements[item], gemImage)
                socketCount = usedSockets - 1  -- Decrement remaining sockets to be displayed

                yOffset = yOffset - 11
				
			
			end
			if emptySockets == 0 then
				table.remove(socketColors)
			end
		end
         
		-- Colour the borders of ND items
		if db.Border then
			self:ColourBordersND()
		end
	end
end
end
function Fizzle:CharacterFrame_OnShow()
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateItems")
	self:UpdateItems()
end

function Fizzle:CharacterFrame_OnHide()
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED", "UpdateItems")
end

-- Border colouring split into two functions so I only need to iterate over each table once.
-- Border colouring for items with durability.
function Fizzle:ColourBorders(slotID, rawslot)
	local quality = GetInventoryItemQuality("player", slotID)
	if quality then
		local r, g, b, _ = GetItemQualityColor(quality)
		_G[rawslot.."FizzleB"]:SetVertexColor(r, g, b)
		_G[rawslot.."FizzleB"]:Show()
	else
		_G[rawslot.."FizzleB"]:Hide()
	end
end

-- Border colouring for items without durability
function Fizzle:ColourBordersND()
	for _, nditem in ipairs(nditems) do
		if _G["Character"..nditem.."Slot"] then
			local slotID, _ = GetInventorySlotInfo(nditem .. "Slot")
			local quality = GetInventoryItemQuality("player", slotID)
			if quality then
				local r, g, b, _ = GetItemQualityColor(quality)
				_G[nditem.."FizzleB"]:SetVertexColor(r, g, b)
				_G[nditem.."FizzleB"]:Show()
			else
				_G[nditem.."FizzleB"]:Hide()
			end
		end
	end
end

-- Toggle the border colouring
function Fizzle:BorderToggle()
	if not db.Border then
		self:HideBorders()
	else
		self:UpdateItems()
	end
end

-- Hide quality borders
function Fizzle:HideBorders()
	for _, item in ipairs(items) do
		local border = _G[item.."FizzleB"]
		if border then
			border:Hide()
		end
	end

	for _, nditem in ipairs(nditems) do
		local border = _G[nditem.."FizzleB"]
		if border then
			border:Hide()
		end
	end
end
