local obj = {}
obj.__index = obj

obj.name = "FocusWindow"
obj.version = "1.0"
obj.author = "palaniraja"
obj.license = "MIT"
obj.homepage = ""

obj.padding = -2
obj.cornerRadius = 24
obj.fillColor = { white = 0, alpha = 0.85 }

obj._canvas = nil
obj._escapeHotkey = nil
obj._toggleHotkey = nil

local function cutoutFrame(windowFrame, screenFrame, padding)
    return {
        x = windowFrame.x - screenFrame.x + padding,
        y = windowFrame.y - screenFrame.y + padding,
        w = windowFrame.w - padding * 2,
        h = windowFrame.h - padding * 2,
    }
end

function obj:stop()
    if self._canvas then
        self._canvas:delete()
        self._canvas = nil
    end

    if self._escapeHotkey then
        self._escapeHotkey:disable()
    end

    return self
end

function obj:start()
    if self._canvas then
        return self
    end

    local win = hs.window.focusedWindow()
    if not win then
        hs.alert.show("FocusWindow: no focused window")
        return self
    end

    local screen = win:screen()
    local screenFrame = screen:fullFrame()
    local windowFrame = win:frame()

    self._canvas = hs.canvas.new(screenFrame)
        :level(hs.canvas.windowLevels.cursor)

    self._canvas:appendElements(
        {
            type = "rectangle",
            action = "fill",
            fillColor = self.fillColor,
        },
        {
            type = "rectangle",
            action = "fill",
            compositeRule = "clear",
            roundedRectRadii = {
                xRadius = self.cornerRadius,
                yRadius = self.cornerRadius,
            },
            frame = cutoutFrame(windowFrame, screenFrame, self.padding),
        }
    )

    self._canvas:show()
    win:focus()

    if not self._escapeHotkey then
        self._escapeHotkey = hs.hotkey.new({}, "escape", function()
            self:stop()
        end)
    end

    self._escapeHotkey:enable()
    return self
end

function obj:toggle()
    if self._canvas then
        return self:stop()
    end

    return self:start()
end

function obj:bindHotkeys(mapping)
    if self._toggleHotkey then
        self._toggleHotkey:delete()
        self._toggleHotkey = nil
    end

    local toggle = mapping and mapping.toggle
    if toggle then
        self._toggleHotkey = hs.hotkey.bind(toggle[1], toggle[2], function()
            self:toggle()
        end)
    end

    return self
end

return obj
