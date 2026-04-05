-- remember-volume.lua
-- Saves volume and mute state on quit, restores on next launch.

local mp      = require 'mp'
local utils   = require 'mp.utils'

local save_file = mp.command_native({"expand-path", "~~home/volume.conf"})

local function save()
    local vol  = mp.get_property_number("volume")
    local mute = mp.get_property("mute")
    if not vol then return end
    local f = io.open(save_file, "w")
    if f then
        f:write(string.format("volume=%s\nmute=%s\n", vol, mute))
        f:close()
    end
end

local function restore()
    local f = io.open(save_file, "r")
    if not f then return end
    local content = f:read("*a")
    f:close()
    local vol  = content:match("volume=([%d%.]+)")
    local mute = content:match("mute=(%a+)")
    if vol  then mp.set_property_number("volume", tonumber(vol)) end
    if mute then mp.set_property("mute", mute) end
end

restore()
mp.register_event("shutdown", save)
