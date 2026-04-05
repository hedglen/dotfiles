-- favorites.lua
-- F16   (btn 4)            → open favorites as playlist
-- Ctrl+F16  (btn 4)        → add current file to favorites
-- Alt+F16   (btn 4)        → open remove-favorites menu

local mp    = require 'mp'
local utils = require 'mp.utils'

local fav_file = mp.command_native({"expand-path", "~~/favorites.txt"})

-- ── helpers ──────────────────────────────────────────────────────────────────

local function read_favorites()
    local lines = {}
    local f = io.open(fav_file, "r")
    if f then
        for line in f:lines() do
            if line ~= "" then table.insert(lines, line) end
        end
        f:close()
    end
    return lines
end

local function write_favorites(lines)
    local f = io.open(fav_file, "w")
    if f then
        for _, line in ipairs(lines) do f:write(line .. "\n") end
        f:close()
        return true
    end
    return false
end

-- ── add ──────────────────────────────────────────────────────────────────────

local function add_favorite()
    local path = mp.get_property("path")
    if not path then mp.osd_message("No file playing"); return end

    local lines = read_favorites()
    for _, line in ipairs(lines) do
        if line == path then mp.osd_message("Already in favorites"); return end
    end

    table.insert(lines, path)
    if write_favorites(lines) then
        mp.osd_message("Added to favorites: " .. (mp.get_property("filename") or path))
    else
        mp.osd_message("Error: could not write favorites file")
    end
end

-- ── open as playlist ─────────────────────────────────────────────────────────

local function open_favorites()
    local f = io.open(fav_file, "r")
    if not f then
        mp.osd_message("Favorites empty — Ctrl+F16 to add current file")
        return
    end
    f:close()
    -- Tell autoload this is a manual playlist so it doesn't override it
    mp.commandv("script-message-to", "autoload", "autoload-reset")
    mp.commandv("loadlist", fav_file, "replace")
    mp.osd_message("Loaded favorites")
end

-- ── remove (called by uosc menu selection) ───────────────────────────────────

local function remove_favorite(path)
    if not path or path == "" then return end
    local lines = read_favorites()
    local new_lines = {}
    local removed = false
    for _, line in ipairs(lines) do
        if line == path then
            removed = true
        else
            table.insert(new_lines, line)
        end
    end
    if removed and write_favorites(new_lines) then
        local name = path:match("[^\\/]+$") or path
        mp.osd_message("Removed from favorites:\n" .. name, 3)
    end
end

-- ── remove menu ──────────────────────────────────────────────────────────────

local function remove_favorites_menu()
    local lines = read_favorites()
    if #lines == 0 then
        mp.osd_message("No favorites to remove")
        return
    end

    local items = {}
    for _, path in ipairs(lines) do
        local name = path:match("[^\\/]+$") or path
        table.insert(items, {
            title = name,
            hint  = path,
            value = {"script-message-to", "favorites", "remove-favorite", path},
        })
    end

    local menu = {
        type  = "menu",
        title = "Remove Favorite",
        items = items,
    }

    mp.commandv("script-message-to", "uosc", "open-menu",
        utils.format_json(menu))
end

-- ── bindings ─────────────────────────────────────────────────────────────────

mp.add_key_binding(nil, "favorites-open",          open_favorites)
mp.add_key_binding(nil, "favorites-add",           add_favorite)
mp.add_key_binding(nil, "favorites-remove-menu",   remove_favorites_menu)

mp.register_script_message("favorites-open",        open_favorites)
mp.register_script_message("favorites-add",         add_favorite)
mp.register_script_message("favorites-remove-menu", remove_favorites_menu)
mp.register_script_message("remove-favorite",       remove_favorite)
