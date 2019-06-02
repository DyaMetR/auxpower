--[[------------------------------------------------------------------
  CONFIGURATION
  Manages serverside and clientside configuration
]]--------------------------------------------------------------------

-- Include menu
AUXPOW:IncludeFile("menu.lua");

-- Default configuration
local DEFAULT_CONFIG = {
  ["sv_auxpow_enabled"] = {value = 1, sv = true, replicated = true},
  ["sv_auxpow_flashlight_ep2"] = {value = 0, sv = true, replicated = true},
  ["sv_auxpow_sprint_enabled"] = {value = 1, sv = true},
  ["sv_auxpow_oxygen_enabled"] = {value = 1, sv = true},
  ["sv_auxpow_oxygen_health_recovery_limit"] = {value = 1, sv = true},
  ["sv_auxpow_flashlight_enabled"] = {value = 1, sv = true},
  ["sv_auxpow_recovery_mul"] = {value = 1, sv = true},
  ["sv_auxpow_expense_mul"] = {value = 1, sv = true},
  ["sv_auxpow_sprint_mul"] = {value = 1, sv = true},
  ["sv_auxpow_oxygen_mul"] = {value = 1, sv = true},
  ["sv_auxpow_flashlight_mul"] = {value = 1, sv = true},
  ["sv_auxpow_ep2flash_recovery_mul"] = {value = 1, sv = true},
  ["sv_auxpow_ep2flash_expense_mul"] = {value = 1, sv = true},
  ["cl_auxpow_drawhud"] = {value = 1},
  ["cl_auxpow_drawhudep2"] = {value = 1},
  ["cl_auxpow_sprint_sound_enable"] = {value = 1},
  ["cl_auxpow_hudcol_r"] = {value = 255},
  ["cl_auxpow_hudcol_g"] = {value = 238},
  ["cl_auxpow_hudcol_b"] = {value = 23},
  ["cl_auxpow_hudcol_crit_r"] = {value = 255},
  ["cl_auxpow_hudcol_crit_g"] = {value = 0},
  ["cl_auxpow_hudcol_crit_b"] = {value = 0},
  ["cl_auxpow_ep2col_r"] = {value = 255},
  ["cl_auxpow_ep2col_g"] = {value = 238},
  ["cl_auxpow_ep2col_b"] = {value = 23},
  ["cl_auxpow_ep2col_crit_r"] = {value = 255},
  ["cl_auxpow_ep2col_crit_g"] = {value = 20},
  ["cl_auxpow_ep2col_crit_b"] = {value = 20},
  ["cl_auxpow_hudpos_x"] = {value = 25},
  ["cl_auxpow_hudpos_y"] = {value = 87},
  ["cl_auxpow_ep2pos_x"] = {value = 431},
  ["cl_auxpow_ep2pos_y"] = {value = 20}
}

-- Initialize ConVars
for convar, config in pairs(DEFAULT_CONFIG) do
  if (config.sv) then
    if CLIENT and config.replicated then
      CreateClientConVar(convar, config.value);
    end
    if SERVER then
      local flags = {FCVAR_ARCHIVE, FCVAR_LUA_SERVER, FCVAR_NOTIFY};
      if (config.replicated) then table.insert(flags, FCVAR_REPLICATED); end
      CreateConVar(convar, config.value, flags);
    end
  else
    if CLIENT then
      CreateClientConVar(convar, config.value, true);
    end
  end
end

--[[
  Returns whether the addon is enabled on the server
  @return {boolean} enabled
]]
function AUXPOW:IsEnabled()
  return GetConVar("sv_auxpow_enabled"):GetInt() > 0;
end

--[[
  Is the Episode 2 flashlight enabled?
  @return {boolean} enabled
]]
function AUXPOW:IsEP2Mode()
  return GetConVar("sv_auxpow_flashlight_ep2"):GetInt() > 0;
end

