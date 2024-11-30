function inlinecv(input_string)
    output_string = input_string:gsub(" ","\\\\")
    return output_string
end