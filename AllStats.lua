local frame, texture
local frame2, texture2
local frame3, texture3
local frame4, texture4
local frame5, texture5

function AllStats_OnLoad()
	CharacterAttributesFrame:Hide();
	CharacterModelFrame:SetHeight(300);
	PaperDollFrame_UpdateStats = NewPaperDollFrame_UpdateStats;
	CharacterFrame:SetScale(1.3)
end

function NewPaperDollFrame_UpdateStats()
	PrintStats();
end

local isExtended = true
-- Create Button
local MyButton = CreateFrame("Button", nil, PaperDollFrame)
MyButton:SetSize(32, 32)
MyButton:SetPoint("BOTTOMRIGHT", PaperDollFrame, "BOTTOMRIGHT", -40, 80)
MyButton:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
MyButton:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
MyButton:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")

-- Create Tooltip Function
local function showTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local tooltipText = isExtended and "Hide Character Stats" or "Show Character Stats"
    GameTooltip:SetText(tooltipText, 1, 1, 1)
    GameTooltip:Show()
end



-- Create Additional Frame (Replace this with your ScrollFrame if needed)
	local currentScale = CharacterFrame:GetScale()
    local currentWidth = CharacterFrame:GetWidth()
    local currentHeight = CharacterFrame:GetHeight()
	

local MyFrame = CreateFrame("Frame", "MyFrame", CharacterFrame)
MyFrame:ClearAllPoints()
MyFrame:SetSize(currentWidth / (1.9 * currentScale), currentHeight / (1 * currentScale))
MyFrame:SetPoint("TOPLEFT", "CharacterFrame", "TOPRIGHT", -34, -26)
MyFrame:SetFrameStrata("LOW")
-- MyFrame:Hide() -- Hide initially
--[[
-- Create Scroll Frame
local scrollFrame = CreateFrame("ScrollFrame", "scrollFrame", MyFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(currentWidth / (1.9 * currentScale), 411)
scrollFrame:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", -70, 5)
scrollFrame:SetFrameStrata("BACKGROUND")

local ContentFrame = CreateFrame("Frame", "ContentFrameID", scrollFrame)
ContentFrame:SetSize(currentWidth / (1.2 * currentScale), currentHeight / (1.2 * currentScale))

-- Attach MyFrame to Scroll Frame
scrollFrame:SetParent(MyFrame)
scrollFrame:SetScrollChild(ContentFrame)


--- Create ScrollBar
local scrollbar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 4, -16)
scrollbar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 16)
scrollbar:SetMinMaxValues(1, 200)
scrollbar:SetValueStep(1)
scrollbar.scrollStep = 1
scrollbar:SetValue(0)
scrollbar:SetWidth(16)
scrollbar:SetScript("OnValueChanged", function (self, value)
    self:GetParent():SetVerticalScroll(value)
end)

-- Update your OnScrollRangeChanged Hook
scrollFrame:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
    local minValue, maxValue = scrollbar:GetMinMaxValues()
    if floor(yrange) ~= 0 then
        scrollbar:SetMinMaxValues(minValue, floor(yrange))
        scrollbar:Show()
    else
        scrollbar:Hide()
    end
end)



-- Create Scroll Bar Styling
local scrollbarName = scrollFrame:GetName()
_G[scrollbarName.."ScrollBar"]:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
  tile = true,
  tileSize = 16,
  edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
]]








-- BaseStat
local BaseStat = MyFrame:CreateTexture(nil, "OVERLAY")
BaseStat:SetSize(140, 22)
BaseStat:SetTexture("Interface\\AddOns\\AllStats\\PaperDollInfoPart1.blp")
BaseStat:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, 5)
BaseStat:SetTexCoord(0, 0.7734375, 0.453125, 0.6015625)

-- Create the BaseStatsText frame
local BaseStatsText = CreateFrame("Frame", "BaseStatsText", UIParent, "StatFrameTemplate")
BaseStatsText:SetID(0)
BaseStatsText:EnableMouse(false)
-- Set the anchor for the BaseStatsText frame
BaseStatsText:SetPoint("TOPLEFT", BaseStat, "TOPLEFT", 38, -3)

-- Create a FontString within the BaseStatsText frame
local AllStatsFrameLabelStats = BaseStatsText:CreateFontString("AllStatsFrameLabelStats", "BACKGROUND", "GameFontHighlightSmall")
-- Set the text for the FontString
AllStatsFrameLabelStats:SetText("Base Stats")
local fontPath, _, fontFlags = AllStatsFrameLabelStats:GetFont()
AllStatsFrameLabelStats:SetFont(fontPath, 13, fontFlags)
-- Set the position of the FontString
AllStatsFrameLabelStats:SetPoint("BOTTOM", BaseStatsText, "TOP", 1, -16)

-- Create an invisible button frame on top of your texture
local clickableFrame = CreateFrame("Button", nil, MyFrame)
clickableFrame:SetSize(180, 22)
clickableFrame:SetPoint("TOPLEFT", BaseStat, "TOPLEFT", -20, 0)
clickableFrame:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")
-- Optional: Add tooltip or cursor change for better UX
clickableFrame:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clickableFrame, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left Click to Hide/Show everything\nRight Click to Hide/Show the Background only", 0, 1, 1)
    GameTooltip:Show()
end)
clickableFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
clickableFrame:RegisterForClicks("AnyUp")

-- Melee
local Melee = MyFrame:CreateTexture(nil, "OVERLAY")
Melee:SetSize(140, 22)
Melee:SetTexture("Interface\\AddOns\\AllStats\\PaperDollInfoPart1.blp")
Melee:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, -93)
Melee:SetTexCoord(0, 0.7734375, 0.453125, 0.6015625)

-- Create the MeleeText frame
local MeleeText = CreateFrame("Frame", "MeleeText", UIParent, "StatFrameTemplate")
MeleeText:SetID(0)
MeleeText:EnableMouse(false)
-- Set the anchor for the MeleeText frame
MeleeText:SetPoint("TOPLEFT", Melee, "TOPLEFT", 38, -3)

