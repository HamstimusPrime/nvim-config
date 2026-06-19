vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.cmd 'set expandtab'
vim.cmd 'set tabstop=1'

vim.cmd 'set softtabstop=1'
vim.cmd 'set shiftwidth=1'
vim.keymap.set('i', 'jj', '<esc>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>j', '<c-w>j')
vim.keymap.set('n', '<leader>k', '<c-w>k')
vim.keymap.set('n', '<leader>h', '<c-w>h')
vim.keymap.set('n', '<leader>l', '<c-w>l')


vim.keymap.set('n', '<leader>s', '<cmd>w<cr>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>c', '"+Y', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>c', '"+y', { noremap = true, silent = true })


vim.keymap.set('n', 'gp', '<cmd>telescope lsp_definitions<cr>', { desc = 'peek definition' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'prev diagnostic' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'show diagnostic' })

vim.keymap.set('n', '<leader>q', '<cmd>wqa<cr>', { noremap = true, silent = true })

vim.keymap.set('t', '<esc>', [[<c-\><c-n>]], { noremap = true, silent = true })
vim.keymap.set('t', '<s-j>', [[<c-\><c-n><c-w>j]], { noremap = true, silent = true })
vim.keymap.set('t', '<s-k>', [[<c-\><c-n><c-w>k]], { noremap = true, silent = true })
vim.keymap.set('t', '<s-h>', [[<c-\><c-n><c-w>h]], { noremap = true, silent = true })
vim.keymap.set('t', '<s-l>', [[<c-\><c-n><c-w>l]], { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ch', ':nohl<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>jj', ':m .+1<cr>==', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>kk', ':m .-2<cr>==', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>e', '$') -- end of line
vim.keymap.set('n', '<leader>b', '0') -- beginning of line

vim.keymap.set('n', '<leader>fm', function() vim.lsp.buf.format { async = false } end, { desc = 'format file' })
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<cr>', { desc = 'toggle file tree' })

vim.opt.autowriteall = true

vim.api.nvim_create_autocmd('focuslost', {
  pattern = '*',
  command = 'silent! wa',
})

vim.api.nvim_create_autocmd('bufleave', {
  pattern = '*',
  command = 'silent! wa',
})

vim.opt.updatetime = 300
vim.api.nvim_create_autocmd('textchanged', {
  pattern = '*',
  command = 'silent! write',
})

vim.keymap.set('n', '<leader>t', function()
  vim.cmd 'belowright split'
  vim.cmd 'terminal'
end)

vim.api.nvim_create_autocmd('filetype', {
  pattern = 'go',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'failed to clone lazy.nvim:\n', 'errormsg' },
      { out, 'warningmsg' },
      { '\npress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- this is also a good place to setup other settings (vim.opt)
vim.g.maplocalleader = '\\'

vim.diagnostic.config {
  underline = true,
  virtual_text = false, -- shows error message inline at end of line
  signs = true,
  update_in_insert = false,
}

-- setup lazy.nvim
require('lazy').setup {
  spec = {
    -- add your plugins here

    { 'nvim-lua/plenary.nvim' }, -- none-ls depends on this
    { 'nvimtools/none-ls.nvim' },
    {
      'folke/tokyonight.nvim',
      lazy = false,
      priority = 1,
      opts = {},

      -- config = function() vim.cmd [[colorscheme tokyonight-night]] end,
    },
    -- {
    --   'ayu-theme/ayu-vim',
    --   lazy = false,
    --   priority = 1000,
    --   config = function()
    --     vim.g.ayucolor = 'mirage' -- 'light', 'mirage', or 'dark'
    --     vim.cmd 'colorscheme ayu'
    --     vim.api.nvim_set_hl(0, 'normal', { bg = '#11141b' })
    --
    --     vim.api.nvim_set_hl(0, 'matchparen', {
    --       fg = '#ff8c00', -- bright orange text
    --       bg = '#f27ebc', -- dark orange background behind it
    --       bold = true,
    --     })
    --   end,
    -- },
    {
      'Shatur/neovim-ayu',
      lazy = false,
      priority = 1000,
      config = function()
        require('ayu').setup {
          mirage = false, -- false = dark, true = mirage (softer dark)
        }
        vim.cmd 'colorscheme ayu-mirage'
        vim.api.nvim_set_hl(0, 'LineNr', { fg = '#424756' })
        vim.api.nvim_set_hl(0, 'Normal', { bg = '#11141b' })
        vim.api.nvim_set_hl(0, 'matchparen', {
          fg = '#ffffff', -- bright orange text
          bg = '#285f62', -- dark orange background behind it
          bold = true,
        })
      end,
    },
    {
      'ThePrimeagen/vim-be-good',
    },
    {
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').setup {} -- no .configs, no .config

        -- enable treesitter highlighting per filetype, the new way
        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'go', 'lua', 'python', 'javascript' },
          callback = function() vim.treesitter.start() end,
        })
      end,
    },
    -- add this to your lua/plugins.lua, lua/plugins/init.lua,  or the file you keep your other plugins:
    {
      'numToStr/Comment.nvim',
      opts = {
        -- add any options here
      },
      config = function() require('Comment').setup() end,
    },
    -- Mason: installs language servers
    { 'williamboman/mason.nvim' },

    -- Bridge between Mason and lspconfig (auto-connects installed servers)
    { 'williamboman/mason-lspconfig.nvim' },

    -- lspconfig: tells Neovim how to talk to each server
    { 'neovim/nvim-lspconfig' },

    {
      'nvim-telescope/telescope.nvim',
      version = '*',
      dependencies = {
        'nvim-lua/plenary.nvim',
        -- optional but recommended
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
    },
    {
      'nvim-tree/nvim-tree.lua',
      version = '*',
      lazy = false,
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require('nvim-tree').setup {
          hijack_netrw = true,
          filters = {
            dotfiles = false,
            custom = {}, -- empty means no custom patterns are hidden
            exclude = {},
            git_ignored = false,
          },
          renderer = {
            highlight_diagnostics = 'name',
          },
          diagnostics = {
            enable = true,
            show_on_dirs = true,
          },
          filesystem_watchers = {
            enable = true,
          },
        }
      end,
    },
    {
      'lukas-reineke/indent-blankline.nvim',
      main = 'ibl',
      ---@module "ibl"
      --@type ibl.config
      opts = {},
    },
    {
      'saghen/blink.cmp',
      dependencies = {
        'saghen/blink.lib',
        -- optional: provides snippets for the snippet source
        'rafamadriz/friendly-snippets',
      },
      build = function()
        -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
        -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
        require('blink.cmp').build():pwait()
      end,

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = { preset = 'super-tab' },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },

        -- (Default) list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"`
        -- See the fuzzy documentation for more information
        fuzzy = { implementation = 'rust' },
        signature = { enabled = true },
      },
    },
    {
      'iamcco/markdown-preview.nvim',
      cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
      ft = { 'markdown' },
      init = function() vim.g.mkdp_theme = 'light' end,
      build = function() vim.fn['mkdp#util#install']() end,
    },
    {
      'shrynx/line-numbers.nvim',
      opts = {},
    },
    {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('lualine').setup {
          options = {
            theme = 'gruvbox',
          },
          sections = {
            lualine_a = { 'mode' },
            lualine_b = { 'branch' },
            lualine_c = { 'filename' },
            lualine_x = { 'filetype' },
            lualine_y = { 'progress' },
            lualine_z = { 'location' },
          },
        }
      end,
    },
    {
      'christoomey/vim-tmux-navigator',
      cmd = {
        'TmuxNavigateLeft',
        'TmuxNavigateDown',
        'TmuxNavigateUp',
        'TmuxNavigateRight',
        'TmuxNavigatePrevious',
        'TmuxNavigatorProcessList',
      },
      keys = {
        { '<c-h>', '<cmd>silent! wa<CR><cmd>TmuxNavigateLeft<cr>' },
        { '<c-j>', '<cmd>silent! wa<CR><cmd>TmuxNavigateDown<cr>' },
        { '<c-k>', '<cmd>silent! wa<CR><cmd>TmuxNavigateUp<cr>' },
        { '<c-l>', '<cmd>silent! wa<CR><cmd>TmuxNavigateRight<cr>' },
        { '<c-\\>', '<cmd>TmuxNavigatePrevious<cr>' },
      },
    },

    {
      'ThePrimeagen/harpoon',
      branch = 'harpoon2',
      dependencies = { 'nvim-lua/plenary.nvim' },
      config = function()
        local harpoon = require 'harpoon'
        harpoon:setup()
        vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end)
        vim.keymap.set('n', '<S-e>', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        -- jump to file 1, 2, 3, 4
        vim.keymap.set('n', '<leader>1', function() harpoon:list():select(1) end)
        vim.keymap.set('n', '<leader>2', function() harpoon:list():select(2) end)
        vim.keymap.set('n', '<leader>3', function() harpoon:list():select(3) end)
        vim.keymap.set('n', '<leader>4', function() harpoon:list():select(4) end)
        vim.keymap.set('n', '<S-n>', function() harpoon:list():next { ui_nav_wrap = true } end)
        vim.keymap.set('n', '<S-p>', function() harpoon:list():prev { ui_nav_wrap = true } end)
      end,
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = function() require('nvim-autopairs').setup() end,
    },
  },

  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { 'habamax' } },
  -- automatically check for plugin updates
  checker = { enabled = true },
}
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { 'gopls' },
  automatic_installation = true,
}
local null_ls = require 'null-ls'

null_ls.setup {
  sources = {
    -- Formatting
    null_ls.builtins.formatting.gofmt, -- formats Go code (standard)
    null_ls.builtins.formatting.goimports, -- formats + organises imports

    -- Linting
    -- null_ls.builtins.diagnostics.golangci_lint, -- runs golangci-lint
    null_ls.builtins.diagnostics.golangci_lint.with {
      condition = function(utils) return utils.root_has_file 'go.mod' end,
    },

    null_ls.builtins.formatting.stylua, -- runs golangci-lint
    null_ls.builtins.diagnostics.staticcheck.with {
      condition = function(utils) return utils.root_has_file 'go.mod' end,
    },
  },
}

-- Format on save for Go files
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function() vim.lsp.buf.format { async = false } end,
})

-- New native Neovim 0.11 way
local capabilities = require('blink.cmp').get_lsp_capabilities()
vim.lsp.config('gopls', { capabilities = capabilities })
vim.lsp.enable 'gopls'

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  end,
})

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
print 'INIT LOADED'
