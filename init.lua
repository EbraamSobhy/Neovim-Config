--  Neovim Lua Config
--  Safe for: 0.11+ / 0.12
--  Security-first, production-ready

-- Leader key (before everything)
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"
vim.g.mkdp_browser = 'brave'

-- SECURITY: Disable unsafe built-ins
vim.g.loaded_netrw       = 1   -- disable netrw (network file access)
vim.g.loaded_netrwPlugin = 1
vim.o.modeline           = false  -- CRITICAL: prevents files from injecting vim commands
vim.o.modelineexpr       = false  -- extra modeline safety (0.9+)
vim.o.exrc               = false  -- disable per-project .nvimrc (can be exploited)

-- SECURITY: Safe file handling

-- Redirect swap/undo/backup away from project dirs
-- so they never appear in Git repos or leak secrets
local state_dir = vim.fn.stdpath("state")

vim.opt.swapfile   = true
vim.opt.directory  = state_dir .. "/swap//"    -- // = full-path encoding (no collisions)
vim.opt.undofile   = true
vim.opt.undodir    = state_dir .. "/undo//"
vim.opt.backup     = false   -- no .bak files sitting next to your code
vim.opt.writebackup= false   -- no temporary backup during write
vim.opt.guicursor = "n-v-c-i-ci-ve-r-cr-o:block"

-- Ensure directories exist
for _, dir in ipairs({
  state_dir .. "/swap",
  state_dir .. "/undo",
}) do
  vim.fn.mkdir(dir, "p")
end

-- UI / Statusline
vim.o.laststatus  = 3       -- global statusline
vim.o.showmode    = true
vim.o.ruler       = false
vim.o.winborder   = "none"  -- rounded floats (0.11+, replaces handler overrides)

-- Terminal title
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern  = "*",
  callback = function()
    vim.o.title       = true
    vim.o.titlestring = "%f"
  end,
})

-- General settings
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.tabstop        = 4
vim.opt.shiftwidth     = 4
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.wrap           = false
vim.opt.termguicolors  = true
vim.opt.cursorline     = false
vim.opt.scrolloff      = 8
vim.opt.signcolumn     = "yes"
vim.opt.updatetime     = 250   -- faster CursorHold / diagnostics
vim.opt.timeoutlen     = 300

-- SECURITY: Don't sync clipboard automatically
-- (prevents accidental token/password exposure via yanks)
-- Use explicit "+y / "+p instead (keymaps below)
-- vim.opt.clipboard = "unnamedplus"   <-- intentionally disabled

-- Keymaps

-- Clipboard: explicit opt-in only (security-conscious)
vim.keymap.set("v", "<C-c>",      '"+y',       { desc = "Copy to system clipboard" })
vim.keymap.set("n", "<C-v>",      '"+p',       { desc = "Paste from system clipboard" })
vim.keymap.set("i", "<C-v>",      "<C-r>+",    { desc = "Paste in insert mode" })

--  shift + Insert paste
vim.opt.clipboard = "unnamedplus"

vim.keymap.set("n", "<S-Insert>", '"+p',    { desc = "Paste from clipboard" })
vim.keymap.set("i", "<S-Insert>", "<C-r>+", { desc = "Paste from clipboard in insert mode" })
vim.keymap.set("v", "<S-Insert>", '"+p',    { desc = "Paste from clipboard in visual mode" })

-- Undo
vim.keymap.set("n", "<C-z>",      "u",          { desc = "Undo" })
vim.keymap.set("i", "<C-z>",      "<Esc>ui",   { desc = "Undo in insert mode" })

