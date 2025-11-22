if cfg.textUI ~= 'qb' then return end

textUI = {}

textUI.show = function(text, options)
    text = text:gsub('\n', '<br>')
    exports['qb-core']:DrawText(text)
end

textUI.hide = function()
    exports['qb-core']:HideText(text)
end
