--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.8) ~  Much Love, Ferib 

]]--

function(v1,v2,v3,v4) local v5=aura_env.ids;local v6=aura_env.GetSpellCooldown;local v7=aura_env.GetSafeSpellIcon;local v8=nil;local v9=0 + 0 ;local v10,v11,v12=0 + 0 ,957 -(892 + 65) ,0 -0 ;if (v3=="Arcane Explosion") then local v14=0 -0 ;while true do if (v14==(1 -0)) then v10,v11,v12=v6(v8);break;end if (v14==(350 -(87 + 263))) then v8=v5.ArcaneExplosion;v9=v7(v8);v14=181 -(67 + 113) ;end end end if (v3=="Blizzard") then v8=v5.Blizzard;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Comet Storm") then local v16=0;while true do if (v16==(1 + 0)) then v10,v11,v12=v6(v8);break;end if (v16==(0 -0)) then v8=v5.CometStorm;v9=v7(v8);v16=1 + 0 ;end end end if (v3=="Cone of Cold") then local v17=0 -0 ;while true do if (v17==(953 -(802 + 150))) then v10,v11,v12=v6(v8);break;end if (v17==(0 -0)) then v8=v5.ConeOfCold;v9=v7(v8);v17=1 -0 ;end end end if (v3=="Flurry") then v8=v5.Flurry;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Freeze") then v8=v5.Freeze;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Frostfire Bolt") then v8=v5.FrostfireBolt;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Frozen Orb") then v8=v5.FrozenOrb;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Frostbolt") then v8=v5.Frostbolt;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Glacial Spike") then local v23=0;while true do if (v23==(0 + 0)) then v8=v5.GlacialSpike;v9=v7(v8);v23=1;end if (v23==(998 -(915 + 82))) then v10,v11,v12=v6(v8);break;end end end if (v3=="Ice Lance") then v8=v5.IceLance;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Ice Nova") then local v25=0 -0 ;while true do if (v25==(0 + 0)) then v8=v5.IceNova;v9=v7(v8);v25=1;end if (v25==(1 -0)) then v10,v11,v12=v6(v8);break;end end end if (v3=="Icy Veins") then v8=v5.IcyVeins;v9=v7(v8);v10,v11,v12=v6(v8);end if (v3=="Ray of Frost") then local v27=0;while true do if ((1188 -(1069 + 118))==v27) then v10,v11,v12=v6(v8);break;end if (v27==(0 -0)) then v8=v5.RayOfFrost;v9=v7(v8);v27=1;end end end if (v3=="Shifting Power") then local v28=0 -0 ;while true do if (v28==(0 + 0)) then v8=v5.ShiftingPower;v9=v7(v8);v28=1 -0 ;end if (v28==(1 + 0)) then v10,v11,v12=v6(v8);break;end end end if (v3=="Clear") then local v29=0;while true do if (0==v29) then v9=791 -(368 + 423) ;v10,v11,v12=0 -0 ,0,18 -(10 + 8) ;break;end end end v1[1]={show=true,changed=true,icon=v9,spell=v8,cooldown=v11,charges=v10,maxCharges=v12};return true;end;