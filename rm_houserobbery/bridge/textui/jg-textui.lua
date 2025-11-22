if cfg.textUI ~= 'jg-textui' then return end

textUI = {}

textUI.show = function(text, options)
    exports['jg-textui']:DrawText(text)
end

textUI.hide = function()
    exports['jg-textui']:HideText()
end
