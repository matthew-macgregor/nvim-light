-- ========================================================================== --
-- ==                           EDITOR SETTINGS                            == --
-- ========================================================================== --


-- Function to configure tab/space behavior
-- @param use_tabs bool: Whether to use tabs (true) or spaces (false)
-- @param width number: The width of indentation/distance between tab stops
function configure_indentation(use_tabs, width)
  if use_tabs then
    vim.opt.expandtab = false
    vim.opt.tabstop = width -- For visual appearance of tab characters
    vim.opt.softtabstop = width -- For max jump distance of manual tabs
    vim.opt.shiftwidth = 0 -- Use tabs indentation
  else
    vim.opt.expandtab = true
    vim.opt.tabstop = width -- For max jump distance of manual tabs
    vim.opt.shiftwidth = width -- For indentation
  end
end

-- Learn more about Neovim lua api
-- https://neovim.io/doc/user/lua-guide.html
-- https://vonheikemen.github.io/devlog/tools/build-your-first-lua-config-for-neovim/

vim.o.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.hlsearch = false
-- vim.o.tabstop = 2
-- vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.termguicolors = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.signcolumn = 'yes'
vim.o.colorcolumn = '79'
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
configure_indentation(true, 4)

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Space as leader key
vim.g.mapleader = ' '

-- Basic clipboard interaction
vim.keymap.set({'n', 'x'}, 'gy', '"+y', {desc = 'Copy to clipboard'})
vim.keymap.set({'n', 'x'}, 'gp', '"+p', {desc = 'Paste clipboard content'})

-- ========================================================================== --
-- ==                               PLUGINS                                == --
-- ========================================================================== --

local mini = {}

mini.branch = 'main'
mini.packpath = vim.fn.stdpath('data') .. '/site'

function mini.require_deps()
  local uv = vim.uv or vim.loop
  local mini_path = mini.packpath .. '/pack/deps/start/mini.nvim'

  if not uv.fs_stat(mini_path) then
    print('Installing mini.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/nvim-mini/mini.nvim',
      string.format('--branch=%s', mini.branch),
      mini_path
    })

    vim.cmd('packadd mini.nvim | helptags ALL')
  end

  local ok, deps = pcall(require, 'mini.deps')
  if not ok then
    return {}
  end

  return deps
end

local MiniDeps = mini.require_deps()
if not MiniDeps.setup then
  return
end

MiniDeps.add('folke/tokyonight.nvim')
MiniDeps.add('folke/which-key.nvim')
MiniDeps.add({
  source = 'nvim-mini/mini.nvim',
  checkout = mini.branch,
})

if vim.fn.has('nvim-0.11') == 1 then
  MiniDeps.add('neovim/nvim-lspconfig')
  MiniDeps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = {
      post_checkout = function()
        vim.cmd.TSUpdate()
      end,
    },
  })
else
  -- NOTE: These plugins no longer support older Neovim versions.
  -- If your Neovim version is below v0.11 they will be pinned to
  -- a version that still supports Neovim v0.9

  MiniDeps.add({
    source = 'neovim/nvim-lspconfig',
    checkout = 'v1.8.0',
  })
  MiniDeps.add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'v0.10.0',
  })
end

-- ========================================================================== --
-- ==                         PLUGIN CONFIGURATION                         == --
-- ========================================================================== --

vim.cmd.colorscheme('tokyonight')

-- See :help MiniIcons.config
-- Change style to 'glyph' if you have a font with fancy icons
require('mini.icons').setup({style = 'ascii'})

-- See :help MiniAi-textobject-builtin
require('mini.ai').setup({n_lines = 500})

-- See :help MiniComment.config
require('mini.comment').setup({})

-- See :help MiniSurround.config
require('mini.surround').setup({})

-- See :help MiniNotify.config
require('mini.notify').setup({
  lsp_progress = {enable = false},
})

-- See :help MiniBufremove.config
require('mini.bufremove').setup({})

-- Close buffer and preserve window layout
vim.keymap.set('n', '<leader>bc', '<cmd>lua pcall(MiniBufremove.delete)<cr>', {desc = 'Close buffer'})

