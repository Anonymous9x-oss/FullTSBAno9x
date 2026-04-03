local VALID_KEY = "CH001-ANONYMOUS9x-KEY-FREE"

return function(inputKey)
    if inputKey == VALID_KEY then
        return true
    else
        return false
    end
end
