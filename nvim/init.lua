vim.opt.termguicolors = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.cmd 'set expandtab'
vim.cmd 'set tabstop=1'

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'DapStopped', { bg = '#242733' })
    vim.api.nvim_set_hl(0, 'NvimDapVirtualText', { fg = '#7e8294', italic = true })
    vim.api.nvim_set_hl(0, 'NvimDapVirtualTextChanged', { fg = '#4bb8b4', bold = true })
    vim.api.nvim_set_hl(0, 'NvimDapVirtualTextError', { fg = '#f7768e' })
  end,
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  pattern = 'term://*lazygit*',
  command = 'startinsert',
})

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function(args)
    -- only touch buffers that are running lazygit
    local buf_name = vim.api.nvim_buf_get_name(args.buf)
    if buf_name:match 'lazygit' then vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = args.buf }) end
  end,
})

vim.cmd 'set softtabstop=1'
vim.cmd 'set shiftwidth=1'
vim.keymap.set('i', 'jj', '<esc>', { noremap = true, silent = true })
vim.g.mapleader = ' '
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')

vim.keymap.set('n', 'j', 'jzz')
vim.keymap.set('n', 'k', 'kzz')

-- set keymap to toggele variable colors
vim.keymap.set('n', '<leader>tc', function() require('markid').toggle() end, { desc = 'toggle markid colors' })

-- For default preset
vim.keymap.set('n', '<leader>m', function() require('treesj').toggle() end)
-- For extending default preset with `recursive = true`
vim.keymap.set('n', '<leader>M', function() require('treesj').toggle { split = { recursive = true } } end)

vim.keymap.set('n', '<leader>j', '<c-w>j')
vim.keymap.set('n', '<leader>k', '<c-w>k')
vim.keymap.set('n', '<leader>h', '<c-w>h')
vim.keymap.set('n', '<leader>l', '<c-w>l')
vim.keymap.set('n', '<leader>Q', '<cmd>wqa<cr>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>s', '<cmd>w<cr>', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>c', '"+Y', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>c', '"+y', { noremap = true, silent = true })
vim.keymap.set('v', '<leader>x', '"+d', { noremap = true, silent = true })

vim.keymap.set('n', 'gp', '<cmd>telescope lsp_definitions<cr>', { desc = 'peek definition' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'prev diagnostic' })
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'show diagnostic' })

vim.keymap.set('n', '<leader>q', '<cmd>wq<cr>', { noremap = true, silent = true })
vim.keymap.set('t', '<leader>q', [[<C-\><C-n>:bd!<CR>]], { desc = 'Kill terminal buffer' })
vim.keymap.set('n', '<leader>cl', '<cmd>q<cr>', { noremap = true, silent = true })

vim.keymap.set('t', '<esc>', [[<c-\><c-n>]], { noremap = true, silent = true })
-- vim.keymap.set('t', '<s-j>', [[<c-\><c-n><c-w>j]], { noremap = true, silent = true })
-- vim.keymap.set('t', '<s-k>', [[<c-\><c-n><c-w>k]], { noremap = true, silent = true })
-- vim.keymap.set('t', '<s-h>', [[<c-\><c-n><c-w>h]], { noremap = true, silent = true })
-- vim.keymap.set('t', '<s-l>', [[<c-\><c-n><c-w>l]], { noremap = true, silent = true })

vim.keymap.set('n', '<leader>ch', ':nohl<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>jj', ':m .+1<cr>==', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>kk', ':m .-2<cr>==', { noremap = true, silent = true })

vim.keymap.set('n', '<leader>rl', '<cmd>LivePreview start<cr>', { desc = 'start live preview' })
vim.keymap.set('n', '<leader>rs', '<cmd>LivePreview stop<cr>', { desc = 'stop live preview' })

vim.keymap.set('n', '<leader>e', '$') -- end of line
vim.keymap.set('n', '<leader>b', '0') -- beginning of line

vim.keymap.set('n', '<leader>fm', function() vim.lsp.buf.format { async = false } end, { desc = 'format file' })
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<cr>', { desc = 'toggle file tree' })

vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })

