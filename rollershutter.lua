--[[
%% autostart
%% properties
391 value  -- BrightnessSensorId
388 value  -- RainSensorId
%% events
%% globals
-]]


if dofile and not _EMULATED then _EMULATED={name="Test",id=400, maxtime=24} dofile("HC2.lua") end

--------------------------------------------------------------------
------------------------------ SENSOR ------------------------------
local BrightnessSensorId =   391  -- ID of the brightness sensor, nil of not available
local RainSensorId       =   388  -- ID of the rain sensor, nil if not available
local HumanitySensor     =   nil  -- ID of the humanity sensor, nil if not available
local WindSensor         =   nil  -- ID of the windsensor, nil if not available

--------------------------------------------------------------------
------------------------------ BlINDS ------------------------------
local blinds = {}
-- List the WindowID as trigger event at "properties" to react on open / close window
blinds[1] = {BlindId=165, WindowId=nil, WaterResist=false, BrightnessClose=10000, BrightnessOpen=500, TempClose=25.0, TempOpen=20.0, WindOpen=25, WindClose=35}  -- Sunblind roof
blinds[2] = {BlindId=144, WindowId=nil, WaterResist=true,  BrightnessClose=10000, BrightnessOpen=500, TempClose=25.0, TempOpen=20.0, WindOpen=25, WindClose=35}  -- Sunblind garden

--------------------------------------------------------------------
------------------------ ADVANCES SETTINGS -------------------------
local DebounceTimeSecond    = 60     -- Brightness or temperature debounce time in second
local ShowStandardDebugInfo = true;  -- Debug shown in white
local ShowExtraDebugInfo    = true;  -- Debug shown in orange



--------------------------------------------------------------------
--------------------------------------------------------------------
--               DO NOT CHANGE THE CODE BELOW                     --
--------------------------------------------------------------------

--private variables
local version = "0.1"
  
-- debug function
Debug = function ( color, message )
    fibaro:debug(string.format('<%s style="color:%s;">%s</%s>', "span", color, message, "span"));
end

--Making sure that only one instance of the scene is running.
fibaro:sleep(50); -- sleep to prevent all instances being killed.
if (fibaro:countScenes() > 1) then
	Debug( "grey", "Abort, Scene count = " .. fibaro:countScenes());
	fibaro:abort();
end

--------------------------------------------------------------------
--  Debugging Functions 
--------------------------------------------------------------------
function StandardDebug( debugMessage )
  if ( ShowStandardDebugInfo ) then
    Debug( "white", debugMessage);   
  end
end

function ExtraDebug( debugMessage )
  if ( ShowExtraDebugInfo ) then
    Debug( "orange", debugMessage);
  end
end

function ErrorDebug( debugMessage )
    Debug( "red", "Error: " .. debugMessage);
    Debug( "red", "");
end

function TestDebug(debugMessage )
   Debug( "blue", "Testing: " .. debugMessage );
end

--------------------------------------------------------------------
--  Print how start this scene
-------------------------------------------------------------------- 
local trigger = fibaro:getSourceTrigger()
if (trigger['type'] == 'property') then
  local source_name = fibaro:getName(tonumber(trigger['deviceID']))
  ExtraDebug("Source device = " .. source_name)
elseif (trigger['type'] == 'global') then
  ExtraDebug("Global variable source = " .. trigger['name']) 
elseif (trigger['type'] == 'other') then
  ExtraDebug("Other source")
end

--------------------------------------------------------------------
--  Function for rain
--  The function checks if its raining and open the blinds if they
--  aren't water resist and not fully open
--------------------------------------------------------------------
function check_rain_and_open_blind()
  -- Check if a rain sensor is present, otherwhise function
  -- does not make sense
  local rain_value = 0
  if RainSensorId ~= nil then
    
    -- Check if it is raining
    local rain_value = fibaro:getValue(RainSensorId, 'value')
    ExtraDebug("Rain sensor returns: ".. rain_value)
    if rain_value == true then
      
      -- It's raining men, hallelujah
      -- Open all blindes how are not water resistant
      for count=1, #blinds do
        if blinds[count].WaterResist == false then
          -- Check if the blind is not fully open
          if tonumber(fibaro:getValue(blinds[count].BlindId)) ~= 0 then
            ShowStandardDebugInfo("Close blind "..fibaro:getName(blinds[count].BlindId).." because it rains")
            fibaro:call(blinds[count].BlindId, "setValue", 0)
          end  -- End if blind was not fully open
        end -- End if is blind not water resist
      end  -- End for loop over all blinds
    end  -- End if its raining
  end  -- End if rain sensor is present
  
  return rain_value
end  -- End function check_rain_and_open_blind()

--------------------------------------------------------------------
--  Function for brightness
--  The function checks the brightness
--------------------------------------------------------------------


check_rain_and_open_blind()

