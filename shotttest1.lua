local Soldier
local player
function Activate()
    print("shoot")
    thisEntity:SetThink(SHOOT,"SHOOT",0)
    thisEntity:RegisterAnimTagListener( AnimTagListener )
end

function AnimTagListener( sTagName, nStatus)
    print (" AnimTag: ", sTagName, "Status: " , 1)
    if sTagName == "firing_ready" and nStatus == 1 then Soldier:SetGraphParameterBool("b_firing",true)
    end
    if sTagName == "Finished_Firing" and nStatus == 1 then Soldier:SetGraphParameterBool("b_firing",true)
    end
    if sTagName == "Finished_Reload" and nStatus == 1 then Soldier:SetGraphParameterBool("b_firing",false)
    end
end
function SHOOT()
    Soldier = Entities:FindByClassnameNearest("npc_combine_s",thisEntity:GetAbsOrigin(),10)
    SoldierFoundEnemy()
    
    return .1
end

function SoldierFoundEnemy()
    player = Entities:GetLocalPlayer()
    --print(player)
    local SoldierAttachEyes = Soldier:ScriptLookupAttachment("eyes")
    local SoldierEyeOrigin = Soldier:GetAttachmentOrigin(SoldierAttachEyes)
    local traceTable = 
    {
        startpos = SoldierEyeOrigin;
        endpos = player:GetCenter();
        ignore = Soldier;
        ent = player;
        mask = 33636363;
        min = player:GetBoundingMins();
        max = player:GetBoundingMaxs();
    }

    TraceHull(traceTable)
    if traceTable.enthit == player then
        Soldier:SetGraphLookTarget(player:GetCenter())
        DebugDrawLine(traceTable.startpos,traceTable.pos,0,255,0,false,1)
        DebugDrawLine(traceTable.pos, traceTable.pos + traceTable.normal * 10, 0, 0, 255, false, 1)
        print("foundvalidline")
        Soldier:SetGraphParameterBool("b_firing",true)
    else
        DebugDrawLine(traceTable.startpos, traceTable.endpos, 255, 0, 0, false, 1)    
        print("linenotvalid")
    end
end