vim.fn.sign_define('DapStopped', { text = '➡️', texthl = 'DapStopped', linehl = 'DapStopped', numhl = 'DapStopped' })

vim.keymap.set('n', '<leader>jr', function()
  vim.cmd 'JavaBuildBuildWorkspace'
  vim.cmd 'JavaRunnerRunMain'
  -- give the terminal buffer a moment to open, then clear its scrollback
  vim.defer_fn(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].buftype == 'terminal' then
        local sb = vim.bo[buf].scrollback
        vim.bo[buf].scrollback = 1
        vim.bo[buf].scrollback = sb
      end
    end
  end, 200) -- wait 200ms for nvim-java's terminal to open
end, { desc = 'Java: Build + Run' })

vim.opt.autowriteall = true

-- vim.api.nvim_create_autocmd('focuslost', {
--   pattern = '*',
--   command = 'silent! wa',
-- })

vim.api.nvim_create_autocmd('TermOpen', {
  callback = function(args) vim.keymap.set('n', '<leader>q', '<cmd>close<cr>', { buffer = args.buf, silent = true }) end,
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

vim.api.nvim_create_autocmd('filetype', {
  pattern = 'java',
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd('filetype', {
  pattern = 'javascript,javascriptreact,typescript,typescriptreact',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
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
    { 'b0o/schemastore.nvim' },
    { 'nvim-lua/plenary.nvim' }, -- none-ls depends on this
    { 'nvimtools/none-ls.nvim', dependencies = { 'nvimtools/none-ls-extras.nvim' } },
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
      'Wansmer/treesj',
      -- keys = { '<space>m', '<space>j', '<space>s' },
      dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
      config = function()
        require('treesj').setup { --[[ your config ]]
        }
      end,
    },
    -- nvim v0.8.0
    {
      'kdheepak/lazygit.nvim',
      lazy = true,
      cmd = {
        'LazyGit',
        'LazyGitConfig',
        'LazyGitCurrentFile',
        'LazyGitFilter',
        'LazyGitFilterCurrentFile',
      },
      -- optional for floating window border decoration
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      -- setting the keybinding for LazyGit with 'keys' is recommended in
      -- order to load the plugin when the command is run for the first time
      keys = {
        { '<leader>lg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
      },
    },
    {
      'ThePrimeagen/vim-be-good',
    },
    {
      'nvim-java/nvim-java',
      config = function()
        require('java').setup {
          log = {
            use_console = true,
            use_file = true,
            level = 'warn',
            log_file = vim.fn.stdpath 'state' .. '/nvim-java.log',
            max_lines = 1000,
            show_location = false,
          },
        }
        vim.lsp.enable 'jdtls'
      end,
    },
    {

      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').setup {
          ensure_installed = { 'python', 'lua', 'go', 'javascript', 'java' },
          auto_install = true,
        } -- no .configs, no .config

        -- enable treesitter highlighting per filetype, the new way
        vim.api.nvim_create_autocmd('FileType', {
          pattern = { 'go', 'lua', 'python', 'javascript', 'typescript', 'java' },
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
      config = function()
        require('telescope').setup {
          defaults = {
            layout_strategy = 'horizontal',
            layout_config = {
              preview_width = 0.75,
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = 'smart_case',
            },
          },
        }
        require('telescope').load_extension 'fzf'
      end,
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
        require('blink.cmp').build():pwait(5000)
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
        completion = {
          documentation = { auto_show = false },
          trigger = {
            show_on_trigger_character = true,
          },
          accept = {
            resolve_timeout_ms = 400, -- default is short; raise it so imports aren't dropped
          },
        },

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
        vim.keymap.set('n', '<C-n>', function() harpoon:list():next { ui_nav_wrap = true } end)
        vim.keymap.set('n', '<C-p>', function() harpoon:list():prev { ui_nav_wrap = true } end)
      end,
    },

    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      config = function() require('nvim-autopairs').setup() end,
    },
    {
      'mfussenegger/nvim-dap',
      dependencies = {
        -- UI panels (variables, call stack, etc.)
        { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
        -- installs delve via Mason automatically
        { 'jay-babu/mason-nvim-dap.nvim' },
        -- pre-configures dap for Go so you don't wire delve manually
        { 'leoluz/nvim-dap-go' },
        -- shows variable values inline as virtual text while debugging
        { 'theHamsta/nvim-dap-virtual-text' },

        { 'mfussenegger/nvim-dap-python' },
      },
      config = function()
        local dap = require 'dap'
        local dapui = require 'dapui'

        -- setup mason-nvim-dap: auto-install delve
        require('mason-nvim-dap').setup {
          ensure_installed = { 'delve', 'python', 'node2', 'java-debug' },
          automatic_installation = true,
          handlers = {
            delve = function() end, -- disable the generic auto-config; dap-go already provides a correct one
          }, -- required, even if empty
        }

        -- setup the UI
        dapui.setup()
        -- setup virtual text
        require('nvim-dap-virtual-text').setup {
          virt_text_pos = 'eol',

          all_references = true,
        }
        -- setup Go-specific dap config (wires delve for you)
        require('dap-go').setup()

        -- custom config: debug the whole package, with a dynamic argument prompt
        table.insert(dap.configurations.go, {
          type = 'go',
          name = 'Debug Package (Arguments)',
          request = 'launch',
          program = '${fileDirname}',
          args = function()
            local args_string = vim.fn.input 'Arguments: '
            return vim.split(args_string, ' +')
          end,
        })

        table.insert(dap.configurations.go, {
          type = 'go',
          name = 'Debug Package (Arguments + Env Vars)',
          request = 'launch',
          program = '${fileDirname}',
          args = function()
            local args_string = vim.fn.input 'Arguments: '
            return vim.split(args_string, ' +')
          end,
          env = function()
            local env_string = vim.fn.input 'Environment variables (KEY=VALUE KEY2=VALUE2): '
            local env_table = {}
            for pair in env_string:gmatch '%S+' do
              local key, value = pair:match '^(.-)=(.*)$'
              if key and value then env_table[key] = value end
            end
            return env_table
          end,
        })

        -- Python
        local function get_python_path()
          -- get the current working directory nvim was opened in
          local cwd = vim.fn.getcwd()
          local venv_python = cwd .. '/.venv/bin/python'

          -- check if that file actually exists on disk
          if vim.fn.filereadable(venv_python) == 1 then return venv_python end

          -- fall back to a system python if no .venv is found
          return '/opt/homebrew/opt/python@3.14/bin/python3.14'
        end

        require('dap-python').setup(get_python_path())

        dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
        dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

        -- keymaps
        vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'toggle breakpoint' })
        vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'continue / start' })
        vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'step over' })
        vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'step into' })
        vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'toggle dap ui' })
        vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'debug: terminate session' })
        -- Eval var under cursor
        vim.keymap.set('n', '<space>?', function() require('dapui').eval(nil, { enter = true }) end)
        vim.keymap.set(
          'n',
          '<leader>dcl',
          function() require('dap.breakpoints').clear(vim.api.nvim_get_current_buf()) end,
          nd,
          { desc = 'debug: clear breakpoints in current file' }
        )

        vim.keymap.set('n', '<leader>dt', require('dap-go').debug_test, { desc = 'debug go test' })
      end,
    },
    {
      'folke/todo-comments.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = {
        -- keywords recognized and how to display them
      },
      config = function()
        require('todo-comments').setup()

        -- keymaps
        vim.keymap.set('n', '<leader>td', '<cmd>TodoTelescope<cr>', { desc = 'todos' })
        vim.keymap.set('n', ']t', function() require('todo-comments').jump_next() end, { desc = 'next todo' })
        vim.keymap.set('n', '[t', function() require('todo-comments').jump_prev() end, { desc = 'prev todo' })
      end,
    },
    {
      'jpalardy/vim-slime',
      lazy = false,
      init = function()
        vim.g.slime_target = 'tmux'
        vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }
        vim.g.slime_dont_ask_default = 1
      end,
    },
    {
      'brianhuster/live-preview.nvim',
      cmd = { 'LivePreview' },
    },
    {
      'emmanueltouzery/apidocs.nvim',
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-telescope/telescope.nvim', -- or, 'folke/snacks.nvim'
      },
      cmd = { 'ApidocsSearch', 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSelect', 'ApidocsUninstall' },
      config = function()
        -- Picker will be auto-detected. To select a picker of your choice explicitly you can set picker by the configuration option 'picker':
        require('apidocs').setup { picker = 'telescope', follow_link_keymap = '<C-]>' }
        -- Possible options are 'ui_select', 'telescope', and 'snacks'
        -- You can change the keymap for following "local://" links by setting the configuration option 'follow_link_keymap' (default is "<C-]>"):
      end,
      keys = {
        { '<leader>sad', '<cmd>ApidocsOpen<cr>', desc = 'Search Api Doc' },
      },
    },
    -- {
    --   'MeanderingProgrammer/render-markdown.nvim',
    --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    --   -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    --   dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    --   --@module 'render-markdown'
    --   --@type render.md.UserConfig
    --   opts = {},
    -- },
  },

  -- Configure any other settings here. See the documentation for more details.
  -- RRlorscheme that will be used when installing plugins.
  install = { colorscheme = { 'habamax' } },
  -- automatically check for plugin updates
  checker = { enabled = true },
}
require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = { 'gopls', 'jdtls', 'pyright', 'jsonls', 'ts_ls' },
  automatic_installation = true,
}

