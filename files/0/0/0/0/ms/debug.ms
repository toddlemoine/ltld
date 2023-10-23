debug = function()
  if not DEBUGGER then return end
  for arg in arguments
    if arg.type == "list" then 
      // for x in arg debug(x) end
      print(arg)
    else
      print(arg)
    end
  end
end