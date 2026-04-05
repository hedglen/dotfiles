-- ab-loop-manager.lua
-- Separate bindings for A point, B point, and reset (unlike built-in ab-loop
-- which cycles through all three with one key)

local function mark_a()
    local pos = mp.get_property_number("time-pos")
    if not pos then return end
    mp.set_property("ab-loop-a", pos)
    mp.osd_message(string.format("A-B: A = %.2fs", pos))
end

local function mark_b()
    local pos = mp.get_property_number("time-pos")
    if not pos then return end
    mp.set_property("ab-loop-b", pos)
    mp.osd_message(string.format("A-B: B = %.2fs", pos))
end

local function reset_loop()
    mp.set_property("ab-loop-a", "no")
    mp.set_property("ab-loop-b", "no")
    mp.osd_message("A-B: Loop cleared")
end

mp.add_forced_key_binding("F21", "ab-mark-a", mark_a)
mp.add_forced_key_binding("F24", "ab-mark-b", mark_b)
mp.add_forced_key_binding("F20", "ab-reset",  reset_loop)
-- Scimitar 8 / 9 / 12 (Num Lock on or off): same keys as input.conf used to map; forced here so script-binding is not required.
mp.add_forced_key_binding("KP2", "ab-scimitar-reset-kp2", reset_loop)
mp.add_forced_key_binding("KP3", "ab-scimitar-a-kp3", mark_a)
mp.add_forced_key_binding("KP_SUBTRACT", "ab-scimitar-b-sub", mark_b)
mp.add_forced_key_binding("KP_DOWN", "ab-scimitar-reset-down", reset_loop)
mp.add_forced_key_binding("KP_PGDWN", "ab-scimitar-a-pgdn", mark_a)

mp.register_script_message("mark-a", mark_a)
mp.register_script_message("mark-b", mark_b)
mp.register_script_message("reset", reset_loop)
