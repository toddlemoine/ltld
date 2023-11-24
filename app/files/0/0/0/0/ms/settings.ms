toggle_settings_theme = function()
  if settings.theme == "light" then
    settings.theme = "dark"
  else
    settings.theme = "light"
  end
  save_settings()  
end

toggle_settings_mode = function()
  if settings.mode == "0" then
    settings.mode = "1"
  else
    settings.mode = "0"
  end
  save_settings()  
end

save_settings = function()
  storage.set('settings', settings)
end