-- File ops
vim.keymap.set("n", "<leader>w",  ":w<CR>",                    { desc = "Save file" })
vim.keymap.set("n", "<leader>q",  ":q<CR>",                    { desc = "Quit" })
vim.keymap.set("n", "<leader>e",  ":NvimTreeToggle<CR>",       { desc = "Toggle file explorer" })
vim.keymap.set("n", "<leader>f",  ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>g",  ":Telescope live_grep<CR>",  { desc = "Search in files" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- MarkdownPreview
vim.keymap.set("n", "<leader>m", ":MarkdownPreview<CR>", { desc = "Markdown preview" })
vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/markdown/preview.css")

-- Select word + change all occurrences
vim.keymap.set("n", "<C-d>", "*Ncgn", { desc = "Select and change next occurrence" })

-- split right a tab
vim.keymap.set("n", "<leader>r", "<C-w>v", { desc = "Split right" })

-- Enable filetype detection
vim.filetype.add({
  pattern = {
    [".*Makefile.*"] = "make",
  },
})

-- Recommended settings for Makefiles
vim.api.nvim_create_autocmd("FileType", {
  pattern = "make",
  callback = function()
    -- Makefiles require real tabs
    vim.opt_local.expandtab = false
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Plugin manager: lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- vim.uv replaces deprecated vim.loop (removed in 0.12)
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({

  -- Theme
  {
    "Mofiqul/vscode.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      vim.o.background = "dark"
      require("vscode").setup({
        transparent     = true,
        italic_comments = true,
      })
      require("vscode").load()
    end,
  },

 -- JetBrainsMono Nerd Font Mono 
 {
  "echasnovski/mini.icons",
  version = false,
  lazy = false,
  priority = 999,
  config  = function()
    require("mini.icons").setup({
      file = {
        [".go"]         = { glyph = "", hl = "MiniIconsBlue"   },
        [".py"]         = { glyph = "", hl = "MiniIconsYellow" },
        [".js"]         = { glyph = "", hl = "MiniIconsYellow" },
        [".ts"]         = { glyph = "", hl = "MiniIconsBlue"   },
        [".tsx"]        = { glyph = "", hl = "MiniIconsBlue"   },
        [".jsx"]        = { glyph = "", hl = "MiniIconsYellow" },
        [".lua"]        = { glyph = "", hl = "MiniIconsBlue"   },
        [".md"]         = { glyph = "", hl = "MiniIconsWhite"  },
        [".json"]       = { glyph = "", hl = "MiniIconsYellow" },
        [".html"]       = { glyph = "", hl = "MiniIconsOrange" },
        [".css"]        = { glyph = "", hl = "MiniIconsBlue"   },
        [".env"]        = { glyph = "", hl = "MiniIconsYellow" },
        [".gitignore"]  = { glyph = "", hl = "MiniIconsOrange" },
        [".sh"]         = { glyph = "", hl = "MiniIconsGreen"  },
        [".yaml"]       = { glyph = "", hl = "MiniIconsOrange" },
        [".yml"]        = { glyph = "", hl = "MiniIconsOrange" },
        [".toml"]       = { glyph = "", hl = "MiniIconsOrange" },
        [".rs"]         = { glyph = "", hl = "MiniIconsOrange" },
        [".cpp"]        = { glyph = "", hl = "MiniIconsBlue"   },
        [".c"]          = { glyph = "", hl = "MiniIconsBlue"   },
        [".png"]        = { glyph = "", hl = "MiniIconsGreen"  },
        [".jpg"]        = { glyph = "", hl = "MiniIconsGreen"  },
        [".svg"]        = { glyph = "", hl = "MiniIconsYellow" },
        ["Dockerfile"]  = { glyph = "", hl = "MiniIconsBlue"   },
        ["Makefile"]    = { glyph = "", hl = "MiniIconsOrange" },
        [".sh"]          = { glyph = "", hl = "MiniIconsGreen"  },
        [".bash"]        = { glyph = "", hl = "MiniIconsGreen"  },
        [".zsh"]         = { glyph = "", hl = "MiniIconsGreen"  },
      },
         filename = {
            [".bashrc"]       = { glyph = "", hl = "MiniIconsGreen" },
            [".bash_profile"] = { glyph = "", hl = "MiniIconsGreen" },
            [".bash_aliases"] = { glyph = "", hl = "MiniIconsGreen" },
            [".bash_history"] = { glyph = "", hl = "MiniIconsGreen" },
            [".zshrc"]        = { glyph = "", hl = "MiniIconsGreen" },
            [".zsh_history"]  = { glyph = "", hl = "MiniIconsGreen" },
            [".profile"]      = { glyph = "", hl = "MiniIconsGreen" },
      },
        })
    -- Hook into nvim-tree so it uses mini.icons
    require("mini.icons").mock_nvim_web_devicons()
  end,
},

{
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- disable default mappings
    vim.g.VM_default_mappings = 0

    vim.g.VM_maps = {
      -- core
      ["Find Under"]         = "<C-d>",   -- select word under cursor / next occurrence
      ["Find Subword Under"] = "<C-d>",   -- works in visual mode too
      ["Select All"]         = "<C-A-d>", -- select all occurrences at once
      ["Skip Region"]        = "q",       -- skip current match, go to next
      ["Remove Region"]      = "Q",       -- remove current cursor

      -- cursor creation
      ["Add Cursor Down"]    = "<C-Down>", -- add cursor below
      ["Add Cursor Up"]      = "<C-Up>",   -- add cursor above

      -- exit
      ["Exit"]               = "<Esc>",   -- exit multi-cursor mode
    }
  end,
},

    -- Markdown Preview
{
  "iamcco/markdown-preview.nvim",
  cmd      = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft       = { "markdown" },
  build    = function() vim.fn.jobstart("cd app && npx --yes yarn install", { cwd = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim" }) end,
  config   = function()
    vim.g.mkdp_auto_close    = 1   -- auto close preview when leaving md buffer
    vim.g.mkdp_open_to_the_world = 0  -- SECURITY: localhost only, not exposed to network
    vim.g.mkdp_port          = ""  -- random port each time
    vim.g.mkdp_browser       = "brave-browser"  -- use system default browser
    vim.g.mkdp_preview_options = {
      disable_sync_scroll = 0,
      sync_scroll_type    = "middle",
    }
  end,
},

  -- File explorer
{
  "nvim-tree/nvim-tree.lua",
    dependencies = { "echasnovski/mini.icons" },
  lazy         = true,
  config       = function()
    require("nvim-tree").setup({
      view = {
        width          = 30,
        side           = "left",
        number         = false,
        relativenumber = false,
        signcolumn     = "no",
      },
      renderer = {
        root_folder_label    = ":~:s?$?/..?",
        highlight_opened_files = "name",
        highlight_git          = false,
        add_trailing           = false,
        indent_width           = 2,
        indent_markers = {
          enable = false,
        },
        icons = {
          webdev_colors = true,
          git_placement = "before",
          padding       = " ",
          symlink_arrow = " ➛ ",
          show = {
            file         = true,   -- show file icons like VSCode
            folder       = true,   -- show folder icons
            folder_arrow = true,   -- show collapse arrow
            git          = false,
          },
          glyphs = {
            default  = "",
            symlink  = "",
            folder = {
              arrow_closed = "",  -- VSCode-style chevron
              arrow_open   = "",
              default      = "",
              open         = "",
              empty        = "",
              empty_open   = "",
              symlink      = "",
              symlink_open = "",
            },
          },
        },
      },
      filters = {
        dotfiles = false,   -- show dotfiles like VSCode
        custom   = { "^.git$" },
      },
      diagnostics = { enable = false },
      git         = { enable = false },
      actions = {
        open_file = {
          quit_on_open  = true,   -- close tree when file selected
          resize_window = true,
        },
      },
      update_focused_file = {
        enable    = true,   -- highlight active file like VSCode
        update_root = false,
      },
    })

    -- VSCode-like colors
    vim.cmd([[
      highlight NvimTreeNormal           guibg=#000000 guifg=#CCCCCC
      highlight NvimTreeNormalNC         guibg=#000000
      highlight NvimTreeEndOfBuffer      guibg=#000000
      highlight NvimTreeRootFolder       guifg=#CCCCCC gui=bold
      highlight NvimTreeFolderName       guifg=#CCCCCC
      highlight NvimTreeOpenedFolderName guifg=#CCCCCC gui=bold
      highlight NvimTreeEmptyFolderName  guifg=#888888
      highlight NvimTreeFolderIcon       guifg=#C8C8C8
      highlight NvimTreeFileIcon         guifg=#CCCCCC
      highlight NvimTreeSpecialFile      guifg=#569CD6 gui=underline
      highlight NvimTreeIndentMarker     guifg=#444444
      highlight NvimTreeWinSeparator     guifg=#000000 guibg=#000000
      highlight NvimTreeCursorLine       guibg=NONE    gui=NONE

    ]])
  end,
},
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config       = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "vertical",
          layout_config   = { height = 0.9 },
          -- SECURITY: never show hidden .env / secret files by default
          file_ignore_patterns = {
            "%.env$", "%.env%..*", "node_modules/", "%.git/",
            "%.pem$", "%.key$", "%.p12$", "%.pfx$",
          },
        },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build  = ":TSUpdate",
    config = function()
      vim.treesitter.language.register("markdown", "mdx")
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "go", "python", "javascript", "typescript",
          "html", "css", "tsx", "json", "markdown", "markdown_inline","make", "svelte", "vue","rust",
        },
        sync_install = false,
        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true },
      })
    end,
  },

  -- Completion: blink.cmp
{
  "saghen/blink.cmp",
  version      = "1.*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
        keymap = {
    preset  = "default",
    ["<CR>"] = { "accept", "fallback" },
 },
    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        Text          = "", Class         = "",
        Function      = "", Interface     = "",
        Method        = "", Module        = "",
        Constructor   = "", Property      = "",
        Field         = "", Unit          = "",
        Variable      = "", Value         = "",
        Constant      = "", Enum          = "",
        EnumMember    = "", Keyword       = "",
        Snippet       = "", Color         = "",
        File          = "", Reference     = "",
        Folder        = "", Event         = "",
        Operator      = "", TypeParameter = "",
        Struct        = "",
      },
    },
    sources    = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      ghost_text    = { enabled = true },
      -- this disables the kind icon column entirely
      menu = {
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
          },
        },
      },
    },
    signature = { enabled = true },
  },
},
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({
        check_ts         = true,
        disable_filetype = { "TelescopePrompt", "vim" },
      })
    end,
  },

  -- Formatting: conform.nvim
  {
    "stevearc/conform.nvim",
    event  = { "BufWritePre" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescript      = { "prettier" },
          typescriptreact = { "prettier" },
          json            = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          python          = { "black" },
          go              = { "goimports", "gofumpt" },
          svelte = { "prettier" },
          vue = { "prettier" },
          rust = { "rustfmt" },
        },
        default_format_opts = { lsp_format = "fallback" },
        format_on_save      = { timeout_ms = 500 },
      })
    end,
  },

  -- Linting: nvim-lint
  {
    "mfussenegger/nvim-lint",
    event  = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        javascript      = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript      = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- LSP: Mason + mason-lspconfig v2
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls", "pyright", "gopls", "bashls",
        "jsonls", "html", "cssls", "tailwindcss", "emmet_ls","svelte","rust","rust_analyzer",
      },
      -- automatic_enable replaces the old handlers table (mason-lspconfig v2 / nvim 0.11+)
      automatic_enable = true,
    },
  },

  -- LSP keymaps & attach logic
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group    = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts   = { buffer = ev.buf }
          local client = vim.lsp.get_client_by_id(ev.data.client_id)

          vim.keymap.set("n", "gD",         vim.lsp.buf.declaration,    opts)
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,     opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,          opts)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>",      vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<space>wa",  vim.lsp.buf.add_workspace_folder,    opts)
          vim.keymap.set("n", "<space>wr",  vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<space>wl",  function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<space>D",   vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "<space>rn",  vim.lsp.buf.rename,          opts)
          vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references,      opts)

          -- Inlay hints (0.10+)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end
        end,
      })
    end,
  },

  -- Extras — all from well-known, audited sources
  { "maxmellon/vim-jsx-pretty",  ft = { "javascriptreact", "typescriptreact" } },

  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ user_default_options = { names = false } })
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function() require("Comment").setup() end,
  },

  -- Auto-save: debounced, modifiable-only
  -- NOTE: debounce raised to 1000ms to avoid writing half-edited
  -- secrets or broken syntax to disk on every keystroke
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup({
        enabled = true,
        execution_message = {
          message           = function() return "Saved " .. vim.fn.strftime("%H:%M:%S") end,
          dim               = 0.18,
          cleaning_interval = 1250,
        },
        trigger_events = { "InsertLeave", "TextChanged" },
        condition = function(buf)
          local fn    = vim.fn
          local utils = require("auto-save.utils.data")
          -- SECURITY: never auto-save .env or secret files
          local filename = fn.expand("%:t")
          local blocked  = { ".env", ".pem", ".key", ".p12", ".pfx" }
          for _, b in ipairs(blocked) do
            if filename == b or filename:match(b .. "$") then return false end
          end
          return fn.getbufvar(buf, "&modifiable") == 1
              and utils.not_in(filename, {})
        end,
        write_all_buffers = false,
        debounce_delay    = 1000,  -- raised from 135ms: safer for secrets
      })
    end,
  },

}, {
  -- lazy.nvim itself: hardened options
  checker = {
    enabled = true,   -- notify on plugin updates (security patches)
    notify  = true,
  },
  change_detection = {
    notify = true,    -- warn if init.lua changes on disk unexpectedly
  },
})

