local Opts = require('vstask.Opts')
local function ToggleTerm_process(cwd, command, direction, opts)
  local size = Opts.get_size(direction, opts)
  if size ~= nil then
    size = " size=" .. size
  else
    size = ''
  end
  local opt_direction = Opts.get_direction(direction, opts)
  if opt_direction == 'current' then
    opt_direction = ""
  else
    opt_direction = ' direction=' .. opt_direction
  end
  local options = ''
  if cwd then
    options = options .. " dir=" .. cwd
  end
  vim.cmd("ToggleTerm " .. size .. opt_direction .. options)
  vim.cmd([[TermExec ]] .. size .. [[ cmd="]] .. command .. [["]])
end

return { Process = ToggleTerm_process }
