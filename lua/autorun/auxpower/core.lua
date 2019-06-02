--[[------------------------------------------------------------------
  CORE
  Include all required files and run main hooks
]]--------------------------------------------------------------------

-- Power supply
AUXPOW:IncludeFile("core/power.lua");
AUXPOW:IncludeFile("core/hud.lua");

-- Configuration
AUXPOW:IncludeFile("config/config.lua");

-- Modules
AUXPOW:IncludeFile("modules/sprint.lua");
AUXPOW:IncludeFile("modules/oxygen.lua");
AUXPOW:IncludeFile("modules/flashlight.lua");

if SERVER then
  --[[
    Sets up the player's auxiliary power related variables
    Calls "AuxPowerInitialize" in case you want to run something just
    before the auxiliary power has been initialized in a player
  ]]
  hook.Add("PlayerSpawn", "auxpow_spawn", function(player)
    AUXPOW:SetupPlayer(player);
    hook.Run("AuxPowerInitialize", player);
  end);

  --[[
    Remove timers upon disconnecting
  ]]
  hook.Add("PlayerDisconnect", "auxpow_disconnect", function(player)
    AUXPOW:PlayerDisconnect(player);
  end);

end
