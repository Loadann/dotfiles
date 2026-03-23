return {
  {
    "nvim-lua/plenary.nvim", -- ensure it's early
    init = function()
      if vim.fn.has("wsl") == 1 then
        vim.g.clipboard = {
          name = "win32yank",
          copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
          paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
          cache_enabled = 0,
        }
      end
    end,
  },
}