require('markid').setup()
-- Tell pyright to suggest unimported symbols AND add the import when accepted
vim.lsp.config('pyright', {
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
      },
    },
  },
})
vim.lsp.enable 'pyright'

-- Tell gopls to do the same for Go
vim.lsp.config('gopls', {
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
    },
  },
})

vim.lsp.config('jsonls', {
  settings = {
    json = {
      schemas = require('schemastore').json.schemas {
        select = {
          '.eslintrc',
          'package.json',
        },
      },

      validate = { enable = true },
    },
  },
})

vim.lsp.enable 'jsonls'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'gopls'
vim.lsp.enable 'pyright'
local null_ls = require 'null-ls'

null_ls.setup {
  sources = {
    -- Formatting
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.prettier,
    require 'none-ls.formatting.ruff', -- moved from builtins
    require 'none-ls.diagnostics.ruff', -- moved from builtins

    -- Linting
    null_ls.builtins.diagnostics.golangci_lint.with {
      condition = function(utils) return utils.root_has_file 'go.mod' end,
    },
    null_ls.builtins.formatting.stylua,
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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  end,
})

vim.g.slime_target = 'tmux'
vim.g.slime_default_config = { socket_name = 'default', target_pane = '{last}' }
vim.g.slime_dont_ask_default = 1

vim.keymap.set('n', '<leader>r', function()
  vim.cmd 'write'
  local file = vim.fn.expand '%:p'
  local ft = vim.bo.filetype
  local base

  if ft == 'python' then
    base = 'python3 ' .. file
  elseif ft == 'go' then
    base = 'go run ' .. file
  else
    print('No run command set for filetype: ' .. ft)
    return
  end

  local args = vim.fn.input 'Args: '
  local cmd = base
  if args ~= '' then cmd = cmd .. ' ' .. args end

  vim.fn['slime#send'](cmd .. '\n')
end)

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
print 'INIT LOADED'
