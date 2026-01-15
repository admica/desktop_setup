-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Dynamically find Python 3 executable
-- Priority: python3 -> python (if it's Python 3)
local function find_python3()
  -- Check common locations in order of preference
  local candidates = {
    vim.fn.expand("~") .. "/python311/bin/python3.11",
    vim.fn.expand("~") .. "/.pyenv/shims/python3",
    "/usr/bin/python3",
    "/usr/local/bin/python3",
  }

  for _, path in ipairs(candidates) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end

  -- Fallback to system python3
  local handle = io.popen("which python3 2>/dev/null")
  if handle then
    local result = handle:read("*a"):gsub("%s+$", "")
    handle:close()
    if result ~= "" then
      return result
    end
  end

  return nil
end

local python_path = find_python3()
if python_path then
  vim.g.python3_host_prog = python_path
end
