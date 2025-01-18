lunajson = require 'Lib/Lua/lunajson/lunajson'

function inlinereplace(input_string)
    local output_string = input_string
    
    -- open the json file
    local jsonfile = io.open('macro.json',"r"):read "*a"
    -- decode json file
    local macros = lunajson.decode(jsonfile)

    -- autoreplace from macro file
    for pat, repl in pairs(macros) do
        output_string = output_string:gsub("([^\\])"..pat,"%1"..repl)
    end

    -- more complicated inline replacements
    -- replace <> with bracket
    output_string = output_string:gsub("(%b<>)",function(x)
        return '\\braket{'..x:sub(2,-2)..'}'
        end
    )

    -- replace differential operators
    output_string = output_string:gsub("[dp][dp][^0-9^%s]+[0-9][^%s]*",function(x)
        local operator = x:sub(1,1)
        if operator == 'p' then
            operator = '\\partial '
        end
        local order_pos , _, _ = x:find("[0-9]")
        local order = x:sub(order_pos,order_pos)
        if order == '0' then
            order = ''
        else
            order = '^'..order
        end
        local var = x:sub(3,order_pos-1)
        local func = ""
        if #x > order_pos then
            func = x:sub(order_pos+1,-1)
        end
        return '\\frac{'..operator..order..func..'}{'..operator..var..order..'}'
    end
    )

    -- replace integrals
    output_string = output_string:gsub("dint ([^%s]+) ([^%s]+)",function(x,y)
        return '\\int_{'..x..'}^{'..y..'}'
    end
    )

    -- recursively replace brackets
    function bracket(string)
        top_output = string:gsub("%b()",function(x)
            nest_output = bracket(x:sub(2,-2))
            return '\\br{'..nest_output..'}'
        end
        )
        return top_output
    end
    output_string = bracket(output_string)

    -- replace fractions
    function fraction(string)
        if string:match(" ([^%s]+)/([^%s]+) ") then
            top_output = string:gsub(" ([^%s]+)/([^%s]+) ", function(x,y)
                return '\\frac{'..x..'}{'..y..'} '
            end
            )
            return fraction(top_output)
        else
            return string
        end 
    end
    output_string = fraction(output_string)

    begin_string = '\\begin{equation}\\begin{split}'
    end_string = '\\end{split}\\end{equation}'
    
    return table.concat({begin_string, output_string, end_string})
end