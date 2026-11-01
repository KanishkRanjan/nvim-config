-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Ctrl-/ : when editing a remote file (scp://host/...), open a shell on that
-- host in the file's folder. Otherwise, open LazyVim's normal local terminal.
local function remote_ssh_cmd()
  local name = vim.api.nvim_buf_get_name(0)
  local host, path = name:match("^scp://([^/]+)/(.*)$")
  if not host then
    return nil
  end
  local dir
  if path == "" or path:sub(-1) == "/" then
    dir = path -- a folder (netrw listing)
  else
    dir = vim.fn.fnamemodify(path, ":h") -- folder of the file
  end
  if dir == "" then
    dir = "."
  end
  -- relative paths start in the remote home dir; "/..." is absolute
  return { "ssh", "-t", host, "cd " .. vim.fn.shellescape(dir) .. " && exec $SHELL -l" }
end

local function smart_terminal()
  local cmd = remote_ssh_cmd()
  if cmd then
    Snacks.terminal(cmd, { win = { position = "bottom" } })
  else
    Snacks.terminal(nil, { cwd = LazyVim.root() })
  end
end

vim.keymap.set("n", "<c-/>", smart_terminal, { desc = "Terminal (remote host if scp:// buffer)" })
vim.keymap.set("n", "<c-_>", smart_terminal, { desc = "which_key_ignore" })

-- Esc Esc leaves terminal typing mode (in case Ctrl-\ Ctrl-n is awkward)
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Exit terminal mode" })
