-- audio-normalize.lua
-- Toggle dynamic audio normalization (dynaudnorm).
-- Useful for late-night watching or content with inconsistent volume.
-- Alt+N to toggle on/off.

local mp = require 'mp'

local filter  = "dynaudnorm=g=5:f=250:r=0.9:p=0.95"
local enabled = false

local function toggle()
    enabled = not enabled
    if enabled then
        mp.command("af add " .. filter)
        mp.osd_message("Audio Normalization: ON\n(dynaudnorm — evening out volume)", 3)
    else
        mp.command("af remove " .. filter)
        mp.osd_message("Audio Normalization: OFF", 3)
    end
end

mp.add_forced_key_binding("alt+n", "audio-normalize-toggle", toggle)
