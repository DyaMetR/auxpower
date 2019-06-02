--[[------------------------------------------------------------------
  OXYGEN
  Limited underwater time
]]--------------------------------------------------------------------

if SERVER then

  -- Parameters
  local DEFAULT_SUPPLY_RATE = 0.14;
  local DEFAULT_DROWN_RATE = 0.07;
  local DEFAULT_DROWN_DAMAGE_RATE = 1;
  local DEFAULT_DROWN_RECOVERY_RATE = 2;
  local DEFAULT_DROWN_DAMAGE_AMOUNT = 10;
  local DEFAULT_DOWNTIME = 1.2;
  local ID, LABEL = "oxygen", "OXYGEN";

  --[[
    Damages the player by drowning
    @param {Player} player
  ]]
  local function TakeDrowningDamage(player, damage)
    damage = damage or DEFAULT_DROWN_DAMAGE_AMOUNT;

    -- Build drowning damage
    local dmginfo = DamageInfo();
    dmginfo:SetDamage(DEFAULT_DROWN_DAMAGE_AMOUNT);
    dmginfo:SetDamageType(DMG_DROWN);
    dmginfo:SetAttacker(player);
    dmginfo:SetInflictor(player);
    dmginfo:SetDamageForce(Vector(0, 0, 0));

    -- Take drowning damage
    player:TakeDamageInfo(dmginfo);
  end

  --[[
    Adds a power expense and drowns the player if it gets depleted
    @param {Player} player
  ]]
  local function PlayerUnderwater(player)
    -- Add expense
    AUXPOW:AddExpense(player, ID, LABEL, DEFAULT_SUPPLY_RATE / AUXPOW:GetOxygenMul(), nil, DEFAULT_DOWNTIME);

    -- If depleted, damage player
    if (not AUXPOW:HasPower(player)) then

      -- Timed loop for oxygen depletion
      if (player.AUXPOW.breathe.tick < CurTime()) then
        if (player.AUXPOW.breathe.oxygen > 0) then
          -- Deplete oxygen reserve
          player.AUXPOW.breathe.oxygen = math.Clamp(player.AUXPOW.breathe.oxygen - 0.01 * AUXPOW:GetOxygenMul(), 0, 1);
          player.AUXPOW.breathe.tick = CurTime() + DEFAULT_DROWN_RATE;
        else
          -- Damage player
          TakeDrowningDamage(player);

          -- Accumulate drown damage
          player.AUXPOW.breathe.health = player.AUXPOW.breathe.health + DEFAULT_DROWN_DAMAGE_AMOUNT;

          player.AUXPOW.breathe.tick = CurTime() + DEFAULT_DROWN_DAMAGE_RATE; -- Next damage tick
        end
      end
    end
  end

  --[[
    Removes expense and regenerates player's oxygen and health
    @param {Player} player
  ]]
  local function PlayerBreathe(player)
    -- Remove expense
    AUXPOW:RemoveExpense(player, ID);

    -- Regenerate oxygen
    if (player.AUXPOW.breathe.tick < CurTime()) then
      player.AUXPOW.breathe.oxygen = math.Clamp(player.AUXPOW.breathe.oxygen + 0.03, 0, 1);
      player.AUXPOW.breathe.tick = CurTime() + DEFAULT_SUPPLY_RATE;
    end

    -- Regenerate health
    if (player.AUXPOW.breathe.health > 0 and player.AUXPOW.breathe.hTick < CurTime()) then
      player:SetHealth(player:Health() + math.min(DEFAULT_DROWN_DAMAGE_AMOUNT, player.AUXPOW.breathe.health));
      player.AUXPOW.breathe.health = math.max(player.AUXPOW.breathe.health - DEFAULT_DROWN_DAMAGE_AMOUNT, 0);

      player.AUXPOW.breathe.hTick = CurTime() + DEFAULT_DROWN_RECOVERY_RATE;
    end
  end

  --[[
    Sets up the variables to keep track of oxygen spent and health lost by drowning
  ]]
  hook.Add("AuxPowerInitialize", "auxpow_oxygen_spawn", function(player)
    player.AUXPOW.breathe = {oxygen = 1, tick = 0, health = 0, hTick = 0};
  end);

  --[[
    Runs the oxygen logic
  ]]
  hook.Add("AuxPowerTick", "auxpow_oxygen", function(player)
    if (not AUXPOW:IsOxygenEnabled()) then AUXPOW:RemoveExpense(player, ID); return; end
    if (player:WaterLevel() >= 3) then
      PlayerUnderwater(player);
    else
      PlayerBreathe(player);
    end
  end);

end