-- Create a FontString within the MeleeText frame
local AllStatsFrameLabelMelee = MeleeText:CreateFontString("AllStatsFrameLabelMelee", "BACKGROUND", "GameFontHighlightSmall")
-- Set the text for the FontString
AllStatsFrameLabelMelee:SetText("Melee")
local fontPath, _, fontFlags = AllStatsFrameLabelMelee:GetFont()
AllStatsFrameLabelMelee:SetFont(fontPath, 13, fontFlags)
-- Set the position of the FontString
AllStatsFrameLabelMelee:SetPoint("BOTTOM", MeleeText, "TOP", 1, -16)

-- Create an invisible button frame on top of your texture
local clickableFrame2 = CreateFrame("Button", nil, MyFrame)
clickableFrame2:SetSize(180, 22)
clickableFrame2:SetPoint("TOPLEFT", Melee, "TOPLEFT", -20, 0)
clickableFrame2:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")

-- Optional: Add tooltip or cursor change for better UX
clickableFrame2:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clickableFrame2, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left Click to Hide/Show everything\nRight Click to Hide/Show the Background only", 0, 1, 1)
    GameTooltip:Show()
end)
clickableFrame2:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
clickableFrame2:RegisterForClicks("AnyUp")

-- Ranged
local Ranged = MyFrame:CreateTexture(nil, "OVERLAY")
Ranged:SetSize(140, 22)
Ranged:SetTexture("Interface\\AddOns\\AllStats\\PaperDollInfoPart1.blp")
Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -111)
Ranged:SetTexCoord(0, 0.7734375, 0.453125, 0.6015625)

-- Create the RangedText frame
local RangedText = CreateFrame("Frame", "RangedText", UIParent, "StatFrameTemplate")
RangedText:SetID(0)
RangedText:EnableMouse(false)
-- Set the anchor for the RangedText frame
RangedText:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 38, -3)

-- Create a FontString within the RangedText frame
local AllStatsFrameLabelRange = RangedText:CreateFontString("AllStatsFrameLabelRange", "BACKGROUND", "GameFontHighlightSmall")
-- Set the text for the FontString
AllStatsFrameLabelRange:SetText("Ranged")
local fontPath, _, fontFlags = AllStatsFrameLabelRange:GetFont()
AllStatsFrameLabelRange:SetFont(fontPath, 13, fontFlags)
-- Set the position of the FontString
AllStatsFrameLabelRange:SetPoint("BOTTOM", RangedText, "TOP", 1, -16)

-- Create an invisible button frame on top of your texture
local clickableFrame3 = CreateFrame("Button", nil, MyFrame)
clickableFrame3:SetSize(180, 22)
clickableFrame3:SetPoint("TOPLEFT", Ranged, "TOPLEFT", -20, 0)
clickableFrame3:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")

-- Optional: Add tooltip or cursor change for better UX
clickableFrame3:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clickableFrame3, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left Click to Hide/Show everything\nRight Click to Hide/Show the Background only", 0, 1, 1)
    GameTooltip:Show()
end)
clickableFrame3:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
clickableFrame3:RegisterForClicks("AnyUp")

-- Spell
local Spell = MyFrame:CreateTexture(nil, "OVERLAY")
Spell:SetSize(140, 22)
Spell:SetTexture("Interface\\AddOns\\AllStats\\PaperDollInfoPart1.blp")
Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -92)
Spell:SetTexCoord(0, 0.7734375, 0.453125, 0.6015625)

-- Create the SpellText frame
local SpellText = CreateFrame("Frame", "SpellText", UIParent, "StatFrameTemplate")
SpellText:SetID(0)
SpellText:EnableMouse(false)
-- Set the anchor for the SpellText frame
SpellText:SetPoint("TOPLEFT", Spell, "TOPLEFT", 38, -3)

-- Create a FontString within the SpellText frame
local AllStatsFrameLabelSpell = SpellText:CreateFontString("AllStatsFrameLabelSpell", "BACKGROUND", "GameFontHighlightSmall")
-- Set the text for the FontString
AllStatsFrameLabelSpell:SetText("Spell")
local fontPath, _, fontFlags = AllStatsFrameLabelSpell:GetFont()
AllStatsFrameLabelSpell:SetFont(fontPath, 13, fontFlags)
-- Set the position of the FontString
AllStatsFrameLabelSpell:SetPoint("BOTTOM", SpellText, "TOP", 1, -16)

-- Create an invisible button frame on top of your texture
local clickableFrame4 = CreateFrame("Button", nil, MyFrame)
clickableFrame4:SetSize(180, 22)
clickableFrame4:SetPoint("TOPLEFT", Spell, "TOPLEFT", -20, 0)
clickableFrame4:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")

-- Optional: Add tooltip or cursor change for better UX
clickableFrame4:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clickableFrame4, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left Click to Hide/Show everything\nRight Click to Hide/Show the Background only", 0, 1, 1)
    GameTooltip:Show()
end)
clickableFrame4:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
clickableFrame4:RegisterForClicks("AnyUp")

-- Defenses
local Defenses = MyFrame:CreateTexture(nil, "OVERLAY")
Defenses:SetSize(140, 22)
Defenses:SetTexture("Interface\\AddOns\\AllStats\\PaperDollInfoPart1.blp")
Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -110)
Defenses:SetTexCoord(0, 0.7734375, 0.453125, 0.6015625)

-- Create the DefensesText frame
local DefensesText = CreateFrame("Frame", "DefensesText", UIParent, "StatFrameTemplate")
DefensesText:SetID(0)
DefensesText:EnableMouse(false)
-- Set the anchor for the DefensesText frame
DefensesText:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 38, -3)

-- Create a FontString within the DefensesText frame
local AllStatsFrameLabelDefense = DefensesText:CreateFontString("AllStatsFrameLabelDefense", "BACKGROUND", "GameFontHighlightSmall")
-- Set the text for the FontString
AllStatsFrameLabelDefense:SetText("Defenses")
local fontPath, _, fontFlags = AllStatsFrameLabelDefense:GetFont()
AllStatsFrameLabelDefense:SetFont(fontPath, 13, fontFlags)
-- Set the position of the FontString
AllStatsFrameLabelDefense:SetPoint("BOTTOM", DefensesText, "TOP", 1, -16)

