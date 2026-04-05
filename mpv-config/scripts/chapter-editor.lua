-- chapter-editor.lua
-- Mark chapter points while playing, then save them to the video file.
--
--   t       = add chapter at current position (auto-named)
--   T       = save all chapters to file
--   ctrl+t  = (already bound) — not used here
--
-- MKV files: uses mkvpropedit (non-destructive, in-place) if found in mpv folder
-- All other formats: uses ffmpeg to remux into a new file alongside the original

local mp    = require 'mp'
local utils = require 'mp.utils'

-- ── Utility ──────────────────────────────────────────────────────────────────

local function hms(s)
    return string.format("%02d:%02d:%06.3f",
        math.floor(s / 3600), math.floor(s % 3600 / 60), s % 60)
end

-- Look for an executable in the mpv install folder, then PATH
-- Returns: path or nil, debug_info string
local function find_exe(name)
    -- Use this script's own path to locate the mpv install dir.
    -- script is at:  <mpv>\portable_config\scripts\chapter-editor.lua
    -- mpv_dir is:    <mpv>   (3 levels up)
    local src = debug.getinfo(1, "S").source:sub(2)  -- strip leading @
    local mpv_dir = src
        :gsub("[\\/]?$", "")       -- strip trailing slash
        :gsub("[\\/][^\\/]+$", "") -- strip filename      → .../scripts
        :gsub("[\\/][^\\/]+$", "") -- strip /scripts      → .../portable_config
        :gsub("[\\/][^\\/]+$", "") -- strip /portable_config → mpv install dir

    local tries = {
        mpv_dir .. "\\" .. name .. ".exe",
        mpv_dir .. "/"  .. name .. ".exe",
    }
    for _, p in ipairs(tries) do
        local info = utils.file_info(p)
        if info then return p end
    end

    -- Fall back to PATH via `where`
    local h = io.popen("where " .. name .. ".exe 2>nul")
    if h then
        local line = h:read("*l"); h:close()
        if line and line ~= "" then return line:match("^%s*(.-)%s*$") end
    end

    return nil
end

-- ── Add chapter ──────────────────────────────────────────────────────────────

