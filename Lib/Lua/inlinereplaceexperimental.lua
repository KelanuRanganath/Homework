lunajson = require 'Lib/Lua/lunajson/lunajson'

function inlinereplaceexperimental(input_counter)
    -- texio.write("Debug :"..input_counter)
    -- open the json file
    local jsonfile = io.open('make.json',"r"):read "*a"
    -- decode json file
    local parms = lunajson.decode(jsonfile)

    -- extract homework and class of current file
    local hw        = parms["Homework"]
    local class     = parms["Class"]

    -- read in .tex file
    if input_counter == 0 then
        lines = ""
        while 1 == 1 do
            local lines_partial = {}
            position, length, _ = hw:find("[0-9]+")
            
                if position == nil then
                    break
                end
                    
            hws = string.sub(hw,position,position)
    
            file_path = table.concat({'Resources/', class, '/Homework ', hws, '/', class, ' Homework ', hws, '.tex'})
    
            for line in io.lines(file_path) do 
                lines_partial[#lines_partial + 1] = line
            end
            
            lines = lines..table.concat(lines_partial, " \\\\ ")
            -- texio.write("Debug :"..lines)
            hw = string.sub(hw,position+length+1,-1)
        end

        -- texio.write("Debug :"..lines)

        -- iterate through .tex file and extract each \exe enviroment
        matches = {}
        counter = 1
        while 1 == 1 do
            local position , length, _ = lines:find("\\eqe{[^}]+}")
            
            if position == nil then
                break
            end

            local j = 4
            local k = 0
            while 1 == 1 do
                if string.sub(lines,position + j,position+j) == "{" then
                    k = k + 1
                elseif string.sub(lines,position + j,position+j) == "}" then
                    k = k - 1
                end
                if k == 0 then
                    break
                end
                j = j + 1
            end

            matches[counter] = string.sub(lines,position+8,position+j-4)
            -- texio.write("Debug :"..position..matches[counter])
            lines = string.sub(lines,position+j+1,-1)
            counter = counter + 1

        end

        local matches_json = lunajson.encode(matches)
        local matches_handle = io.open("Lib/matches.json", "w")

        if matches_handle then
            -- Write content to file
            matches_handle:write(matches_json)
            -- Close the file
            matches_handle:close()
        end
    end
    
    -- open the json file
    local matchesjson = io.open('Lib/matches.json',"r"):read "*a"
    
    -- decode json file
    local matches = lunajson.decode(matchesjson)

    output_string = matches[input_counter+1]
    
    -- open the json file
    local jsonfile = io.open('macro.json',"r"):read "*a"
    -- decode json file
    local macros = lunajson.decode(jsonfile)
    
    -- autoreplace from macro file
    for pat, repl in pairs(macros) do
        --texio.write("Break point :[%^\\]"..pat)
        output_string = output_string:gsub("([^\\])"..pat,"%1"..repl)
    end

    -- more complicated inline replacements
    -- replace <> with bracket
    output_string = output_string:gsub("(%b<>)",function(x)
        return '\\braket{'..x:sub(2,-2)..'}'
        end
    )
    
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

    -- replace integrals
    output_string = output_string:gsub("dint ([^%s]+) ([^%s]+)",function(x,y)
        return '\\int_{'..x..'}^{'..y..'}'
    end
    )

    -- replace sums
    output_string = output_string:gsub("dsum ([^%s]+) ([^%s]+)",function(x,y)
        return '\\sum_{'..x..'}^{'..y..'}'
    end
    )

    output_string = output_string:gsub("lsum ([^%s]+) ",function(x)
        return '\\sum_{'..x..'}'
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
    
    begin_string = '\\begin{equation} \\begin{split} '
    end_string = '\\end{split} \\end{equation}'

    -- texio.write("Debug :"..output_string)

    return begin_string..output_string..end_string
end