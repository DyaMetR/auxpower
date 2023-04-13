--[[------------------------------------------------------------------
  H.E.V Mark V Auxiliary Power
  Version 1.7
  April 13th, 2023
  Made by DyaMetR
]]--------------------------------------------------------------------

-- Main framework table
AUXPOW = {};
AUXPOW.Version = "1.7";

--[[
  METHODS
]]

--[[
  Correctly includes a file
  @param {string} file
  @void
]]--
function AUXPOW:IncludeFile(file)
  if SERVER then
    include(file);
    AddCSLuaFile(file);
  end
  if CLIENT then
    include(file);
  end
end

--[[
  INCLUDES
]]
AUXPOW:IncludeFile("auxpower/core.lua");
