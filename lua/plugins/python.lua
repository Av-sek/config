-- Make pyright use the project's virtualenv, like VS Code does.
-- Envs live in virtualenvwrapper's $WORKON_HOME (~/Envs), named after the project, e.g.
--   ~/Github/evaire            -> ~/Envs/evaire
--   ~/Github/matrix/ECLAT.Matrix -> ~/Envs/matrix   (part after the last dot, lowercased)
local workon = vim.env.WORKON_HOME or vim.fn.expand("~/.virtualenvs")

--- The python to use for a project root, first match wins:
--- an activated env ($VIRTUAL_ENV) > $WORKON_HOME/<name matching the project> > .venv/venv/env inside the project.
--- ~/Envs comes before .venv because that's where your envs live; a leftover .venv can be stale
--- (post-processing's was missing pypdf). Override per project with <leader>cv.
local function project_python(root)
  if vim.env.VIRTUAL_ENV then return vim.env.VIRTUAL_ENV .. "/bin/python" end
  local name = vim.fs.basename(root)
  for _, guess in ipairs({ name, name:lower(), (name:match("[^.]+$") or name):lower() }) do
    local py = workon .. "/" .. guess .. "/bin/python"
    if vim.uv.fs_stat(py) then return py end
  end
  for _, dir in ipairs({ ".venv", "venv", "env" }) do
    local py = root .. "/" .. dir .. "/bin/python"
    if vim.uv.fs_stat(py) then return py end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
          -- Like VS Code (Pylance) by default: report missing imports, undefined names and syntax errors,
          -- but not type mismatches. Switch to "basic" or "standard" when you want type checking.
          -- A project's own [tool.pyright] in pyproject.toml still wins.
          settings = { python = { analysis = { typeCheckingMode = "off" } } },
          -- Project root = the git repo (like opening the folder in VS Code), so a nested pyproject.toml
          -- (e.g. src/llm/postprocess/) doesn't shrink the project. An explicit pyrightconfig.json wins.
          root_markers = { "pyrightconfig.json", ".git", { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" } },
          on_init = function(client)
            local py = project_python(client.root_dir or vim.fn.getcwd())
            if not py then return end
            client.settings = vim.tbl_deep_extend("force", client.settings or {}, { python = { pythonPath = py } })
            client:notify("workspace/didChangeConfiguration", { settings = client.settings })
          end,
        },
      },
    },
  },
  { -- <leader>cv also lists every env in $WORKON_HOME; your pick is remembered per project
    "linux-cultist/venv-selector.nvim",
    opts = {
      search = {
        workon_home = { command = "$FD '/bin/python$' " .. workon .. " --no-ignore-vcs --full-path --color never" },
      },
    },
  },
}
