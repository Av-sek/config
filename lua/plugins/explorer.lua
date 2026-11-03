-- File explorer (<leader>e) and search (<leader><space> files, <leader>/ text) tweaks.

-- Searches include hidden and git-ignored files (.omc, .claude, .env…) but skip bulky folders you never
-- want results from. Add to this list if a project has another one.
local skip = { ".git", "node_modules", ".venv", "venv", "__pycache__", ".mypy_cache", ".ruff_cache", ".pytest_cache", "dist", "build" }

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          hidden = true, -- show dotfiles/dot-folders (.env, .github, .vscode…); H toggles
          ignored = true, -- and git-ignored ones (.omc, .venv…), like VS Code; I toggles
          win = {
            list = {
              keys = {
                -- Default <BS> moves the tree's root above your project. Collapse the folder instead (like h).
                ["<BS>"] = "explorer_close",
              },
            },
          },
        },
        files = { hidden = true, ignored = true, exclude = skip },
        grep = { hidden = true, ignored = true, exclude = skip },
      },
    },
  },
}
