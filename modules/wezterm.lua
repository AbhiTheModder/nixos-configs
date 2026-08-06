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

-- Keep the remote host visible in every tab, especially when several SSH
-- aliases are open at once.
wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
  local pane = tab.active_pane
  local domain = domain_label(pane.domain_name)
  local title = tab.tab_title

  if not title or #title == 0 then
    title = pane.title
  end

  local has_unseen_output = false
  for _, tab_pane in ipairs(tab.panes) do
    if tab_pane.has_unseen_output then
      has_unseen_output = true
      break
    end
  end

  local background = '#282a36'
  local foreground = '#bd93f9'

  if tab.is_active then
    background = domain == 'local' and '#44475a' or '#6272a4'
    foreground = '#f8f8f2'
  elseif has_unseen_output then
    background = '#ffb86c'
    foreground = '#282a36'
  elseif hover then
    background = '#44475a'
    foreground = '#f8f8f2'
  end

  local label = string.format(' %s · %s ', domain, title)
  label = wezterm.truncate_right(label, max_width)

  return {
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = label },
  }
end)

return config
