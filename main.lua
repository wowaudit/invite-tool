Wit = LibStub("AceAddon-3.0"):NewAddon("Wowaudit Invite Tool", "AceTimer-3.0")
local addon = Wit
local AceGUI = LibStub("AceGUI-3.0")
local inviteString
local invitingPreview
local uninvitingPreview
local notInSetup
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
    frame:SetLayout("Flow")
    frame:SetWidth(445)
    frame:SetHeight(120)
    frame:EnableResize(false)
    frame.frame:SetFrameStrata("MEDIUM")
    frame.frame:Raise()
    frame.content:SetFrameStrata("MEDIUM")
    frame.content:Raise()

    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Paste invite string here:")
    editbox:SetWidth(200)
    editbox:SetCallback("OnTextChanged", function(widget, event, text) inviteString = text end)
    editbox:DisableButton(true)
    frame:AddChild(editbox)

    local replaceButton = AceGUI:Create("Button")
    replaceButton:SetText("Replace")
    replaceButton:SetWidth(100)
    replaceButton:SetCallback("OnClick", function() addon:Replace(false) end)
    frame:AddChild(replaceButton)

    local inviteButton = AceGUI:Create("Button")
    inviteButton:SetText("Invite only")
    inviteButton:SetWidth(100)
    inviteButton:SetCallback("OnClick", function() addon:InviteOnly() end)
    frame:AddChild(inviteButton)

    inviteString = ""
    notInSetup = ""
    self.previewer = self:ScheduleRepeatingTimer("UpdatePreview", 0.1)

    frame:SetCallback("OnClose", function(widget)
      AceGUI:Release(widget)
      frameShown = false
      self:CancelTimer(self.previewer)
    end)
  end
end

function addon:UpdatePreview()
  addon:Replace(true)
  notInSetup = ""
end

function addon:Replace(preview)
  addon:Uninvite(preview)
  addon:Invite(preview)
end

function addon:InviteOnly()
  notInSetup = ""
  addon:Uninvite(true)
  addon:Invite(false)

  if (string.len(notInSetup) > 0) then
    print("These players are not in the setup but haven't been removed: "..notInSetup:sub(1, -3))
  end
end

function addon:Uninvite(preview)
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
      local name, rank, subgroup = GetRaidRosterInfo(j)
			if name and myname ~= name then
        local shouldRemain = false
        for inviteTarget in string.gmatch(inviteString, "([^;]+)") do
          if string.find(inviteTarget, name) then
            if preview then
              invitingPreview = invitingPreview - 1
            end
            shouldRemain = true
          end
        end

        if not shouldRemain then
          if preview then
            notInSetup = notInSetup..name..", "
            uninvitingPreview = uninvitingPreview + 1
          else
            UninviteUnit(name)
          end
        end
			end
		end
	end
end

function addon:Invite(preview)
  -- Invite raid members in the string
  for inviteTarget in string.gmatch(inviteString, "([^;]+)") do
    if preview then
      invitingPreview = invitingPreview + 1
    else
      InviteUnit(inviteTarget)
    end
  end

  if preview then
    frame:SetStatusText("Removing "..uninvitingPreview.." | Inviting "..invitingPreview)
  end
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
