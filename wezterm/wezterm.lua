local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Open every tab/pane in WSL Ubuntu (splits keep the current directory)
config.default_domain = "WSL:Ubuntu"

-- Look
config.font = wezterm.font("MesloLGS NF")
config.font_size = 11
config.color_scheme = "Tokyo Night" -- matches LazyVim's default theme
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.window_padding = { left = 4, right = 4, top = 4, bottom = 0 }

-- tmux-style prefix: Alt+a, then a key (Alt+a twice sends a real Alt+a).
-- Not Ctrl+b/Ctrl+a so it doesn't clash with tmux (Ctrl+a) running inside.
config.leader = { key = "a", mods = "ALT", timeout_milliseconds = 1000 }

config.keys = {
  { key = "a", mods = "LEADER|ALT", action = act.SendKey({ key = "a", mods = "ALT" }) },

  -- panes
  { key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "LeftArrow", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "DownArrow", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "UpArrow", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "RightArrow", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "o", mods = "LEADER", action = act.ActivatePaneDirection("Next") },
  { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- tabs (tmux "windows")
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "w", mods = "LEADER", action = act.ShowTabNavigator },
  { key = "&", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
  {
    key = ",",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Rename tab",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },

  -- copy mode / paste
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "]", mods = "LEADER", action = act.PasteFrom("Clipboard") },
}

-- Alt+a then 0-9 jumps to that tab (0 = first, like tmux)
for i = 0, 9 do
  table.insert(config.keys, { key = tostring(i), mods = "LEADER", action = act.ActivateTab(i) })
end

-- Show "PREFIX" in the status bar while Alt+a is waiting for a key
wezterm.on("update-right-status", function(window, _)
  window:set_right_status(window:leader_is_active() and " PREFIX " or "")
end)

return config
