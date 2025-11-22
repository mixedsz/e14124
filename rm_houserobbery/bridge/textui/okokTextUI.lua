if cfg.textUI ~= 'okokTextUI' then return end

textUI = {}

textUI.show = function(text, options)
    text = text:gsub('\n', '<br>')
    exports['okokTextUI']:Open(text, 'darkgrey', 'left')
end

textUI.hide = function()
    exports['okokTextUI']:Close()
end