-- Create an invisible button frame on top of your texture
local clickableFrame5 = CreateFrame("Button", nil, MyFrame)
clickableFrame5:SetSize(180, 22)
clickableFrame5:SetPoint("TOPLEFT", Defenses, "TOPLEFT", -20, 0)
clickableFrame5:SetHighlightTexture("Interface\\BUTTONS\\UI-Common-MouseHilight")

-- Optional: Add tooltip or cursor change for better UX
clickableFrame5:SetScript("OnEnter", function()
    GameTooltip:SetOwner(clickableFrame5, "ANCHOR_RIGHT")
    GameTooltip:SetText("Left Click to Hide/Show everything\nRight Click to Hide/Show the Background only", 0, 1, 1)
    GameTooltip:Show()
end)
clickableFrame5:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
clickableFrame5:RegisterForClicks("AnyUp")

-- Textures behind

-- Bottom Right
local DefenseFrame2 = CreateFrame("Frame", "DefenseFrame2", UIParent)
DefenseFrame2:SetSize(currentWidth / (2.2 * currentScale), currentHeight / (1.3 * currentScale))
DefenseFrame2:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", 68.5, 120)
DefenseFrame2:SetFrameStrata("LOW")

local tframe = DefenseFrame2:CreateTexture(nil, "ARTWORK")
tframe:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-BottomRight.blp")
-- tframe:SetPoint("BOTTOM", MyFrame, "BOTTOM", 20, -37)
tframe:SetAllPoints(DefenseFrame2)

-- Top Right
local tframe2 = MyFrame:CreateTexture(nil, "ARTWORK")
tframe2:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-TopRight.blp")
tframe2:SetPoint("TOP", MyFrame, "TOP", 20, 87)


-- Middle Right
local DefenseFrame3 = CreateFrame("Frame", "DefenseFrame3", UIParent)
DefenseFrame3:SetSize(currentWidth / (2.2 * currentScale), currentHeight / (1.3 * currentScale))
DefenseFrame3:SetPoint("TOPLEFT", Ranged, "BOTTOMLEFT", 68.5, 210)
DefenseFrame3:SetFrameStrata("LOW")

local tframe3 = DefenseFrame3:CreateTexture(nil, "ARTWORK")
tframe3:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-BottomRight1.blp")
-- tframe3:SetPoint("TOP", MyFrame, "TOP", 20, -80)
tframe3:SetAllPoints(DefenseFrame3)

-- Middle Right
--[[local tframe3bis = MyFrame:CreateTexture(nil, "ARTWORK")
tframe3bis:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-BottomRight1.blp")
tframe3bis:SetPoint("TOP", MyFrame, "TOP", 20, -160)]]

-- Bottom Left
local DefenseFrame = CreateFrame("Frame", "DefenseFrame", UIParent)
DefenseFrame:SetSize(currentWidth / (2.2 * currentScale), currentHeight / (1.3 * currentScale))
DefenseFrame:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", -65, 120)
DefenseFrame:SetFrameStrata("LOW")

local tframe4 = DefenseFrame:CreateTexture(nil, "ARTWORK")
tframe4:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-middleLeft2.blp")
-- tframe4:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
-- tframe4:SetPoint("BOTTOM", DefenseFrame, "BOTTOM", -80, -37)
tframe4:SetAllPoints(DefenseFrame)

-- Middle Left
-- Middle Right
local DefenseFrame5 = CreateFrame("Frame", "DefenseFrame5", UIParent)
DefenseFrame5:SetSize(currentWidth / (2.2 * currentScale), currentHeight / (1.3 * currentScale))
DefenseFrame5:SetPoint("TOPLEFT", Ranged, "BOTTOMLEFT", 0, 210)
DefenseFrame5:SetFrameStrata("LOW")

local tframe5 = DefenseFrame5:CreateTexture(nil, "ARTWORK")
tframe5:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-middleLeft.blp")
-- tframe5:SetPoint("BOTTOM", MyFrame, "BOTTOM", -50, 180)
tframe5:SetAllPoints(DefenseFrame5)

-- Middle Left
--[[local tframe5bis = MyFrame:CreateTexture(nil, "ARTWORK")
tframe5bis:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-middleLeft.blp")
tframe5bis:SetPoint("BOTTOM", MyFrame, "BOTTOM", -50, 100)]]

-- Top Left
local tframe6 = MyFrame:CreateTexture(nil, "ARTWORK")
tframe6:SetTexture("Interface\\AddOns\\AllStats\\UI-Character-General-BottomRight2.blp")
tframe6:SetPoint("BOTTOM", MyFrame, "BOTTOM", -50, 343)


MyButton:SetScript("OnEnter", showTooltip)
MyButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Button OnClick Function
MyButton:SetScript("OnClick", function(self)
    isExtended = not isExtended
    if isExtended then
        AllStatsFrame:Show()
		 MyFrame:Show()
		 texture:Show()
		texture2:Show()
		if AllStatsFrameStatRangeDamage:IsVisible() then
		texture3:Show()
		end
		texture4:Show()
		texture5:Show()
		AllStatsFrameLabelStats:Show()
		AllStatsFrameLabelMelee:Show()
		AllStatsFrameLabelRange:Show()
		AllStatsFrameLabelSpell:Show()
		AllStatsFrameLabelDefense:Show()
        self:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Up")
		self:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-PrevPage-Down")
		MagicResFrame1:Show()
		MagicResFrame2:Show()
		MagicResFrame3:Show()
		MagicResFrame4:Show()
		MagicResFrame5:Show()
		tframe:Show()
		tframe2:Show()
		tframe3:Show()
		tframe4:Show()
		tframe5:Show()
		tframe6:Show()
    else
        AllStatsFrame:Hide()
		 MyFrame:Hide()
		 texture:Hide()
		texture2:Hide()
		texture3:Hide()
		texture4:Hide()
		texture5:Hide()
		AllStatsFrameLabelStats:Hide()
		AllStatsFrameLabelMelee:Hide()
		AllStatsFrameLabelRange:Hide()
		AllStatsFrameLabelSpell:Hide()
		AllStatsFrameLabelDefense:Hide()
        self:SetNormalTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Up")
		self:SetPushedTexture("Interface\\BUTTONS\\UI-SpellbookIcon-NextPage-Down")
		MagicResFrame1:Hide()
		MagicResFrame2:Hide()
		MagicResFrame3:Hide()
		MagicResFrame4:Hide()
		MagicResFrame5:Hide()
		tframe:Hide()
		tframe2:Hide()
		tframe3:Hide()
		tframe4:Hide()
		tframe5:Hide()
		tframe6:Hide()
    end
    showTooltip(self) -- Update the tooltip
end)