-- See :help MiniFiles.config
local mini_files = require('mini.files')
mini_files.setup({})

-- Toggle file explorer
-- See :help MiniFiles-navigation
vim.keymap.set('n', '<leader>e', function()
  if mini_files.close() then
    return
  end

  mini_files.open()
end, {desc = 'File explorer'})

-- See :help MiniPick.config
require('mini.pick').setup({})

-- See available pickers
-- :help MiniPick.builtin
-- :help MiniExtra.pickers
vim.keymap.set('n', '<leader>?', '<cmd>Pick oldfiles<cr>', {desc = 'Search file history'})
vim.keymap.set('n', '<leader><space>', '<cmd>Pick buffers<cr>', {desc = 'Search open files'})
vim.keymap.set('n', '<leader>ff', '<cmd>Pick files<cr>', {desc = 'Search all files'})
vim.keymap.set('n', '<leader>fg', '<cmd>Pick grep_live<cr>', {desc = 'Search in project'})
vim.keymap.set('n', '<leader>fd', '<cmd>Pick diagnostic<cr>', {desc = 'Search diagnostics'})
vim.keymap.set('n', '<leader>fs', '<cmd>Pick buf_lines<cr>', {desc = 'Buffer local search'})

-- See :help MiniStatusline.config
require('mini.statusline').setup({})

-- See :help MiniExtra
require('mini.extra').setup({})

-- See :help MiniSnippets.config
require('mini.snippets').setup({})

-- See :help MiniCompletion.config
require('mini.completion').setup({})

-- See :help which-key.nvim-which-key-setup
require('which-key').setup({
  icons = {
    mappings = false,
    keys = {
      Space = 'Space',
      Esc = 'Esc',
      BS = 'Backspace',
      C = 'Ctrl-',
    },
  },
})

require('which-key').add({
  {'<leader>f', group = 'Fuzzy Find'},
  {'<leader>b', group = 'Buffer'},
})

-- Treesitter setup
local ts_parsers = {'lua', 'vim', 'vimdoc', 'c', 'query', 'python'}

if vim.fn.has('nvim-0.11') == 1 then
  require('nvim-treesitter').install(ts_parsers)

  local ts = vim.treesitter
  local ts_filetypes = vim.iter(ts_parsers)
    :map(ts.language.get_filetypes)
    :flatten()
    :fold({}, function(tbl, v)
      tbl[v] = true
      return tbl
    end)

  vim.api.nvim_create_autocmd('FileType', {
    desc = 'enable treesitter',
    callback = function(event)
      local ft = event.match
      if ts_filetypes[ft] == nil then
        return
      end

      local lang = ts.language.get_lang(ft)
      local ok, hl = pcall(ts.query.get, lang, 'highlights')

      if ok and hl then
        ts.start(event.buf, lang)
      end
    end,
  })
else
  -- This setup method only works for nvim-treesitter `v0.10.0`
  -- which should only be downloaded if neovim's version is below v0.11
  require('nvim-treesitter.configs').setup({
    highlight = {enable = true},
    ensure_installed = ts_parsers,
  })
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}

    -- These keymaps will become defaults after Neovim v0.11
    -- I've added them here for backwards compatibility
    vim.keymap.set('n', 'grr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gri', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'grt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'grn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set('n', 'gra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    vim.keymap.set('n', 'gO', '<cmd>lua vim.lsp.buf.document_symbol()<cr>', opts)
    vim.keymap.set({'i', 's'}, '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)

    -- These are custom keymaps
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'grd', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
  end,
})

vim.lsp.enable('lua_ls')
vim.lsp.enable('pyright')


local starter = require('mini.starter')
starter.setup({
  evaluate_single = true,
  items = {
    starter.sections.builtin_actions(),
    starter.sections.recent_files(10, false),
    starter.sections.recent_files(10, true),
    -- Use this if you set up 'mini.sessions'
    -- starter.sections.sessions(5, true)
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.indexing('all', { 'Builtin actions' }),
    starter.gen_hook.padding(3, 2),
  },
})
