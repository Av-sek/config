-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Drag & drop files onto the explorer (<leader>e) to copy them into the folder under the cursor, like VS Code.
-- Terminals deliver a drop as pasted path text, so this hooks paste; pasting anywhere else is unchanged.
local function dropped_paths(text)
  local paths, i = {}, 1
  while i <= #text do
    local c = text:sub(i, i)
    if c:match("%s") then
      i = i + 1
    else
      local q = (c == '"' or c == "'") and c or nil
      local j = q and (text:find(q, i + 1, true) or #text + 1) or (text:find("%s", i) or #text + 1)
      local p = text:sub(q and i + 1 or i, j - 1)
      if p:match("^%a:[\\/]") or p:match("^\\\\") then -- Windows path (C:\..., \\wsl.localhost\...)
        p = vim.trim(vim.fn.system({ "wslpath", "-u", p }))
      elseif p:find("\\", 1, true) and not vim.uv.fs_stat(p) then -- half-converted: /mnt/c/Users/me\Downloads\x.py
        p = p:gsub("\\", "/")
      end
      paths[#paths + 1] = p
      i = j + 1
    end
  end
  return paths
end

local paste, chunks = vim.paste, {}
vim.paste = function(lines, phase)
  if vim.bo.filetype ~= "snacks_picker_list" then
    return paste(lines, phase)
  end
  if phase == -1 or phase == 1 then
    chunks = {}
  end
  -- a streamed paste splits anywhere: each chunk's first line continues the previous chunk's last line
  if #chunks > 0 then
    chunks[#chunks] = chunks[#chunks] .. table.remove(lines, 1)
  end
  vim.list_extend(chunks, lines)
  if phase ~= -1 and phase ~= 3 then
    return true
  end
  local picker = Snacks.picker.get({ source = "explorer" })[1]
  local paths = dropped_paths(table.concat(chunks, " "))
  local missing = vim.tbl_filter(function(p) return not vim.uv.fs_stat(p) end, paths)
  if not picker or #paths == 0 or #missing > 0 then
    Snacks.notify.warn("Drop: not a file:\n" .. table.concat(#missing > 0 and missing or chunks, "\n"))
    return true
  end
  local dir = picker:dir()
  Snacks.picker.util.copy(paths, dir)
  local Tree = require("snacks.explorer.tree")
  Tree:refresh(dir)
  Tree:open(dir)
  require("snacks.explorer.actions").update(picker, { target = dir })
  Snacks.notify(("Copied %d item(s) to %s"):format(#paths, vim.fn.fnamemodify(dir, ":~:.")))
  return true
end