for i=1,5 do _G["MagicResFrame" .. i]:SetScale(0.8)end
MagicResFrame1:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 10, -25)
MagicResFrame2:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 40, -25)
MagicResFrame3:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 70, -25)
MagicResFrame4:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 100, -25)
MagicResFrame5:SetPoint("TOPLEFT", Defenses, "TOPLEFT", 130, -25)
local function ShowOrHideTexture()
    if PaperDollFrame:IsVisible() then
        texture:Show()
		texture2:Show()
		if AllStatsFrameStatRangeDamage:IsVisible() then
		texture3:Show()
		end
		texture4:Show()
		texture5:Show()
		BaseStat:Show()
		AllStatsFrameLabelStats:Show()
		Melee:Show()
		AllStatsFrameLabelMelee:Show()
		Ranged:Show()
		AllStatsFrameLabelRange:Show()
		Spell:Show()
		AllStatsFrameLabelSpell:Show()
		Defenses:Show()
		AllStatsFrameLabelDefense:Show()
		tframe:Show()
		tframe2:Show()
		tframe3:Show()
		tframe4:Show()
		tframe5:Show()
		tframe6:Show()
		
    else
        texture:Hide()
		texture2:Hide()
		texture3:Hide()
		texture4:Hide()
		texture5:Hide()
		BaseStat:Hide()
		AllStatsFrameLabelStats:Hide()
		Melee:Hide()
		AllStatsFrameLabelMelee:Hide()
		Ranged:Hide()
		AllStatsFrameLabelRange:Hide()
		Spell:Hide()
		AllStatsFrameLabelSpell:Hide()
		Defenses:Hide()
		AllStatsFrameLabelDefense:Hide()
		tframe:Hide()
		tframe2:Hide()
		tframe3:Hide()
		tframe4:Hide()
		tframe5:Hide()
		tframe6:Hide()
    end
end


local function UpdateTexture(texture)
    local className, classFilename, classId = UnitClass("player")

    -- Your mapping from class and spec to texture
    local textureMap = {
        WARRIOR = "Interface\\AddOns\\AllStats\\Talent\\WarriorArms-TopLeft.blp",
        SHAMAN = "Interface\\AddOns\\AllStats\\Talent\\ShamanRestoration-TopLeft.blp",
		PALADIN = "Interface\\AddOns\\AllStats\\Talent\\PaladinProtection-TopLeft.blp",
        HUNTER = "Interface\\AddOns\\AllStats\\Talent\\HunterBeastMastery-TopLeft.blp",
		ROGUE = "Interface\\AddOns\\AllStats\\Talent\\RogueSubtlety-TopLeft.blp",
        MAGE = "Interface\\AddOns\\AllStats\\Talent\\MageArcane-TopLeft.blp",
		WARLOCK = "Interface\\AddOns\\AllStats\\Talent\\WarlockSummoning-TopLeft.blp",
        PRIEST = "Interface\\AddOns\\AllStats\\Talent\\PriestDiscipline-TopLeft.blp",
		DRUID = "Interface\\AddOns\\AllStats\\Talent\\DruidBalance-TopLeft.blp",
        -- etc.
    }

    -- Update the texture
    if textureMap[classFilename] then
        texture:SetTexture(textureMap[classFilename])
		texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        -- Default texture if class is not found in the map
        texture:SetTexture("Interface\\AddOns\\AllStats\\nightelf_1.blp")
    end
end

local function UpdateTexture2(texture2)
    local className, classFilename, classId = UnitClass("player")

    -- Your mapping from class and spec to texture
    local textureMap2 = {
        WARRIOR = "Interface\\AddOns\\AllStats\\Talent\\WarriorFury-TopLeft.blp",
        SHAMAN = "Interface\\AddOns\\AllStats\\Talent\\ShamanElementalCombat-TopLeft.blp",
		PALADIN = "Interface\\AddOns\\AllStats\\Talent\\PaladinCombat-TopLeft.blp",
        HUNTER = "Interface\\AddOns\\AllStats\\Talent\\HunterSurvival-TopLeft.blp",
		ROGUE = "Interface\\AddOns\\AllStats\\Talent\\RogueAssassination-TopLeft.blp",
        MAGE = "Interface\\AddOns\\AllStats\\Talent\\MageFire-TopLeft.blp",
		WARLOCK = "Interface\\AddOns\\AllStats\\Talent\\WarlockCurses-TopLeft.blp",
        PRIEST = "Interface\\AddOns\\AllStats\\Talent\\PriestHoly-TopLeft.blp",
		DRUID = "Interface\\AddOns\\AllStats\\Talent\\DruidFeralCombat-TopLeft.blp",
    }


    -- Update the texture
    if textureMap2[classFilename] then
        texture2:SetTexture(textureMap2[classFilename])
		texture2:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        -- Default texture if class is not found in the map
        texture2:SetTexture("Interface\\AddOns\\AllStats\\nightelf_1.blp")
    end
end

local function UpdateTexture3(texture3)
    local className, classFilename, classId = UnitClass("player")

    -- Your mapping from class and spec to texture
    local textureMap3 = {
        WARRIOR = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
        SHAMAN = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		PALADIN = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		HUNTER = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		ROGUE = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
        MAGE = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		WARLOCK = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
        PRIEST = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		DRUID = "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
    }

    -- Update the texture
    if textureMap3[classFilename] then
        texture3:SetTexture(textureMap3[classFilename])
		texture3:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        -- Default texture if class is not found in the map
        texture3:SetTexture("Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp")
    end
