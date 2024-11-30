lunajson = require 'Lib/Lua/lunajson/lunajson'

function make()
    -- open the json file
    local jsonfile = io.open('make.json',"r"):read "*a"
    -- decode json file
    local parms = lunajson.decode(jsonfile)

    local hw        = parms["Homework"]
    local class     = parms["Class"]
    local year      = parms["Year"]
    local author    = parms["Author"]
    local quarter   = parms["Quarter"]
    
    local out = table.concat({
    '\\title{Physics ', class, ': Homework ', hw, '}',
    '\\author{Kelanu R.}',
    '\\date{', quarter, ' ', year, '}',
    '\\maketitle',
    '\\pagebreak',
    '\\counterwithin*{equation}{section}',
    '\\include{Resources/', class, '/Homework ', hw, '/', class, ' Homework ', hw, '}'
    })
    
    return out
end