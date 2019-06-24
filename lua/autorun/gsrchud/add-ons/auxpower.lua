--[[------------------------------------------------------------------
  SUPPORT FOR GOLDSRC HUD
  Add new HUD element
]]--------------------------------------------------------------------

if CLIENT and GSRCHUD ~= nil then

  -- Convars
  local enabled = CreateClientConVar("cl_auxpow_gsrchud_flashlight", 1, true);

  -- Variables
  local flashlight = 1;

  --[[
    Draws the flashlight representing aux. power in the top right corner
    @void
  ]]
  local function Flashlight()
    if (not AUXPOW:IsEnabled() or enabled:GetInt() <= 0) then return; end

    local margin, _ = GSRCHUD:GetSpriteDimensions("flash_beam");
    local w, h = GSRCHUD:GetSpriteDimensions("flash_empty");
    local x, y = ScrW() - (w + margin) * GSRCHUD:GetHUDScale(), 10 + h * (GSRCHUD:GetHUDScale() - 1);

    -- Draw flashlight beam when on and hightlight
    local alpha = 0.5;
    if (LocalPlayer():FlashlightIsOn()) then
      alpha = 1;
      GSRCHUD:DrawSprite(x + w * GSRCHUD:GetHUDScale(), y, "flash_beam", GSRCHUD:GetHUDScale(), nil, flashlight <= 0.25);
    end

    -- Draw flashlight
    GSRCHUD:DrawSprite(x, y, "flash_empty", GSRCHUD:GetHUDScale(), nil, flashlight <= 0.25);
    GSRCHUD:DrawSprite(x, y, "flash_full", GSRCHUD:GetHUDScale(), alpha * 255, flashlight <= 0.25, nil, nil, nil, true, flashlight, true);
  end

  GSRCHUD:AddElement(Flashlight);

  -- Get flashlight power and hide default HUD
  hook.Add("AuxPowerHUDPaint", "auxpower_gsrchud_vanilla", function(power, labels)
    if (not GSRCHUD:IsEnabled() or not AUXPOW:IsEnabled() or AUXPOW:IsEP2Mode() or enabled:GetInt() <= 0) then return; end
    flashlight = power;
    return true;
  end);

  hook.Add("EP2FlashlightHUDPaint", "auxpower_gsrchud_ep2", function(power)
    if (not GSRCHUD:IsEnabled() or not AUXPOW:IsEnabled() or not AUXPOW:IsEP2Mode() or enabled:GetInt() <= 0) then return; end
    flashlight = power;
    return true;
  end);

  -- Add options
  hook.Add( "PopulateToolMenu", "auxpow_gsrchud_menu", function()
    spawnmenu.AddToolMenuOption( "Options", "GoldSrc HUD Additions", "cl_auxpow_gsrchud", "Aux. Power", "", "", function(panel)
      panel:AddControl( "CheckBox", {
    		Label = "Enable flashlight icon",
    		Command = "cl_auxpow_gsrchud_flashlight",
    		}
    	);
    end);
  end);

end
