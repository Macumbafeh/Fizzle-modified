local _G = getfenv(0)
local GetCursorPosition = GetCursorPosition

-- someone wanted the feature to hide the dressing rooms' backgrounds
local function ToggleBG(notog)
	if not notog then CU_HideBG = not CU_HideBG end
	local f = (CU_HideBG and DressUpBackgroundTopLeft.Hide) or DressUpBackgroundTopLeft.Show
	f(DressUpBackgroundTopLeft)
	f(DressUpBackgroundTopRight)
	f(DressUpBackgroundBotLeft)
	f(DressUpBackgroundBotRight)
	if AuctionDressUpBackgroundTop then
		f(AuctionDressUpBackgroundTop)
		f(AuctionDressUpBackgroundBot)
	end
end
local function OnMouseDown(this, a1)
	this.pMouseDown(a1)
	if a1 == "LeftButton" then
		this.isrotating = 1
		if IsControlKeyDown() then
			ToggleBG()
		end
	elseif a1 == "RightButton" then
		this.isposing = 1
	end
	this.prevx, this.prevy = GetCursorPosition()
end
local function OnMouseUp(this, a1)
	this.pMouseUp(a1)
	if a1 == "LeftButton" then
		this.isrotating = nil
	end
	if a1 == "RightButton" then
		this.isposing = nil
	end
end
local function OnMouseWheel(this, a1)
	local cz, cx, cy = this:GetPosition()
	this:SetPosition(cz + ((a1 > 0 and 0.6) or -0.6), cx, cy)
end
local function OnUpdate(this)
	if this.isrotating then
		local currentx, currenty = GetCursorPosition()
		this:SetFacing(this:GetFacing() + ((currentx - this.prevx) / 50))
		this.prevx, this.prevy = currentx, currenty
	elseif this.isposing then
		local currentx, currenty = GetCursorPosition()
		local cz, cx, cy = this:GetPosition()
		this:SetPosition(cz, cx + ((currentx - this.prevx) / 50), cy + ((currenty - this.prevy) / 50))
		this.prevx, this.prevy = currentx, currenty
	end
end

-- base functions
-- - model - model frame name (string)
-- - w/h - new width/height of the model frame
-- - x/y - new x/y positions for default setpoint
-- - sigh - if rotation buttons have different base names than parent
-- - norotate - if the model doesn't have default rotate buttons
local function Apply(model, w, h, x, y, sigh, norotate)
	local gmodel = _G[model]
	if not norotate then
		model = sigh or model
		_G[model.."RotateRightButton"]:Hide()
		_G[model.."RotateLeftButton"]:Hide()
	end
	if w then gmodel:SetWidth(w) end
	if h then gmodel:SetHeight(h) end
	if x or y then 
		local p,rt,rp,px,py = gmodel:GetPoint()
		gmodel:SetPoint(p, rt, rp, x or px, y or py) 
	end
	
	gmodel:EnableMouse(true)
	gmodel:EnableMouseWheel(true)
	gmodel.pMouseDown = gmodel:GetScript("OnMouseDown") or function() end
	gmodel.pMouseUp = gmodel:GetScript("OnMouseUp") or function() end
	gmodel:SetScript("OnMouseDown", OnMouseDown)
	gmodel:SetScript("OnMouseUp", OnMouseUp)
	gmodel:SetScript("OnMouseWheel", OnMouseWheel)
	gmodel:SetScript("OnUpdate", OnUpdate)
end
-- in case someone wants to apply it to his/her model
CloseUpApplyChange = Apply

local gtt = GameTooltip
local function gttshow(this)
	gtt:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
	gtt:SetText(this.tt)
	if CloseUpNPCModel:IsVisible() and this.tt == "Undress" then
		gtt:AddLine("Cannot dress NPC models (2.1)")
	end
	gtt:Show()
end
local function gtthide()
	gtt:Hide()
end
local function newbutton(name, parent, text, w, h, button, tt, func)
	local b = button or CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
	b:SetText(text or b:GetText())
	b:SetWidth(w or b:GetWidth())
	b:SetHeight(h or b:GetHeight())
	b:SetScript("OnClick", func)
	if tt then
		b.tt = tt
		b:SetScript("OnEnter", gttshow)
		b:SetScript("OnLeave", gtthide)
	end
	return b
end

-- modifies the auction house dressing room
local function DoAH()
	Apply("AuctionDressUpModel", nil, 370, 0, 10)
	local tb, du = AuctionDressUpFrameResetButton, AuctionDressUpModel
	local w, h = 20, tb:GetHeight()
	newbutton(nil, nil, "T", w, h, tb, "Target", function()
		if UnitExists("target") and UnitIsVisible("target") then
			du:SetUnit("target")
		end
	end)
	local a,b,c,d,e = tb:GetPoint()
	tb:SetPoint(a,b,c,d,e-30)
	newbutton("CloseUpAHResetButton", du, "R", 20, 22, nil, "Reset", function() du:Dress() end):SetPoint("RIGHT", tb, "LEFT", 0, 0)
	newbutton("CloseUpAHUndressButton", du, "U", 20, 22, nil, "Undress", function() du:Undress() end):SetPoint("LEFT", tb, "RIGHT", 0, 0)
	ToggleBG(true)
