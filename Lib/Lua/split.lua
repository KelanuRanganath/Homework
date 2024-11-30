function split_string(input_string, delimiter)
  local result = {}
  for match in (input_string .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end