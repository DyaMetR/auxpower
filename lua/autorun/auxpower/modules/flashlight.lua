--[[------------------------------------------------------------------
  FLASHLIGHT
  Limited flashlight use
]]--------------------------------------------------------------------

local NET = "auxpow_flashlight";

if SERVER then

  util.AddNetworkString(NET);

  -- Parameters
  local DEFAULT_FLASHLIGHT_RATE = 0.4;
  local DEFAULT_DOWNTIME = 0.5;
  local DEFAULT_EP2_RATE = 1.23;
  local DEFAULT_EP2_RECOVERY_RATE = 0.01;
  local ID, LABEL = "flashlight", "FLASHLIGHT";

  --[[
    Adds an expense when the flashlight is turned on, and turns it off in
    case it runs out of power
    @param {Player} player
  ]]
  local function VanillaFlashlight(player)
    if (not AUXPOW:IsFlashlightEnabled()) then AUXPOW:RemoveExpense(player, ID); return; end
    if (player:FlashlightIsOn()) then
      AUXPOW:AddExpense(player, ID, LABEL, DEFAULT_FLASHLIGHT_RATE / AUXPOW:GetFlashlightMul(), nil, DEFAULT_DOWNTIME);

      -- Turn off is power runs out
      if (not AUXPOW:HasPower(player)) then
        player:Flashlight(false);
      end
    else
      AUXPOW:RemoveExpense(player, ID);
    end
  end

  --[[
    Returns the amount of flashlight power a player has
    @param {Player} player
  ]]
  function AUXPOW:GetFlashlightPower(player)
    return player.AUXPOW.flashlight.power;
  end

  --[[
    Returns whether the player's flashlight has power
    @param {Player} player
    @return {boolean} has enough power
  ]]
  function AUXPOW:HasFlashlightPower(player)
    return AUXPOW:GetFlashlightPower(player) > 0;
  end

  --[[
    Sets an amount of flashlight power to a player
    @param {Player} player
    @param {number} amount
  ]]
  function AUXPOW:SetFlashlightPower(player, amount)
    player.AUXPOW.flashlight.power = amount;
  end

  --[[
    Adds power amount to the flashlight and sends it to the player
    Turns the flashlight off if it reaches 0
    @param {Player} player
    @param {number} amount
  ]]
  function AUXPOW:AddFlashlightPower(player, amount)
    -- Add power
    AUXPOW:SetFlashlightPower(player, math.Clamp(AUXPOW:GetFlashlightPower(player) + amount, 0, 1));

    -- Check if it ran out of battery
    if (not AUXPOW:HasFlashlightPower(player)) then
      player:Flashlight(false);
    end

    -- Send it to the player
    net.Start(NET);
    net.WriteFloat(AUXPOW:GetFlashlightPower(player));
    net.Send(player);
  end

  --[[
    Drains a self power supply for the flashlight, turns it off if it
    runs out of battery and regenerates it if off
    @param {Player} player
  ]]
  local function EpisodeFlashlight(player)
    AUXPOW:RemoveExpense(player, ID);
    if (player.AUXPOW.flashlight.tick < CurTime()) then
      if (player:FlashlightIsOn()) then
        AUXPOW:AddFlashlightPower(player, -0.01);
        player.AUXPOW.flashlight.tick = CurTime() + DEFAULT_EP2_RATE / AUXPOW:GetEP2ExpenseMul();
      else
        AUXPOW:AddFlashlightPower(player, 0.01);
        player.AUXPOW.flashlight.tick = CurTime() + DEFAULT_EP2_RECOVERY_RATE / AUXPOW:GetEP2RecoveryMul();
      end
    end
  end

  --[[
    Based on configuration, will either drain the auxiliar power or it's own
    flashlight supply
  ]]
  hook.Add("AuxPowerTick", "auxpow_flashlight", function(player)
    if (AUXPOW:IsEP2Mode()) then
      EpisodeFlashlight(player);
    else
      VanillaFlashlight(player);
    end
  end);

  --[[
    Sets up the Episode 2 based flashlight variables
  ]]
  hook.Add("AuxPowerInitialize", "auxpow_flashlight_init", function(player)
    player.AUXPOW.flashlight = {power = 1, tick = 0};
  end);

end

