local obj = {}

obj.__index = obj
obj.name = "FocusWindow"
obj.version = "1.2"
obj.author = "palaniraja"
obj.license = "MIT"

obj.padding = -2
obj.cornerRadius = 24
obj.fillColor = { white = 0, alpha = 0.85 }

obj.canvas = nil
obj.escapeHotkey = nil
obj.following = false
obj.windowFilter = nil

local function cutoutFrame(windowFrame, screenFrame, padding)
    return {
        x = windowFrame.x - screenFrame.x + padding,
        y = windowFrame.y - screenFrame.y + padding,
        w = windowFrame.w - padding * 2,
        h = windowFrame.h - padding * 2,
    }
end

function obj:update(win)
    win = win or hs.window.focusedWindow()

    if not win then
        return
    end

    local windowFrame = win:frame()
    local screen = win:screen()

    if not windowFrame or not screen then
        return
    end

    local screenFrame = screen:fullFrame()

    if not self.canvas then
        self.canvas = hs.canvas.new(screenFrame)
            :level(hs.canvas.windowLevels.cursor)

        self.canvas:appendElements(
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
                frame = cutoutFrame(
                    windowFrame,
                    screenFrame,
                    self.padding
                ),
            }
        )

        self.canvas:show()
    else
        -- Required when switching to a window on another monitor.
        self.canvas:frame(screenFrame)

        self.canvas[2].frame = cutoutFrame(
            windowFrame,
            screenFrame,
            self.padding
        )
    end

    self.escapeHotkey:enable()
end

function obj:hide()
    self.following = false

    if self.windowFilter then
        self.windowFilter:unsubscribeAll()
        self.windowFilter = nil
    end

    if self.canvas then
        self.canvas:delete()
        self.canvas = nil
    end

    if self.escapeHotkey then
        self.escapeHotkey:disable()
    end
end

-- Static mode: highlight only the currently focused window.
function obj:toggle()
    if self.canvas then
        self:hide()
    else
        self:update()
    end
end

-- Follow mode: move the cutout whenever focus changes.
function obj:toggleFollow()
    if self.following then
        self:hide()
        return
    end

    self:hide()
    self.following = true

    self.windowFilter = hs.window.filter.new()
    self.windowFilter:subscribe(
        hs.window.filter.windowFocused,
        function(win)
            if self.following then
                self:update(win)
            end
        end
    )

    self:update()
end

function obj:bindHotkeys(mapping)
    local spec = {
        toggle = hs.fnutils.partial(self.toggle, self),
        follow = hs.fnutils.partial(self.toggleFollow, self),
    }

    hs.spoons.bindHotkeysToSpec(spec, mapping)
    return self
end

function obj:start()
    if not self.escapeHotkey then
        self.escapeHotkey = hs.hotkey.new({}, "escape", function()
            self:hide()
        end)
    end

    return self
end

function obj:stop()
    self:hide()

    if self.escapeHotkey then
        self.escapeHotkey:delete()
        self.escapeHotkey = nil
    end

    return self
end

return obj