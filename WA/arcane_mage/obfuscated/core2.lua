--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.8) ~  Much Love, Ferib 

]]--

function(v1,v1,v1,v1,v2,v1,v1,v1,v1,v1,v1,v1,v3,v1,v1,v1,v1) if (v2~=UnitGUID("player")) then return false;end aura_env.PrevCast3=aura_env.PrevCast2;aura_env.PrevCast2=aura_env.PrevCast;aura_env.PrevCast=v3;aura_env.PrevCastTime=GetTime();if (v3==aura_env.ids.FrozenOrb) then aura_env.FrozenOrbRemains=GetTime() + 6 + 9 ;elseif (v3==aura_env.ids.ConeOfCold) then aura_env.ConeOfColdLastUsed=GetTime();end local v8=aura_env.KTrigCD;v8("Clear");return;end;