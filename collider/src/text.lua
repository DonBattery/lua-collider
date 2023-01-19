_G.fontSizes = {
    large = 26,
    medium = 14,
    small = 8,
}

_G.fonts = {}

function _G.loadFont(name, source)
    fonts[name .. "LG"] = love.graphics.newFont(source, fontSizes.large)
    fonts[name .. "MD"] = love.graphics.newFont(source, fontSizes.medium)
    fonts[name .. "SM"] = love.graphics.newFont(source, fontSizes.small)
end

local function getFont(fontName)
    if fonts[fontName] ~= nil then
        return fonts[fontName]
    elseif fonts[fontName .. "MD"] ~= nil then
        return fonts[fontName .. "MD"]
    end
    return love.graphics.getFont()
end

function _G.text(text, x, y, color, font)
    love.graphics.setFont(getFont(font))
    love.graphics.setColor(color)
    love.graphics.print(text, x, y)
end

return {
    loadFont = loadFont,
    text = text,
}