end

local function UpdateTexture4(texture4)
    local className, classFilename, classId = UnitClass("player")

    -- Your mapping from class and spec to texture
    local textureMap4 = {
        WARRIOR = "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
        SHAMAN = "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
		PALADIN = "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
        HUNTER = "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
		ROGUE = "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
        MAGE = "Interface\\AddOns\\AllStats\\Talent\\MageFrost-TopLeft.blp",
		WARLOCK = "Interface\\AddOns\\AllStats\\Talent\\WarlockDestruction-TopLeft.blp",
        PRIEST = "Interface\\AddOns\\AllStats\\Talent\\PriestShadow-TopLeft.blp",
		DRUID = "Interface\\AddOns\\AllStats\\Talent\\DruidRestoration-TopLeft.blp",
    }


    -- Update the texture
    if textureMap4[classFilename] then
        texture4:SetTexture(textureMap4[classFilename])
		texture4:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        -- Default texture if class is not found in the map
        texture4:SetTexture("Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp")
    end
end

local function UpdateTexture5(texture5)
    local className, classFilename, classId = UnitClass("player")

    -- Your mapping from class and spec to texture
    local textureMap5 = {
        WARRIOR = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
        SHAMAN = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
		PALADIN = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
		HUNTER = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
		ROGUE = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
        MAGE = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
		WARLOCK = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
        PRIEST = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
		DRUID = "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
    }

    -- Update the texture
    if textureMap5[classFilename] then
        texture5:SetTexture(textureMap5[classFilename])
		texture5:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    else
        -- Default texture if class is not found in the map
        texture5:SetTexture("Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp")
		-- ranged "Interface\\AddOns\\AllStats\\Talent\\HunterMarksmanship-TopLeft.blp",
		-- spell "Interface\\AddOns\\AllStats\\Talent\\ShamanEnhancement-TopLeft.blp",
		-- Defenses "Interface\\AddOns\\AllStats\\Talent\\WarriorProtection-TopLeft.blp",
    end
end

local function OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "AllStats" then
        if AllStatsFrame then
            frame1 = CreateFrame("Frame", "MyNewFrame", UIParent)
            frame1:SetSize(135, 102)
            frame1:SetPoint("TOPLEFT", BaseStat, "BOTTOMLEFT", 25, 2)

            texture = frame1:CreateTexture(nil, "BACKGROUND")
            texture:SetAllPoints(frame1)
            texture:Hide()  -- Hide it by default
            
			frame2 = CreateFrame("Frame", "MyNewFrame2", UIParent)
            frame2:SetSize(135, 120)
            frame2:SetPoint("TOPLEFT", Melee, "BOTTOMLEFT", 25, 2)
			
			texture2 = frame2:CreateTexture(nil, "BACKGROUND")
            texture2:SetAllPoints(frame2)
            texture2:Hide()
			
			frame3 = CreateFrame("Frame", "MyNewFrame3", UIParent)
            frame3:SetSize(135, 96)
            frame3:SetPoint("TOPLEFT", Ranged, "BOTTOMLEFT", 25, 2)
			
			texture3 = frame3:CreateTexture(nil, "BACKGROUND")
            texture3:SetAllPoints(frame3)
            texture3:Hide()
			
			frame4 = CreateFrame("Frame", "MyNewFrame4", UIParent)
            frame4:SetSize(135, 119)
            frame4:SetPoint("TOPLEFT", Spell, "BOTTOMLEFT", 25, 2)
			
			texture4 = frame4:CreateTexture(nil, "BACKGROUND")
            texture4:SetAllPoints(frame4)
            texture4:Hide()
			
			frame5 = CreateFrame("Frame", "MyNewFrame5", UIParent)
            frame5:SetSize(135, 118)
            frame5:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", 25, -26)
			
			texture5 = frame5:CreateTexture(nil, "BACKGROUND")
            texture5:SetAllPoints(frame5)
            texture5:Hide()
			
            -- Hook CharacterFrame's methods to show/hide texture
            hooksecurefunc(PaperDollFrame, "Show", ShowOrHideTexture)
            hooksecurefunc(PaperDollFrame, "Hide", ShowOrHideTexture)
			hooksecurefunc(CharacterFrame, "Show", ShowOrHideTexture)
            hooksecurefunc(CharacterFrame, "Hide", ShowOrHideTexture)
            
            -- Initial state
            ShowOrHideTexture()
			UpdateTexture(texture)
			UpdateTexture2(texture2)
			UpdateTexture3(texture3)
			UpdateTexture4(texture4)
			UpdateTexture5(texture5)
		elseif event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
			UpdateTexture(texture)
			UpdateTexture2(texture2)
			UpdateTexture3(texture3)
			UpdateTexture4(texture4)
			UpdateTexture5(texture5)
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent('PLAYER_LOGIN')
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", OnEvent)


clickableFrame:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
        if texture:IsVisible() then
			texture:Hide()
		else
			if AllStatsFrameStat1:IsVisible() then
				texture:Show()
			else
				texture:Hide()
			end
		end
	elseif button == "LeftButton" then
		if AllStatsFrameStat1:IsVisible() then
			texture:Hide()
			AllStatsFrameStat1:Hide()
			AllStatsFrameStat2:Hide()
			AllStatsFrameStat3:Hide()
			AllStatsFrameStat4:Hide()
			AllStatsFrameStat5:Hide()
			Melee:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, -14)
			AllStatsFrameStatMeleeDamage:SetPoint("TOPLEFT", AllStatsFrameStat5, "BOTTOMLEFT", 0, 56)
		else
			frame1:Show()
			texture:Show()
			AllStatsFrameStat1:Show()
			AllStatsFrameStat2:Show()
			AllStatsFrameStat3:Show()
			AllStatsFrameStat4:Show()
			AllStatsFrameStat5:Show()
			Melee:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, -93)
			AllStatsFrameStatMeleeDamage:SetPoint("TOPLEFT", AllStatsFrameStat5, "BOTTOMLEFT", 0, -24)
		end
	end
