--- Decodes from JSON.
---

local function removeComments(json)
  local lines = vim.split(json, '\n')
  local filtered_lines = {}
  for _, line in ipairs(lines) do
    -- 忽略以 // 开头的行
    if not line:match('^%s*//') then
      table.insert(filtered_lines, line)
    end
  end
  return table.concat(filtered_lines, '\n')
end

---@param data string Data to decode
---@returns table json_obj Decoded JSON object
local json_decode = function(data)
  local json_file = io.open(data, 'r')
  if json_file == nil then
    return nil, 'JSON file not found'
  end
  local json_content = removeComments(json_file:read('*all'))
  json_file:close()
  local ok, result = pcall(vim.fn.json_decode, json_content)
  if ok then
    return result
  else
    return nil, result
  end
end




--- load settings from JSON file
---@param path string JSON file path
---@return boolean is_error if error then true
local load_setting_json = function(path)
  vim.validate {
    path = { path, 's' },
  }

  if vim.fn.filereadable(path) == 0 then
    print("Invalid file path.")
    return
  end

  local decoded, err = json_decode(path)
  if err ~= nil then
    print(err)
    return
  end
  return decoded
end

return {
  load_json = load_setting_json
}
