-- boss-key.lua
-- Pause + minimize: F22, and Corsair Scimitar button 10 (numpad 0 / Insert) via forced bindings here.
-- input.conf script-binding / script-message-to is unreliable on some Windows builds; Lua bindings are not.

local function boss_key()
    mp.set_property("pause", "yes")
    mp.add_timeout(0.05, function()
        mp.set_property("window-minimized", "yes")
    end)
end

mp.add_forced_key_binding("F22", "boss-key", boss_key)
for _, key in ipairs({ "KP0", "KP_INS", "INS" }) do
    mp.add_forced_key_binding(key, "boss-scimitar-" .. key, boss_key)
end

mp.register_script_message("boss-key", boss_key)
