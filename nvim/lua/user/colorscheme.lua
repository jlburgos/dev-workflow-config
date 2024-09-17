-- This sin't working for some reason
-- local colorscheme = "tokyonight"
--vim.g.tokyonight_style = "night"

-- Doing this instead!
--local colorscheme = "tokyonight-night"
local colorscheme = "evening"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]

