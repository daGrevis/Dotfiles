-- Part of https://dagrev.is/Dotfiles

-- Based on kickstart.nvim as of 5bdde24

-- If you experience any errors, start with running `:checkhealth`.

local function close_all_floating_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative == 'win' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

-- Vim has this abstract button called Leader. Sets Leader to Space.
-- This means that <leader>w mapping can be invoked by pressing <Space>w.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Show absolute line number or current line, but relative number everywhere else.
-- This makes it easy to jump to a specific line by doing something like 10j or 17k.
vim.opt.number = true
vim.opt.relativenumber = true

-- Default to 2 spaces for indentation.
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Enables mouse mode support.
-- Sometimes useful for scrolling, resizing splits and selecting something.
vim.opt.mouse = 'a'

-- The right mouse button should extend the selection, NOT open up select dialog.
vim.opt.mousemodel = 'extend'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Don't show startup message.
vim.opt.shortmess:append 'I'

-- Don't show ins-completion-menu messages.
vim.opt.shortmess:append 'c'

-- Do create undo files.
vim.opt.undofile = true

-- Do NOT create swap files.
vim.opt.swapfile = false

-- Ignore case when all characters are in lower case.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Match globally (avoid /g in s/foo/bar/g).
vim.opt.gdefault = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets replacements for certain characters like tabs and trailing spaces.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Adds - to the list of keyword characters. Used for w and * mapping among other things.
vim.opt.iskeyword:append '-'

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on.
-- Helps finding the cursor.
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- Keeps cursor at the center region of screen.
vim.opt.scrolloff = 25

vim.keymap.set('n', '<C-c>', function()
  close_all_floating_windows()
end)

vim.keymap.set('n', '<C-l>', function()
  vim.cmd 'nohlsearch'
  close_all_floating_windows()
end)

vim.keymap.set('n', '<leader>d', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Go to prev/next diagnostic.
vim.keymap.set('n', '[l', function()
  vim.diagnostic.goto_prev()
end)
vim.keymap.set('n', ']l', function()
  vim.diagnostic.goto_next()
end)
-- Go to prev/next error.
vim.keymap.set('n', '[L', function()
  vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR }
end)
vim.keymap.set('n', ']L', function()
  vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR }
end)

-- Move to start of line with H.
vim.keymap.set({ 'n', 'v' }, 'H', '^')
-- Move to end of line with L.
vim.keymap.set({ 'n', 'v' }, 'L', '$')

-- Just like regular * and #, but doesn't move.
-- TODO: Add this to visual mode.
vim.keymap.set('n', '*', 'g*N')
vim.keymap.set('n', '#', 'g#N')

-- Just like regular ~, but doesn't move.
vim.keymap.set('n', '~', function()
  vim.api.nvim_feedkeys('~', 'n', true)
  -- Move one character left if we are not on the last character of current line.
  if #vim.api.nvim_get_current_line() ~= vim.fn.virtcol '.' then
    vim.api.nvim_feedkeys('h', 'n', true)
  end
end)

-- Indent visually selected text without leaving selection.
vim.keymap.set('v', '>', '>gv')
vim.keymap.set('v', '<', '<gv')

-- Character-wise marks.
vim.keymap.set('n', "'", '`')

-- Run macro called q.
vim.keymap.set('n', 'Q', '@q')

-- Yank X, delete Y, paste X with ""p.
-- http://stackoverflow.com/a/1504373
vim.keymap.set('n', '""', '"0')

-- Join lines with <Leader>j.
vim.keymap.set({ 'n', 'v' }, '<leader>j', ':join<cr>')

-- Treat a wrapped-line like many lines when navigating with j and k.
vim.keymap.set('n', 'j', function()
  return vim.v.count > 0 and 'j' or 'gj'
end, { expr = true })
vim.keymap.set('n', 'k', function()
  return vim.v.count > 0 and 'k' or 'gk'
end, { expr = true })

-- Switch to adjacent tab with J or K.
vim.keymap.set('n', 'J', 'gt')
vim.keymap.set('n', 'K', 'gT')

