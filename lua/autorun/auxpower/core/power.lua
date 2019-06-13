--[[------------------------------------------------------------------
  POWER SUPPLY
  Player auxiliary power supply
]]--------------------------------------------------------------------

AUXPOW.NET = { -- Network strings
  amount = "auxpow_amount",
  expenses = "auxpow_expenses"
}

if SERVER then

  -- Parameters
  local DEFAULT_TICKRATE = 0.01;
  local DEFAULT_RECOVERY_RATE = 0.09;
  local DEFAULT_PENALTY = 0.03; -- Energy taken away when adding an expense
  local DEFAULT_PENALTY_TIME = 0.3; -- Recovery penalty
  local TIMER_NAME = "_auxpow";

  -- Initialize network strings
  util.AddNetworkString(AUXPOW.NET.amount);
  util.AddNetworkString(AUXPOW.NET.expenses);

  --[[
    Returns a player's auxiliary power data
    @param {Player} player
    @return {table} auxiliary power data
  ]]
  function AUXPOW:GetData(player)
    return player.AUXPOW;
  end

  --[[
    Returns a player's auxiliary power expenses
    @param {Player} player
    @return {table} expenses
  ]]
  function AUXPOW:GetExpenses(player)
    return AUXPOW:GetData(player).expense;
  end

  --[[
    Whether a player has active auxiliary power expenses
    @param {Player} player
    @return {boolean} has expenses
  ]]
  function AUXPOW:HasExpenses(player)
    return table.Count(AUXPOW:GetExpenses(player)) > 0;
  end

  --[[
    Returns a player's current auxiliary power levels
    @param {Player} player
    @return {number} power level
  ]]
  function AUXPOW:GetPower(player)
    return AUXPOW:GetData(player).power;
  end

  --[[
    Whether a player has auxiliary power
    @param {Player} player
    @return {boolean} has auxiliary power
  ]]
  function AUXPOW:HasPower(player)
    return AUXPOW:GetPower(player) > 0;
  end

  --[[
    Sets a new level for a player's auxiliary power
    @param {Player} player
    @param {number} power
  ]]
  function AUXPOW:SetPower(player, power)
    AUXPOW:GetData(player).power = power;

    -- Send to client
    net.Start(AUXPOW.NET.amount);
    net.WriteFloat(AUXPOW:GetPower(player));
    net.Send(player);
  end

  --[[
    Adds power to a player's auxiliary power supply
    @param {Player} player
    @param {number} power to add
  ]]
  function AUXPOW:AddPower(player, power)
    AUXPOW:SetPower(player, math.min(AUXPOW:GetPower(player) + power, 1));

    -- If drained, get the greater downtime
    if (not AUXPOW:HasPower(player) and AUXPOW:HasExpenses(player)) then
      local downtime = 0;
      for _, expense in pairs(AUXPOW:GetExpenses(player)) do
        if (expense.downtime > downtime) then
          downtime = expense.downtime;
        end
      end
      AUXPOW:SetPower(player, -(downtime * DEFAULT_TICKRATE)/(DEFAULT_RECOVERY_RATE * AUXPOW:GetRecoveryMul()));
    end
  end

  --[[
    Adds an active expense to the auxiliary power system
    @param {Player} player
    @param {string} id
    @param {string} label
    @param {number} rate of energy consumption in seconds
    @param {number|nil} how much energy it consumes per tick
    @param {number|nil} how many seconds of downtime will the aux. power have after being drained
  ]]
  function AUXPOW:AddExpense(player, id, label, rate, expense, downtime)
    expense = expense or 0.01;
    downtime = downtime or 0;
    if (AUXPOW:GetExpenses(player)[id] ~= nil) then return; end
    AUXPOW:GetExpenses(player)[id] = {label = label, rate = rate, tick = CurTime() + rate, expense = expense, downtime = downtime};
    AUXPOW:AddPower(player, -DEFAULT_PENALTY);

    -- Send to client
    net.Start(AUXPOW.NET.expenses);
    net.WriteString(id);
    net.WriteString(label);
    net.Send(player);
  end

  --[[
    Removes a auxiliary power expense
    @param {Player} player
    @param {string} id
  ]]
  function AUXPOW:RemoveExpense(player, id)
    if (AUXPOW:GetExpenses(player)[id] == nil) then return; end
    AUXPOW:GetExpenses(player)[id] = nil;

    -- Send to client
    net.Start(AUXPOW.NET.expenses);
    net.WriteString(id);
    net.WriteString("");
    net.Send(player);
  end

  --[[
    Main power supply loop
    Checks for expenses and either depletes or regenerates the power level
    @param {Player} player
  ]]
  function AUXPOW:PlayerTick(player)
    if (not AUXPOW:IsSuitEquipped(player)) then player.AUXPOW.power = 1; return; end
    if (AUXPOW:HasExpenses(player)) then
      for _, expense in pairs(AUXPOW:GetExpenses(player)) do
        if (expense.tick < CurTime()) then
          AUXPOW:AddPower(player, -expense.expense * AUXPOW:GetExpenseMul());
          expense.tick = CurTime() + expense.rate;
        end
      end
      player.AUXPOW.regenTick = CurTime() + DEFAULT_PENALTY_TIME;
    else
      if (AUXPOW:GetData(player).regenTick < CurTime()) then
        AUXPOW:AddPower(player, 0.01 * AUXPOW:GetRecoveryMul());
        player.AUXPOW.regenTick = CurTime() + DEFAULT_RECOVERY_RATE;
      end
    end
  end

  --[[
    Setups a player's variables
    @param {Player} player
  ]]
  function AUXPOW:SetupPlayer(player)
    -- Setup table
    player.AUXPOW = {
      power = 1, -- Power level
      regenTick = 0, -- Power regeneration tick time
      expense = {} -- Power expenses
    };

    -- Setup timer if it doesn't exist
    if (not timer.Exists(player:EntIndex() .. TIMER_NAME)) then
      timer.Create(player:EntIndex() .. TIMER_NAME, DEFAULT_TICKRATE, 0, function()
        if (IsValid(player)) then
          if (AUXPOW:IsEnabled()) then
            AUXPOW:PlayerTick(player);
            hook.Run("AuxPowerTick", player);
          end
        else
          timer.Remove(player:EntIndex() .. TIMER_NAME);
        end
      end);
    end
  end

  --[[
    Called when a player disconnects
    @param {Player} player
  ]]
  function AUXPOW:PlayerDisconnect(player)
    timer.Remove(player:EntIndex() .. TIMER_NAME);
  end

end