end)

clickableFrame2:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
        if texture2:IsVisible() then
			texture2:Hide()
		else
			if AllStatsFrameStatMeleeDamage:IsVisible() then
				texture2:Show()
			else
				texture2:Hide()
			end
		end
	elseif button == "LeftButton" then
		if AllStatsFrameStatMeleeDamage:IsVisible() then
			texture2:Hide()
			AllStatsFrameStatMeleeDamage:Hide()
			AllStatsFrameStatMeleeSpeed:Hide()
			AllStatsFrameStatMeleePower:Hide()
			AllStatsFrameStatMeleeHit:Hide()
			AllStatsFrameStatMeleeCrit:Hide()
			AllStatsFrameStatMeleeExpert:Hide()
			Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -19)
			AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, 70)
		else
			frame2:Show()
			texture2:Show()
			AllStatsFrameStatMeleeDamage:Show()
			AllStatsFrameStatMeleeSpeed:Show()
			AllStatsFrameStatMeleePower:Show()
			AllStatsFrameStatMeleeHit:Show()
			AllStatsFrameStatMeleeCrit:Show()
			AllStatsFrameStatMeleeExpert:Show()
			Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -111)
			AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, -21.5)
			if not AllStatsFrameStatRangeDamage:IsVisible() then
				AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", clickableFrame4, "BOTTOMLEFT", 40, 1)
			else
				AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", clickableFrame4, "BOTTOMLEFT", 40, 1)
			end
		end
    end
end)

clickableFrame3:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
        if texture3:IsVisible() then
			texture3:Hide()
		else
			if AllStatsFrameStatRangeDamage:IsVisible() then
				texture3:Show()
			else
				texture3:Hide()
			end
		end
	elseif button == "LeftButton" then
		if AllStatsFrameStatRangeDamage:IsVisible() then
			texture3:Hide()
			AllStatsFrameStatRangeDamage:Hide()
			AllStatsFrameStatRangeSpeed:Hide()
			AllStatsFrameStatRangePower:Hide()
			AllStatsFrameStatRangeHit:Hide()
			AllStatsFrameStatRangeCrit:Hide()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -19)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", clickableFrame4, "BOTTOMLEFT", 40, 1)
		else
			frame3:Show()
			texture3:Show()
			AllStatsFrameStatRangeDamage:Show()
			AllStatsFrameStatRangeSpeed:Show()
			AllStatsFrameStatRangePower:Show()
			AllStatsFrameStatRangeHit:Show()
			AllStatsFrameStatRangeCrit:Show()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -92)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", clickableFrame4, "BOTTOMLEFT", 40, 1)
		end
    end
end)

clickableFrame4:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
        if texture4:IsVisible() then
			texture4:Hide()
		else
			if AllStatsFrameStatSpellDamage:IsVisible() then
				texture4:Show()
			else
				texture4:Hide()
			end
		end
	elseif button == "LeftButton" then
		if AllStatsFrameStatSpellDamage:IsVisible() then
			texture4:Hide()
			AllStatsFrameStatSpellDamage:Hide()
			AllStatsFrameStatSpellHeal:Hide()
			AllStatsFrameStatSpellHit:Hide()
			AllStatsFrameStatSpellCrit:Hide()
			AllStatsFrameStatSpellHaste:Hide()
			AllStatsFrameStatSpellRegen:Hide()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -19)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", AllStatsFrameStatSpellRegen, "BOTTOMLEFT", 0, 45)
		else
			frame4:Show()
			texture4:Show()
			AllStatsFrameStatSpellDamage:Show()
			AllStatsFrameStatSpellHeal:Show()
			AllStatsFrameStatSpellHit:Show()
			AllStatsFrameStatSpellCrit:Show()
			AllStatsFrameStatSpellHaste:Show()
			AllStatsFrameStatSpellRegen:Show()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -110)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", AllStatsFrameStatSpellRegen, "BOTTOMLEFT", 0, -45)
		end
    end
end)

clickableFrame5:SetScript("OnClick", function(self, button)
	if button == "RightButton" then
        if texture5:IsVisible() then
			texture5:Hide()
		else
			if AllStatsFrameStatArmor:IsVisible() then
				texture5:Show()
			else
				texture5:Hide()
			end
		end
	elseif button == "LeftButton" then
		if AllStatsFrameStatArmor:IsVisible() then
			texture5:Hide()
			AllStatsFrameStatArmor:Hide()
			AllStatsFrameStatDefense:Hide()
			AllStatsFrameStatDodge:Hide()
			AllStatsFrameStatParry:Hide()
			AllStatsFrameStatBlock:Hide()
			AllStatsFrameStatResil:Hide()
		else
			frame5:Show()
			texture5:Show()
			AllStatsFrameStatArmor:Show()
			AllStatsFrameStatDefense:Show()
			AllStatsFrameStatDodge:Show()
			AllStatsFrameStatParry:Show()
			AllStatsFrameStatBlock:Show()
			AllStatsFrameStatResil:Show()
		end
    end
end)

local function caster_collapse()
if AllStatsFrameStatMeleeDamage:IsVisible() then
	-- Melee
	frame2:Hide()
	texture2:Hide()
	AllStatsFrameStatMeleeDamage:Hide()
	AllStatsFrameStatMeleeSpeed:Hide()
	AllStatsFrameStatMeleePower:Hide()
	AllStatsFrameStatMeleeHit:Hide()
	AllStatsFrameStatMeleeCrit:Hide()
	AllStatsFrameStatMeleeExpert:Hide()
	Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -19)
	AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, 70)
end
	
if AllStatsFrameStatRangeDamage:IsVisible() then
	-- Ranged
	frame3:Hide()
	texture3:Hide()
	AllStatsFrameStatRangeDamage:Hide()
	AllStatsFrameStatRangeSpeed:Hide()
	AllStatsFrameStatRangePower:Hide()
	AllStatsFrameStatRangeHit:Hide()
	AllStatsFrameStatRangeCrit:Hide()
	Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -19)
	AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", AllStatsFrameStat5, "BOTTOMLEFT", 0, -62)
