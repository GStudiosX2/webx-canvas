function set_interval(f, interval: number)
  local function i()
    set_timeout(function()
      f()
      i()
    end, interval)
  end
  i()
end

return set_interval
