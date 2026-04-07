local wezterm = require 'wezterm'

local paths = require 'modules.paths'

local function resolve_git_bash()
  local from_env = (os.getenv 'WEZTERM_GIT_BASH' or ''):gsub('^%s+', ''):gsub('%s+$', '')
  if from_env ~= '' and paths.file_exists(from_env) then
    return from_env
  end
  local candidates = {
    'C:\\Program Files\\Git\\bin\\bash.exe',
    paths.home .. '\\scoop\\apps\\git\\current\\bin\\bash.exe',
    paths.home .. '\\AppData\\Local\\Programs\\Git\\bin\\bash.exe',
  }
  for _, candidate in ipairs(candidates) do
    if paths.file_exists(candidate) then
      return candidate
    end
  end
  wezterm.log_error('Git Bash not found in known paths; falling back to Program Files default.')
  return 'C:\\Program Files\\Git\\bin\\bash.exe'
end

local function resolve_wsl_distro()
  -- Keep distro resolution import-safe: no run_child_process during require().
  local from_env = (os.getenv('WEZTERM_WSL_DISTRO') or ''):gsub('^%s+', ''):gsub('%s+$', '')
  if from_env ~= '' then
    return from_env
  end
  return 'Ubuntu'
end

return {
  git_bash = resolve_git_bash(),
  wsl_distro = resolve_wsl_distro(),
}