-- Switch to specific tab with leader + N.
vim.keymap.set('n', '<leader>1', ':tabnext 1<CR>')
vim.keymap.set('n', '<leader>2', ':tabnext 2<CR>')
vim.keymap.set('n', '<leader>3', ':tabnext 3<CR>')
vim.keymap.set('n', '<leader>4', ':tabnext 4<CR>')
vim.keymap.set('n', '<leader>5', ':tabnext 5<CR>')
vim.keymap.set('n', '<leader>6', ':tabnext 6<CR>')
vim.keymap.set('n', '<leader>7', ':tabnext 7<CR>')
vim.keymap.set('n', '<leader>8', ':tabnext 8<CR>')
vim.keymap.set('n', '<leader>9', ':tabnext 9<CR>')
vim.keymap.set('n', '<leader>0', ':tabnext 10<CR>')

-- Switch to previous tab with double leader.
vim.g.previous_tab = 1
vim.api.nvim_set_keymap('n', '<leader><leader>', ':lua vim.cmd("tabn " .. vim.g.previous_tab)<CR>', {})
vim.api.nvim_create_autocmd('TabLeave', {
  callback = function()
    vim.g.previous_tab = vim.fn.tabpagenr()
  end,
})

-- Create directory of current file if it doesn't exist.
vim.api.nvim_create_autocmd('BufNewFile', {
  pattern = '*',
  callback = function()
    local bufname = vim.fn.bufname '%'
    local dir = vim.fn.fnamemodify(bufname, ':p:h')
    vim.fn.mkdir(dir, 'p')
  end,
})

-- Save and close buffer.
vim.keymap.set('n', '<leader>q', 'ZZ')

-- Save buffer.
vim.keymap.set('n', '<leader>w', ':w<CR>')

-- Prefill command to edit buffer.
vim.keymap.set('n', '<leader>e', ':e ')

-- Reload buffer.
vim.keymap.set('n', '<leader>ee', ':e!<CR>')

-- Prefill command to edit buffer from current directory.
vim.keymap.set('n', '<leader>r', function()
  local dir = vim.fn.expand '%:h'
  vim.api.nvim_feedkeys(':e ' .. dir .. '/', 'n', true)
end)

-- Prefill command to open a new tab.
vim.keymap.set('n', '<leader>t', ':tabe ')

-- Prefill command to open a new tab from current directory.
vim.keymap.set('n', '<leader>y', function()
  local dir = vim.fn.expand '%:h'
  vim.api.nvim_feedkeys(':tabe ' .. dir .. '/', 'n', true)
end)

-- Select line without newline at the end.
vim.keymap.set('n', '<leader>c', '^v$h')

-- Select buffer without newline at end.
vim.keymap.set('n', '<leader>v', 'ggVG')

-- Open buffer in a new tab.
vim.keymap.set('n', '<leader>o', '<C-W>T')

-- Open help.
vim.keymap.set('n', '<leader>h', ':help ')

-- Copy to system clipboard with <C-c>.
vim.keymap.set('v', '<C-c>', '"*ygv"+y')

-- Paste from system clipboard with <C-v>.
vim.keymap.set('i', '<C-v>', '<Esc>"+pi')
vim.keymap.set('c', '<C-v>', '<C-r>+')

-- Common typos.
vim.cmd 'command! Q q'
vim.cmd 'command! Wqa wqa'
vim.cmd 'command! Wq wq'
vim.cmd 'command! Qa qa'

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-save buffer.
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'VimLeavePre' }, {
  callback = function(event)
    if event.file == '' then
      return
    end

    local buf = event.buf
    if vim.api.nvim_get_option_value('modified', { buf = buf }) then
      vim.schedule(function()
        vim.api.nvim_buf_call(buf, function()
          vim.cmd 'silent! write'
        end)
      end)
    end
  end,
})

-- Tabline on top.

-- Always show the tabline.
vim.opt.showtabline = 2

