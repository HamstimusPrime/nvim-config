local M = {}

M.colors = {
  "#ff6188", "#fc9867", "#ffd866", "#a9dc76", "#78dce8",
  "#ab9df2", "#ff9ac1", "#66d9ef", "#f92672", "#a6e22e",
  "#fd971f", "#e6db74", "#f8f8f2", "#ae81ff", "#f4468f",
  "#ff8b39", "#fff275", "#8bd450", "#28ccd9", "#7a5ef8",
  "#ff5db1", "#56d9d0", "#ff9d5c", "#c4f042", "#5ca4ff",
  "#e05fff", "#ff7096", "#39d1a4", "#ffb400", "#9d8cff",
}

local bit = require("bit")
local ns = vim.api.nvim_create_namespace("markid")
M.enabled = true

-- FNV-1a hash: mixes bits multiplicatively, spreads names across
-- the color list much more evenly than a simple byte sum would.
-- Neovim runs on LuaJIT (Lua 5.1 syntax), which has no native
-- bitwise operators, so we use LuaJIT's `bit` library instead.
local function hash(str)
  local h = 2166136261
  for i = 1, #str do
    h = bit.bxor(h, str:byte(i))
    h = bit.band(h * 16777619, 0xFFFFFFFF)
  end
  return h
end

function M.highlight(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if not M.enabled then return end

  local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not lang then return end

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_parser or not parser then return end

  local ok_query, query = pcall(vim.treesitter.query.parse, lang, "(identifier) @markid")
  if not ok_query then return end

  local root = parser:parse()[1]:root()

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] == "markid" then
      local text = vim.treesitter.get_node_text(node, bufnr)
      local idx = (hash(text) % #M.colors) + 1
      local group = "Markid" .. idx
      vim.api.nvim_set_hl(0, group, { fg = M.colors[idx] })

      local srow, scol, erow, ecol = node:range()
      vim.api.nvim_buf_set_extmark(bufnr, ns, srow, scol, {
        end_row = erow, end_col = ecol,
        hl_group = group, priority = 200,
      })
    end
  end
end

function M.toggle()
  M.enabled = not M.enabled
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
  vim.notify("markid: " .. (M.enabled and "on" or "off"))
end

function M.setup(opts)
  opts = opts or {}
  M.colors = opts.colors or M.colors
  vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave", "BufWritePost" }, {
    callback = function(args) M.highlight(args.buf) end,
  })
end

return M