if SERVER then
  --[[
    Returns the power recovery multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetRecoveryMul()
    return GetConVar("sv_auxpow_recovery_mul"):GetFloat();
  end

  --[[
    Returns the power expense multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetExpenseMul()
    return GetConVar("sv_auxpow_expense_mul"):GetFloat();
  end

  --[[
    Returns whether sprinting expense is enabled
    @param {boolean} enabled
  ]]
  function AUXPOW:IsSprintEnabled()
    return GetConVar("sv_auxpow_sprint_enabled"):GetInt() > 0;
  end

  --[[
    Returns whether oxygen expense and drowning is enabled
    @param {boolean} enabled
  ]]
  function AUXPOW:IsOxygenEnabled()
    return GetConVar("sv_auxpow_oxygen_enabled"):GetInt() > 0;
  end

  --[[
    Should health cap to maximum amount when regenerating health?
    @return {boolean} enabled
  ]]
  function AUXPOW:IsOxygenHealthRegenerationLimited()
    return GetConVar("sv_auxpow_oxygen_health_recovery_limit"):GetInt() > 0;
  end

  --[[
    Returns whether flashlight expense is enabled
    @param {boolean} enabled
  ]]
  function AUXPOW:IsFlashlightEnabled()
    return GetConVar("sv_auxpow_flashlight_enabled"):GetInt() > 0;
  end

  --[[
    Returns the sprint power expense multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetSprintMul()
    return GetConVar("sv_auxpow_sprint_mul"):GetFloat();
  end

  --[[
    Returns the oxygen power expense multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetOxygenMul()
    return GetConVar("sv_auxpow_oxygen_mul"):GetFloat();
  end

  --[[
    Returns the flashlight power expense multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetFlashlightMul()
    return GetConVar("sv_auxpow_flashlight_mul"):GetFloat();
  end

  --[[
    Returns the Episode 2 flashlight recovery multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetEP2RecoveryMul()
    return GetConVar("sv_auxpow_ep2flash_recovery_mul"):GetFloat();
  end

  --[[
    Returns the Episode 2 flashlight expense multiplicator
    @return {number} multiplier
  ]]
  function AUXPOW:GetEP2ExpenseMul()
    return GetConVar("sv_auxpow_ep2flash_expense_mul"):GetFloat();
  end

  --[[
    Reset serverside values to default
  ]]
  concommand.Add("sv_auxpow_reset", function(player, com, args)
    if (player:IsAdmin() or game.SinglePlayer()) then
      for convar, config in pairs(DEFAULT_CONFIG) do
        if (config.sv) then
          RunConsoleCommand(convar, config.value);
        end
      end
    end
  end);
end

if CLIENT then

  --[[
    Should the default HUD display
    @return {boolean} enabled
  ]]
  function AUXPOW:IsHUDEnabled()
    return GetConVar("cl_auxpow_drawhud"):GetInt() > 0;
  end

  --[[
    Should the flashlight HUD component draw
    @return {boolean} enabled
  ]]
  function AUXPOW:IsEP2HUDEnabled()
    return GetConVar("cl_auxpow_drawhudep2"):GetInt() > 0;
  end

  --[[
    Should the sprint sounds be heard
    @return {boolean} enabled
  ]]
  function AUXPOW:IsSprintSoundEnabled()
    return GetConVar("cl_auxpow_sprint_sound_enable"):GetInt() > 0;
  end

  --[[
    Returns default HUD position
    @return {number} x
    @return {number} y
  ]]
  function AUXPOW:GetHUDPos()
    return GetConVar("cl_auxpow_hudpos_x"):GetInt(), GetConVar("cl_auxpow_hudpos_y"):GetInt();
  end

  --[[
    Returns default HUD colour
    @return {Color} colour
  ]]
  function AUXPOW:GetHUDColour()
    return Color(GetConVar("cl_auxpow_hudcol_r"):GetInt(), GetConVar("cl_auxpow_hudcol_g"):GetInt(), GetConVar("cl_auxpow_hudcol_b"):GetInt());
  end

  --[[
    Returns default HUD critical colour
    @return {Color} colour
  ]]
  function AUXPOW:GetHUDCritColour()
    return Color(GetConVar("cl_auxpow_hudcol_crit_r"):GetInt(), GetConVar("cl_auxpow_hudcol_crit_g"):GetInt(), GetConVar("cl_auxpow_hudcol_crit_b"):GetInt());
  end

  --[[
    Returns Episode 2 flashlight HUD position
    @return {number} x
    @return {number} y
  ]]
  function AUXPOW:GetEP2HUDPos()
    return GetConVar("cl_auxpow_ep2pos_x"):GetInt(), GetConVar("cl_auxpow_ep2pos_y"):GetInt();
  end

  --[[
    Returns Episode 2 flashlight HUD colour
    @return {Color} colour
  ]]
  function AUXPOW:GetEP2HUDColour()
    return Color(GetConVar("cl_auxpow_ep2col_r"):GetInt(), GetConVar("cl_auxpow_ep2col_g"):GetInt(), GetConVar("cl_auxpow_ep2col_b"):GetInt());
  end

  --[[
    Returns Episode 2 flashlight HUD critical colour
    @return {Color} colour
  ]]
  function AUXPOW:GetEP2HUDCritColour()
    return Color(GetConVar("cl_auxpow_ep2col_crit_r"):GetInt(), GetConVar("cl_auxpow_ep2col_crit_g"):GetInt(), GetConVar("cl_auxpow_ep2col_crit_b"):GetInt());
  end

  --[[
    Reset clientside values to default
  ]]
  concommand.Add("cl_auxpow_reset", function(player, com, args)
    for convar, config in pairs(DEFAULT_CONFIG) do
      if (not config.sv) then
        RunConsoleCommand(convar, config.value);
      end
    end
  end);

end
