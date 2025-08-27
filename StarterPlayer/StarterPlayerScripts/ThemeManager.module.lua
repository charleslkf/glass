local ThemeManager = {}

ThemeManager.Themes = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 30),
        Primary = Color3.fromRGB(45, 45, 45),
        Secondary = Color3.fromRGB(60, 60, 60),
        Tertiary = Color3.fromRGB(80, 80, 80),
        Text = Color3.new(1, 1, 1),
        Success = Color3.fromRGB(100, 255, 100),
        Failure = Color3.fromRGB(255, 100, 100),
        Highlight = Color3.fromRGB(200, 200, 100),
        Border = Color3.fromRGB(200, 200, 200),
        Handle = Color3.fromRGB(220, 40, 40),
        SuccessZone = Color3.new(1, 1, 1),
        MemoryPattern = Color3.fromRGB(150, 150, 255),
        PairColors = {
            Color3.fromRGB(255, 87, 87),
            Color3.fromRGB(87, 255, 87),
            Color3.fromRGB(87, 87, 255),
            Color3.fromRGB(255, 255, 87),
            Color3.fromRGB(255, 87, 255),
            Color3.fromRGB(87, 255, 255),
        }
    }
}

-- For now, we'll just use the dark theme by default.
ThemeManager.CurrentTheme = ThemeManager.Themes.Dark

function ThemeManager.get(colorName)
    return ThemeManager.CurrentTheme[colorName]
end

return ThemeManager
