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

CharacterModelFrameRotateRightButton:Hide()
CharacterModelFrameRotateLeftButton:Hide()
for i=1,5 do _G["MagicResFrame" .. i]:Hide()end
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
	}
         
	-- Items without durability but with some quality, needed for border colouring.
	nditems = {
		"Ammo",
		"Neck",
		"Back",
		"Finger0",
		"Finger1",
		"Trinket0",
		"Trinket1",
		"Relic",
		"Tabard",
	}
         
	for _, item in ipairs(items) do
		self:CreateBorder("Character", item, "Fizzle", true)
	end

	-- Same again, but for ND items, and only creating a border
	for _, nditem in ipairs(nditems) do
		self:CreateBorder("Character", nditem, "Fizzle", false)
	end
end

local enchantTextPositions = {
    Head = { point = "LEFT", relativePoint = "RIGHT", x = 7, y = 0 },
    Hands = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 0 },
    MainHand = { point = "TOP", relativePoint = "TOP", x = 0, y = 35 },
    -- Add more slots as needed
	}
	
	local enchantAttributes = {
    ["2937"] = "+20 Spell damage",  -- Replace with actual enchant IDs and names
    ["2323"] = "",
    -- Add more enchants as needed
}
	
	local gemAttributes = {
    ["30582"] = "+4 Agility, +6 Stamina",  -- Shifting Nightseye, replace with actual gem IDs
    -- Add more gems as needed
	}
	
	local gemTextPositions = {
    Head = { point = "LEFT", relativePoint = "RIGHT", x = 7, y = 10 },
    Hands = { point = "RIGHT", relativePoint = "LEFT", x = -7, y = 15 },
    MainHand = { point = "TOP", relativePoint = "TOP", x = 10, y = 35 },
    -- Add more slots as needed
}

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
            -- This will print a message to the default chat frame if itemLink is nil
            DEFAULT_CHAT_FRAME:AddMessage("Item link is nil for slot: " .. item)
        else
            local _, _, enchantID = string.find(itemLink, "item:%d+:(%d+)")

            -- New Code: Handling Enchant Texts
            if enchantID and enchantID ~= "0" then
                local enchantText = enchantAttributes[enchantID]
                if enchantText then
                    local str = _G[item.."FizzleS"]
                    local position = enchantTextPositions[item]

                    if position then
                        local enchantStr = _G[item.."FizzleSEnchant"] or str:GetParent():CreateFontString(item.."FizzleSEnchant", "OVERLAY")
                        local font, _, flags = NumberFontNormal:GetFont()
                        enchantStr:SetFont(font, fontSize, flags)

                        -- Set the enchantment text position based on the table
                        enchantStr:SetPoint(position.point, str, position.relativePoint, position.x, position.y)
						enchantStr:SetTextColor(0, 1, 0, 1)
                        enchantStr:SetText(enchantText)
                    end
                end
            end
        end
    
		
		-- gems
		if itemLink then
        local _, _, enchantID, gem1, gem2, gem3 = string.find(itemLink, "item:%d+:(%d+):(%d*):(%d*):(%d*)")

        local gems = {gem1, gem2, gem3}
        local gemText = ""

        for _, gemID in ipairs(gems) do
            if gemID and gemID ~= "0" and gemAttributes[gemID] then
                if #gemText > 0 then
                    gemText = gemText .. ", "
                end
                gemText = gemText .. gemAttributes[gemID]
            end
        end

        local gemText = "gem ID"  -- Replace with actual gem attributes

    if #gemText > 0 then
        local str = _G[item.."FizzleS"]
        local position = gemTextPositions[item]  -- Get the position settings from the table

        if position then
            local gemStr = _G[item.."FizzleSGem"] or str:GetParent():CreateFontString(item.."FizzleSGem", "OVERLAY")
            local font, _, flags = NumberFontNormal:GetFont()
            gemStr:SetFont(font, fontSize, flags)

            -- Set the gem text position based on the table
            gemStr:SetPoint(position.point, str, position.relativePoint, position.x, position.y)

            gemStr:SetText(gemText)
        end
    end
    end
		end
         
		-- Colour the borders of ND items
		if db.Border then
			self:ColourBordersND()
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