if CLIENT then

  -- Parameters
  local HORIZONTAL_OFFSET, VERTICAL_OFFSET = 431, 19;
  local COLOUR = Color(255, 238, 23);
  local FWIDTH, FHEIGHT = 59, 38;
  local LIGHT_IDLE, LIGHT_ACTIVE = "®", "©";
  local ALPHA_ACTIVE, ALPHA_IDLE = 1, 0.18;

  -- Variables
  local power = 1;
  local colour = 1;
  local alpha = ALPHA_IDLE;
  local barAlpha = 0;

  -- Create scaled font
  surface.CreateFont( "auxpow_flashlight", {
    font = "HalfLife2",
    size = math.Round(51 * AUXPOW:GetScale()),
    weight = 0,
    additive = true,
    antialias = true
  });

  --[[
    Returns the amount of flashlight battery the client acknowledges the player has
    @return {number} flashlight battery
  ]]
  function AUXPOW:GetFlashlight()
    return power;
  end

  --[[
    Returns the flashlight HUD component colour
    @return {Color} colour
  ]]
  local function GetColour()
    return AUXPOW:ColourWithAlpha(AUXPOW:IntersectColour(AUXPOW:GetEP2HUDColour(), AUXPOW:GetEP2HUDCritColour(), colour), alpha);
  end

  --[[
    Animates the flashlight HUD component
    @param {number}
  ]]
  local function Animate()
    -- Colour
    local col = 1;
    if (power < 0.2) then col = 0; end
    colour = Lerp(FrameTime() * 4, colour, col);

    -- Alpha
    local a = ALPHA_IDLE;
    if (LocalPlayer():FlashlightIsOn()) then a = ALPHA_ACTIVE; end
    alpha = Lerp(FrameTime() * 4, alpha, a);

    a = 0;
    if (power < 1) then a = 1; end
    barAlpha = Lerp(FrameTime() * 30, barAlpha, a);
  end

  --[[
    Draws the flashlight icon
    @param {number} x
    @param {number} y
    @param {boolean} is the flashlight active
    @param {Color|nil} colour
    @param {number|nil} alpha
    @param {number|nil} horizontal alignment
  ]]
  local function DrawFlashlightIcon(x, y, active, col, a, align)
    col = col or GetColour();
    a = a or alpha;
    align = align or TEXT_ALIGN_LEFT;
    local icon = LIGHT_IDLE;
    if (active) then icon = LIGHT_ACTIVE; end
    draw.SimpleText(icon, "auxpow_flashlight", x, y, GetColour(), align);
  end

  --[[
    Draws the flashlight panel
    @param {number} x
    @param {number} y
  ]]
  function AUXPOW:DrawFlashlightHUD(x, y)
    if (not LocalPlayer():Alive()) then power = 1; return; end
    local w, h = math.floor(FWIDTH * AUXPOW:GetScale()), math.floor(FHEIGHT * AUXPOW:GetScale());
    y = y - h;
    Animate();
    draw.RoundedBox(6, x, y, w, h, Color(0, 0, 0, 80));
    AUXPOW:DrawBar(x + 7 * AUXPOW:GetScale(), y + 29 * AUXPOW:GetScale(), 3, 3, 1, 10, power, GetColour(), barAlpha, 0.3);
    DrawFlashlightIcon(x + w * 0.51, y - h * 0.35, LocalPlayer():FlashlightIsOn(), nil, nil, TEXT_ALIGN_CENTER);
  end

  --[[
    Draws the default HUD component
    Calls the "EP2FlashlightHUDPaint" hook to see if it's overriden (in case you want to make your own)
  ]]
  hook.Add("HUDPaint", "auxpow_flashlight_hud", function()
    local shouldDraw = hook.Run("EP2FlashlightHUDPaint", power) ~= true;
    if (AUXPOW:IsEnabled() and shouldDraw and AUXPOW:IsEP2HUDEnabled() and AUXPOW:IsEP2Mode() and GetConVar("cl_drawhud"):GetInt() > 0) then
      local x, y = AUXPOW:GetEP2HUDPos();
      AUXPOW:DrawFlashlightHUD(math.Round(x * AUXPOW:GetScale()), ScrH() - math.Round(y * AUXPOW:GetScale()));
    end
  end);

  -- Receive EP2 flashlight power amount
  net.Receive(NET, function(len)
    power = net.ReadFloat();
  end);

end
