local wezterm = require 'wezterm'

local home = wezterm.home_dir

local M = {
  home = home,
  workstation = home .. '\\workstation',
}

M.dotfiles = M.workstation .. '\\dotfiles'
M.projects = M.dotfiles .. '\\projects'

function M.file_exists(path)
  local fh = io.open(path, 'r')
  if fh then
    fh:close()
    return true
  end
  return false
end

return M
