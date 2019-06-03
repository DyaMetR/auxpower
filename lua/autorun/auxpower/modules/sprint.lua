--[[------------------------------------------------------------------
  SPRINT
  Limited running time
]]--------------------------------------------------------------------

local NET = "auxpow_sprint";

if SERVER then

  util.AddNetworkString(NET);

  -- Parameters
  local DEFAULT_SPRINT_RATE = 0.09;
  local DEFAULT_DOWNTIME = 1;
  local ID, LABEL = "sprint", "SPRINT";

  --[[
    Returns whether a player is using any movement based input
    @param {Player} player
    @return {boolean} is using input
  ]]
  local function IsUsingMoveInput(player)
    return player:KeyDown(IN_FORWARD) or player:KeyDown(IN_BACK) or player:KeyDown(IN_MOVELEFT) or player:KeyDown(IN_MOVERIGHT);
  end

  --[[
    Returns whether a player can sprint
    @param {Player} player
    @return {boolean} can sprint
  ]]
  local function CanSprint(player)
    return (AUXPOW:HasPower(player) and not player.AUXPOW.exhaust) or not AUXPOW:IsSprintEnabled();
  end

  --[[
    Send to the client whether they can sprint or not
    @param {Player} player
  ]]
  local function UpdateCanSprint(player)
    net.Start(NET);
    net.WriteBool(CanSprint(player));
    net.Send(player);
  end

  --[[
    Controls player movement to slow down player running speed if there's no
    power
  ]]
  hook.Add("Move", "auxpow_sprint_move", function(player, mv)
    if (CanSprint(player)) then return; end
    mv:SetMaxSpeed(player:GetWalkSpeed());
  end);

  --[[
    Runs the sprinting logic
  ]]
  hook.Add("AuxPowerTick", "auxpow_sprint", function(player)
    if (not AUXPOW:IsSprintEnabled()) then AUXPOW:RemoveExpense(player, ID); return; end
    -- Temporaly disable player ability to sprint if it's exhausted
    if (not AUXPOW:HasPower(player) and not player.AUXPOW.exhaust) then
      player.AUXPOW.exhaust = true;
      UpdateCanSprint(player);
    elseif (AUXPOW:HasPower(player) and AUXPOW:GetPower(player) > 0.11 and player.AUXPOW.exhaust) then
      player.AUXPOW.exhaust = false;
      UpdateCanSprint(player);
    end

    -- Sprint
    if (player:IsSprinting() and not player.AUXPOW.exhaust and IsUsingMoveInput(player) and player:GetVelocity():Length() > player:GetWalkSpeed()) then
      AUXPOW:AddExpense(player, ID, LABEL, DEFAULT_SPRINT_RATE / AUXPOW:GetSprintMul(), nil, DEFAULT_DOWNTIME);
    else
      AUXPOW:RemoveExpense(player, ID);
    end
  end);

  --[[
    Spawns the player with the variable to know if player is exhausted
  ]]
  hook.Add("AuxPowerInitialize", "auxpow_sprint_init", function(player)
    player.AUXPOW.exhaust = false;

    -- Address CW 2.0 conflicts
    -- CW 2.0
    if (CW_Move ~= nil) then
      hook.Add("Move", "CW_Move", function(ply, mv)
        if (not CanSprint(player)) then return; end
        CW_Move(ply, mv);
      end);
    end
  end);

end

if CLIENT then
  -- Parameters
  local SPRINT_SOUND = "player/suit_sprint.wav";
  local EXHAUST_SOUND = "common/wpn_denyselect.wav";

  -- Variables
  local canSprint = true;
  local sprinted = false;
  local exhausted = false;
  local exhaustPressed = false;

  --[[
    Check if the player starts sprinting, and then play the sound
    Make it Think in case you press Shift while standing still, and then start running
  ]]
  hook.Add("Think", "auxpow_sprint_sound", function()
    if (LocalPlayer():InVehicle() or not AUXPOW:IsSprintSoundEnabled()) then return; end
    if (LocalPlayer():IsSprinting()) then
      if (AUXPOW:GetPower() >= 0.1) then
        if (not sprinted) then
          LocalPlayer():EmitSound(SPRINT_SOUND);
          sprinted = true;
        end
        exhausted = false;
      elseif (AUXPOW:GetPower() <= 0) then
        exhausted = true;
      end
    elseif (not LocalPlayer():IsSprinting()) then
      sprinted = false;
      if (AUXPOW:GetPower() >= 0.1) then
        exhausted = false;
      end
    end
  end);

  --[[
    Makes the denial sound if exhausted
  ]]
  hook.Add("KeyPress", "auxpow_exhaust", function(player, key)
    if (AUXPOW:IsSprintSoundEnabled() and LocalPlayer():Alive() and not LocalPlayer():InVehicle() and key == IN_SPEED and exhausted and not exhaustPressed) then
      LocalPlayer():EmitSound(EXHAUST_SOUND);
      exhaustPressed = true;
    end
  end);

  hook.Add("KeyRelease", "auxpow_exhaust_release", function(player, key)
    if (AUXPOW:IsSprintSoundEnabled() and LocalPlayer():Alive() and not LocalPlayer():InVehicle() and key == IN_SPEED and exhaustPressed) then
      exhaustPressed = false;
    end
  end);

  --[[
    Predicts movement based on whether the player can sprint or not
  ]]
  hook.Add("Move", "auxpow_sprint_predict", function(player, mv)
    if (canSprint) then return; end
    mv:SetMaxSpeed(player:GetWalkSpeed());
  end);

  --[[
    Overrides H.E.V sounds by Agent Agrimar
  ]]
  hook.Add("Initialize", "auxpow_init", function()
    hook.Add("KeyPress", "RetroShift", function(ply, key) return; end);
  end);

  net.Receive(NET, function(len)
    canSprint = net.ReadBool();
  end);
end
