vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

vim.g.termfeatures = {
osc52 = false,
}

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

-- Paksa background transparan & garis batas/indent warna putih
local function set_transparent()
  vim.cmd [[
    hi Normal guibg=NONE ctermbg=NONE
    hi NormalNC guibg=NONE ctermbg=NONE
    hi SignColumn guibg=NONE ctermbg=NONE
    hi LineNr guibg=NONE ctermbg=NONE
    hi EndOfBuffer guibg=NONE ctermbg=NONE
    hi NvimTreeNormal guibg=NONE ctermbg=NONE
    hi NvimTreeNormalNC guibg=NONE ctermbg=NONE
    hi NvimTreeEndOfBuffer guibg=NONE ctermbg=NONE
    hi NvimTreeWinSeparator guifg=#FFFFFF guibg=NONE ctermfg=White ctermbg=NONE
    hi WinSeparator guifg=#FFFFFF guibg=NONE ctermfg=White ctermbg=NONE
    hi NvimTreeIndentMarker guifg=#FFFFFF guibg=NONE ctermfg=White ctermbg=NONE
    hi NormalFloat guibg=NONE ctermbg=NONE
    hi FloatBorder guifg=#FFFFFF guibg=NONE ctermfg=White ctermbg=NONE
  ]]
end

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("TransparentBg", { clear = true }),
  callback = set_transparent,
})