end
local function DoIns()
	Apply("InspectModelFrame", nil, nil, nil, nil, "InspectModel")
end

-- now apply the changes
-- need an event frame since 2 of the models are from LoD addons
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(this, event, a1)
	if a1 == "Blizzard_AuctionUI" then
		DoAH()
	elseif a1 == "Blizzard_InspectUI" then
		DoIns()
	end
end)
-- in case Blizzard_AuctionUI or Blizzard_InspectUI were loaded early
if AuctionDressUpModel then DoAH() end
if InspectModelFrame then DoIns() end

-- main dressing room model with undress buttons
do
	Apply("DressUpModel", nil, 332, nil, 104)
	local tb = DressUpFrameCancelButton
	local w, h = 40, tb:GetHeight()
	local m = DressUpModel

	-- since 2.1 dressup models doesn't apply properly to NPCs, make a substitute
	local tm = CreateFrame("PlayerModel", "CloseUpNPCModel", DressUpFrame)
	tm:SetAllPoints(DressUpModel)
	tm:Hide()
	Apply("CloseUpNPCModel", nil, nil, nil, nil, nil, true)
	
	DressUpFrame:HookScript("OnShow", function()
		tm:Hide()
		m:Show()
		ToggleBG(true)
	end)
	
	-- convert default close button into set target button
	newbutton(nil, nil, "Tar", w, h, tb, "Target", function()
		if UnitExists("target") and UnitIsVisible("target") then 
			if UnitIsPlayer("target") then
				tm:Hide()
				m:Show()
				m:SetUnit("target")
			else
				tm:Show()
				m:Hide()
				tm:SetUnit("target")
			end
			SetPortraitTexture(DressUpFramePortrait, "target")
		end
	end)
	local a,b,c,d,e = tb:GetPoint()
	tb:SetPoint(a, b, c, d - (w/2), e)

	newbutton("CloseUpUndressButton", DressUpFrame, "Und", w, h, nil, "Undress", function() m:Undress() end):SetPoint("LEFT", tb, "RIGHT", -2, 0)
end

Apply("CharacterModelFrame")
Apply("TabardModel", nil, nil, nil, nil, "TabardCharacterModel")
Apply("PetModelFrame")
Apply("PetStableModel")
PetPaperDollPetInfo:SetFrameStrata("HIGH")



-- Table to map race names to texture paths
local raceTextureMap = {
    ["Human"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\Human_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\Human_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\Human_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\Human_4.blp",
    },
    ["NightElf"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\nightelf_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\nightelf_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\nightelf_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\nightelf_4.blp",
    },
	["Orc"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\orc_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\orc_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\orc_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\orc_4.blp",
    },
	["Dwarf"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\dwarf_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\dwarf_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\dwarf_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\dwarf_4.blp",
    },
	["Gnome"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\gnome_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\gnome_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\gnome_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\gnome_4.blp",
    },
	["Draenei"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\draenei_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\draenei_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\draenei_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\draenei_4.blp",
    },
	["Troll"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\troll_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\troll_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\troll_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\troll_4.blp",
    },
	["Scourge"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\scourge_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\scourge_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\scourge_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\scourge_4.blp",
    },
	["Tauren"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\tauren_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\tauren_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\tauren_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\tauren_4.blp",
    },
	["BloodElf"] = {
        topLeft = "Interface\\AddOns\\Fizzle\\Textures\\bloodelf_1.blp",
        topRight = "Interface\\AddOns\\Fizzle\\Textures\\bloodelf_2.blp",
        botLeft = "Interface\\AddOns\\Fizzle\\Textures\\bloodelf_3.blp",
        botRight = "Interface\\AddOns\\Fizzle\\Textures\\bloodelf_4.blp",
    },
}

