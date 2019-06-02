--[[------------------------------------------------------------------
  HUD
  Displays the default heads up display component
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local LABEL = "AUX. POWER";
  local WIDTH, HEIGHT = 163, 41;
  local EXPENSE_HEIGHT = 16;
  local HORIZONTAL_OFFSET, VERTICAL_OFFSET = 25, 87;
  local SW, SH, SM = 9, 6, 5;
  local COLOUR = Color(255, 238, 23);
  local ANIM_RATE = 0.04;
  local FADE_SPEED = 0.04;

  -- Variables
  local power = 1; -- Auxiliary power levels
  local labels = {}; -- Expenses to display
  local tick = 0; -- Animation tick
  local height = 0; -- Additional height
  local colour = 0; -- Current colour (red amount)
  local alpha = 0; -- Opacity

  --[[
    Returns the amount of power the client acknowledges the player has
    @return {number} power
  ]]
  function AUXPOW:GetPower()
    return power;
  end

  --[[
		Given a value, determines how much of each one is shown
		@param {number} a
		@param {number} b
		@param {number} value
		@return {number} result
	]]
	function AUXPOW:Intersect(a, b, value)
		return (a * value) + (b * (1-value));
	end

	--[[
		Intersects two colours based on a value
		@param {number} a
		@param {number} b
		@param {number} value
		@param {Color} result
	]]
	function AUXPOW:IntersectColour(a, b, value)
		return Color(AUXPOW:Intersect(a.r, b.r, value), AUXPOW:Intersect(a.g, b.g, value), AUXPOW:Intersect(a.b, b.b, value), AUXPOW:Intersect(a.a, b.a, value));
  end

  --[[
    Returns the HUD scale
    @return {number} scale
  ]]
  function AUXPOW:GetScale()
    return ScrH() / 768;
  end

  -- Create scaled font
  surface.CreateFont( "auxpow", {
    font = "Verdana",
    size = math.Round(14 * AUXPOW:GetScale()),
    weight = 1000,
    antialias = true
  });

  --[[
    Returns a colour with a custom alpha value applied
    @param {number} colour
    @param {number} alpha
    @return {Color} resulting colour
  ]]
  function AUXPOW:ColourWithAlpha(col, a)
    return Color(col.r, col.g, col.b, col.a * a);
  end

  --[[
    Returns the HUD element colour
    @return {Color} colour
  ]]
  local function GetColour()
    return AUXPOW:ColourWithAlpha(AUXPOW:IntersectColour(AUXPOW:GetHUDColour(), AUXPOW:GetHUDCritColour(), colour), alpha);
  end

  --[[
    Animates the HUD panel
    @void
  ]]
  local function Animate()
    -- Colour
    local col = 1;
    if (power < 0.2) then col = 0; end
    colour = Lerp(FrameTime() * 4, colour, col);

    -- Linear animations
    if (tick < CurTime()) then
      -- Label animation
      if (table.Count(labels) >= height) then
        height = math.min(height + ANIM_RATE, table.Count(labels));
      else
        height = math.max(height - ANIM_RATE, 0);
      end

      -- Fade-in/out
      if (power < 1 or table.Count(labels) > 0) then
        alpha = math.min(alpha + FADE_SPEED, 1);
      else
        alpha = math.max(alpha - FADE_SPEED, 0);
      end

      tick = CurTime() + 0.01;
    end
  end

  --[[
    Draws a segmented progress bar
    @param {number} x
    @param {number} y
    @param {number} segment width
    @param {number} segment height
    @param {number} segment margin
    @param {number} amount of segments
    @param {number} value
    @param {Color|nil} colour
    @param {number|nil} alpha
    @param {number|nil} background alpha
  ]]
  function AUXPOW:DrawBar(x, y, w, h, m, amount, value, col, a, bgA)
    col = col or GetColour();
    a = a or alpha;
    bgA = bgA or 0.4;

    -- Background
    for i=0, amount do
      draw.RoundedBox(0, x + math.Round((w + m) * AUXPOW:GetScale()) * i, y, math.Round(w * AUXPOW:GetScale()), math.Round(h * AUXPOW:GetScale()), Color(col.r * 0.8, col.g * 0.8, col.b * 0.8, col.a * bgA * a));
    end

    -- Foreground
    if (value <= 0) then return; end
    for i=0, math.Round(value * amount) do
      draw.RoundedBox(0, x + math.Round((w + m) * AUXPOW:GetScale()) * i, y, math.Round(w * AUXPOW:GetScale()), math.Round(h * AUXPOW:GetScale()), Color(col.r, col.g, col.b, col.a * a));
    end
  end

  --[[
    Draws the auxiliary power HUD panel
    @param {number} x
    @param {number} y
  ]]
  function AUXPOW:DrawHUDPanel(x, y)
    if (not LocalPlayer():Alive()) then power = 1; labels = {}; return; end
    local w, h = WIDTH * AUXPOW:GetScale(), (HEIGHT + EXPENSE_HEIGHT * height) * AUXPOW:GetScale();
    y = y - h;

    -- Animate
    Animate();

    -- Background
    draw.RoundedBox(6, x, y, w, h, Color(0, 0, 0, 80 * alpha));

    -- Title
    draw.SimpleText(LABEL, "auxpow", x + (13 * AUXPOW:GetScale()), y + (5 * AUXPOW:GetScale()), GetColour());

    -- Bar
    AUXPOW:DrawBar(x + 14 * AUXPOW:GetScale(), y + 24 * AUXPOW:GetScale(), SW, SH, SM, 9, power);

    -- Expenses
    render.SetScissorRect(x, y, x + w, y + h, true);
    local i = 1;
    for _, label in pairs(labels) do
      draw.SimpleText(label, "auxpow", x + (14 * AUXPOW:GetScale()), y + (35 + (EXPENSE_HEIGHT * (i - 1))) * AUXPOW:GetScale(), GetColour());
      i = i + 1;
    end
    render.SetScissorRect(0, 0, 0, 0, false);
  end

  --[[
    Draws the default HUD component
    Calls the "AuxPowerHUDPaint" hook to see if it's overriden (in case you want to make your own)
  ]]
  hook.Add("HUDPaint", "auxpow_drawhud", function()
    local shouldDraw = hook.Run("AuxPowerHUDPaint", power, labels) ~= true;
    if (AUXPOW:IsEnabled() and shouldDraw and AUXPOW:IsHUDEnabled() and GetConVar("cl_drawhud"):GetInt() > 0) then
      local x, y = AUXPOW:GetHUDPos();
      AUXPOW:DrawHUDPanel(x * AUXPOW:GetScale(), ScrH() - (y * AUXPOW:GetScale()));
    end
  end);

  -- Receive power levels
  net.Receive(AUXPOW.NET.amount, function(len)
    power = net.ReadFloat();
  end);

  -- Receive labels
  net.Receive(AUXPOW.NET.expenses, function(len)
    local id = net.ReadString();
    local label = net.ReadString();

    -- Check if the label is valid; if not, remove it from tray
    if (string.len(label) > 0) then
      labels[id] = label;
    else
      labels[id] = nil;
    end
  end);
end
