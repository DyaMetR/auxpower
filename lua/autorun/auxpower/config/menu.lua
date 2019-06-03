--[[------------------------------------------------------------------
  CONFIGURATION MENU
  Edit addon configuration
]]--------------------------------------------------------------------

if CLIENT then

  --[[
    Client only options
  ]]
  local function clientOptions( panel )
  	panel:ClearControls();

    panel:AddControl( "CheckBox", {
      Label = "Sprint sounds enabled",
      Command = "cl_auxpow_sprint_sound_enable",
      }
    );

    panel:AddControl( "CheckBox", {
  		Label = "Aux. power HUD enabled",
  		Command = "cl_auxpow_drawhud",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Aux. power horizontal offset",
      Type = "Integer",
      Min = 0,
      Max = 1306,
      Command = "cl_auxpow_hudpos_x"}
    );

    panel:AddControl( "Slider", {
      Label = "Aux. power vertical offset",
      Type = "Integer",
      Min = 0,
      Max = 768,
      Command = "cl_auxpow_hudpos_y"}
    );

    panel:AddControl( "Color", {
      Label = "Aux. power colour",
      Red = "cl_auxpow_hudcol_r",
      Green = "cl_auxpow_hudcol_g",
      Blue = "cl_auxpow_hudcol_b"
      }
    );

    panel:AddControl( "Color", {
      Label = "Aux. power critical colour",
      Red = "cl_auxpow_hudcol_crit_r",
      Green = "cl_auxpow_hudcol_crit_g",
      Blue = "cl_auxpow_hudcol_crit_b"
      }
    );

    panel:AddControl( "CheckBox", {
      Label = "Flashlight HUD enabled",
      Command = "cl_auxpow_drawhudep2",
      }
    );

    panel:AddControl( "Slider", {
      Label = "Flashlight horizontal offset",
      Type = "Integer",
      Min = 0,
      Max = 1306,
      Command = "cl_auxpow_ep2pos_x"}
    );

    panel:AddControl( "Slider", {
      Label = "Flashlight vertical offset",
      Type = "Integer",
      Min = 0,
      Max = 768,
      Command = "cl_auxpow_ep2pos_y"}
    );

    panel:AddControl( "Color", {
      Label = "Flashlight colour",
      Red = "cl_auxpow_ep2col_r",
      Green = "cl_auxpow_ep2col_g",
      Blue = "cl_auxpow_ep2col_b"
      }
    );

    panel:AddControl( "Color", {
      Label = "Flashlight critical colour",
      Red = "cl_auxpow_ep2col_crit_r",
      Green = "cl_auxpow_ep2col_crit_g",
      Blue = "cl_auxpow_ep2col_crit_b"
      }
    );

    panel:AddControl( "Button", {
  		Label = "Reset settings to default",
  		Command = "cl_auxpow_reset",
  		}
  	);

    -- Credits
    panel:AddControl( "Label",  { Text = ""});
    panel:AddControl( "Label",  { Text = "Version 1.4"});
    panel:AddControl( "Label",  { Text = ""});
  	panel:AddControl( "Label",  { Text = "Credits"});
    panel:AddControl( "Label",  { Text = "Main script: DyaMetR"});
    panel:AddControl( "Label",  { Text = "Flashlight icon: VALVe"});
    panel:AddControl( "Label",  { Text = ""});
  end

  --[[
    Client only options
  ]]
  local function serverOptions( panel )
  	panel:ClearControls();

    panel:AddControl( "CheckBox", {
  		Label = "Enabled",
  		Command = "sv_auxpow_enabled",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Aux. power recovery multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_recovery_mul"}
    );

    panel:AddControl( "Slider", {
      Label = "Aux. power expense multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_expense_mul"}
    );

    panel:AddControl( "CheckBox", {
  		Label = "Sprint enabled",
  		Command = "sv_auxpow_sprint_enabled",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Sprint expense multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_sprint_mul"}
    );

    panel:AddControl( "CheckBox", {
  		Label = "Oxygen enabled",
  		Command = "sv_auxpow_oxygen_enabled",
  		}
  	);

    panel:AddControl( "CheckBox", {
  		Label = "Cap health regeneration at maximum health",
  		Command = "sv_auxpow_oxygen_health_recovery_limit",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Oxygen expense multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_oxygen_mul"}
    );

    panel:AddControl( "CheckBox", {
  		Label = "Vanilla flashlight enabled",
  		Command = "sv_auxpow_flashlight_enabled",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Flashlight expense multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_flashlight_mul"}
    );

    panel:AddControl( "CheckBox", {
  		Label = "HL2: Episode 2 flashlight mode",
  		Command = "sv_auxpow_flashlight_ep2",
  		}
  	);

    panel:AddControl( "Slider", {
      Label = "Flashlight recovery multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_ep2flash_recovery_mul"}
    );

    panel:AddControl( "Slider", {
      Label = "Flashlight expense multiplier",
      Type = "Float",
      Min = 0,
      Max = 25,
      Command = "sv_auxpow_ep2flash_expense_mul"}
    );

    panel:AddControl( "Button", {
  		Label = "Reset settings to default",
  		Command = "sv_auxpow_reset",
  		}
  	);

  end

  --[[
    Add options to the Q menu
  ]]
  local function menuCreation()
  	spawnmenu.AddToolMenuOption( "Options", "DyaMetR", "cl_AUXPOW", "Auxiliary power", "", "", clientOptions );
    spawnmenu.AddToolMenuOption( "Utilities", "DyaMetR", "sv_AUXPOW", "Auxiliary power", "", "", serverOptions );
  end
  hook.Add( "PopulateToolMenu", "auxpow_menu", menuCreation );

end
