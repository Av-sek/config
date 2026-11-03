-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Habit builder: arrow keys in Normal mode remind you of the Neovim way instead of moving.
-- Delete this block once hjkl, w/b, f/t and / are second nature.
for key, hint in pairs({
  ["<Up>"] = "k (or 5k, <C-u>, {)",
  ["<Down>"] = "j (or 5j, <C-d>, })",
  ["<Left>"] = "h (or b, F{char}, 0)",
  ["<Right>"] = "l (or w, f{char}, $)",
}) do
  vim.keymap.set("n", key, function() vim.notify("Use " .. hint, vim.log.levels.WARN) end, { desc = "Habit: use " .. hint })
end
