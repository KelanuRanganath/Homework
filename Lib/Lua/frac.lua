dofile('Lib/Lua/split.lua')

function frac(input)
    split = split_string(input, '|')  
    str = table.concat({'{',split[1],'}{',split[2],'}'})
    return str
end