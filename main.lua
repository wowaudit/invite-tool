Wit = LibStub("AceAddon-3.0"):NewAddon("Wowaudit Invite Tool")
local addon = Wit
local AceGUI = LibStub("AceGUI-3.0")
local inviteString
local invitingPreview
local uninvitingPreview
local frame
local frameShown

SLASH_WOWAUDITINVITETOOL1, SLASH_WOWAUDITINVITETOOL2 = '/wit', '/wowaudit';

function SlashCmdList.WOWAUDITINVITETOOL(msg, editBox)
  addon:CreateFrame()
end

function addon:CreateFrame()
  if frameShown then
    return
  else
    frame = AceGUI:Create("Frame")
    frame:SetTitle("Wowaudit Invite Tool")
    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget); frameShown = false end)
    frame:SetLayout("Flow")
    frame:SetWidth(345)
    frame:SetHeight(120)
    frame:EnableResize(false)
    frame.frame:SetFrameStrata("MEDIUM")
    frame.frame:Raise()
    frame.content:SetFrameStrata("MEDIUM")
    frame.content:Raise()

    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Paste invite string here:")
    editbox:SetWidth(200)
    editbox:SetCallback("OnTextChanged", function(widget, event, text) inviteString = text; addon:Invite(true) end)
    editbox:DisableButton(true)
    frame:AddChild(editbox)

    local button = AceGUI:Create("Button")
    button:SetText("Send")
    button:SetWidth(100)
    button:SetCallback("OnClick", function() addon:Invite(false) end)
    frame:AddChild(button)
  end
end

function addon:Invite(preview)
  invitingPreview = 0
  uninvitingPreview = 0
  if not (string.len(inviteString) > 0) then
    frame:SetStatusText("Removing "..uninvitingPreview.." | Inviting "..invitingPreview)
    return
  end

  -- Uninvite raid members not in the string
  -- Shamelessly copied and adjusted from ExRT
  local rosterSize = GetNumGroupMembers() or 0
	local myname = UnitName("player")
	for j=rosterSize,1,-1 do
		local nown = GetNumGroupMembers() or 0
		if nown > 0 then
      local name, rank = GetRaidRosterInfo(j)
			if name and myname ~= name then
        local shouldRemain = false
        for inviteTarget in string.gmatch(inviteString, "([^;]+)") do
          if string.find(inviteTarget, name) then
            invitingPreview = invitingPreview - 1
            shouldRemain = true
          end
        end


        if not shouldRemain then
          uninvitingPreview = uninvitingPreview + 1
          if not preview then UninviteUnit(name) end
        end
			end
		end
	end

  -- Invite raid members in the string
  for inviteTarget in string.gmatch(inviteString, "([^;]+)") do
    invitingPreview = invitingPreview + 1
    if not preview then InviteUnit(inviteTarget) end
  end

  if not preview then
    inviteString = ""
    uninvitingPreview = 0
    invitingPreview = 0
  end

  frame:SetStatusText("Removing "..uninvitingPreview.." | Inviting "..invitingPreview)
end

function split(input, separator)
  if separator == nil then
    separator = "%s"
  end
  local t={}
  for str in string.gmatch(input, "([^"..separator.."]+)") do
    table.insert(t, str)
  end
  return t
end
