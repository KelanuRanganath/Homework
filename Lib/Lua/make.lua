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
    local title     = parms["Title"]
    local toc       = parms["Toc"]

    if title == "default" then
        title = '\\title{Physics '..class..': Homework '..hw..'}'
    else
        title = '\\title{'..title..'}'
    end

    if author == "none" then
        author = ""
    else
        author = '\\author{'..author..'}'
    end

    inc = '\\include{Resources/'..class..'/Homework '
    include = ""
    while 1 == 1 do
        local position, length, _ = hw:find("[0-9]+")
        
            if position == nil then
                break
            end
                
        hws = string.sub(hw,position,position)
        -- texio.write("Debug :"..hws)
        hw = string.sub(hw,position+length+1,-1)
        include = include..inc..hws..'/'..class..' Homework '..hws..'} '
    end

    if toc ~= "none" then
        toc = '\\tableofcontents'
    else
        toc = ''
    end
        
    local out = table.concat({
    title,
    author,
    '\\date{', quarter, ' ', year, '}',
    '\\maketitle',
    toc,
    '\\pagebreak',
    '\\counterwithin*{equation}{section}',
    include
    })
    
    return out
end