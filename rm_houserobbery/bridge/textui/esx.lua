if cfg.textUI ~= 'esx' then return end

textUI = {}

textUI.show = function(text, options)
    text = text:gsub('\n', '<br>')
    exports['esx_textui']:TextUI(text)
end

textUI.hide = function()
    exports['esx_textui']:HideUI()
end
