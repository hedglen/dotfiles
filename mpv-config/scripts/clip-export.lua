-- clip-export.lua
-- Mark in/out points and export a clip via ffmpeg (stream copy, no re-encode).
-- Keys (set via add_forced_key_binding):
--   Ctrl+I  — set clip IN point
--   Ctrl+O  — set clip OUT point
--   Ctrl+E  — export clip

local mp    = require 'mp'
local utils = require 'mp.utils'

local clip_in  = nil
local clip_out = nil

-- ── path helpers ────────────────────────────────────────────────────────────

local function find_exe(name)
    -- Navigate up from this script's path: lua → scripts → portable_config → mpv dir
    local src = debug.getinfo(1, "S").source:sub(2)
    local mpv_dir = src
        :gsub("[\\/]?$",        "")
        :gsub("[\\/][^\\/]+$",  "")   -- strip filename
        :gsub("[\\/][^\\/]+$",  "")   -- strip /scripts
        :gsub("[\\/][^\\/]+$",  "")   -- strip /portable_config

    for _, p in ipairs({ mpv_dir .. "\\" .. name .. ".exe",
                         mpv_dir .. "/" .. name .. ".exe" }) do
        if utils.file_info(p) then return p end
    end

    local h = io.popen("where " .. name .. ".exe 2>nul")
    if h then
        local line = h:read("*l"); h:close()
        if line and line ~= "" then return line:match("^%s*(.-)%s*$") end
    end
    return nil
end

-- ── formatting ───────────────────────────────────────────────────────────────

local function hms(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    return string.format("%02d:%02d:%06.3f", h, m, sec)
end

local function hms_tag(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = math.floor(s % 60)
    if h > 0 then return string.format("%d%02d%02d", h, m, sec)
    else           return string.format("%d%02d",    m, sec) end
end

local function display(s)
    local h = math.floor(s / 3600)
    local m = math.floor((s % 3600) / 60)
    local sec = s % 60
    if h > 0 then return string.format("%d:%02d:%05.2f", h, m, sec)
    else           return string.format("%d:%05.2f",        m, sec) end
end

-- ── actions ──────────────────────────────────────────────────────────────────

local function set_in()
    clip_in = mp.get_property_number("time-pos")
    if not clip_in then return end
    local out_str = clip_out and ("  OUT: " .. display(clip_out)) or "  (OUT not set)"
    mp.osd_message("Clip IN:  " .. display(clip_in) .. out_str, 3)
end

local function set_out()
    clip_out = mp.get_property_number("time-pos")
    if not clip_out then return end
    local in_str = clip_in and ("IN:  " .. display(clip_in) .. "\n") or "(IN not set)\n"
    mp.osd_message(in_str .. "Clip OUT: " .. display(clip_out), 3)
end

local function export_clip()
    if not clip_in  then mp.osd_message("Set clip IN point first  (Ctrl+I)", 4); return end
    if not clip_out then mp.osd_message("Set clip OUT point first (Ctrl+O)", 4); return end
    if clip_out <= clip_in then mp.osd_message("OUT must be after IN", 4); return end

    local src = mp.get_property("path")
    if not src then mp.osd_message("No file loaded", 4); return end

    local ffmpeg = find_exe("ffmpeg")
    if not ffmpeg then mp.osd_message("ffmpeg not found — cannot export clip", 5); return end

    local dir, fname = utils.split_path(src)
    local basename   = fname:match("^(.+)%.[^%.]+$") or fname
    local ext        = src:match("%.([^%.]+)$") or "mkv"
    local outfile    = dir .. basename .. "_clip_" .. hms_tag(clip_in) .. "-" .. hms_tag(clip_out) .. "." .. ext

    mp.osd_message("Exporting clip…  (do not close mpv)", 60)

    local result = mp.command_native({
        name = "subprocess",
        args = {
            ffmpeg, "-y",
            "-ss", hms(clip_in),
            "-to", hms(clip_out),
            "-i",  src,
            "-c",  "copy",
            "-avoid_negative_ts", "make_zero",
            outfile
        },
        capture_stdout = true,
        capture_stderr = true,
        playback_only  = false,
    })

    if result.status == 0 then
        local dur = clip_out - clip_in
        mp.osd_message(string.format("Clip saved! (%.1fs)\n→ %s", dur,
            outfile:match("[^\\/]+$")), 8)
        clip_in  = nil
        clip_out = nil
    else
        mp.osd_message("Export failed — check console for details", 6)
        mp.msg.error(result.stderr or "")
    end
end

local function show_status()
    local in_str  = clip_in  and display(clip_in)  or "not set"
    local out_str = clip_out and display(clip_out) or "not set"
    mp.osd_message("Clip  IN: " .. in_str .. "\nClip OUT: " .. out_str ..
        "\n\nCtrl+I = IN  |  Ctrl+O = OUT  |  Ctrl+E = Export", 5)
end

-- ── bindings ─────────────────────────────────────────────────────────────────

mp.add_forced_key_binding("ctrl+i", "clip-set-in",     set_in)
mp.add_forced_key_binding("ctrl+o", "clip-set-out",    set_out)
mp.add_forced_key_binding("ctrl+e", "clip-export",     export_clip)
mp.add_forced_key_binding("ctrl+p", "clip-status",     show_status)
