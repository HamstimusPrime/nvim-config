local M = {}


M.colors = {
  "#fb3bcb", "#fc9867", "#ffd866", "#a9dc76", "#78dce8",
  "#ab9df2", "#f6025f", "#66d9ef", "#fd03d3", "#a6e22e",
  "#fd971f", "#e6db74", "#f8f8f2", "#ae81ff", "#c45a86",
  "#ff8b39", "#fff275", "#8bd450", "#28ccd9", "#7a5ef8",
  "#ff5db1", "#56d9d0", "#ff9d5c", "#c4f042", "#5ca4ff",
  "#7cff5f", "#70e7ff", "#ccd139", "#3956fb", "#16cb28",
  "#c00000", "#8b0098", "#d139b5", "#7a715d", "#6a5fa4",
  "#fa9b36", "#635256", "#16604a", "#4fa313", "#8ed4c9",
  "#f5c0c0", "#f5d3c0", "#f5eac0", "#dff5c0", "#c0f5c8",
  "#c0f5f1", "#c0dbf5", "#ccc0f5", "#f2c0f5", "#98fc03",
  "#ff6188", "#fc9867", "#ffd866", "#a9dc76", "#78dce8",
  "#ab9df2", "#ff9ac1", "#66d9ef", "#f92672", "#a6e22e",
}




M.exclude_parents = {
  "field_identifier",        -- Go struct fields / selector expressions
  "field_declaration",       -- Go struct field decls
  "property_identifier",     -- JS/TS object properties
  "shorthand_property_identifier",
  "shorthand_property_identifier_pattern",
  "attribute",                -- Python class attributes (approximate)
}
local ns = vim.api.nvim_create_namespace("markid")
M.enabled = true
M.overrides = {}  -- [identifier text] = color index, set manually via shuffle_word

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
      local parent = node:parent()
      local skip = parent and vim.tbl_contains(M.exclude_parents, parent:type())

      -- Go: `Foo{Name: "x"}` parses Name as a plain `identifier` wrapped
      -- in `literal_element`, inside `keyed_element`'s "key" field.
      -- This is a struct field name, not a variable reference, so skip it.
      if not skip and parent and parent:type() == "literal_element" then
        local keyed = parent:parent()
        if keyed and keyed:type() == "keyed_element" then
          local key_nodes = keyed:field("key")
          if key_nodes and key_nodes[1] == parent then
            skip = true
          end
        end
      end

      if not skip then
        local text = vim.treesitter.get_node_text(node, bufnr)
        local idx = M.overrides[text] or ((hash(text) % #M.colors) + 1)
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

function M.shuffle()
  for i = #M.colors, 2, -1 do
    local j = math.random(i)
    M.colors[i], M.colors[j] = M.colors[j], M.colors[i]
  end
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
  vim.notify("markid: colors shuffled")
end

-- Reassign a random color to one specific identifier name, independent
-- of the hash-based color every other name still uses.
function M.shuffle_word(word)
  if not word or word == "" then return end
  local current = M.overrides[word] or ((hash(word) % #M.colors) + 1)
  local idx = current
  if #M.colors > 1 then
    while idx == current do
      idx = math.random(#M.colors)
    end
  end
  M.overrides[word] = idx
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
  vim.notify("markid: shuffled color for '" .. word .. "'")
end

function M.shuffle_word_under_cursor()
  M.shuffle_word(vim.fn.expand("<cword>"))
end

-- Remove a name's manual override, letting it fall back to its hash color.
function M.reset_word(word)
  M.overrides[word] = nil
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
end

function M.reset_word_under_cursor()
  M.reset_word(vim.fn.expand("<cword>"))
end

function M.setup(opts)
  opts = opts or {}
  M.colors = opts.colors or M.colors
  M.exclude_parents = opts.exclude_parents or M.exclude_parents
  vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "InsertLeave", "BufWritePost" }, {
    callback = function(args) M.highlight(args.buf) end,
  })
end

return M