local classTextureMap = {
	["HUNTER"] = {
        hunter = "Interface\\AddOns\\Fizzle\\Textures\\petHunter.blp",
    },
	["WARLOCK"] = {
       warlock = "Interface\\AddOns\\Fizzle\\Textures\\petWarlock.blp",
    },
}
-- Function to handle event
local function OnEvent(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, race = UnitRace("player")
        local _, class = UnitClass("player")
		
        local texturePaths = raceTextureMap[race]
        local texturePaths2 = classTextureMap[class]

        if not texturePaths then
            return
        end
        
        if not texturePaths2 then
            
        end
		CharacterModelFrameRotateRightButton:Hide()
		CharacterModelFrameRotateLeftButton:Hide()

		-- for i=1,5 do _G["MagicResFrame" .. i]:Hide()end
		PlayerStatFrameLeftDropDown:Hide()
		PlayerStatFrameRightDropDown:Hide()

		CharacterAttributesFrame:Hide()
		CharacterModelFrame:ClearAllPoints()
        CharacterModelFrame:SetSize(231, 320)
		CharacterModelFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", 66, -78)
		
		PetModelFrame:ClearAllPoints()
		PetModelFrame:SetSize(310, 320)
		PetModelFrame:SetPoint("TOPLEFT", 25, -70)
        -- Create or update the background textures
        if not CharacterModelFrame.textureTopLeft then
			CharacterModelFrame.textureTopLeft = CharacterModelFrame:CreateTexture(nil, "BACKGROUND")
			CharacterModelFrame.textureTopLeft:SetSize(212, 244)
			CharacterModelFrame.textureTopLeft:SetPoint("TOPLEFT")
			CharacterModelFrame.textureTopLeft:SetTexCoord(0.171875, 1, 0.0392156862745098, 1)
		end
		CharacterModelFrame.textureTopLeft:SetTexture(texturePaths.topLeft)

		if not CharacterModelFrame.textureTopRight then
			CharacterModelFrame.textureTopRight = CharacterModelFrame:CreateTexture(nil, "BACKGROUND")
			CharacterModelFrame.textureTopRight:SetSize(19, 244)
			CharacterModelFrame.textureTopRight:SetPoint("TOPLEFT", CharacterModelFrame.textureTopLeft, "TOPRIGHT")
			CharacterModelFrame.textureTopRight:SetTexCoord(0, 0.296875, 0.0392156862745098, 1)
		end
		CharacterModelFrame.textureTopRight:SetTexture(texturePaths.topRight)

        if not CharacterModelFrame.textureBotLeft then
            CharacterModelFrame.textureBotLeft = CharacterModelFrame:CreateTexture(nil, "BACKGROUND")
            CharacterModelFrame.textureBotLeft:SetSize(212, 128)
			CharacterModelFrame.textureBotLeft:SetPoint("TOPLEFT", CharacterModelFrame.textureTopLeft, "BOTTOMLEFT")
			CharacterModelFrame.textureBotLeft:SetTexCoord(0.171875, 1, 0, 1)
        end
        CharacterModelFrame.textureBotLeft:SetTexture(texturePaths.botLeft)

        if not CharacterModelFrame.textureBotRight then
            CharacterModelFrame.textureBotRight = CharacterModelFrame:CreateTexture(nil, "BACKGROUND")
            CharacterModelFrame.textureBotRight:SetSize(19, 128)
			CharacterModelFrame.textureBotRight:SetPoint("TOPLEFT", CharacterModelFrame.textureTopLeft, "BOTTOMRIGHT")
			CharacterModelFrame.textureBotRight:SetTexCoord(0, 0.296875, 0, 1)
        end
        CharacterModelFrame.textureBotRight:SetTexture(texturePaths.botRight)
		
		if race == "SCOURGE" then
			CharacterModelFrame.textureTopLeft:SetAlpha(0.2)
			CharacterModelFrame.textureTopRight:SetAlpha(0.2)
			CharacterModelFrame.textureBotLeft:SetAlpha(0.2)
			CharacterModelFrame.textureBotRight:SetAlpha(0.2)
		elseif race == "BLOODELF" then
			CharacterModelFrame.textureTopLeft:SetAlpha(0.7)
			CharacterModelFrame.textureTopRight:SetAlpha(0.7)
			CharacterModelFrame.textureBotLeft:SetAlpha(0.7)
			CharacterModelFrame.textureBotRight:SetAlpha(0.7)
		elseif race == "ORC" or race == "TROLL" then
			CharacterModelFrame.textureTopLeft:SetAlpha(0.5)
			CharacterModelFrame.textureTopRight:SetAlpha(0.5)
			CharacterModelFrame.textureBotLeft:SetAlpha(0.5)
			CharacterModelFrame.textureBotRight:SetAlpha(0.5)
		else
			CharacterModelFrame.textureTopLeft:SetAlpha(0.6)
			CharacterModelFrame.textureTopRight:SetAlpha(0.6)
			CharacterModelFrame.textureBotLeft:SetAlpha(0.6)
			CharacterModelFrame.textureBotRight:SetAlpha(0.6)
		end
		
		
		if class == "HUNTER" then
			if not CharacterModelFrame.HunterBackground then
				PetModelFrame.HunterBackground = PetModelFrame:CreateTexture(nil, "BACKGROUND")
				PetModelFrame.HunterBackground:SetSize(310, 330)
				PetModelFrame.HunterBackground:SetPoint("CENTER", PetModelFrame, "CENTER", 0, -10)
				PetModelFrame.HunterBackground:SetAlpha(0.6)
			end
			PetModelFrame.HunterBackground:SetTexture(texturePaths2.hunter)
		elseif class == "WARLOCK" then
			if not CharacterModelFrame.WarlockBackground then
				PetModelFrame.WarlockBackground = PetModelFrame:CreateTexture(nil, "BACKGROUND")
				PetModelFrame.WarlockBackground:SetSize(310, 330)
				PetModelFrame.WarlockBackground:SetPoint("CENTER", PetModelFrame, "CENTER", 0, -10)
				PetModelFrame.WarlockBackground:SetAlpha(0.8)
			end
			PetModelFrame.WarlockBackground:SetTexture(texturePaths2.warlock)
		end
		
		
    end
end

-- Create a frame to listen for the event
local frame = CreateFrame("Frame")

-- Register for the event
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Set the event handling function
frame:SetScript("OnEvent", OnEvent)