-- Custom highlights (after Lazy)
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern  = "*",
  callback = function()
    vim.cmd("hi StatusLine guibg=#000000 guifg=#FFFFFF")
    vim.cmd("hi ModeMsg    guibg=#000000 guifg=#FFFFFF")
    vim.cmd("hi BlinkCmpScrollBarThumb guibg=#000000")
    vim.cmd("hi BlinkCmpScrollBarGutter guibg=#000000")
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local is_dir = vim.fn.isdirectory(data.file) == 1
    if not is_dir then return end
    vim.cmd.cd(data.file)
    require("nvim-tree.api").tree.open()
  end,
})


-- Auto-close nvim-tree when it's the last window
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local tree_wins = {}
    local floating_wins = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") then
        table.insert(tree_wins, w)
      end
      if vim.api.nvim_win_get_config(w).relative ~= "" then
        table.insert(floating_wins, w)
      end
    end
    if #wins - #floating_wins - #tree_wins == 1 then
      for _, w in ipairs(tree_wins) do
        vim.api.nvim_win_close(w, true)
      end
    end
  end,
})

-- Auto-close when selecting a file (nvim-tree opens it, tree closes)
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match("NvimTree_") then return end  -- ignore tree itself
    local tree_api = require("nvim-tree.api")
    if tree_api.tree.is_visible() then
      tree_api.tree.close()
    end
  end,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, { border = "none" }
)

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern  = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#FFFFFF", bg = "#000000" })
    vim.api.nvim_set_hl(0, "WinSeparator",         { fg = "#FFFFFF", bg = "#000000" })
    vim.api.nvim_set_hl(0, "VertSplit",             { fg = "#FFFFFF", bg = "#000000" })
  end,
})

-- Force it immediately too
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#FFFFFF", bg = "#000000" })
vim.api.nvim_set_hl(0, "WinSeparator",         { fg = "#FFFFFF", bg = "#000000" })
vim.api.nvim_set_hl(0, "VertSplit",             { fg = "#FFFFFF", bg = "#000000" })
