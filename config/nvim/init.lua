-- carter's init.lua: Rawdog Edition (no LSP, focus on native features)

-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Helper function for key mappings
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- Basic settings
vim.g.mapleader = ","
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.synmaxcol = 10000

-- Clipboard settings
vim.opt.clipboard:append { "unnamedplus" }
vim.opt.shortmess:append("A")

-- Editor settings
vim.opt.number = true
vim.opt.linebreak = true
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.conceallevel = 3
vim.opt.hidden = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10

-- Visual and Search Improvements
vim.opt.relativenumber = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.laststatus = 3

-- Swap and undo settings
vim.opt.swapfile = false
vim.opt.autoread = true
vim.opt.undofile = true
vim.opt.foldenable = false
local undodir = vim.fn.stdpath("config") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir
vim.filetype.add({ extension = { ok = "python" } })

-- Mouse configuration
vim.opt.mouse = "a"
vim.opt.mousemodel = "popup_setpos"

-- Plugin setup
require("lazy").setup({
    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup {
                git = { enable = false },
                filters = {
                    custom = { "^.git$", "^.obsidian$", "^.Trash.*$" }
                }
            }
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvim-treesitter").setup()

            -- install parsers
            require("nvim-treesitter").install({
                "bash", "c", "lua", "markdown", "markdown_inline",
                "python", "vim", "html", "css", "javascript",
            })

            -- enable highlighting + indent per filetype
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "bash", "c", "lua", "markdown", "python", "vim", "html", "css", "javascript" },
                callback = function()
                    vim.treesitter.start()
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
    
    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        config = function()
            require('telescope').setup({
                pickers = {
                    colorscheme = { enable_preview = true },
                },
            })
        end,
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        },
    },

    -- the missing motion
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },
    
    -- Status line
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = true,
    },

    -- Theme
    {
      "folke/tokyonight.nvim",
      config = function()
        require("tokyonight").setup({
          style = "night",
          transparent = true,
          styles = {
            comments = { italic = true },
            keywords = { italic = false },
          }
        })
      end
    },

    {
      "catppuccin/nvim",
      name = "catppuccin",
      config = function()

        require("catppuccin").setup({
          flavour = "mocha",
          transparent_background = true,
          styles = {
            comments = { "italic" },
            keywords = {},
          }
        })
        vim.cmd.colorscheme("catppuccin-macchiato")
      end
    },

    {
      "rose-pine/neovim",
      name = "rose-pine",
    },

    {
      "rebelot/kanagawa.nvim",
      name = "kanagawa",
    },

    {
      "projekt0n/github-nvim-theme",
      name = "github-theme",
    },

    {
      "miikanissi/modus-themes.nvim",
      name = "modus-themes",
    },

    {
      "EdenEast/nightfox.nvim",
      name = "nightfox",
    },
})

-- Override :colorscheme to use Telescope picker
vim.cmd("cnoreabbrev colorscheme Telescope colorscheme")

-- Key mappings
map("!", "<C-h>", "<C-w>")
map("n", "L", "ciw")
map("n", "<BS>", "<C-o>")
map("n", "K", ":nohlsearch<CR><Esc>")

-- Native Commenting (Requires Neovim 0.10+)
-- gcc comments a line, gc comments selection.
-- We remap <C-c> to
map("n", "<C-c>", "gcc", { remap = true })
map("v", "<C-c>", "gc", { remap = true })

-- NvimTree mappings
map("n", "<C-n>", ":NvimTreeFindFileToggle %:p:h<CR><Esc>")
map("n", "<C-h>", ":NvimTreeOpen %:p:h<CR><Esc>")
map("n", "<C-l>", ":NvimTreeClose<CR><Esc>")

-- Custom Workflow mappings
map("n", "W", "viwo<Esc>~h")
map("n", "<leader>q", ":q!<CR>")
map("n", "<leader>w", ":w!<CR>")
map("n", "gx", ":!xdg-open <C-R><C-A><CR><Esc>")
map("n", "0", "^")
map("n", "^", "0")

-- Remember cursor position when reopening files
vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
            vim.fn.setpos(".", vim.fn.getpos("'\""))
            vim.cmd("normal! zv")
        end
    end,
})

-- Markdown template for new posts
vim.api.nvim_create_augroup("MdTemplateAutoCmd", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  group = "MdTemplateAutoCmd",
  pattern = vim.fn.expand("~") .. "/.local/src/carterpage/content/posts/*.md",
  callback = function()
    local filename = vim.fn.expand("%:t:r")
    local title = filename:gsub("-", " "):gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    local date = os.date("%Y-%m-%d")
    local lines = {
      "---",
      'title: "' .. title .. '"',
      "date: " .. date,
      "---",
      ""
    }
    vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    vim.cmd("normal! G")
    vim.cmd("startinsert")
  end
})

-- Number selected lines with Ctrl-n (Fixed to skip empty lines)
vim.api.nvim_create_user_command('NumberMarkdownList', function()
    local buf = vim.api.nvim_get_current_buf()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")

    local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)

    local count = 0
    for i, line in ipairs(lines) do
        if not line:match("^%s*$") then
            count = count + 1
            line = line:gsub("^%s*%d+%.%s*", "")  -- strip "1. " style
            line = line:gsub("^%s*[-*+]%s*", "")  -- strip "- " / "* " / "+ " style
            line = line:gsub("^%s*(.-)%s*$", "%1") -- trim
            lines[i] = count .. ". " .. line
        end
    end

    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, lines)
end, {range = true})
map('v', '<C-n>', ':NumberMarkdownList<CR>')

-- Highlight URLs
vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#7aa2f7" })
