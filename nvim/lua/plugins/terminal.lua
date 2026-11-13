-- Open the <C-/> terminal as a floating window instead of a bottom split
return {
  "folke/snacks.nvim",
  opts = {
    terminal = {
      win = { position = "float", border = "rounded" },
    },
  },
}