end
end

local function melee_collapse()
	if AllStatsFrameStatRangeDamage:IsVisible() then
			frame3:Hide()
			texture3:Hide()
			AllStatsFrameStatRangeDamage:Hide()
			AllStatsFrameStatRangeSpeed:Hide()
			AllStatsFrameStatRangePower:Hide()
			AllStatsFrameStatRangeHit:Hide()
			AllStatsFrameStatRangeCrit:Hide()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -19)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", AllStatsFrameStatRangeCrit, "BOTTOMLEFT", 0, 52)
	end
	
	if AllStatsFrameStatSpellDamage:IsVisible() then
			frame4:Hide()
			texture4:Hide()
			AllStatsFrameStatSpellDamage:Hide()
			AllStatsFrameStatSpellHeal:Hide()
			AllStatsFrameStatSpellHit:Hide()
			AllStatsFrameStatSpellCrit:Hide()
			AllStatsFrameStatSpellHaste:Hide()
			AllStatsFrameStatSpellRegen:Hide()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -19)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", 18, -23)
	end
end

local function hybrid_collapse()
if AllStatsFrameStatRangeDamage:IsVisible() then
			frame3:Hide()
			texture3:Hide()
			AllStatsFrameStatRangeDamage:Hide()
			AllStatsFrameStatRangeSpeed:Hide()
			AllStatsFrameStatRangePower:Hide()
			AllStatsFrameStatRangeHit:Hide()
			AllStatsFrameStatRangeCrit:Hide()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -19)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", AllStatsFrameStatRangeCrit, "BOTTOMLEFT", 0, 52)
	end
end

local function hunter_collapse()
	if AllStatsFrameStatMeleeDamage:IsVisible() then
		-- Melee
		frame2:Hide()
		texture2:Hide()
		AllStatsFrameStatMeleeDamage:Hide()
		AllStatsFrameStatMeleeSpeed:Hide()
		AllStatsFrameStatMeleePower:Hide()
		AllStatsFrameStatMeleeHit:Hide()
		AllStatsFrameStatMeleeCrit:Hide()
		AllStatsFrameStatMeleeExpert:Hide()
		Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -19)
		AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, 70)
	end
	
	if AllStatsFrameStatSpellDamage:IsVisible() then
			frame4:Hide()
			texture4:Hide()
			AllStatsFrameStatSpellDamage:Hide()
			AllStatsFrameStatSpellHeal:Hide()
			AllStatsFrameStatSpellHit:Hide()
			AllStatsFrameStatSpellCrit:Hide()
			AllStatsFrameStatSpellHaste:Hide()
			AllStatsFrameStatSpellRegen:Hide()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -19)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", Defenses, "BOTTOMLEFT", 18, -23)
	end
end