-- Generate unique labels for paths by shortening them.
local function generate_unique_tabline_labels(paths, segments)
  segments = segments or 1

  local seen = {} -- [path] = true
  local unique_paths = {} -- Deduplicated list.
  local path_to_indices = {} -- [path] = { original_index1, original_index2, ... }

  for i, path in ipairs(paths) do
    if not seen[path] then
      seen[path] = true
      table.insert(unique_paths, path)
      path_to_indices[path] = { i }
    else
      table.insert(path_to_indices[path], i)
    end
  end

  local groups = {} -- [subpath] = { index1, index2, ... }

  for i, path in ipairs(unique_paths) do
    -- Split path by '/'.
    local parts = {}
    for part in string.gmatch(path, '([^/]+)') do
      table.insert(parts, part)
    end

    -- Take the last 'segments' parts of the path safely.
    local sub = #parts >= segments and table.concat({ unpack(parts, #parts - segments + 1) }, '/') or path

    -- Group by suffix.
    groups[sub] = groups[sub] or {}
    table.insert(groups[sub], i)
  end

  local unique_labels = {}

  for sub, indices in pairs(groups) do
    if #indices == 1 then
      unique_labels[indices[1]] = sub
    else
      -- If multiple paths share the same suffix, we recurse.
      local conflicting_paths = {}
      for _, i in ipairs(indices) do
        conflicting_paths[#conflicting_paths + 1] = unique_paths[i]
      end
      local resolved = generate_unique_tabline_labels(conflicting_paths, segments + 1)
      for j, i in ipairs(indices) do
        unique_labels[i] = resolved[j]
      end
    end
  end

  for i, label in ipairs(unique_labels) do
    -- Check to append "/" only when needed.
    if '/' .. label == unique_paths[i] then
      unique_labels[i] = '/' .. label
    end
  end

  -- Map back to original paths.
  local final_labels = {} -- Indexed like `paths`.
  for i, path in ipairs(unique_paths) do
    for _, original_index in ipairs(path_to_indices[path]) do
      final_labels[original_index] = unique_labels[i]
    end
  end

  return final_labels
end

-- Get paths for each tab’s active buffer and shorten them.
local function get_tabline_labels(tabs)
  local paths = {}

  for _, tab in ipairs(tabs) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    table.insert(paths, name ~= '' and name or '[No Name]')
  end

  return generate_unique_tabline_labels(paths)
end

-- Tabline rendering function.
function _G.my_tabline()
  local s = ''
  local tabs = vim.api.nvim_list_tabpages()
  local current = vim.api.nvim_get_current_tabpage()

  local labels = get_tabline_labels(tabs)

  for i, tab in ipairs(tabs) do
    local hl = (tab == current) and '%#TabLineSel#' or '%#TabLine#'
    s = s .. hl
    s = s .. '%' .. i .. 'T'
    s = s .. ' ' .. i .. ' ' .. labels[i] .. ' '
  end

  s = s .. '%#TabLineFill#%T'

  return s
end

vim.opt.tabline = '%!v:lua.my_tabline()'

-- Installs `lazy.nvim` plugin manager.
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

---@diagnostic disable: missing-fields
require('lazy').setup {
  -- Allow plugins to add their own repeats onto . mapping.
  'tpope/vim-repeat',

  -- Add/delete/replace surroundings (brackets, quotes, etc.).
  'tpope/vim-surround',

  -- Detect tabstop and shiftwidth automatically.
  'tpope/vim-sleuth',

  -- Bracket mappings.
  'tpope/vim-unimpaired',

  -- UNIX helpers in command mode.
  'tpope/vim-eunuch',

  -- Helpers for modifying word under the cursor.
  'tpope/vim-abolish',

  {
    -- Continuously updated session files.
    'tpope/vim-obsession',
    config = function()
      local function S()
        local obsessions_dir = vim.fn.expand '~/.obsessions'

        vim.fn.mkdir(obsessions_dir, 'p')

        local session_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
        local path = obsessions_dir .. '/' .. session_name .. '.vim'

        if vim.fn.filereadable(path) == 0 then
          vim.cmd('Obsession ' .. vim.fn.fnameescape(path))
        else
          vim.cmd 'Obsession!'
        end
      end

      vim.api.nvim_create_user_command('S', S, {})
    end,
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '-' },
        topdelete = { text = '-' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end)

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end)

        map('n', '<leader>b', gitsigns.blame_line)
        map('n', '<leader>B', gitsigns.blame)
      end,
    },
  },

  { -- Adds marks to the gutter.
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {
      builtin_marks = {
        -- Position where the cursor was the last time.
        '^',
        -- Position where the last change was made.
        '.',
        -- Last selected visual area.
        '<',
        '>',
      },
    },
    -- mappings:
    -- dmx Delete mark x
    -- dm<space> Delete all marks in the current buffer
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons' },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = {
              ['<Esc>'] = require('telescope.actions').close,
              ['<C-p>'] = require('telescope.actions').cycle_history_prev,
              ['<C-r>'] = require('telescope.actions').to_fuzzy_refine,
            },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<C-p>', builtin.find_files)
      vim.keymap.set('n', '//', builtin.live_grep)
      vim.keymap.set('n', '??', builtin.grep_string)
    end,
  },

  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      'saghen/blink.cmp',
    },
    config = function()
      -- Fixes not being able to run Mason installed language servers on NixOS by calling patchelf.
      local mason_registry = require 'mason-registry'
      mason_registry:on('package:install:success', function(pkg)
        pkg:get_receipt():if_present(function()
          local command = ('patchelf --print-interpreter %q'):format "$(grep -oE '/nix/store/[a-z0-9]+-neovim-unwrapped-[0-9]+.[0-9]+.[0-9]+/bin/nvim' $(which nvim))"
          local handle = io.popen(command)
          local interpreter
          if handle ~= nil then
            interpreter = handle:read '*a'
            handle:close()
          end

          local bin_path = ''

          if pkg.name == 'lua-language-server' then
            bin_path = pkg:get_install_path() .. '/libexec/bin/lua-language-server'
          end
          if pkg.name == 'stylua' then
            print('stylua path', pkg:get_install_path())
            bin_path = pkg:get_install_path() .. '/stylua'
          end

          if bin_path ~= '' then
            os.execute(('patchelf --set-interpreter %q %q'):format(interpreter, bin_path))
          end
        end)
      end)

      -- Brief aside: **What is LSP?**
      --
      -- LSP is an initialism you've probably heard, but might not understand what it is.
      --
      -- LSP stands for Language Server Protocol. It's a protocol that helps editors
      -- and language tooling communicate in a standardized fashion.
      --
      -- In general, you have a "server" which is some tool built to understand a particular
      -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
      -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
      -- processes that communicate with some "client" - in this case, Neovim!
      --
      -- LSP provides Neovim with features like:
      --  - Go to definition
      --  - Find references
      --  - Autocompletion
      --  - Symbol Search
      --  - and more!
      --
      -- Thus, Language Servers are external tools that must be installed separately from
      -- Neovim. This is where `mason` and related plugins come into play.
      --
      -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
      -- and elegantly composed help section, `:help lsp-vs-treesitter`

      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          -- NOTE: Remember that Lua is a real programming language, and as such it is possible
          -- to define small helper and utility functions so you don't have to repeat yourself.
          --
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under the cursor.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gD', function()
            vim.cmd 'vsplit'
            require('telescope.builtin').lsp_definitions()
          end, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`ts_ls`) will work just fine
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },

        ts_ls = {},

        eslint = {
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = bufnr,
              command = 'EslintFixAll',
            })
          end,
        },
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- You can press `g?` for help in this menu.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>p',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never'
        else
          lsp_format_opt = 'fallback'
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        html = { 'prettierd', 'prettier', stop_after_first = true },
        css = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier', stop_after_first = true },
      },
    },
  },

  { -- Completion.
    'saghen/blink.cmp',
    dependencies = {
      {
        'Kaiser-Yang/blink-cmp-dictionary',
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },

    -- Download pre-built Rust binary.
    version = '*',

    config = function()
      local source_priority = {
        lsp = 3,
        path = 2,
        buffer = 1,
        dictionary = 0,
      }

      require('blink-cmp').setup {
        completion = {
          documentation = {
            auto_show = true,
          },
        },

        fuzzy = {
          implementation = 'prefer_rust_with_warning',

          sorts = {
            function(a, b)
              local a_priority = source_priority[a.source_id]
              local b_priority = source_priority[b.source_id]
              if a_priority ~= b_priority then
                return a_priority > b_priority
              end
            end,
            -- defaults
            'score',
            'sort_text',
          },
        },

        keymap = {
          preset = 'enter',

          ['<Tab>'] = { 'show', 'select_next', 'fallback' },
          ['<S-Tab>'] = { 'select_prev', 'fallback' },
        },

        signature = {
          enabled = true,
        },

        sources = {
          default = { 'lsp', 'path', 'buffer', 'dictionary' },

          providers = {
            lsp = {
              -- async = true,
            },

            path = {
              opts = {
                -- Completion from cwd instead of current buffer's parent dir.
                get_cwd = function(_)
                  return vim.fn.getcwd()
                end,
              },
            },

            buffer = {
              max_items = 10,
              opts = {
                -- Completion from all buffers.
                get_bufnrs = function()
                  return vim.tbl_filter(function(bufnr)
                    return vim.bo[bufnr].buftype == ''
                  end, vim.api.nvim_list_bufs())
                end,
              },
            },

            dictionary = {
              module = 'blink-cmp-dictionary',
              name = 'Dict',
              min_keyword_length = 3,
              max_items = 10,
              opts = {
                dictionary_files = function()
                  return { vim.fn.expand '~/Dropbox/Assets/english-words.txt' }
                end,
              },
            },
          },

          per_filetype = {
            codecompanion = { 'codecompanion' },
          },
        },
      }
    end,
  },

  { -- Snippets.
    'L3MON4D3/LuaSnip',
    config = function()
      require('luasnip.loaders.from_snipmate').lazy_load()

      local ls = require 'luasnip'

      vim.keymap.set({ 'i' }, '<C-s>', function()
        ls.expand()
      end, { silent = true })
    end,
  },

  -- Highlight TODO, FIXME etc..
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  { -- Commenting.
    'numToStr/Comment.nvim',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      local pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      require('Comment').setup {
        pre_hook = pre_hook,
      }
    end,
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup {
        n_lines = 500,
        search_method = 'cover_or_nearest',
      }

      local CTRL_S = vim.api.nvim_replace_termcodes('<C-S>', true, true, true)
      local CTRL_V = vim.api.nvim_replace_termcodes('<C-V>', true, true, true)

      local modes = {
        ['n'] = { name = 'Normal', hl = 'StatuslineModeNormal' },
        ['v'] = { name = 'Visual', hl = 'StatuslineModeVisual' },
        ['V'] = { name = 'V-Line', hl = 'StatuslineModeVisual' },
        [CTRL_V] = { name = 'V-Block', hl = 'StatuslineModeVisual' },
        ['s'] = { name = 'Select', hl = 'StatuslineModeVisual' },
        ['S'] = { name = 'S-Line', hl = 'StatuslineModeVisual' },
        [CTRL_S] = { name = 'S-Block', hl = 'StatuslineModeVisual' },
        ['i'] = { name = 'Insert', hl = 'StatuslineModeInsert' },
        ['R'] = { name = 'Replace', hl = 'StatuslineModeReplace' },
        ['c'] = { name = 'Command', hl = 'StatuslineModeCommand' },
        ['r'] = { name = 'Prompt', hl = 'StatuslineModeOther' },
        ['!'] = { name = 'Shell', hl = 'StatuslineModeOther' },
        ['t'] = { name = 'Terminal', hl = 'StatuslineModeOther' },
      }

      local statusline = require 'mini.statusline'

      local section_mode = function()
        local icon = ''
        local mode_info = modes[vim.fn.mode()]

        return icon, mode_info.hl
      end

      local sign_levels = {
        { name = 'added', text = '+', hl = 'GitSignsAdd' },
        { name = 'changed', text = '~', hl = 'GitSignsChange' },
        { name = 'removed', text = '-', hl = 'GitSignsDelete' },
      }

      local section_git = function(args)
        if MiniStatusline.is_truncated(args.trunc_width) then
          return ''
        end

        if vim.b.gitsigns_head == nil then
          return ''
        end

        local t = {}
        for _, sign in ipairs(sign_levels) do
          local n = vim.b.gitsigns_status_dict[sign.name] or 0
          if n > 0 then
            table.insert(t, ' %#' .. sign.hl .. '#' .. sign.text .. n .. '%*')
          end
        end

        return '%#TabLineSel# ' .. vim.b.gitsigns_head .. ' %*' .. (#t == 0 and '' or (table.concat(t, '') .. ' '))
      end

      local section_location = function()
        return '%l:%v/%L'
      end

      local diagnostic_levels = {
        { name = 'ERROR', text = 'E', hl = 'DiagnosticVirtualTextError' },
        { name = 'WARN', text = 'W', hl = 'DiagnosticVirtualTextWarn' },
        { name = 'INFO', text = 'I', hl = 'DiagnosticVirtualTextInfo' },
        { name = 'HINT', text = 'H', hl = 'DiagnosticVirtualTextHint' },
      }
      local diagnostic_counts = {}

      local get_diagnostic_count = function(buf_id)
        local res = {}
        for _, d in ipairs(vim.diagnostic.get(buf_id)) do
          res[d.severity] = (res[d.severity] or 0) + 1
        end
        return res
      end

      local track_diagnostics = vim.schedule_wrap(function(data)
        diagnostic_counts[data.buf] = vim.api.nvim_buf_is_valid(data.buf) and get_diagnostic_count(data.buf) or nil
        vim.cmd 'redrawstatus'
      end)
      vim.api.nvim_create_autocmd('DiagnosticChanged', { pattern = '*', callback = track_diagnostics })

      local section_diagnostics = function(args)
        if MiniStatusline.is_truncated(args.trunc_width) then
          return ''
        end

        local count = diagnostic_counts[vim.api.nvim_get_current_buf()]
        if count == nil then
          return ''
        end

        local t = {}
        for _, level in ipairs(diagnostic_levels) do
          local n = count[vim.diagnostic.severity[level.name]] or 0
          if n > 0 then
            table.insert(t, ' %#' .. level.hl .. '#[' .. level.text .. n .. ']%*')
          end
        end
        if #t == 0 then
          return ''
        end

        return table.concat(t, '')
      end

      statusline.setup {
        use_icons = false,
        content = {
          active = function()
            local mode, mode_hl = section_mode()
            local diagnostics = section_diagnostics { trunc_width = 75 }
            local filename = MiniStatusline.section_filename { trunc_width = 140 }
            local git = section_git { trunc_width = 40 }
            local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
            local location = section_location()
            local search = MiniStatusline.section_searchcount { trunc_width = 75 }

            return MiniStatusline.combine_groups {
              { hl = mode_hl, strings = { mode } },
              '%<', -- Mark general truncate point
              { hl = 'MiniStatuslineFilename', strings = { filename, git } },
              '%=', -- End left alignment
              { strings = { diagnostics, fileinfo } },
              { hl = 'TabLineSel', strings = { search, location } },
            }
          end,
        },
      }
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'clojure',
        'cmake',
        'comment',
        'cpp',
        'c_sharp',
        'css',
        'dart',
        'diff',
        'dockerfile',
        'elixir',
        'go',
        'html',
        'html',
        'java',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'php',
        'po',
        'python',
        'query',
        'query',
        'regex',
        'rst',
        'ruby',
        'rust',
        'scss',
        'sql',
        'terraform',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

  { -- Smooth scrolling.
    'karb94/neoscroll.nvim',
    opts = {
      duration_multiplier = 2 / 3,
      easing = 'cubic',
    },
  },

  { -- File explorer.
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<Tab>', ':Neotree reveal<CR>', silent = true },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
        },
        window = {
          mappings = {
            ['<Tab>'] = 'close_window',
            -- Keep the regular search, don't go into filter mode.
            ['/'] = 'noop',
          },
        },
      },
      window = {
        width = 60,
      },
      event_handlers = {
        {
          event = 'file_open_requested',
          handler = function()
            require('neo-tree.command').execute { action = 'close' }
          end,
        },
      },
    },
  },

  { -- Auto-close delimiters.
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },

  { -- Moves the argument to left or right side.
    'AndrewRadev/sideways.vim',
    keys = {
      { '<leader>,', ':SidewaysLeft<CR>' },
      { '<leader>.', ':SidewaysRight<CR>' },
    },
  },

  { -- Switch segments of text with predefined replacements.
    'AndrewRadev/switch.vim',
  },

  { -- Indent guides.
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = { '┆', '┇' },
      },
      scope = {
        enabled = true,
        highlight = 'NonText',
        show_start = false,
        show_end = false,
      },
    },
    config = function(_, opts)
      local hooks = require 'ibl.hooks'
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)

      require('ibl').setup(opts)
    end,
  },

  { -- Edit GPG encrypted files.
    'jamessan/vim-gnupg',
  },

  { -- Handle line and column numbers in file names.
    'kopischke/vim-fetch',
  },

  {
    -- Multi-line support for f, F, t & T.
    'dahu/vim-fanfingtastic',
  },

  { -- Colorscheme.
    'EdenEast/nightfox.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      local theme = os.getenv 'THEME'

      if theme == nil then
        vim.cmd.colorscheme 'nightfox'
        return
      end

      vim.cmd.colorscheme(theme)

      local function hi(hl, opts)
        local hl_opts = opts or {}

        if opts.fg then
          hl_opts.fg = os.getenv(opts.fg)
        end
        if opts.bg then
          hl_opts.bg = os.getenv(opts.bg)
        end

        vim.api.nvim_set_hl(0, hl, hl_opts)
      end

      hi('Normal', { bg = 'THEME_BG0' })
      hi('NormalNC', { bg = 'THEME_BG0' })

      hi('TabLine', { fg = 'THEME_FG1', bg = 'THEME_BG0' })
      hi('TabLineSel', { fg = 'THEME_WHITE', bg = 'THEME_BG3', bold = true })

      hi('IncSearch', { fg = 'THEME_BLACK', bg = 'THEME_YELLOW', bold = true })

      hi('StatuslineModeCommand', { fg = 'THEME_YELLOW', bg = 'THEME_BG0' })
      hi('StatuslineModeNormal', { fg = 'THEME_BLUE', bg = 'THEME_BG0' })
      hi('StatuslineModeInsert', { fg = 'THEME_GREEN', bg = 'THEME_BG0' })
      hi('StatuslineModeVisual', { fg = 'THEME_MAGENTA', bg = 'THEME_BG0' })
      hi('StatuslineModeReplace', { fg = 'THEME_RED', bg = 'THEME_BG0' })
      hi('StatuslineModeOther', { fg = 'THEME_ORANGE', bg = 'THEME_BG0' })
    end,
  },

  { -- Convert between color notations.
    'NTBBloodbath/color-converter.nvim',
    config = function()
      local color_converter = require 'color-converter'

      color_converter.setup {}

      vim.api.nvim_create_user_command('ColorConverterToHex', function()
        color_converter.to_hex()
      end, {})

      vim.api.nvim_create_user_command('ColorConverterToRgb', function()
        color_converter.to_rgb()
      end, {})

      vim.api.nvim_create_user_command('ColorConverterToHsl', function()
        color_converter.to_hsl()
      end, {})
    end,
  },

  {
    'olimorris/codecompanion.nvim',
    version = 'v18.5.1',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('codecompanion').setup {
        strategies = {
          chat = {
            adapter = 'anthropic',
            keymaps = {
              close = {
                -- Don't close on <C-c>
                modes = { n = '<Nop>', i = '<Nop>' },
              },
            },
          },
        },
        adapters = {
          acp = {
            opts = {
              show_presets = false,
            },
          },
        },
      }

      -- Toggle CodeCompanion chat buffer
      vim.keymap.set({ 'n' }, '<Leader>a', '<cmd>CodeCompanionChat Toggle<CR>', { noremap = true, silent = true })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd [[cab cc CodeCompanion]]

      -- TODO: https://codecompanion.olimorris.dev/configuration/prompt-library
    end,
  },
}

local function search_for_diff_marker()
  vim.cmd '/\\v[=><]{4,}'
end

vim.api.nvim_create_user_command('SearchForDiffMarker', search_for_diff_marker, {})

vim.api.nvim_create_user_command('ReverseLines', function(opts)
  if opts.range > 0 then
    -- Work with visual selection
    vim.cmd(string.format('%d,%dg/^/m%d', opts.line1, opts.line2, opts.line1 - 1))
  else
    -- Work with entire buffer
    vim.cmd 'g/^/m0'
  end
end, { range = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