local function add_chapter()
    local pos = mp.get_property_number("time-pos")
    if not pos then return end

    local list = mp.get_property_native("chapter-list") or {}

    -- Renumber after sort so names stay sequential
    table.insert(list, {title = "Chapter " .. (#list + 1), time = pos})
    table.sort(list, function(a, b) return a.time < b.time end)
    for i, ch in ipairs(list) do
        if ch.title:match("^Chapter %d+$") then
            ch.title = "Chapter " .. i
        end
    end

    mp.set_property_native("chapter-list", list)
    mp.osd_message(string.format("Chapter %d added @ %s  (T to save)", #list, hms(pos)), 3)
end

-- ── Save with mkvpropedit (MKV, non-destructive in-place) ────────────────────

local function write_xml(chapters, path)
    local f = io.open(path, "w")
    if not f then return false end
    f:write('<?xml version="1.0" encoding="UTF-8"?>\n')
    f:write('<!DOCTYPE Chapters SYSTEM "matroskachapters.dtd">\n')
    f:write('<Chapters><EditionEntry>\n')
    for _, ch in ipairs(chapters) do
        local s  = ch.time
        local hh = math.floor(s / 3600)
        local mm = math.floor(s % 3600 / 60)
        local ss = math.floor(s % 60)
        local ns = math.floor((s % 1) * 1e9)
        f:write(string.format(
            '  <ChapterAtom>\n' ..
            '    <ChapterTimeStart>%02d:%02d:%02d.%09d</ChapterTimeStart>\n' ..
            '    <ChapterDisplay><ChapterString>%s</ChapterString></ChapterDisplay>\n' ..
            '  </ChapterAtom>\n',
            hh, mm, ss, ns, ch.title or ""))
    end
    f:write('</EditionEntry></Chapters>\n')
    f:close()
    return true
end

local function save_mkv(mkvpropedit, filepath, chapters, dir)
    local xml = dir .. "_chaptmp.xml"
    if not write_xml(chapters, xml) then
        mp.osd_message("Error: could not write temp XML", 3); return
    end
    mp.osd_message("Saving chapters…", 10)
    local r = mp.command_native({
        name = "subprocess",
        args = {mkvpropedit, filepath, "--chapters", xml},
        capture_stdout = true, capture_stderr = true,
    })
    os.remove(xml)
    if r.status == 0 then
        mp.osd_message(string.format("Saved %d chapters to file", #chapters), 4)
    else
        mp.osd_message("mkvpropedit error — chapters not saved\n" .. (r.stderr or ""), 6)
    end
end

-- ── Save with ffmpeg (any format, remux to new file) ─────────────────────────

local function write_ffmeta(chapters, duration, path)
    local f = io.open(path, "w")
    if not f then return false end
    f:write(";FFMETADATA1\n")
    for i, ch in ipairs(chapters) do
        local s_ms = math.floor(ch.time * 1000)
        local e_ms = chapters[i + 1]
            and (math.floor(chapters[i + 1].time * 1000) - 1)
            or  math.floor((duration or (ch.time + 1)) * 1000)
        f:write(string.format(
            "\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=%d\nEND=%d\ntitle=%s\n",
            s_ms, e_ms, ch.title or ""))
    end
    f:close()
    return true
end

local function save_ffmpeg(ffmpeg, filepath, chapters, dir, basename, ext)
    local duration = mp.get_property_number("duration") or 0
    local meta_tmp = dir .. "_chapmeta.txt"
    -- Output alongside original so there are no file-lock issues
    local outpath  = dir .. basename .. "_chapters." .. ext

    if not write_ffmeta(chapters, duration, meta_tmp) then
        mp.osd_message("Error: could not write ffmetadata", 3); return
    end

    mp.osd_message("Remuxing with chapters… (do not close mpv)", 30)
    local r = mp.command_native({
        name = "subprocess",
        args = {ffmpeg, "-y", "-i", filepath, "-i", meta_tmp,
                "-map_metadata", "1", "-map_metadata:s:v", "0:s:v",
                "-c", "copy", outpath},
        capture_stdout = true, capture_stderr = true,
    })
    os.remove(meta_tmp)

    if r.status == 0 then
        mp.osd_message(string.format(
            "Saved %d chapters →\n%s", #chapters, basename .. "_chapters." .. ext), 6)
    else
        os.remove(outpath)
        mp.osd_message("ffmpeg error — chapters not saved", 5)
    end
end

-- ── Main save dispatcher ──────────────────────────────────────────────────────

local function save_chapters()
    local path = mp.get_property("path")
    if not path or path:match("^https?://") then
        mp.osd_message("Cannot save chapters for streams", 3); return
    end

    local chapters = mp.get_property_native("chapter-list") or {}
    if #chapters == 0 then
        mp.osd_message("No chapters to save  (press t to add one)", 3); return
    end

    local dir, filename = utils.split_path(path)
    local basename = filename:match("^(.+)%.[^%.]+$") or filename
    local ext      = filename:match("%.([^%.]+)$") or "mkv"

    if ext:lower() == "mkv" or ext:lower() == "mka" then
        local mkvpe = find_exe("mkvpropedit")
        if mkvpe then
            save_mkv(mkvpe, path, chapters, dir)
            return
        end
    end

    local ffmpeg = find_exe("ffmpeg")
    if ffmpeg then
        save_ffmpeg(ffmpeg, path, chapters, dir, basename, ext)
    else
        mp.osd_message("ffmpeg not found — place ffmpeg.exe in C:\\mpv\\", 5)
    end
end

-- ── Bindings ─────────────────────────────────────────────────────────────────

mp.add_forced_key_binding("t", "chapter-add",  add_chapter)
mp.add_forced_key_binding("T", "chapter-save", save_chapters)
