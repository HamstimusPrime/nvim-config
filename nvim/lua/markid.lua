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
 "#ff6188", "#ff5500", "#ffd866", "#467a12", "#00636e",
 "#3c299c", "#921f4b", "#66d9ef", "#ff0606", "#a6e22e",
 "#8b4e08", "#e6db74", "#f8f8f2", "#ae81ff", "#f4468f",
 "#ff8b39", "#03ad39", "#73ff00", "#28ccd9", "#7a5ef8",
 "#c50166", "#56d9d0", "#ff9d5c", "#3a227a", "#5ca4ff",
 "#e05fff", "#fa094a", "#0a3024", "#ffb400", "#2600ff",
}



M.exclude_parents = {
  "field_identifier",        -- Go struct fields / selector expressions
  "field_declaration",       -- Go struct field decls
  "property_identifier",     -- JS/TS object properties (e.g. `obj.prop`)
}
local ns = vim.api.nvim_create_namespace("markid")
M.enabled = true
M.overrides = {}  -- [identifier text] = color index, set manually via shuffle_word
M.disabled = {}   -- [identifier text] = true, names with colors turned off
M.focus = {}      -- [identifier text] = true; when not empty, ONLY these names get colors

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

-- Some languages use a different node type for shorthand references to a
-- variable (e.g. JS/TS object shorthand `{val}` isn't type "identifier").
-- These still refer to the same name and should get the same color.
M.extra_capture_nodes = {
  "shorthand_property_identifier",          -- JS/TS: {val}
  "shorthand_property_identifier_pattern",  -- JS/TS: const {val} = obj
}

local query_cache = {}

-- Each extra node type is tested on its own against the loaded grammar,
-- so this works for any language name and any parser version.
local function build_query(lang)
  if query_cache[lang] ~= nil then return query_cache[lang] or nil end

  local parts = { "(identifier)" }
  for _, node_type in ipairs(M.extra_capture_nodes) do
    local ok = pcall(vim.treesitter.query.parse, lang, "(" .. node_type .. ") @x")
    if ok then table.insert(parts, "(" .. node_type .. ")") end
  end

  local ok, query = pcall(vim.treesitter.query.parse, lang, "[" .. table.concat(parts, "\n") .. "] @markid")
  query_cache[lang] = ok and query or false
  return ok and query or nil
end

function M.highlight(bufnr)
  bufnr = bufnr or 0
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  if not M.enabled then return end

  local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].filetype)
  if not lang then return end

  local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok_parser or not parser then return end

  local query = build_query(lang)
  if not query then return end

  local root = parser:parse()[1]:root()

  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] == "markid" then
      local parent = node:parent()
      local skip = parent and vim.tbl_contains(M.exclude_parents, parent:type())

      -- Python: `bullet.kill` is an `attribute` node with two identifier
      -- children (object + attribute name). Only skip the attribute-name
      -- side (`kill`), not the object side (`bullet`).
      if not skip and parent and parent:type() == "attribute" then
        local attr_field = parent:field("attribute")
        if attr_field and attr_field[1] == node then
          skip = true
        end
      end

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

      local text = not skip and vim.treesitter.get_node_text(node, bufnr)
      local focus_ok = next(M.focus) == nil or M.focus[text]
      if text and focus_ok and not M.disabled[text] then
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

-- Turn the color on or off for one identifier name only.
function M.toggle_word(word)
  if not word or word == "" then return end
  M.disabled[word] = not M.disabled[word] or nil
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
  vim.notify("markid: '" .. word .. "' " .. (M.disabled[word] and "off" or "on"))
end

function M.toggle_word_under_cursor()
  M.toggle_word(vim.fn.expand("<cword>"))
end

local function refresh_all()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      M.highlight(bufnr)
    end
  end
end

-- Focus mode: add or remove one name from the focus list.
-- While the list has at least one name, only those names are colored.
function M.focus_word(word)
  if not word or word == "" then return end
  M.focus[word] = not M.focus[word] or nil
  refresh_all()
  vim.notify("markid focus: " .. (next(M.focus) and table.concat(vim.tbl_keys(M.focus), ", ") or "off (all names colored)"))
end

function M.focus_word_under_cursor()
  M.focus_word(vim.fn.expand("<cword>"))
end

function M.clear_focus()
  M.focus = {}
  refresh_all()
  vim.notify("markid focus: off (all names colored)")
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
