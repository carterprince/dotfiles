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

    -- Treesitter (Syntax Highlighting)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            highlight = { 
                enable = true, 
                additional_vim_regex_highlighting = { "markdown" } 
            },
            indent = { enable = true },
            ensure_installed = { "bash", "c", "lua", "markdown", "python", "vim" },
        },
        config = function(_, opts)
            require("nvim-treesitter.config").setup(opts)
        end,
    },
    
    -- Fuzzy finder
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
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
        vim.cmd.colorscheme("tokyonight")
      end
    }
})

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
map("n", "M", ":!run %<CR>")
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
    
    for i, line in ipairs(lines) do
        -- Only number non-empty lines
        if not line:match("^%s*$") then
            line = line:gsub("^%s*[%d-*+]+%.?%s*", "") -- Remove existing bullets
            line = line:gsub("^%s*(.-)%s*$", "%1")     -- Trim whitespace
            lines[i] = i .. ". " .. line
        end
    end
    
    vim.api.nvim_buf_set_lines(buf, start_line - 1, end_line, false, lines)
end, {range = true})
map('v', '<C-n>', ':NumberMarkdownList<CR>')

-- Highlight URLs
vim.api.nvim_set_hl(0, "@markup.link.url", { fg = "#7aa2f7" })

-- my genius bullet hack
vim.api.nvim_set_hl(0, "MarkdownBullet", { fg = "#ff9e64" })
local ns = vim.api.nvim_create_namespace("")
vim.api.nvim_create_autocmd({"CursorMoved", "TextChanged", "BufEnter"}, {
    pattern = "*.md",
    callback = function()
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
        local cur = vim.fn.line(".") - 1
        for i, l in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, 0)) do
            local w = l:match("^(%s*)[-*+] ")
            if w and i - 1 ~= cur then
                vim.api.nvim_buf_set_extmark(0, ns, i - 1, #w, {
                    virt_text = {{"•", "MarkdownBullet"}}, virt_text_pos = "overlay"
                })
            end
        end
    end
})


local man_group = vim.api.nvim_create_augroup("ManResize", { clear = true })
local resize_timer = nil

vim.api.nvim_create_autocmd("VimResized", {
    group = man_group,
    pattern = "*",
    callback = function()
        if vim.bo.filetype ~= "man" then return end

        -- Kill any existing timer to prevent spamming
        if resize_timer then
            vim.loop.timer_stop(resize_timer)
        end

        -- Create a new timer that waits 100ms after the last resize event
        resize_timer = vim.loop.new_timer()
        resize_timer:start(100, 0, vim.schedule_wrap(function()
            if vim.api.nvim_buf_is_valid(0) and vim.bo.filetype == "man" then
                local view = vim.fn.winsaveview()
                
                -- Use the 'Man' command directly with the current buffer name (URI)
                -- We escape it to handle parentheses correctly
                local name = vim.fn.fnameescape(vim.fn.expand("%"))
                vim.cmd("silent! Man " .. name)
                
                vim.fn.winrestview(view)
            end
        end))
    end,
})
