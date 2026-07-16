# FocusWindow Spoon

Dims the current screen while leaving the focused window visible.

Inspired by https://github.com/cabeen/zen-mode

## Install


`git clone https://github.com/palaniraja/FocusWindow.git  ~/.hammerspoon/Spoons/FocusWindow`

or Download repo and copy `FocusWindow.spoon` into:

```text
~/.hammerspoon/Spoons/
```

Then add this to `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("FocusWindow")

spoon.FocusWindow:bindHotkeys({
    toggle = { { "alt", "cmd" }, "z" },
})
```

Reload Hammerspoon.

- `Option + Command + Z` toggles the effect.
- `Escape` turns it off.

## Optional settings

Set these before binding the hotkey:

```lua
spoon.FocusWindow.padding = -2
spoon.FocusWindow.cornerRadius = 24
spoon.FocusWindow.fillColor = { white = 0, alpha = 0.85 }
```

The cutout does not follow the window if it is moved or resized while active.
