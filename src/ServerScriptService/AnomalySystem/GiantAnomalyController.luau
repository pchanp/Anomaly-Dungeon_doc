local Controller={}
local records=setmetatable({},{__mode="k"})
local valid={IDLE=true,APPROACHING=true,ACTIVE=true,CALMING=true,CALMED=true}
local function setState(giant,state)
 assert(valid[state],"invalid giant state")
 local record=records[giant]
 if not record then record={State="IDLE",CalmedUntil=0};records[giant]=record end
 record.State=state
 giant:SetAttribute("State",state)
 local model=giant:FindFirstChild("Model")
 if model then
  local color=state=="CALMED" and Color3.fromRGB(80,125,145) or state=="CALMING" and Color3.fromRGB(110,90,140) or Color3.fromRGB(62,48,42)
  local imported=model:FindFirstChild("ImportedGiant") for _,part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") and part.Name~="Root" and not (imported and part:IsDescendantOf(imported)) then part.Color=color;part.Transparency=state=="CALMED" and .3 or 0 end end
 end
end
function Controller.Start(giant)
 records[giant]={State="IDLE",CalmedUntil=0}
 giant:SetAttribute("AnomalyId","GIANT")
 giant:SetAttribute("DisplayName","Giant Anomaly")
 giant:SetAttribute("Active",true)
 giant:SetAttribute("CalmMeter",0)
 setState(giant,"IDLE")
 return giant
end
function Controller.GetState(giant) local r=records[giant];return r and r.State or giant:GetAttribute("State") or "IDLE" end
function Controller.SetState(giant,state) setState(giant,state) end
function Controller.SetCalmed(giant,duration)
 local r=records[giant] or {};records[giant]=r;r.CalmedUntil=workspace:GetServerTimeNow()+(duration or 10)
 setState(giant,"CALMING")
 task.delay(1,function() if giant.Parent and Controller.GetState(giant)=="CALMING" then setState(giant,"CALMED") end end)
end
function Controller.SetAggressive(giant) local r=records[giant] or {};records[giant]=r;r.CalmedUntil=0;giant:SetAttribute("CalmMeter",0);setState(giant,"APPROACHING") end
function Controller.GetCalmedUntil(giant) local r=records[giant];return r and r.CalmedUntil or 0 end
return Controller