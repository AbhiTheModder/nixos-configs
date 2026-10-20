local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- Typography
config.font = wezterm.font_with_fallback {
  'Maple Mono NF CN',
  'Noto Color Emoji',
  'Symbols Nerd Font Mono',
}
config.font_size = 12.0
config.line_height = 1.05
config.adjust_window_size_when_changing_font_size = false

config.color_scheme = 'Noctalia'

-- Mango handles the outer window layout, opacity and compositor effects.
config.enable_wayland = true
-- Mango already owns the border and resize behavior. Keeping WezTerm's own
-- resize decoration can produce a bad initial Wayland window offset.
config.window_decorations = 'NONE'
config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}

config.scrollback_lines = 10000
config.default_cursor_style = 'SteadyBar'
config.audible_bell = 'Disabled'
config.hide_mouse_cursor_when_typing = true

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false
config.status_update_interval = 1000

config.keys = {
  {
    key = 'p',
    mods = 'CTRL|ALT',
    action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES|TABS' },
  },
  {
    key = 'n',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = 'New workspace: ',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
}

config.inactive_pane_hsb = {
  saturation = 0.85,
  brightness = 0.70,
}

config.ssh_backend = 'LibSsh'
config.ssh_domains = wezterm.default_ssh_domains()

for _, domain in ipairs(config.ssh_domains) do
  if domain.name:match '^SSH:' then
    domain.assume_shell = 'Posix'
  end
end

local function domain_label(domain_name)
  local label = domain_name or 'local'
  label = label:gsub('^SSHMUX:', '')
  label = label:gsub('^SSH:', '')
  return label
end

local function path_from_uri(uri)
  if not uri then
    return nil
  end

  local value = tostring(uri)
  if value:match '^file://' then
    return value:gsub('^file://[^/]*', '')
  end

  return uri.file_path
end

local function basename_from_uri(uri)
  local path = path_from_uri(uri)
  if not path or path == '' then
    return '~'
  end

  path = path:gsub('/+$', '')
  return path:match '([^/]+)$' or path
end

local function project_label(uri)
  return basename_from_uri(uri)
end

local function git_branch(uri)
  local path = path_from_uri(uri)
  if not path then
    return nil
  end

  local ok, success, stdout = pcall(
    wezterm.run_child_process,
    { 'git', '-C', path, 'branch', '--show-current' }
  )
  if ok and success and stdout then
    local branch = stdout:gsub('%s+$', '')
    return branch ~= '' and branch or nil
  end

  return nil
end

local function process_label(pane)
  local process = pane.foreground_process_name or ''
  process = process:gsub('^.*/', '')

  local known_agents = {
    ['claude'] = 'Claude',
    ['.claude-wrapped'] = 'Claude',
    ['codex'] = 'Codex',
    ['.codex-wrapped'] = 'Codex',
    ['opencode'] = 'OpenCode',
    ['pi'] = 'Pi',
    ['crush'] = 'Crush',
  }

  return known_agents[process] or process
end

local function workspace_label()
  return wezterm.mux.get_active_workspace() or 'default'
end

wezterm.on('update-right-status', function(window, pane)
  local cwd_uri = pane:get_current_working_dir()
  local workspace = workspace_label()
  local branch = git_branch(cwd_uri)
  local branch_label = branch and string.format('  ·   %s', branch) or ''
  window:set_right_status(wezterm.format {
    { Foreground = { Color = '#8be9fd' } },
    { Text = string.format(' 󰉋 %s%s ', workspace, branch_label) },
  })
end)

-- Keep the remote host visible in every tab, especially when several SSH
-- aliases are open at once.
wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local pane = tab.active_pane
  local domain = domain_label(pane.domain_name)
  local project = project_label(pane.current_working_dir)
  local agent = process_label(pane)
  local title = tab.tab_title and #tab.tab_title > 0 and tab.tab_title or agent

  local has_unseen_output = false
  for _, tab_pane in ipairs(tab.panes) do
    if tab_pane.has_unseen_output then
      has_unseen_output = true
      break
    end
  end

  local background = '#242631'
  local foreground = '#aeb4c4'

  if tab.is_active then
    background = domain == 'local' and '#3b4261' or '#31556b'
    foreground = '#f8f8f2'
  elseif has_unseen_output then
    background = '#f1c75b'
    foreground = '#20222d'
  elseif hover then
    background = '#34394d'
    foreground = '#f8f8f2'
  end

  local domain_prefix = domain == 'local' and '' or string.format('%s  ', domain)
  local label = string.format(' %s%s / %s ', domain_prefix, project, title)
  label = wezterm.truncate_right(label, max_width)

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = label },
  }
end)

return config
