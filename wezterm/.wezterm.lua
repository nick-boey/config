local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { 'pwsh.exe', 'NoLogo'}

config.color_scheme = 'JetBrains Darcula'
config.colors = {
	background = "#1f1f1f",
}

config.warn_about_missing_glyphs = false
config.hide_tab_bar_if_only_one_tab = true

config.keys = {
	{
		key = "I",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			top_level = true,
			direction = "Right",
			size = { Percent = 50 },
		}),
	},
	{
		key = "O",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SplitPane({
			top_level = true,
			direction = "Down",
			size = { Percent = 50 },
		}),
	},
	{
		key = "s",
		mods = "CTRL|SHIFT",
		action = wezterm.action.PaneSelect {
			mode = "SwapWithActive"
		}
	},
	{
		key = "q",
		mods = "CTRL|SHIFT",
		action = wezterm.action({ CloseCurrentPane = { confirm = false } }),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = 'F11',
		action = wezterm.action.ToggleFullScreen,
	}
}

return config
