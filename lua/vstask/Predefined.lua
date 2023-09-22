-- split a string into a table
-- @param s string to split
-- @param delimiter substring to split on
function Split(s, delimiter)
  local result = {};
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match);
  end
  return result;
end

local get_abs_file = function()
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_bufnr)
  local absolute_path = vim.fn.expand(current_file)
  return absolute_path
end

local get_relative_file = function()
  return vim.fn.bufname()
end

-- get the path seperator for the current os
local get_path_seperator = function()
  return package.config:sub(1, 1)
end

-- get filename from path string
-- returns the filename from a absolute path
-- @param path character to split on
local get_filename = function(path)
  local sep = get_path_seperator()
  local split = Split(path, sep)
  return split[#split]
end

-- get the current opened file's dirname relative to workspaceFolder
-- @param workspaceFolder the workspace folder
-- @param filePath the file path
-- @return the relative path to the file
-- @return the filename
local get_relative_path = function(workspaceFolder, filePath)
  local filename = get_filename(filePath)
  local relativePath = filePath:gsub(workspaceFolder, "")
  return relativePath, filename
end


-- get the current opened files base name (without extension)
local get_current_file_basename_no_extension = function()
  local sep = get_path_seperator()
  local path = get_abs_file()
  local split = Split(path, sep)   -- split on /
  local filename = split[#split]   -- get the filename
  split = Split(filename, "%.")    -- split on .
  table.remove(split, #split)      -- remove extension
  return table.concat(split, "%.") -- join back together
end

-- get the current opened files base name
local get_current_file_basename = function()
  local sep = get_path_seperator()
  local path = get_relative_file() -- get the path
  local split = Split(path, sep)   -- split on /
  local filename = split[#split]   -- get the filename
  return filename
end

-- get current opened files dirname
local get_current_file_dirname = function()
  local sep = get_path_seperator()
  local path = get_abs_file()     -- get the path
  local split = Split(path, sep)  -- split on /
  table.remove(split, #split)     -- remove filename
  return table.concat(split, sep) -- join back together
end

-- get the current open files extension
local get_current_file_extension = function()
  local filename = get_relative_file()   -- get the path
  local pos = filename:find("%.[^%.]+$") -- 查找最后一个点及其后面的内容
  if pos then
    return filename:sub(pos + 1)         -- 返回后缀部分
  else
    return ""                            -- 如果没有找到后缀，则返回空字符串
  end
end

-- get the current working directory
local get_current_dir = function()
  return vim.fn.fnamemodify(vim.fn.getcwd(), ":h")
end

-- get the current line number
local get_current_line_number = function()
  return vim.fn.line(".")
end

-- get the selected text
local get_selected_text = function()
  return vim.fn.getreg("*")
end

-- get the exec path
local get_exec_path = function()
  return vim.fn.executable()
end



local get_file = function()
  return get_filename(get_abs_file())
end

-- get the file workspace folder
local function find_git_vscode_directory(start_directory)
  local current_directory = vim.fn.expand(start_directory)
  while current_directory ~= '/' do
    local git_directory = current_directory .. '/.git'
    local vscode_directory = current_directory .. '/.vscode'
    local nvim_directory = current_directory .. '/.nvim'
    local project_file = current_directory .. '/.project'
    if vim.fn.isdirectory(nvim_directory) == 1 then
      return current_directory
    elseif vim.fn.isdirectory(git_directory) == 1 then
      return current_directory
    elseif vim.fn.isdirectory(vscode_directory) == 1 then
      return current_directory
    elseif vim.fn.filereadable(project_file) == 1 then
      return current_directory
    end
    current_directory = vim.fn.fnamemodify(current_directory, ':h')
  end
  return nil
end

local get_file_workspace_folder = function()
  return find_git_vscode_directory(get_current_file_dirname())
end



local get_workspacefolder_basename = function()
  return get_filename(vim.fn.getcwd())
end

local get_relative_file_dirname = function()
  local sep = get_path_seperator()
  local workspaceFolder = get_file_workspace_folder()
  local filePath = get_relative_file()
  local relativePath, filename = get_relative_path(workspaceFolder, filePath)
  local relativeFileDirname = Split(relativePath, filename)[1]
  -- if the last char is / then remove it
  if relativeFileDirname and relativeFileDirname:sub(-1) == sep then
    relativeFileDirname = relativeFileDirname:sub(1, -2)
  end
  return relativeFileDirname
end

return {
  ["workspaceFolder"] = vim.fn.getcwd,
  ["workspaceFolderBasename"] = get_workspacefolder_basename,
  ["file"] = get_file,
  ["fileWorkspaceFolder"] = get_file_workspace_folder,
  ["relativeFile"] = get_relative_file,
  ["relativeFileDirname"] = get_relative_file_dirname,
  ["fileBasename"] = get_current_file_basename,
  ["fileBasenameNoExtension"] = get_current_file_basename_no_extension,
  ["fileDirname"] = get_current_file_dirname,
  ["fileExtname"] = get_current_file_extension,
  ["cwd"] = get_current_dir,
  ["lineNumber"] = get_current_line_number,
  ["selectedText"] = get_selected_text,
  -- ["execPath"] = get_exec_path,
  ["defaultBuildTask"] = nil,
  ["pathSeparator"] = get_path_seperator
}