function PrintStats()
	local str = AllStatsFrameStat1;
	local agi = AllStatsFrameStat2;
	local sta = AllStatsFrameStat3;
	local int = AllStatsFrameStat4;
	local spi = AllStatsFrameStat5;

	local md = AllStatsFrameStatMeleeDamage;
	local ms = AllStatsFrameStatMeleeSpeed;
	local mp = AllStatsFrameStatMeleePower;
	local mh = AllStatsFrameStatMeleeHit;
	local mc = AllStatsFrameStatMeleeCrit;
	local me = AllStatsFrameStatMeleeExpert;

	local rd = AllStatsFrameStatRangeDamage;
	local rs = AllStatsFrameStatRangeSpeed;
	local rp = AllStatsFrameStatRangePower;
	local rh = AllStatsFrameStatRangeHit;
	local rc = AllStatsFrameStatRangeCrit;

	local sd = AllStatsFrameStatSpellDamage;
	local she = AllStatsFrameStatSpellHeal;
	local shi = AllStatsFrameStatSpellHit;
	local sc = AllStatsFrameStatSpellCrit;
	local sha = AllStatsFrameStatSpellHaste;
	local sr = AllStatsFrameStatSpellRegen;

	local armor = AllStatsFrameStatArmor;
	local def = AllStatsFrameStatDefense;
	local dodge = AllStatsFrameStatDodge;
	local parry = AllStatsFrameStatParry;
	local block = AllStatsFrameStatBlock;
	local res = AllStatsFrameStatResil;


	PaperDollFrame_SetStat(str, 1);
	PaperDollFrame_SetStat(agi, 2);
	PaperDollFrame_SetStat(sta, 3);
	PaperDollFrame_SetStat(int, 4);
	PaperDollFrame_SetStat(spi, 5);

	PaperDollFrame_SetDamage(md);
	md:SetScript("OnEnter", CharacterDamageFrame_OnEnter);
	PaperDollFrame_SetAttackSpeed(ms);
	PaperDollFrame_SetAttackPower(mp);
	PaperDollFrame_SetRating(mh, CR_HIT_MELEE);
	PaperDollFrame_SetMeleeCritChance(mc);
	PaperDollFrame_SetExpertise(me);

	PaperDollFrame_SetRangedDamage(rd);
	rd:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter);
	PaperDollFrame_SetRangedAttackSpeed(rs);
	PaperDollFrame_SetRangedAttackPower(rp);
	PaperDollFrame_SetRating(rh, CR_HIT_RANGED);
	PaperDollFrame_SetRangedCritChance(rc);

	PaperDollFrame_SetSpellBonusDamage(sd);
	sd:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter);
	PaperDollFrame_SetSpellBonusHealing(she);
	PaperDollFrame_SetRating(shi, CR_HIT_SPELL);
	PaperDollFrame_SetSpellCritChance(sc);
	sc:SetScript("OnEnter", CharacterSpellCritChance_OnEnter);
	PaperDollFrame_SetSpellHaste(sha);
	PaperDollFrame_SetManaRegen(sr);

	PaperDollFrame_SetArmor(armor);
	PaperDollFrame_SetDefense(def);
	PaperDollFrame_SetDodge(dodge);
	PaperDollFrame_SetParry(parry);
	PaperDollFrame_SetBlock(block);
	PaperDollFrame_SetResilience(res);
	
	if not AllStatsFrameStat1:IsVisible() then
			texture:Hide()
			AllStatsFrameStat1:Hide()
			AllStatsFrameStat2:Hide()
			AllStatsFrameStat3:Hide()
			AllStatsFrameStat4:Hide()
			AllStatsFrameStat5:Hide()
			Melee:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, -14)
			AllStatsFrameStatMeleeDamage:SetPoint("TOPLEFT", AllStatsFrameStat5, "BOTTOMLEFT", 0, 56)
		else
			texture:Show()
			AllStatsFrameStat1:Show()
			AllStatsFrameStat2:Show()
			AllStatsFrameStat3:Show()
			AllStatsFrameStat4:Show()
			AllStatsFrameStat5:Show()
			Melee:SetPoint("TOPLEFT", MyFrame, "TOPLEFT", 0, -93)
			AllStatsFrameStatMeleeDamage:SetPoint("TOPLEFT", AllStatsFrameStat5, "BOTTOMLEFT", 0, -24)
		end
		if not AllStatsFrameStatMeleeDamage:IsVisible() then
			texture2:Hide()
			AllStatsFrameStatMeleeDamage:Hide()
			AllStatsFrameStatMeleeSpeed:Hide()
			AllStatsFrameStatMeleePower:Hide()
			AllStatsFrameStatMeleeHit:Hide()
			AllStatsFrameStatMeleeCrit:Hide()
			AllStatsFrameStatMeleeExpert:Hide()
			Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -19)
			AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, 70)
		else
			texture2:Show()
			AllStatsFrameStatMeleeDamage:Show()
			AllStatsFrameStatMeleeSpeed:Show()
			AllStatsFrameStatMeleePower:Show()
			AllStatsFrameStatMeleeHit:Show()
			AllStatsFrameStatMeleeCrit:Show()
			AllStatsFrameStatMeleeExpert:Show()
			Ranged:SetPoint("TOPLEFT", Melee, "TOPLEFT", 0, -111)
			AllStatsFrameStatRangeDamage:SetPoint("TOPLEFT", AllStatsFrameStatMeleeExpert, "BOTTOMLEFT", 0, -21.5)
		end
		if not AllStatsFrameStatRangeDamage:IsVisible() then
			texture3:Hide()
			AllStatsFrameStatRangeDamage:Hide()
			AllStatsFrameStatRangeSpeed:Hide()
			AllStatsFrameStatRangePower:Hide()
			AllStatsFrameStatRangeHit:Hide()
			AllStatsFrameStatRangeCrit:Hide()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -19)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", AllStatsFrameStatRangeCrit, "BOTTOMLEFT", 0, 52)
		else
			texture3:Show()
			AllStatsFrameStatRangeDamage:Show()
			AllStatsFrameStatRangeSpeed:Show()
			AllStatsFrameStatRangePower:Show()
			AllStatsFrameStatRangeHit:Show()
			AllStatsFrameStatRangeCrit:Show()
			Spell:SetPoint("TOPLEFT", Ranged, "TOPLEFT", 0, -92)
			AllStatsFrameStatSpellDamage:SetPoint("TOPLEFT", AllStatsFrameStatRangeCrit, "BOTTOMLEFT", 0, -21)
		end
		if not AllStatsFrameStatSpellDamage:IsVisible() then
			texture4:Hide()
			AllStatsFrameStatSpellDamage:Hide()
			AllStatsFrameStatSpellHeal:Hide()
			AllStatsFrameStatSpellHit:Hide()
			AllStatsFrameStatSpellCrit:Hide()
			AllStatsFrameStatSpellHaste:Hide()
			AllStatsFrameStatSpellRegen:Hide()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -19)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", AllStatsFrameStatSpellRegen, "BOTTOMLEFT", 0, 45)
		else
			texture4:Show()
			AllStatsFrameStatSpellDamage:Show()
			AllStatsFrameStatSpellHeal:Show()
			AllStatsFrameStatSpellHit:Show()
			AllStatsFrameStatSpellCrit:Show()
			AllStatsFrameStatSpellHaste:Show()
			AllStatsFrameStatSpellRegen:Show()
			Defenses:SetPoint("TOPLEFT", Spell, "TOPLEFT", 0, -110)
			AllStatsFrameStatArmor:SetPoint("TOPLEFT", AllStatsFrameStatSpellRegen, "BOTTOMLEFT", 0, -45)
		end
		
		if not AllStatsFrameStatArmor:IsVisible() then
			texture5:Hide()
			AllStatsFrameStatArmor:Hide()
			AllStatsFrameStatDefense:Hide()
			AllStatsFrameStatDodge:Hide()
			AllStatsFrameStatParry:Hide()
			AllStatsFrameStatBlock:Hide()
			AllStatsFrameStatResil:Hide()
		else
			texture5:Show()
			AllStatsFrameStatArmor:Show()
			AllStatsFrameStatDefense:Show()
			AllStatsFrameStatDodge:Show()
			AllStatsFrameStatParry:Show()
			AllStatsFrameStatBlock:Show()
			AllStatsFrameStatResil:Show()
		end
		local _, class = UnitClass("player")  -- The second return value is the unlocalized class name

	if class == "PRIEST" or class == "WARLOCK" or class == "MAGE" then
		if PaperDollFrame:IsVisible() then
		caster_collapse()
		end
	elseif class == "ROGUE" or class == "WARRIOR" then
		if PaperDollFrame:IsVisible() then
		melee_collapse()
		end
	elseif class == "SHAMAN" or class == "DRUID" or class == "PALADIN" then
		if PaperDollFrame:IsVisible() then
		hybrid_collapse()
		end
	elseif class == "HUNTER" then
		if PaperDollFrame:IsVisible() then
		hunter_collapse()
		end
	end
end

local AllStatsShowFrame = true;

function AllStatsButtonShowFrame_OnClick()
	AllStatsShowFrame = not AllStatsShowFrame;
	if AllStatsShowFrame then
		AllStatsFrame:Show();
	else
		AllStatsFrame:Hide();
	end
end



-- Todo MacroFrame and PlayerTalentFrame to move when character frame is open