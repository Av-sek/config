-- Django templates. LazyVim's python extra covers .py files; this adds the {% %} / {{ }} templates.
-- Neovim already detects them: an .html file containing Django tags gets filetype "htmldjango".
return {
  { -- syntax highlighting for templates
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "htmldjango" } },
  },
  { -- djlint formats templates (<leader>cf, or on save like everything else)
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "djlint" } },
  },
  {
    "stevearc/conform.nvim",
    opts = { formatters_by_ft = { htmldjango = { "djlint" } } },
  },
}
