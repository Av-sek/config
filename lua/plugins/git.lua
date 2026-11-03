-- Show git blame (author, date, message) at the end of the cursor line, always on
return {
  "lewis6991/gitsigns.nvim",
  opts = {
    current_line_blame = true,
    current_line_blame_opts = { delay = 300 },
  },
}
