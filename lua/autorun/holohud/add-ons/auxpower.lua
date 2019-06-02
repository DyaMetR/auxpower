--[[------------------------------------------------------------------
  SUPPORT FOR H0L-D4
  Add new HUD element
]]--------------------------------------------------------------------

if CLIENT and HOLOHUD ~= nil then

  -- Parameters
  local PANEL_NAME = "auxpower";
  local EP2_PANEL = "auxpower_flashlight";
  local FONT_NAME = "holohud_auxpower";
  local FONT_NAME_BIG = FONT_NAME .. "_big";
  local OUTLINE_TEXTURE = surface.GetTextureID("auxpower/holohud/ic_batt_border");
  local BATTERY_TEXTURE = surface.GetTextureID("auxpower/holohud/ic_batt");
  local BRIGHT_TEXTURE = surface.GetTextureID("auxpower/holohud/ic_batt_b");
  local HORIZONTAL_OFFSET, VERTICAL_OFFSET = 20, 20;
  local WIDTH, HEIGHT = 83, 40;
  local FWIDTH, FHEIGHT = 105, 35;

  -- Variables
  local auxpower = 1;
  local flashlight = 1;
  local colour1, colour2 = 1, 1;

  -- Add panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddFlashPanel(EP2_PANEL);

  -- Create flashlight icon font
  HOLOHUD:CreateFont(FONT_NAME, 47, "HalfLife2", 0);
  HOLOHUD:CreateFont(FONT_NAME_BIG, 62, "HalfLife2", 0);

  --[[
    Draws the energy left on the auxiliary power supply
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
  ]]
  local function DrawPower(x, y, w, h, auxCol, auxColText, auxColCrit)
    -- Animate colour fade in/out
    local c = 1;
    if (auxpower < 0.2) then c = 0; end
    colour1 = Lerp(FrameTime() * 6, colour1, c);

    c = 1;
    if (flashlight < 0.2) then c = 0; end
    colour2 = Lerp(FrameTime() * 6, colour2, c);

    -- Draw aux. power indicator
    local colour = HOLOHUD:IntersectColour(auxCol, auxColCrit, colour1);
    local textColour = HOLOHUD:IntersectColour(auxColText, auxColCrit, colour1);
    HOLOHUD:DrawTexture(OUTLINE_TEXTURE, x + w - 34, y + 4, 32, 32, Color(100, 100, 100));
    HOLOHUD:DrawProgressTexture(x + w - 34, y + 4, BATTERY_TEXTURE, BRIGHT_TEXTURE, 32, 32, 32, auxpower, nil, colour, TEXT_ALIGN_BOTTOM, nil, true);
    HOLOHUD:DrawNumber(x + 7, y + 19, math.max(math.Round(auxpower * 100), 0), textColour, nil, nil, "holohud_small");
    --[[
    -- Draw flashlight
    if (AUXPOW:IsEP2Mode()) then
      if (flashlight < 1) then last = 1; end
      if (last == 1) then
        local textColour = HOLOHUD:IntersectColour(flashColText, flashColCrit, colour2);
        local colour = HOLOHUD:IntersectColour(flashCol, flashColCrit, colour2);
        local a, b = x, y;
        local u1, u2 = 43, 28;
        local iconFont = FONT_NAME;

        -- If it's flashlight only, make it bigger
        if (auxpower >= 1) then
          iconFont = FONT_NAME_BIG;
          a = x + 4;
          b = y + 3;
          u1, u2 = 56, 40;
          HOLOHUD:DrawNumber(x + 10, y + (h * 0.5), math.max(math.Round(flashlight * 100), 0), textColour, nil, nil, "holohud_small", nil, nil, TEXT_ALIGN_CENTER);
        else
          HOLOHUD:DrawNumber(x + 10, y + h - 14, math.max(math.Round(flashlight * 100), 0), textColour, nil, nil, "holohud_tiny");
        end

        -- Draw icon
        local u, v = a + w + 2, b + h + 8;
        local alpha = 133;
        if (LocalPlayer():FlashlightIsOn()) then alpha = 255; end
        -- Background
        HOLOHUD:DrawText(u, v, "®", iconFont, colour, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, nil, alpha * 0.5);

        -- Foreground
        render.SetScissorRect(x + u1, y, x + u1 + u2 * (flashlight), y + h, true);
        HOLOHUD:DrawText(u, v, "®", iconFont, colour, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, nil, alpha);
        render.SetScissorRect(0, 0, 0, 0, false);
      end
    end]]
  end

  --[[
    Draws the flashlight icon
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
  ]]
  local function DrawFlashlight(x, y, w, h, flashCol, flashColText, flashColCrit)
    local textColour = HOLOHUD:IntersectColour(flashColText, flashColCrit, colour2);
    local colour = HOLOHUD:IntersectColour(flashCol, flashColCrit, colour2);

    -- Draw number
    HOLOHUD:DrawNumber(x + 8, y + (h * 0.5) - 1, math.max(math.Round(flashlight * 100), 0), textColour, nil, nil, "holohud_small", nil, nil, TEXT_ALIGN_CENTER);

    -- Draw icon
    local u1, u2 = 56, 40;
    local u, v = x + w + 5, y + 14;
    local alpha = 133;
    if (LocalPlayer():FlashlightIsOn()) then alpha = 255; end
    -- Background
    HOLOHUD:DrawText(u, v, "®", FONT_NAME_BIG, colour, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, nil, alpha * 0.5);

    -- Foreground
    render.SetScissorRect(x + u1, y, x + u1 + u2 * (flashlight), y + h, true);
    HOLOHUD:DrawText(u, v, "®", FONT_NAME_BIG, colour, nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, nil, alpha);
    render.SetScissorRect(0, 0, 0, 0, false);
  end

  --[[
    Draws the auxiliary power panel
    @param {table} configuration
  ]]
  local function DrawPanel(config)
    -- Aux. power offset
    local w, h = WIDTH, HEIGHT;
    local x, y = ScrW() - w - config("x"), config("y");

    -- Flashlight offset
    local fW, fH = FWIDTH, FHEIGHT;
    local fX, fY = ScrW() - fW - config("fX"), config("fY");

    local u, v = HOLOHUD.ELEMENTS:GetElementSize("ping");

    -- Move flashlight meter
    if (fX >= ScrW() - fW - 20 and x >= ScrW() - w - 20 and HOLOHUD:IsPanelActive(PANEL_NAME)) then
      fY = y + h + 5;
    end

    -- Avoid 'ping' element
    local pingPos = ScrW() - u - 20;
    if (HOLOHUD:IsPanelActive("ping")) then
      if (x + w >= pingPos and y < v + 20) then
        y = v + 25;
      end

      if ((fX + fW >= pingPos) and fY < v + 20) then
        fY = fY + v + 5;
      end
    end

    -- Extend if EP2Mode
    --[[if (AUXPOW:IsEP2Mode() and (last == 1 or flashlight < 1)) then
      if (auxpower < 1) then
        h = h + 20;
      else
        h = 35;
        w = 105;
        x = ScrW() - w - 20;
      end
    end]]

    HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, DrawPower, PANEL_NAME, TEXT_ALIGN_TOP, config("colour"), config("colour_text"), config("crit_colour"));
    HOLOHUD:SetPanelActive(PANEL_NAME, auxpower < 1 and AUXPOW:IsEnabled());

    HOLOHUD:SetPanelActive(EP2_PANEL, flashlight < 1 and AUXPOW:IsEP2Mode() and AUXPOW:IsEnabled());
    HOLOHUD:DrawFragmentAlignSimple(fX, fY, fW, fH, DrawFlashlight, EP2_PANEL, TEXT_ALIGN_TOP, config("ep2_colour"), config("ep2_colour_text"), config("ep2_crit_colour"));

    return w, h;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Auxiliary power",
    "Displays the amount of auxiliary power left",
    nil,
    {
      colour = { name = "Aux. power colour", value = Color(77, 204, 255) },
      colour_text = { name = "Aux. power text colour", value = Color(255, 255, 255) },
      crit_colour = { name = "Aux. power critical colour", value = Color(255, 88, 88) },
      ep2_colour = { name = "Flashlight colour", value = Color(200, 180, 80)},
      ep2_colour_text = { name = "Flashlight text colour", value = Color(255, 255, 255)},
      ep2_crit_colour = { name = "Flashlight critical colour", value = Color(255, 0, 0)},
      x = { name = "Horizontal offset", value = 20, minValue = 0, maxValue = ScrW() },
      y = { name = "Vertical offset", value = 20, minValue = 0, maxValue = ScrW() },
      fX = { name = "Flashlight hor. offset", value = 20, minValue = 0, maxValue = ScrW() },
      fY = { name = "Flashlight ver. offset", value = 20, minValue = 0, maxValue = ScrW() }
    },
    DrawPanel
  );

  -- Get flashlight power and hide default HUD
  hook.Add("AuxPowerHUDPaint", "auxpower_holohud_vanilla", function(power, labels)
    if (not HOLOHUD:IsHUDEnabled() or not AUXPOW:IsEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled(PANEL_NAME)) then return; end
    auxpower = power;
    return true;
  end);

  hook.Add("EP2FlashlightHUDPaint", "auxpower_holohud_ep2", function(power)
    if (not HOLOHUD:IsHUDEnabled() or not AUXPOW:IsEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled(PANEL_NAME)) then return; end
    flashlight = power;
    return true;
  end);

end
