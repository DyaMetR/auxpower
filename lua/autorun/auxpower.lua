--[[-------------------
H.E.V Auxiliary Power
   Version 1.4.1
     09/06/19
By DyaMetR
]]---------------------

-- Main framework table
AUXPOW = {};

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
